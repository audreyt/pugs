{-# OPTIONS_GHC -fglasgow-exts -fparr #-}

{-|
    Class meta-model.  (object meta-meta-model)

>   Learn now the lore of Living Creatures!
>   First name the four, the free peoples:
>   Eldest of all, the elf-children;
>   Dwarf the delver, dark are his houses;
>   Ent the earthborn, old as mountains;
>   Man the mortal, master of horses...
-}

module Pugs.Class
    ( module Pugs.Class
    , module Pugs.AST.Eval
    , module MO.Run
    , module MO.Compile
    , module MO.Compile.Class
    , module MO.Util
    , module Control.Monad.Fix
    ) where
import MO.Run hiding (__)
import MO.Compile
import MO.Compile.Class
import MO.Util hiding (traceM, traceShow)
import Pugs.Internals
import Pugs.AST.Eval
import Control.Monad.Fix
import qualified Data.Map as Map
import qualified Data.Typeable as Typeable

type Val = Invocant Eval
type Call = MethodInvocation Eval

class (Show a, Typeable a, Ord a) => Boxable a where
    mkVal :: a -> Val
    mkVal x = MkInvocant x (class_interface (classOf x))

    coerceVal :: Val -> Eval a
    coerceVal (MkInvocant x _) = case Typeable.cast x of
        Just y -> return y
        _      -> fail $ "Cannot coerce from " ++ (show $ typeOf x) ++ " to " ++ (show $ typeOf (undefined :: a))

    methodsOf :: [(ID, MethodPrim a)]
    methodsOf = []

    classOf :: a -> PureClass
    classOf _ = mkPureClass (classNameOf (undefined :: a)) ([] :: [(ID, a -> Eval Val)])

    classNameOf :: a -> String
    classNameOf _ = takeTypeName "" . reverse . show . typeOf $ (undefined :: a)
        -- Here we intuit "Str" from "Pugs.Val.Str.PureStr".
        where
        takeTypeName acc [] = acc
        takeTypeName acc (x:xs)
            | isLower x = takeTypeName (x:acc) xs
            | otherwise = x:acc

type MethodPrim a = (a -> [:Val:] -> Eval Val)

(===) :: (Boxable b, ((:>:) (MethodPrim b)) a) => String -> a -> (ID, MethodPrim b)
(===) x y = (_cast x, cast y)

(...) :: Boxable b => String -> (a -> b) -> (ID, a -> Eval Val)
(...) x y = (_cast x, (return . mkVal) . y)

(!!!) :: Boxable b => String -> (a -> Eval b) -> (ID, a -> Eval Val)
(!!!) x y = (_cast x, mkValM . y)

mkValM :: Boxable a => Eval a -> Eval Val
mkValM x = do
    x' <- x
    return $ MkInvocant x' (class_interface (classOf x'))

mkBoxClass :: Typeable t => String -> [(ID, t -> Eval Val)] -> PureClass
mkBoxClass cls methods = newMOClass MkMOClass
    { moc_parents         = []
    , moc_roles           = []
    , moc_attributes      = []
    , moc_public_methods  = newCollection' methodName $ map mkBoxMethod methods
    , moc_private_methods = newCollection []
    , moc_name            = _cast cls
    }

-- | Variant of @mkBoxClass@ making use of the fixed-point combinator
-- to tye in its "self", and, that adds the standard HOW and WHICH methods.
mkPureClass :: (Boxable a) => String -> [(ID, a -> Eval Val)] -> PureClass
mkPureClass cls methods =
    fix (mkBoxClass cls . methods')
    where 
    methods' self = flip (++) methods
        [ "HOW"         ... const self
        , "WHAT"        ... const (raiseWhatError ("Can't access attributes of prototype: " ++ cls) `asTypeOf` self)
        , "WHICH"       ... id
        , "ITEM"        ... id
        , "LIST"        ... id
        ]

raiseWhatError :: String -> a
raiseWhatError = error

mkBoxMethod :: Typeable t => (ID, t -> Eval Val) -> AnyMethod Eval
mkBoxMethod (meth, fun) = MkMethod $ MkSimpleMethod
    { sm_name       = meth
    , sm_definition = MkMethodCompiled $ \args -> do
        str <- fromInvocant args
        fun str   -- Note that we expect "fun" to be monadic
    }

type PureClass = MOClass Eval

instance (Show a, Typeable a, Ord a) => Boxable (Maybe a)

instance Boxable a => Boxable [a]
instance Boxable a => Boxable [:a:]
instance Typeable1 [::] where
    typeOf1 _ = mkTyConApp (mkTyCon "[::]") []

instance Boxable ID
instance Boxable PureClass where
    classOf _ = _PureClass

_PureClass :: PureClass
_PureClass = mkPureClass "Class"
    [ "methods"     ... ((map methodName . all_methods) :: PureClass -> [ID])
    ]

instance ((:>:) Call) String where
    cast = (`MkMethodInvocation` CaptSub{ c_feeds = [::] }) . _cast

instance ((:>:) Call) ByteString where
    cast = (`MkMethodInvocation` CaptSub{ c_feeds = [::] }) . cast

instance ((:>:) Call (ByteString, [Val], Map ID Val)) where
    cast (meth, pos, named) = MkMethodInvocation (cast meth) CaptSub{ c_feeds = [: MkFeed (toP pos) (Map.map (\x -> [:x:]) named) :]}

