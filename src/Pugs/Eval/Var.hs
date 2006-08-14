{-# OPTIONS_GHC -fglasgow-exts -cpp #-}

module Pugs.Eval.Var (
    findVar, findVarRef,
    findSub, inferExpType,  inferExpCxt, FindSubFailure(..),
    isQualified, packageOf, qualify,
    toPackage, toQualified,
) where
import qualified Data.Map as Map
import Pugs.Internals
import Pugs.AST
import Pugs.Types
import Pugs.Embed.Perl5
import Pugs.Bind
import Pugs.Prim.List (op2Reduce, op1HyperPrefix, op1HyperPostfix, op2Hyper)
import Pugs.Prim.Param (foldParam)
import Pugs.Pretty
import Pugs.Config
import Pugs.Monads
import qualified Pugs.Val as Val
import Pugs.Val hiding (Val, IValue, VUndef)

findVar :: Var -> Eval (Maybe VRef)
findVar (':':x:_) | x /= '*' = return Nothing
findVar name = do
    rv <- findVarRef name
    case rv of
        Nothing  -> case name of
            ('&':_) -> do
                sub <- findSub name Nothing []
                return $ either (const Nothing) (Just . codeRef) sub
            _ -> return Nothing
        Just ref -> fmap Just $ liftSTM (readTVar ref)

findVarRef :: Var -> Eval (Maybe (TVar VRef))
findVarRef name
    | Just (package, name') <- breakOnGlue "::" name
    = case () of
        _ | Just (sig, "") <- breakOnGlue "CALLER" package -> do
            maybeCaller <- asks envCaller
            case maybeCaller of
                Just env -> local (const env) $ do
                    rv <- findVarRef (sig ++ name')
                    return rv
                Nothing -> retError "cannot access CALLER:: in top level" name
        _ | Just (sig, "") <- breakOnGlue "ENV" package -> fix $ \upLevel -> do
            maybeCaller <- asks envCaller
            case maybeCaller of
                Just env -> local (const env) $ do
                    rv <- findVarRef (sig ++ name')
                    if isJust rv then return rv else upLevel
                Nothing -> do
                    -- final callback: try an "environment" lookup
                    -- XXX: how does "@+PATH" differ from "$+PATH"?
                    -- XXX: how to tell empty env from nonexistent env?
                    --      should we allow writes?
                    exists <- evalExp $ App (Var "&exists") (Just (Var "%*ENV")) [Val (VStr name')]
                    case exists of
                        VBool False -> do
                            retError "no such ENV:: variable" name'
                        _           -> do
                            rv   <- enterLValue (evalExp $ Syn "{}" [Var "%*ENV", Val (VStr name')])
                            tvar <- liftSTM . newTVar =<< fromVal rv
                            return (Just tvar)
        _ | Just (sig, "") <- breakOnGlue "OUTER" package -> do
            maybeOuter <- asks envOuter
            case maybeOuter of
                Just env -> local (const env) $ do
                    findVarRef (sig ++ name')
                Nothing -> retError "cannot access OUTER:: in top level" name
        _ -> doFindVarRef name
    | (sig:'+':name') <- name = findVarRef (sig:("ENV::"++name'))
    | (_:'?':_) <- name = do
        rv  <- getMagical name
        case rv of
            Nothing  -> doFindVarRef name
            Just val -> do
                tvar <- liftSTM $ newTVar (MkRef . constScalar $ val)
                return $ Just tvar
    | "%" <- name = do
        {- %CALLER::, %OUTER::, %Package::, etc, all recurse to here. -}
        pad <- asks envLexical
        let plist   = padToList pad
        hlist <- mapM padEntryToHashEntry plist
        let hash    = IHash $ Map.fromList hlist
        let hashref = MkRef hash
        tvar <- liftSTM $ newTVar hashref
        return $ Just tvar
    | otherwise = doFindVarRef name
    where
    padEntryToHashEntry :: (Var, [(TVar Bool, TVar VRef)]) -> Eval (VStr, Val)
    padEntryToHashEntry (key, (_, tvref) : _) = do
        vref   <- liftSTM (readTVar tvref)
        let val = VRef vref
        return (key, val)
    padEntryToHashEntry (_, []) = do fail "Nonexistant var in pad?"
    doFindVarRef :: Var -> Eval (Maybe (TVar VRef))
    doFindVarRef name = do
        callCC $ \foundIt -> do
            lexSym  <- fmap (findSym name . envLexical) ask
            when (isJust lexSym) $ foundIt lexSym
            glob    <- liftSTM . readTVar . envGlobal =<< ask
            name'   <- toQualified name
            -- XXX - find qualified name here
            let globSym = findSym name' glob
            when (isJust globSym) $ foundIt globSym
            let globSym = findSym (toGlobal name) glob
            when (isJust globSym) $ foundIt globSym
            return Nothing


{-|
  The findSub dispatch system:

  The Eval.Var findSub dispatch system was written before S12's
  dispatch order was specced clearly.  Back then there were no clear
  distinction between single and multiple dispatch, and so both were
  lumped in a single findSub loop.  So "$x.foo.bar" is no different
  from bar(foo($x)), rather, bar(foo($x:):).  But MMD dictates that
  you have to find which of the candidate &bar to be dispatched to
  before you fully evaluate its argument foo($x:) under its specified
  context.  But you can't find out which candidates of &bar to
  dispatch to, unless you know the type of foo($x).  That's a
  chicken-egg problem.  So I wrote a tiny type inferencer to guess a
  type of an Exp without actually evaluating its side effects.  The
  idea is that foo($x) is first inferred, then uses that inferred type
  to decide which bar() to call, and finally evaluate foo($x) in full.
  Using the argument type expected by bar().  But the infer engine
  didn't handle indexed expressions well.  $x[0] etc.  In any case,
  that tiny inferencer is obsolete under the new (November 2005) S12
  and docs/notes/multimethods.pod.  Which would be implemented at PIL
  layer.  The inferencer fix I just committed (r8874) for indexed
  expressions, just checks if both the indice and indexee are simple
  expressions (i.e. things that can be evaluated without side
  effects), and if so, it just evaluates them to find out their actual
  type.

-}

data FindSubFailure
    = NoMatchingMulti
    | NoSuchSub
    | NoSuchMethod !Type

findSub :: String     -- ^ Name, with leading @\&@.
        -> Maybe Exp  -- ^ Invocant
        -> [Exp]      -- ^ Other arguments
        -> Eval (Either FindSubFailure VCode)
findSub name' invs args = do
    case invs of
        Just _ | Just (package, name') <- breakOnGlue "::" name
               , Just (sig, "") <- breakOnGlue "SUPER" package -> do
            typ <- asks envPackage
            findSuperSub (mkType typ) (sig ++ name')
        Just exp | not (':' `elem` drop 2 name) -> case unwrap exp of
            Val inv@VV{}     -> withExternalCall callMethodVV inv 
            Val inv@PerlSV{} -> withExternalCall callMethodPerl5 inv 
            exp' -> do
                typ <- evalInvType exp'
                findTypedSub typ name
        _ -> findBuiltinSub NoSuchSub name

    where
    err :: b -> Maybe a -> Either b a
    err _ (Just j) = Right j
    err x Nothing  = Left x

    name = possiblyFixOperatorName name'

    findSuperSub :: Type -> String -> Eval (Either FindSubFailure VCode)
    findSuperSub typ name = do
        let pkg = showType typ
            qualified = (head name:pkg) ++ "::" ++ tail name
        subs    <- findWithSuper pkg name
        subs'   <- either (flip findBuiltinSub name) (return . Right) subs
        case subs' of
            Right sub | subName sub == qualified -> return (Left $ NoSuchMethod typ)
            _   -> return subs'
    findTypedSub :: Type -> String -> Eval (Either FindSubFailure VCode)
    findTypedSub typ name = do
        subs    <- findWithPkg (showType typ) name
        either (flip findBuiltinSub name) (return . Right) subs
    findBuiltinSub :: FindSubFailure -> String -> Eval (Either FindSubFailure VCode)
    findBuiltinSub failure name = do
        sub <- findSub' name
        maybe (fmap (err failure) $ possiblyBuildMetaopVCode name) (return . Right) sub
    evalInvType :: Exp -> Eval Type
    evalInvType x = inferExpType $ unwrap x

    withExternalCall callMeth inv = do
        fmap (err . NoSuchMethod $ valType inv) $ do
            metaSub <- possiblyBuildMetaopVCode name
            if isJust metaSub then return metaSub else callMeth

    callMethodVV :: Eval (Maybe VCode)
    callMethodVV = do
        let (_, methName) = breakSigil name
        -- Look up the proto for the method in VV land right here
        -- Whether it matched or not, it's the proto's signature
        -- that's available to the inferencer, not any of its children's
        -- (this is because MMD in newland is performed _after_ everything
        -- has been reduced.)
        return . Just $ mkPrim
            { subName     = methName
            , subParams   = makeParams ["Object", "List", "Named"]
            , subReturns  = mkType "Any"
            , subBody     = Prim $ \(inv:named:pos:_) -> do
                invVV   <- fromVal inv      :: Eval Val.Val
                posVVs  <- fromVals pos     :: Eval [Val.Val]
                namVVs  <- do
                    list <- fromVal named
                    fmap Map.fromList $ forM list $ \(k, v) -> do
                        key <- fromVal k
                        val <- fromVal v
                        return (key, [val])   :: Eval (ID, [Val.Val])

                -- This is the Capture object we are going to work with
                let capt = CaptMeth invVV [MkFeed posVVs namVVs]

                return . castV $ "CCall " ++ show methName ++ " " ++ show capt
            }

    callMethodPerl5 :: Eval (Maybe VCode)
    callMethodPerl5 = do
        return . Just $ mkPrim
            { subName     = name
            , subParams   = makeParams ["Object", "List", "Named"]
            , subReturns  = mkType "Scalar::Perl5"
            , subBody     = Prim $ \(inv:named:pos:_) -> do
                sv      <- fromVal inv
                posSVs  <- fromVals pos
                namSVs  <- fmap concat (fromVals named)
                let svs = posSVs ++ namSVs
                found   <- liftIO $ canPerl5 sv (tail name)
                found'  <- liftIO $ if found
                    then return found
                    else canPerl5 sv "AUTOLOAD"
                if not found'
                    then do
                        -- XXX - when svs is empty, this could call back here infinitely
                        --       add an extra '&' to force no-reinterpretation.
                        evalExp (App (Var ('&':name)) Nothing (map (Val . PerlSV) (sv:svs)))
                    else do
                        subSV   <- liftIO . vstrToSV $ tail name
                        runInvokePerl5 subSV sv svs
            }
    possiblyBuildMetaopVCode :: String -> Eval (Maybe VCode)
    possiblyBuildMetaopVCode op'' | "&prefix:[" `isPrefixOf` op'', "]" `isSuffixOf` op'' = do 
        -- Strip the trailing "]" from op
        let op' = drop 9 (init op'')
        let (op, keep) | '\\':real <- op' = (real, True)
                       | otherwise        = (op', False)
        -- We try to find the userdefined sub.
        -- We use the first two elements of invs as invocants, as these are the
        -- types of the op.
            rv = fmap (either (const Nothing) Just) $ findSub ("&infix:" ++ op) Nothing (take 2 $ args ++ [Val undef, Val undef])
        maybeM rv $ \code -> return $ mkPrim
            { subName     = "&prefix:[" ++ (if keep then "\\" else "") ++ op ++ "]"
            , subType     = SubPrim
            , subAssoc    = "spre"
            , subParams   = makeParams $
                if any isLValue (subParams code)
                    then ["rw!List"] -- XXX - does not yet work for the [=] case
                    else ["List"]
            , subReturns  = anyType
            , subBody     = Prim $ \[vs] -> do
                list_of_args <- fromVal vs
                op2Reduce keep list_of_args (VCode code)
            }
        -- Now we construct the sub. Is there a more simple way to do it?
    possiblyBuildMetaopVCode op' | "&prefix:" `isPrefixOf` op', "\171" `isSuffixOf` op' = do 
        let op = drop 8 (init op')
        possiblyBuildMetaopVCode ("&prefix:" ++ op ++ "<<")
    possiblyBuildMetaopVCode op' | "&prefix:" `isPrefixOf` op', "<<" `isSuffixOf` op' = do 
        let op = drop 8 (init (init op'))
            rv = fmap (either (const Nothing) Just) $ findSub ("&prefix:" ++ op) Nothing [head $ args ++ [Val undef]]
        maybeM rv $ \code -> return $ mkPrim
            { subName     = "&prefix:" ++ op ++ "<<"
            , subType     = SubPrim
            , subAssoc    = subAssoc code
            , subParams   = subParams code
            , subReturns  = mkType "List"
            , subBody     = Prim
                (\x -> op1HyperPrefix code (listArg x))
            }
    possiblyBuildMetaopVCode op' | "&postfix:\187" `isPrefixOf` op' = do
        let op = drop 10 op'
        possiblyBuildMetaopVCode ("&postfix:>>" ++ op)
    possiblyBuildMetaopVCode op' | "&postfix:>>" `isPrefixOf` op' = do
        let op = drop 11 op'
            rv = fmap (either (const Nothing) Just) $ findSub ("&postfix:" ++ op) Nothing [head $ args ++ [Val undef]]
        maybeM rv $ \code -> return $ mkPrim
            { subName     = "&postfix:>>" ++ op
            , subType     = SubPrim
            , subAssoc    = subAssoc code
            , subParams   = subParams code
            , subReturns  = mkType "List"
            , subBody     = Prim
                (\x -> op1HyperPostfix code (listArg x))
            }
    possiblyBuildMetaopVCode op' | "&infix:\187" `isPrefixOf` op', "\171" `isSuffixOf` op' = do 
        let op = drop 8 (init op')
        possiblyBuildMetaopVCode ("&infix:>>" ++ op ++ "<<")
    possiblyBuildMetaopVCode op' | "&infix:>>" `isPrefixOf` op', "<<" `isSuffixOf` op' = do 
        let op = drop 9 (init (init op'))
            rv = fmap (either (const Nothing) Just) $ findSub ("&infix:" ++ op) Nothing (take 2 (args ++ [Val undef, Val undef]))
        maybeM rv $ \code -> return $ mkPrim
            { subName     = "&infix:>>" ++ op ++ "<<"
            , subType     = SubPrim
            , subAssoc    = subAssoc code
            , subParams   = makeParams ["Any", "Any"]
            , subReturns  = mkType "List"
            , subBody     = Prim (\[x, y] -> op2Hyper code x y)
            }
        -- Taken from Pugs.Prim. Probably this should be refactored. (?)
    possiblyBuildMetaopVCode _ = return Nothing
    listArg [x] = x
    listArg xs = VList xs
    makeParams = map (\p -> p{ isWritable = isLValue p }) . foldr foldParam [] . map takeWord
    takeWord = takeWhile isWord . dropWhile (not . isWord)
    isWord   = not . (`elem` "(),:")
    findAttrs pkg = do
        maybeM (findVar (':':'*':pkg)) $ \ref -> do
            meta    <- readRef ref
            fetch   <- doHash meta hash_fetchVal
            fromVal =<< fetch "is"
    findWithPkg :: String -> String -> Eval (Either FindSubFailure VCode)
    findWithPkg pkg name = do
        subs <- findSub' (('&':pkg) ++ "::" ++ tail name)
        maybe (findWithSuper pkg name) (return . Right) subs
    findWithSuper :: String -> String -> Eval (Either FindSubFailure VCode)
    findWithSuper pkg name = do
        -- get superclasses
        attrs <- fmap (fmap (filter (/= pkg) . nub)) $ findAttrs pkg
        if isNothing attrs || null (fromJust attrs) then fmap (err NoMatchingMulti) (findSub' name) else do
        (`fix` (fromJust attrs)) $ \run pkgs -> do
            if null pkgs then return (Left $ NoSuchMethod $ mkType pkg) else do
            subs <- findWithPkg (head pkgs) name
            either (const $ run (tail pkgs)) (return . Right) subs
    findSub' :: String -> Eval (Maybe VCode)
    findSub' name = do
        subSyms     <- findSyms name
        lens        <- mapM argSlurpLen (unwrap $ maybeToList invs ++ args)
        doFindSub (sum lens) subSyms
    argSlurpLen :: Exp -> Eval Int
    argSlurpLen (Val val) = valSlurpLen val
    argSlurpLen (Var name) = do
        val <- evalExp (Var name)
        valSlurpLen val
    argSlurpLen (Syn "," list) =  return $ length list
    argSlurpLen _ = return 1 -- XXX

    valSlurpLen :: Val -> Eval Int
    valSlurpLen (VList list) = return $ length list
    valSlurpLen (VRef (MkRef (IArray av))) = array_fetchSize av
    valSlurpLen (VRef (MkRef (IHash hv))) = hash_fetchSize hv
    valSlurpLen _  = return 1 -- XXX

    doFindSub :: Int -> [(String, Val)] -> Eval (Maybe VCode)
    doFindSub slurpLen subSyms = do
        subs' <- subs slurpLen subSyms
        -- let foo (x, sub) = show x ++ show (map paramContext $ subParams sub)
        -- trace (unlines $ map foo $ sort subs') return ()
        return $ case sort subs' of
            ((_, sub):_)    -> Just sub
            _               -> Nothing
    subs :: Int -> [(String, Val)] -> Eval [((Bool, Bool, Int, Int), VCode)]
    subs slurpLen subSyms = fmap catMaybes . forM subSyms $ \(_, val) -> do
        sub@(MkCode{ subReturns = ret, subParams = prms }) <- fromVal val
        let rv = return $ arityMatch sub (length (maybeToList invs ++ args)) slurpLen
        maybeM rv $ \fun -> do
            -- if deltaFromCxt ret == 0 then return Nothing else do
            let pairs = map (typeOfCxt . paramContext) prms
                            `zip` (map unwrap $ maybeToList invs ++ args)
            deltaCxt    <- deltaFromCxt ret
            deltaArgs   <- mapM deltaFromPair pairs
            let bound = either (const False) (const True) $ bindParams sub invs args
            return ((isMulti sub, bound, sum deltaArgs, deltaCxt), fun)
    deltaFromCxt :: Type -> Eval Int
    deltaFromCxt x  = do
        cls <- asks envClasses
        cxt <- asks envContext
        return $ deltaType cls (typeOfCxt cxt) x
    deltaFromPair (x, y) = do
        cls <- asks envClasses
        typ <- inferExpType y
        return $ deltaType cls x typ

{-|
Take an expression, and attempt to predict what type it will evaluate to
/without/ actually evaluating it.
-}
inferExpType :: Exp -> Eval Type
inferExpType exp@(Var (_:'.':_)) = fromVal =<< evalExp exp
inferExpType exp@(Var (_:'!':_:_)) = fromVal =<< evalExp exp
inferExpType (Var var) = do
    rv  <- findVar var
    case rv of
        Nothing  -> return $ typeOfSigil (head var)
        Just ref -> do
            let typ = refType ref
            cls <- asks envClasses
            if isaType cls "List" typ
                then return typ
                else fromVal =<< readRef ref
inferExpType (Val val) = fromVal val
inferExpType (App (Val val) _ _) = do
    sub <- fromVal val
    return $ subReturns sub
inferExpType (App (Var "&new") (Just inv) _) = inferExpType $ unwrap inv
inferExpType (App (Var name) invs args) = do
    sub <- findSub name invs args
    case sub of
        Right sub    -> return $ subReturns sub
        Left _       -> return $ mkType "Any"
inferExpType (Ann (Cxt cxt) _) | typeOfCxt cxt /= (mkType "Any") = return $ typeOfCxt cxt
inferExpType (Ann (Cxt _) exp) = inferExpType exp
inferExpType (Ann (Pos _) exp) = inferExpType exp
inferExpType (Pad _ _ exp) = inferExpType exp
inferExpType (Sym _ _ exp) = inferExpType exp
inferExpType (Stmts _ exp) = inferExpType exp
inferExpType (Syn "," _)    = return $ mkType "List"
inferExpType (Syn "\\[]" _) = return $ mkType "Array"
inferExpType (Syn "\\{}" _) = return $ mkType "Hash"
inferExpType (Syn "&{}" _)  = return $ mkType "Code"
inferExpType (Syn "@{}" _)  = return $ mkType "Array"
inferExpType (Syn "%{}" _)  = return $ mkType "Hash"
inferExpType (Syn "=>" _)   = return $ mkType "Pair"
inferExpType exp@(Syn "{}" [_, idxExp]) = if isSimpleExp exp
    then fromVal =<< enterRValue (evalExp exp)
    else fmap typeOfCxt (inferExpCxt idxExp)
inferExpType exp@(Syn "[]" [_, idxExp]) = if isSimpleExp exp
    then fromVal =<< enterRValue (evalExp exp)
    else fmap typeOfCxt (inferExpCxt idxExp)
inferExpType (Syn "sub" [exp]) = inferExpType exp
inferExpType _ = return anyType

isSimpleExp :: Exp -> Bool
isSimpleExp Var{}           = True
isSimpleExp Val{}           = True
isSimpleExp (Ann _ x)       = isSimpleExp x
isSimpleExp (Syn _ xs)      = all isSimpleExp xs
isSimpleExp _               = False


{-|
Return the context that an expression bestows upon a hash or array
subscript. See 'reduce' for @\{\}@ and @\[\]@.
-}
inferExpCxt :: Exp -> Eval Cxt
inferExpCxt exp = return $ if isScalarLValue exp
    then cxtItemAny
    else cxtSlurpyAny
{-
inferExpCxt :: Exp -- ^ Expression to find the context of
         -> Eval Cxt
inferExpCxt (Ann (Pos {}) exp)           = inferExpCxt exp
inferExpCxt (Ann (Cxt cxt) _)            = return cxt
inferExpCxt (Syn "," _)            = return cxtSlurpyAny
inferExpCxt (Syn "[]" [_, exp])    = inferExpCxt exp
inferExpCxt (Syn "{}" [_, exp])    = inferExpCxt exp
inferExpCxt (Syn (sigil:"{}") _) = return $ cxtOfSigil sigil
inferExpCxt (Val (VList {}))       = return cxtSlurpyAny
inferExpCxt (Val (VRef ref))       = do
    cls <- asks envClasses
    let typ = refType ref
    return $ if isaType cls "List" typ
        then cxtSlurpyAny
        else CxtItem typ
inferExpCxt (Val {})                = return cxtItemAny
inferExpCxt (Var (sigil:_))         = return $ cxtOfSigil sigil
inferExpCxt (App (Var "&list") _ _) = return cxtSlurpyAny
inferExpCxt (App (Var "&item") _ _) = return cxtSlurpyAny
inferExpCxt (App (Var name) invs args)   = do
    -- inspect the return type of the function here
    env <- ask
    sub <- findSub name invs args
    return $ case sub of
        Right sub
            | isaType (envClasses env) "Scalar" (subReturns sub)
            -> CxtItem (subReturns sub)
        _ -> cxtSlurpyAny
inferExpCxt _                      = return cxtSlurpyAny
-}

{-|
Evaluate the \'magical\' variable associated with a given name. Returns 
@Nothing@ if the name does not match a known magical.
-}
getMagical :: String -- ^ Name of the magical var to evaluate
           -> Eval (Maybe Val)
getMagical "$?FILE"     = posSym posName
getMagical "$?LINE"     = posSym posBeginLine
getMagical "$?COLUMN"   = posSym posBeginColumn
getMagical "$?POSITION" = posSym pretty
getMagical "$?MODULE"   = constSym "main"
getMagical "$?OS"       = constSym $ getConfig "osname"
getMagical "$?CLASS"    = fmap (Just . VType . mkType) (asks envPackage)
getMagical ":?CLASS"    = fmap (Just . VType . mkType) (asks envPackage)
getMagical "$?PACKAGE"  = fmap (Just . VType . mkType) (asks envPackage)
getMagical ":?PACKAGE"  = fmap (Just . VType . mkType) (asks envPackage)
getMagical "$?ROLE"     = fmap (Just . VType . mkType) (asks envPackage)
getMagical ":?ROLE"     = fmap (Just . VType . mkType) (asks envPackage)
getMagical _            = return Nothing

posSym :: Value a => (Pos -> a) -> Eval (Maybe Val)
posSym f = fmap (Just . castV . f) $ asks envPos
constSym :: String -> Eval (Maybe Val)
constSym = return . Just . castV

findSyms :: Var -> Eval [(Var, Val)]
findSyms name = do
        runMaybeT (findLexical `mplus` findPackage `mplus` findGlobal) >>= \ret ->
            case ret of
                Nothing -> return []
                Just xs -> return xs
    where
        findLexical :: MaybeT Eval [(Var, Val)]
        findLexical = do
            lex <- lift $ asks envLexical
            padSym lex name
            
        findPackage :: MaybeT Eval [(Var, Val)]
        findPackage = do
            glob <- lift $ askGlobal
            pkg  <- lift $ asks envPackage
            padSym glob name `mplus` padSym glob (toPackage pkg name)

        findGlobal :: MaybeT Eval [(Var, Val)]
        findGlobal = do
            glob <- lift $ askGlobal
            padSym glob (toGlobal name)

        padSym :: Pad -> Var -> MaybeT Eval [(Var, Val)]
        padSym pad var = do
            case lookupPad var pad of
                Just tvar -> lift $ do
                    refs <- liftSTM $ mapM readTVar tvar
                    forM refs $ \ref -> do
                        val <- readRef ref
                        return (var, val)
                Nothing -> mzero
        

toGlobal :: String -> String
toGlobal name
    | (sigil, identifier) <- break (\x -> isAlpha x || x == '_') name
    , last sigil /= '*'
    = sigil ++ ('*':identifier)
    | otherwise = name

arityMatch :: VCode -> Int -> Int -> Maybe VCode
arityMatch sub@MkCode{ subAssoc = assoc, subParams = prms } argLen argSlurpLen
    | assoc == "list" || assoc == "chain"
    = Just sub
    | isNothing $ find (not . isSlurpy) prms -- XXX - what about empty ones?
    , assoc == "pre"
    , slurpLen <- length $ filter (\p -> isSlurpy p && head (paramName p) == '$') prms
    , hasArray <- isJust $ find (\p -> isSlurpy p && head (paramName p) /= '$') prms
    , if hasArray then slurpLen <= argSlurpLen else slurpLen == argSlurpLen
    = Just sub
    | reqLen <- length $ filter (\p -> not (isOptional p || isSlurpy p)) prms
    , optLen <- length $ filter (\p -> isOptional p) prms
    , hasArray <- isJust $ find (\p -> isSlurpy p && head (paramName p) /= '$') prms
    , argLen >= reqLen && (hasArray || argLen <= (reqLen + optLen))
    = Just sub
    | otherwise
    = Nothing

breakSigil :: String -> (String, String)
breakSigil = break (\x -> isAlpha x || x == '_')

toPackage :: String -> String -> String
toPackage pkg name
    | (sigil, identifier) <- breakSigil name
    , last sigil /= '*'
    = concat [sigil, pkg, "::", identifier]
    | otherwise = name

packageOf :: String -> String
packageOf name = case isQualified name of
    Just (pkg, _)   -> pkg
    _               -> "main"

qualify :: String -> String
qualify name = case isQualified name of
    Just _  -> name
    _       -> let (sigil, name') = breakSigil name
        in sigil ++ "main::" ++ name'

isQualified :: String -> Maybe (String, String)
isQualified name
    | Just (post, pre) <- breakOnGlue "::" (reverse name) =
    let (sigil, pkg) = span (not . isAlphaNum) preName
        name'       = possiblyFixOperatorName (sigil ++ postName)
        preName     = reverse pre
        postName    = reverse post
    in case takeWhile isAlphaNum pkg of
        "OUTER"     -> Nothing
        "CALLER"    -> Nothing
        _           -> Just (pkg, name')
isQualified _ = Nothing

toQualified :: String -> Eval String
toQualified name@(_:'*':_) = return name
toQualified name@(_:'?':_) = return name
toQualified name@(_:'+':_) = return name
toQualified name@(_:"!") = return name
toQualified name@(_:"/") = return name
toQualified name = do
    case isQualified name of
        Just _  -> return name
        _       -> do
            pkg <- asks envPackage
            return $ toPackage pkg name
