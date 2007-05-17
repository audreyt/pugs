{-# OPTIONS_GHC -fglasgow-exts -fallow-overlapping-instances #-}

{-|
    Pretty printing for various data structures.

>   Galadriel! Galadriel!
>   Clear is the water of your well;
>   White is the stars in your white hand;
>   Unmarred, unstained is leaf and land
>   In Dwimordene, in Lorien
>   More fair than thoughts of Mortal Men.
-}

module Pugs.Pretty (
    Pretty(..), pretty, priggy,
) where
import Pugs.Internals
import Pugs.Types
import Pugs.AST
import qualified Pugs.Val as Val
import Pugs.Rule (SourcePos)
import Text.PrettyPrint
import qualified Data.Set as Set
import qualified Data.Map as Map

defaultIndent :: Int
defaultIndent = 2

class (Show a) => Pretty a where
    format, formatQuite :: a -> Doc
    format x = text $ show x
    formatQuite = format

instance Pretty VStr
instance Pretty Var

instance Pretty EntryFlags where
    format (MkEntryFlags True)  = text "(is context)"
    format _                    = empty

instance Pretty Exp where
    format (NonTerm pos) = text "Syntax error at" <+> format pos
    format (Val v) = format v
    format (Syn x vs) = text "Syn" <+> format x <+> (braces $ vcat (punctuate (text ";") (map format vs)))
    format (Stmts exp1 exp2) = (vcat $ punctuate (text ";") $ (map format) [exp1, exp2])
    format (App (Var name) invs args) = text "App" <+> text (cast name) <+> parens (nest defaultIndent $ cat (punctuate (text ": ") [ cat (punctuate (text ", ") (map format x)) | x <- [maybeToList invs, args] ]))
    format (App sub invs args) = text "App" <+> parens (format sub) <+> parens (nest defaultIndent $ vcat (punctuate (text ", ") (map format $ maybeToList invs ++ args)))
    format (Sym scope name flags init exp) = text "Sym" <+> text (show scope) <+> format name <+> format flags <+> format init $+$ format exp
    format (Ann _ exp) = format exp
    format x = text $ show x
    formatQuite (Syn "," xs) = parens (formatQuite xs)
    formatQuite (App (Var var) Nothing args)
        | C_infix <- v_categ var
        = parens (hsep (punctuate (text . (' ':) . cast $ v_name var) (map formatQuite args)))
        | otherwise
        = text (showsVar var "") <> parens (formatQuite args)
    formatQuite (App (Var var) (Just inv) args)
        = formatQuite inv <> char '.' <> text (cast $ v_name var) <> parens (formatQuite args)
    formatQuite (Ann _ exp) = formatQuite exp
    formatQuite x = format x

instance Pretty [Exp] where
    format xs = hsep (punctuate comma (map format xs))
    formatQuite xs = hsep (punctuate comma (map formatQuite xs))

instance Pretty (TVar Bool, TVar VRef) where
    format (_, tvar) = format tvar

instance Pretty Type where
    format = format . showType

instance Pretty PadEntry where
    format x = format (pe_type x) <+> format (pe_proto x)

instance Pretty Pad where
    format pad = vcat $ map formatAssoc $ padToList pad
        where
        formatAssoc (name, var) = format name <+> text ":=" <+> (nest defaultIndent $ format var)

instance Pretty Pos where
    format pos =
        let file = cast (posName pos)
            bln  = show $ posBeginLine pos
            bcl  = show $ posBeginColumn pos
            eln  = show $ posEndLine pos
            ecl  = show $ posEndColumn pos
            fmt ln cl = text "line" <+> text ln <> comma <+> text "column" <+> text cl
        in text file <+> case (bln == eln, bcl == ecl) of
            (True, True)  -> fmt bln bcl
            (True, False) -> fmt bln (bcl ++ "-" ++ ecl)
            (False, _)    -> fmt bln bcl <+> (text "-" <+> fmt eln ecl)

instance Pretty SubType where
    format = text . map toLower . drop 3 . show

instance Pretty Env where
    format x = doubleBraces $ nest defaultIndent (format $ envBody x) 

instance Pretty (Val, Val) where
    format (x, y) = hang (format x <+> text "=>") defaultIndent (format y)

instance Pretty (Exp, SourcePos) where
    format (x, _) = format x 

instance Pretty (TVar VRef) where
    format x = text ('#':show x)

instance Pretty VRef where
    format x = text ('#':show x)

instance Pretty VMatch where
    format m = joinList (text ", ")
        [ form ("ok",        matchOk)
        , form ("from",      matchFrom)
        , form ("to",        matchTo)
        , form ("str",       matchStr)
        , form ("sub_pos",   matchSubPos)
        , form ("sub_named", matchSubNamed)
        ]
        where
        form :: Pretty a => (String, VMatch -> a) -> Doc
        form (s, f) = hang (text s <+> text "=>") defaultIndent (format $ f m)

instance Pretty Bool where
    format x = text $ if x then "Bool::True" else "Bool::False"

instance Pretty Int where
    format i = int i

instance Pretty VList where
    format [x] = parens $ format x <> text ","
    format xs
        | not . null . (drop 100) $ xs = parens $ (format (head xs) <+> text ", ...")
        | otherwise = parens $ (joinList $ text ", ") (map format xs)

instance Pretty Params where
    format = text . show . paramsToSig

instance Pretty VHash where
    format x = cat
        [ text "{"
        , nest defaultIndent . joinList (text ", ") $
            [ format (VStr k, v) | (k, v) <- Map.toList x ]
        , text "}"
        ]

instance Pretty LexPads where
    format xs = hsep (punctuate comma (map format xs))

instance Pretty LexPad where
    format (PRuntime p) = format p
    format (PCompiling p) = format p

instance Pretty MPad where
    format = text . show

instance Pretty Val where
    format (VJunc j) = parens $ joinList mark items 
        where
        dups = juncDup j
        vals = juncSet j
        items = map format $ values
        values = Set.elems vals ++ (concatMap (replicate 2)) (Set.elems dups)
        mark  = case juncType j of
            JAny  -> text " | "
            JAll  -> text " & "
            JOne  -> text " ^ "
            JNone -> text " ! "
    format (VBool x) = format x
    format (VNum x) = if x == 1/0
                         then text "Inf"
                         else if x == -1/0 
                                then text "-Inf"
                                else text $ show x
    format (VInt x) = integer x
    format (VStr x) = text $ "\"" ++ encodeUTF8 (concatMap quoted x) ++ "\""
    format (VRat x) = text $ showTrueRat x
    format (VComplex (r :+ i)) = format (VNum r) <+> text "+" <+> format (VNum i) <> text "i"
    format (VControl ControlContinuation{}) = text "<continuation>"
    format (VControl x) = text $ show x
    format (VProcess x) = text $ show x
    format (VOpaque (MkOpaque x)) = braces $ text $ "obj:" ++ show x
{-
    format (VRef (VList x))
        | not . null . (drop 100) $ x
        = brackets $ format (head x) <+> text ", ..."
        | otherwise = brackets $ cat $ (punctuate $ text ", ") (map format x)
-}
    format (VRef x) = format x
    format (VList x) = format x
    format (VCode x) = (<> braces (format $ subBody x)) .
        (<+> braces (format (subOuterPads x))) .
        (<+> format (subInnerPad x)) . (<> format (subParams x)) . text $ case subType x of
        SubMacro        -> "macro "
        SubRoutine      -> "sub "
        SubMethod       -> "method "
        SubCoroutine    -> "coro "
        SubPointy       -> "->"
        SubBlock        -> ""
        SubPrim         -> ""
    format (VBlock _) = text "{...}"
    format (VError x posList)
        -- Is this correct? Does this work on win32, too?
        | last s == '\n' = text . init $ s
        | otherwise      = text "***" <+>
            (vcat (map text $ split "\n" s) $+$ (text "at" <+> vcat (map format $ reverse posList)))
        where
        s = case x of
              VStr s' -> s'
              _       -> pretty x
--  format (VArray x) = format (VList $ Array.elems x)
--  format (VHash h) = braces $ (joinList $ text ", ") $
--      [ format (VStr k, v) | (k, v) <- Map.toList h ]
    format (VHandle x) = text $ show x
    format (VThread t) = text $ takeWhile isDigit $ dropWhile (not . isDigit) $ show t
    format (VSocket x) = text $ show x
    -- format (MVal v) = text $ inlinePerformSTM $ do
    --     val <- readTVar v
    --     return $ pretty val
    format (VRule _) = text $ "{regex}"
    format (VSubst _) = text $ "{subst}"
    format (VType t) = text $ "::" ++ showType t
    format (VObject o) = text $ "{obj:" ++ showType (objType o) ++ "}"
    format (VMatch m) = cat
        [ text "Match.new("
        , nest defaultIndent $ format m
        , text ")"
        ]
    format (PerlSV _) = text $ "{obj-perl5}"
    format VUndef = text $ "undef"
    format (VV x) = format x -- === formatVal x
    formatQuite (VV x) = text . cast $ Val.valShow x
    formatQuite x = format x

instance Pretty Val.Val where
    format = formatVal

quoted :: Char -> String
quoted '\'' = "\\'"
quoted '\\' = "\\\\"
quoted '"'  = "\\\""
quoted '{'  = "\\{"
quoted '\t' = "\\t"
quoted '\r' = "\\r"
quoted '\n' = "\\n"
quoted '$'  = "\\$"
quoted '@'  = "\\@"
quoted '%'  = "\\%"
quoted '&'  = "\\&"
quoted '^'  = "\\^"
quoted x | isPrint x = [x]
quoted x    = "\\x[" ++ showHex (ord x) "]"

doubleBraces :: Doc -> Doc
doubleBraces x = vcat [ (lbrace <> lbrace), nest defaultIndent x, rbrace <> rbrace]

joinList :: Doc -> [Doc] -> Doc
joinList x y = cat $ punctuate x y

pretty, priggy :: Pretty a => a -> String
pretty a = render $ format a
priggy a = render $ formatQuite a
