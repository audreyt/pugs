{-# OPTIONS_GHC -fglasgow-exts -fallow-undecidable-instances -fallow-overlapping-instances #-}
{-! global : YAML_Pos, Perl6Class, MooseClass !-}
{-|
    Perl 6 Values.

>   There beryl, pearl, and opal pale,
>   And metal wrought like fishes' mail,
>   Buckler and corslet, axe and sword,
>   And shining spears were laid in hoard...
-}
module Pugs.Val (
    Value(..), Val(..), ValUndef, ValNative, Id,
    module Pugs.Val.Str,
) where
import Pugs.Internals
import GHC.Exts
import Data.Generics.Basics hiding (cast)
import qualified Data.Typeable as Typeable
import qualified Data.ByteString as Buf

import Pugs.AST.SIO
import Pugs.Val.Str

{-|

This module contains the definition of the five variants for a Perl 6 value.
However, the actual constructors for each variant are abstract, and this module
does not provide concrete data type definitions beyond those five.

-}

-- | 'Val' represents what an unconstrained scalar container can hold.
data Val
    = VUndef  !ValUndef   -- ^ Values that are false on .defined      (ValId = undef)
    | VNative !ValNative  -- ^ Values that can fit into an UArray     (ValId = impl.dep.)
    | forall a. Pure a => VPure !a  -- ^ Values that are immutable    (ValId = pureId)
    | forall a. Mut a  => VMut  !a  -- ^ In-memory mutable structures (ValId = memory addr)
    | forall a. Ext a  => VExt  !a  -- ^ Input/Ouput handles          (ValId = memory addr)
    deriving (Typeable)

{-
instance Value SIO Val where
    val = id
    valId VUndef{}      = cast (NBit False)
    valId (VNative x)   = valId x
    valId (VPure x)     = valId x
    valId (VMut x)      = valId x
    valId (VExt x)      = valId x
    valCompare        = compare
    valMeta (VUndef x)  = cast . show . typeOf $ x
    valMeta (VNative x) = cast . show . typeOf $ x
    valMeta (VPure x)   = valMeta x
    valMeta (VMut x)    = valMeta x
    valMeta (VExt x)    = valMeta x
    valShow             = cast . show
-}

-- instance Pure PureStr where
--  pureId x = cast (cast x :: ByteString)

instance ((:>:) Id) NativeBuf where
    cast = cast . NBuf

{-
instance Value Identity ValNative where
    val             = VNative
    valCompare      = compare
    valShow         = cast . show
    valId x         = cast x
-}

-- | 'Id' is an unique ID that distinguishes two @Val@s of the same type from each other.
type Id = Maybe ValNative

instance ((:>:) Id) ValNative where
    cast = Just

--------------------------------------------------------------------------------------

-- | L<S06/"Undefined types">
data ValUndef
    = UUndef                        -- ^ "my $x"
    | UWhatever                     -- ^ "my $x = *"
    | UFailure  { f_err  :: !Id }   -- ^ "my $x = fail 'oops'"
    | UProto    { p_meta :: !Id }   -- ^ "my $x = Dog"
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
type NativeComplex  = () -- Complex NativeNum 

--------------------------------------------------------------------------------------

type P = Identity

class Coercible m a => Value m a where
    val         :: a -> Val
    valMeta     :: a -> Class
    valMeta     = error "moose"
    valShow     :: a -> PureStr
    valShow _ = cast "<opaque>"
    valId       :: a -> Id
    valId = cast . NUint . unsafeCoerce#
    valCompare  :: a -> a -> Ordering
    valCompare x y = valId x `compare` valId y

class (Monad m, Functor m, Eq a, Data a, Typeable a) => Coercible m a | a -> m where
    asBit    :: a -> m PureBit
    asBit _ = return True
    asInt    :: a -> m PureInt
    asInt x = fail $ "coerce fail: " ++ (show $ typeOf x) ++ " to PureInt"
    asNum    :: a -> m PureNum
    asNum x = fail $ "coerce fail: " ++ (show $ typeOf x) ++ " to PureNum"
    asStr    :: a -> m PureStr
    asStr x = return (cast "<opaque>") -- XXX wrong
    asList   :: a -> Maybe (m PureList)
    asList _ = Nothing -- default = do not flatten
    asNative :: a -> m ValNative
    asNative = fmap (NBuf . cast) . asStr

instance Coercible P PureStr where
    asStr  = return . cast

class (Coercible P a, Ord a, Show a) => Pure a where {}
instance (Coercible P a, Ord a, Show a) => Pure a where {}

instance Pure a => Value P a where
    val         = VPure
    valId       = Just . runIdentity . asNative
    valShow     = cast . show
    valCompare  = compare

instance Mut a => Value STM a where
    val         = VMut

instance Ext a => Value SIO a where
    val         = VExt

class Coercible STM a => Mut a where {}
instance Coercible STM a => Mut a where {}

class Coercible SIO a => Ext a where {}
instance Coercible SIO a => Ext a where {}

type Class = PureStr -- XXX - Wrong

dynEq :: (Typeable a, Typeable b, Eq a) => a -> b -> Bool
dynEq x y = case Typeable.cast y of
    Just y' -> x == y'
    Nothing -> False

dynCompare :: forall a b ma mb. (Value ma a, Value mb b) => a -> b -> Ordering
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
type PureBit        = Bool
type PureBool       = Bool
type PureException  = ()            -- XXX *very* bogus
type PureCode       = ()            -- XXX *very* bogus
type PureSig        = ()
type PureCap        = ()
type PureSet        = Set Val
type PureSeq        = Seq Val
type PureList       = Seq (Either PureSeq PureRange) -- XXX - *very bogus*
type PureComplex    = ()
type PureInt        = ()
type PureNum        = ()
type PureRange      = ()
type PureJunc       = ()
type PurePair       = ()
type PureMap        = ()

{-
--------------------------------------------------------------------------------------
-- | L<S06/"Mutable types"> minus IO types
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
    (VMut aa)    == (VMut aa')      = dynEq aa aa'
    (VExt aa)    == (VExt aa')      = dynEq aa aa'
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

instance Data Val where
    toConstr (VUndef x)     = toConstr x
    toConstr (VNative x)    = toConstr x
    toConstr (VPure x)      = toConstr x
    toConstr (VMut x)       = toConstr x
    toConstr (VExt x)       = toConstr x
    dataTypeOf (VUndef x)   = dataTypeOf x
    dataTypeOf (VNative x)  = dataTypeOf x
    dataTypeOf (VPure x)    = dataTypeOf x
    dataTypeOf (VMut x)     = dataTypeOf x
    dataTypeOf (VExt x)     = dataTypeOf x
    gunfold                 = gunfold
