{-# OPTIONS_GHC -fglasgow-exts -fno-warn-orphans #-}

module Pugs.Prim.Keyed (
  -- keyed values (Val)
  pairsFromVal, keysFromVal, valuesFromVal,

  -- keyed references (VRef)
  pairsFromRef, keysFromRef, valuesFromRef,
  existsFromRef, deleteFromRef,
) where
import Pugs.Internals
import Pugs.AST
import Pugs.Types
import qualified Data.Map as Map
import qualified Data.Set as Set

pairsFromVal :: Val -> Eval [Val]
pairsFromVal VUndef = return []
pairsFromVal (PerlSV sv) = do
    keys    <- hash_fetchKeys sv
    return $ VList (map castV keys)
    elems   <- mapM (hash_fetchElem sv) keys
    return $ map (VRef . MkRef . IPair) (keys `zip` elems)
pairsFromVal (VRef ref) = pairsFromRef ref
pairsFromVal v = fallback pairsFromVal v

fallback :: (Val -> Eval b) -> Val -> Eval b
fallback f v@(VV vv) = do
    val <- vvToVal vv
    case val of
        VV{} -> die "Not a keyed object" v
        _    -> f val
fallback _ v = die "Not a keyed value" v

keysFromVal :: Val -> Eval Val
keysFromVal VUndef = return $ VList []
keysFromVal (PerlSV sv) = do
    keys    <- hash_fetchKeys sv
    return $ VList (map castV keys)
keysFromVal (VList vs) = return . VList $ map VInt [0 .. (genericLength vs) - 1]
keysFromVal (VRef ref) = do
    vals <- keysFromRef ref
    return $ VList vals
keysFromVal v = fallback keysFromVal v

valuesFromVal :: Val -> Eval Val
valuesFromVal VUndef = return $ VList []
valuesFromVal (VJunc j) = return . VList . Set.elems $ juncSet j
valuesFromVal v@(VList _) = return v
valuesFromVal (VRef ref) = do
    vals <- valuesFromRef ref
    return $ VList vals
valuesFromVal (PerlSV sv) = do
    pairs <- hash_fetch sv
    return . VList $ Map.elems pairs
valuesFromVal v = fallback valuesFromVal v

-- XXX These bulks of code below screams for refactoring

pairsFromRef :: VRef -> Eval [Val]
pairsFromRef r@(MkRef (IPair _)) = do
    return [VRef r]
pairsFromRef (MkRef (IHash hv)) = do
    keys    <- hash_fetchKeys hv
    elems   <- mapM (hash_fetchElem hv) keys
    return $ map (VRef . MkRef . IPair) (keys `zip` elems)
pairsFromRef (MkRef (IArray av)) = do
    vals    <- array_fetch av
    return $ map castV ((map VInt [0..]) `zip` vals)
pairsFromRef (MkRef (IScalar sv)) = do
    refVal  <- scalar_fetch' sv
    pairsFromVal refVal
pairsFromRef ref = die "Not a keyed reference" ref

keysFromRef :: VRef -> Eval [Val]
keysFromRef (MkRef (IPair pv)) = do
    key     <- pair_fetchKey pv
    return [key]
keysFromRef (MkRef (IHash hv)) = do
    keys    <- hash_fetchKeys hv
    return $ map castV keys
keysFromRef (MkRef (IArray av)) = do
    keys    <- array_fetchKeys av
    return $ map castV keys
keysFromRef (MkRef (IScalar sv)) = do
    refVal  <- scalar_fetch' sv
    if defined refVal
        then fromVal =<< keysFromVal refVal
        else return []
keysFromRef ref = die "Not a keyed reference" ref

valuesFromRef :: VRef -> Eval [Val]
valuesFromRef (MkRef (IPair pv)) = do
    val   <- pair_fetchVal pv
    return [val]
valuesFromRef (MkRef (IHash hv)) = do
    pairs <- hash_fetch hv
    return $ Map.elems pairs
valuesFromRef (MkRef (IArray av)) = array_fetch av
valuesFromRef (MkRef (IScalar sv)) = do
    refVal  <- scalar_fetch' sv
    if defined refVal
        then fromVal =<< valuesFromVal refVal
        else return []
valuesFromRef ref = die "Not a keyed reference" ref

existsFromRef :: VRef -> Val -> Eval VBool
existsFromRef (MkRef (IHash hv)) val = do
    idx     <- fromVal val
    hash_existsElem hv idx
existsFromRef (MkRef (IArray av)) val = do
    idx     <- fromVal val
    array_existsElem av idx
existsFromRef (MkRef (IScalar sv)) val = do
    refVal  <- scalar_fetch' sv
    case refVal of
        VRef ref    -> existsFromRef ref val
        VList _     -> (`existsFromRef` val) =<< fromVal refVal
        _           -> return False
existsFromRef ref _ = die "Not a keyed reference" ref

deleteFromRef :: VRef -> Val -> Eval Val
deleteFromRef (MkRef (IHash hv)) val = do
    idxs    <- fromVals val
    rv      <- forM idxs $ \idx -> do
        val <- hash_fetchVal hv idx
        hash_deleteElem hv idx
        return val
    return $ VList rv
deleteFromRef (MkRef (IArray av)) val = do
    idxs    <- fromVals val
    rv      <- forM idxs $ \idx -> do
        val <- array_fetchVal av idx
        array_deleteElem av idx
        return val
    return $ VList rv
deleteFromRef (MkRef (IScalar sv)) val = do
    refVal  <- scalar_fetch' sv
    case refVal of
        VRef ref    -> deleteFromRef ref val
        VList _     -> (`deleteFromRef` val) =<< fromVal refVal
        v           -> die "Argument is not a Hash or Array element or slice in delete" v
deleteFromRef ref _ = die "Argument is not a Hash or Array element or slice in delete" ref

