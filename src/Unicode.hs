{-# OPTIONS -fglasgow-exts -fvia-C -fno-implicit-prelude -O #-}
{-# OPTIONS -#include "UnicodeC.h" #-}
{-# OPTIONS -#include "UnicodeC.c" #-}

{-
    Unicode internals.

    Sí na veth bâden im derel
    Vi dúath dofn tummen.
    Atham meraid velig a tynd
    Athan eryd bain beraidh.
    Or 'waith bain nura Anor
    A panlû elin cuinar
    Ú-pedithon 'i-aur gwann'
    Egor nai îl 'namarië'.
-}

-- Based on the GHC.Unicode library, Copyright 2005, Dimitry Golubovsky.
-- See GHC's LICENSE file for the full license text.

module Unicode (
    GeneralCategory (..),
    generalCategory,
    isAscii, isLatin1, isControl,
    isAsciiUpper, isAsciiLower,
    isPrint, isSpace,  isUpper,
    isLower, isAlpha,  isDigit,
    isOctDigit, isHexDigit, isAlphaNum,
    toUpper, toLower, toTitle,
    isLetter,               -- :: Char -> Bool
    isMark,                 -- :: Char -> Bool
    isNumber,               -- :: Char -> Bool
    isPunctuation,          -- :: Char -> Bool
    isSymbol,               -- :: Char -> Bool
    isSeparator,            -- :: Char -> Bool
  ) where

import GHC.Base
import GHC.Real  (fromIntegral)
import GHC.Num	 (fromInteger)
import GHC.Read
import GHC.Show
import GHC.Enum
import Foreign.C.Types (CInt)

-- | Unicode General Categories (column 2 of the UnicodeData table)
-- in the order they are listed in the Unicode standard.

data GeneralCategory
        = UppercaseLetter       -- Lu  Letter, Uppercase
        | LowercaseLetter       -- Ll  Letter, Lowercase
        | TitlecaseLetter       -- Lt  Letter, Titlecase
        | ModifierLetter        -- Lm  Letter, Modifier
        | OtherLetter           -- Lo  Letter, Other
        | NonSpacingMark        -- Mn  Mark, Non-Spacing
        | SpacingCombiningMark  -- Mc  Mark, Spacing Combining
        | EnclosingMark         -- Me  Mark, Enclosing
        | DecimalNumber         -- Nd  Number, Decimal
        | LetterNumber          -- Nl  Number, Letter
        | OtherNumber           -- No  Number, Other
        | ConnectorPunctuation  -- Pc  Punctuation, Connector
        | DashPunctuation       -- Pd  Punctuation, Dash
        | OpenPunctuation       -- Ps  Punctuation, Open
        | ClosePunctuation      -- Pe  Punctuation, Close
        | InitialQuote          -- Pi  Punctuation, Initial quote
        | FinalQuote            -- Pf  Punctuation, Final quote
        | OtherPunctuation      -- Po  Punctuation, Other
        | MathSymbol            -- Sm  Symbol, Math
        | CurrencySymbol        -- Sc  Symbol, Currency
        | ModifierSymbol        -- Sk  Symbol, Modifier
        | OtherSymbol           -- So  Symbol, Other
        | Space                 -- Zs  Separator, Space
        | LineSeparator         -- Zl  Separator, Line
        | ParagraphSeparator    -- Zp  Separator, Paragraph
        | Control               -- Cc  Other, Control
        | Format                -- Cf  Other, Format
        | Surrogate             -- Cs  Other, Surrogate
        | PrivateUse            -- Co  Other, Private Use
        | NotAssigned           -- Cn  Other, Not Assigned
        deriving (Eq, Ord, Enum, Read, Show, Bounded)

-- | Retrieves the general Unicode category of the character.
generalCategory :: Char -> GeneralCategory
generalCategory c = toEnum (wgencat (fromIntegral (ord c)))

-- ------------------------------------------------------------------------
-- These are copied from Hugs Unicode.hs

-- derived character classifiers

isLetter :: Char -> Bool
isLetter c = case generalCategory c of
        UppercaseLetter         -> True
        LowercaseLetter         -> True
        TitlecaseLetter         -> True
        ModifierLetter          -> True
        OtherLetter             -> True
        _                       -> False

isMark :: Char -> Bool
isMark c = case generalCategory c of
        NonSpacingMark          -> True
        SpacingCombiningMark    -> True
        EnclosingMark           -> True
        _                       -> False

isNumber :: Char -> Bool
isNumber c = case generalCategory c of
        DecimalNumber           -> True
        LetterNumber            -> True
        OtherNumber             -> True
        _                       -> False

isPunctuation :: Char -> Bool
isPunctuation c = case generalCategory c of
        ConnectorPunctuation    -> True
        DashPunctuation         -> True
        OpenPunctuation         -> True
        ClosePunctuation        -> True
        InitialQuote            -> True
        FinalQuote              -> True
        OtherPunctuation        -> True
        _                       -> False

isSymbol :: Char -> Bool
isSymbol c = case generalCategory c of
        MathSymbol              -> True
        CurrencySymbol          -> True
        ModifierSymbol          -> True
        OtherSymbol             -> True
        _                       -> False

isSeparator :: Char -> Bool
isSeparator c = case generalCategory c of
        Space                   -> True
        LineSeparator           -> True
        ParagraphSeparator      -> True
        _                       -> False

-- | Selects the first 128 characters of the Unicode character set,
-- corresponding to the ASCII character set.
isAscii                 :: Char -> Bool
isAscii c	 	=  c <  '\x80'

-- | Selects the first 256 characters of the Unicode character set,
-- corresponding to the ISO 8859-1 (Latin-1) character set.
isLatin1                :: Char -> Bool
isLatin1 c              =  c <= '\xff'

isAsciiUpper, isAsciiLower :: Char -> Bool
isAsciiLower c          =  c >= 'a' && c <= 'z'
isAsciiUpper c          =  c >= 'A' && c <= 'Z'

-- | Selects control characters, which are the non-printing characters of
-- the Latin-1 subset of Unicode.
isControl               :: Char -> Bool

-- | Selects printable Unicode characters
-- (letters, numbers, marks, punctuation, symbols and spaces).
isPrint                 :: Char -> Bool

-- | Selects white-space characters in the Latin-1 range.
-- (In Unicode terms, this includes spaces and some control characters.)
isSpace                 :: Char -> Bool
-- isSpace includes non-breaking space
-- Done with explicit equalities both for efficiency, and to avoid a tiresome
-- recursion with GHC.List elem
isSpace c		=  c == ' '	||
			   c == '\t'	||
			   c == '\n'	||
			   c == '\r'	||
			   c == '\f'	||
			   c == '\v'	||
			   c == '\xa0'  ||
			   iswspace (fromIntegral (ord c)) /= 0

-- | Selects alphabetic Unicode characters (letters) that are not lower-case.
-- (In Unicode terms, this includes letters in upper and title cases,
-- as well as modifier letters and other letters.)
isUpper                 :: Char -> Bool

-- | Selects lower-case alphabetic Unicode characters (letters).
isLower                 :: Char -> Bool

-- | Selects alphabetic Unicode characters (letters).
isAlpha                 :: Char -> Bool

-- | Selects alphabetic or numeric digit Unicode characters.
--
-- Note that numeric digits outside the ASCII range are selected by this
-- function but not by 'isDigit'.  Such digits may be part of identifiers
-- but are not used by the printer and reader to represent numbers.
isAlphaNum              :: Char -> Bool

-- | Selects ASCII digits, i.e. @\'0\'@..@\'9\'@.
isDigit                 :: Char -> Bool

-- | Selects ASCII octal digits, i.e. @\'0\'@..@\'7\'@.
isOctDigit              :: Char -> Bool
isOctDigit c		=  c >= '0' && c <= '7'

-- | Selects ASCII hexadecimal digits,
-- i.e. @\'0\'@..@\'9\'@, @\'a\'@..@\'f\'@, @\'A\'@..@\'F\'@.
isHexDigit              :: Char -> Bool
isHexDigit c		=  isDigit c || c >= 'A' && c <= 'F' ||
                                        c >= 'a' && c <= 'f'

-- | Convert a letter to the corresponding upper-case letter, leaving any
-- other character unchanged.  Any Unicode letter which has an upper-case
-- equivalent is transformed.
toUpper                 :: Char -> Char

-- | Convert a letter to the corresponding lower-case letter, leaving any
-- other character unchanged.  Any Unicode letter which has a lower-case
-- equivalent is transformed.
toLower                 :: Char -> Char

-- -----------------------------------------------------------------------------
-- Implementation with the supplied auto-generated Unicode character properties
-- table (default)

-- Regardless of the O/S and Library, use the functions contained in WCsubst.c

-- type WInt = HTYPE_WINT_T
-- type CInt = HTYPE_INT

isDigit    c = iswdigit (fromIntegral (ord c)) /= 0
isAlpha    c = iswalpha (fromIntegral (ord c)) /= 0
isAlphaNum c = iswalnum (fromIntegral (ord c)) /= 0
--isSpace    c = iswspace (fromIntegral (ord c)) /= 0
isControl  c = iswcntrl (fromIntegral (ord c)) /= 0
isPrint    c = iswprint (fromIntegral (ord c)) /= 0
isUpper    c = iswupper (fromIntegral (ord c)) /= 0
isLower    c = iswlower (fromIntegral (ord c)) /= 0

toLower c = chr (fromIntegral (towlower (fromIntegral (ord c))))
toUpper c = chr (fromIntegral (towupper (fromIntegral (ord c))))
toTitle c = chr (fromIntegral (towtitle (fromIntegral (ord c))))

foreign import ccall unsafe "stg_hack_u_iswdigit"
  iswdigit :: CInt -> CInt

foreign import ccall unsafe "stg_hack_u_iswalpha"
  iswalpha :: CInt -> CInt

foreign import ccall unsafe "stg_hack_u_iswalnum"
  iswalnum :: CInt -> CInt

foreign import ccall unsafe "stg_hack_u_iswcntrl"
  iswcntrl :: CInt -> CInt

foreign import ccall unsafe "stg_hack_u_iswspace"
  iswspace :: CInt -> CInt

foreign import ccall unsafe "stg_hack_u_iswprint"
  iswprint :: CInt -> CInt

foreign import ccall unsafe "stg_hack_u_iswlower"
  iswlower :: CInt -> CInt

foreign import ccall unsafe "stg_hack_u_iswupper"
  iswupper :: CInt -> CInt

foreign import ccall unsafe "stg_hack_u_towlower"
  towlower :: CInt -> CInt

foreign import ccall unsafe "stg_hack_u_towupper"
  towupper :: CInt -> CInt

foreign import ccall unsafe "stg_hack_u_towtitle"
  towtitle :: CInt -> CInt

foreign import ccall unsafe "stg_hack_u_gencat"
  wgencat :: CInt -> Int
