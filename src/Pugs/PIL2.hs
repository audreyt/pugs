{-# OPTIONS_GHC -fglasgow-exts -funbox-strict-fields -fallow-overlapping-instances -fno-warn-orphans -fno-warn-incomplete-patterns -fallow-undecidable-instances #-}
{- Generated by DrIFT (Automatic class derivations for Haskell) -}
{-# LINE 1 "src/Pugs/PIL2.hs-drift" #-}

{-|
    Pugs Intermediate Language, version 2.

>   And the Tree that was withered shall be renewed,
>   And he shall plant it in the high places,
>   And the City shall be blessed.
>   Sing all ye people!

-}


module Pugs.PIL2 (
    PIL_Environment(..),
    PIL_Stmts(..), PIL_Stmt(..), PIL_Decl(..),
    PIL_Expr(..), PIL_Literal(..), PIL_LValue(..),
    TParam(..), TCxt(..), TEnv(..),
) where
import Pugs.AST hiding (Prim)
import Pugs.Internals hiding (get, put)
import Pugs.Types
import Emit.PIR
import DrIFT.Perl5
import DrIFT.YAML
import DrIFT.JSON

-- import DrIFT.XML
-- {-! global : Haskell2Xml !-}

{-! global : Perl5, JSON, YAML !-}

{-|
    The plan here is to first compile the environment (subroutines,
    statements, etc.) to an abstract syntax tree ('PIL' -- Pugs Intermediate
    Language) using the 'compile' function and 'Compile' class.

- Unify the Apply and Bind forms into method calls.
    Apply becomes .postcircumfix:<( )>
    Bind becomes .infix:<:=>

- Compile-time object initiation built with opaque object binders

- A PIL tree is merely an (unordered!) set of static declarations;
  the responsibility of calling the main function -- let's call it &{''}
  just for fun -- resides on the runtime.

- Anonymous closures -- should they be lambda-lifted and given ANON
  names? If yes this gives us flexibility over CSE (common shared expression)
  optimization, but this may be BDUF.  No λ lifting for now.

- Okay, time to try a simple definition.

   [SRC] say "Hello, World!"
   [PIL] SigList.new('&').infix:<:=>(
            Code.new(
                body => [|
                    ::?MY.postcircumfix<{ }>('&say')
                        .postcircumfix<( )>(Str.new('Hello World'))
                |]
                ... # other misc attributes
            )
        )

    -- Compile time analysis of &say is needed here.
    -- We want to allow possibility of MMD (note _open_ pkgs by default)
       so there needs to be a generic form.
    -- Static binding performed as another optimization pass.

    -- Predefined objects (_always_ bound to the same thing in compiler)
        ::?MY       -- current lexical scope
        ::?OUR      -- current package scope
        Symbol resolution (static vs dynamic lookup) is to be done at
        pass-1 for PIL2.  The "&say" below is _definitely_ dynamic.
        Or is it?  Why?  Because @Larry mandates "multi &*say" instead
        of a more restricted form of ::* as a default lexical scope
        that closes over the toplevel program.  Maybe pursue a ruling
        toward the more static definition, otherwise all builtins become
        _slower_ to infer than userdefined code, which is Just Not Right.

    -- String construction -- handled like perl5 using overload qq""?
       Ask @Larry for ruling over constant creation and propagation rules.
       (probably "use a macro if you'd like to change")
       so, safe to assume a prim form in PIL level.

    -- We _really_ need a quasiquoting notation for macro generation;
       introduce moral equivalent of [|...|] in PIL form, probably just an
       "AST" node.  (in CLR they call it System.Reflection.Expression)
       -- problem with this is it's a closed set; if we are to extend AST
          on the compiler level --
          -- nah, we aren't bootstrapping yet. KISS.

    -- This is a very imperative view; the runtime would be carrying
       instructions of populating the ObjSpace (Smalltalk, Ruby-ish)
       rather than fitting an AST into a lexical evaluator environment
       (LISP, Scheme-ish)

    -- Need better annotator for inferrence to work, esp. now it's
       populated with redundant .postcircumfix calls.  OTOH, they
       can be assumed to be closed under separate-compilation regime,
       so we eventually regain the signature.  But it'd be much slower
       than the current PIL1.  Oy vey.

    -- OTOH, refactor into a Callable role and introduce .apply?
       This is integral's (sensible) suggestion, but we don't have a
       Role system working yet, so why bother.

-}

data PIL_Environment = PIL_Environment
    { pilGlob :: [PIL_Decl]
    , pilMain :: PIL_Stmts
    }
    deriving (Show, Eq, Ord, Typeable)

data PIL_Stmts = PNil
    | PStmts
        { pStmt  :: !PIL_Stmt
        , pStmts :: !PIL_Stmts
        }
    | PPad
        { pScope :: !Scope
        , pSyms  :: ![(VarName, PIL_Expr)]
        , pStmts :: !PIL_Stmts
        }
    deriving (Show, Eq, Ord, Typeable)

data PIL_Stmt = PNoop | PStmt { pExpr :: !PIL_Expr } | PPos
        { pPos  :: !Pos
        , pExp  :: !Exp
        , pNode :: !PIL_Stmt
        }
    deriving (Show, Eq, Ord, Typeable)

data PIL_Expr
    = PRawName { pRawName :: !VarName }
    | PExp { pLV  :: !PIL_LValue }
    | PLit { pLit :: !PIL_Literal }
    | PThunk { pThunk :: !PIL_Expr }
    | PCode
        { pType    :: !SubType
        , pParams  :: ![TParam]
        , pLValue  :: !Bool
        , pIsMulti :: !Bool
        , pBody    :: !PIL_Stmts
        }
    deriving (Show, Eq, Ord, Typeable)

data PIL_Decl = PSub
    { pSubName      :: !SubName
    , pSubType      :: !SubType
    , pSubParams    :: ![TParam]
    , pSubLValue    :: !Bool
    , pSubIsMulti   :: !Bool
    , pSubBody      :: !PIL_Stmts
    }
    deriving (Show, Eq, Ord, Typeable)

data PIL_Literal = PVal { pVal :: Val }
    deriving (Show, Eq, Ord, Typeable)

data PIL_LValue = PVar { pVarName :: !VarName }
    | PApp 
        { pCxt  :: !TCxt
        , pFun  :: !PIL_Expr
        , pInv  :: !(Maybe PIL_Expr)
        , pArgs :: ![PIL_Expr]
        }
    | PAssign
        { pLHS  :: ![PIL_LValue]
        , pRHS  :: !PIL_Expr
        }
    | PBind
        { pLHS  :: ![PIL_LValue]
        , pRHS  :: !PIL_Expr
        }
    deriving (Show, Eq, Ord, Typeable)

data TParam = MkTParam
    { tpParam   :: !Param
    , tpDefault :: !(Maybe (PIL_Expr))
    }
    deriving (Show, Eq, Ord, Typeable)

data TCxt
    = TCxtVoid | TCxtLValue !Type | TCxtItem !Type | TCxtSlurpy !Type
    | TTailCall !TCxt
    deriving (Show, Eq, Ord, Typeable)

data TEnv = MkTEnv
    { tLexDepth :: !Int                 -- ^ Lexical scope depth
    , tTokDepth :: !Int                 -- ^ Exp nesting depth
    , tCxt      :: !TCxt                -- ^ Current context
    , tReg      :: !(TVar (Int, String))-- ^ Register name supply
    , tLabel    :: !(TVar Int)          -- ^ Label name supply
    }
    deriving (Show, Eq, Ord, Typeable)

{-* Generated by DrIFT : Look, but Don't Touch. *-}
instance Perl5 PIL_Environment where
    showPerl5 (PIL_Environment aa ab) =
	      showP5HashObj "PIL::Environment"
	      [("pilGlob", showPerl5 aa) , ("pilMain", showPerl5 ab)]

instance JSON PIL_Environment where
    showJSON (PIL_Environment aa ab) = showJSHashObj "PIL_Environment"
	     [("pilGlob", showJSON aa) , ("pilMain", showJSON ab)]

instance YAML PIL_Environment where
    asYAML (PIL_Environment aa ab) = asYAMLmap "PIL_Environment"
	   [("pilGlob", asYAML aa) , ("pilMain", asYAML ab)]

instance Perl5 PIL_Stmts where
    showPerl5 (PNil) = showP5Class "PNil"
    showPerl5 (PStmts aa ab) = showP5HashObj "PStmts"
	      [("pStmt", showPerl5 aa) , ("pStmts", showPerl5 ab)]
    showPerl5 (PPad aa ab ac) = showP5HashObj "PPad"
	      [("pScope", showPerl5 aa) , ("pSyms", showPerl5 ab) ,
	       ("pStmts", showPerl5 ac)]

instance JSON PIL_Stmts where
    showJSON (PNil) = showJSScalar "PNil"
    showJSON (PStmts aa ab) = showJSHashObj "PStmts"
	     [("pStmt", showJSON aa) , ("pStmts", showJSON ab)]
    showJSON (PPad aa ab ac) = showJSHashObj "PPad"
	     [("pScope", showJSON aa) , ("pSyms", showJSON ab) ,
	      ("pStmts", showJSON ac)]

instance YAML PIL_Stmts where
    asYAML (PNil) = asYAMLcls "PNil"
    asYAML (PStmts aa ab) = asYAMLmap "PStmts"
	   [("pStmt", asYAML aa) , ("pStmts", asYAML ab)]
    asYAML (PPad aa ab ac) = asYAMLmap "PPad"
	   [("pScope", asYAML aa) , ("pSyms", asYAML ab) ,
	    ("pStmts", asYAML ac)]

instance Perl5 PIL_Stmt where
    showPerl5 (PNoop) = showP5Class "PNoop"
    showPerl5 (PStmt aa) = showP5HashObj "PStmt"
	      [("pExpr", showPerl5 aa)]
    showPerl5 (PPos aa ab ac) = showP5HashObj "PPos"
	      [("pPos", showPerl5 aa) , ("pExp", showPerl5 ab) ,
	       ("pNode", showPerl5 ac)]

instance JSON PIL_Stmt where
    showJSON (PNoop) = showJSScalar "PNoop"
    showJSON (PStmt aa) = showJSHashObj "PStmt"
	     [("pExpr", showJSON aa)]
    showJSON (PPos aa ab ac) = showJSHashObj "PPos"
	     [("pPos", showJSON aa) , ("pExp", showJSON ab) ,
	      ("pNode", showJSON ac)]

instance YAML PIL_Stmt where
    asYAML (PNoop) = asYAMLcls "PNoop"
    asYAML (PStmt aa) = asYAMLmap "PStmt" [("pExpr", asYAML aa)]
    asYAML (PPos aa ab ac) = asYAMLmap "PPos"
	   [("pPos", asYAML aa) , ("pExp", asYAML ab) , ("pNode", asYAML ac)]

instance Perl5 PIL_Expr where
    showPerl5 (PRawName aa) = showP5HashObj "PRawName"
	      [("pRawName", showPerl5 aa)]
    showPerl5 (PExp aa) = showP5HashObj "PExp" [("pLV", showPerl5 aa)]
    showPerl5 (PLit aa) = showP5HashObj "PLit" [("pLit", showPerl5 aa)]
    showPerl5 (PThunk aa) = showP5HashObj "PThunk"
	      [("pThunk", showPerl5 aa)]
    showPerl5 (PCode aa ab ac ad ae) = showP5HashObj "PCode"
	      [("pType", showPerl5 aa) , ("pParams", showPerl5 ab) ,
	       ("pLValue", showPerl5 ac) , ("pIsMulti", showPerl5 ad) ,
	       ("pBody", showPerl5 ae)]

instance JSON PIL_Expr where
    showJSON (PRawName aa) = showJSHashObj "PRawName"
	     [("pRawName", showJSON aa)]
    showJSON (PExp aa) = showJSHashObj "PExp" [("pLV", showJSON aa)]
    showJSON (PLit aa) = showJSHashObj "PLit" [("pLit", showJSON aa)]
    showJSON (PThunk aa) = showJSHashObj "PThunk"
	     [("pThunk", showJSON aa)]
    showJSON (PCode aa ab ac ad ae) = showJSHashObj "PCode"
	     [("pType", showJSON aa) , ("pParams", showJSON ab) ,
	      ("pLValue", showJSON ac) , ("pIsMulti", showJSON ad) ,
	      ("pBody", showJSON ae)]

instance YAML PIL_Expr where
    asYAML (PRawName aa) = asYAMLmap "PRawName"
	   [("pRawName", asYAML aa)]
    asYAML (PExp aa) = asYAMLmap "PExp" [("pLV", asYAML aa)]
    asYAML (PLit aa) = asYAMLmap "PLit" [("pLit", asYAML aa)]
    asYAML (PThunk aa) = asYAMLmap "PThunk" [("pThunk", asYAML aa)]
    asYAML (PCode aa ab ac ad ae) = asYAMLmap "PCode"
	   [("pType", asYAML aa) , ("pParams", asYAML ab) ,
	    ("pLValue", asYAML ac) , ("pIsMulti", asYAML ad) ,
	    ("pBody", asYAML ae)]

instance Perl5 PIL_Decl where
    showPerl5 (PSub aa ab ac ad ae af) = showP5HashObj "PSub"
	      [("pSubName", showPerl5 aa) , ("pSubType", showPerl5 ab) ,
	       ("pSubParams", showPerl5 ac) , ("pSubLValue", showPerl5 ad) ,
	       ("pSubIsMulti", showPerl5 ae) , ("pSubBody", showPerl5 af)]

instance JSON PIL_Decl where
    showJSON (PSub aa ab ac ad ae af) = showJSHashObj "PSub"
	     [("pSubName", showJSON aa) , ("pSubType", showJSON ab) ,
	      ("pSubParams", showJSON ac) , ("pSubLValue", showJSON ad) ,
	      ("pSubIsMulti", showJSON ae) , ("pSubBody", showJSON af)]

instance YAML PIL_Decl where
    asYAML (PSub aa ab ac ad ae af) = asYAMLmap "PSub"
	   [("pSubName", asYAML aa) , ("pSubType", asYAML ab) ,
	    ("pSubParams", asYAML ac) , ("pSubLValue", asYAML ad) ,
	    ("pSubIsMulti", asYAML ae) , ("pSubBody", asYAML af)]

instance Perl5 PIL_Literal where
    showPerl5 (PVal aa) = showP5HashObj "PVal" [("pVal", showPerl5 aa)]

instance JSON PIL_Literal where
    showJSON (PVal aa) = showJSHashObj "PVal" [("pVal", showJSON aa)]

instance YAML PIL_Literal where
    asYAML (PVal aa) = asYAMLmap "PVal" [("pVal", asYAML aa)]

instance Perl5 PIL_LValue where
    showPerl5 (PVar aa) = showP5HashObj "PVar"
	      [("pVarName", showPerl5 aa)]
    showPerl5 (PApp aa ab ac ad) = showP5HashObj "PApp"
	      [("pCxt", showPerl5 aa) , ("pFun", showPerl5 ab) ,
	       ("pInv", showPerl5 ac) , ("pArgs", showPerl5 ad)]
    showPerl5 (PAssign aa ab) = showP5HashObj "PAssign"
	      [("pLHS", showPerl5 aa) , ("pRHS", showPerl5 ab)]
    showPerl5 (PBind aa ab) = showP5HashObj "PBind"
	      [("pLHS", showPerl5 aa) , ("pRHS", showPerl5 ab)]

instance JSON PIL_LValue where
    showJSON (PVar aa) = showJSHashObj "PVar"
	     [("pVarName", showJSON aa)]
    showJSON (PApp aa ab ac ad) = showJSHashObj "PApp"
	     [("pCxt", showJSON aa) , ("pFun", showJSON ab) ,
	      ("pInv", showJSON ac) , ("pArgs", showJSON ad)]
    showJSON (PAssign aa ab) = showJSHashObj "PAssign"
	     [("pLHS", showJSON aa) , ("pRHS", showJSON ab)]
    showJSON (PBind aa ab) = showJSHashObj "PBind"
	     [("pLHS", showJSON aa) , ("pRHS", showJSON ab)]

instance YAML PIL_LValue where
    asYAML (PVar aa) = asYAMLmap "PVar" [("pVarName", asYAML aa)]
    asYAML (PApp aa ab ac ad) = asYAMLmap "PApp"
	   [("pCxt", asYAML aa) , ("pFun", asYAML ab) , ("pInv", asYAML ac) ,
	    ("pArgs", asYAML ad)]
    asYAML (PAssign aa ab) = asYAMLmap "PAssign"
	   [("pLHS", asYAML aa) , ("pRHS", asYAML ab)]
    asYAML (PBind aa ab) = asYAMLmap "PBind"
	   [("pLHS", asYAML aa) , ("pRHS", asYAML ab)]

instance Perl5 TParam where
    showPerl5 (MkTParam aa ab) = showP5HashObj "MkTParam"
	      [("tpParam", showPerl5 aa) , ("tpDefault", showPerl5 ab)]

instance JSON TParam where
    showJSON (MkTParam aa ab) = showJSHashObj "MkTParam"
	     [("tpParam", showJSON aa) , ("tpDefault", showJSON ab)]

instance YAML TParam where
    asYAML (MkTParam aa ab) = asYAMLmap "MkTParam"
	   [("tpParam", asYAML aa) , ("tpDefault", asYAML ab)]

instance Perl5 TCxt where
    showPerl5 (TCxtVoid) = showP5Class "TCxtVoid"
    showPerl5 (TCxtLValue aa) = showP5ArrayObj "TCxtLValue"
	      [showPerl5 aa]
    showPerl5 (TCxtItem aa) = showP5ArrayObj "TCxtItem" [showPerl5 aa]
    showPerl5 (TCxtSlurpy aa) = showP5ArrayObj "TCxtSlurpy"
	      [showPerl5 aa]
    showPerl5 (TTailCall aa) = showP5ArrayObj "TTailCall"
	      [showPerl5 aa]

instance JSON TCxt where
    showJSON (TCxtVoid) = showJSScalar "TCxtVoid"
    showJSON (TCxtLValue aa) = showJSArrayObj "TCxtLValue"
	     [showJSON aa]
    showJSON (TCxtItem aa) = showJSArrayObj "TCxtItem" [showJSON aa]
    showJSON (TCxtSlurpy aa) = showJSArrayObj "TCxtSlurpy"
	     [showJSON aa]
    showJSON (TTailCall aa) = showJSArrayObj "TTailCall" [showJSON aa]

instance YAML TCxt where
    asYAML (TCxtVoid) = asYAMLcls "TCxtVoid"
    asYAML (TCxtLValue aa) = asYAMLseq "TCxtLValue" [asYAML aa]
    asYAML (TCxtItem aa) = asYAMLseq "TCxtItem" [asYAML aa]
    asYAML (TCxtSlurpy aa) = asYAMLseq "TCxtSlurpy" [asYAML aa]
    asYAML (TTailCall aa) = asYAMLseq "TTailCall" [asYAML aa]

instance Perl5 TEnv where
    showPerl5 (MkTEnv aa ab ac ad ae) = showP5HashObj "MkTEnv"
	      [("tLexDepth", showPerl5 aa) , ("tTokDepth", showPerl5 ab) ,
	       ("tCxt", showPerl5 ac) , ("tReg", showPerl5 ad) ,
	       ("tLabel", showPerl5 ae)]

instance JSON TEnv where
    showJSON (MkTEnv aa ab ac ad ae) = showJSHashObj "MkTEnv"
	     [("tLexDepth", showJSON aa) , ("tTokDepth", showJSON ab) ,
	      ("tCxt", showJSON ac) , ("tReg", showJSON ad) ,
	      ("tLabel", showJSON ae)]

instance YAML TEnv where
    asYAML (MkTEnv aa ab ac ad ae) = asYAMLmap "MkTEnv"
	   [("tLexDepth", asYAML aa) , ("tTokDepth", asYAML ab) ,
	    ("tCxt", asYAML ac) , ("tReg", asYAML ad) , ("tLabel", asYAML ae)]

--  Imported from other files :-
