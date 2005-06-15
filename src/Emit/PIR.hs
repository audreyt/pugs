{-# OPTIONS_GHC -fglasgow-exts -fallow-overlapping-instances #-}

module Emit.PIR where
import Text.PrettyPrint
import Data.Char

data RegType = RegInt | RegNum | RegStr | RegPMC
    deriving (Show, Eq)

data RelOp = RelLT | RelLE | RelEQ | RelNE | RelGE | RelGT
    deriving (Show, Eq)

data ObjType    = PerlUndef
    deriving (Show, Eq)

type LabelName  = String
type SubName    = String
type VarName    = String
type PrimName   = String
type PkgName    = String

data Identifier
    = VAR VarName
    | PMC Int
    | STR Int
    | LIT Literal
    deriving (Show, Eq)

data Literal
    = LitStr String
    | LitInt Integer
    | LitNum Double
    deriving (Show, Eq)

class (Show x) => Emit x where
    emit :: x -> Doc
    -- emit x = error ("Unrecognized construct: " ++ show x)

instance Emit String where
    emit = text

instance Emit Decl where
    emit (DeclNS name) = emit ".namespace" <+> brackets (quotes $ emit name)
    emit (DeclSub name styps stmts)
        =  (emit ".sub" <+> doubleQuotes (emit name) <+> commaSep styps)
        $+$ nested stmts
        $+$ emit ".end"

instance Emit SubType where
    emit = emit . ('@':) . drop 3 . show

instance (Emit a) => Emit [a] where
    emit = vcat . map emit

nested :: (Emit x) => x -> Doc
nested = nest 4 . emit

eqSep :: (Emit a, Emit b, Emit c) => a -> b -> [c] -> Doc
eqSep lhs rhs args = emit lhs <+> equals <+> emit rhs <+> commaSep args

commaSep :: (Emit x) => [x] -> Doc
commaSep = hsep . punctuate comma . map emit

curPad :: Doc
curPad = int (-1)

instance Emit Stmt where
    emit (StmtComment []) = empty
    emit (StmtComment str) = char '#' <+> emit str
    emit (StmtLine file line) = text "#line" <+> doubleQuotes (emit file) <+> emit line
    emit (StmtIns ins) = emit ins
    emit (StmtLabel name ins) = emit name <> colon $+$ emit ins
    emit (StmtPad stmts) = emit "new_pad" <+> curPad

instance Emit RegType where
    emit = emit . map toLower . drop 3 . show

instance Emit Ins where
    emit (InsLocal rtyp name) = emit ".local" <+> emit rtyp <+> emit name
    emit (InsNew ident otyp) = eqSep ident "new" [otyp]
    emit (InsAssign ident lit) = eqSep ident lit noArgs
    emit (InsPrim (Just ret) name args) = eqSep ret name args
    emit (InsPrim Nothing name args) = emit name <+> commaSep args
    emit (InsFun rets name args) = vcat
        [ eqSep (PMC 10) "find_name" [LitStr name]
        , emit "set_args" <+> sig <> comma <+> commaSep args
        , emit "invokecc" <+> emit (PMC 10)
        ]
        where
        sig = quotes $ parens (commaSep (replicate (length args) "0b1000"))
    emit x = error $ "can't emit: " ++ show x

noArgs :: [Identifier]
noArgs = []

-- set_args '(0b0,0b0,0b0)', $P1, $P2, $P3

instance Emit ObjType where
    emit = emit . ('.':) . show

instance Emit Identifier where
    emit (VAR name) = emit name
    emit (PMC num) = emit "$P" <> emit num
    emit (STR str) = emit "$S" <> emit str
    emit (LIT lit) = emit lit

instance Emit Literal where
    emit (LitStr str) = text . show $ concatMap quoted str
        where
        quoted :: Char -> String
        quoted '\'' = "\\'"
        quoted '\\' = "\\\\"
        quoted x = [x]

instance Emit Int where
    emit = int

data Stmt
    = StmtComment   String
    | StmtLine      FilePath Int
    | StmtIns       Ins
    | StmtLabel     LabelName Ins
    | StmtPad       [Stmt]
    deriving (Show, Eq)

data Ins
    = InsLocal      RegType VarName
    | InsNew        Identifier ObjType 
    | InsBind       Identifier Identifier
    | InsAssign     Identifier Literal
    | InsFun        [Identifier] PrimName [Identifier]
    | InsPrim       (Maybe Identifier) PrimName [Identifier]
    | InsStoreLex   VarName Identifier
    deriving (Show, Eq)

data SubType = SubMAIN | SubLOAD | SubANON | SubMETHOD | SubMULTI [ObjType]
    deriving (Show, Eq)

type PIR = [Decl]

data Decl
    = DeclSub   SubName [SubType] [Stmt]
    | DeclNS    PkgName
    deriving (Show, Eq)

infixl 4 <--
infixl 4 .-
infixl 4 <-&
infixl 4 .&

namespace = DeclNS
x <-- (name, args) = InsPrim (Just x) name args
x <-& (name, args) = InsFun x name args
(.-) = InsPrim Nothing
(.&) = InsFun []


p0 :: Identifier
p0 = PMC 0

s0 :: Identifier
s0 = STR 0

class LiteralClass x y | x -> y where
    lit :: x -> y 

instance LiteralClass String Identifier where
    lit = LIT . LitStr

sub :: SubName -> [Sig] -> [Ins] -> Decl
sub name sigs body = DeclSub name [] stmts
    where
    param = "get_params" .- (flags:map sigIdent sigs)
    stmts = map StmtIns (param:body)
    flags = lit . render . parens . commaSep $ map sigFlags sigs

instance Emit [SigFlag] where
    emit [MkSigSlurpy] = emit "0b1000"
    emit [] = emit "0b0"

data Sig = MkSig
    { sigFlags  :: [SigFlag]
    , sigIdent  :: Identifier
    }
    deriving (Show, Eq)
data SigFlag = MkSigSlurpy
    deriving (Show, Eq)

slurpy :: Identifier -> Sig
slurpy = MkSig [MkSigSlurpy]

preludePIR :: Doc
preludePIR = emit $
    [ sub "&print" [slurpy p0]
        [ s0 <-- ("join", [lit "", p0])
        , "print" .- [s0]
        ]
    , sub "&say" [slurpy p0]
        [ "&print" .& [p0]
        , "print" .- [lit "\n"]
        ]
    , namespace "main"
    ]

