{-# OPTIONS_GHC -fglasgow-exts -cpp -fno-warn-deprecations -fallow-overlapping-instances #-}

{-|
    Evaluation and reduction engine.

>   Home is behind, the world ahead,
>   And there are many paths to tread
>   Through shadows to the edge of night,
>   Until the stars are all alight.
>   Then world behind and home ahead,
>   We'll wander back to home and bed...

This module takes an /abstract syntax tree/ and recursively evaluates it,
thereby evaluating the program.

The AST is represented as a hierarchy of nested 'Exp' expressions
(see "Pugs.AST").  Some understanding of 'Exp' and "Pugs.AST" in will help in
understanding this module.
-}

module Pugs.Eval (
    evaluate,
    emptyEnv, evaluateMain,
    enterLValue, enterRValue,
    runWarn
) where
import Pugs.Internals
import Prelude hiding ( exp )
import qualified Data.Map as Map

import Pugs.AST
import Pugs.Junc
import Pugs.Bind
import Pugs.Prim
import Pugs.Prim.List (op0Zip, op0Cat, op0Each, op0RoundRobin)
import Pugs.Monads
import Pugs.Pretty
import Pugs.Types
import Pugs.External
import Pugs.Eval.Var
import DrIFT.YAML ()
import qualified Data.ByteString.Char8 as Buf


{-|
Construct a new, \'empty\' 'Env' (evaluation environment).

See the source of 'Pugs.Prims.initSyms' for a list of symbols that are
initially present in the global 'Pad'.
-}
emptyEnv :: (MonadIO m, MonadSTM m) 
         => String             -- ^ Name associated with the environment
         -> [STM PadMutator]   -- ^ List of 'Pad'-mutating transactions used
                               --     to declare an initial set of global
                               --     variables
         -> m Env
emptyEnv name genPad = liftSTM $ do
    pad  <- sequence genPad
    ref  <- newTVar Map.empty
    syms <- initSyms
    let globPad = combine (pad ++ syms) $ mkPad []
    glob <- newTVar globPad
    init <- newTVar $ MkInitDat { initPragmas=[] }
    maxi <- newTVar $ MkObjectId 1
    return $ MkEnv
        { envContext = CxtVoid
        , envLexical = mkPad []
        , envImplicit= Map.empty
        , envLValue  = False
        , envGlobal  = length (show (padKeys globPad)) `seq` glob -- force eval of all sym names
        , envPackage = cast "Main"
        , envClasses = initTree
        , envEval    = evaluate
        , envCaller  = Nothing
        , envOuter   = Nothing
        , envFrames  = emptyFrames
        , envBody    = Val undef
        , envDebug   = Just ref -- Set to "Nothing" to disable debugging
        , envPos     = MkPos name 1 1 1 1
        , envPragmas = []
        , envInitDat = init
        , envMaxId   = maxi
        , envAtomic  = False
        }

-- Evaluation ---------------------------------------------------------------

{-|
Emits a runtime warning.
-}
-- XXX: This should cache so that you don't warn in the same place twice
--   (even though Perl 5 doesn't do this).
--   It should also respond to lexical warnings pragmata.
runWarn :: String -> Eval ()
runWarn msg = do 
    enterEvalContext CxtVoid $
        App (_Var "&warn") Nothing [Val (VStr msg)]
    return ()

type DebugCache = TVar (Map ID String)

{-# SPECIALIZE debug :: DebugCache -> ID -> (String -> String) -> String -> String -> Eval () #-}
debug :: Pretty a => DebugCache -> ID -> (String -> String) -> String -> a -> Eval ()
debug ref key fun str a = do
    val <- liftSTM $ do
        fm <- readTVar ref
        let val = fun $ Map.findWithDefault "" key fm
        writeTVar ref (Map.insert key val fm)
        return val
    when (length val > 100) $ do
        liftIO $ putStrLn "*** Warning: deep recursion"
    liftIO $ putStrLn ("***" ++ val ++ str ++ encodeUTF8 (pretty a))

evaluateMain :: Exp -> Eval Val
evaluateMain exp = do
    -- S04: INIT {...}*      at run time, ASAP
    initAV   <- reduceVar $ cast "@*INIT"
    initSubs <- fromVals initAV
    enterContext CxtVoid $ do
        mapM_ evalExp [ App (Val sub) Nothing [] | sub@VCode{} <- initSubs ]
    evalExp (Syn "=" [_Var "@*INIT", Syn "," []])
    -- The main runtime
    tryT (evaluate exp) `finallyM` do
        -- S04: END {...}       at run time, ALAP
        endAV       <- reduceVar $ cast "@*END"
        endSubs     <- fromVals endAV
        endMainAV   <- reduceVar $ cast "@Main::END"
        endMainSubs <- fromVals endMainAV
        enterContext CxtVoid $ do
            mapM_ evalExp [ App (Val sub) Nothing [] | sub@VCode{} <- endMainSubs ++ endSubs ]

{-|
Evaluate an expression.

This function mostly just delegates to 'reduce'.
-}
evaluate :: Exp -- ^ The expression to evaluate
         -> Eval Val
evaluate (Val val) = evalVal val
evaluate exp = do
    debugRef <- asks envDebug
    case debugRef of
        Just ref -> do
            want <- asks envWant
            debug ref (cast "indent") ('-':) (" Evl [" ++ want ++ "]:\n") exp
            val <- local (\e -> e{ envBody = exp }) $ reduce exp
            debug ref (cast "indent") (\x -> if null x then [] else tail x) "- Ret: " val
            trapVal val (return val)
        Nothing -> do
            val <- local (\e -> e{ envBody = exp }) (reduce exp)
            trapVal val (return val)

-- Reduction ---------------------------------------------------------------

retVal :: Val -> Eval Val
retVal val = evaluate (Val val)

retItem :: Val -> Eval Val
retItem val = do
    ifListContext
        (retVal $ VList [val])
        (retVal $ val)

{-|
Add a symbol to the global 'Pad'.

Used by 'reduceSym'.
-}
addGlobalSym :: PadMutator -- ^ 'Pad'-transformer that will insert the new
                           --     symbol
             -> Eval ()
addGlobalSym newSym = do
    glob <- asks envGlobal
    liftSTM $ do
        syms <- readTVar glob
        writeTVar glob (newSym syms)

trapVal :: Val -> Eval a -> Eval a
trapVal val action = case val of
    VError str posList -> do
        pos <- asks envPos
        retShift $ VError str (pos:posList)
    VControl c      -> retControl c
    _               -> action

evalRef :: VRef -> Eval Val
evalRef ref = do
    if refType ref == (mkType "Thunk") then forceRef ref else do
    val <- catchT $ \esc -> do
        MkEnv{ envContext = cxt, envLValue = lv, envClasses = cls } <- ask
        let typ = typeOfCxt cxt
            isCollectionRef = isaType cls "List" (refType ref)
        -- If RValue, read from the reference
        unless lv $ do
            when (isCollectionRef && isItemCxt cxt) $ do
                -- auto-enreference
                esc $ VRef ref
            case ref of
                MkRef IPair{}   -> esc (VRef ref)
                _               -> esc =<< readRef ref
        -- LValue here
        when isCollectionRef $ esc (castV ref)
        val <- readRef ref
        let isAutovivify = and $
                [ isItemCxt cxt
                , isUndefinedVal val
                , (typ ==) `any` [mkType "Array", mkType "Hash"]
                ]
            isUndefinedVal VUndef   = True
            isUndefinedVal VType{}  = True
            isUndefinedVal _        = False
            -- Here we ensutre "my Hash $x" can only vivify into Hash no matter how it's asked.
            typ' = case val of
                VType t -> t
                _       -> typ 
        when isAutovivify $ do
            ref' <- newObject typ'
            writeRef ref (VRef ref')
        return $ castV ref
    retVal val

{-|
Reduce an expression into its value.

This function dispatches to the relevant @reduce*@ function for the type of
expression given.
-}
reduce :: Exp -- ^ The expression to reduce
       -> Eval Val

reduce (Val v) = reduceVal v

reduce (Var name) = reduceVar name

reduce (Stmts this rest) = reduceStmts this rest

reduce (Ann (Prag prag) exp) = reducePrag prag exp

reduce (Ann (Pos pos) exp) = reducePos pos exp

reduce (Ann (Cxt cxt) exp) = reduceCxt cxt exp

reduce (Ann _ exp) = reduce exp

reduce (Pad scope lexEnv exp) = reducePad scope lexEnv exp

reduce (Sym scope name exp) = reduceSym scope name exp

-- Reduction for no-operations
reduce Noop = retEmpty

reduce (Syn name subExps) = reduceSyn name subExps

reduce (App subExp inv args) = reduceApp subExp inv args

reduce exp = retError "Invalid expression" exp

reduceVal :: Val -> Eval Val
reduceVal v@(VRef (MkRef IPair{})) = return v

-- Reduction for mutables
reduceVal v@(VRef var) = do
    lv <- asks envLValue
    if lv then retVal v else do
    rv <- readRef var
    retVal rv

-- Reduction for constants
reduceVal v = retVal v

-- Reduction for variables
reduceVar :: Var -> Eval Val
reduceVar var@MkVar{ v_sigil = sig, v_twigil = twi, v_name = name, v_package = pkg }
    | TAttribute <- twi
    = reduceSyn (show sig ++ "{}") [ Syn "{}" [_Var "&self", Val (VStr $ cast name)] ]
    | TPrivate <- twi
    = reduceSyn (show sig ++ "{}") [ Syn "{}" [_Var "&self", Val (VStr $ cast name)] ]
    | otherwise = do
        v <- findVar var
        case v of
            Just ref -> evalRef ref
            Nothing
                | SType <- sig      -> return . VType . cast $ if isQualifiedVar var
                    then cast $ Buf.join (__"::") [cast pkg, cast name]
                    else name
                | isGlobalVar var || pkg `notElem` [emptyPkg, callerPkg, outerPkg, contextPkg] -> do
                    -- $Qualified::Var is not found.  Vivify at lvalue context.
                    lv <- asks envLValue
                    if lv then evalExp (Sym SGlobal var (Var var)) else retEmpty
                | otherwise         -> retError "Undeclared variable" var

_scalarContext :: Cxt
_scalarContext = CxtItem $ mkType "Scalar"

reduceStmts :: Exp -> Exp -> Eval Val
reduceStmts Noop rest           = reduce rest
reduceStmts (Ann _ Noop) rest   = reduce rest
reduceStmts this Noop           = reduce this
reduceStmts this (Ann _ Noop)   = reduce this

-- XXX - Hack to get context propagating to "return"
reduceStmts this@(App (Var var) _ _) _ | var == cast "&return" = reduce this
reduceStmts this@(Ann _ (App (Var var) _ _)) _ | var == cast "&return" = reduce this

reduceStmts this rest = do
    let withCxt = case this of
            App (Var var) _ _         | var == cast "&yield" -> id
            Ann _ (App (Var var) _ _) | var == cast "&yield" -> id
            _  -> enterContext cxtVoid
    val <- withCxt (reduce this)
    let writeEnv = do
            env <- ask
            writeVar (cast "$*_") val
            return . VControl $ ControlEnv env
    trapVal val $ case rest of
        Ann _ (Syn "env" [])    -> writeEnv
        Syn "env" []            -> writeEnv
        _                       -> reduce rest

reducePrag :: [Pragma] -> Exp -> Eval Val
reducePrag prag exp = do
    local (\e -> e{ envPragmas = prag }) $ do
        evalExp exp

{-|
Reduce a 'Pos' expression by reducing its subexpression in a new 'Env', which
holds the 'Pos'\'s position.
-}
reducePos :: Pos -> Exp -> Eval Val
reducePos pos exp = do
    local (\e -> e{ envPos = pos }) $ do
        evalExp exp

reducePad :: Scope -> Pad -> Exp -> Eval Val
reducePad SEnv lex@(MkPad lex') exp = do
    local (\e -> e{ envImplicit = Map.map (const ()) lex' `Map.union` envImplicit e }) $
        reducePad SMy lex exp
reducePad SMy lex exp = do
    -- heuristics: if we are repeating ourselves, generate a new TVar.
    lex' <- refreshPad lex
    local (\e -> e{ envLexical = lex' `unionPads` envLexical e }) $ do
        evalExp exp

reducePad STemp lex exp = do
    tmps <- mapM (\(sym, _) -> evalExp $ App (_Var "&TEMP") (Just $ Var sym) []) $ padToList lex
    -- default to nonlocal exit
    isNonLocal  <- liftSTM $ newTVar True
    val <- tryT $ do
        -- if the liftSTM is reached, exp evaluated without error; no need to shift out
        evalExp exp `finallyM` liftSTM (writeTVar isNonLocal False)
    mapM_ (\tmp -> evalExp $ App (Val tmp) Nothing []) tmps
    isn <- liftSTM $ readTVar isNonLocal
    (if isn then retShift else return) val

reducePad _ lex exp = do
    local (\e -> e{ envLexical = lex `unionPads` envLexical e }) $ do
        evalExp exp
        
reduceSym :: Scope -> Var -> Exp -> Eval Val
-- Special case: my (undef) is no-op
reduceSym scope var exp
--  | var == cast "" = evalExp exp
    | scope <= SMy = do
        ref <- newObject (typeOfSigilVar var)
        let (gen, var')
                | SCodeMulti <- v_sigil var
                = (genMultiSym, var{ v_sigil = SCode })
                | otherwise
                = (genSym, var)
        sym <- gen var' ref
        enterLex [ sym ] $ evalExp exp
    | otherwise = do
        ref <- newObject (typeOfSigilVar var)
        let (gen, var')
                | SCodeMulti <- v_sigil var
                = (genMultiSym, var{ v_sigil = SCode })
                | otherwise
                = (genSym, var)
        qn      <- toQualified var'
        sym     <- gen qn ref
        addGlobalSym sym
        evalExp exp

-- Context forcing
reduceCxt :: Cxt -> Exp -> Eval Val
reduceCxt cxt exp = do
    val <- enterEvalContext cxt exp
    enterEvalContext cxt (Val val) -- force casting

{-|
Reduce a 'Syn' expression, i.e. a syntactic construct that cannot (yet) be
expressed using 'App' (regular sub application).

Theoretically, 'Syn' will one day be deprecated when 'App' becomes powerful
enough to make it redundant.
-}
reduceSyn :: String -> [Exp] -> Eval Val

reduceSyn "()" [exp] = reduce exp

reduceSyn "named" [keyExp, valExp] = do
    key <- enterEvalContext cxtItemAny keyExp
    val <- enterEvalContext cxtItemAny valExp
    retItem $ castV (key, val)

reduceSyn "env" [] = do
    env <- ask
    -- writeVar "$*_" val
    return . VControl $ ControlEnv env

reduceSyn "block" [exp]
    | Syn "sub" [Val (VCode sub@MkCode{ subType = SubBlock })] <- unwrap exp = do
        unless (isEmptyParams (subParams sub)) $
            fail "Blocks with implicit params cannot occur at statement level"
        env <- ask
        enterSub (sub{ subEnv = Just env }) . reduce $ case unwrap (subBody sub) of
            Syn "block" [exp] -> case unwrap exp of
                -- Here we have a nested statement-level block: "{ { 3 } }";
                -- we actually want to create two OUTER blocks, so reduce normally.
                Syn "sub" [Val (VCode MkCode{ subType = SubBlock })] -> subBody sub
                _   -> exp
            _                   -> subBody sub
    | otherwise = enterBlock $ reduce exp
    
reduceSyn "sub" [exp] = do
    (VCode sub) <- enterEvalContext (cxtItem "Code") exp
    env  <- ask
    cont <- if subType sub /= SubCoroutine then return Nothing else liftSTM $ do
        tvar <- newTVar (error "empty sub")
        let thunk = (`MkThunk` anyType) . fix $ \redo -> do
            evalExp $ subBody sub
            liftSTM $ writeTVar tvar thunk
            redo
        writeTVar tvar thunk
        return $ Just tvar
    newBody <- transformExp cloneBodyStates $ subBody sub
    retVal $ VCode sub
        { subEnv  = Just env
        , subCont = cont
        , subBody = newBody
        }
    where
    cloneBodyStates (Pad scope pad exp) | scope <= SMy = do
        pad' <- clonePad pad
        return $ Pad scope pad' exp
    cloneBodyStates x = return x
    clonePad pad = do
        fmap listToPad $ forM (padToList pad) $ \(var, tvars) -> do
            tvars' <- forM tvars $ \(_, tvar) -> do
                fresh'  <- liftSTM $ newTVar False
                tvar'   <- (liftSTM . newTVar) =<< case v_sigil var of
                    SType       -> liftSTM $ readTVar tvar
                    SCode       -> liftSTM $ readTVar tvar
                    SCodeMulti  -> liftSTM $ readTVar tvar
                    _           -> newObject (typeOfSigilVar var)
                return (fresh', tvar')
            return (var, tvars')

reduceSyn "but" [obj, block] = do
    evalExp $ App (_Var "&Pugs::Internals::but_block") Nothing [obj, block]

reduceSyn name [cond, bodyIf, bodyElse]
    | "if"     <- name = doCond id
    | "unless" <- name = doCond not
    where
    doCond :: (Bool -> Bool) -> Eval Val
    doCond f = do
        vbool     <- enterRValue $ enterEvalContext (cxtItem "Bool") cond
        vb        <- fromVal vbool
        if (f vb)
            then reduce bodyIf
            else reduce bodyElse

reduceSyn "for" [list, body] = enterLoop $ do
    av    <- enterLValue $ enterEvalContext cxtSlurpyAny list
    sub   <- fromCodeExp body
    -- XXX this is wrong -- should use Array.next
    elms  <- case av of
        VRef (MkRef sv@IScalar{})   -> return [sv]
        VList xs                    -> return . (`map` xs) $ \x -> case x of
            VRef (MkRef sv@IScalar{})   -> sv
            _                           -> (IScalar x)
        _                           -> join $ doArray av array_fetchElemAll
    -- This makes "for @x { ... }" into "for @x -> $_ is rw {...}"
    let arity = max 1 $ length (subParams sub)
        runBody [] _ _ = retVal undef
        runBody vs sub' isFirst = do
            let (these, rest) = arity `splitAt` vs
                realSub
                    = (`afterLeave` if null rest then subLastBlocks else const [])
                    . (`beforeLeave` subNextBlocks)
                    $ if isFirst then sub' `beforeEnter` subFirstBlocks else sub'
            rv <- apply realSub Nothing $ map (Val . VRef . MkRef) these
            case rv of
                VControl (ControlLoop LoopRedo) -> runBody vs sub' isFirst
                VControl (ControlLoop LoopLast) -> retVal undef
                _                               -> runBody rest sub' False
    runBody elms sub True

reduceSyn "gather" [exp] = do
    sub     <- fromVal =<< evalExp exp
    globTV  <- asks envGlobal
    glob    <- liftSTM $ readTVar globTV
    oldAV   <- findSymRef takeVar glob
    oldSym  <- genSym takeVar oldAV
    newAV   <- newObject (mkType "Array")
    newSym  <- genSym takeVar newAV
    liftSTM $ writeTVar globTV (newSym glob)
    enterGather $ apply sub Nothing []
    readRef newAV `finallyM` liftSTM (modifyTVar globTV oldSym)
    where
    takeVar = cast "$*TAKE"

reduceSyn "loop" exps = enterLoop $ do
    let [pre, cond, post, body] = case exps of { [_] -> exps'; _ -> exps }
        exps' = [emptyExp, Val (VBool True), emptyExp] ++ exps
        evalCond | unwrap cond == Noop = return True
                 | otherwise = fromVal =<< enterEvalContext (cxtItem "Bool") cond
    sub     <- fromVal =<< (enterRValue $ enterEvalContext (cxtItem "Code") body)
    evalExp pre
    vb      <- evalCond
    if not vb then retEmpty else fix $ \runBody -> do
        valBody <- apply (sub `beforeLeave` subNextBlocks) Nothing []
        let runNext = do
                valPost <- evalExp post
                vb      <- evalCond
                trapVal valPost $ if vb then runBody else retEmpty
        case valBody of
            VControl (ControlLoop LoopRedo) -> runBody
            VControl (ControlLoop LoopLast) -> retEmpty
            VControl (ControlLoop LoopNext) -> runNext
            _                               -> trapVal valBody runNext

reduceSyn "given" [topic, body] = enterGiven $ do
    sub     <- fromCodeExp body
    apply sub Nothing [App (_Var "&VAR") (Just topic) []]

reduceSyn "when" [match, body] = do
    result  <- reduce $ case unwrap match of
        App _ (Just (Var var)) _    | var == varTopic -> match
        Syn _ [Var var, _]          | var == varTopic -> match
        _ -> App (_Var "&*infix:~~") Nothing [Var varTopic, match]
    rb      <- fromVal result
    if not rb then retEmpty else do
        sub     <- fromCodeExp body
        enterWhen $ apply sub Nothing []

reduceSyn "default" [body] = do
    sub     <- fromCodeExp body
    enterWhen $ apply sub Nothing []

reduceSyn name [cond, body]
    | "while" <- name = doWhileUntil id False
    | "until" <- name = doWhileUntil not False
    | "postwhile" <- name = doWhileUntil id True
    | "postuntil" <- name = doWhileUntil not True
    where
    -- XXX The "first" loop should be merged into the normal runloop
    doWhileUntil :: (Bool -> Bool) -> Bool -> Eval Val
    doWhileUntil f postloop = enterLoop $ do
        origSub <- fromVal =<< (enterRValue $ enterEvalContext (cxtItem "Code") body)
        let sub = origSub `beforeLeave` subNextBlocks
        rv  <- if not postloop then retEmpty else fix $ \runBody -> do
            rv <- apply sub Nothing [Val $ castV undef]
            case rv of
                VControl (ControlLoop LoopRedo) -> runBody
                _                               -> return rv
        case rv of
            VError{}                        -> retVal rv
            VControl (ControlLoop LoopLast) -> retEmpty
            _                               -> do
                ($ rv) . fix $ \runLoop prev -> do
                    vbool <- enterEvalContext (cxtItem "Bool") cond
                    vb    <- fromVal vbool
                    if f vb
                        then fix $ \runBody -> do
                            rv <- apply sub Nothing [Val vbool]
                            case rv of
                                VControl (ControlLoop LoopRedo) -> runBody
                                VControl (ControlLoop LoopLast) -> retVal prev
                                VError{}    -> retVal rv
                                _           -> runLoop prev
                        else case prev of
                            VControl ControlLoop{}  -> retEmpty
                            _                       -> retVal rv

reduceSyn "=" [lhs, rhs] = do
    refVal  <- enterLValue $ evalExp lhs
    ref     <- fromVal refVal
    cls     <- asks envClasses
    let typ = refType ref
        cxt | isaType cls "List" typ = cxtSlurpyAny
            | otherwise = cxtItem $ takeWhile (/= ':') . show $ refType ref
    val <- enterRValue $ enterEvalContext cxt rhs
    writeRef ref val
    lv      <- asks envLValue
    if lv then retVal refVal else
        ifListContext (readRef ref) $
            if cxt == cxtSlurpyAny
                then retVal refVal
                else readRef ref

reduceSyn "::=" exps = reduce (Syn ":=" exps)

reduceSyn ":=" exps
    | [Syn "," vars, Syn "," vexps] <- unwrap exps = do
        when (length vars > length vexps) $ do
            fail $ "Wrong number of binding parameters: "
                ++ (show $ length vexps) ++ " actual, "
                ++ (show $ length vars) ++ " expected"
        -- env' <- cloneEnv env -- FULL THUNKING
        names <- forM vars $ \var -> case unwrap var of
            Var name -> return name
            Syn [sigil,':',':','(',')'] [vexp]
                | Val (VStr name) <- unwrap vexp -> return $ cast (sigil:name)
            _        -> retError "Cannot bind this as lhs" var
        bindings <- forM (names `zip` vexps) $ \(var, vexp) -> enterLValue $ do
            {- FULL THUNKING
            let ref = thunkRef . MkThunk $ do
                    local (const env'{ envLValue = True }) $ do
                        enterEvalContext (cxtOfSigil $ head name) vexp
            -}
            val  <- enterEvalContext (cxtOfSigilVar var) vexp
            ref  <- fromVal val
            rv   <- findVarRef var
            case rv of
                Just tvar -> return (tvar, ref)
                _ | isGlobalVar var || v_package var `notElem` [emptyPkg, callerPkg, outerPkg, contextPkg] -> do
                    -- $Qualified::Var is not found.  Vivify at lvalue context.
                    evalExp (Sym SGlobal var Noop)
                    rv' <- findVarRef var
                    case rv' of
                        Just tvar   -> return (tvar, ref)
                        _           -> retError "Bind to undeclared variable" var
                _   -> retError "Bind to undeclared variable" var
        forM_ bindings $ \(tvar, ref) -> do
            liftSTM $ writeTVar tvar ref
        return $ case map (VRef . snd) bindings of
            [v] -> v
            vs  -> VList vs

reduceSyn ":=" [var, vexp] = do
    let expand e | e'@(Syn "," _) <- unwrap e = e'
        expand e = Syn "," [e]
    reduce (Syn ":=" [expand var, expand vexp])

reduceSyn "*" [] = return (VNum (1/0))

{-
reduceSyn "[,]" [exp] = do
    val <- enterRValue $ enterEvalContext cxtSlurpyAny exp
    return . VList =<< fromVal val
    -- vals <- fromVals val
    -- return $ VList $ concat vals
-}

reduceSyn "," exps = do
    vals <- mapM (enterEvalContext cxtSlurpyAny) exps
    retVal . VList . concat $ map castList vals
    where
    castList (VList vs) = vs
    castList v = [v]

reduceSyn "val" [exp] = do
    enterRValue $ evalExp exp

reduceSyn "\\{}" [exp] = do
    v   <- enterRValue . enterBlock $ enterEvalContext cxtSlurpyAny exp
    hv  <- newObject (mkType "Hash")
    writeRef hv v
    retVal $ VRef hv

reduceSyn "\\[]" [exp] = do
    v   <- enterRValue $ enterEvalContext cxtSlurpyAny exp
    av  <- newObject (mkType "Array")
    writeRef av v
    retItem $ VRef av

reduceSyn "[]" exps
    -- XXX evil hack for infinite slices
    | [lhs, App (Var var) invs args] <- unwrap exps
    , var == cast "&postfix:..."
    , [idx] <- maybeToList invs ++ args
--  , not (envLValue env)
    = reduce (Syn "[...]" [lhs, idx])
    | [lhs, App (Var var) invs args] <- unwrap exps
    , var == cast "&infix:.."
    , [idx, Val (VNum n)] <- maybeToList invs ++ args
    , n == 1/0
--  , not (envLValue env)
    = reduce (Syn "[...]" [lhs, idx])
    | otherwise = do
        let [listExp, indexExp] = exps
        varVal  <- enterLValue $ enterEvalContext (cxtItem "Array") listExp
        idxCxt  <- inferExpCxt indexExp 
        idxVal  <- enterRValue $ enterEvalContext idxCxt indexExp
        lv      <- asks envLValue
        doFetch (mkFetch $ doArray varVal array_fetchElem)
                (mkFetch $ doArray varVal array_fetchVal)
                (fromVal idxVal) lv $ case idxVal of
                    VList {} -> False
                    _        -> True

reduceSyn "[...]" [listExp, indexExp] = do
    idxVal  <- enterRValue $ enterEvalContext (cxtItem "Int") indexExp
    idx     <- fromVal idxVal
    listVal <- enterRValue $ enterEvalContext cxtSlurpyAny listExp
    list    <- fromVal listVal
    -- elms    <- mapM fromVal list -- flatten
    retVal $ VList (drop idx $ list)

-- XXX - Wrong!
reduceSyn "|" [exp] = evalExp exp

reduceSyn "@{}" [exp] = do
    val     <- enterEvalContext (cxtItem "Array") exp
    ivar    <- doArray val IArray
    evalRef (MkRef ivar)

reduceSyn "%{}" [exp] = do
    val     <- enterEvalContext (cxtItem "Hash") exp
    ivar    <- doHash val IHash
    evalRef (MkRef ivar)

reduceSyn "&{}" [exp] = do
    val     <- enterEvalContext (cxtItem "Code") exp
    sub     <- fromVal val
    return $ VCode sub

reduceSyn "${}" [exp] = do
    val     <- enterEvalContext (cxtItem "Scalar") exp
    ref     <- fromVal val
    evalRef ref

reduceSyn (sigil:"::()") exps = do
    -- These are all parts of the name
    parts   <- mapM fromVal =<< mapM evalExp exps
    -- Now we only have to add the sigil in front of the string and join
    -- the parts with "::".
    let varname = sigil:(concat . (intersperse "::") $ parts)
    -- Finally, eval the varname.
    reduceVar (possiblyFixOperatorName (cast varname))

reduceSyn "{}" [listExp, indexExp] = do
    varVal  <- enterLValue $ enterEvalContext (cxtItem "Hash") listExp
    idxCxt  <- inferExpCxt indexExp 
    idxVal  <- enterRValue $ enterEvalContext idxCxt indexExp
    lv      <- asks envLValue
    doFetch (mkFetch $ doHash varVal hash_fetchElem)
        (mkFetch $ doHash varVal hash_fetchVal)
        (fromVal idxVal) lv $ case idxVal of
            VList {} -> False
            _        -> True

reduceSyn "rx" [exp, adverbs] = do
    hv      <- fromVal =<< evalExp adverbs
    val     <- enterEvalContext (cxtItem "Str") exp
    str     <- fromVal val
    p5      <- fromAdverb hv ["P5", "Perl5", "perl5"]
    p5flags <- fromAdverb hv ["P5", "Perl5", "perl5"]
    flag_g  <- fromAdverb hv ["g", "global"]
    flag_i  <- fromAdverb hv ["i", "ignorecase"]
    flag_s  <- fromAdverb hv ["s", "sigspace"]
    flag_r  <- fromAdverb hv ["ratchet"]
    flag_tilde  <- fromAdverb hv ["stringify"] -- XXX hack
    adverbHash  <- reduce adverbs
    let g = ('g' `elem` p5flags || flag_g)
        p5re = mkRegexWithPCRE (encodeUTF8 str) $
                    [ pcreUtf8
                    , ('i' `elem` p5flags || flag_i) `implies` pcreCaseless
                    , ('m' `elem` p5flags) `implies` pcreMultiline
                    , ('s' `elem` p5flags) `implies` pcreDotall
                    , ('x' `elem` p5flags) `implies` pcreExtended
                    ]
        p6re = combine
            [ if flag_s then (\x -> ":sigspace(1)[" ++ x ++ "]") else id
            , if flag_r then (\x -> ":ratchet(1)[" ++ x ++ "]") else id
            ] str
        {-
        p6re | null p6reAdvs = str
             | ':':_ <- str  = p6reAdvs ++ str
             | otherwise     = p6reAdvs ++ "::" ++ str
        -}
        rx | p5 = do ns <- liftIO $ numSubs p5re
                     return $ MkRulePCRE p5re g ns flag_tilde str adverbHash
           | otherwise = return $ MkRulePGE p6re g flag_tilde adverbHash
    retVal . VRule =<< rx
    where
    implies True  = id
    implies False = const 0
    fromAdverb _ [] = fromVal undef
    fromAdverb hv (k:ks) = case lookup k hv of
        Just v  -> fromVal v
        Nothing -> fromAdverb hv ks

reduceSyn "//" exps = reduceSyn "match" exps -- XXX - this is wrong

reduceSyn "match" exps = do
    env <- ask
    let cls = envClasses env
        cxt = envContext env
        typ = typeOfCxt cxt
    if isaType cls "Bool" typ
        then reduceApp (_Var "&infix:~~") Nothing [Var varTopic, Syn "rx" exps]
        else reduceSyn "rx" exps

reduceSyn "subst" [exp, subst, adverbs] = do
    (VRule rx)  <- reduce (Syn "rx" [exp, adverbs])
    retVal $ VSubst (MkSubst rx subst)

reduceSyn "trans" (fromExp:toExp:_) = do
    from <- fromVal =<< reduce fromExp
    to   <- fromVal =<< reduce toExp
    retVal $ VSubst (MkTrans from to)

-- XXX - Runtime mixin
reduceSyn "is" (lhs:_) = reduce lhs
reduceSyn "does" (lhs:_) = reduce lhs

reduceSyn "package" [kind, exp] = reduceSyn "namespace" [kind, exp, emptyExp]

reduceSyn "namespace" [_kind, exp, body] = do
    val <- evalExp exp
    str <- fromVal val
    when (str `elem` words "MY OUR OUTER CALLER") $ do
        fail $ "Cannot use " ++ str ++ " as a namespace"
    enterPackage (cast str) $ evalExp body

reduceSyn "inline" [langExp, _] = do
    langVal <- evalExp langExp
    lang    <- fromVal langVal
    when (lang /= "Haskell") $
        retError "Inline: Unknown language" langVal
    pkg     <- asks envPackage -- full module name here
    let file = (`concatMap` cast pkg) $ \v -> case v of
                    '-' -> "__"
                    _ | isAlphaNum v -> [v]
                    _ -> "_"
    externRequire "Haskell" (file ++ ".o")
    retEmpty

reduceSyn "=>" [keyExp, valExp] = do
    key <- enterEvalContext cxtItemAny keyExp
    val <- enterEvalContext cxtItemAny valExp
    retItem $ castV (key, val)

reduceSyn syn [lhsExp, rhsExp]
    | last syn == '=' = do
        let op = "&infix:" ++ init syn
        lhs <- enterLValue $ evalExp lhsExp
        val <- readRef =<< fromVal lhs
        evalExp $ Syn "=" [Val lhs, App (_Var op) Nothing [Val val, rhsExp]]

reduceSyn "q:code" [ body ] = expToEvalVal body

reduceSyn "CCallDyn" (Val (VStr quant):methExp:invExp:args) = do
    -- Experimental support for .*$meth, assuming single inheritance.
    str     <- fromVal =<< enterEvalContext (cxtItem "Str") methExp
    let meth = cast ('&':str)
    invVal  <- enterLValue . enterEvalContext cxtItemAny $ invExp
    found   <- findSub meth (Just (Val invVal)) args
    case found of
        Left{}      -> do
            let klugedInv = case unwrap invExp of
                    App{}  -> Val invVal    -- no re-evaluation
                    Syn{}  -> Val invVal    -- no re-evaluation
                    _      -> invExp        -- re-evaluation assumed to be ok
            foundSub    <- findSub meth Nothing (klugedInv:args)
            case foundSub of
                Left{}      -> case quant of
                    "+" -> do
                        typ     <- fromVal invVal
                        retError ("No such method in class " ++ showType typ) meth
                    _   -> do
                        retEmpty
                Right sub   -> applySub sub Nothing (klugedInv:args)
        Right sub | SubMethod <- subType sub, quant /= "?" -> do
            typ     <- fromVal invVal
            subs    <- findAccum meth{ v_package = nextPkg } typ -- Given type, get all methods
            rvs     <- forM (nub (sub:subs)) $ \sub -> applySub sub (Just (Val invVal)) args
            return (VList rvs)
        Right sub   -> do
            -- XXX - Walk multi variants
            applySub sub (Just (Val invVal)) args
    where
    findAccum meth typ = do
        found <- findSub meth (Just (Val (VType typ))) args
        case found of
            Right sub | Just env <- subEnv sub -> do
                let thisPkg = envPackage env
                rest <- findAccum meth (cast thisPkg)
                return (sub:rest)
            _         -> return []

reduceSyn name exps =
    retError "Unknown syntactic construct" (Syn name exps)

data SpecialApp
    = AppSub        !([Exp] -> Eval Val)
    | AppMeth       !(Exp -> [Exp] -> Eval Val)
    | AppSubMeth    !(Maybe Exp -> [Exp] -> Eval Val)
    deriving (Typeable)

class SpecialAppHelper a where
    (...) :: String -> a -> (Var, SpecialApp)

instance SpecialAppHelper (Maybe Exp -> [Exp] -> Eval Val) where
    n ... f = (cast n, AppSubMeth f)

instance SpecialAppHelper ([Exp] -> Eval Val) where
    n ... f = (cast n, AppSub f)

instance SpecialAppHelper (Exp -> [Exp] -> Eval Val) where
    n ... f = (cast n, AppMeth f)

specialApp :: Map Var SpecialApp
specialApp = Map.fromList
    [ "&VAR"        ... \invs args -> do
        res <- forM (maybeToList invs ++ args) $ \exp -> do
            enterLValue (enterEvalContext cxtItemAny exp)
        case res of
            [x] -> return x
            _   -> return $ VList res
    , "&hash"       ... (enterEvalContext cxtItemAny . Syn "\\{}" . (:[]) . Syn ",")
    , "&list"       ... \args -> do
        enterEvalContext cxtSlurpyAny $ case args of
            []    -> Val (VList [])
            [exp] -> exp
            exps  -> Syn "," exps
    , "&item"       ... \args -> do
        enterRValue . enterEvalContext cxtItemAny $ case args of
            [exp] -> exp
            _     -> Syn "," args
    , "&cat"        ... \args -> do
        vals <- mapM (enterRValue . enterEvalContext (cxtItem "Array")) args
        val  <- op0Cat vals
        retVal val
    , "&each"       ... \args -> do
        vals <- mapM (enterRValue . enterEvalContext (cxtItem "Array")) args
        val  <- op0Each vals
        retVal val
    , "&roundrobin" ... \args -> do
        vals <- mapM (enterRValue . enterEvalContext (cxtItem "Array")) args
        val  <- op0RoundRobin vals
        retVal val
    , "&zip"        ... \args -> do
        vals <- mapM (enterRValue . enterEvalContext (cxtItem "Array")) args
        val  <- op0Zip vals
        retVal val
    , "&return"     ... \args -> do
        (op1Return . retControl . ControlLeave (<= SubRoutine) 0) =<<
            case args of
                []      -> retEmpty
                [arg]   -> evalExp arg
                args    -> evalExp (Syn "," args)
    , "&goto"       ... \inv args -> do
        sub     <- fromCodeExp inv
        let callerEnv :: Env -> Env
            callerEnv env = let caller = maybe env id (envCaller env) in
                env{ envCaller  = envCaller caller
                   , envContext = envContext caller
                   , envLValue  = envLValue caller
                   , envFrames  = envFrames caller
                   , envPos     = envPos caller
                   }
        local callerEnv $ do
            val <- apply sub Nothing args
            retShift =<< retVal val
            retEmpty
    , "&call"       ... \inv args -> do
        sub     <- fromCodeExp inv
        let callerEnv :: Env -> Env
            callerEnv env = let caller = maybe env id (envCaller env) in
                env{ envCaller  = envCaller caller
                   , envContext = envContext caller
                   , envLValue  = envLValue caller
                   , envFrames  = envFrames caller
                   , envPos     = envPos caller
                   }
        vcap <- case args of
            []      -> return (CaptSub { c_feeds = [] })
            (x:_)   -> castVal =<< fromVal =<< enterRValue (enterEvalContext (cxtItem "Capture") x)
        local callerEnv $ applyCapture sub vcap
    , "&assuming"   ... \inv args -> do
        sub     <- fromCodeExp inv
        case bindSomeParams sub Nothing args of
            Left errMsg      -> fail errMsg
            Right curriedSub -> retVal $ castV $ curriedSub
    , "&infix:=>"   ... reduceSyn "=>"
    , "&circumfix:\\( )" ... \invs args -> do
        feeds <- argsFeed [] Nothing [args]
        case invs of
            Just i' -> do
                invVal  <- reduce i'
                vv      <- fromVal invVal
                return $ VV $ val $ CaptMeth{ c_invocant = vv, c_feeds = feeds }
            Nothing -> do
                return $ VV $ val $ CaptSub{ c_feeds = feeds }
    , "&prefix:|<<" ... reduceSyn "," -- XXX this is wrong as well - should handle at args level
    ]

reduceApp :: Exp -> Maybe Exp -> [Exp] -> Eval Val
reduceApp (Var var) invs args
    | SCodeMulti <- sig = doCall var{ v_sigil = SCode } invs args
    | SCode <- sig = case Map.lookup var specialApp of
        Just (AppSub f)     | Nothing <- invs   -> f args
        Just (AppMeth f)    | Just inv <- invs  -> f inv args
        Just (AppSubMeth f)                     -> f invs args
        _ | Nothing <- invs
          , [inv] <- args
          , not (isInterpolated inv)            -> case inv of
            Syn "named" _   -> normalDispatch
            _               -> do
                -- Try a local lookup of subs only.  If found, don't bother a method lookup.
                rv <- findVar var
                if isJust rv
                    then normalDispatch
                    else doCall var (Just inv) [] -- XXX - This will go away!
        _ -> doCall var invs args
    | otherwise = normalDispatch
    where
    sig = v_sigil var
    normalDispatch  = doCall var invs args

reduceApp subExp invs args = do
    vsub <- enterEvalContext (cxtItem "Code") subExp
    (`juncApply` [ApplyArg dummyVar vsub False]) $ \[arg] -> do
        sub  <- fromVal $ argValue arg
        apply sub invs args

applyCapture :: VCode -> ValCapt -> Eval Val
applyCapture sub capt = apply sub inv (argsPos ++ argsNam)
    where
    argsPos = map (Val . castV) (f_positionals feed)
    argsNam = [Syn "named" [Val (VStr (cast k)), Val (castV (last vs))] | (k, vs@(_:_)) <- Map.toList $ f_nameds feed ]
    feed = mconcat (c_feeds capt)
    inv  = case capt of 
        CaptMeth { c_invocant = val }   -> Just (Val (castV val))
        _                               -> Nothing

argsFeed :: [ValFeed] -> Maybe ValFeed -> [[Exp]] -> Eval [ValFeed]
argsFeed fAcc aAcc [] = return $ fAcc ++ maybeToList aAcc
argsFeed fAcc aAcc [[]] = return $ fAcc ++ maybeToList aAcc
argsFeed fAcc aAcc (argl:als) = do
    acc <- af aAcc argl
    argsFeed fAcc (Just acc) als
    where
    -- af :: Maybe (Feed Val) -> [Exp] -> Eval (Feed Val)
    af res [] = return $ feed res
    -- I'm not sure how much reduction should go on here? E.g. call reduceNamedArg, but what about the val?
    af res (n:args)
        | Syn "named" _ <- unwrapN = do
            Syn "named" [Val (VStr key), valExp] <- reduceNamedArg n
            argVal  <- fromVal =<< reduce valExp
            af (Just $ resFeed{ f_nameds = addNamed (f_nameds resFeed) key argVal }) args
        | Syn "|" (capExp:_) <- unwrapN = do
            cap <- castVal =<< fromVal =<< enterRValue (enterEvalContext (cxtItem "Capture") capExp)
            af (Just (mconcat (resFeed:c_feeds cap))) args
        | App (Var var) Nothing capExps <- unwrapN
        , var == cast "&prefix:|<<" = do
            caps    <- mapM castVal =<< fromVals =<< (enterRValue $ enterEvalContext (cxtSlurpy "Capture") (Syn "," capExps))
            af (Just (mconcat (resFeed:concatMap c_feeds caps))) args
        | otherwise = do
            argVal  <- fromVal =<< reduce n
            af (Just resFeed{ f_positionals = (f_positionals resFeed) ++ [argVal] }) args
        where
        unwrapN = unwrap n
        resFeed = feed res
    feed res = maybe emptyFeed id res
    addNamed :: (Map ID [a]) -> VStr -> a -> Map ID [a]
    addNamed mp k v =
        let id = cast k in
        Map.insertWith (flip (++)) id [v] mp

dummyVar :: Var
dummyVar = cast "$"

chainFun :: Params -> Exp -> Params -> Exp -> [Val] -> Eval Val
chainFun p1 f1 p2 f2 (v1:v2:vs) = do
    v1' <- forceThunk v1
    v2' <- forceThunk v2
    val <- juncApply (\args -> applyExp SubPrim args f1) (chainArgs p1 [v1', v2'])
    vb  <- fromVal val
    case vb of
        False -> return val
        True  -> do
            vs' <- case vs of
                (v3:rest)   -> do
                    v3' <- forceThunk v3
                    return (v3':rest)
                _           -> return vs
            juncApply (\args -> applyExp SubPrim args f2) (chainArgs p2 (v2':vs'))
    where
    chainArgs prms vals =
        [ ApplyArg name v False
        | name  <- map paramName (prms ++ repeat (last prms))
        | v     <- vals
        ]
    forceThunk (VRef (MkRef (IThunk tv)))   = thunk_force tv
    forceThunk x                            = return x
chainFun _ _ _ _ _ = fail "Impossible: Chained function with less than 2 arguments?"

interpolateExp :: Exp -> Eval [Exp]
interpolateExp exp
    | Syn "|" [x] <- unwrapped      = do
        val <- enterRValue (enterEvalContext (cxtItem "Capture") x)
        interpolateVal val
--  | Syn "|<<" [x] <- unwrapped    = do
--      fail "moose"
    | otherwise                     = return [exp]
    where
    unwrapped = unwrap exp

interpolateVal :: Val -> Eval [Exp]
interpolateVal (VRef (MkRef (IArray av))) = do
    vs <- array_fetch av
    return (map Val vs)
interpolateVal (VRef (MkRef (IHash hv))) = do
    vs <- hash_fetch hv
    return [ Syn "named" [Val (VStr k), Val v] | (k, v) <- Map.toList vs ]
interpolateVal (VRef (MkRef (IPair pv))) = do
    (k, v) <- pair_fetch pv
    return [ Syn "named" [Val k, Val v] ]
interpolateVal val = return [Val val]

isInterpolated :: Exp -> Bool
isInterpolated (Ann _ exp)      = isInterpolated exp
isInterpolated (Syn "|" _)      = True
isInterpolated (Syn "|<<" _)    = True
isInterpolated _                = False

evalInvocant :: Exp -> Eval Val
evalInvocant exp
    | Syn "," xs <- unwrap exp = do
        enterLValue . enterEvalContext cxtItemAny $
            Syn "," (map (\x -> Syn "val" [x]) xs)
    | otherwise = enterLValue $ enterEvalContext cxtItemAny exp

doCall :: Var -> Maybe Exp -> [Exp] -> Eval Val
doCall var invs origArgs = do
    -- First, reduce the invocant fully in item context.
    invs'   <- fmapM (fmap Val . evalInvocant) invs

    -- Support for |$foo here
    args    <- if any isInterpolated origArgs
        then fmap concat (mapM interpolateExp origArgs)
        else return origArgs

    sub     <- findSub var invs' args

    -- XXX - Consider this case:
    --      sub f (*@_) { @_ }
    --      =$fh.f; # App
    --      @foo.f; # Var
    -- We can't go back and re-evaluate the =$fh call under list context
    -- after it failed its method lookup; however, we really need to go back
    -- and re-evaluate @foo under list context.  So we use a klugy heuristic
    -- before this is resolved (by explicit "method is export" and removal
    -- of the one-arg-fallback-to-method altogether):
    let klugedInvs = case fmap unwrap invs of
            Just App{}  -> invs' -- no re-evaluation
            Just Syn{}  -> invs' -- no re-evaluation
            _           -> invs  -- re-evaluation assumed to be ok
    case sub of
        Right sub    -> do
            applySub sub klugedInvs args
        _ | [Syn "," args'] <- unwrap args -> do
            sub <- findSub var klugedInvs args'
            either err (fail errSpcMessage) sub
        -- If a method called failed, fallback to sub call
        Left NoSuchMethod{} | Just inv <- klugedInvs -> do
            doCall var Nothing (inv:args)
        Left failure -> err failure
    where
    errSpcMessage = "Extra space found after " ++ cast var ++ " (...) -- did you mean " ++ cast var ++ "(...) instead?"
    err NoMatchingMulti    = retError "No compatible subroutine found" var
    err NoSuchSub          = retError "No such sub" var
    err (NoSuchMethod typ) = retError ("No such method in class " ++ showType typ) var

applySub :: VCode -> (Maybe Exp) -> [Exp] -> Eval Val
applySub sub invs args
    -- list-associativity
    | MkCode{ subAssoc = A_list }           <- sub
    , (App (Var var') Nothing args'):rest   <- args
    , C_infix <- v_categ var'
    , cast (subName sub) == v_name var'
    = applySub sub invs (args' ++ rest)
    -- fix subParams to agree with number of actual arguments
    | MkCode{ subAssoc = A_list, subParams = (p:_) }   <- sub
    = apply sub{ subParams = length args `replicate` p } invs args
    -- chain-associativity
    | MkCode{ subAssoc = A_chain }      <- sub
    , Nothing                           <- invs
    = case args of
        (App _ Nothing _:_) -> mungeChainSub sub args
        _                   -> applyChainSub sub args
    -- normal application
    | otherwise
    = apply sub invs args
    where
    mungeChainSub :: VCode -> [Exp] -> Eval Val
    mungeChainSub sub args = do
        let MkCode{ subAssoc = A_chain, subParams = [_,_] } = sub
            (App (Var name') invs' args'):rest = args
        theSub   <- findSub name' invs' args'
        case theSub of
            Right sub' | A_chain <- subAssoc sub'
                -> augmentChainSub sub sub' args' rest
            _ -> applyChainSub sub args
    augmentChainSub :: VCode -> VCode -> [Exp] -> [Exp] -> Eval Val
    augmentChainSub sub sub' args' rest = do
        let MkCode{ subBody = fun, subParams = prm } = sub
            MkCode{ subBody = fun', subParams = prm' } = sub'
            augmentedSub = sub
                { subParams = prm' ++ [(last prm){ isLazy = True }]
                , subBody   = Prim $ chainFun prm' fun' prm fun
                }
        applySub augmentedSub Nothing (args' ++ rest)
    applyChainSub :: VCode -> [Exp] -> Eval Val
    applyChainSub sub args = tryAnyComprehension [] args
        where
        vanillaApply = apply sub' Nothing args
        tryAnyComprehension _ [] = vanillaApply
        tryAnyComprehension pre (pivot:post)
            | App (Var var') _ _    <- unwrap pivot
            , var' == cast "&list" = do
                -- List comprehension!  This:
                --      1 < list(@x) < 2
                -- Becomes this:
                --      list(@x).grep:{ 1 < $_ < 2 }
                -- Except we don't introduce a $_ variable, as to avoid shadowing.
                items <- fromVal =<< reduce pivot
                fmap VList . (`filterM` items) $ \item -> do
                    vbool <- enterRValue . enterContext (cxtItem "Bool") $ do
                        apply sub' Nothing (reverse pre ++ (Val item:post))
                    fromVal vbool
            | otherwise = do
                -- Accumulate pre and scan to the next.  Note pre must be reversed as above.
                tryAnyComprehension (pivot:pre) post
        prms    = subParams sub
        -- Align the argument number against the parameter number
        sub'    = sub{ subParams = take (length args) (prms ++ repeat (last prms)) }

applyExp :: SubType -> [ApplyArg] -> Exp -> Eval Val
applyExp _ bound (Prim f) =
    f [ argValue arg | arg <- bound, (argName arg) /= cast "%_" ]
applyExp styp [] body = do
    applyThunk styp [] $ MkThunk (evalExp body) anyType
applyExp styp bound@(invArg:_) body = do
    let (attribute, normal) = partition isAttribute bound
        invocant            = argValue invArg
    -- For each $!foo or $.bar in arg list, assign back to the object directly.
    forM attribute $ \arg -> do
        let name  = dropWhile (not . isAlpha) (cast $ argName arg)
            value = argValue arg
        evalExp $ Syn "=" [Syn "{}" [Val invocant, Val (VStr name)], Val value]
    applyThunk styp normal $ MkThunk (evalExp body) anyType
    where
    isAttribute arg = case v_twigil (argName arg) of
        TAttribute  -> True
        TPrivate    -> True
        _           -> False

applyThunk :: SubType -> [ApplyArg] -> VThunk -> Eval Val
applyThunk _ [] thunk = thunk_force thunk
applyThunk styp bound@(arg:_) thunk = do
    -- introduce self and $_ as the first invocant.
    inv     <- case styp of
        SubPointy               -> aliased [cast "$_"]
        _ | styp <= SubMethod   -> aliased [cast "&self"] -- , "$_"]
        _                       -> return []
    pad <- formal
    enterLex (inv ++ pad) $ thunk_force thunk
    where
    -- Don't generate pad entries for siglets such as "$" and "@".
    formal = sequence
        [ genSym var =<< fromVal val
        | ApplyArg var val _ <- bound
        , v_name var /= nullID
        ]
    aliased names = do
        argRef  <- fromVal (argValue arg)
        mapM (`genSym` argRef) names

{-|
Apply a sub (or other code object) to an (optional) invocant, and
a list of arguments.

Mostly delegates to 'doApply' after explicitly retrieving the local 'Env'.
-}
apply :: VCode       -- ^ The sub to apply
      -> (Maybe Exp) -- ^ Explicit invocant
      -> [Exp]       -- ^ List of arguments (not including explicit invocant)
      -> Eval Val
apply sub invs args = do
    env <- ask
    doApply env sub invs args

-- XXX not entirely sure how this evaluation should proceed
reduceNamedArg :: Exp -> Eval Exp
reduceNamedArg (Syn "named" [keyExp, val]) = do
    key    <- fmap VStr $ fromVal =<< enterEvalContext cxtItemAny keyExp
    return $ Syn "named" [Val key, val]
reduceNamedArg other = return other

        

-- XXX - faking application of lexical contexts
-- XXX - what about defaulting that depends on a junction?
{-|
Apply a sub (or other code object) to an (optional) invocants, and a list of
arguments, in the specified environment.
-}
doApply :: Env         -- ^ Environment to evaluate in
        -> VCode       -- ^ The sub to apply
        -> (Maybe Exp) -- ^ Explicit invocant
        -> [Exp]       -- ^ List of arguments (not including explicit invocant)
        -> Eval Val
doApply env sub@MkCode{ subCont = cont, subBody = fun, subType = typ } invs args = do
    realInvs <- fmapM reduceNamedArg invs
    realArgs <-  mapM reduceNamedArg args  
    case bindParams sub realInvs realArgs of
        Left errMsg -> fail errMsg
        Right sub   -> do
            forM_ (subSlurpLimit sub) $ \limit@(n, _) -> do
                extra <- checkSlurpyLimit limit
                unless (null extra) $ do
                    fail $
                        "Too many slurpy arguments for " ++ cast (subName sub) ++ ": "
                        ++ show ((genericLength (take 1000 extra)) + n) ++ " actual, "
                        ++ show n ++ " expected"
            (syms, bound) <- doBind [] (subBindings sub)
            -- trace (show bound) $ return ()
            val <- local fixEnv $ enterLex syms $ do
                (`juncApply` bound) $ \realBound -> do
                    enterSub sub $ case cont of
                        Just tvar   -> do
                            thunk <- liftSTM $ readTVar tvar
                            applyThunk (subType sub) realBound thunk
                        Nothing     -> applyExp (subType sub) realBound fun
            case typ of 
                SubMacro    -> applyMacroResult val 
                _           -> retVal val
    where
    applyMacroResult :: Val -> Eval Val
    applyMacroResult (VObject o)
        | objType o == mkType "Code::Exp" = reduce (fromObject o)
    applyMacroResult code@VStr{}    = reduceApp (_Var "&eval") (Just $ Val code) []
    applyMacroResult code@VCode{}   = reduceApp (Val code) Nothing []
    applyMacroResult VUndef         = retEmpty
    applyMacroResult _              = fail "Macro did not return an AST, a Str or a Code!"
    fixSub MkCode{ subType = SubPrim } env = env
    fixSub sub env = env
        { envLexical = subPad sub
        , envPackage = maybe (envPackage env) envPackage (subEnv sub)
        , envOuter   = maybe Nothing envOuter (subEnv sub)
        }
    fixEnv :: Env -> Env
    fixEnv | typ >= SubBlock = id
           | otherwise       = envEnterCaller
    doBind :: [PadMutator] -> [(Param, Exp)] -> Eval ([PadMutator], [ApplyArg])
    doBind syms [] = return (syms, [])
    doBind syms ((prm, exp):rest) = do
        -- trace ("<== " ++ (show (prm, exp))) $ return ()
        let var = paramName prm
            cxt = cxtOfSigilVar var
        (val, coll) <- enterContext cxt $ case exp of
            Syn "param-default" [exp, Val (VCode sub)] -> do
                local (fixSub sub . fixEnv) $ enterLex syms $ expToVal prm exp
            _  -> expToVal prm exp
        -- trace ("==> " ++ (show val)) $ return ()
        boundRef <- fromVal val
        newSym   <- genSym var boundRef
        (syms', restArgs) <- doBind (newSym:syms) rest
        return (syms', ApplyArg var val coll:restArgs)
    expToVal :: Param -> Exp -> Eval (Val, Bool)
    expToVal MkOldParam{ isLazy = thunk, isLValue = lv, paramContext = cxt, paramName = var, isWritable = rw } exp = do
        env <- ask -- freeze environment at this point for thunks
        let eval = local (const env{ envLValue = lv }) $ do
                enterEvalContext cxt exp
            thunkify = do
                memo    <- liftSTM $ newTVar Nothing
                let forceThunk = do
                        res <- eval
                        liftSTM $ writeTVar memo (Just res)
                        return res
                    evalThunk = do
                        cur <- liftSTM $ readTVar memo
                        maybe forceThunk return cur
                return . VRef . thunkRef $ MkThunk evalThunk anyType
        val <- if thunk then thunkify else do
            v   <- eval
            typ <- evalValType v
            let cls = envClasses env
            if isaType cls "Junction" typ then return v else do
            case (lv, rw) of
                (True, True)    -> return v
                (True, False)   -> do
                    --- not scalarRef! -- use the new "transparent IType" thing!
                    case showType (typeOfSigilVar var) of
                        "Hash"  -> ($ v) . fix $ \redo x -> case x of
                            VRef (MkRef (IHash h)) -> return (VRef $ hashRef h) 
                            VRef ref@(MkRef IScalar{}) -> redo =<< readRef ref
                            _ -> fmap (VRef . hashRef) (fromVal v :: Eval VHash)
                        "Array" -> ($ v) . fix $ \redo x -> case x of
                            VRef (MkRef (IArray a)) -> return (VRef $ arrayRef a) 
                            VRef ref@(MkRef IScalar{}) -> redo =<< readRef ref
                            _ -> fmap (VRef . arrayRef) (fromVal v :: Eval VArray)
                        _       -> case v of
                            VRef (MkRef IScalar{}) -> return (VRef $ scalarRef v) 
                            VRef _ -> return v -- XXX - preserving ref
                            _ -> return (VRef $ scalarRef v) 
                (False, False)  -> return v -- XXX reduce to val?
                (False, True)   -> do
                    -- make a copy
                    ref <- newObject (typeOfSigilVar var)
                    writeRef ref v
                    return (VRef ref)
        return (val, (isSlurpyCxt cxt || isCollapsed (typeOfCxt cxt)))
    checkSlurpyLimit :: (VInt, Exp) -> Eval [Val]
    checkSlurpyLimit (n, exp) = do
        listVal <- enterLValue $ enterEvalContext (cxtItem "Array") exp
        list    <- fromVal listVal
        elms    <- mapM fromVal list -- flatten
        return $ genericDrop n (concat elms :: [Val])
    isCollapsed :: Type -> Bool
    isCollapsed typ
        | isaType (envClasses env) "Bool" typ        = True
        | isaType (envClasses env) "Junction" typ    = True
        | otherwise                     = False

doFetch :: (Val -> Eval (IVar VScalar))
        -> (Val -> Eval Val)
        -> (forall v. (Value v) => Eval v)
        -> Bool
        -> Bool
        -> Eval Val
doFetch fetchElem fetchVal fetchIdx isLV isSV = case (isLV, isSV) of
    (True, True) -> do
        -- LValue, Scalar context
        idx <- fetchIdx
        elm <- fetchElem idx
        retIVar elm
    (True, False) -> do
        -- LValue, List context
        idxList <- fetchIdx
        elms    <- mapM fetchElem idxList
        retIVar $ IArray elms
    (False, True) -> do
        -- RValue, Scalar context
        idx <- fetchIdx
        fetchVal idx
    (False, False) -> do
        -- RValue, List context
        idxList <- fetchIdx
        fmap VList $ mapM fetchVal idxList

mkFetch :: (Value n) => Eval (n -> Eval t) -> Val -> Eval t
mkFetch f v = do
    f' <- f
    v' <- fromVal v
    f' v'

afterLeave :: VCode -> (VCode -> [VCode]) -> VCode
afterLeave code@MkCode{ subBody = Syn "block" [Val (VCode code')] } f =
    code{ subBody = Syn "block" [Val (VCode (afterLeave code' f))] }
afterLeave code f = code{ subLeaveBlocks = subLeaveBlocks code ++ f code }

beforeLeave :: VCode -> (VCode -> [VCode]) -> VCode
beforeLeave code@MkCode{ subBody = Syn "block" [Val (VCode code')] } f =
    code{ subBody = Syn "block" [Val (VCode (afterLeave code' f))] }
beforeLeave code f = code{ subLeaveBlocks = f code ++ subLeaveBlocks code }

beforeEnter :: VCode -> (VCode -> [VCode]) -> VCode
beforeEnter code@MkCode{ subBody = Syn "block" [Val (VCode code')] } f =
    code{ subBody = Syn "block" [Val (VCode (beforeEnter code' f))] }
beforeEnter code f = code{ subEnterBlocks = f code ++ subEnterBlocks code }

fromCodeExp :: Exp -> Eval VCode
fromCodeExp x = case x of
    Syn "block" [Val VCode{}]   -> fromClosure x
    Syn "block" [_]             -> do
        env <- ask
        return $ mkCode
            { subEnv        = Just env
            , subType       = SubBlock
            , subParams     = [defaultScalarParam]
            , subBody       = x
            }
    _                           -> fromClosure x
    where
    fromClosure = (fromVal =<<) . enterRValue . enterEvalContext (cxtItem "Code")

