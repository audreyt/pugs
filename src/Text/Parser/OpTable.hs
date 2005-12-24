{-# OpTIONS_GHC -fglasgow-exts -funbox-strict-fields #-}

-- A Haskell port of PGE::OPTable.

module Text.Parser.OpTable where
import Prelude hiding (length, lookup)
import Data.Ratio
import Data.Map as NMap
import Data.Seq as NSeq
import Data.FastPackedString as NStr

data Op
    = Infix         { str :: !Str, assoc :: !Assoc }
    | Prefix        { str :: !Str }
    | Postfix       { str :: !Str }
    | Term          { str :: !Str }
    | Close         { str :: !Str }
    | Ternary       { str :: !Str, str2 :: !Str }
    | Circumfix     { str :: !Str, str2 :: !Str }
    | PostCircumfix { str :: !Str, str2 :: !Str }
    deriving (Eq, Show, Ord)

type Precedence = Ratio Int
type Arity = Int

data Token = MkToken
    { tokOp    :: !Op
    , tokPrec  :: !Precedence
    , tokArity :: !Arity
    , tokClose :: !(Maybe Op)
    }

data Match = MkMatch
    { matchOp   :: !Op
    , matchSubs :: !(Seq Match)
    }

data Assoc
    = Non | Left | Right | Chain | List
    deriving (Eq, Show, Ord)

data Whitespace
    = AllowWhitespace
    | NoWhitespace
    deriving (Eq, Show, Ord)

data PrecRelation
    = DefaultPrec
    | SameAs        { relOp :: !Op }
    | TighterThan   { relOp :: !Op }
    | LooserThan    { relOp :: !Op }
    deriving (Eq, Show, Ord)

data OpTable = MkOpTable
    { tableEntries   :: !EntryMap
    , tableTerms     :: !TokenMap
    , tableOps       :: !TokenMap
    , tableWsTerms   :: !TokenMap
    , tableWsOps     :: !TokenMap
    }

type Str = NStr.FastString
type EntryMap = Map Op Token
type TokenMap = Map Term Token

-- | Terms are ordered by descending length first.
newtype Term = MkTerm Str deriving (Eq, Show)

instance Ord Term where
    compare (MkTerm x) (MkTerm y) = case compare (NStr.length y) (NStr.length x) of
        EQ -> compare x y
        o  -> o

addToken :: OpTable -> Op -> PrecRelation -> Whitespace -> OpTable
addToken table op rel ws = doCloseOp . doInsert $ table{ tableEntries = ents' }
    where
    ents  = tableEntries table
    ents' = doCloseEntry $ insert op tok ents
    tok   = MkToken
        { tokOp    = op
        , tokPrec  = calculatePrec rel ents
        , tokArity = arityOf op
        , tokClose = maybeOpClose
        }
    doInsert = insertBy op tok ws
    (doCloseOp, doCloseEntry, maybeOpClose)
        | isClosing op =
            ( insertOp mkTokClose AllowWhitespace
            , insert opClose tok
            , Just opClose
            )
        | otherwise    = (id, id, Nothing)
    opClose = Close (str2 op)
    mkTokClose = MkToken
        { tokOp     = opClose
        , tokPrec   = tokPrec tok
        , tokArity  = 0
        , tokClose  = Nothing
        }

arityOf :: Op -> Arity
arityOf Close{}         = 0
arityOf Ternary{}       = 3
arityOf Infix{}         = 2
arityOf PostCircumfix{} = 2
arityOf _               = 1

insertBy :: Op -> Token -> Whitespace -> OpTable -> OpTable
insertBy Term{}           = insertTerm
insertBy Prefix{}         = insertTerm
insertBy Circumfix{}      = insertTerm
insertBy _                = insertOp

isClosing :: Op -> Bool
isClosing Ternary{}         = True
isClosing Circumfix{}       = True
isClosing PostCircumfix{}   = True
isClosing _                 = False

insertTerm, insertOp :: Token -> Whitespace -> OpTable -> OpTable
insertTerm tok NoWhitespace    table = table
    { tableTerms   = insertTok tok (tableTerms table)   }
insertTerm tok AllowWhitespace table = table
    { tableTerms   = insertTok tok (tableTerms table)
    , tableWsTerms = insertTok tok (tableWsTerms table) }
insertOp   tok NoWhitespace    table = table
    { tableOps     = insertTok tok (tableOps table)     }
insertOp   tok AllowWhitespace table = table
    { tableOps     = insertTok tok (tableOps table)
    , tableWsOps   = insertTok tok (tableWsOps table) }

insertTok :: Token -> TokenMap -> TokenMap
insertTok tok tmap = insert key tok tmap
    where
    key = MkTerm $ str (tokOp tok)

defaultPrec :: Precedence
defaultPrec = 1%1

calculatePrec :: PrecRelation -> EntryMap -> Precedence
calculatePrec DefaultPrec _ = defaultPrec
calculatePrec rel toks = case rel of
    SameAs {}       -> prec
    TighterThan {}  -> prec / 2
    LooserThan {}   -> prec / 2 * 3
    where
    prec = tokPrec (toks ! (relOp rel))

parse :: OpTable -> Str -> Match
parse = undefined
