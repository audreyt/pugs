import Text.ParserCombinators.Parsec
import qualified Data.Map
import System.IO
import Debug.Trace
type Label = [Char]
type Register = [Char]
data Value = Var [Char] | IntegerConstant Integer | StringConstant [Char] | None
    deriving Show
data Capture = Capture Register [Register] [Register]
    deriving Show
data Stmt = Decl Register Value | Goto Label | Br Register Label Label | Call Register Register Capture
    deriving Show
data Argument = Pos Register | Named Register Register

data Mold = Mold [Stmt]
    deriving Show

identifier = do
    first <- choice [alphaNum, char '_']
    rest <- many1 $ choice [alphaNum, char '_', digit]
    return $ [first] ++ rest

ws = do
    many1 $ choice
        [ oneOf "\t\n "
        , char '#' >> many1 (noneOf "\n") >> newline
        ]
    return [()]

opt_ws = option [()] ws

tok r = do
    res <- r
    opt_ws
    return res

lparen = char '('
rparen = char ')'

register =  char '$' >> identifier

stmt = choice [call,decl]

value = choice 
      [ do
          char '$'
          name <- identifier
          return $ Var name
      , do
        digits <- many1 digit 
        return $ IntegerConstant $ read digits
      , do
        content <- between (char '"') (char '"') quotedChar
        return $ StringConstant $ concat content
      ]
      where
      quotedChar = many $
        do
        c <- noneOf "\"\\"
        return [c]
        <|> do 
            char '\\'
            c <- anyChar
            return ['\\',c]

decl = do 
    string "my"
    ws
    x <- tok register
    value <- option None $ (tok $ char '=') >> value
    return (Decl x value)

call = do
    target <- tok register
    tok $ char '='
    invocant <- tok register
    char '.'
    identifier <- register
    arguments <- between (tok lparen) rparen $ sepBy (tok argument) (tok $ char ',')
    let pos = [ x | Pos x <- arguments]
    let named = [x | (Named k v) <- arguments, x <- [k,v]]
    return $ Call target identifier (Capture invocant pos named)

argument = do
        char ':'
        key <- tok register
        value <- between (tok $ char '(') (tok $ char ')') (tok register)
        return $ Named key value
    <|> do 
        arg <- tok register
        return $ Pos arg

terminator :: Parser ()
terminator = opt_ws >> (((tok $ char ';') >> return ()) <|> eof)
top = do 
    opt_ws
    stmts <- tok $ endBy1 stmt terminator
    eof
    return $ stmts

type RegMap = Data.Map.Map [Char] Int

toBytecode :: Stmt -> RegMap -> [Int]
--(Capture invocant positional named)

toBytecode (Call target identifier (Capture invocant positional named)) regs =
    let reg r = Data.Map.findWithDefault (-1) r regs in
    let args x = [length x] ++ map reg x in
    [1,reg target,reg invocant,reg identifier] ++ args positional ++ args named

toBytecode x regs = []

isReg (Decl _ None) = True
isReg _ = False

countRegister stmts = length $ filter isReg stmts

addRegister :: RegMap -> Stmt -> RegMap
addRegister regs (Decl reg None) = regs
addRegister regs (Decl reg value) = Data.Map.insert reg ((Data.Map.size regs)+4)  regs
addRegister regs _ = regs


addFreeRegister :: RegMap -> Stmt -> RegMap
addFreeRegister regs (Decl reg None) = Data.Map.insert reg ((Data.Map.size regs)+4)  regs
addFreeRegister regs (Decl reg _) = regs 
addFreeRegister regs _ = regs

registerMap :: [Stmt] -> RegMap
registerMap stmts = foldl addFreeRegister (foldl addRegister Data.Map.empty stmts) stmts

emit :: [Stmt] -> RegMap -> [Int]
emit stmts regMap = concatMap (\op -> toBytecode op regMap) stmts ++ [0]

joinStr sep list = foldl (\a b -> a ++ sep ++ b) (head list) (tail list)

dumpConstantToC :: Value -> [Char]
dumpConstantToC (StringConstant str) = "SMOP__NATIVE__idconst_createn(\""++str++"\","++(show $ length str) ++ "),"
dumpConstantToC (IntegerConstant int) = "SMOP__NATIVE__int_create("++(show int)++"),"
dumpConstantToC (None) = ""
dumpConstantToC (Var name) = "SMOP_REFERENCE(interpreter,"++name++"),"

dumpConstantsToC stmts = "(SMOP__Object*[]) {" ++
    concat [dumpConstantToC c | Decl reg c <- stmts] ++ "NULL}"
dumpToC stmts =
    let regMap    = registerMap stmts in
    let freeRegs  = countRegister stmts in
    let bytecode  = emit stmts regMap in
    let constants = dumpConstantsToC stmts in
    "SMOP__Mold_create(" ++ show freeRegs ++ "," ++ constants ++ ","
    ++ show (length bytecode) ++ ",(int[]) {" ++
    (joinStr "," $ map show bytecode)
    ++ "})"

main = do
    hFlush stdout
    line <- getContents
    case (parse top "" line) of 
        Left err      -> print err
        Right stmts -> do 
            -- print stmts
            putStrLn $ dumpToC stmts
