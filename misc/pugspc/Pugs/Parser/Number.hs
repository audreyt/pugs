
module Pugs.Parser.Number (
    parseNatOrRat,
    naturalOrRat,
    signedNaturalOrRat,
) where
import Pugs.Internals
import Pugs.Rule
import Text.ParserCombinators.Parsec.Char

parseNatOrRat :: String -> Either ParseError (Either Integer (Ratio Integer))
parseNatOrRat s = runParser signedNaturalOrRat () "" s

signedNaturalOrRat :: GenParser Char st (Either Integer (Ratio Integer))
signedNaturalOrRat = do
    sig <- sign
    if sig then naturalOrRat else do
        num <- naturalOrRat
        return $ case num of
            Left i  -> Left (-i)
            Right d -> Right (-d)

naturalOrRat :: GenParser Char st (Either Integer (Ratio Integer))
naturalOrRat = (<?> "number") $ do
        try (char '0' >> zeroNumRat)
    <|> decimalRat
    <|> fractRatOnly
    where
    zeroNumRat = do
            n <- hexadecimal <|> decimal <|> octalBad <|> octal <|> binary
            return (Left n)
        <|> decimalRat
        <|> fractRat 0
        <|> return (Left 0)

    decimalRat = do
        n <- decimalLiteral
        option (Left n) (try $ fractRat n)

    fractRatOnly = do
        fract <- try fraction
        expo  <- option (1%1) expo
        return (Right $ fract * expo) -- Right is Rat

    fractRat n = do
            fract <- try fraction
            expo  <- option (1%1) expo
            return (Right $ ((n % 1) + fract) * expo) -- Right is Rat
        <|> do
            expo <- expo
            if expo < 1
                then return (Right $ (n % 1) * expo)
                else return (Right $ (n % 1) * expo)

    fraction = do
            char '.'
            digit  <- satisfy isDigit
            digits <- many (satisfy isWordDigit) <?> "fraction"
            return (digitsToRat $ filter (/= '_') (digit:digits))
        <?> "fraction"
        where
        digitsToRat d = digitsNum d % (10 ^ length d)
        digitsNum d = foldl (\x y -> x * 10 + (toInteger $ digitToInt y)) 0 d
        isWordDigit x = (isDigit x || x == '_')

    expo :: GenParser Char st Rational
    expo = do
            oneOf "eE"
            f <- sign
            e <- decimalLiteral <?> "exponent"
            return (power (if f then e else -e))
        <?> "exponent"
        where
        power e | e < 0      = 1 % (10^abs(e))
                | otherwise  = (10^e) % 1

    decimalLiteral         = number 10
    hexadecimal     = do{ char 'x'; number 16  }
    decimal         = do{ oneOf "_d"; number 10  }
    octal           = do{ char 'o'; number 8 }
    octalBad        = do{ many1 octDigit ; fail "0100 is not octal in perl6 any more, use 0o100 instead." }
    binary          = do{ char 'b'; number 2  }

    number base = do
        d   <- baseDigit base
        ds  <- many (baseDigit base <|> 
                do { char '_'; lookAhead (baseDigit base); return '_' })
        let n = foldl (\x d -> base*x + b36DigitToInteger d) 0 digits
            digits = (d : filter (/= '_') ds)
        seq n (return n)
        where
        baseDigit                   = baseDigitInt . fromIntegral
        baseDigitInt b 
            | b <= 10               = oneOf $ take b ['0'..'9']
            | b >  10 && b <= 36    = oneOf $ ['0'..'9'] 
                                    ++ take (b - 10) ['a'..'z'] 
                                    ++ take (b - 10) ['A'..'Z']
            | otherwise             = error "baseDigitInt: base too large"
        b36DigitToInteger           = toInteger . b36DigitToInt
        b36DigitToInt c
            | isDigit c             = fromEnum c - fromEnum '0'
            | c >= 'a' && c <= 'z'  = fromEnum c - fromEnum 'a' + 10
            | c >= 'A' && c <= 'Z'  = fromEnum c - fromEnum 'A' + 10
            | otherwise             = error "b36DigitToInt: not a base 36 digit"

sign :: GenParser Char st Bool
sign = (char '-' >> return False)
   <|> (char '+' >> return True)
   <|> return True


