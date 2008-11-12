{-# OPTIONS_GHC -fglasgow-exts -fallow-undecidable-instances -fno-warn-orphans -funbox-strict-fields -cpp -fno-warn-deprecations -fallow-overlapping-instances #-}

{-|
    Compiler interface.

>   And words unheard were spoken then
>   Of folk and Men and Elven-kin,
>   Beyond the world were visions showed
>   Forbid to those that dwell therein...
-}

module Pugs.Compile (
    PIL_Stmts(..), PIL_Stmt(..), PIL_Expr(..), PIL_Decl(..), PIL_Literal(..), PIL_LValue(..),
    Compile(..),
    TEnv(..), initTEnv,
    TCxt(..), tcVoid, tcLValue,
    TParam(..),
    EnterClass(..),
    die, varText
) where
import Pugs.AST
import Pugs.Internals
import Pugs.Types
import Pugs.Monads
import Pugs.PIL1
import Language.PIR
import Text.PrettyPrint
import qualified Data.ByteString.Char8 as BS

tcVoid, tcLValue :: TCxt
tcVoid      = TCxtVoid
tcLValue    = TCxtLValue anyType

{-
tcItem, tcSlurpy :: TCxt
tcItem      = TCxtItem anyType
tcSlurpy    = TCxtSlurpy anyType
-}

type Comp = Eval

{-| Currently only 'Exp' → 'PIL' -}
class (Show a, Typeable b) => Compile a b where
    compile :: a -> Comp b
    compile x = fail ("Unrecognized construct: " ++ show x)

-- Compile instances
instance Compile () PIL_Environment where
    compile _ = do
        glob    <- askGlobal
        main    <- asks envBody
        globPIL <- compile glob
        mainPIL <- compile main
        return $ PIL_Environment globPIL mainPIL

instance Compile (Var, [(TVar Bool, TVar VRef)]) PIL_Decl where
    compile = compError

instance Compile Param TParam where
    compile prm = do
        defC <- if isOptional prm
            then fmap Just $ compile (paramDefault prm)
            else return Nothing
        return $ MkTParam
            { tpParam = prm
            , tpDefault = defC
            }

{-| Compiles a 'Pad' to a list of 'PIL_Decl's. Currently, only subroutines and
    @\@*END@ are compiled. -}
instance Compile Pad [PIL_Decl] where
    compile pad = do
        entries' <- mapM canCompile entries
        return $ concat entries'
        where
        entries = sortBy padSort [ (cast var, readPadEntry ref) | (var, ref) <- padToList pad ]
        canCompile (name@('&':_) :: String, sym) = do
            (ref :: VRef) <- sym
            (case ref of
                MkRef ICode{} -> do
                    codes <- readCodesFromRef ref
                    fmap concat $ forM codes (doCode name)
                MkRef (IScalar sv) | scalar_iType sv == mkType "Scalar::Const"
                    -> doCode name =<< fromVal =<< scalar_fetch sv
                _ -> return []) :: Comp [PIL_Decl]
        canCompile ("@*END", sym) = do
            ref     <- sym
            cvList  <- fromVals =<< readRef ref :: Comp [VCode]
            decls   <- eachM cvList $ \(i, cv) -> do
                compile (("&*END_" ++ show i), cv) :: Comp [PIL_Decl]
            compile ("&*END", concat decls)
        canCompile ((_:twigil:_), _) | not (isAlphaNum twigil) = return []
        canCompile (name, sym) = do
            -- translate them into store_global calls?
            -- placing them each into one separate init function?
            val     <- readRef =<< sym
            valC    <- compile val
            let assignC = PAssign [PVar name'] valC
                bodyC   = PStmts (PStmt . PExp $ assignC) PNil
                initL   = "__init_" ++ (render $ varText name)
                name' | ':' `elem` name = name
                      | otherwise = "Main::" ++ name -- XXX wrong
            return [PSub initL SubPrim [] False False bodyC]
        doCode name vsub = case subBody vsub of
            Prim _  -> return []
            _       -> compile (name, vsub)

eachM :: (Monad m) => [a] -> ((Int, a) -> m b) -> m [b]
eachM = forM . ([0..] `zip`)

instance Compile (SubName, [PIL_Decl]) [PIL_Decl] where
    compile (name, decls) = do
        let bodyC = [ PStmts . PStmt . PExp $ PApp tcVoid (PExp (PVar sub)) Nothing []
                    | PSub sub _ _ _ _ _ <- decls
                    ]
        return (PSub name SubPrim [] False False (combine bodyC PNil):decls)

instance Compile (SubName, VCode) [PIL_Decl] where
{-
    compile (name, vsub) | packageOf name /= packageOf (subName vsub) = do
        let storeC  = PBind [PVar $ qualify name] (PExp . PVar . qualify $ subName vsub)
            bodyC   = PStmts (PStmt . PExp $ storeC) PNil
            exportL = "__export_" ++ (render $ varText name)
        return [PSub exportL SubPrim [] False False bodyC]
-}
    compile (name, vsub) = do
        bodyC   <- enter cxtItemAny . compile $ case subBody vsub of
            Syn "block" [body]  -> body
            body                -> body
        paramsC <- compile $ subParams vsub
        return [PSub name (subType vsub) paramsC (subLValue vsub) (isMulti vsub) bodyC]

instance Compile (String, PadEntry) PIL_Expr where
    compile (name, entry) = do
        rv <- readRef =<< readPadEntry entry
        case rv of
            VCode sub   -> return $ PRawName (cast $ subName sub)
            _           -> return $ PRawName name

instance Compile Exp PIL_Stmts where
    -- XXX: pragmas?
    compile (Ann Pos{} rest) = compile rest -- fmap (PPos pos rest) $ compile rest
    compile (Ann Prag{} rest) = compile rest -- fmap (PPos pos rest) $ compile rest
    compile (Ann (Cxt cxt) rest) = enter cxt $ compile rest
    compile (Ann _ rest) = compile rest
{-
    compile (Stmts (Pad SOur _ exp) rest) = do
        compile $ mergeStmts exp rest
    compile (Stmts (Pad scope pad exp) rest) = do
        padC    <- compile [ (cast var :: String, ref) | (var, ref) <- padToList pad ]
        let symC = (map (cast . fst) $ padToList pad) `zip` padC
            exps = [ Syn ":=" [_Var name, _Var from]
                   | (name, PRawName from) <- symC
                   , name /= from
                   ]
        expC    <- compile $ mergeStmts (foldl1 mergeStmts (exps ++ [exp])) rest
        return $ PPad scope symC expC
-}
    compile exp = compileStmts exp

class EnterClass m a where
    enter :: a -> m b -> m b

instance EnterClass Comp VCode where
    enter sub = local (\e -> e{ envLValue = subLValue sub, envContext = CxtItem (subReturns sub) })

instance EnterClass Comp Cxt where
    enter cxt = local (\e -> e{ envContext = cxt })

compileStmts :: Exp -> Comp PIL_Stmts
compileStmts exp = case exp of
    Stmts this Noop -> do
        thisC   <- compile this
        return $ PStmts (tailCall thisC) PNil
        where
        tailCall (PStmt (PExp (PApp cxt fun inv args)))
            = PStmt $ PExp $ PApp (TTailCall cxt) fun inv args
        tailCall (PPos pos exp x) = PPos pos exp (tailCall x)
        tailCall x = x
    Stmts this (Syn "namespace" [Val (VStr sym), Val (VStr pkg), rest]) -> do
        thisC   <- enter cxtVoid $ compile this
        declC   <- enter cxtVoid $ compile decl
        restC   <- enterPackage (cast pkg) $ compileStmts rest
        return $ PStmts thisC $ PStmts declC restC
        where
          -- XXX - kludge.
          decl = App (_Var func) Nothing [(Val (VStr pkg))]
          func = "&" ++ (capitalize sym) ++ "::_create"
          capitalize []     = []
          capitalize (c:cs) = toUpper c:cs

    Stmts this rest -> do
        thisC   <- enter cxtVoid $ compile this
        restC   <- compileStmts rest
        return $ PStmts thisC restC
    Noop        -> return PNil
    _           -> compile (Stmts exp Noop)

instance Compile Val PIL_Stmt where
    compile = fmap PStmt . compile . Val

instance Compile Val PIL_Expr where
    compile = compile . Val

instance Compile Exp PIL_Stmt where
    compile (Ann (Pos pos) rest) = fmap (PPos pos rest) $ compile rest
    compile (Ann (Cxt cxt) rest) = enter cxt $ compile rest
    -- XXX: pragmas?
    compile (Ann Prag{} rest) = compile rest -- fmap (PPos pos rest) $ compile rest
    compile (Ann _ rest) = compile rest
    compile Noop = return PNoop
    {-
    compile (Val val) = do
        cxt     <- asks envContext
        if isVoidCxt cxt
            then case val of
                VBool True      -> compile Noop
                _               -> do
                    warn "Useless use of a constant in void context" val
                    compile Noop
            else compile val
    -}
    compile (Val val) = compile val
    compile (Syn "loop" [exp]) =
        compile (Syn "loop" $ [emptyExp, Val (VBool True), emptyExp, exp])
    compile (Syn "loop" [pre, cond, post, body]) = do
        preC    <- compile pre
        -- loop (...; ; ...) {...} ->
        -- loop (...; True; ...) {...}
        let cond' | unwrap cond == Noop
                  = return $ PStmts (PStmt . PLit . PVal $ VBool True) PNil
                  | otherwise
                  = compile cond
        condC   <- cond'
        bodyC   <- compile body
        postC   <- compile post
        funC    <- compile (_Var "&statement_control:loop")
        return . PStmt . PExp $ PApp TCxtVoid funC Nothing
            [preC, pBlock condC, bodyC, pBlock postC]
    compile exp@(Syn "unless" _) = fmap (PStmt . PExp) $ compConditional exp
    compile exp@(Syn "while" _) = compLoop exp
    compile exp@(Syn "until" _) = compLoop exp
    compile exp@(Syn "postwhile" _) = compLoop exp
    compile exp@(Syn "postuntil" _) = compLoop exp
    compile (Syn "for" [exp, body]) = do
        expC    <- compile exp
        bodyC   <- compile body
        funC    <- compile (_Var "&statement_control:for")
        return . PStmt . PExp $ PApp TCxtVoid funC Nothing [expC, bodyC]
    compile (Syn "given" _) = compile (_Var "$_") -- XXX
    compile (Syn "when" _) = compile (_Var "$_") -- XXX
    compile exp = fmap PStmt $ compile exp

pBlock :: PIL_Stmts -> PIL_Expr
pBlock = PCode SubBlock [] False False

{-
subTCxt :: VCode -> Eval TCxt
subTCxt sub = return $ if subLValue sub
    then TCxtLValue (subReturns sub)
    else TCxtItem (subReturns sub)
-}

askTCxt :: Eval TCxt
askTCxt = do
    env <- ask
    return $ if envLValue env
        then TCxtLValue (typeOfCxt $ envContext env)
        else case envContext env of
            CxtVoid         -> TCxtVoid
            CxtItem typ     -> TCxtItem typ
            CxtSlurpy typ   -> TCxtSlurpy typ

instance (Compile a b) => Compile [a] [b] where
    compile = fmapM compile

instance (Compile a b, Compile a c) => Compile [a] (b, c) where
    compile [x, y] = do { x' <- compile x ; y' <- compile y; return (x', y') }
    compile x = compError x

instance (Compile a b, Compile a c, Compile a d) => Compile [a] (b, c, d) where
    compile [x, y, z] = do { x' <- compile x ; y' <- compile y; z' <- compile z; return (x', y', z') }
    compile x = compError x

instance Compile Exp PIL_LValue where
    compile (Ann Pos{} rest) = compile rest -- fmap (PPos pos rest) $ compile rest
    compile (Ann Prag{} rest) = compile rest
    compile (Ann (Cxt cxt) rest) = enter cxt $ compile rest
    compile (Ann _ rest) = compile rest
    -- XXX: pragmas?
    compile (Var name) = return $ _PVar name
    compile (Syn (sigil:"::()") exps) = do
        compile $ App (_Var "&Pugs::Internals::symbolic_deref") Nothing $
            (Val . VStr $ sigil:""):exps
    compile (App (Var var) (Just inv) args) | var == cast "&goto" = do
        cxt     <- askTCxt
        funC    <- compile inv
        argsC   <- enter cxtItemAny $ compile args
        return $ PApp (TTailCall cxt) funC Nothing argsC
    compile (App fun inv args) = do
        cxt     <- askTCxt
        funC    <- compile fun
        invC    <- maybeM (return inv) compile
        argsC   <- enter cxtItemAny $ compile args
        if isLogicalLazy funC
            then return $ PApp cxt funC invC (head argsC:map PThunk (tail argsC))
            else return $ PApp cxt funC invC argsC
        where
        -- XXX HACK
        isLogicalLazy (PExp (PVar "&infix:or"))  = True
        isLogicalLazy (PExp (PVar "&infix:and")) = True
        isLogicalLazy (PExp (PVar "&infix:andthen")) = True
        isLogicalLazy (PExp (PVar "&infix:orelse")) = True
        isLogicalLazy (PExp (PVar "&infix:||"))  = True
        isLogicalLazy (PExp (PVar "&infix:&&"))  = True
        isLogicalLazy (PExp (PVar "&infix://"))  = True
        isLogicalLazy _ = False
    compile exp@(Syn "if" _) = compConditional exp
    compile exp@(Syn "cond" _) = compConditional exp
    compile (Syn "{}" (x:xs)) = compile $ App (_Var "&postcircumfix:{}") (Just x) xs
    compile (Syn "[]" (x:xs)) = do
        compile (App (_Var "&postcircumfix:[]") (Just x) xs)
    compile (Syn "," exps) = do
        compile (App (_Var "&infix:,") Nothing exps)
    -- Minor hack, my $a = [] is parsed as my $a = [Noop], resulting in my $a =
    -- [undef], which is wrong.
    compile (Syn "\\[]" [Noop]) = do
        compile (App (_Var "&circumfix:[]") Nothing [])
    compile (Syn "\\[]" exps) = do
        compile (App (_Var "&circumfix:[]") Nothing exps)
    compile (Syn name@(sigil:"{}") exps) | (sigil ==) `any` "$@%&" = do
        compile (App (_Var $ "&circumfix:" ++ name) Nothing exps)
    compile (Syn "\\{}" exps) = do
        compile (App (_Var "&circumfix:{}") Nothing exps)
    compile (Syn "*" exps) = do
        compile (App (_Var "&prefix:*") Nothing exps)
    compile (Syn "=" [lhs, rhs]) = do
        lhsC <- enterLValue $ compile lhs
        rhsC <- enterRValue $ compile rhs
        return $ PAssign [lhsC] rhsC
    compile (Syn ":=" exps) = do
        (lhsC, rhsC) <- enterLValue $ compile exps
        return $ PBind [lhsC] rhsC
    compile (Syn syn [lhs, exp]) | last syn == '=' = do
        let op = "&infix:" ++ init syn
        compile $ Syn "=" [lhs, App (_Var op) Nothing [lhs, exp]]
    compile (Syn "but" [obj, block]) =
        compile $ App (_Var "&Pugs::Internals::but_block") Nothing [obj, block]
    compile exp@(Syn "namespace" _) = do
        -- XXX - Is there a better way to wrap Stmts as LValue?
        compile $ App (Syn "sub"
            [ Val . VCode $ mkSub
                { subBody   = Stmts Noop exp
                , subParams = []
                }
            ]) Nothing []
    -- For PIL2 we want real zone separation, e.g.
    --   PApp { pNamedArgs = [...], pPositionalArgs = [...], ... }
    -- For now, using &Pugs::Internals::named_pair is probably ok.
    compile (Syn "named" kv@[_, _]) = do
        compile $ App (_Var "&Pugs::Internals::named_pair") Nothing kv
    compile exp = compError exp

compLoop :: Exp -> Comp PIL_Stmt
compLoop (Syn name [cond, body]) = do
    cxt     <- askTCxt
    condC   <- enter (CxtItem $ mkType "Bool") $ compile cond
    bodyC   <- enter CxtVoid $ compile body
    funC    <- compile (_Var $ "&statement_control:" ++ name)
    return . PStmt . PExp $ PApp cxt funC Nothing [pBlock condC, bodyC]
compLoop exp = compError exp

{-| Compiles a conditional 'Syn' (@if@ and @unless@) to a call to an
    appropriate function call (@&statement_control:if@ or
    @&statement_control:unless@). -}
compConditional :: Exp -> Comp PIL_LValue
compConditional (Syn name exps) = do
    [condC, trueC, falseC] <- compile exps
    funC    <- compile $ _Var ("&statement_control:" ++ name)
    cxt     <- askTCxt
    return $ PApp cxt funC Nothing [condC, PThunk trueC, PThunk falseC]
compConditional exp = compError exp

_PVar :: Var -> PIL_LValue
_PVar = PVar . cast

addPad stmt entry = PPad{pStmts=stmt,pScope=SMy,pSyms=[((BS.unpack $ cast $ fst entry),PRawName "...")]}
{-| Compiles various 'Exp's to 'PIL_Expr's. -}
instance Compile Exp PIL_Expr where
    compile (Ann Pos{} rest) = compile rest -- fmap (PPos pos rest) $ compile rest
    compile (Ann Prag{} rest) = compile rest
    compile (Ann (Cxt cxt) rest) = enter cxt $ compile rest
    compile (Ann _ rest) = compile rest
    -- XXX: pragmas?
    compile (Var name) = return . PExp $ _PVar name
    compile exp@(Val (VCode _)) = compile $ Syn "sub" [exp]
    compile (Val val) = fmap PLit $ compile val
    compile Noop = compile (Val undef)
    compile (Syn "block" [body]) = do
        cxt     <- askTCxt
        bodyC   <- compile body
        return $ PExp $ PApp cxt (pBlock bodyC) Nothing []
    compile (Syn "sub" [Val (VCode sub)]) =  do
        bodyC   <- enter sub $ compile $ case subBody sub of
            Syn "block" [exp]   -> exp
            exp                 -> exp
        paramsC <- compile $ subParams sub
        return $ PCode (subType sub) paramsC (subLValue sub) (isMulti sub) (foldl addPad bodyC (padToList $ subInnerPad sub))
    compile (Syn "module" _) = compile Noop
    compile (Syn "match" exp) = compile $ Syn "rx" exp -- wrong
    compile (Syn "//" exp) = compile $ Syn "rx" exp
    compile (Syn "rx" (exp:_)) = compile exp -- XXX WRONG - use PCRE
    compile (Syn "subst" (exp:_)) = compile exp -- XXX WRONG - use PCRE
    compile (Syn "trans" (exp:_)) = compile exp -- XXX WRONG
    compile (Syn "|" [exp]) = compile exp -- XXX WRONG
    compile (Syn "|<<" [exp]) = compile exp -- XXX WRONG
    compile exp@(App _ _ _) = fmap PExp $ compile exp
    compile exp@(Syn _ _) = fmap PExp $ compile exp
    compile exp = compError exp

compError :: forall a b. Compile a b => a -> Comp b
compError = die $ "Compile error -- invalid "
    ++ (show $ typeOf (undefined :: b))

{-| Compiles a 'Val' to a 'PIL_Literal'. -}
instance Compile Val PIL_Literal where
    compile (VList vs) = return $ PVal (VList (filter isSimple vs))
        where
        isSimple (VRef _) = False
        isSimple _        = True
    compile (VRef _) = return $ PVal VUndef
    compile val = return $ PVal val

-- utility functions
padSort :: (String, a) -> (String, a) -> Ordering
padSort (a, _) (b, _)
    | (head a == ':' && head b == '&') = LT
    | (head b == ':' && head a == '&') = GT
    | otherwise = compare a b

varText :: String -> Doc
varText ('$':name)  = text $ "s__" ++ escaped name
varText ('@':name)  = text $ "a__" ++ escaped name
varText ('%':name)  = text $ "h__" ++ escaped name
varText ('&':name)  = text $ "c__" ++ escaped name
varText x           = error $ "invalid name: " ++ x

initTEnv :: Eval TEnv
initTEnv = do
    initReg <- io $ newTVarIO (0, "")
    initLbl <- io $ newTVarIO 0
    return $ MkTEnv
        { tLexDepth = 0
        , tTokDepth = 0
        , tCxt      = tcVoid
        , tReg      = initReg
        , tLabel    = initLbl
        }

