{-# OPTIONS_GHC -fglasgow-exts #-}

module Pugs.Compile.Pugs (genPugs) where
import Pugs.AST
import Pugs.Types
import Pugs.Internals
import Text.PrettyPrint

class (Show x) => Compile x where
    compile :: x -> Eval Doc
    compile x = fail ("Unrecognized construct: " ++ show x)
    compileList :: [x] -> Eval Doc
    compileList = liftM prettyList . mapM compile

instance (Compile x) => Compile [x] where
    compile = compileList

prettyList :: [Doc] -> Doc
prettyList = brackets . vcat . punctuate comma

prettyDo :: [Doc] -> Doc
prettyDo docs = parens $ text "do" <+> (braces $ vcat (punctuate semi docs))
                                                       

instance Compile Exp where
    compile (Syn syn exps) = do
        expsC <- compileList exps
        return $ prettyDo
                [ text "exps <- sequence $ " <+> expsC
                , text ("return (Syn " ++ show syn ++ " exps)")
                ]
    compile (Stmts exp1 exp2) = do
        exp1C <- compile exp1
        exp2C <- compile exp2
        return $ prettyDo 
                [ text "exp1 <-" <+> exp1C
                , text "exp2 <-" <+> exp2C
                , text "return (Stmts exp1 exp2)"
                ]
    compile (Pad scope pad exp) = do
        padC <- compile pad
        expC <- compile exp
        return $ prettyDo
                [ text "pad <-" <+> padC
                , text "exp <-" <+> expC
                , text ("return (Pad " ++ show scope ++ " pad exp)")
                ]
    compile exp = return $ text "return" $+$ parens (text $ show exp)

instance Compile Pad where
    compile pad = do
        symsC <- mapM compile syms
        return $ text "fmap mkPad . sequence $ "
            $+$ nest 4 (prettyList $ filter (not . isEmpty) symsC)
        where
        syms = padToList pad

instance Compile (String, [(TVar Bool, TVar VRef)]) where
    compile ((_:'?':_), _) = return empty -- XXX - @?INIT etc; punt for now
    compile ((_:'=':_), _) = return empty -- XXX - @=POS etc; punt for now
    compile (n, tvars) = do
        tvarsC <- compile tvars
        return $ prettyDo 
                [ text "tvars <- sequence" <+> tvarsC
                , text ("return (" ++ show n ++ ", tvars)")
                ]

instance Compile (TVar Bool, TVar VRef) where
    compile (fresh, tvar) = do
        freshC <- compile fresh
        tvarC  <- compile tvar
        return $ prettyDo 
                [ text "fresh <-" <+> freshC
                , text "tvar <-" <+> tvarC
                , text "return (fresh, tvar)"
                ]

instance Compile (TVar Bool) where
    compile fresh = do
        bool <- liftSTM $ readTVar fresh
        return $ text "liftSTM" <+> parens (text "newTVar" <+> text (show bool))

instance Compile (TVar VRef) where
    compile fresh = do
        vref    <- liftSTM $ readTVar fresh
        vrefC   <- compile vref
        return $ prettyDo            
                [ text "vref <-" <+> vrefC
                , text "liftSTM (newTVar vref)"
                ]

instance Compile VRef where
    compile (MkRef (ICode cv)) = do
        vsub <- code_fetch cv
        vsubC <- compile vsub
        return (text "return (MkRef " <> 
                parens (sep [text "ICode $ ", vsubC]) <> text ")")
    compile (MkRef (IScalar sv)) | scalar_iType sv == mkType "Scalar::Const"
                                 = do
        sv <- scalar_fetch sv
        svC <- compile sv
        return (text "return (MkRef " <> 
                parens (sep [text "IScalar $ ", svC]) <> text ")")

    compile ref = do
        return $ text $ "newObject (mkType \"" ++ showType (refType ref) ++ "\")"

instance Compile Val where
    compile x = return $ text $ show x

instance Compile VCode where
    compile x = return $ text $ show x

genPugs :: Eval Val
genPugs = do
    exp     <- asks envBody
    glob    <- askGlobal
    globC   <- compile glob
    expC    <- compile exp
    return . VStr . unlines $
        [ "{-# OPTIONS_GHC -fglasgow-exts -fno-warn-unused-imports -fno-warn-unused-binds -O #-}"
        , "module MainCC where"
        , "import Pugs.Run"
        , "import Pugs.AST"
        , "import Pugs.Types"
        , "import Pugs.Internals"
        , ""
        , "mainCC = do"
        , "    glob <- globC"
        , "    exp  <- expC"
        , "    runAST glob exp"
        , ""
        , renderStyle (Style PageMode 0 0) $ text "globC =" <+> globC
        , ""
        , renderStyle (Style PageMode 0 0) $ text "expC =" <+> expC
        , ""
        ]
