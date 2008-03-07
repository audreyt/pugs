{-# LANGUAGE MagicHash, FlexibleInstances, OverlappingInstances,IncoherentInstances,
  IncoherentInstances, UndecidableInstances #-}

module Data.Array.Judy.HashIO (
    HashIO (..),
    UniqueHashIO, -- (..),
    ReversibleHashIO (..)
) where

import Data.HashTable (hashString)

import Data.Array.Judy.Private
import GHC.Exts (unsafeCoerce#)

class HashIO a where
    -- Two step conversion, first from a -> Int then Int -> Value
    hashIO :: a -> IO Value
class HashIO a => UniqueHashIO a
class UniqueHashIO a => ReversibleHashIO a where
    -- Two step conversion, first from Value -> Int then Int -> a
    unHashIO :: Value -> IO a

instance Enum a => UniqueHashIO a where

instance Enum a => HashIO a where
    hashIO = return . unsafeCoerce# . fromEnum

instance Enum a => ReversibleHashIO a where
    unHashIO = return . toEnum . unsafeCoerce#


instance HashIO Value where
    hashIO = return

instance UniqueHashIO Value

instance ReversibleHashIO Value where
    unHashIO = return

instance HashIO Integer where
    hashIO = return . fromIntegral . hashString . show

