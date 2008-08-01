{-# OPTIONS_GHC -fglasgow-exts -fallow-undecidable-instances -fno-warn-orphans -funbox-strict-fields -cpp -fallow-overlapping-instances #-}

{-|
    This module provides 'genPIR', a function which compiles the current
    environment to PIR code.

    The general plan is to first compile the environment (subroutines,
    statements, etc.) to an abstract syntax tree ('PIL' -- Pugs Intermediate
    Language) using the 'compile' function and 'Compile' class, and then
    translate the PIL_to a data structure of type 'PIR' using the 'trans'
    function and 'Translate' class. This data structure is then reduced to
    final PIR code by "Emit.PIR".
-}

module Pugs.CodeGen.PIR (genPIR, genPIR_YAML) where
import Pugs.Internals
import Pugs.AST hiding (Sig(..), PureSig)
import Pugs.Types
import Pugs.PIL1
import Language.PIR
import Pugs.Pretty
import Text.PrettyPrint
import Pugs.CodeGen.PIR.Prelude (preludeStr)
import Pugs.Prim.Eval
import Pugs.Compile
import Pugs.Run (getLibs)
import DrIFT.YAML
import qualified Data.ByteString.UTF8 as Str

type CodeGen a = WriterT [Stmt] (ReaderT TEnv IO) a
type CodeGenMonad = WriterT [Stmt] (ReaderT TEnv IO)

ratToNum :: VRat -> VNum
ratToNum x = (fromIntegral $ numerator x) / (fromIntegral $ denominator x)

{-| Currently only 'PIL' → 'PIR' -}
class (Show a, Typeable b) => Translate a b | a -> b where
    trans :: a -> CodeGen b
    trans _ = fail "Untranslatable construct!"

instance EnterClass CodeGenMonad TCxt where
    enter cxt = local (\e -> e{ tCxt = cxt })

transError :: forall a b. Translate a b => a -> CodeGen b
transError = die $ "Translate error -- invalid "
    ++ (show $ typeOf (undefined :: b))

instance Translate PIL_Stmts [Stmt] where
    trans PNil = return []
    trans (PStmts this rest) = do
        thisC   <- trans this
        tell [thisC]
        trans rest
    trans (PPad SMy pad exps) = do
        valsC   <- mapM trans (map snd pad)
        pass $ do
            expsC   <- trans exps
            return ([], (StmtPad (map fst pad `zip` valsC) expsC:))
    trans (PPad _ pad exps) = do
        -- XXX - maybe warn about bad pads?
        trans (PPad SMy pad exps)

instance Translate PIL_Stmt Stmt where
    trans PNoop = return (StmtComment "")
    trans (PStmt (PLit (PVal VUndef))) = return $ StmtComment ""
    trans (PStmt (PLit (PVal VType{}))) = return $ StmtComment ""
    trans (PStmt exp) = do
        expC    <- trans exp
        return $ StmtIns $ InsExp expC
    trans (PPos pos exp rest) = do
        dep     <- asks tTokDepth
        tell [StmtComment $ (replicate dep ' ') ++ "{{{ " ++ pretty exp]
        expC    <- local (\e -> e{ tTokDepth = dep + 1 }) $ trans rest
        tell [StmtComment $ (replicate dep ' ') ++ "}}} " ++ pretty pos]
        return expC

instance Translate PIL_Expr Expression where
    trans (PRawName name) = fmap ExpLV $ genName name
    trans (PExp exp) = fmap ExpLV $ trans exp
    trans (PLit (PVal VUndef)) = do
        pmc     <- genScalar "undef"
        return $ ExpLV pmc
    trans (PLit (PVal VType{})) = do
        pmc     <- genScalar "undef"
        return $ ExpLV pmc
    trans (PLit lit) = do
        -- generate fresh supply and things...
        litC    <- trans lit
        pmc     <- genScalar "lit"
        tellIns $ pmc <== litC
        return $ ExpLV pmc
    trans (PThunk exp) = do
        [begL, _]  <- genLabel ["thunk", "thunkInit"]
        this    <- genPMC "thunk"
        let begP = begL ++ "_C"
        tellIns $ InsConst (VAR begP) Sub (lit begL)
        tellIns $ reg this <-- "newclosure" $ [bare begP]
        -- inner subroutine begins
        censor ((:[]) . StmtSub begL) $ do
            -- tellIns $ "push_eh" .- [bare initL]
            expC <- trans exp
            tellIns $ "set_returns" .- retSigList [expC]
            tellIns $ "returncc" .- []
        return (ExpLV this)
    trans (PCode styp params _ _ body) = do
        [begL]  <- genLabel ["block"]
        this    <- genPMC "block"
        let begP = begL ++ "_C"
        tellIns $ InsConst (VAR begP) Sub (lit begL)
        tellIns $ reg this <-- "newclosure" $ [bare begP]
        -- inner subroutine begins
        censor ((:[]) . StmtSub begL) $ do
            let prms = map tpParam params
            tell [StmtPad (map prmToPad prms) []]
            tellIns $ "get_params" .- sigList (map prmToSig prms)
            wrapSub styp $ do
                mapM storeLex params
                bodyC   <- case body of
                    PNil -> return nullPMC
                    _    -> trans body >> lastPMC
                tellIns $ "set_returns" .- retSigList [bodyC]
                tellIns $ "returncc" .- []
        return (ExpLV this)

prmToPad :: Param -> (VarName, Expression)
prmToPad prm = (cast (paramName prm), ExpLV (VAR $ prmToIdent prm))

isQualified :: String -> Maybe (String, String)
isQualified name
    | Just (post, pre) <- breakOnGlue "::" (reverse name) =
    let (sigil, pkg) = span (not . isAlphaNum) preName
        name'       = possiblyFixOperatorName (cast $ sigil ++ postName)
        preName     = reverse pre
        postName    = reverse post
    in case takeWhile isAlphaNum pkg of
        "OUTER"     -> Nothing
        "CALLER"    -> Nothing
        _           -> Just (pkg, cast name')
isQualified _ = Nothing

instance Translate PIL_Decl Decl where
    trans (PSub name styp params lvalue ismulti body) 
        | Just (pkg, name') <- isQualified name = do
            declC <- trans $ PSub (cast name') styp params lvalue ismulti body
            return $ DeclNS (cast pkg) [declC]
    trans (PSub name styp params _ _ body) = do
        (_, stmts)  <- listen $ do
            let prms = map tpParam params
            tell [StmtPad (map prmToPad prms) []]
            tellIns $ "get_params" .- sigList (map prmToSig prms)
            -- tellIns $ "new_pad" .- [lit curPad]
            wrapSub styp $ do
                mapM storeLex params
                bodyC   <- case body of
                    PNil -> return nullPMC
                    _    -> trans body >> lastPMC
                tellIns $ "set_returns" .- retSigList [bodyC]
                tellIns $ "returncc" .- []
        return (DeclSub name [SubOUTER "MAIN"] stmts)

instance Translate PIL_Literal Expression where
    trans (PVal (VBool bool)) = return $ ExpLit (LitInt (toInteger $ fromEnum bool))
    trans (PVal (VStr str)) = return $ ExpLit (LitStr str)
    trans (PVal (VInt int)) = return $ ExpLit (LitInt int)
    trans (PVal (VNum num)) = return $ ExpLit (LitNum num)
    trans (PVal (VRat rat)) = return $ ExpLit (LitNum (ratToNum rat))
    -- trans (PVal (VList [])) = return $ LitInt 0 -- XXX Wrong
    trans (PVal (VCode code))
        | MkCode{ subBody = Syn "block" [ Ann _ exp ] } <- code
        , App (Var var) Nothing [] <- exp
        = fmap ExpLV (trans (PVar $ cast var))
    trans (PVal (VList vs)) = do
        pmc <- genArray "vlist"
        forM vs $ \val -> do
            valC <- trans (PVal val)
            tellIns $ "push" .- [pmc, valC]
        return pmc
    trans val@(PVal _) = transError val

instance Translate PIL_LValue LValue where
    trans (PVar name) | Just (pkg, name') <- isQualified (cast name) = do
        [globL] <- genLabel ["glob"]
        pmc     <- genScalar "glob"
        tell [StmtRaw (text "errorsoff .PARROT_ERRORS_GLOBALS_FLAG")]
        tellIns $ pmc       <-- "find_global" $ [lit pkg, lit name']
        -- XXX - change this to an unless_null call on parrot 0.4.2!
        tellIns $ tempINT   <-- "defined" $ [reg pmc]
        tellIns $ "if" .- [tempINT, bare globL]
        tellIns $ InsNew pmc PerlScalar
        tellIns $ "store_global" .- [lit pkg, lit name', reg pmc]
        tellLabel globL
        tell [StmtRaw (text "errorson .PARROT_ERRORS_GLOBALS_FLAG")]
        return pmc
    -- XXX - hack to erase OUTER before we have proper pad uplevel support
    trans (PVar name)
        | Just (package, name') <- breakOnGlue "::" name
        , Just (sig, "") <- breakOnGlue "OUTER" package
        = trans $ PVar (sig ++ name')
    trans (PVar name) = do
        pmc     <- genScalar "lex"
        tellIns $ pmc <-- "find_name" $ [lit $ possiblyFixOperatorName $ cast name]
        return pmc
    trans (PAssign [lhs] rhs) = do
        lhsC    <- enter tcLValue $ trans lhs
        rhsC    <- trans rhs
        tellIns $ lhsC <== rhsC
        return lhsC
    trans (PBind [PVar name] rhs) = do
        rhsC    <- trans rhs
        tellIns $ "store_lex" .- [lit name, rhsC]
        trans (PVar name)
    trans (PBind [lhs] rhs) = do
        lhsC    <- enter tcLValue $ trans lhs
        rhsC    <- trans rhs
        tellIns $ lhsC <:= rhsC
        return lhsC
    trans (PApp _ exp@PCode{} Nothing []) = do
        blockC  <- trans exp
        tellIns $ [reg tempPMC] <-& blockC $ []
        return tempPMC
    trans (PApp (TCxtLValue _) (PExp (PVar "&postcircumfix:[]")) Nothing [PExp lhs, rhs]) = do
        lhsC    <- trans lhs
        rhsC    <- trans rhs
        return $ lhsC `KEYED` rhsC
    trans (PApp ctx fun (Just inv) args) =
        trans (PApp ctx fun Nothing (inv:args))  -- XXX wrong
    trans (PApp _ fun Nothing args) = do
        funC <- trans fun {- case fun of
            PExp (PVar name) -> return $ lit name
            _           -> trans fun
        -}
        argsC   <- mapM trans args
        -- XXX WORKAROUND PARROT BUG (see below)
        pmc     <- genScalar "app"
        -- XXX - probe if funC is slurpy, then modify ExpLV pmc accordingly
        tellIns $ [reg pmc] <-& funC $ argsC
        return pmc
        {- XXX PARROT BUG -- tailcall broken
        case cxt of
            TTailCall _ -> do
                tellIns $ InsTailFun funC argsC
                return nullPMC
            _ -> do
                pmc     <- genScalar "app"
                -- XXX - probe if funC is slurpy, then modify ExpLV pmc accordingly
                tellIns $ [reg pmc] <-& funC $ argsC
                return pmc
        -}
    trans x = transError x

instance LiteralClass Var where
    lit = ExpLit . LitStr . cast

instance LiteralClass ByteString where
    lit = ExpLit . LitStr . cast

-- XXX - slow way of implementing "return"
wrapSub :: SubType -> CodeGen () -> CodeGen ()
wrapSub SubPrim = id
wrapSub SubBlock = id -- XXX not really
wrapSub _ = \body -> do
    [retL, errL] <- genLabel ["returnHandler", "errHandler"]
    tellIns $ "push_eh" .- [bare retL]
    body
    tellLabel retL
    tellIns $ ("get_results" .- sigList [tempPMC, tempSTR])
    tellIns $ "clear_eh" .- []
    tellIns $ tempSTR <-- "typeof" $ [tempPMC]
    tellIns $ "eq" .- [tempSTR, lit "Exception", bare errL]
    tellIns $ "set_returns" .- sigList [tempPMC]
    tellIns $ "returncc" .- []
    tellLabel errL
    tellIns $ "throw" .- [tempPMC]

prmToSig :: Param -> Sig
prmToSig prm = MkSig (prmToArgs prm) . bare $ prmToIdent prm

prmToArgs :: Param -> [ArgFlag]
prmToArgs prm = combine 
    [ isSlurpy   ==> MkArgSlurpyArray
    , isOptional ==> MkArgOptional
    ] []
    where
    f ==> arg = if f prm then (arg:) else id

prmToIdent :: Param -> String
prmToIdent = render . varText . cast. paramName

storeLex :: TParam -> CodeGen ()
storeLex param = do
    when (isOptional prm) $ do
        [defC] <- genLabel ["defaultDone"]
        tellIns $ "unless_null" .- [bare name, bare defC]
        case tpDefault param of
            Nothing     -> tellIns $ InsNew (VAR name) PerlScalar
            (Just exp)  -> do
                expC <- trans exp
                -- compile it away
                tellIns $ VAR name <:= expC
        tellLabel defC
    tellIns $ "store_lex" .- [lit (cast var :: VarName), bare name]
    where
    var     = paramName prm
    name    = prmToIdent prm
    prm     = tpParam param

tellIns :: Ins -> CodeGen ()
tellIns = tell . (:[]) . StmtIns

{-| Inserts a label. -}
tellLabel :: String -> CodeGen ()
tellLabel name = tellIns $ InsLabel name

lastPMC :: (RegClass a) => CodeGen a
lastPMC = do
    tvar    <- asks tReg
    io $ stm $ do
        (cur, name) <- readTVar tvar
        return $ case cur of
            0 -> nullPMC
            _ -> reg (VAR (('p':show cur) ++ (if null name then name else ('_':name))))

genPMC :: (RegClass a) => String -> CodeGen a
genPMC name = do
    tvar    <- asks tReg
    name'   <- io $ stm $ do
        (cur, _) <- readTVar tvar
        writeTVar tvar (cur + 1, name)
        return $ ('p':show (cur + 1)) ++ ('_':name)
    tellIns $ InsLocal RegPMC name'
    return $ reg (VAR name')

genWith :: (RegClass a) => (LValue -> Ins) -> String -> CodeGen a
genWith f name = do
    pmc <- genPMC name
    tellIns $ f pmc
    return $ reg pmc

genScalar :: (RegClass a) => String -> CodeGen a
genScalar = genWith (`InsNew` PerlScalar)

genArray :: (RegClass a) => String -> CodeGen a
genArray = genWith (`InsNew` PerlArray)

-- genHash :: (RegClass a) => String -> CodeGen a
-- genHash = genWith (`InsNew` PerlHash)

genLabel :: [String] -> CodeGen [LabelName]
genLabel names = do
    tvar    <- asks tLabel
    cnt     <- io $ stm $ do
        cur <- readTVar tvar
        writeTVar tvar (cur + 1)
        return cur
    return $ map (\name -> "LABEL_" ++ show cnt ++ ('_':name)) names

genName :: (RegClass a) => String -> CodeGen a
genName name = do
    let var = render $ varText name
    tellIns $ InsLocal RegPMC var
    tellIns $ InsNew (VAR var) (varInit name)
    return $ reg (VAR var)

varInit :: String -> ObjType
varInit ('$':_) = PerlScalar
varInit ('@':_) = PerlArray
varInit ('%':_) = PerlHash
varInit ('&':_) = PerlScalar
varInit x       = internalError $ "Invalid name: " ++ x

-- XXX: do something useful with the filename arg
genPIR_YAML :: FilePath -> Eval Val
genPIR_YAML _ = genPIRWith $ \globPIR mainPIR _ -> do
    yaml <- io (showYaml (mainPIR, globPIR))
    return (VStr yaml)

{-| Compiles the current environment to PIR code. -}
genPIR :: FilePath -> Eval Val
genPIR file = genPIRWith $ \globPIR mainPIR penv -> do
    libs        <- io $ getLibs
    return . VStr . unlines $
        [ "#!/usr/bin/env parrot"
        , "# " ++ file
        , renderStyle (Style PageMode 0 0) $ preludePIR $+$ vcat
        -- Namespaces have bugs in both pugs and parrot.
        [ emit $ DeclNS "Main"
        [ DeclSub "init" [SubMAIN, SubANON] $ map StmtIns (
            -- Eventually, we'll have to write our own find_name wrapper (or
            -- fix Parrot's find_name appropriately). See Pugs.Eval.Var.
            -- For now, we simply store $P0 twice.
            [ InsNew tempPMC PerlEnv
            , "store_global"    .- [lit "%*ENV", tempPMC]
            , "store_global"    .- [lit "%ENV", tempPMC]
            , InsNew tempPMC PerlArray
            ] ++ [ "push" .- [tempPMC, lit path] | path <- libs ] ++
            [ "store_global"    .- [lit "@*INC", tempPMC]
            , "store_global"    .- [lit "@INC", tempPMC]
            , InsNew tempPMC PerlArray
            , "store_global"    .- [lit "@*END", tempPMC]
            , "store_global"    .- [lit "@END", tempPMC]
            , InsNew tempPMC PerlArray
            , "store_global"    .- [lit "@*CHECK", tempPMC]
            , "store_global"    .- [lit "@CHECK", tempPMC]
            , "getstdin"        .- [tempPMC]
            , "store_global"    .- [lit "$*IN", tempPMC]
            , "store_global"    .- [lit "$IN", tempPMC]
            , "getstdout"       .- [tempPMC]
            , "store_global"    .- [lit "$*OUT", tempPMC]
            , "store_global"    .- [lit "$OUT", tempPMC]
            , "getstderr"       .- [tempPMC]
            , "store_global"    .- [lit "$*ERR", tempPMC]
            , "store_global"    .- [lit "$ERR", tempPMC]
            , "getinterp"       .- [tempPMC]
            , tempPMC   <:= ExpLV (tempPMC `KEYED` bare ".IGLOBALS_ARGV_LIST")
            , tempPMC2  <-- "shift" $ [tempPMC]
            , "store_global"    .- [lit "@*ARGS", tempPMC]
            , "store_global"    .- [lit "@ARGS", tempPMC]
            , "store_global"    .- [lit "$*PROGRAM_NAME", tempPMC2]
            , "store_global"    .- [lit "$PROGRAM_NAME", tempPMC2]
            -- XXX wrong, should be lexical
            , InsNew tempPMC PerlScalar
            , "store_global"    .- [lit "$_", tempPMC]
            ]) ++ [ StmtRaw (text (name ++ "()")) | PSub name@('_':'_':_) _ _ _ _ _ <- pilGlob penv ] ++
            [ StmtRaw (text "MAIN()")
            , StmtIns $ tempPMC  <-- "find_global" $ [lit "Perl6::Internals", lit "&exit"]
            , StmtIns $ "set_args" .- sigList [MkSig [] lit0]
            , StmtIns $ "invokecc" .- [tempPMC]
            ]
        , DeclSub "MAIN" [SubANON] mainPIR ]
        , emit globPIR ] ]

genPIRWith :: ([Decl] -> [Stmt] -> PIL_Environment -> Eval a) -> Eval a
genPIRWith f = do
    tenv        <- initTEnv
    -- Load the PIR Prelude.
    local (\env -> env{ envDebug = Nothing }) $ do
        opEval style "<prelude-pir>" preludeStr
    penv        <- compile ()
    globPIR     <- runCodeGenGlob tenv (pilGlob penv)
    mainPIR     <- runCodeGenMain tenv (pilMain penv)
    f globPIR mainPIR penv
    where
    style = MkEvalStyle
        { evalResult = EvalResultModule
        , evalError  = EvalErrorFatal
        }

runCodeGenGlob :: TEnv -> [PIL_Decl] -> Eval [Decl]
runCodeGenGlob tenv = mapM $ fmap fst . runCodeGen tenv

runCodeGenMain :: TEnv -> PIL_Stmts -> Eval [Stmt]
runCodeGenMain tenv = fmap snd . runCodeGen tenv

runCodeGen :: (Translate a b) => TEnv -> a -> Eval (b, [Stmt])
runCodeGen tenv = io . (`runReaderT` tenv) . runWriterT . trans
