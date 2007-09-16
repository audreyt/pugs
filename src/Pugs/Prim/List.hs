{-# OPTIONS_GHC -fglasgow-exts -fallow-overlapping-instances #-}

module Pugs.Prim.List (
    op0Zip, op0Cross, op0Cat, op0Each, op0RoundRobin, op1Pick, op1Sum,
    op1Min, op1Max, op1Uniq,
    op2Pick,
    op2ReduceL, op2Reduce, op2Grep, op2First, op2Map, op2Join,
    sortByM,
    op1HyperPrefix, op1HyperPostfix, op2Hyper,
) where
import Pugs.Internals
import Pugs.AST
import Pugs.Types
import Pugs.Monads
import qualified Data.Set as Set

import Pugs.Prim.Numeric
import Pugs.Prim.Lifts

op0Cat :: [Val] -> Eval Val
op0Cat = fmap (VList . concat) . mapM fromVal

op0Zip :: [Val] -> Eval Val
op0Zip = fmap (VList . fmap VList . op0Zip') . mapM fromVal

op0Each :: [Val] -> Eval Val
op0Each = fmap (VList . concat . op0Zip') . mapM fromVal

op0RoundRobin :: [Val] -> Eval Val
op0RoundRobin = fmap (VList . fst . partition defined . concat . op0Zip') . mapM fromVal

op0Zip' :: [[Val]] -> [[Val]]
op0Zip' lists | any null lists = []
op0Zip' []    = []
op0Zip' lists = (map zipFirst lists):(op0Zip' (map zipRest lists))
    where
    zipFirst []     = undef
    zipFirst (x:_)  = x
    zipRest  []     = []
    zipRest  (_:xs) = xs

op0Cross :: [Val] -> Eval Val
op0Cross = fmap (VList . fmap VList . op0Cross') . mapM fromVal

op0Cross' :: [[Val]] -> [[Val]]
op0Cross' [] = [[]]
op0Cross' (xs:yss) = do
    x <- xs
    ys <- op0Cross' yss
    return (x:ys)

op1Pick :: Val -> Eval Val
op1Pick (VRef r) = op1Pick =<< readRef r
op1Pick (VList []) = return undef
op1Pick (VList vs) = do
    rand <- io $ randomRIO (0, length vs - 1)
    return $ vs !! rand
op1Pick (VJunc (MkJunc _ _ set)) | Set.null set = return undef
op1Pick (VJunc (MkJunc JAny _ set)) = do -- pick mainly works on 'any'
    rand <- io $ randomRIO (0 :: Int, (Set.size set) - 1)
    return $ (Set.elems set) !! rand
op1Pick (VJunc (MkJunc JNone _ _)) = return undef
op1Pick (VJunc (MkJunc JAll _ set)) =
    if (Set.size $ set) == 1 then return $ head $ Set.elems set
    else return undef
op1Pick (VJunc (MkJunc JOne dups set)) =
    if (Set.size $ set) == 1 && (Set.size $ dups) == 0
    then return $ head $ Set.elems set
    else return undef
op1Pick v = die "pick not defined" v

shuffleN :: Int -> [a] -> Eval [a]
shuffleN _ [] = return []
shuffleN 0 _  = return []
shuffleN n xs = do
    -- pick the first element
    first <- io $ randomRIO (0 :: Int, length xs - 1)
    rest <- shuffleN (n-1) $ take first xs ++ drop (first+1) xs
    return $ head (drop first xs) : rest

op2Pick :: Val -> Val -> Eval Val
op2Pick (VRef r) num = do
    ref <- readRef r
    op2Pick ref num
op2Pick l@(VList xs) (VNum n)
    | n == 1/0  = op2Pick l (VInt . toInteger $ length xs)
    | otherwise = op2Pick l (VInt $ floor n)
op2Pick (VList xs) (VInt num) = do
    shuffled <- shuffleN (fromInteger num) xs
    return $ VList shuffled
op2Pick r _ = die "pick not defined" r

op1Sum :: Val -> Eval Val
op1Sum list = do
    vals <- fromVal list
    foldM (op2Numeric (+)) undef vals

op1Min :: Val -> Eval Val
op1Min v = op1MinMax not v

op1Max :: Val -> Eval Val
op1Max v = op1MinMax id v

-- min_or_max is a function which negates truth/falsehood.
-- This is necessary as op1MinMax should cope with min() as well as max().
op1MinMax :: (Bool -> Bool) -> Val -> Eval Val
op1MinMax min_or_max v = do
    -- We want to have a real Haskell list
    args    <- fromVal v
    -- Extract our comparator sub, or Nothing if none was specified
    (valList, cmp) <- case args of
        (v:vs) -> do
            ifValTypeIsa v "Code"
                (return (vs, Just v))
                (ifValTypeIsa (last args) "Code"
                    (return (init args, Just $ last args))
                    (return (args, Nothing)))
        _  -> return (args, Nothing)
    -- Now let our helper function do the rest
    op1MinMax' min_or_max cmp valList
    where
    op1MinMax' :: (Bool -> Bool) -> (Maybe Val) -> [Val] -> Eval Val
    -- The min or max of an empty list is undef.
    op1MinMax' _ _ [] = return undef
    -- We have to supply our own comparator...
    op1MinMax' _ Nothing valList = foldM default_compare (head valList) (tail valList)
    -- or use the one of the user
    op1MinMax' min_or_max (Just subVal) valList = do
          sub <- fromVal subVal
          evl <- asks envEval
          -- Here we execute the user's sub
          foldM (\a b -> do
              rv  <- local (\e -> e{ envContext = cxtItem "Int" }) $ do
                  evl (App (Val sub) Nothing [Val a, Val b])
              int <- fromVal rv
              -- If the return value from the sub was
              --   -1 ==> a < b
              --    0 ==> a == b
              --   +1 ==> a > b
              -- We call min_or_max so we can work for both min() and max().
              return $ if min_or_max (int > (0::VInt)) then a else b) (head valList) (tail valList)
    -- This is the default comparision function, which will be used if the user
    -- hasn't specified a own comparision function.
    default_compare a b = do
        a' <- vCastRat a
        b' <- vCastRat b
        let cmp = if a' < b' then (-1) else if a' == b' then 0 else 1
        return $ if min_or_max (cmp > (0::VInt)) then a else b

op1Uniq :: Val -> Eval Val
op1Uniq v = do
    -- We want to have a real Haskell list
    args    <- fromVal v
    -- Extract our comparator sub, or Nothing if none was specified
    (valList, cmp) <- case args of
        (v:vs) -> do
            ifValTypeIsa v "Code"
                (return (vs, Just v))
                (ifValTypeIsa (last args) "Code"
                    (return (init args, Just $ last args))
                    (return (args, Nothing)))
        _  -> return (args, Nothing)
    -- After this parameter unpacking, we begin doing the real work.
    op1Uniq' cmp valList
    where
    op1Uniq' :: (Maybe Val) -> [Val] -> Eval Val
    -- If the user didn't specify an own comparasion sub, we can simply use
    -- Haskell's nub.
    op1Uniq' Nothing valList = return . VList $ nub valList
    -- Else, we have to write our own nubByM and use that.
    op1Uniq' (Just subVal) valList = do
        sub <- fromVal subVal
        evl <- asks envEval
        -- Here we execute the user's sub
        result <- nubByM (\a b -> do
            rv  <- local (\e -> e{ envContext = cxtItem "Bool" }) $ do
                evl (App (Val sub) Nothing [Val a, Val b])
            -- The sub returns either true or false.
            bool <- fromVal rv
            return . VBool $ bool) valList
        return . VList $ result
    -- This is the same as nubBy, only lifted into the Eval monad
    nubByM :: (Val -> Val -> Eval Val) -> [Val] -> Eval [Val]
    nubByM eq l = nubByM' l []
      where
        nubByM' [] _      = return []
        nubByM' (y:ys) xs = do
            -- elemByM returns a Val, but we need a VBool, so we have to use fromVal.
            cond <- fromVal =<< elemByM eq y xs
            if cond then nubByM' ys xs else do
                result <- nubByM' ys (y:xs)
                return (y:result)
        elemByM :: (Val -> Val -> Eval Val) -> Val -> [Val] -> Eval Val
        elemByM _  _ []     = return . VBool $ False
        elemByM eq y (x:xs) = do
            cond <- fromVal =<< eq x y
            -- Same here (we need a VBool, not a Var).
            if cond then return . VBool $ cond else elemByM eq y xs

op2ReduceL :: Bool -> Val -> Val -> Eval Val
op2ReduceL keep sub@(VCode _) list = op2ReduceL keep list sub
op2ReduceL keep list sub = do
    code <- fromVal sub
    op2Reduce keep list $ VCode code{ subAssoc = A_left }

op2Reduce :: Bool -> Val -> Val -> Eval Val
op2Reduce keep sub@VCode{} list = op2Reduce keep list sub
op2Reduce keep list sub = do
    code <- fromVal sub
    args <- fromVal list
    if null args then identityVal (subName code) else do
    -- cxt  <- asks envContext
    let arity = length $ subParams code
        (reduceM, reduceMn) = if keep then (scanM, scanMn) else (foldM, foldMn)
    if subAssoc code == A_list
        then asks envEval >>= \evl -> evl $ App (Val $ VCode code{ subParams = length args `replicate` head (subParams code)}) Nothing (map Val args)
        else do
            when (arity < 2) $ fail "Cannot reduce() using a unary or nullary function."
            -- n is the number of *additional* arguments to be passed to the sub.
            -- Ex.: reduce { $^a + $^b       }, ...   # n = 1
            -- Ex.: reduce { $^a + $^b + $^c }, ...   # n = 2
            let n = arity - 1
            -- Break on empty list.
            let doFold xs = do
                evl <- asks envEval
                local (\e -> e{ envContext = cxtItemAny }) $ do
                    evl (App (Val sub) Nothing (map Val xs))
            case subAssoc code of
                A_right -> do
                    let args' = reverse args
                    reduceMn args' n (doFold . reverse)
                A_chain -> if arity /= 2            -- FIXME: incorrect for scans
                    then fail
                        "When reducing using a chain-associative sub,\nthe sub must take exactly two arguments."
                    else catchT $ \esc -> do
                        let doFold' x y = do
                            val <- doFold [x, y]
                            case val of
                                VBool False -> esc val
                                _           -> return y
                        reduceM doFold' (head args) (tail args)
                        return $ VBool True
                A_non   -> fail $ "Cannot reduce over non-associativity"
                _       -> reduceMn args n doFold -- "left", "pre"
    where
    -- This is a generalized foldM.
    -- It takes an input list (from which the first elem will be used as start
    -- value), the number of additional arguments, and a reducing function.
    foldMn :: [Val] -> Int -> ([Val] -> Eval Val) -> Eval Val
    foldMn list n f = foldM (\a b -> f (a:b)) (head list) $ list2LoL n $ drop 1 list
    -- Scan version of foldMn.
    scanMn :: [Val] -> Int -> ([Val] -> Eval Val) -> Eval Val
    scanMn list n f = scanM (\a b -> f (a:b)) (head list) $ list2LoL n $ drop 1 list
    -- The Prelude defines foldM but not scanM.
    scanM :: (Val -> b -> Eval Val) -> Val -> [b] -> Eval Val
    scanM f q ls = case ls of
        []   -> return $ VList [q]
        x:xs -> do
            fqx  <- f q x
            rest <- fromVal =<< scanM f fqx xs
            return $ VList (q:rest)
    identityVal name = case nameStr of
        "**"    -> _1
        "*"     -> _1
        "/"     -> _fail
        "%"     -> _fail
        "x"     -> _fail
        "xx"    -> _fail
        "+&"    -> _neg1
        "+<"    -> _fail
        "+>"    -> _fail
        "~&"    -> _fail
        "~<"    -> _fail
        "~>"    -> _fail
        "+"     -> _0
        "-"     -> _0
        "~"     -> _''
        "+|"    -> _0
        "+^"    -> _0
        "~|"    -> _''
        "~^"    -> _''
        "&"     -> _junc JAll
        "|"     -> _junc JAny
        "^"     -> _junc JOne
        "!="    -> _false
        "=="    -> _true
        "<"     -> _true
        "<="    -> _true
        ">"     -> _true
        ">="    -> _true
        "~~"    -> _true
        "eq"    -> _true
        "ne"    -> _false
        "lt"    -> _true
        "le"    -> _true
        "gt"    -> _true
        "ge"    -> _true
        "=:="   -> _true
        "==="   -> _true
        "eqv"   -> _true
        "&&"    -> _true
        "||"    -> _false
        "^^"    -> _false
        ","     -> _list
        "Z"     -> _list
        "X"     -> _list
        ('!':_) -> _false
        _           -> _undef
        where
        nameStr = cast name
        _0      = return (VInt 0)
        _1      = return (VInt 1)
        _undef  = return undef
        _false  = return (VBool False)
        _true   = return (VBool True)
        _list   = return (VList [])
        _neg1   = return (VInt $ -1)
        _junc   = \jtyp -> return . VJunc $ MkJunc jtyp Set.empty Set.empty
        _''     = return (VStr "")
        _fail   = fail $ "reduce is nonsensical for " ++ cast name

op2Grep :: Val -> Val -> Eval Val
op2Grep sub@(VCode _) list = op2Grep list sub
op2Grep list sub = do
    args <- fromVal list
    vals <- (`filterM` args) $ \x -> do
        evl <- asks envEval
        rv  <- local (\e -> e{ envContext = cxtItem "Bool" }) $ do
            evl (App (Val sub) Nothing [Val x])
        fromVal rv
    return $ VList vals

op2First :: Val -> Val -> Eval Val
op2First sub@(VCode _) list = op2First list sub
op2First list sub = do
  (VList vals) <- (op2Grep list sub)
  if not (null vals)
    then return $ (vals !! 0)
    else return $ undef

op2Map :: Val -> Val -> Eval Val
op2Map sub@(VCode _) list = op2Map list sub
op2Map list sub = do
    args  <- fromVal list
    arity <- fmap (length . subParams) (fromVal sub)
    evl   <- asks envEval
    vals  <- mapMn args arity $ \x -> do
        rv  <- local (\e -> e{ envContext = cxtSlurpyAny }) $ do
            evl (App (Val sub) Nothing (map Val x))
        fromVal rv
    return $ VList vals
    where
    -- Takes a list, an arity, and a function.
    mapMn           :: [Val] -> Int -> ([Val] -> Eval [Val]) -> Eval [Val]
    mapMn list 0 f   = fmap concat (mapM (const $ f []) list)
    mapMn list n f   = mapMn' (list2LoL n list) f
    -- Takes a LoL and a function and applies the function to the inputlist.
    mapMn'          :: [[Val]] -> ([Val] -> Eval [Val]) -> Eval [Val]
    mapMn' (x:xs) f  = liftM2 (++) (f x) (mapMn' xs f)
    mapMn' []     _  = return []

{-|
Takes an int and a list and returns a LoL.
Ex.:

> list2LoL 3 [1,2,3,4,5] = [[1,2,3],[4,5,undef]]
-}
list2LoL :: Int -> [Val] -> [[Val]]
list2LoL n list
    | n == 0           = fail "Cannot map() using a nullary function."
    -- If the list has exactly n elements, we've finished our work.
    | length list == n = [list]
    -- If the list is empty, we're done, too.
    | length list == 0 = []
    -- But if the list contains more elems than we need, we process the
    -- first n ones and the rest separately.
    | length list  > n = (list2LoL n $ take n list) ++ (list2LoL n $ drop n list)
    -- And if the list contains less elems than we need, we pad with undefs.
    | length list  < n = list2LoL n $ list ++ [undef :: Val]
    | otherwise        = fail "Invalid arguments to internal function list2LoL passed."

op2Join :: Val -> Val -> Eval Val
-- op2Join (VList [x@(VRef _)]) y = op2Join x y
op2Join x y = do
    (strVal, valList) <- ifValTypeIsa x "Scalar"
        (return (x, (VRef (arrayRef (listVal y)))))
        (return (y, x))
    str     <- fromVal strVal
    ref     <- fromVal valList
    list    <- readRef ref
    strList <- fromVals list
    return . VStr . concat . intersperse str $ strList

sortByM :: (Val -> Val -> Eval Bool) -> [Val] -> Eval [Val]
sortByM _ []  = return []
sortByM _ [x] = return [x]
sortByM f xs  = do
    let (as, bs) = splitAt (length xs `quot` 2) xs
    aSorted <- sortByM f as
    bSorted <- sortByM f bs
    doMerge f aSorted bSorted
    where
    doMerge :: (Val -> Val -> Eval Bool) -> [Val] -> [Val] -> Eval [Val]
    doMerge _ [] ys = return ys
    doMerge _ xs [] = return xs
    doMerge f (x:xs) (y:ys) = do
        isLessOrEqual <- f x y
        if isLessOrEqual
            then do
                rest <- doMerge f xs (y:ys)
                return (x:rest)
            else do
                rest <- doMerge f (x:xs) ys
                return (y:rest)

op1HyperPrefix :: VCode -> Val -> Eval Val
op1HyperPrefix sub (VRef ref) = do
    x <- readRef ref
    op1HyperPrefix sub x
op1HyperPrefix sub x
    | VList x' <- x
    = fmap VList $ hyperList x'
    | otherwise
    = fail "Hyper OP only works on lists"
    where
    doHyper x
        | VRef x' <- x
        = doHyper =<< readRef x'
        | VList{} <- x
        = op1HyperPrefix sub x
        | otherwise
        = enterEvalContext cxtItemAny $ App (Val $ VCode sub) Nothing [Val x]
    hyperList xs = do
        env <- ask
        io $ do
            mvs <- forM xs $ \x -> do
                mv  <- newEmptyMVar
                forkIO $ do
                    val <- runEvalIO env (doHyper x)
                    putMVar mv val
                return mv
            mapM takeMVar mvs

op1HyperPostfix :: VCode -> Val -> Eval Val
op1HyperPostfix = op1HyperPrefix

op2Hyper :: VCode -> Val -> Val -> Eval Val
op2Hyper sub (VRef ref) y = do
    x <- readRef ref
    op2Hyper sub x y
op2Hyper sub x (VRef ref) = do
    y <- readRef ref
    op2Hyper sub x y
op2Hyper sub x y
    | VList x' <- x, VList y' <- y
    = fmap VList $ hyperLists x' y'
    | VList x' <- x
    = fmap VList $ mapM ((flip doHyper) y) x'
    | VList y' <- y
    = fmap VList $ mapM (doHyper x) y'
    | otherwise
    = fail "Hyper OP only works on lists"
    where
    doHyper x y 
        | VRef x' <- x, VRef y' <- y
        = join $ liftM2 doHyper (readRef x') (readRef y')
        | VRef x' <- x
        = (flip doHyper $ y) =<< readRef x'
        | VRef y' <- y
        = doHyper x =<< readRef y'
        | VList{} <- x
        = op2Hyper sub x y
        | VList{} <- y
        = op2Hyper sub x y
        | otherwise
        = enterEvalContext cxtItemAny $ App (Val $ VCode sub) Nothing [Val x, Val y]
    hyperLists xs ys = do
        env <- ask
        io $ do
            mvs <- doHyperLists env xs ys
            mapM takeMVar mvs
    doHyperLists _ [] [] = return []
    doHyperLists _ xs [] = mapM newMVar xs
    doHyperLists _ [] ys = mapM newMVar ys
    doHyperLists env (x:xs) (y:ys) = do
        mv  <- newEmptyMVar
        forkIO $ do
            val <- runEvalIO env $ doHyper x y
            putMVar mv val
        mvs <- doHyperLists env xs ys
        return (mv:mvs)
