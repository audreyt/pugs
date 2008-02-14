{-# OPTIONS_GHC -fglasgow-exts -fallow-undecidable-instances -fallow-overlapping-instances -fno-warn-missing-methods -cpp #-}
{-|
    Perl 6 Values.

>   There beryl, pearl, and opal pale,
>   And metal wrought like fishes' mail,
>   Buckler and corslet, axe and sword,
>   And shining spears were laid in hoard...
-}

module Pugs.Val (
    module Pugs.Val,
    module Pugs.Val.Code,
    module Pugs.Val.Capture,
    Val, Call,
) where
import Pugs.Class
import Pugs.Val.Base ()
import Pugs.Val.Code
import Pugs.Val.Capture
import Pugs.Internals
import Text.PrettyPrint

asStr :: Val -> Eval PureStr
asStr (MkInvocant x _) = return (cast (show x))
asBit :: Val -> Eval PureBit
asBit _ = return (cast True)
asInt :: Val -> Eval PureInt
asInt _ = return (cast (0 :: Int))
asNum :: Val -> Eval PureNum
asNum _ = return (cast (0 :: Double))
listVal :: Val -> Eval PureList
listVal = return . (:[])
itemVal :: Val -> Eval Val
itemVal = return

valMeta :: Val -> PureStr
valMeta _ = cast "Object"

valShow :: Val -> PureStr
valShow _ = cast "<opaque>"

formatVal :: Val -> Doc
formatVal (MkInvocant x _) = text (show x)

castVal :: forall a m . (Monad m, Typeable a) => Val -> m a
castVal (MkInvocant v _)  = fromTypeable v

instance ((:>:) PureNum) Rational where cast = NRational
instance ((:<:) PureNum) Rational where
    castBack (NDouble   x) = toRational x
    castBack (NRational x) = x
instance ((:>:) PureNum) Double where cast = NDouble
instance ((:<:) PureNum) Double where
    castBack (NDouble   x) = x
    castBack (NRational x) = fromRational x

instance ((:>:) PureInt) Integer where cast = IFinite
instance ((:<:) PureInt) Integer where
    castBack (IFinite i) = i
    castBack INotANumber = error "NaN"
    castBack (IInfinite SPositive) = error "+Infinity"
    castBack (IInfinite SNegative) = error "-Infinity"

instance ((:>:) PureInt) Int where cast = IFinite . toInteger 
instance ((:<:) PureInt) Int where
    castBack (IFinite i) = fromInteger i
    castBack INotANumber = error "NaN"
    castBack (IInfinite SPositive) = error "+Infinity"
    castBack (IInfinite SNegative) = error "-Infinity"
type PureList = [Val] -- Seq (Either PureSeq PureRange) -- XXX - *very bogus*

newtype PureBit = MkBit Bool
    deriving (Typeable, Show, Eq, Ord, Data, (:>:) Bool, (:<:) Bool)

type PureStr = ByteString

data PureInt
    = IFinite      !Integer
    | IInfinite    !Sign
    | INotANumber
    deriving (Typeable, Show, Eq, Ord, Data)

data PureNum
    = NDouble   !Double              -- change to "!NativeDouble"
    | NRational !Rational
    deriving (Typeable, Show, Eq, Ord, Data)

data Sign
    = SPositive
    | SNegative
    deriving (Show, Eq, Ord, Data, Typeable)

-- | L<S02/"Undefined types">
data ValUndef
    = UUndef                      -- ^ "my $x"
    | UWhatever                   -- ^ "my $x = *"
    | UFailure  { f_err  :: !ID } -- ^ "my $x = fail 'oops'"
    | UProto    { p_meta :: !ID } -- ^ "my $x = Dog"
    deriving (Show, Eq, Ord, Data, Typeable)

instance Boxable ValUndef
instance Boxable PureInt
instance Boxable PureNum
instance Boxable PureSig
instance Boxable PureBit
instance Boxable ValCapt

instance Boxable Int
{-
module Pugs.Val (
    IValue(..), Val(..), ValUndef(..), ValNative, P,
    ICoercible(..), WHICH, castVal, formatVal,
    PureBit, PureBool, PureInt, PureNum, PureStr, PureList, itemVal, listVal,

    Table, Var(..),

    -- From Code
    Sig(..), SigParam(..), ParamAccess(..), ParamDefault(..),
    Capt(..), Feed(..), emptyFeed, Code(..),
    ValCapt, ValFeed,
) where
import Pugs.Internals
import Pugs.Class
import GHC.Exts
import Data.Generics.Basics hiding (cast)
import qualified Data.Typeable as Typeable
import qualified Data.ByteString as Buf
import qualified Data.Map as Map
import qualified Data.Set as Set
import Data.Monoid

import Pugs.AST.SIO
import Pugs.Val.Base
--import Pugs.Val.Sig
--import Pugs.Val.Code
--import Pugs.Exp
import {-# SOURCE #-} Pugs.Exp
import qualified Pugs.Types as Types
import Pugs.Types (Var(..))

import Text.PrettyPrint -- move to Pugs.Val.Pretty?

-- XXX - Once GHC 6.6 is released with bindists, change #include to .hs-boot!
#include "Val/Code.hs"

{-|

This module contains the definition of the five variants for a Perl 6 value.
However, the actual constructors for each variant are abstract, and this module
does not provide concrete data type definitions beyond those five.

-}

-- | 'Val' represents what an unconstrained scalar container can hold.
data Val
    = VUndef  !ValUndef   -- ^ Values that are false on .defined      (WHICH = undef)
    | VNative !ValNative  -- ^ Values that can fit into an UArray     (WHICH = impl.dep.)
    | forall a. Pure a => VPure !a  -- ^ Values that are immutable    (WHICH = pureId)
    | forall a. Mut a  => VMut  !a  -- ^ In-memory mutable structures (WHICH = memory addr)
    | forall a. Ext a  => VExt  !a  -- ^ Input/Ouput handles          (WHICH = memory addr)
    deriving (Typeable)

castVal :: forall a m . (Monad m, Typeable a) => Val -> m a
--castVal = gmapQi 0 fromTypeable -- when we have 6.6, and can make all Val in Data.
castVal (VUndef v)  = fromTypeable v
castVal (VNative v) = fromTypeable v
castVal (VPure v)   = fromTypeable v
castVal (VMut v)    = fromTypeable v
castVal (VExt v)    = fromTypeable v

-- | Value view. Contains methods for inspecting values: getting
-- their metaclass, ids, stringification and so on.
class ICoercible m a => IValue m a where
    -- | lift an ASTish leaf type to a value. Using this convenience method
    -- you can say "val (NInt 42)" instead of "Val (VNative (NInt 42))".
    val         :: a -> Val
    -- | retrieve metaclass instance of a value.
    valMeta     :: a -> Class
    valMeta     = cast . takeTypeName "" . reverse . show . typeOf
        where
        -- Here we intuit "Str" from "Pugs.Val.Str.PureStr".
        takeTypeName acc [] = acc
        takeTypeName acc (x:xs)
            | isLower x = takeTypeName (x:acc) xs
            | otherwise = x:acc
    -- | Stringification of arbitrary values.
    valShow     :: a -> PureStr
    valShow _ = cast "<opaque>"
    -- | Identity.
    valId       :: a -> WHICH
    valId x = cast (NUint (W# (unsafeCoerce# x)))
    -- | Comparison.
    valCompare  :: a -> a -> Ordering
    valCompare x y = valId x `compare` valId y

instance ICoercible SIO Val where
    -- XXX - have to invent a generic map somehow -- DrIFT anyone?
    asBit VUndef{}      = cast False
    asBit (VNative x)   = cast $ asBit x
    asBit (VPure x)     = cast $ asBit x
    asBit (VMut x)      = cast $ asBit x
    asInt (VPure x)     = cast $ asInt x
    asNum (VPure x)     = cast $ asNum x
    asStr (VPure x)     = cast $ asStr x
    asItem = Just . itemVal
    asList = Just . listVal
    asNative (VPure x)  = cast $ asNative x

-- evaluate a Val in Item context, a.k.a. rvalue, a.k.a. "is readonly"
itemVal :: Val -> SIO Val
itemVal v@(VPure x) = f v x asItem
itemVal v@(VMut x)  = f v x asItem
itemVal v@(VExt x)  = f v x asItem
itemVal v           = return v

-- evaluate a Val in List context, a.k.a. flattening, a.k.a. "is slurpy"
listVal :: Val -> SIO PureList
listVal v@(VPure x) = f v x asList
listVal v@(VMut x)  = f v x asList
listVal v@(VExt x)  = f v x asList
listVal v           = cast v

f v x g = maybe (cast v) cast (g x)

instance ((:>:) PureList) Val where
    cast = singleton -- . Left . singleton

instance IValue SIO Val where
    val = id
    valId VUndef{}      = cast (NBit False)
    valId (VNative x)   = Just x
    valId (VPure x)     = valId x
    valId (VMut x)      = valId x
    valId (VExt x)      = valId x
    valCompare          = compare
    valMeta (VUndef x)  = cast . show . typeOf $ x
    valMeta (VNative x) = valMeta x
    valMeta (VPure x)   = valMeta x
    valMeta (VMut x)    = valMeta x
    valMeta (VExt x)    = valMeta x
    valShow             = cast . show

-- instance Pure PureStr where
--  pureId x = cast (cast x :: ByteString)

instance ((:>:) WHICH) NativeBuf where
    cast = cast . NBuf

instance ICoercible P ValNative where
    asNative = return . id

instance IValue P ValNative where
    val                 = VNative
    valMeta NBit{}      = cast "bit"
    valMeta NInt{}      = cast "int"
    valMeta NUint{}     = cast "uint"
    valMeta NBuf{}      = cast "buf"
    valMeta NNum{}      = cast "num"
    valMeta NComplex{}  = cast "complex"
    valCompare          = compare
    valShow             = cast . show
    valId x             = cast x

-- | 'WHICH' is an unique ID that distinguishes two @Val@s of the same type from each other.
type WHICH = Maybe ValNative

instance ((:>:) WHICH) ValNative where
    cast = Just

--------------------------------------------------------------------------------------

-- | L<S02/"Undefined types">
data ValUndef
    = UUndef                        -- ^ "my $x"
    | UWhatever                     -- ^ "my $x = *"
    | UFailure  { f_err  :: !WHICH } -- ^ "my $x = fail 'oops'"
    | UProto    { p_meta :: !WHICH } -- ^ "my $x = Dog"
    deriving (Show, Eq, Ord, Data, Typeable)

--------------------------------------------------------------------------------------
-- | Unboxed values.
data ValNative
    = NBit      !NativeBit      -- ^ 0
    | NInt      !NativeInt      -- ^ -3
    | NUint     !NativeUint     -- ^ 7
    | NBuf      !NativeBuf      -- ^ (a raw chunk of ints or uints)
    | NNum      !NativeNum      -- ^ 4.2
    | NComplex  !NativeComplex  -- ^ (45 - 9i)
    deriving (Show, Eq, Ord, Data, Typeable)

type NativeBit      = Bool
type NativeInt      = Int
type NativeUint     = Word
type NativeBuf      = ByteString
type NativeNum      = Float

-- Haskell's Complex type does not instantiate Ord and Data.
newtype NativeComplex = MkNComplex { unComplex :: Complex NativeNum }
    deriving (Show, Eq, Typeable)
instance Ord NativeComplex where
    compare = error "NativeComplex numbers cannot be ordered"
instance Data NativeComplex where
--  gunfold    = error "gunfold NativeComplex"
    toConstr   = error "toConstr NativeComplex"
    dataTypeOf = error "dataTypeOf NativeComplex"

--------------------------------------------------------------------------------------

-- | L<S02/"Immutable types">

-- | Pure values need not be in a monad, but we put them in the trivial
-- Identity so that they are at the same monadic depth as Mut and Ext.
type P = Identity
instance Typeable1 P

class (ICoercible P a, Ord a, Show a) => Pure a where
    purePretty :: a -> Doc
    purePretty = text . show

instance (ICoercible P a, Ord a, Show a) => Pure a where {}

liftP :: Monad m => P a -> m a
liftP = return . runIdentity

instance Pure a => IValue P a where
    val         = VPure
    valId       = liftP . asNative
    valShow     = cast . show
    valCompare  = compare

instance Mut a => IValue STM a where
    val         = VMut

instance Ext a => IValue SIO a where
    val         = VExt

class ICoercible STM a => Mut a where {}
instance ICoercible STM a => Mut a where {}

class ICoercible SIO a => Ext a where {}
instance ICoercible SIO a => Ext a where {}

-- type Class = PureStr -- XXX - Wrong

dynEq :: (Typeable a, Typeable b, Eq a) => a -> b -> Bool
dynEq x y = case Typeable.cast y of
    Just y' -> x == y'
    Nothing -> False

dynCompare :: forall a b ma mb. (IValue ma a, IValue mb b) => a -> b -> Ordering
dynCompare x y = case Typeable.cast y of
    Just y' -> valCompare x y'
    Nothing -> compare (show $ typeOf x) (show $ typeOf y)

{-
    = PBit       !PureBit
    | PInt       !PureInt
    | PStr       !PureStr
    | PNum       !PureNum
    | PComplex   !PureComplex
    | PBool      !PureBool
    | PException !PureException -- XXX
    | PCode      !PureCode
    | PBlock     !PureCode -- XXX: or more primitive type?
    | PList      !PureList
    | PSeq       !PureSeq
    | PRange     !PureRange
    | PSet       !PureSet
    | PJunc      !PureJunc
    | PPair      !PurePair
    | PMap       !PureMap
    | PSig       !PureSig
    | PCap       !PureCap 
    deriving (Show, Eq, Ord, Data, Typeable) {-!derive: YAML_Pos, Perl6Class, MooseClass!-}

-}
type PureBool       = Bool
type PureException  = ()            -- XXX *very* bogus
type PureCode       = ()            -- XXX *very* bogus
type PureCap        = ()
type PureSet        = Set Val
type PureSeq        = Seq Val
type PureComplex    = ()
type PureRange      = ()
type PureJunc       = ()
type PurePair       = ()
type PureMap        = ()

{-
--------------------------------------------------------------------------------------
-- | L<S02/"Mutable types"> minus IO types
--   Computations on these types take place in the STM monad.
data ValMut
    = MScalar    !MutScalar
    | MArray     !MutArray
    | MHash      !MutHash
    | MBuf       !MutBuf
    | MRoutine   !MutRoutine
    | MSub       !MutRoutine -- ?
    | MMethod    !MutRoutine -- ?
    | MSubmethod !MutRoutine -- ?
    | MMacro     -- ???
    | MRegex     !MutVRule -- XXX: maybe move to pure
    | MMatch     !MutVMatch
    | MPackage   !MutPackage
    | MModule    !MutModule
    | MClass     !MutClass
    | MRole      !MutRole
    | MGrammar   !MutGrammar
    | MObject    !MutObject  -- ? or ObjectId?
    | MForeign   !MutDynamic -- ...?
    deriving (Show, Eq, Ord, Data, Typeable) {-!derive: YAML_Pos, Perl6Class, MooseClass!-}
-}

--------------------------------------------------------------------------------------
{-
-- | Obviously side-effectual types such as file handles.
--   Computations on these types must take place in the IO monad.
data ValExt
    = IFile     !ExtFile     -- ^ File handle
    | ISocket   !ExtSocket   -- ^ Socket handle
    | IThread   !ExtThread   -- ^ Thread handle
    | IProcess  !ExtProcess  -- ^ Process handle
    deriving (Show, Eq, Ord, Data, Typeable) {-!derive: YAML_Pos, Perl6Class, MooseClass!-}
-}

type ExtFile         = ()
type ExtSocket       = ()
type ExtThread       = ()
type ExtProcess      = ()

--------------------------------------------------------------------------------------

-- | General purpose mapping from identifiers to values.
type Table = Map.Map ID Val


{- Pad -}
{-|
A 'Pad' keeps track of the names of all currently-bound symbols, and
associates them with the things they actually represent.

It is represented as a mapping from names to /lists/ of bound items.
This is to allow for multi subs, because we will need to keep
/multiple/ subs associated with one symbol. In other cases, the list
should just contain a single value. See 'Pugs.AST.genSym' and 'Pugs.AST.genMultiSym' for
more details.

@TVar@ indicates that the mapped-to items are STM transactional variables.

Pads are stored in the current 'Code', and lexical lookups proceed through
progressively outer scopes until an item is found. For dynamic variables
(e.g., "our"), the pad holding the items is located in the package.
-}

newtype Pad = MkPad { padEntries :: Map.Map Var PadEntry }
    deriving (Show, Eq, Ord, Data, Typeable) {-!derive: YAML_Pos, Perl6Class, MooseClass!-}

newtype EntryStorage = MkStorage { s_cell :: TVar Val }
    deriving (Data, Typeable) {-!derive: YAML_Pos, Perl6Class, MooseClass!-}
instance Show EntryStorage where
    show _ = error "can't show EntryStorage"
instance Ord EntryStorage where
    compare _ = error "can't compare EntryStorage"
instance Eq EntryStorage where
    (==) = error "can't equate EntryStorage"

data EntryDeclarator
    = DeclMy
    | DeclOur
    | DeclHas
    | DeclState
    | DeclConstant
    deriving (Show, Eq, Ord, Data, Typeable) {-!derive: YAML_Pos, Perl6Class, MooseClass!-}

data PadEntry = MkEntry
    { e_declarator :: EntryDeclarator   -- ^ my etc.
    , e_storage    :: EntryStorage      -- ^ stored value
    }
    deriving (Show, Eq, Ord, Data, Typeable) {-!derive: YAML_Pos, Perl6Class, MooseClass!-}

--------------------------------------------------------------------------------------

-- type Var = Types.Var
{- Variable specification. This belongs in an AST .hs file, not here but until
 - it finds its home we will give it boarding.
 - XXX - Augment Pugs.Types.Var to reason about caller/outer, not here! -}

 {-
data Var
    = VarLexical
        { v_name        :: ID
        , v_callerCount :: Int
        , v_outerCount  :: Int
        }
    | VarDynamic
        { v_name        :: ID
        , v_packageName :: [ID]
        }
    | VarMagic
        { v_magic       :: Magic
        }
    deriving (Show, Eq, Ord, Data, Typeable) {-!derive: YAML_Pos, Perl6Class, MooseClass!-}
    -}

data Magic
    = MOS               -- ^ $?OS        Which os am I compiled for?
    | MOSVer            -- ^ $?OSVER     Which os version am I compiled for?
    | MPerlVer          -- ^ $?PERLVER   Which Perl version am I compiled for?
    | MFile             -- ^ $?FILE      Which file am I in?
    | MLine             -- ^ $?LINE      Which line am I at?
    | MScalarPackage    -- ^ $?PACKAGE   Which package am I in?
    | MArrayPackages    -- ^ @?PACKAGE   Which packages am I in?
    | MScalarModule     -- ^ $?MODULE    Which module am I in?
    | MArrayModules     -- ^ @?MODULE    Which modules am I in?
    | MScalarClass      -- ^ $?CLASS     Which class am I in? (as variable)
    | MArrayClasses     -- ^ @?CLASS     Which classes am I in?
    | MScalarRole       -- ^ $?ROLE      Which role am I in? (as variable)
    | MArrayRoles       -- ^ @?ROLE      Which roles am I in?
    | MScalarGrammar    -- ^ $?GRAMMAR   Which grammar am I in?
    | MArrayGrammars    -- ^ @?GRAMMAR   Which grammars am I in?
    | MParser           -- ^ $?PARSER    Which Perl grammar was used to
                        -- ^                   parse this statement?
    | MScalarRoutine    -- ^ &?ROUTINE   Which routine am I in?
    | MArrayRoutines    -- ^ @?ROUTINE   Which routines am I in?
    | MScalarBlock      -- ^ &?BLOCK     Which block am I in?
    | MArrayBlocks      -- ^ @?BLOCK     Which blocks am I in?
    deriving (Show, Eq, Ord, Data, Typeable) {-!derive: YAML_Pos, Perl6Class, MooseClass!-}

--------------------------------------------------------------------------------------
formatVal :: Val -> Doc
formatVal (VUndef v) = text $ case v of
    (UUndef)     -> "undef"
    (UWhatever)  -> "{whatever}"
    (UFailure x) -> "{failure:" ++ (show x) ++ "}" -- what we really want is to port Pretty to fps
    (UProto x)   -> "{proto:" ++ (show x) ++ "}"
formatVal (VNative v) = text $ case v of
    (NBit x)     -> if x then "True" else "False"
    (NInt x)     -> show x
    (NUint x)     -> show x
    (NBuf _)     -> "{Buf}"
    (NNum x)     -> show x
    (NComplex (MkNComplex x)) -> (show "(") ++ (show $ realPart x) ++ " " ++
        (if (0 >) (imagPart x) then "- " ++ (show $ 0 - imagPart x) else "+ " ++ (show $ imagPart x)) ++ "*Math::i)"
formatVal (VPure v) = purePretty v
formatVal x = text $ show x

--    (NComplex r i(s@i')) -> "(" ++ (show r) ++ " " ++
--        (if s == '-' then ("- " ++ show i') else ("+ " ++ show i)) ++ "*i)"
--formatVal (VPure v) = runIdentity
--------------------------------------------------------------------------------------

{-* Generated by DrIFT : Look, but Don't Touch. *-}
instance Show Val where
    showsPrec d (VUndef aa) = showParen (d >= 10)
              (showString "VUndef" . showChar ' ' . showsPrec 10 aa)
    showsPrec d (VNative aa) = showParen (d >= 10)
              (showString "VNative" . showChar ' ' . showsPrec 10 aa)
    showsPrec d (VPure aa) = showParen (d >= 10)
              (showString "VPure (" . showsPrec 10 aa . showChar ')')
    showsPrec d (VMut aa) = showParen (d >= 10)
              (showString "VMut (" . (cast(valShow aa) ++) . showChar ')')
    showsPrec d (VExt aa) = showParen (d >= 10)
              (showString "VExt (" . (cast(valShow aa) ++) . showChar ')')

instance Eq Val where
    (VUndef aa)  == (VUndef aa')    = aa == aa'
    (VNative aa) == (VNative aa')   = aa == aa'
    (VPure aa)   == (VPure aa')     = dynEq aa aa'
    (VMut aa)    == (VMut aa')      = valId aa == valId aa'
    (VExt aa)    == (VExt aa')      = valId aa == valId aa'
    _            == _               = False

instance Ord Val where
    compare (VUndef aa) (VUndef aa') = compare aa aa'
    compare (VUndef _) (VNative _) = LT
    compare (VUndef _) (VPure _) = LT
    compare (VUndef _) (VMut _) = LT
    compare (VUndef _) (VExt _) = LT
    compare (VNative _) (VUndef _) = GT
    compare (VNative aa) (VNative aa') = compare aa aa'
    compare (VNative _) (VPure _) = LT
    compare (VNative _) (VMut _) = LT
    compare (VNative _) (VExt _) = LT
    compare (VPure _) (VUndef _) = GT
    compare (VPure _) (VNative _) = GT
    compare (VPure aa) (VPure aa') = dynCompare aa aa'
    compare (VPure _) (VMut _) = LT
    compare (VPure _) (VExt _) = LT
    compare (VMut _) (VUndef _) = GT
    compare (VMut _) (VNative _) = GT
    compare (VMut _) (VPure _) = GT
    compare (VMut aa) (VMut aa') = dynCompare aa aa'
    compare (VMut _) (VExt _) = LT
    compare (VExt _) (VUndef _) = GT
    compare (VExt _) (VNative _) = GT
    compare (VExt _) (VPure _) = GT
    compare (VExt _) (VMut _) = GT
    compare (VExt aa) (VExt aa') = dynCompare aa aa'


-}
