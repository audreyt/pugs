{-# OPTIONS_GHC -cpp -fglasgow-exts -fno-warn-orphans -fallow-overlapping-instances -fallow-undecidable-instances #-}

module Pugs.AST.Internals where
import Pugs.Types
import Pugs.Internals
import Pugs.AST.Pos
import Pugs.AST.SIO
import Control.Concurrent.STM
import Data.Dynamic

instance Typeable Val

data Env
data Val
data VRef
data VObject
data PadEntry
data Exp
-- newtype Pad = MkPad { padEntries :: Map Var PadEntry }
newtype ObjectId = MkObjectId { unObjectId :: Int }

type VType = Type
type VArray = [Val]
type VList = [Val]
type VHash = Map VStr Val

showVal :: Val -> String
envPos' :: Env -> Pos
errStr :: VStr -> Val
errStrPos :: VStr -> Pos -> Val
errValPos :: Val -> Pos -> Val
envAtomic :: Env -> Bool
envContext :: Env -> Cxt
envMaxId :: Env -> TVar ObjectId
enterAtomicEnv :: Env -> Env
objOpaque :: VObject -> Maybe Dynamic

anyToVal :: (Show a, Typeable a) => a -> Val
--anyFromVal :: Typeable a => Val -> a

createObjectRaw :: (MonadSTM m)
    => ObjectId -> Maybe Dynamic -> VType -> [(VStr, Val)] -> m VObject
