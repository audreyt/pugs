{-# OPTIONS_GHC -fglasgow-exts -fallow-undecidable-instances #-}

module Judy.CollectionsM (
    MapM (..),
    MapF (..)
) where

-- import Judy.Freeze
-- import Foreign
import Data.IORef
import qualified Data.Map       as DM
import qualified Data.HashTable as HT

import Prelude hiding (lookup)

-- import Prelude (Bool(..), Int, Maybe(..),
--                 (==), (.), (+), ($), (-), (&&), (||),
--                 Eq, Ord,
--                 error, const, not, fst, snd, maybe, head, otherwise, curry, uncurry, flip,
--                 min, max, Show)

-- import Prelude hiding (sum,concat,lookup,map,filter,foldr,foldr1,foldl,null,reverse,(++),minimum,maximum,all,elem,concatMap,drop,head,tail,init)

{-
class Monad m => CollectionM c i o m | c -> i o m where
    -- From Foldable
    null :: c -> m Bool
    size :: c -> m Int

    empty :: m c
    isSingleton :: c -> m Bool
    -- FIXME: create a new structure? or delete inplace? or have both options?
    filter :: (o -> Bool) -> c -> m c
    insert :: i -> c -> m ()
    singleton :: i -> m c

    -- FIXME: Foldable here
    insertMany :: [i] -> c -> m ()
    isSingleton :: c -> m Bool
-}

class Monad m => MapM c k a m | c -> k a m where
    new :: m c
    --delete :: k -> c -> m ()
    delete :: k -> c -> m Bool
    member :: k -> c -> m Bool
    lookup :: k -> c -> m (Maybe a)
    insert :: k -> a -> c -> m ()
    alter :: Eq a => (Maybe a -> Maybe a) -> k -> c -> m (Maybe a)

    -- Generalize more... (fromFoldable, fromListWith, and both)
    --fromFoldableWith :: Foldable l (k,a) => (a -> a -> a) -> l -> m c
    fromList :: [(k,a)] -> m c
    toList :: c -> m [(k,a)]

    elems :: c -> m [a]
    keys :: c -> m [k]

    mapToList :: (k -> a -> b) -> c -> m [b]

    swapMaps :: c -> c -> m ()



--map :: ... -> m c, using updates

-- Should it create the new value or not
--lookupWithDefault :: (MapM c k a m) -> k -> c -> m


    --union :: c -> c -> m c
    --intersection :: c -> c -> m c
    --difference :: c -> c -> c
    --isSubset :: c -> c -> m Bool

    --insertWith :: (a -> a -> a) -> k -> a -> c -> m ()

    -- FIXME: create a new structure? or delete inplace? or have both?
    --mapWithKey :: (k -> a -> a) -> c -> m c
    --unionWith :: (a -> a -> a) -> c -> c -> m c
    --intersectionWith :: (a -> a -> a) -> c -> c -> m c
    --differenceWith :: (a -> a -> Maybe a) -> c -> c -> m c
    --isSubmapBy :: (a -> a -> Bool) -> c -> c -> m Bool

class MapF c k a | c -> k a where
    memberF :: k -> c -> Bool
    lookupF :: k -> c -> Maybe a
    fromListF :: [(k,a)] -> c
    toListF :: c -> [(k, a)]

instance (Ord k) => MapM (IORef (DM.Map k a)) k a IO where
    new = newIORef DM.empty
    delete k m = do
        modifyIORef m (\x -> DM.delete k x)
        return True
    member k m = do
        m' <- readIORef m
        return $ DM.member k m'
    lookup k m = do
        m' <- readIORef m
        return $ DM.lookup k m'
    insert k a m = modifyIORef m (\x -> DM.insert k a x)
    alter f k m = do
        m' <- readIORef m
        case DM.lookup k m' of
            Nothing -> case (f Nothing) of
                Nothing -> return Nothing
                Just y  -> (insert k y m) >> (return $ Just y)
            Just x  -> case (f (Just x)) of
                Nothing -> (delete k m)   >> (return Nothing)
                Just y  -> (insert k y m) >> (return $ Just y)
    fromList = newIORef . DM.fromList
    toList m = do
        m' <- readIORef m
        return $ DM.toList m'
    elems m = do
        m' <- readIORef m
        return $ DM.elems m'
    keys m = do
        m' <- readIORef m
        return $ DM.keys m'
    mapToList f m = do
        m' <- readIORef m
        let l = DM.toList m'
        let f' (k,a) = f k a
        return $ map f' l
    swapMaps x y = do
        x' <- readIORef x
        y' <- readIORef y
        writeIORef x y'
        writeIORef y x'

instance MapM (HT.HashTable String a) String a IO where
    new = HT.new (==) HT.hashString
    delete k m = (HT.delete m k) >> (return True)
    member k m = do
        x <- HT.lookup m k
        return $ case x of
            Nothing -> False
            Just _  -> True
    lookup = flip HT.lookup
    insert k a m = HT.insert m k a
    alter f k m = do
        x <- HT.lookup m k
        case x of
            Nothing -> case (f Nothing) of
                Nothing -> return Nothing
                Just y  -> (HT.insert m k y) >> (return $ Just y)
            Just y  -> case (f $ Just y) of
                Nothing -> (HT.delete m k)   >> (return Nothing)
                Just z  -> (HT.insert m k z) >> (return $ Just z)
    fromList = HT.fromList HT.hashString
    toList = HT.toList
    elems = (fmap (map snd)) . HT.toList
    keys  = (fmap (map fst)) . HT.toList
    mapToList f = (fmap (map f')) . HT.toList
        where f' (a,b) = f a b
    swapMaps x y = do
        x' <- HT.toList x
        y' <- HT.toList y
        mapM_ (\(a,_) -> HT.delete x a) x'
        mapM_ (\(a,_) -> HT.delete y a) y'
        mapM_ (\(a,b) -> HT.insert x a b) y'
        mapM_ (\(a,b) -> HT.insert y a b) x'

instance MapM (HT.HashTable Int a) Int a IO where
    new = HT.new (==) HT.hashInt
    delete k m = (HT.delete m k) >> (return True)
    member k m = do
        x <- HT.lookup m k
        return $ case x of
            Nothing -> False
            Just _  -> True
    lookup = flip HT.lookup
    insert k a m = HT.insert m k a
    alter f k m = do
        x <- HT.lookup m k
        case x of
            Nothing -> case (f Nothing) of
                Nothing -> return Nothing
                Just y  -> (HT.insert m k y) >> (return $ Just y)
            Just a  -> case (f $ Just a) of
                Nothing -> (HT.delete m k)   >> (return Nothing)
                Just y  -> (HT.insert m k y) >> (return $ Just y)
    fromList = HT.fromList HT.hashInt
    toList = HT.toList
    elems = (fmap (map snd)) . HT.toList
    keys  = (fmap (map fst)) . HT.toList
    mapToList f = (fmap (map f')) . HT.toList
        where f' (a,b) = f a b
    swapMaps x y = do
        x' <- HT.toList x
        y' <- HT.toList y
        mapM_ (\(a,_) -> HT.delete x a) x'
        mapM_ (\(a,_) -> HT.delete y a) y'
        mapM_ (\(a,b) -> HT.insert x a b) y'
        mapM_ (\(a,b) -> HT.insert y a b) x'
