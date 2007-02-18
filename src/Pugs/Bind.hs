{-# OPTIONS_GHC -fglasgow-exts -fallow-overlapping-instances #-}

{-|
    Parameter binding.

>   A star was bound upon her brows,
>   A light was on her hair
>   As sun upon the golden boughs
>   In Lorien the fair...
-}

module Pugs.Bind (
    bindParams, bindSomeParams,
) where
import Pugs.Internals
import Pugs.AST
import Pugs.Types

{-|
Contains either a valid value of @a@ (@Right@), or a @String@ error
message (@Left@).
-}
type MaybeError a = Either String a

{-|
Match up named arguments with named parameters, producing a list of new
bindings, and lists of remaining unbound args and params.
-}
bindNames :: [Exp] -- ^ List of argument expressions to be bound
          -> [Param] -- ^ List of parameters to try binding; includes both
                     --     named params and positional params
          -> (Bindings, [Exp], [Param]) -- ^ Bindings made;
                                        --   remaining (unbound) named args;
                                        --   remaining (positional) params
bindNames exps prms = (bound, exps', prms')
    where
    prms' = prms \\ (map fst bound)
    (bound, exps') = foldr doBindNamed ([], []) (map unwrapNamedArg exps)
    doBindNamed (name, exp) (bound, exps) = case foundParam of
        Just prm -> ( ((prm, exp) : bound), exps )
        _        -> ( bound, (Syn "named" [Val (VStr $ cast name), exp]:exps) )
        where
        foundParam = find ((== name) . v_name . paramName) prms

emptyHashExp :: Exp
emptyHashExp  = Val $ VList [] -- VHash $ vCast $ VList []

emptyArrayExp :: Exp
emptyArrayExp = Val $ VList [] -- VArray $ vCast $ VList []

{-|
Create a binding from the slurpy hash parameter (e.g. @\*%_@) to a hash
containing all the remaining named arguments. If multiple slurpy hashes
are given, only the first gets the arguments--the rest get an empty hash.
Used by 'bindSomeParams'.
-}
bindHash :: [Exp]   -- ^ Named arguments (pair expressions) that were not
                    --     consumed by explicit named parameters
         -> [Param] -- ^ List of slurpy hash parameters
         -> MaybeError Bindings
bindHash [] []          = return []
bindHash [] [p]         = return [ (p, emptyHashExp) ]
bindHash (v:_) []       = fail $ "Named argument found where no matched parameter expected: " ++ show (unwrapNamedArg v)
bindHash vs (p:ps@(_:_))= do
    first <- (bindHash vs [p])
    return $ first ++ (ps `zip` repeat emptyHashExp)
bindHash vs [p]         = return [ (p, Syn "\\{}" [Syn "," vs]) ] -- XXX cast to Hash

{-|
Create bindings from the slurpy scalar and array parameters to the remaining
positional arguments. The first slurpy array param gets all of the remaining
args; subsequent slurpy array params get an empty array. Slurpy scalars may
not appear after slurpy array params.

Returns the bindings performed, and the sub's new 'SlurpLimit'.

Mostly uses 'doBindArray' to do its dirty work. Used by 'bindSomeParams'.

>[12:16] <scook0> autrijus: At the moment, if you call a sub that has multiple slurpy arrays, 
>                   Pugs deliberately binds the first one normally, and makes all the rest empty
>[12:17] <scook0> Is this proper behaviour, or is it just a quirk of the current implementation?
>[12:17] <autrijus> no, that's specced.
>[12:17] <autrijus> i.e. correct
-}
bindArray :: [Exp]      -- ^ List of slurpable argument expressions
          -> [Param]    -- ^ List of all slurpy positional params (scalar and array)
          -> SlurpLimit -- ^ The sub's current 'SlurpLimit'
          -> MaybeError (Bindings, SlurpLimit)
bindArray vs ps oldLimit = do
    let exp = Ann (Cxt cxtSlurpyAny) (Syn "," vs)
    case foldM (doBindArray exp) ([], 0) prms of
        Left errMsg      -> fail errMsg
        Right (bound, n) -> do
            let newLimit = case prms of
                    ((_, SArray):_) -> oldLimit
                    ((_, SArrayMulti):_) -> oldLimit
                    _    | n > 0 -> (n, exp) : oldLimit
                    _            -> oldLimit
            return (reverse bound, newLimit)
    where
    prms = map (\p -> (p, v_sigil $ paramName p)) ps 

{-|
Construct an expression representing an infinite slice of the given
array expression, beginning at element /n/ (i.e. @\@array\[\$n...\]@).

Used by 'doBindArray' to bind a slurpy array parameter to the rest of
the slurpable arguments.
-}
doSlice :: Exp -- ^ The array expression to slice
        -> VInt -- ^ Index of the first element in the resulting slice (/n/)
        -> Exp 
doSlice v n = Syn "[...]" [v, Val $ VInt n]

-- XXX - somehow force failure
{-|
Construct an expression representing element /n/ in the given array
expression (i.e. @\@array\[\$n\]@).

Used by 'doBindArray' to bind a particular slurpy scalar parameter to one of 
the slurpable arguments.
-}
doIndex :: Exp -> VInt -> Exp
doIndex v n = Syn "[]" [Syn "val" [v], Val $ VInt n]

doBindArray :: Exp -> (Bindings, VInt) -> (Param, VarSigil) -> MaybeError (Bindings, VInt)
doBindArray _ (xs, -1) (p, SArray) = return (((p, emptyArrayExp):xs), -1)
doBindArray _ (_, -1)  (p, _) = fail $ "Slurpy array followed by slurpy scalar: " ++ show p
doBindArray v (xs, n)  (p, SArray) = return (((p, doSlice v n):xs), -1)
doBindArray v (xs, n)  (p, _) = case v of
    (Syn "," [])    -> fail $ "Insufficient arguments for slurpy scalar"
    _               -> return (((p, doIndex v n):xs), n+1)
-- doBindArray _ (_, _)  (_, x) = internalError $ "doBindArray: unexpected char: " ++ (show x)


isNamedArg :: Exp -> Bool
isNamedArg (Syn "named" [(Val (VStr _)), _]) = True
isNamedArg (Syn "named" [Ann _ (Val (VStr _)), _]) = True -- should the Ann reach here?
isNamedArg arg@(Syn "named" _)               = error $ "malformed named arg: " ++ show arg
isNamedArg _                                 = False

unwrapNamedArg :: Exp -> (ID, Exp)
unwrapNamedArg (Syn "named" [(Val (VStr key)), val]) = (cast key, val)
unwrapNamedArg (Syn "named" [Ann _ (Val (VStr key)), val]) = (cast key, val) -- (see comment in isNamedArg)
unwrapNamedArg x = error $ "not a well-formed named arg: " ++ show x

{-|
Bind parameters to a callable, then verify that the binding is complete
(i.e. all mandatory params are bound; all unspecified params have default
bindings).

Uses 'bindSomeParams' to perform the initial binding, then uses
'finalizeBindings' to check all required params and give default values to
any unbound optional ones. Once this is complete, /everything/ should be
bound.

Note that while 'bindParams' produces values /representing/ the bindings from
params to args, it does not actually introduce any symbols--that occurs later
on in the call process.
-}
bindParams :: VCode       -- ^ A code object to perform bindings on
           -> (Maybe Exp) -- ^ (Optional) explicit invocant
           -> [Exp]       -- ^ List of arguments (actual params) to bind
           -> MaybeError VCode -- ^ Returns either a new 'VCode' with all the
                               --     bindings in place, or an error message
-- Special case: 'close $fh' should be bound as '$fh.close'
bindParams sub Nothing [inv]
    | (p:_) <- subParams sub, isInvocant p
    = bindParams sub (Just inv) []
bindParams sub invExp argsExp = do
    case bindSomeParams sub invExp argsExp of
        Left errMsg -> Left errMsg
        Right boundSub -> finalizeBindings boundSub

{-|
Verify that all invocants and required parameters are bound, and give default
values to any unbound optional parameters.
-}
finalizeBindings :: VCode -> MaybeError VCode
finalizeBindings sub = do
    let params    = subParams sub
        bindings  = subBindings sub
        boundInvs = filter (isInvocant . fst) bindings    -- bound invocants
        invocants = takeWhile isInvocant params           -- expected invocants

    -- Check that we have enough invocants bound
    when (not . null $ invocants) $ do
        let missing  = show (length invocants)
            supplied = show (length boundInvs)
        fail $ concat
            [ "Missing invocant parameters in '"
            , cast (subName sub)
            , "': "
            , supplied, " received, "
            , missing,  " missing"
            ]
            
    let (boundOpt, boundReq) = partition (isOptional . fst) bindings -- bound params which are required
        (optPrms, reqPrms)   = partition isOptional params -- all params which are required, and all params which are opt

    -- Check length of required parameters
    when (length boundReq < length reqPrms) $ do
        fail $ "Missing required parameters: "
            ++ unwords (map (cast . paramName) $ reqPrms \\ map fst boundReq)

    let unboundOptPrms = optPrms \\ (map fst boundOpt) -- unbound optParams are allPrms - boundPrms
        optPrmsDefaults = [
            Syn "param-default" [paramDefault prm, Val (VCode sub)]
            | prm <- unboundOptPrms
            ] -- get a list of default values
        boundDefOpts = unboundOptPrms `zip` optPrmsDefaults -- turn into exprs, so that +$y = $x will work
        
    return sub {
        subBindings = ((subBindings sub) ++ boundDefOpts)
    }

{-|
Take a code object and lists of invocants and arguments, and produce (if
possible) a new 'VCode' value representing the same code object, with as many
parameters bound as possible (using the given invocants and args).
-}
bindSomeParams :: VCode       -- ^ Code object to perform bindings on
               -> (Maybe Exp) -- ^ Explicit invocant expression
               -> [Exp]       -- ^ List of argument expressions
               -> MaybeError VCode -- ^ A new 'VCode' structure, augmented
                                   --     with the new bindings
bindSomeParams sub invExp argsExp = do
    let params     = subParams sub
        bindings   = subBindings sub
        slurpLimit = subSlurpLimit sub
        (invPrms, argPrms) = span isInvocant params
        (givenInvs, givenArgs) = if null invPrms
            then ([], (maybeToList invExp++argsExp))
            else (maybeToList invExp, argsExp)

    let boundInv                = invPrms `zip` givenInvs -- invocants are just bound, params to given
        (namedArgs, posArgs)    = partition isNamedArg givenArgs
        (boundNamed, namedForSlurp, allPosPrms) = bindNames namedArgs argPrms -- bind pair args to params. namedForSlup = leftover pair args
        (itemPrms, slurpyPrms)  = break isSlurpy allPosPrms -- split any prms not yet bound, into regular and slurpy. allPosPrms = not bound by named
        posPrms                 = filter (not . isNamed) itemPrms
        boundPos                = posPrms `zip` posArgs -- bind all the unbound params in positional order
        posForSlurp             = drop (length posPrms) posArgs -- and whatever's left will be slurped

    -- Bind slurpy arrays and hashes
    let (slurpNamed, slurpPos) = partition ((SHash ==) . v_sigil . paramName) slurpyPrms
        -- defaultPos      = if hasDefaultArray  then [] else [defaultArrayParam]
        defaultScalar   = if hasDefaultScalar then [] else [] -- XXX - fetch from *@_
        hasDefaultScalar= isJust (find ((varTopic ==) . paramName) params)
        
    boundHash   <- bindHash namedForSlurp slurpNamed -- put leftover named args in %_
    (boundArray, newSlurpLimit) <- bindArray posForSlurp slurpPos slurpLimit
    boundScalar <- return $ defaultScalar `zip` (givenInvs ++ givenArgs) -- put, uh, something in $_

    let newParams = params \\ (map fst newBindings);
        newBindings = concat
            [ bindings      -- Existing bindings
            , boundInv      -- Newly bound invocants
            , boundNamed    -- ...nameds
            , boundPos      -- ...positional
            , boundHash     -- ...*%hash
            , boundArray    -- ...*@array
            , boundScalar   -- ...*$scalar
            ]
    
    return sub
        { subBindings   = newBindings
        , subParams     = newParams
        , subSlurpLimit = newSlurpLimit
        }

