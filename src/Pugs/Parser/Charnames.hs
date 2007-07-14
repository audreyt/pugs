{-# OPTIONS_GHC -fglasgow-exts -fno-full-laziness -fno-cse -cpp -fvia-C -fallow-overlapping-instances #-}

module Pugs.Parser.Charnames (nameToCode) where

import Pugs.Internals

#ifdef PUGS_HAVE_PERL5

import Pugs.Embed.Perl5

-- If we do have Perl 5, support for all unicode names via Perl5's charnames::vianame.

nameToCode :: String -> Maybe Int
nameToCode name = inlinePerformIO $ do
    sv      <- evalPerl5 ("use utf8; use charnames ':full'; ord(qq[\\N{"++name++"}])") nullEnv 1
    svToVInt sv >>= \iv -> case iv of
        0 -> svToVStr sv >>= \pv -> case pv of
            "0" -> return (Just 0)
            _   -> return Nothing   -- undef
        x -> return (Just x)

#else

import qualified Data.HashTable as H
import UTF8 (unsafePackAddress, hash)

-- If we don't have Perl 5, support for names in the 0x00 - 0xFF range only.

nameToCode :: String -> Maybe Int
nameToCode name = inlinePerformIO (H.lookup _NameToCode (cast name))

{-# NOINLINE _NameToCode #-}
_NameToCode :: H.HashTable ByteString Int
_NameToCode = unsafePerformIO $! hashList
    [ (unsafePackAddress 4 "NULL"#, 0x0000)
    , (unsafePackAddress 16 "START OF HEADING"#, 0x0001)
    , (unsafePackAddress 13 "START OF TEXT"#, 0x0002)
    , (unsafePackAddress 11 "END OF TEXT"#, 0x0003)
    , (unsafePackAddress 19 "END OF TRANSMISSION"#, 0x0004)
    , (unsafePackAddress 7 "ENQUIRY"#, 0x0005)
    , (unsafePackAddress 11 "ACKNOWLEDGE"#, 0x0006)
    , (unsafePackAddress 4 "BELL"#, 0x0007)
    , (unsafePackAddress 9 "BACKSPACE"#, 0x0008)
    , (unsafePackAddress 20 "CHARACTER TABULATION"#, 0x0009)
    , (unsafePackAddress 14 "LINE FEED (LF)"#, 0x000A)
    , (unsafePackAddress 9 "LINE FEED"#, 0x000A)
    , (unsafePackAddress 15 "LINE TABULATION"#, 0x000B)
    , (unsafePackAddress 14 "FORM FEED (FF)"#, 0x000C)
    , (unsafePackAddress 9 "FORM FEED"#, 0x000C)
    , (unsafePackAddress 20 "CARRIAGE RETURN (CR)"#, 0x000D)
    , (unsafePackAddress 15 "CARRIAGE RETURN"#, 0x000D)
    , (unsafePackAddress 9 "SHIFT OUT"#, 0x000E)
    , (unsafePackAddress 8 "SHIFT IN"#, 0x000F)
    , (unsafePackAddress 16 "DATA LINK ESCAPE"#, 0x0010)
    , (unsafePackAddress 18 "DEVICE CONTROL ONE"#, 0x0011)
    , (unsafePackAddress 18 "DEVICE CONTROL TWO"#, 0x0012)
    , (unsafePackAddress 20 "DEVICE CONTROL THREE"#, 0x0013)
    , (unsafePackAddress 19 "DEVICE CONTROL FOUR"#, 0x0014)
    , (unsafePackAddress 20 "NEGATIVE ACKNOWLEDGE"#, 0x0015)
    , (unsafePackAddress 16 "SYNCHRONOUS IDLE"#, 0x0016)
    , (unsafePackAddress 25 "END OF TRANSMISSION BLOCK"#, 0x0017)
    , (unsafePackAddress 6 "CANCEL"#, 0x0018)
    , (unsafePackAddress 13 "END OF MEDIUM"#, 0x0019)
    , (unsafePackAddress 10 "SUBSTITUTE"#, 0x001A)
    , (unsafePackAddress 6 "ESCAPE"#, 0x001B)
    , (unsafePackAddress 26 "INFORMATION SEPARATOR FOUR"#, 0x001C)
    , (unsafePackAddress 27 "INFORMATION SEPARATOR THREE"#, 0x001D)
    , (unsafePackAddress 25 "INFORMATION SEPARATOR TWO"#, 0x001E)
    , (unsafePackAddress 25 "INFORMATION SEPARATOR ONE"#, 0x001F)
    , (unsafePackAddress 5 "SPACE"#, 0x0020)
    , (unsafePackAddress 16 "EXCLAMATION MARK"#, 0x0021)
    , (unsafePackAddress 14 "QUOTATION MARK"#, 0x0022)
    , (unsafePackAddress 11 "NUMBER SIGN"#, 0x0023)
    , (unsafePackAddress 11 "DOLLAR SIGN"#, 0x0024)
    , (unsafePackAddress 12 "PERCENT SIGN"#, 0x0025)
    , (unsafePackAddress 9 "AMPERSAND"#, 0x0026)
    , (unsafePackAddress 10 "APOSTROPHE"#, 0x0027)
    , (unsafePackAddress 16 "LEFT PARENTHESIS"#, 0x0028)
    , (unsafePackAddress 17 "RIGHT PARENTHESIS"#, 0x0029)
    , (unsafePackAddress 8 "ASTERISK"#, 0x002A)
    , (unsafePackAddress 9 "PLUS SIGN"#, 0x002B)
    , (unsafePackAddress 5 "COMMA"#, 0x002C)
    , (unsafePackAddress 12 "HYPHEN-MINUS"#, 0x002D)
    , (unsafePackAddress 9 "FULL STOP"#, 0x002E)
    , (unsafePackAddress 7 "SOLIDUS"#, 0x002F)
    , (unsafePackAddress 10 "DIGIT ZERO"#, 0x0030)
    , (unsafePackAddress 9 "DIGIT ONE"#, 0x0031)
    , (unsafePackAddress 9 "DIGIT TWO"#, 0x0032)
    , (unsafePackAddress 11 "DIGIT THREE"#, 0x0033)
    , (unsafePackAddress 10 "DIGIT FOUR"#, 0x0034)
    , (unsafePackAddress 10 "DIGIT FIVE"#, 0x0035)
    , (unsafePackAddress 9 "DIGIT SIX"#, 0x0036)
    , (unsafePackAddress 11 "DIGIT SEVEN"#, 0x0037)
    , (unsafePackAddress 11 "DIGIT EIGHT"#, 0x0038)
    , (unsafePackAddress 10 "DIGIT NINE"#, 0x0039)
    , (unsafePackAddress 5 "COLON"#, 0x003A)
    , (unsafePackAddress 9 "SEMICOLON"#, 0x003B)
    , (unsafePackAddress 14 "LESS-THAN SIGN"#, 0x003C)
    , (unsafePackAddress 11 "EQUALS SIGN"#, 0x003D)
    , (unsafePackAddress 17 "GREATER-THAN SIGN"#, 0x003E)
    , (unsafePackAddress 13 "QUESTION MARK"#, 0x003F)
    , (unsafePackAddress 13 "COMMERCIAL AT"#, 0x0040)
    , (unsafePackAddress 22 "LATIN CAPITAL LETTER A"#, 0x0041)
    , (unsafePackAddress 22 "LATIN CAPITAL LETTER B"#, 0x0042)
    , (unsafePackAddress 22 "LATIN CAPITAL LETTER C"#, 0x0043)
    , (unsafePackAddress 22 "LATIN CAPITAL LETTER D"#, 0x0044)
    , (unsafePackAddress 22 "LATIN CAPITAL LETTER E"#, 0x0045)
    , (unsafePackAddress 22 "LATIN CAPITAL LETTER F"#, 0x0046)
    , (unsafePackAddress 22 "LATIN CAPITAL LETTER G"#, 0x0047)
    , (unsafePackAddress 22 "LATIN CAPITAL LETTER H"#, 0x0048)
    , (unsafePackAddress 22 "LATIN CAPITAL LETTER I"#, 0x0049)
    , (unsafePackAddress 22 "LATIN CAPITAL LETTER J"#, 0x004A)
    , (unsafePackAddress 22 "LATIN CAPITAL LETTER K"#, 0x004B)
    , (unsafePackAddress 22 "LATIN CAPITAL LETTER L"#, 0x004C)
    , (unsafePackAddress 22 "LATIN CAPITAL LETTER M"#, 0x004D)
    , (unsafePackAddress 22 "LATIN CAPITAL LETTER N"#, 0x004E)
    , (unsafePackAddress 22 "LATIN CAPITAL LETTER O"#, 0x004F)
    , (unsafePackAddress 22 "LATIN CAPITAL LETTER P"#, 0x0050)
    , (unsafePackAddress 22 "LATIN CAPITAL LETTER Q"#, 0x0051)
    , (unsafePackAddress 22 "LATIN CAPITAL LETTER R"#, 0x0052)
    , (unsafePackAddress 22 "LATIN CAPITAL LETTER S"#, 0x0053)
    , (unsafePackAddress 22 "LATIN CAPITAL LETTER T"#, 0x0054)
    , (unsafePackAddress 22 "LATIN CAPITAL LETTER U"#, 0x0055)
    , (unsafePackAddress 22 "LATIN CAPITAL LETTER V"#, 0x0056)
    , (unsafePackAddress 22 "LATIN CAPITAL LETTER W"#, 0x0057)
    , (unsafePackAddress 22 "LATIN CAPITAL LETTER X"#, 0x0058)
    , (unsafePackAddress 22 "LATIN CAPITAL LETTER Y"#, 0x0059)
    , (unsafePackAddress 22 "LATIN CAPITAL LETTER Z"#, 0x005A)
    , (unsafePackAddress 19 "LEFT SQUARE BRACKET"#, 0x005B)
    , (unsafePackAddress 15 "REVERSE SOLIDUS"#, 0x005C)
    , (unsafePackAddress 20 "RIGHT SQUARE BRACKET"#, 0x005D)
    , (unsafePackAddress 17 "CIRCUMFLEX ACCENT"#, 0x005E)
    , (unsafePackAddress 8 "LOW LINE"#, 0x005F)
    , (unsafePackAddress 12 "GRAVE ACCENT"#, 0x0060)
    , (unsafePackAddress 20 "LATIN SMALL LETTER A"#, 0x0061)
    , (unsafePackAddress 20 "LATIN SMALL LETTER B"#, 0x0062)
    , (unsafePackAddress 20 "LATIN SMALL LETTER C"#, 0x0063)
    , (unsafePackAddress 20 "LATIN SMALL LETTER D"#, 0x0064)
    , (unsafePackAddress 20 "LATIN SMALL LETTER E"#, 0x0065)
    , (unsafePackAddress 20 "LATIN SMALL LETTER F"#, 0x0066)
    , (unsafePackAddress 20 "LATIN SMALL LETTER G"#, 0x0067)
    , (unsafePackAddress 20 "LATIN SMALL LETTER H"#, 0x0068)
    , (unsafePackAddress 20 "LATIN SMALL LETTER I"#, 0x0069)
    , (unsafePackAddress 20 "LATIN SMALL LETTER J"#, 0x006A)
    , (unsafePackAddress 20 "LATIN SMALL LETTER K"#, 0x006B)
    , (unsafePackAddress 20 "LATIN SMALL LETTER L"#, 0x006C)
    , (unsafePackAddress 20 "LATIN SMALL LETTER M"#, 0x006D)
    , (unsafePackAddress 20 "LATIN SMALL LETTER N"#, 0x006E)
    , (unsafePackAddress 20 "LATIN SMALL LETTER O"#, 0x006F)
    , (unsafePackAddress 20 "LATIN SMALL LETTER P"#, 0x0070)
    , (unsafePackAddress 20 "LATIN SMALL LETTER Q"#, 0x0071)
    , (unsafePackAddress 20 "LATIN SMALL LETTER R"#, 0x0072)
    , (unsafePackAddress 20 "LATIN SMALL LETTER S"#, 0x0073)
    , (unsafePackAddress 20 "LATIN SMALL LETTER T"#, 0x0074)
    , (unsafePackAddress 20 "LATIN SMALL LETTER U"#, 0x0075)
    , (unsafePackAddress 20 "LATIN SMALL LETTER V"#, 0x0076)
    , (unsafePackAddress 20 "LATIN SMALL LETTER W"#, 0x0077)
    , (unsafePackAddress 20 "LATIN SMALL LETTER X"#, 0x0078)
    , (unsafePackAddress 20 "LATIN SMALL LETTER Y"#, 0x0079)
    , (unsafePackAddress 20 "LATIN SMALL LETTER Z"#, 0x007A)
    , (unsafePackAddress 18 "LEFT CURLY BRACKET"#, 0x007B)
    , (unsafePackAddress 13 "VERTICAL LINE"#, 0x007C)
    , (unsafePackAddress 19 "RIGHT CURLY BRACKET"#, 0x007D)
    , (unsafePackAddress 5 "TILDE"#, 0x007E)
    , (unsafePackAddress 6 "DELETE"#, 0x007F)
    , (unsafePackAddress 20 "BREAK PERMITTED HERE"#, 0x0082)
    , (unsafePackAddress 13 "NO BREAK HERE"#, 0x0083)
    , (unsafePackAddress 15 "NEXT LINE (NEL)"#, 0x0085)
    , (unsafePackAddress 9 "NEXT LINE"#, 0x0085)
    , (unsafePackAddress 22 "START OF SELECTED AREA"#, 0x0086)
    , (unsafePackAddress 20 "END OF SELECTED AREA"#, 0x0087)
    , (unsafePackAddress 24 "CHARACTER TABULATION SET"#, 0x0088)
    , (unsafePackAddress 39 "CHARACTER TABULATION WITH JUSTIFICATION"#, 0x0089)
    , (unsafePackAddress 19 "LINE TABULATION SET"#, 0x008A)
    , (unsafePackAddress 20 "PARTIAL LINE FORWARD"#, 0x008B)
    , (unsafePackAddress 21 "PARTIAL LINE BACKWARD"#, 0x008C)
    , (unsafePackAddress 17 "REVERSE LINE FEED"#, 0x008D)
    , (unsafePackAddress 16 "SINGLE SHIFT TWO"#, 0x008E)
    , (unsafePackAddress 18 "SINGLE SHIFT THREE"#, 0x008F)
    , (unsafePackAddress 21 "DEVICE CONTROL STRING"#, 0x0090)
    , (unsafePackAddress 15 "PRIVATE USE ONE"#, 0x0091)
    , (unsafePackAddress 15 "PRIVATE USE TWO"#, 0x0092)
    , (unsafePackAddress 18 "SET TRANSMIT STATE"#, 0x0093)
    , (unsafePackAddress 16 "CANCEL CHARACTER"#, 0x0094)
    , (unsafePackAddress 15 "MESSAGE WAITING"#, 0x0095)
    , (unsafePackAddress 21 "START OF GUARDED AREA"#, 0x0096)
    , (unsafePackAddress 19 "END OF GUARDED AREA"#, 0x0097)
    , (unsafePackAddress 15 "START OF STRING"#, 0x0098)
    , (unsafePackAddress 27 "SINGLE CHARACTER INTRODUCER"#, 0x009A)
    , (unsafePackAddress 27 "CONTROL SEQUENCE INTRODUCER"#, 0x009B)
    , (unsafePackAddress 17 "STRING TERMINATOR"#, 0x009C)
    , (unsafePackAddress 24 "OPERATING SYSTEM COMMAND"#, 0x009D)
    , (unsafePackAddress 15 "PRIVACY MESSAGE"#, 0x009E)
    , (unsafePackAddress 27 "APPLICATION PROGRAM COMMAND"#, 0x009F)
    , (unsafePackAddress 14 "NO-BREAK SPACE"#, 0x00A0)
    , (unsafePackAddress 25 "INVERTED EXCLAMATION MARK"#, 0x00A1)
    , (unsafePackAddress 9 "CENT SIGN"#, 0x00A2)
    , (unsafePackAddress 10 "POUND SIGN"#, 0x00A3)
    , (unsafePackAddress 13 "CURRENCY SIGN"#, 0x00A4)
    , (unsafePackAddress 8 "YEN SIGN"#, 0x00A5)
    , (unsafePackAddress 10 "BROKEN BAR"#, 0x00A6)
    , (unsafePackAddress 12 "SECTION SIGN"#, 0x00A7)
    , (unsafePackAddress 9 "DIAERESIS"#, 0x00A8)
    , (unsafePackAddress 14 "COPYRIGHT SIGN"#, 0x00A9)
    , (unsafePackAddress 26 "FEMININE ORDINAL INDICATOR"#, 0x00AA)
    , (unsafePackAddress 41 "LEFT-POINTING DOUBLE ANGLE QUOTATION MARK"#, 0x00AB)
    , (unsafePackAddress 8 "NOT SIGN"#, 0x00AC)
    , (unsafePackAddress 11 "SOFT HYPHEN"#, 0x00AD)
    , (unsafePackAddress 15 "REGISTERED SIGN"#, 0x00AE)
    , (unsafePackAddress 6 "MACRON"#, 0x00AF)
    , (unsafePackAddress 11 "DEGREE SIGN"#, 0x00B0)
    , (unsafePackAddress 15 "PLUS-MINUS SIGN"#, 0x00B1)
    , (unsafePackAddress 15 "SUPERSCRIPT TWO"#, 0x00B2)
    , (unsafePackAddress 17 "SUPERSCRIPT THREE"#, 0x00B3)
    , (unsafePackAddress 12 "ACUTE ACCENT"#, 0x00B4)
    , (unsafePackAddress 10 "MICRO SIGN"#, 0x00B5)
    , (unsafePackAddress 12 "PILCROW SIGN"#, 0x00B6)
    , (unsafePackAddress 10 "MIDDLE DOT"#, 0x00B7)
    , (unsafePackAddress 7 "CEDILLA"#, 0x00B8)
    , (unsafePackAddress 15 "SUPERSCRIPT ONE"#, 0x00B9)
    , (unsafePackAddress 27 "MASCULINE ORDINAL INDICATOR"#, 0x00BA)
    , (unsafePackAddress 42 "RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK"#, 0x00BB)
    , (unsafePackAddress 27 "VULGAR FRACTION ONE QUARTER"#, 0x00BC)
    , (unsafePackAddress 24 "VULGAR FRACTION ONE HALF"#, 0x00BD)
    , (unsafePackAddress 30 "VULGAR FRACTION THREE QUARTERS"#, 0x00BE)
    , (unsafePackAddress 22 "INVERTED QUESTION MARK"#, 0x00BF)
    , (unsafePackAddress 33 "LATIN CAPITAL LETTER A WITH GRAVE"#, 0x00C0)
    , (unsafePackAddress 33 "LATIN CAPITAL LETTER A WITH ACUTE"#, 0x00C1)
    , (unsafePackAddress 38 "LATIN CAPITAL LETTER A WITH CIRCUMFLEX"#, 0x00C2)
    , (unsafePackAddress 33 "LATIN CAPITAL LETTER A WITH TILDE"#, 0x00C3)
    , (unsafePackAddress 37 "LATIN CAPITAL LETTER A WITH DIAERESIS"#, 0x00C4)
    , (unsafePackAddress 38 "LATIN CAPITAL LETTER A WITH RING ABOVE"#, 0x00C5)
    , (unsafePackAddress 23 "LATIN CAPITAL LETTER AE"#, 0x00C6)
    , (unsafePackAddress 35 "LATIN CAPITAL LETTER C WITH CEDILLA"#, 0x00C7)
    , (unsafePackAddress 33 "LATIN CAPITAL LETTER E WITH GRAVE"#, 0x00C8)
    , (unsafePackAddress 33 "LATIN CAPITAL LETTER E WITH ACUTE"#, 0x00C9)
    , (unsafePackAddress 38 "LATIN CAPITAL LETTER E WITH CIRCUMFLEX"#, 0x00CA)
    , (unsafePackAddress 37 "LATIN CAPITAL LETTER E WITH DIAERESIS"#, 0x00CB)
    , (unsafePackAddress 33 "LATIN CAPITAL LETTER I WITH GRAVE"#, 0x00CC)
    , (unsafePackAddress 33 "LATIN CAPITAL LETTER I WITH ACUTE"#, 0x00CD)
    , (unsafePackAddress 38 "LATIN CAPITAL LETTER I WITH CIRCUMFLEX"#, 0x00CE)
    , (unsafePackAddress 37 "LATIN CAPITAL LETTER I WITH DIAERESIS"#, 0x00CF)
    , (unsafePackAddress 24 "LATIN CAPITAL LETTER ETH"#, 0x00D0)
    , (unsafePackAddress 33 "LATIN CAPITAL LETTER N WITH TILDE"#, 0x00D1)
    , (unsafePackAddress 33 "LATIN CAPITAL LETTER O WITH GRAVE"#, 0x00D2)
    , (unsafePackAddress 33 "LATIN CAPITAL LETTER O WITH ACUTE"#, 0x00D3)
    , (unsafePackAddress 38 "LATIN CAPITAL LETTER O WITH CIRCUMFLEX"#, 0x00D4)
    , (unsafePackAddress 33 "LATIN CAPITAL LETTER O WITH TILDE"#, 0x00D5)
    , (unsafePackAddress 37 "LATIN CAPITAL LETTER O WITH DIAERESIS"#, 0x00D6)
    , (unsafePackAddress 19 "MULTIPLICATION SIGN"#, 0x00D7)
    , (unsafePackAddress 34 "LATIN CAPITAL LETTER O WITH STROKE"#, 0x00D8)
    , (unsafePackAddress 33 "LATIN CAPITAL LETTER U WITH GRAVE"#, 0x00D9)
    , (unsafePackAddress 33 "LATIN CAPITAL LETTER U WITH ACUTE"#, 0x00DA)
    , (unsafePackAddress 38 "LATIN CAPITAL LETTER U WITH CIRCUMFLEX"#, 0x00DB)
    , (unsafePackAddress 37 "LATIN CAPITAL LETTER U WITH DIAERESIS"#, 0x00DC)
    , (unsafePackAddress 33 "LATIN CAPITAL LETTER Y WITH ACUTE"#, 0x00DD)
    , (unsafePackAddress 26 "LATIN CAPITAL LETTER THORN"#, 0x00DE)
    , (unsafePackAddress 26 "LATIN SMALL LETTER SHARP S"#, 0x00DF)
    , (unsafePackAddress 31 "LATIN SMALL LETTER A WITH GRAVE"#, 0x00E0)
    , (unsafePackAddress 31 "LATIN SMALL LETTER A WITH ACUTE"#, 0x00E1)
    , (unsafePackAddress 36 "LATIN SMALL LETTER A WITH CIRCUMFLEX"#, 0x00E2)
    , (unsafePackAddress 31 "LATIN SMALL LETTER A WITH TILDE"#, 0x00E3)
    , (unsafePackAddress 35 "LATIN SMALL LETTER A WITH DIAERESIS"#, 0x00E4)
    , (unsafePackAddress 36 "LATIN SMALL LETTER A WITH RING ABOVE"#, 0x00E5)
    , (unsafePackAddress 21 "LATIN SMALL LETTER AE"#, 0x00E6)
    , (unsafePackAddress 33 "LATIN SMALL LETTER C WITH CEDILLA"#, 0x00E7)
    , (unsafePackAddress 31 "LATIN SMALL LETTER E WITH GRAVE"#, 0x00E8)
    , (unsafePackAddress 31 "LATIN SMALL LETTER E WITH ACUTE"#, 0x00E9)
    , (unsafePackAddress 36 "LATIN SMALL LETTER E WITH CIRCUMFLEX"#, 0x00EA)
    , (unsafePackAddress 35 "LATIN SMALL LETTER E WITH DIAERESIS"#, 0x00EB)
    , (unsafePackAddress 31 "LATIN SMALL LETTER I WITH GRAVE"#, 0x00EC)
    , (unsafePackAddress 31 "LATIN SMALL LETTER I WITH ACUTE"#, 0x00ED)
    , (unsafePackAddress 36 "LATIN SMALL LETTER I WITH CIRCUMFLEX"#, 0x00EE)
    , (unsafePackAddress 35 "LATIN SMALL LETTER I WITH DIAERESIS"#, 0x00EF)
    , (unsafePackAddress 22 "LATIN SMALL LETTER ETH"#, 0x00F0)
    , (unsafePackAddress 31 "LATIN SMALL LETTER N WITH TILDE"#, 0x00F1)
    , (unsafePackAddress 31 "LATIN SMALL LETTER O WITH GRAVE"#, 0x00F2)
    , (unsafePackAddress 31 "LATIN SMALL LETTER O WITH ACUTE"#, 0x00F3)
    , (unsafePackAddress 36 "LATIN SMALL LETTER O WITH CIRCUMFLEX"#, 0x00F4)
    , (unsafePackAddress 31 "LATIN SMALL LETTER O WITH TILDE"#, 0x00F5)
    , (unsafePackAddress 35 "LATIN SMALL LETTER O WITH DIAERESIS"#, 0x00F6)
    , (unsafePackAddress 13 "DIVISION SIGN"#, 0x00F7)
    , (unsafePackAddress 32 "LATIN SMALL LETTER O WITH STROKE"#, 0x00F8)
    , (unsafePackAddress 31 "LATIN SMALL LETTER U WITH GRAVE"#, 0x00F9)
    , (unsafePackAddress 31 "LATIN SMALL LETTER U WITH ACUTE"#, 0x00FA)
    , (unsafePackAddress 36 "LATIN SMALL LETTER U WITH CIRCUMFLEX"#, 0x00FB)
    , (unsafePackAddress 35 "LATIN SMALL LETTER U WITH DIAERESIS"#, 0x00FC)
    , (unsafePackAddress 31 "LATIN SMALL LETTER Y WITH ACUTE"#, 0x00FD)
    , (unsafePackAddress 24 "LATIN SMALL LETTER THORN"#, 0x00FE)
    , (unsafePackAddress 35 "LATIN SMALL LETTER Y WITH DIAERESIS"#, 0x00FF)
    ]
    where
    hashList :: [(ByteString, a)] -> IO (H.HashTable ByteString a)
    hashList = H.fromList hash

#endif
