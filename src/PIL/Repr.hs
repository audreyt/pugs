{-# OPTIONS_GHC -fglasgow-exts #-}
module PIL.Repr (Repr, createRepr, callRepr, reprName) where
import PIL.Repr.P6Array as P6Array
import PIL.Repr.P6Hash as P6Hash
import PIL.Repr.P6Scalar as P6Scalar
import PIL.Repr.P6Opaque as P6Opaque
import PIL.Native.Types
import Data.Typeable
import qualified Data.Map as Map
import qualified UTF8 as Str

data Repr
    = P6Nil
    | P6Hash !P6Hash
    | P6Array !P6Array
    | P6Scalar !P6Scalar
    | P6Opaque !P6Opaque
    deriving (Typeable)
    
reprTypes :: MapOf (Native -> STM Repr)
reprTypes = mkMap
    [ ("p6nil",    (const (return P6Nil)))
    , ("p6hash",   (fmap P6Hash . P6Hash.create))
    , ("p6array",  (fmap P6Array . P6Array.create))
    , ("p6scalar", (fmap P6Scalar . P6Scalar.create))
    , ("p6opaque", (fmap P6Opaque . P6Opaque.create))
    ]

createRepr :: NativeStr -> Native -> STM Repr
createRepr = (reprTypes !)

_as_bit = Str.pack "as_bit"

_p6nil = Str.pack "p6nil"
_p6hash = Str.pack "p6hash"
_p6array = Str.pack "p6array"
_p6scalar = Str.pack "p6scalar"
_p6opaque = Str.pack "p6opaque"

reprName :: Repr -> NativeStr
reprName P6Nil = _p6nil
reprName P6Hash{} = _p6hash
reprName P6Array{} = _p6array
reprName P6Scalar{} = _p6scalar
reprName P6Opaque{} = _p6opaque

callRepr :: Repr -> NativeStr -> ObjectPrim
callRepr P6Nil s | s == _as_bit = const (return (NBit True))
callRepr P6Nil s = error $ "Cannot find " ++ show s ++ " for a prototypical class"
callRepr (P6Hash x) s = (P6Hash.prims ! s) x
callRepr (P6Array x) s = (P6Array.prims ! s) x
callRepr (P6Scalar x) s = (P6Scalar.prims ! s) x
callRepr (P6Opaque x) s = (P6Opaque.prims ! s) x

(!) :: (Ord a, Show a) => Map.Map a b -> a -> b
(!) x k    = case Map.lookup k x of
    Just v  -> v
    Nothing -> error $ "Cannot find " ++ show k ++ " in map: " ++ show (Map.keys x)

mkMap :: [(String, a)] -> MapOf a
mkMap = Map.fromList . map (\(k, v) -> (Str.pack k, v))
