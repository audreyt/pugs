{-# OPTIONS_GHC -fglasgow-exts -fno-warn-orphans -fno-full-laziness -fno-cse -fallow-overlapping-instances #-}

{-|
    Primitive operators.

>   There hammer on the anvil smote,
>   There chisel clove, and graver wrote;
>   There forged was blade, and bound was hilt;
>   The delver mined, the mason built...
-}

module Pugs.Prim (
    primOp,
    primDecl,
    initSyms,
    op2ChainedList,
    op1Exit,

    -- used by Pugs.Compile.Haskell
    op0, op1, op2,

    -- used Pugs.Eval
    op1Return, op1Yield,
    foldParam, op2Hyper, op1HyperPrefix, op1HyperPostfix, retSeq, atomicEval
) where
import Pugs.Internals
import Pugs.Junc
import Pugs.AST
import Pugs.Types
import Pugs.Monads
import Pugs.Pretty
import Text.Printf
import Pugs.External
import Pugs.Embed
import Pugs.Eval.Var
import Pugs.Meta ()
import qualified Data.Map as Map
import qualified Data.Set as Set
import Data.IORef
import System.IO.Error (isEOFError)

import Pugs.Prim.Keyed
import Pugs.Prim.Yaml
import Pugs.Prim.Match
import Pugs.Prim.List
import Pugs.Prim.Numeric
import Pugs.Prim.Lifts
import Pugs.Prim.Eval
import Pugs.Prim.Code
import Pugs.Prim.Param
import qualified Data.IntSet as IntSet
import DrIFT.YAML
import GHC.Exts (unsafeCoerce#)
import GHC.Unicode
import qualified Data.HashTable as H
import Data.Time.LocalTime
import Data.Time.Calendar.OrdinalDate
import Data.Time.Calendar.MonthDay

constMacro :: Exp -> [Val] -> Eval Val
constMacro = const . expToEvalVal

-- |Implementation of 0-ary and variadic primitive operators and functions
-- (including list ops).
op0 :: String -> [Val] -> Eval Val
op0 "&"  = fmap opJuncAll . mapM fromVal
op0 "^"  = fmap opJuncOne . mapM fromVal
op0 "|"  = fmap opJuncAny . mapM fromVal
op0 "want"  = const $ fmap VStr (asks (maybe "Item" envWant . envCaller))
op0 "Bool::True"  = const . return $ VBool True
op0 "Bool::False" = const . return $ VBool False
op0 "True"  = constMacro . Val $ VBool True
op0 "False" = constMacro . Val $ VBool False
op0 "time"  = const $ do
    clkt <- guardIO getCurrentTime
    return $ VRat $ pugsTimeSpec clkt
op0 "times"  = const $ do
    ProcessTimes _ u s cu cs <- guardIO getProcessTimes
    return . VList $ map (castV . (% (clocksPerSecond :: VInt)) . toInteger . fromEnum)
        [u, s, cu, cs]
op0 "Z" = op0Zip
op0 "X" = op0Cross
    -- op0 "minmax" = op0Minmax
op0 "File::Spec::cwd" = const $ do
    cwd <- guardIO getCurrentDirectory
    return $ VStr cwd
op0 "File::Spec::tmpdir" = const $ do
    tmp <- guardIO getTemporaryDirectory
    return $ VStr tmp
op0 "Pugs::Internals::pi" = const $ return $ VNum pi
op0 "self"    = const $ expToEvalVal (_Var "$__SELF__")
op0 "say"     = const $ op1 "IO::say" (VHandle stdout)
op0 "print"   = const $ op1 "IO::print" (VHandle stdout)
op0 "return"  = const $ op1Return (retControl (ControlLeave (<= SubRoutine) 0 undef))
op0 "yield"   = const $ op1Yield (retControl (ControlLeave (<= SubRoutine) 0 undef))
op0 "leave"   = const $ retControl (ControlLeave (>= SubBlock) 0 undef)
op0 "take"    = const $ assertFrame FrameGather retEmpty
op0 "nothing" = const . return $ VBool True
op0 "Pugs::Safe::safe_getc"     = const . op1Getc $ VHandle stdin
op0 "Pugs::Safe::safe_readline" = const . op1Readline $ VHandle stdin
op0 "reverse" = const $ return (VList [])
op0 "chomp"   = const $ return (VList [])
op0 "fork"    = const $ opPerl5 "fork" []
op0 "defer"   = const $ do
    env <- ask
    if envAtomic env then guardSTM retry else fail "Cannot call &defer outside a contend block."
op0 other = const $ fail ("Unimplemented listOp: " ++ other)

-- |Implementation of unary primitive operators and functions
op1 :: String -> Val -> Eval Val
op1 "!"    = op1Cast (VBool . not)
op1 "WHICH" = \x -> do
    val <- fromVal x
    return $ case val of
        VObject o   -> castV . unObjectId $ objId o
        _           -> val
op1 "chop" = \x -> do
    str <- fromVal x
    return $ if null str
        then VStr str
        else VStr $ init str
op1 "Scalar::chomp" = \x -> do
    str <- fromVal x
    return $ op1Chomp str
op1 "Str::split" = op1Cast (castV . words)
op1 "lc"         = op1Cast (VStr . map toLower)
op1 "lcfirst"    = op1StrFirst toLower
op1 "uc"         = op1Cast (VStr . map toUpper)
op1 "ucfirst"    = op1StrFirst toUpper
op1 "capitalize" = op1Cast $ VStr . (mapEachWord capitalizeWord)
  where
    mapEachWord _ [] = []
    mapEachWord f str@(c:cs)
        | isSpace c = c:(mapEachWord f cs)
        | otherwise = f word ++ mapEachWord f rest
          where (word,rest) = break isSpace str
    capitalizeWord []     = []
    capitalizeWord (c:cs) = toUpper c:(map toLower cs)
op1 "quotemeta" = op1Cast (VStr . concat . map toQuoteMeta)
op1 "undef" = const $ return undef
op1 "undefine" = \x -> do
    when (defined x) $ do
        ref <- fromVal x
        clearRef ref
    return undef
op1 "+"    = op1Numeric id
op1 "abs"  = op1Numeric abs
op1 "Pugs::Internals::truncate" = op1Round truncate
op1 "Pugs::Internals::round"    = op1Round round
op1 "Pugs::Internals::floor"    = op1Round floor
op1 "Pugs::Internals::ceiling"  = op1Round ceiling
op1 "cos"  = op1Floating cos
op1 "sin"  = op1Floating sin
op1 "tan"  = op1Floating tan
op1 "sqrt" = op1Floating sqrt
op1 "atan" = op1Floating atan
op1 "post:i" = \x -> do
    n <- fromVal x
    return $ VComplex (0 :+ n)
op1 "post:++" = \x -> atomicEval $ do
    ref <- fromVal x
    val <- fromVal x
    val' <- case val of
        (VStr str)  -> return (VStr $ strInc str)
        _           -> op1Numeric (+1) val
    writeRef ref val'
    case val of
        (VStr _)    -> return val
        _           -> op1 "+" val
op1 "++"   = \mv -> do
    op1 "post:++" mv
    fromVal mv
op1 "post:--"   = \x -> atomicEval $ do
    ref <- fromVal x
    val <- fromVal x
    writeRef ref =<< op1Numeric (\x -> x - 1) val
    return val
op1 "--"   = \mv -> do
    op1 "post:--" mv
    fromVal mv
op1 "-"    = op1Numeric negate
op1 "item" = \v -> return $ case v of
    VList vs    -> VRef . arrayRef $ vs
    _           -> v
op1 "sort" = \v -> do
    args    <- fromVal v
    (valList, sortByGiven) <- case args of
        (v:vs) -> do
            ifValTypeIsa v "Code"
                (return (vs, Just v))
                (ifValTypeIsa (last args) "Code"
                    (return (init args, Just $ last args))
                    (return (args, Nothing)))
        _  -> return (args, Nothing)
    sortBy <- case sortByGiven of
        Nothing -> readVar (cast "&*infix:cmp")
        Just subVal -> return subVal
    sub <- fromVal sortBy
    sorted <- (`sortByM` valList) $ \v1 v2 -> do
        rv  <- enterEvalContext (cxtItem "Int") $ App (Val sub) Nothing [Val v1, Val v2]
        int <- fromVal rv
        return (int <= (0 :: Int))
    retSeq sorted
op1 "Scalar::reverse" = \v -> do
    str     <- fromVal v
    return (VStr $ reverse str)
op1 "List::reverse" = \v -> do
    vlist <- fromVal v
    return (VList $ reverse vlist)
op1 "list" = op1Cast VList
op1 "pair" = op1Cast $ VList . (map $ \(k, v) -> castV ((VStr k, v) :: VPair))
op1 "~"    = op1Cast VStr
op1 "?"    = op1Cast VBool
op1 "int"  = op1Cast VInt
op1 "+^"   = op1Cast (VInt . pred . negate) -- Arbitrary precision complement- 0 ==> -1 / 1 ==> -2
op1 "~^"   = op1Cast (VStr . mapStr complement)
op1 "?^"   = op1 "!"
op1 "\\"   = return . doCapture
    where
    doCapture :: Val -> Val
    doCapture v@(VRef (MkRef IScalar{})) = VRef . scalarRef $ v
    doCapture v@VRef{}                   = v
    doCapture (VList vs)                 = VRef . arrayRef $ vs
    doCapture v                          = VRef . scalarRef $ v
op1 "^" = op2RangeExclRight (VNum 0)
op1 "post:..."  = op1Range
op1 "not"  = op1 "!"
op1 "true" = op1 "?"
op1 "any"  = op1Cast opJuncAny
op1 "all"  = op1Cast opJuncAll
op1 "one"  = op1Cast opJuncOne
op1 "none" = op1Cast opJuncNone
op1 "perl" = op1Pretty $ MkPrettyPrinter pretty
op1 "guts" = op1Pretty $ MkPrettyPrinter priggy
op1 "yaml" = dumpYaml
op1 "require_haskell" = \v -> do
    name    <- fromVal v
    externRequire "Haskell" name
    return $ VBool True
op1 "require_parrot" = \v -> do
    -- name    <- fromVal v
    fail "evalParrotFile has bitrotten." -- io $ evalParrotFile name
    return $ VBool True
op1 "require_perl5" = \v -> do
    pkg     <- fromVal v
    let requireLine = "require " ++ pkg ++ "; '" ++ pkg ++ "'"
    val     <- evalPerl5WithCurrentEnv requireLine
    evalExp (_Sym SOur (':':'*':pkg) mempty (Val val) (newMetaType pkg))
    return val
op1 "require_java" = \v -> do
    pkg     <- fromVal v
    let requireLine = "package main; use Inline (qw( Java STUDY AUTOSTUDY 1 STUDY ), ['" ++ mod ++ "']); '" ++ pkg ++ "'"
        lastPart    = last (split "::" pkg)
        mod         = concat (intersperse "." (split "::" pkg))
    val     <- evalPerl5WithCurrentEnv requireLine
    evalExp (_Sym SOur (':':'*':pkg) mempty (Val val) (newMetaType pkg))
    when (lastPart /= pkg) $ do
        evalExp_ (_Sym SOur (':':'*':lastPart) mempty (Val val) (newMetaType lastPart))
    return val
op1 "Pugs::Internals::eval_parrot" = \v -> do
    -- code    <- fromVal v
    fail "evalParrot has bitrotten." 
    {-
    io . evalParrot $ case code of
        ('.':_) -> code
        _       -> unlines
            [ ".sub pugs_eval_parrot"
            -- , "trace 1"
            , code
            , ".end"
            ]
    -}
    return $ VBool True

-- XXX - revert these two to Prelude.pm's ::Disabled version once YAML+Closure is working
op1 "use" = opRequire True 
op1 "require" = opRequire False

op1 "Pugs::Internals::use" = opRequire True
op1 "Pugs::Internals::require" = opRequire False
op1 "Pugs::Internals::eval_perl6" = \v -> do
    str <- fromVal v
    opEval quiet "<eval>" (encodeUTF8 str)
    where quiet = MkEvalStyle { evalResult = EvalResultLastValue
                              , evalError  = EvalErrorUndef }
op1 "evalfile" = \v -> do
    filename <- fromVal v
    opEvalFile filename
op1 "Pugs::Internals::eval_perl5" = \v -> do
    str     <- fromVal v
    env     <- ask
    lex     <- asks envLexical
    let vars = [ v | v@MkVar{ v_sigil = SScalar, v_twigil = TNil } <- Set.toList (padKeys lex), v /= varTopic ]
        code = "sub { " ++ codeSafe ++ codeVar ++ str ++ "\n}"
        codeSafe | safeMode  = "use ops (':default', 'binmode', 'entereval');"
                 | otherwise = ""
        codeVar | null vars = ""
                | otherwise = "my (" ++ (concat $ intersperse ", " (map cast vars)) ++ ") = @_;"
    vals    <- mapM readVar vars
    rv  <- tryIO (Perl5ErrorString "") $ do
        envSV   <- mkEnv env
        sub     <- evalPerl5 code envSV 0
        args    <- mapM newSVval vals
        invokePerl5 sub nullSV args envSV (enumCxt $ envContext env)
    case rv of
        Perl5ReturnValues [x]   -> io $ svToVal x
        Perl5ReturnValues xs    -> io $ fmap VList (mapM svToVal xs)
        Perl5ErrorString str    -> fail str
        Perl5ErrorObject err    -> throwError (PerlSV err)
op1 "Pugs::Internals::evalfile_p6y" = op1EvalFileP6Y
op1 "Pugs::Internals::eval_p6y"     = op1EvalP6Y
op1 "Pugs::Internals::eval_haskell" = op1EvalHaskell
op1 "Pugs::Internals::eval_yaml" = evalYaml
op1 "contend" = \v -> do
    env <- ask
    guardSTM . runEvalSTM env . evalExp $ App (Val v) Nothing []
op1 "try" = \v -> do
    sub <- fromVal v
    env <- ask
    val <- tryT $ case envAtomic env of
        True    -> guardSTM . runEvalSTM env . evalExp $ App (Val $ VCode sub) Nothing []
        False   -> guardIO . runEvalIO env . evalExp $ App (Val $ VCode sub) Nothing []
    retEvalResult style val
    where
    style = MkEvalStyle
        { evalResult = EvalResultLastValue
        , evalError  = EvalErrorUndef
        }
-- Tentative implementation of nothingsmuch's lazy proposal.
op1 "lazy" = \v -> do
    sub     <- fromVal v
    memo    <- io $ newTVarIO Nothing
    let exp = App (Val $ VCode sub) Nothing []
        thunk = do
            cur <- stm $ readTVar memo
            maybe eval return cur
        eval = do
            res <- evalExp exp
            stm $ writeTVar memo (Just res)
            return res
    typ <- inferExpType exp
    return . VRef . thunkRef $ MkThunk thunk typ

op1 "defined" = op1Cast (VBool . defined)
op1 "last" = const $ assertFrame FrameLoop $ op1ShiftOut (VControl (ControlLoop LoopLast))
op1 "next" = const $ assertFrame FrameLoop $ op1ShiftOut (VControl (ControlLoop LoopNext))
op1 "redo" = const $ assertFrame FrameLoop $ op1ShiftOut (VControl (ControlLoop LoopRedo))
op1 "continue" = const $ assertFrame FrameWhen $ op1ShiftOut (VControl (ControlWhen WhenContinue))
op1 "break" = const $ assertFrame FrameWhen $ op1ShiftOut (VControl (ControlWhen WhenBreak))
op1 "return" = op1Return . op1ShiftOut . VControl . ControlLeave (<= SubRoutine) 0
op1 "yield" = op1Yield . op1ShiftOut . VControl . ControlLeave (<= SubRoutine) 0
op1 "leave" = op1ShiftOut . VControl . ControlLeave (>= SubBlock) 0
op1 "take" = \v -> assertFrame FrameGather $ do
    glob    <- askGlobal
    arr     <- findSymRef (cast "$*TAKE") glob
    push    <- doArray (VRef arr) array_push
    push (listVal v)
    retEmpty
op1 "sign" = \v -> withDefined [v] $
    op1Cast (VInt . signum) v

op1 "srand" = \v -> do
    x <- fromVal v
    guardSTM . unsafeIOToSTM $ do
       seed <- if defined v
          then return x
          else randomRIO (0, 2^(31::Int))
       setStdGen $ mkStdGen seed
    return (castV True)
op1 "rand"  = \v -> do
    x    <- fromVal v
    rand <- guardSTM . unsafeIOToSTM
               $ getStdRandom (randomR (0, if x == 0 then 1 else x))
    return $ VNum rand
op1 "say" = op2 "IO::say" (VHandle stdout)
op1 "print" = op2 "IO::print" (VHandle stdout)
op1 "IO::say" = \v -> op2 "IO::say" v $ VList []
op1 "IO::print" = \v -> op2 "IO::print" v $ VList []
op1 "IO::next" = \v -> do
    fh  <- fromVal v
    guardIO $ fmap (VStr . (++ "\n") . decodeUTF8) (hGetLine fh)
op1 "Pugs::Safe::safe_print" = \v -> do
    str  <- fromVal v
    guardIO . putStr $ encodeUTF8 str
    return $ VBool True
op1 "die" = \v -> do
    v'      <- fromVal $! v
    poss    <- asks envPosStack
    retShift $! VError (errmsg $! v') poss
    where
    errmsg VUndef      = VStr "Died"
    errmsg VType{}     = VStr "Died"
    errmsg (VStr "")   = VStr "Died"
    errmsg (VList [])  = VStr "Died"
    errmsg (VList [x]) = x
    errmsg x           = x
op1 "warn" = \v -> do
    strs <- fromVal v
    errh <- readVar $ cast "$*ERR"
    poss    <- asks envPosStack
    op2 "IO::say" errh $ VList [ VStr $ pretty (VError (errmsg strs) poss) ]
    where
    errmsg "" = VStr "Warning: something's wrong"
    errmsg x  = VStr x
op1 "fail" = op1 "fail_" -- XXX - to be replaced by Prelude later
op1 "fail_" = \v -> do
    throw <- fromVal =<< readVar (cast "$*FAIL_SHOULD_DIE")
    if throw then op1 "die" (errmsg v) else do
    poss    <- asks envPosStack
    let die = retShift $ VError (errmsg v) poss
        dieThunk = VRef . thunkRef $ MkThunk die (mkType "Failure")
    op1Return (retControl (ControlLeave (<= SubRoutine) 0 dieThunk))
    where
    errmsg VUndef      = VStr "Failed"
    errmsg VType{}     = VStr "Failed"
    errmsg (VStr "")   = VStr "Failed"
    errmsg (VList [])  = VStr "Failed"
    errmsg (VList [x]) = x
    errmsg x           = x
op1 "exit" = op1Exit
op1 "readlink" = \v -> do
    str  <- fromVal v
    guardIO $ fmap VStr (readSymbolicLink str)
op1 "sleep" = \v -> do
    x <- fromVal v :: Eval VNum
    guardIO $ do
        start   <- getCurrentTime
        threadDelay (round $ x * clocksPerSecond)
        finish  <- getCurrentTime
        return $ VRat (toRational $ diffUTCTime start finish)
op1 "mkdir" = guardedIO createDirectory
op1 "rmdir" = guardedIO removeDirectory
op1 "chdir" = guardedIO setCurrentDirectory
op1 "graphs"= op1Cast (VInt . (genericLength :: String -> VInt)) -- XXX Wrong
op1 "codes" = op1Cast (VInt . (genericLength :: String -> VInt))
op1 "chars" = op1Cast (VInt . (genericLength :: String -> VInt))
op1 "bytes" = op1Cast (VInt . (genericLength :: String -> VInt) . encodeUTF8)

op1 "unlink" = \v -> do
    vals <- fromVals v
    rets <- mapM (doBoolIO removeFile) vals
    return $ VInt $ sum $ map bool2n rets
op1 "readdir" = \v -> do
    path  <- fromVal v
    files <- guardIO $ getDirectoryContents path
    retSeq (map VStr files)
op1 "slurp" = \v -> do
    ifValTypeIsa v "IO"
        (do h <- fromVal v
            ifListContext (strictify $! op1 "=" v) $ do
                content <- guardIO $ hGetContents h
                return . VStr $ decodeUTF8 content)
        (do
            fileName    <- fromVal v
            ifListContext
                (slurpList fileName)
                (slurpScalar fileName))
    where
    strictify action = do
        VList lines <- action
        return $ VList (length lines `seq` lines)
    slurpList file = strictify $! op1 "=" (VList [VStr file])
    slurpScalar file = do
        content <- guardIO $ readFile file
        return . VStr $ decodeUTF8 content
op1 "opendir" = \v -> do
    str <- fromVal v
    dir <- guardIO $ openDirStream str
    obj <- createObject (mkType "IO::Dir") []
    return . VObject $ obj{ objOpaque = Just $ toDyn dir }
op1 "IO::Dir::close" = op1 "IO::Dir::closedir"
op1 "IO::Dir::closedir" = guardedIO (closeDirStream . fromObject)
op1 "IO::Dir::rewind" = op1 "IO::Dir::rewinddir"
op1 "IO::Dir::rewinddir" = guardedIO (rewindDirStream . fromObject)
op1 "IO::Dir::read" = op1 "IO::Dir::readdir"
op1 "IO::Dir::readdir" = \v -> do
    dir <- fmap fromObject (fromVal v)
    ifListContext
        (retSeq =<< readDirStreamList dir)
        (guardIO $ fmap (\x -> if null x then undef else castV x) $ readDirStream dir)
    where
    readDirStreamList dir = do
        this <- tryIO "" $ readDirStream dir
        if null this then return [] else do
        rest <- readDirStreamList dir
        return (VStr this:rest)
op1 "Pugs::Internals::runShellCommand" = \v -> do
    str <- fromVal v
    cxt <- asks envContext
    (res, exitCode) <- tryIO ("", ExitFailure (-1)) $ do
        (inp,out,_,pid) <- runInteractiveCommand (encodeUTF8 str)
        hClose inp
        res             <- fmap (decodeUTF8 . deCRLF) $ hGetContents out
        exitCode        <- waitForProcess pid
        return (res, exitCode)
    handleExitCode exitCode 
    return $ case cxt of
        CxtSlurpy{} -> VList (map VStr $ lines res)
        _           -> VStr res
    where
    -- XXX - crude CRLF treatment
    deCRLF []                   = []
    deCRLF ('\r':xs@('\n':_))   = xs
    deCRLF (x:xs)               = (x:deCRLF xs)
op1 "Pugs::Internals::runInteractiveCommand" = \v -> do
    str <- fromVal v
    guardIO $ do
        (inp,out,err,pid) <- runInteractiveCommand str
        return $ VList [ VHandle inp
                       , VHandle out
                       , VHandle err
                       , VProcess (MkProcess pid)
                       ]
op1 "Pugs::Internals::check_for_io_leak" = \v -> do
    rv      <- evalExp (App (Val v) Nothing [])
    leaked  <- fromVal =<< op2Match rv (VType $ mkType "IO")
    when leaked $ do
        fail $ "BEGIN and CHECK blocks may not return IO handles,\n" ++
               "as they would be invalid at runtime."
    return rv
op1 "run" = \v -> do
    cmd         <- fromVal v
    exitCode    <- tryIO (ExitFailure (-1)) $ system (encodeUTF8 cmd)
    handleExitCode exitCode
op1 "accept" = \v -> do
    socket      <- fromVal v
    (h, _, _)   <- guardIO $ accept socket
    return $ VHandle h
op1 "detach" = \v -> do
    case v of
        VThread thr -> do
            stm $ tryPutTMVar (threadLock thr) undef
            return $ VBool True
        _           -> fail $ "Not a thread: " ++ show v
op1 "kill" = \v -> do
    case v of
        VThread thr -> do
            guardIO . killThread $ threadId thr
            return $ VBool True
        _           -> fail $ "Not a thread: " ++ show v
op1 "join" = \v -> do
    case v of
        VThread thr -> stm $ takeTMVar (threadLock thr)
        _           -> op2Join v (VList [])
op1 "async" = \v -> do
    env     <- ask
    code    <- fromVal v
    lock    <- stm $ newEmptyTMVar
    tid     <- guardIO . forkIO $ do -- (if rtsSupportsBoundThreads then forkOS else forkIO) $ do
        val <- runEvalIO env $ do
            enterEvalContext CxtVoid $ App (Val code) Nothing []
        stm $ tryPutTMVar lock val
        return ()
    return . VThread $ MkThread
        { threadId      = tid
        , threadLock    = lock
        }
--WV: async should return the thread id!    return undef
op1 "listen" = \v -> do
    port    <- fromVal v
    socket  <- guardIO $ listenOn (PortNumber $ fromInteger port)
    return $ VSocket socket
op1 "flush" = guardedIO hFlush
op1 "IO::close" = guardedIO hClose
op1 "Socket::close" = guardedIO sClose
op1 "Pair::key" = fmap fst . (fromVal :: Val -> Eval VPair)
op1 "Pair::value" = \v -> do
    ivar <- join $ doPair v pair_fetchElem
    return . VRef . MkRef $ ivar
op1 "pairs" = \v -> do
    pairs <- pairsFromVal v
    retSeq pairs
op1 "List::kv" = \v -> do
    pairs <- pairsFromVal v
    kvs   <- forM pairs $ \(VRef ref) -> do
        pair   <- readRef ref
        fromVal pair
    retSeq $ concat kvs
op1 "Pair::kv" = op1 "List::kv"
op1 "keys" = keysFromVal
op1 "values" = valuesFromVal
-- According to Damian
-- (http://www.nntp.perl.org/group/perl.perl6.language/21895),
-- =$obj should call $obj.next().
op1 "="        = \v -> case v of
    VObject _               -> evalExp $ App (_Var "&shift") (Just $ Val v) []
    VRef (MkRef IArray{})   -> do
        ifListContext
            (fmap VList (join $ doArray v array_fetch))
            (join $ doArray v array_shift)
    _           -> op1 "readline" v
op1 "readline" = op1Readline
op1 "getc"     = op1Getc
op1 "WHAT"     = fmap VType . evalValType
op1 "List::end"   = \x -> fmap (castV . pred) (join $ doArray x array_fetchSize) -- monadic join
op1 "List::elems" = \x -> fmap castV (join $ doArray x array_fetchSize) -- monadic join
op1 "List::pop"   = \x -> join $ doArray x array_pop -- monadic join
op1 "List::shift" = \x -> join $ doArray x array_shift -- monadic join
op1 "pick"  = op1Pick
op1 "sum"   = op1Sum
op1 "min"   = op1Min
op1 "max"   = op1Max
op1 "uniq"  = op1Uniq
op1 "chr"   = op1Cast (VStr . (:[]) . chr)
op1 "ord"   = op1Cast $ \str -> if null str then undef else (castV . ord . head) str
op1 "hex"   = fail "hex() is not part of Perl 6 - use :16() instead."
op1 "oct"   = fail "oct() is not part of Perl 6 - use :8() instead."
op1 "log"   = op1Floating log
op1 "log10" = op1Floating (logBase 10)
op1 "from"  = op1Cast (castV . matchFrom)
op1 "to"    = op1Cast (castV . matchTo)
op1 "matches" = op1Cast (VList . matchSubPos)
op1 "gather" = \v -> do
    evl <- asks envEval
    evl (Syn "gather" [Val v])
op1 "Thread::yield" = const $ do
    guardSTM . unsafeIOToSTM $ yield
    return $ VBool True
op1 "DESTROYALL" = \x -> cascadeMethod id "DESTROY" x VUndef
-- [,] is a noop -- It simply returns the input list
op1 "prefix:[,]" = return
op1 "prefix:$<<" = op1SigilHyper SScalar
op1 "prefix:@<<" = op1SigilHyper SArray
op1 "prefix:%<<" = op1SigilHyper SHash
op1 "prefix:&<<" = op1SigilHyper SCode
op1 "Code::assoc" = op1CodeAssoc
op1 "Code::name"  = op1CodeName
op1 "Code::arity" = op1CodeArity
op1 "Code::body"  = op1CodeBody
op1 "Code::pos"   = op1CodePos
op1 "Code::signature" = op1CodeSignature
op1 "IO::tell"    = \v -> do
    h <- fromVal v
    res <- guardIO $ hTell h
    return $ VInt res
op1 "Rat::numerator" = \(VRat t) -> return . VInt $ numerator t
op1 "Rat::denominator" = \(VRat t) -> return . VInt $ denominator t
op1 "TEMP" = \v -> do
    ref <- fromVal v
    val <- readRef ref
    return . VCode $ mkPrim
        { subBody = Prim . const $ do
            writeRef ref val
            retEmpty
        }
op1 "Pugs::Internals::hIsOpen" = op1IO hIsOpen
op1 "Pugs::Internals::hIsClosed" = op1IO hIsClosed
op1 "Pugs::Internals::hIsReadable" = op1IO hIsReadable
op1 "Pugs::Internals::hIsWritable" = op1IO hIsWritable
op1 "Pugs::Internals::hIsSeekable" = op1IO hIsSeekable
op1 "Pugs::Internals::reduceVar" = \v -> do
    str <- fromVal v
    evalExp (_Var str)
op1 "Pugs::Internals::rule_pattern" = \v -> do
    case v of
        VRule MkRulePGE{rxRule=re} -> return $ VStr re
        VRule MkRulePCRE{rxRuleStr=re} -> return $ VStr re
        _ -> fail $ "Not a rule: " ++ show v
op1 "Pugs::Internals::rule_adverbs" = \v -> do
    case v of
        VRule MkRulePGE{rxAdverbs=hash} -> return hash
        VRule MkRulePCRE{rxAdverbs=hash} -> return hash
        _ -> fail $ "Not a rule: " ++ show v
op1 "Pugs::Internals::current_pragma_value" = \v -> do
    name <- fromVal v
    prags <- asks envPragmas
    return $ findPrag name prags
    where
        findPrag :: String -> [Pragma] -> Val
        findPrag _ [] = VUndef
        findPrag n (this:rest)
            | n == pragName this = VInt $ toInteger $ pragDat this
            | otherwise          = findPrag n rest
op1 "Pugs::Internals::caller_pragma_value" = \v -> do
    caller <- asks envCaller
    case caller of
        Just env -> local (const env) (op1 "Pugs::Internals::current_pragma_value" v)
        _        -> return $ VUndef
op1 "eager" = \v -> do
    vlist <- fromVal v
    return $! length (map valType vlist) `seq` VList vlist
op1 "Pugs::Internals::emit_yaml" = \v -> do
    glob <- filterPrim =<< asks envGlobal
    yml  <- io $ showYaml (filterUserDefinedPad glob, v)
    return $ VStr yml
op1 "Object::HOW" = \v -> do
    typ     <- evalValType v
    evalExp $ _Var (':':'*':showType typ)
op1 "Class::name" = \v -> do
    cls     <- fromVal v
    meta    <- readRef =<< fromVal cls
    fetch   <- doHash meta hash_fetchVal
    str     <- fromVal =<< fetch "name"
    return str
op1 "Class::traits" = \v -> do
    cls     <- fromVal v
    meta    <- readRef =<< fromVal cls
    fetch   <- doHash meta hash_fetchVal
    str     <- fromVal =<< fetch "is"
    return str
op1 "vv" = op1Cast VV
op1 "stat" = \x -> opPerl5 "require File::stat; File::stat::stat" [x]
op1 "lstat" = \x -> opPerl5 "require File::stat; File::stat::lstat" [x]
op1 "Pugs::Internals::localtime"  = \x -> do
    tz  <- io getCurrentTimeZone
    tm  <- fromVal x    -- seconds since Perl's epoch
    let utc   = posixSecondsToUTCTime (fromInteger tm + offset)
        local = utcToLocalTime tz utc
        day   = localDay local
        tod   = localTimeOfDay local
        (year, month, dayOfMonth)   = toGregorian day 
        (sec, pico)                 = properFraction $ todSec tod
        (_, dayOfWeek)              = sundayStartWeek day
    -- if wantString then return . VStr $ formatTime "%c" (ZonedTime local tz) else
    retSeq [ vI    $ year
           , vI    $ month
           , vI    $ dayOfMonth
           , vI    $ todHour tod
           , vI    $ todMin tod
           , VInt  $ sec
           , vI    $ fromEnum (pico * 1000000000000)
           , vI    $ dayOfWeek + 1
           , vI    $ (monthAndDayToDayOfYear (isLeapYear year) month dayOfMonth) - 1
           , VStr  $ timeZoneName tz
           , vI    $ timeZoneMinutes tz * 60
           , VBool $ timeZoneSummerOnly tz
           ]
    where
    offset :: NominalDiffTime
    offset = 946684800 -- diff between Haskell and Perl epochs (seconds)
    vI :: Integral a => a -> Val
    vI = VInt . toInteger

op1 other   = \_ -> fail ("Unimplemented unaryOp: " ++ other)

op1IO :: Value a => (Handle -> IO a) -> Val -> Eval Val
op1IO = \fun v -> do
    val <- fromVal v
    fmap castV (guardIO $ fun val)

op1SigilHyper :: VarSigil -> Val -> Eval Val
op1SigilHyper sig val = do
    vs <- fromVal val
    evalExp $ Syn "," (map (\x -> Syn (shows sig "{}") [Val x]) vs)

retSeq :: VList -> Eval Val
retSeq xs = length xs `seq` return (VList xs)

handleExitCode :: ExitCode -> Eval Val
handleExitCode exitCode = do
    glob    <- askGlobal
    errSV   <- findSymRef (cast "$!") glob
    writeRef errSV $ case exitCode of
        ExitFailure x   -> VInt $ toInteger x
        ExitSuccess     -> VUndef
    return (VBool $ exitCode == ExitSuccess)

cascadeMethod :: ([VStr] -> [VStr]) -> VStr -> Val -> Val -> Eval Val
cascadeMethod f meth v args = do
    typ     <- evalValType v
    pkgs    <- fmap f (pkgParents $ showType typ)
    named   <- case args of
        VUndef -> return Map.empty
        VType{}-> return Map.empty
        _      -> join $ doHash args hash_fetch

    -- Here syms is a list of (sym, tvar) tuples where tvar is the physical coderef
    -- The monad in the "do" below is List.
    syms <- forM pkgs $ \pkg -> do
        let sym = cast $ ('&':pkg) ++ "::" ++ meth
        maybeM (fmap (lookupPad sym) askGlobal) $ \ref -> do
            return (sym, ref)

    forM_ (nubBy (\(_, x) (_, y) -> x == y) (catMaybes syms)) $ \(sym, _) -> do
        enterEvalContext CxtVoid $
            App (Var sym) (Just $ Val v)
                [ Syn "named" [Val (VStr key), Val val]
                | (key, val) <- Map.assocs named
                ]
    return undef

op1Return :: Eval Val -> Eval Val
op1Return action = assertFrame FrameRoutine $ do
    sub   <- fromVal =<< readVar (cast "&?ROUTINE")
    -- If this is a coroutine, reset the entry point
    case subCont sub of
        Nothing -> action
        Just tvar -> do
            let thunk = (`MkThunk` anyType) . fix $ \redo -> do
                evalExp $ subBody sub
                stm $ writeTVar tvar thunk
                redo
            stm $ writeTVar tvar thunk
            action

op1Yield :: Eval Val -> Eval Val
op1Yield action = assertFrame FrameRoutine $ do
    sub   <- fromVal =<< readVar (cast "&?ROUTINE")
    case subCont sub of
        Nothing -> fail $ "cannot yield() from a " ++ pretty (subType sub)
        Just tvar -> callCC $ \esc -> do
            stm $ writeTVar tvar (MkThunk (esc undef) anyType)
            action

op1ShiftOut :: Val -> Eval Val
op1ShiftOut v = retShift =<< do
    evl <- asks envEval
    evl $ case v of
        VList [x]   -> Val x
        _           -> Val v

op1Exit :: Val -> Eval a
op1Exit v = do
    rv <- fromVal v
    retControl . ControlExit $ if rv /= 0
        then ExitFailure rv else ExitSuccess

op1StrFirst :: (Char -> Char) -> Val -> Eval Val
op1StrFirst f = op1Cast $ VStr .
    \str -> case str of
        []      -> []
        (c:cs)  -> (f c:cs)

-- op1Readline and op1Getc are precisely the implementation of op1 "readline"
-- and op1 "getc", but those may be hidden in safe mode. We still want to use
-- the functionality with the safe variants, hence these functions.
op1Readline :: Val -> Eval Val
op1Readline = \v -> op1Read v (io . getLines) getLine
    where
    getLines :: VHandle -> IO Val
    getLines fh = unsafeInterleaveIO $ do
        line <- doGetLine fh
        case line of
            Just str -> do
                ~(VList rest) <- getLines fh
                return $ VList (VStr str:rest)
            _ -> return (VList [])
    getLine :: VHandle -> Eval Val
    getLine fh = do
        line <- io $! doGetLine fh
        case line of
            Just str    -> return $! VStr $! (length str `seq` str)
            _           -> return undef
    doGetLine :: VHandle -> IO (Maybe VStr)
    doGetLine fh = guardIOexcept [(isEOFError, Nothing)] $ do
        line <- hGetLine fh
        return . Just . decodeUTF8 $ line

op1Getc :: Val -> Eval Val
op1Getc = \v -> op1Read v (getChar) (getChar)
    where
    getChar :: VHandle -> Eval Val
    getChar fh = guardIOexcept [(isEOFError, undef)] $ do
        char <- hGetChar fh
        str  <- getChar' fh char
        return $ VStr $ decodeUTF8 str
    -- We may have to read more than one byte, as one utf-8 char can span
    -- multiple bytes.
    getChar' :: VHandle -> Char -> IO String
    getChar' fh char
        | ord char < 0x80 = return [char]
        | ord char < 0xE0 = readNmore 1
        | ord char < 0xEE = readNmore 2
        | ord char < 0xF5 = readNmore 3
        | otherwise       = fail "Invalid utf-8 read by getc()"
        where
        readNmore :: Int -> IO String
        readNmore n = do
            new <- sequence $ replicate n (hGetChar fh)
            return $ char:new

{-|
Read a char or a line from a handle.
-}
op1Read :: Val                   -- ^ The handle to read from (packed in a 'Val')
        -> (VHandle -> Eval Val) -- ^ The function to call in list context
        -> (VHandle -> Eval Val) -- ^ The function to call in item context
        -> Eval Val              -- ^ The return value (a list of strings or a
                                 --   string, packed in a 'Val')
op1Read v fList fScalar = do
    fh  <- handleOf v
    ifListContext
        (fList fh)
        (fScalar fh)
    where
    handleOf x | safeMode, (VHandle h) <- x, h /= stdin = fail "Evil handle detected"
    handleOf _ | safeMode = return stdin
    handleOf VUndef = handleOf (VList [])
    handleOf (VList []) = do
        argsGV  <- readVar (cast "$*ARGS")
        gv      <- fromVal argsGV
        if defined gv
            then handleOf gv
            else do
                args    <- readVar (cast "@*ARGS")
                files   <- fromVal args
                if null files
                    then return stdin
                    else do
                        hdl <- handleOf (VStr (head files)) -- XXX wrong
                        writeVar (cast "$*ARGS") (VHandle hdl)
                        return hdl
    handleOf (VStr x) = do
        return =<< guardIO $ openFile x ReadMode
    handleOf (VList [x]) = handleOf x
    handleOf v = fromVal v

bool2n :: Bool -> VInt
bool2n v = if v
  then 1
  else 0

doBoolIO :: Value a => (a -> IO b) -> Val -> Eval Bool
doBoolIO f v = do
    x <- fromVal v
    tryIO False $ do
        f x
        return True

guardedIO :: Value a => (a -> IO b) -> Val -> Eval Val
guardedIO f v = do
    x <- fromVal v
    guardIO $ f x
    return $ VBool True

guardedIO2 :: (Value a, Value b)
    => (a -> b -> IO c) -> Val -> Val -> Eval Val
guardedIO2 f u v = do
    x <- fromVal u
    y <- fromVal v
    guardIO $ f x y
    return $ VBool True

mapStr :: (Word8 -> Word8) -> [Word8] -> String
mapStr f = map (chr . fromEnum . f)

mapStr2 :: (Word8 -> Word8 -> Word8) -> [Word8] -> [Word8] -> String
mapStr2 f x y = map (chr . fromEnum . uncurry f) $ x `zip` y

mapStr2Fill :: (Word8 -> Word8 -> Word8) -> [Word8] -> [Word8] -> String
mapStr2Fill f x y = map (chr . fromEnum . uncurry f) $ x `zipFill` y
    where
    zipFill [] [] = []
    zipFill as [] = zip as (repeat 0)
    zipFill [] bs = zip (repeat 0) bs
    zipFill (a:as) (b:bs) = (a,b) : zipFill as bs

op1Chomp :: VStr -> Val
op1Chomp "" = VStr ""
op1Chomp str
    | last str == '\n'  = VStr (init str)
    | otherwise         = VStr str

perlReplicate :: VInt -> a -> [a]
perlReplicate = genericReplicate . max 0

-- XXX only used at    op2 "?^"   because my Haskell is too poor - ferreira 
neBool :: VBool -> VBool -> VBool
neBool = (==) . not

-- |Implementation of 2-arity primitive operators and functions
op2 :: String -> Val -> Val -> Eval Val
op2 "rename" = guardedIO2 rename
op2 "symlink" = guardedIO2 createSymbolicLink
op2 "link" = guardedIO2 createLink
op2 "*"  = op2Numeric (*)
op2 "/"  = op2Divide
op2 "%"  = op2Modulus
op2 "x"  = op2Cast (\x y -> VStr . concat $ (y :: VInt) `perlReplicate` x)
op2 "xx" = op2Cast (\x y -> VList . concat $ (y :: VInt) `perlReplicate` x)
op2 "+&" = op2Int (.&.)
op2 "+<" = op2Int shiftL
op2 "+>" = op2Int shiftR
op2 "~&" = op2Str $ mapStr2 (.&.)
op2 "~<" = op2Cast (\x y -> VStr $ mapStr (`shiftL` y) x)
op2 "~>" = op2Cast (\x y -> VStr $ mapStr (`shiftR` y) x)
op2 "**" = op2Exp
op2 "+"  = op2Numeric (+)
op2 "-"  = op2Numeric (-)
op2 "atan" = op2Num atan2
op2 "~"  = op2Str (++)
op2 "+|" = op2Int (.|.)
op2 "+^" = op2Int xor
op2 "~|" = op2Str $ mapStr2Fill (.|.)
op2 "?|" = op2Bool (||)
op2 "?&" = op2Bool (&&)
op2 "~^" = op2Str $ mapStr2Fill xor
op2 "?^" = op2Bool neBool -- for bools, 'xor' is the same as '!=='
op2 "=>" = \x y -> return $ castV (x, y)
op2 "="  = \x y -> evalExp (Syn "=" [Val x, Val y])
op2 "cmp"= op2OrdNumStr
op2 "leg"= op2Ord vCastStr
op2 "<=>"= op2OrdNumeric compare
op2 ".." = op2Range
op2 "..^" = op2RangeExclRight
op2 "^.." = op2RangeExclLeft
op2 "^..^" = op2RangeExclBoth
op2 "!=" = op2OrdNumeric (/=)
op2 "==" = op2OrdNumeric (==)
op2 "<"  = op2OrdNumeric (<)
op2 "<=" = op2OrdNumeric (<=)
op2 ">"  = op2OrdNumeric (>)
op2 ">=" = op2OrdNumeric (>=)
op2 "ne" = op2Cmp vCastStr (/=)
op2 "eq" = op2Cmp vCastStr (==)
op2 "lt" = op2Cmp vCastStr (<)
op2 "le" = op2Cmp vCastStr (<=)
op2 "gt" = op2Cmp vCastStr (>)
op2 "ge" = op2Cmp vCastStr (>=)
op2 "~~" = op2Match
op2 "=:=" = \x y -> do
    return $ castV $ case x of
        VRef xr | VRef yr <- y ->
            -- Take advantage of the pointer address built-in with (Show VRef)
            show xr == show yr
        _   ->
            W# (unsafeCoerce# x :: Word#) == W# (unsafeCoerce# y :: Word#)
op2 "===" = \x y -> do
    return $ castV (x == y)
op2 "eqv" = op2Identity -- XXX wrong, needs to compare full objects
op2 "&&" = op2Logical (fmap not . fromVal)
op2 "||" = op2Logical (fmap id . fromVal)
op2 "^^" = \x y -> do
    let xor True True   = VBool False
        xor True False  = x
        xor False True  = y
        xor False False = VBool False
    op2Cast xor x y
op2 "//" = op2Logical (return . defined)
op2 ".[]" = \x y -> do
    evl <- asks envEval
    evl $ Syn "[]" [Val x, Val y]
op2 ".{}" = \x y -> do
    evl <- asks envEval
    evl $ Syn "{}" [Val x, Val y]
-- XXX pipe forward XXX
op2 "and"= op2 "&&"
op2 "or" = op2 "||"
op2 "xor"= op2 "^^"
op2 "orelse"= op2 "//"	-- XXX wrong
op2 "andthen"= op2 "&&"	-- XXX even wronger
op2 "pick" = op2Pick
op2 "grep" = op2Grep
op2 "first" = op2First
op2 "map"  = op2Map
op2 "join" = op2Join
op2 "reduce" = op2ReduceL False
op2 "produce" = op2ReduceL True
op2 "reverse" = op2MaybeListop (VList . reverse) (VStr . reverse)
op2 "chomp" = op2MaybeListop (VList . map op1Chomp) op1Chomp
op2 "kill" = \s v -> do
    sig  <- fromVal s
    pids <- fromVals v
    sig' <- fromVal sig
    pids'<- mapM fromVal pids
    let doKill pid = do
        signalProcess (toEnum sig') (toEnum pid)
        return 1
    rets <- mapM (tryIO 0 . doKill) pids'
    return . VInt $ sum rets
op2 "isa"    = \x y -> do
    typY <- case y of
        VStr str -> return $ mkType str
        _        -> fromVal y
    typX <- fromVal x -- XXX consider line 224 of Pugs.Prim.Match case too
    typs <- pkgParentClasses (showType typX)
    return . VBool $ showType typY `elem` (showType typX:typs)
op2 "does"   = \x y -> do
    typY <- case y of
        VStr str -> return $ mkType str
        _        -> fromVal y
    op2Match x (VType typY)
op2 "delete" = \x y -> do
    ref <- fromVal x
    rv  <- deleteFromRef ref y
    -- S29: delete always returns the full list regardless of context.
    return $ case rv of
        VList [x]   -> x
        _           -> rv
op2 "exists" = \x y -> do
    ref <- fromVal x
    fmap VBool (existsFromRef ref y)
op2 "unshift" = op2Array array_unshift
op2 "push" = op2Array array_push
op2 "split" = op2Split
op2 "Str::split" = flip op2Split
op2 "connect" = \x y -> do
    host <- fromVal x
    port <- fromVal y
    hdl  <- guardIO $ connectTo host (PortNumber $ fromInteger port)
    return $ VHandle hdl
op2 "Pugs::Internals::hSetBinaryMode" = \x y -> do
    fh    <- fromVal x
    mode  <- fromVal y
    guardIO $ hSetBinaryMode fh mode
    return $ VBool True
op2 "Pugs::Internals::openFile" = \x y -> do
    filename <- fromVal x
    mode     <- fromVal y
    hdl      <- guardIO $ do
        h <- openFile filename (modeOf mode)
        hSetBuffering h NoBuffering
        return h
    return $ VHandle hdl
    where
    modeOf "r"  = ReadMode
    modeOf "w"  = WriteMode
    modeOf "a"  = AppendMode
    modeOf "rw" = ReadWriteMode
    modeOf m    = error $ "unknown mode: " ++ m
op2 "exp" = \x y -> if defined y
    then op2Num (**) x y
    else op1Floating exp x
op2 "Pugs::Internals::sprintf" = \x y -> do
    -- a single argument is all Haskell can really handle.
    -- XXX printf should be wrapped in a catch so a mis-typed argument
    -- doesnt kill pugs with a runtime exception.
    -- XXX fail... doesnt?!
    str <- fromVal x
    arg <- fromVal y
    return $ VStr $ case arg of
       VNum n -> printf str n
       VRat r -> printf str ((fromRational r)::Double)
       VInt i -> printf str i
       VStr s -> printf str s
       _      -> fail "should never be reached given the type declared below"
op2 "run" = \x y -> do
    prog        <- fromVal x
    args        <- fromVals y
    exitCode    <- tryIO (ExitFailure (-1)) $
        rawSystem (encodeUTF8 prog) (map encodeUTF8 args)
    handleExitCode exitCode
op2 "crypt" = \x y -> opPerl5 "crypt" [x, y]
op2 "chmod" = \x y -> do
    mode  <- fromVal x
    files <- fromVals y
    rets  <- mapM (doBoolIO . flip setFileMode $ toEnum mode) files
    return . VInt . sum $ map bool2n rets
op2 "splice" = \x y -> do
    fetchSize   <- doArray x array_fetchSize
    len'        <- fromVal y
    sz          <- fetchSize
    let len = if len' < 0 then if sz > 0 then (len' `mod` sz) else 0 else len'
    op4 "splice" x y (castV (sz - len)) (VList [])
op2 "sort" = \x y -> do
    xs <- fromVals x
    ys <- fromVals y
    op1 "sort" . VList $ xs ++ ys
op2 "IO::say" = op2Print True
op2 "IO::print" = op2Print False
op2 "printf" = op3 "IO::printf" (VHandle stdout)
op2 "BUILDALL" = cascadeMethod reverse "BUILD"
op2 "Pugs::Internals::install_pragma_value" = \x y -> do
    name <- fromVal x
    val  <- fromVal y
    idat <- asks envInitDat
    idatval <- stm $ readTVar idat
    --trace ("installing " ++ name ++ "/" ++ (show val)) $ return ()
    let prag = initPragmas idatval
    stm $ writeTVar idat idatval{initPragmas = 
        MkPrag{ pragName=name, pragDat=val } : prag }
    return (VBool True)
op2 "Pugs::Internals::base" = \x y -> do
    base <- fromVal x
    case y of
        VRef{}  -> op2BasedDigits base =<< fromVal y
        VList{} -> op2BasedDigits base =<< fromVal y
        _       -> do
            str <- fromVal y
            op2BasedDigits base [ s | Just s <- map baseDigit str ]
op2 "HOW::does" = \t p -> do
    meta    <- readRef =<< fromVal t
    fetch   <- doHash meta hash_fetchVal
    name    <- fromVal =<< fetch "name"
    roles   <- fromVals p
    mixinRoles name roles
    return undef

op2 ('!':name) = \x y -> op1Cast (VBool . not) =<< op2 name x y
op2 other = \_ _ -> fail ("Unimplemented binaryOp: " ++ other)

baseDigit :: Char -> Maybe Val
baseDigit '.'       = return (VStr ".")
baseDigit ch | ch >= '0' && ch <= '9' = return (castV (ord ch - ord '0'))
baseDigit ch | ch >= 'a' && ch <= 'z' = return (castV (ord ch - ord 'a' + 10))
baseDigit ch | ch >= 'A' && ch <= 'Z' = return (castV (ord ch - ord 'A' + 10))
baseDigit _         = Nothing

op2BasedDigits :: VInt -> [Val] -> Eval Val
op2BasedDigits base vs
    | null post = do
        pre' <- mapM fromVal pre
        return $ VInt (asIntegral pre')
    | otherwise = do
        pre'  <- mapM fromVal pre
        post' <- mapM fromVal $ tail post
        return $ VRat (asFractional (0:post') + (asIntegral pre' % 1))
    where
    (pre, post) = break (== VStr ".") $ filter (/= VStr "_") vs
    asIntegral = foldl (\x d -> base * x + d) 0
    asFractional :: [VInt] -> VRat
    asFractional = foldr (\d x -> (x / (base % 1)) + (d % 1)) (0 % 1)

op2Print :: Bool -> Val -> Val -> Eval Val
op2Print wantNewline h v = do
    handle <- fromVal h
    strs   <- mapM fromVal =<< case v of
        VList vs  -> return vs
        _         -> return [v]
    guardIO $ do
        forM_ strs (hPutStr handle . encodeUTF8)
        when wantNewline (hPutStr handle "\n")
        return $ VBool True

op2Split :: Val -> Val -> Eval Val
op2Split x y = do
    val <- fromVal x
    str <- fromVal y
    case val of
        VRule rx -> do
            chunks <- rxSplit rx str
            return $ VList chunks
        _ -> do
            delim <- fromVal val
            return $ split' delim str
    where
    split' :: VStr -> VStr -> Val
    split' [] xs = VList $ map (VStr . (:[])) xs
    split' glue xs = VList $ map VStr $ split glue xs

op2MaybeListop :: forall tlist titem. (Value tlist, Value [tlist], Value titem) =>
    ([tlist] -> Val) -> (titem -> Val) -> Val -> Val -> Eval Val
op2MaybeListop flist fitem lead rest = case lead of
    VList{} -> do
        lead' <- fromVal lead
        rest' <- fromVal rest
        return (flist $ lead' ++ rest')
    VRef ref -> do
        vs      <- fromVal =<< readRef ref
        vlist   <- fromVal rest
        return (flist $ vs ++ vlist)
    _ | VList [] <- rest -> do
        -- Probably a single item.
        item    <- fromVal lead 
        return (fitem item)
    _ -> do
        lead'   <- fromVal lead
        rest'   <- fromVal rest
        return (flist (lead':rest'))

-- |Implementation of 3-arity primitive operators and functions
op3 :: String -> Val -> Val -> Val -> Eval Val
op3 "Pugs::Internals::exec" = \x y z -> do
    prog        <- fromVal x
    shell       <- fromVal y
    args        <- fromVals z
    exitCode    <- guardIO $ executeFile' prog shell args Nothing
    rv          <- handleExitCode exitCode
    when (rv == VBool True) $ do
        guardIO $ exitWith ExitSuccess
    return rv
op3 "Pugs::Internals::caller" = \x y z -> do
    --kind <- fromVal =<< op1 "WHAT" x
    kind <- case x of
        VStr str -> return $ mkType str
        _        -> fromVal x
    skip <- fromVal y
    when (skip < 0) $ do
        fail "Pugs::Internals::caller called with negative skip"
    label <- fromVal z
    op3Caller kind skip label
op3 "index" = \x y z -> do
    str <- fromVal x
    sub <- fromVal y
    pos <- fromVal z
    return . VInt $ doIndex 0 str sub pos
    where
    doIndex :: VInt -> VStr -> VStr -> VInt -> VInt
    doIndex n a b p
        | p > 0, null a     = doIndex n a b 0
        | p > 0             = doIndex (n+1) (tail a) b (p-1)
        | b `isPrefixOf` a  = n
        | null a            = -1
        | otherwise         = doIndex (n+1) (tail a) b 0
op3 "rindex" = \x y z -> do
    str <- fromVal x
    sub <- fromVal y
    pos <- fromVal z
    let skip | defined z = length str - pos - length sub
             | otherwise = 0
    return . VInt $ doRindex str sub skip
    where
    doRindex :: VStr -> VStr -> Int -> VInt
    doRindex a b skip
        | skip > 0         = doRindex (init a) b (skip-1)
        | b `isSuffixOf` a = toInteger $ length a - length b
        | null a           = -1
        | otherwise        = doRindex (init a) b 0

op3 "splice" = \x y z -> do
    op4 "splice" x y z (VList [])
op3 "split" = op3Split
op3 "Str::split" = \x y z -> do
    op3 "split" y x z
op3 "HOW::new" = \t n p -> do
    cls     <- op3 "Object::new" t n p
    meta    <- readRef =<< fromVal cls
    fetch   <- doHash meta hash_fetchVal

    attrs   <- fetch "attrs"

    name    <- fromVal =<< fetch "name" :: Eval String
    roles   <- fromVals =<< fetch "does" :: Eval [String]
    supers  <- fromVals =<< fetch "is" :: Eval [String]

    -- Role flattening -- copy over things there and put it to symbol table
    -- XXX - also do renaming of concrete types mentioned in roles
    -- XXX - also, rewrite subEnv mentioned in the subs
    -- XXX - also, copy over the inheritance chain from role's metaobject
    mixinRoles name roles

    -- Merge in slot definitions in "attrs"
    defs        <- join $ doHash attrs hash_fetch
    parentAttrs <- forM (roles ++ supers) $ fetchMetaInfo "attrs"
    store       <- doHash attrs hash_store
    store $ Map.unions (defs:parentAttrs)
    
    return cls

op3 "Object::new" = \t n p -> do
    positionals <- fromVal p
    typ     <- fromVal t
    named   <- fromVal n

    defs    <- fetchMetaInfo "attrs" (showType typ)
    attrs   <- io $ H.new (==) H.hashString
    writeIVar (IHash attrs) (named `Map.union` defs)
    uniq    <- newObjectId
    unless (positionals == VList []) (fail "Must only use named arguments to new() constructor\nBe sure to use bareword keys.")
    let obj = VObject $ MkObject
            { objType   = typ
            , objAttrs  = attrs
            , objId     = uniq
            , objOpaque = Nothing
            }
    -- Now start calling BUILD for each of parent classes (if defined)
    op2 "BUILDALL" obj $ (VRef . hashRef) named
    -- Register finalizers by keeping weakrefs somehow
    setFinalization obj

op3 "Object::clone" = \t n _ -> do
    named <- fromVal n
    (VObject o) <- fromVal t
    attrs   <- readIVar (IHash $ objAttrs o)
    attrs'  <- io $ H.new (==) H.hashString
    uniq    <- newObjectId
    writeIVar (IHash attrs') (named `Map.union` attrs)
    return $ VObject o{ objAttrs = attrs', objId = uniq }

op3 "Pugs::Internals::hSeek" = \x y z -> do
    handle <- fromVal x
    pos <- fromVal y
    mode <- fromVal z
    guardIO $ hSeek handle (modeOf mode) pos
    retEmpty
    where
        modeOf :: Int -> SeekMode
        modeOf 0 = AbsoluteSeek
        modeOf 1 = RelativeSeek
        modeOf 2 = SeekFromEnd
        modeOf m = error ("Unknown seek mode: " ++ (show m))
op3 "IO::printf" = \x y z -> do
    rv      <- evalExp $ App (_Var "&sprintf") Nothing [Val y, Val z]
    op2Print False x rv
op3 other = \_ _ _ -> fail ("Unimplemented 3-ary op: " ++ other)

mixinRoles :: String -> [String] -> Eval ()
mixinRoles name roles = do
    glob    <- asks envGlobal
    let rolePkgs = map cast roles
        thisPkg  = cast name

    stm . modifyMPad glob $ \(MkPad entries) ->
        MkPad . Map.unionWith mergePadEntry entries . Map.fromList $
            [ (k{ v_package = thisPkg }, v)
            | (k, v) <- Map.assocs entries
            , v_package k `elem` rolePkgs
            ]

op3Split :: Val -> Val -> Val -> Eval Val
op3Split x y z = do
    val <- fromVal x
    str <- fromVal y
    limit <- fromVal z
    case val of
        VRule rx -> do
            chunks <- rxSplit_n rx str limit
            return $ VList chunks
        _ -> do
            delim <- fromVal val
            return $ split' delim str limit
    where
    split' :: VStr -> VStr -> Int -> Val
    split' [] xs n = VList $ (map (VStr . (:[])) (take (n-1) xs)) ++ [ VStr $ drop (n-1) xs ]
    split' glue xs n = VList $ map VStr $ split_n glue xs n

-- XXX - The "String" below wants to be Type.
fetchMetaInfo :: Value a => String -> [Char] -> Eval a
fetchMetaInfo key typ = do
    meta    <- readRef =<< fromVal =<< evalExp (_Var (':':'*':typ))
    fetch   <- doHash meta hash_fetchVal
    fromVal =<< fetch key

-- |Implementation of 4-arity primitive operators and functions.
-- Only substr and splice
op4 :: String -> Val -> Val -> Val -> Val -> Eval Val
op4 "substr" = \x y z w -> do
    str  <- fromVal x
    pos  <- fromVal y
    lenP <- fromVal z
    let len | defined z = lenP
            | otherwise = length str
        (pre, result, post) = doSubstr str pos len
    let change = \new -> do
        var <- fromVal x
        rep <- fromVal new
        writeRef var (VStr $ concat [pre, rep, post])
    -- If the replacement is given in w, change the str.
    when (defined w && not (defined result)) $ change w
    -- Return a proxy which will modify the str if assigned to.
    return $ VRef . MkRef $ proxyScalar (return result) change
    where
    doSubstr :: VStr -> Int -> Int -> (VStr, Val, VStr)
    doSubstr str pos len
        | abs pos > length str = ("", VUndef, "")
        | pos < 0   = doSubstr str (length str + pos) len
        | len < 0   = doSubstr str pos (length str - pos + len)
        | otherwise = ((take pos str), VStr (take len $ drop pos str), (drop (pos + len) str))

-- op4 "splice" = \x y z w-> do
op4 "splice" = \x y z w -> do
    splice  <- doArray x array_splice
    start   <- fromVal y
    count   <- fromVal z
    vals    <- fromVals w
    vals'   <- splice start count vals
    return $ VList vals'

op4 other = \_ _ _ _ -> fail ("Unimplemented 4-ary op: " ++ other)

op1Range :: Val -> Eval Val
op1Range (VStr s)    = return . VList $ map VStr $ strRangeInf s
op1Range (VRat n)    = return . VList $ map VRat [n ..]
op1Range (VNum n)    = return . VList $ map VNum [n ..]
op1Range (VInt n)    = return . VList $ map VInt [n ..]
op1Range x           = do
    int <- fromVal x
    op1Range (VInt int)

{- In the four op2Range* functions below, rationals
have to be handled separately because Haskell ranges 
are different from Perl 6 ranges.  For example, 
in Haskell, [1.1 .. 2] will return [1.1,2.1].  So, we
run the elements through a filter to ensure that the 
upper bound is satisfied 
-}
op2Range :: Val -> Val -> Eval Val
op2Range (VStr s) y  = do
    y'  <- fromVal y
    return . VList $ map VStr $ strRange s y'
op2Range (VNum n) y  = do
    y'  <- fromVal y
    return . VList $ map VNum [n .. y']
op2Range x (VNum n)  = do
    x'  <- fromVal x
    return . VList $ map VNum [x' .. n]
op2Range (VRat n) y  = do
    y'  <- fromVal y
    return . VList $ map VRat (filter (<= y') [n .. y'])
op2Range x (VRat n)  = do
    x'  <- fromVal x
    return . VList $ map VRat (filter (<= n) [x' .. n])
op2Range x y         = do
    x'  <- fromVal x
    y'  <- fromVal y
    return . VList $ map VInt [x' .. y']

-- because the right-exclusivity of a range can leave it
-- with no remaining elements, we need to check before
-- removing an element when enforcing left-exclusivity
removeRangeFirst :: [Val] -> [Val]
removeRangeFirst vals = if null vals then vals else init vals

op2RangeExclRight :: Val -> Val -> Eval Val
op2RangeExclRight (VRat n) y  = do
    y' <- fromVal y
    return . VList $ map VRat (filter (< y') [n .. y'])
op2RangeExclRight x (VRat n)  = do
    x'  <- fromVal x
    return . VList $ map VRat (filter (< n) [x' .. n])
op2RangeExclRight x y = do
    VList vals <- op2Range x y
    return . VList $ removeRangeFirst vals

op2RangeExclLeft :: Val -> Val -> Eval Val
op2RangeExclLeft (VRat n) y  = do
    y'  <- fromVal y
    return . VList $ map VRat (filter (\v -> n < v && v <= y') [n .. y'])
op2RangeExclLeft x (VRat n)  = do
    x'  <- fromVal x
    return . VList $ map VRat (filter (\v -> x' < v && v <= n) [x' .. n])
op2RangeExclLeft x y = do
    VList vals <- op2Range x y
    return . VList $ tail vals

op2RangeExclBoth :: Val -> Val -> Eval Val
op2RangeExclBoth (VRat n) y  = do
    y'  <- fromVal y
    return . VList $ map VRat (filter (\v -> n < v && v < y') [n .. y'])
op2RangeExclBoth x (VRat n)  = do
    x'  <- fromVal x
    return . VList $ map VRat (filter (\v -> x' < v && v < n) [x' .. n])
op2RangeExclBoth x y = do
    VList vals <- op2Range x y
    return . VList $ removeRangeFirst (tail vals)

op2ChainedList :: Val -> Val -> Val
op2ChainedList x y
    | VList xs <- x, VList ys <- y  = VList $ xs ++ ys
    | VList xs <- x                 = VList $ xs ++ [y]
    | VList ys <- y                 = VList (x:ys)
    | otherwise                     = VList [x, y]

op2Logical :: (Val -> Eval Bool) -> Val -> Val -> Eval Val
op2Logical f x y = do
    ok <- f x
    if ok then return x else do
    ref <- fromVal y
    forceRef ref

op2Identity :: Val -> Val -> Eval Val
op2Identity (VObject x) (VObject y) = return $ VBool (objId x == objId y)
op2Identity (VRef ref) y = do
    x <- readRef ref
    op2Identity x y
op2Identity x (VRef ref) = do
    y <- readRef ref
    op2Identity x y
op2Identity x y = do
    return $ VBool (x == y)

op2Cmp :: (a -> Eval b) -> (b -> b -> VBool) -> a -> a -> Eval Val
op2Cmp f cmp x y = do
    x' <- f x
    y' <- f y
    return $ VBool $ x' `cmp` y'

op2Ord :: (Ord ord) => (Val -> Eval ord) -> Val -> Val -> Eval Val
op2Ord f x y = withDefined [x, y] $ do
    x' <- f x
    y' <- f y
    return $ VInt $ case x' `compare` y' of
        LT -> -1
        EQ -> 0
        GT -> 1

isNumeric :: Val -> Bool
isNumeric (VNum {}) = True
isNumeric (VRat {}) = True
isNumeric (VInt {}) = True
isNumeric _ = False

op2OrdNumStr :: Val -> Val -> Eval Val
op2OrdNumStr x y
    | isNumeric x && isNumeric y = op2Ord vCastRat x y
    | otherwise                  = op2Ord vCastStr x y

op3Caller :: Type -> Int -> Val -> Eval Val
--op3Caller kind skip label = do
op3Caller kind skip _ = do                                 -- figure out label
    chain <- callChain =<< ask
    formatFrame $ filter labelFilter $ drop skip $ filter kindFilter chain
    where
    formatFrame :: [(Env, Maybe VCode)] -> Eval Val
    formatFrame [] = retEmpty
    formatFrame ((env, Just sub):_) = retSeq
        [ VStr $ cast (envPackage env)                 -- .package
        , VStr $ cast (posName $ envPos env)           -- .file
        , VInt $ toInteger $ posBeginLine $ envPos env -- .line
        , VStr $ cast (subName sub)                    -- .subname
        , VStr $ show $ subType sub                    -- .subtype
        , VCode $ sub                                  -- .sub
        -- TODO: add more things as they are specced.
        ]
    formatFrame ((env, _):_) = retSeq
        [ VStr $ cast (envPackage env)                 -- .package
        , VStr $ cast (posName $ envPos env)           -- .file
        , VInt $ toInteger $ posBeginLine $ envPos env -- .line
        ]
    kindFilter :: (Env, Maybe VCode) -> Bool
    kindFilter (_, Just sub) =
        case (showType kind, subType sub) of
            ("Any",      _)          -> True  -- I hope this is optimized
            ("Method",   SubMethod)  -> True
            ("Sub",      SubRoutine) -> True
            ("Block",    SubBlock)   -> True
            ("Block",    SubPointy)  -> True
            (_,          _)          -> False
    kindFilter _ = kind == anyType
    labelFilter _ = True                             -- TODO: figure out how
    callChain :: Env -> Eval [(Env, Maybe VCode)]
    callChain cur = 
        case envCaller cur of
            Just caller -> do
                val <- local (const caller) (readVar $ cast "&?ROUTINE")
                if (val == undef) then return [(caller, Nothing)] else do
                sub <- fromVal val
                rest <- callChain caller
                return ((caller, Just sub) : rest)
            _           -> return []


opPerl5 :: String -> [Val] -> Eval Val
opPerl5 sub args = do
    env     <- ask
    envSV   <- io $ mkEnv env
    let prms = map (\i -> "$_[" ++ show i ++ "]") [0 .. (length args - 1)]
    subSV   <- io $ evalPerl5 ("sub { " ++ sub ++ "(" ++ (concat $ intersperse ", " prms) ++ ") }") envSV (enumCxt cxtItemAny)
    argsSV  <- mapM fromVal args
    runInvokePerl5 subSV nullSV argsSV

evalPerl5WithCurrentEnv :: String -> Eval Val
evalPerl5WithCurrentEnv code = do
    env     <- ask
    guardIO $ do
        envSV   <- mkEnv env
        sv      <- evalPerl5 code envSV $ enumCxt cxtItemAny
        return (PerlSV sv)

atomicEval :: Eval Val -> Eval Val
atomicEval action = do
    env <- ask
    if envAtomic env then action else do
        rv <- guardSTM (runEvalSTM env action)
        case rv of
            VError{}    -> retShift rv
            VControl{}  -> retShift rv
            _           -> return rv

{-| Assert that a list of Vals is all defined.
This should 'fail' (in the Perl sense).

TOTHINK: report which element in the input list was the one
triggering the failure. Just zipping with [1 ..] may not be
enough because our caller may not be passing through its own
input args in the same order and position to us.

-}
withDefined :: (Monad m) => [Val] -> m a -> m a
withDefined [] c = c
withDefined (VUndef:_) _  = fail "use of uninitialized value"
withDefined (VType{}:_) _ = fail "use of uninitialized value"
withDefined (_:xs) c = withDefined xs c

-- |Returns a transaction to install a primitive operator using
-- 'Pugs.AST.genMultiSym'.
-- The associativity determines the arity and fixity of ops.
-- The primitive\'s subBody is defined in 'op0', 'op1', etc depending on arity,
-- the default is 'op0'.
-- The Pad symbol name is prefixed with \"&*\" for functions and
-- \"&*\" ~ fixity ~ \":\" for operators.
primOp :: String -> String -> Params -> String -> Bool -> Bool -> Bool -> STM PadMutator
primOp sym assoc prms ret isSafe isMacro isExport = fullEval $ do
    prim <- genMultiSym var (sub (isSafe || not safeMode)) mempty
    case assoc of
        -- Manufacture &infix:<!===> from &infix:<===>.
        "chain" | head sym /= '!' -> do
            prim' <- primOp ('!':sym) assoc prms ret isSafe isMacro isExport
            return (prim . prim')
        _       | isExport -> do
            -- Here we rewrite a multi form that redispatches into the method form.
            prim' <- genMultiSym (var{ v_package = emptyPkg }) (sub (isSafe || not safeMode)) mempty
            return (prim . prim')
        _       -> return prim
    where
    -- It is vital that we generate the ID for the Var for all the primitives at once,
    -- otherwise they'll be generated unpredictably during runtime with an as-needed basis,
    -- which may introduce race conditions under e.g. anotmer atomic block.
    fullEval x = idKey (v_name var) `seq` x

    -- In safemode, we filter all prims marked as "unsafe".
    var | isAlpha (head sym)
        , fixity == "prefix"
        = cast ("&*" ++ sym)
        | otherwise
        = cast ("&*" ++ fixity ++ (':':sym))

    pkg = do
        (_, pre) <- breakOnGlue "::" (reverse sym)
        return $ dropWhile (not . isAlphaNum) (reverse pre)

    sub safe = codeRef $! mkPrim
        { subName     = cast sym
        , subType     = case pkg of
            Nothing | isMacro       -> SubMacro
                    | otherwise     -> SubPrim
            Just "Pugs::Internals"  -> SubPrim
            _                       -> SubMethod
        , subAssoc    = case assoc of
            "left"  -> A_left
            "right" -> A_right
            "non"   -> A_non
            "chain" -> A_chain
            "list"  -> A_list
            "spre"  -> AIrrelevantToParsing -- XXX HACK
            _       -> ANil
        , subParams   = prms
        , subReturns  = mkType ret
        , subBody     = Prim $! if safe then f else unsafe
        }
    unsafe :: [Val] -> Eval Val
    unsafe _ = fail $ "Unsafe function '" ++ sym ++ "' called under safe mode"
    f :: [Val] -> Eval Val
    f    = case arity of
        Arity0 -> op0 sym
        Arity1 -> \x -> case x of
            [a]       -> op1 symName a
            [a,b]     -> op2 sym a b
            [a,b,c]   -> op3 sym a b c
            [a,b,c,d] -> op4 sym a b c d
            a         -> op0 sym a
        Arity2 -> \[x,y] -> op2 sym x y
    symName = if modify then assoc ++ ":" ++ sym else sym
    -- prefix symName with post, circum or other (not yet used)
    -- to disambiguate, for example, &*prefix:++ and &*postfix:++ in 'op0'
    (arity, fixity, modify) = case assoc of
        "pre"       -> (Arity1, "prefix", False)
        "spre"      -> (Arity1, "prefix", False)
        "post"      -> (Arity1, "postfix", True)
        "circum"    -> (Arity1, "circumfix", True)
        "left"      -> (Arity2, "infix", False)
        "right"     -> (Arity2, "infix", False)
        "non"       -> (Arity2, "infix", False)
        "chain"     -> (Arity2, "infix", False)
        "list"      -> (Arity0, "infix", False)
        other       -> (Arity0, other, True)

data Arity = Arity0 | Arity1 | Arity2
    deriving (Show, Eq, Ord, Typeable)

-- |Produce a Pad update transaction with 'primOp' from a string description
primDecl :: String -> STM PadMutator
primDecl str = length str `seq` rv `seq` rv
    where
    rv = primOp sym assoc params ret
        ("safe" `isPrefixOf` traits)
        ("macro" `isSuffixOf` traits)
        ("export" `isSuffixOf` traits)
    (ret:assoc:sym:traits:prms) = words str
    takeWord = takeWord' . dropWhile (not . isWord)
    takeWord' "" = ""
    takeWord' (':':':':xs) = (':':':':takeWord' xs)
    takeWord' (x:xs) | isWord x = (x:takeWord' xs)
    takeWord' _ = ""
    isWord = not . (`elem` "(),:")
    prms'  = map takeWord prms
    prms'' = foldr foldParam [] prms'
    params = map (\p -> p{ isWritable = isLValue p }) prms''

setFinalization :: Val -> Eval Val
setFinalization obj = do
    env <- ask
    -- XXX - Not sure if this can break guarantees in STM or not; disable for now
    if envAtomic env
        then return obj -- stm $ unsafeIOToSTM (obj `setFinalization` env)
        else io $ obj `setFinalizationIn` env
    where
    setFinalizationIn obj env = do
        objRef <- mkWeakPtr obj . Just $ do
            runEvalIO env $ do
                evalExp $ App (_Var "&DESTROYALL") (Just $ Val obj) []
            return ()
        modifyIORef _GlobalFinalizer (>> finalize objRef)
        return obj

-- A "box" to put our polymorphic printer in
newtype PrettyPrinter = MkPrettyPrinter { runPrinter :: forall a. Pretty a => a -> String }

-- op1 "perl"
op1Pretty :: PrettyPrinter -> Val -> Eval Val
op1Pretty printer v = do
    recur   <- io (newTVarIO False)
    let ?seen    = IntSet.empty
        ?recur   = recur
        ?printer = printer
    rv      <- prettyVal v
    isRecur <- stm (readTVar recur)
    return $ VStr $ decodeUTF8 $ if isRecur then "$_ := " ++ rv else rv

prettyVal :: (?seen :: IntSet.IntSet, ?recur :: TVar Bool, ?printer :: PrettyPrinter) => Val -> Eval VStr
prettyVal v@(VRef r) = do
    ptr <- io (stableAddressOf r)
    if IntSet.member ptr ?seen
        then do
            stm $ writeTVar ?recur True
            return "\\$_"
        else let ?seen = IntSet.insert ptr ?seen in doPrettyVal v
prettyVal v = doPrettyVal v

doPrettyVal :: (?seen :: IntSet.IntSet, ?recur :: TVar Bool, ?printer :: PrettyPrinter) => Val -> Eval VStr
doPrettyVal v@(VRef r) = do
    v'  <- readRef r
    ifValTypeIsa v "Pair"
        (case v' of
            VList [ks, vs] -> do
                kStr <- prettyVal ks
                vStr <- prettyVal vs
                return $ "(" ++ kStr ++ " => " ++ vStr ++ ")"
            _ -> prettyVal v'
        )
        (do str <- prettyVal v'
            ifValTypeIsa v "Array"
                (return $ ('[':(init (tail str))) ++ "]")
                (ifValTypeIsa v "Hash"
                    (return $ ('{':(init (tail str))) ++ "}")
                    (return ('\\':str)))
        )
doPrettyVal (VList vs) = do
    vs' <- mapM prettyVal vs
    -- (3,) should dump as (3,), not a (3), which would be the same as 3.
    return $ case vs' of
        []  -> "()"
        [x] -> "(" ++ x ++ ",)"
        _   -> "(" ++ concat (intersperse ", " vs') ++ ")"
doPrettyVal v@(VObject obj) = do
    -- ... dump the objAttrs
    -- XXX this needs fixing WRT demagicalized pairs:
    -- currently, this'll return Foo.new((attr => "value)), with the inner
    -- parens, which is, of course, wrong.
    hash    <- fromVal v :: Eval VHash
    str     <- prettyVal (VRef (hashRef hash))
    return $ showType (objType obj)
        ++ ".new(" ++ init (tail str) ++ ")"
doPrettyVal v = return (runPrinter ?printer v)

-- XXX -- Junctive Types -- XXX --

-- spre is "symbolic pre", that is, operators for which a precedence has
-- already been assigned in Parser.hs

-- |Initial set global symbols to populate the evaluation environment
--  in the form of Pad mutating transactions built with 'primDecl'.
--
--  The source string format is:
--
-- >  ret_val   assoc   op_name [safe|unsafe] args
initSyms :: STM [PadMutator]
initSyms = seq (length syms) $ do
    rv <- mapM primDecl syms
    length rv `seq` return (length rv `seq` rv)
    where
    syms = filter (not . null) . lines $ "\
\\n   Bool      spre    !       safe   (Bool)\
\\n   Num       spre    +       safe   (Num)\
\\n   Num       pre     abs     safe   (Num)\
\\n   Int       pre     Pugs::Internals::truncate safe   (Num)\
\\n   Int       pre     Pugs::Internals::round    safe   (Num)\
\\n   Int       pre     Pugs::Internals::floor    safe   (Num)\
\\n   Int       pre     Pugs::Internals::ceiling  safe   (Num)\
\\n   Num       pre     atan    safe   (Num)\
\\n   Num       pre     atan    safe   (Num, Num)\
\\n   Num       pre     cos     safe   (Num)\
\\n   Num       pre     sin     safe   (Num)\
\\n   Num       pre     tan     safe   (Num)\
\\n   Any       pre     Pugs::Internals::pi      safe   ()\
\\n   Any       pre     self    safe,macro   ()\
\\n   Bool      pre     nothing safe   ()\
\\n   Num       pre     exp     safe   (Num, ?Num)\
\\n   Num       pre     sqrt    safe   (Num)\
\\n   Num       spre    -       safe   (Num)\
\\n   Str       spre    ~       safe   (Str)\
\\n   Bool      spre    ?       safe   (Bool)\
\\n   Str       spre    =       unsafe (?IO)\
\\n   List      spre    =       unsafe (?IO)\
\\n   Str       pre     readline unsafe (?IO)\
\\n   List      pre     readline unsafe (?IO)\
\\n   Str       pre     getc     unsafe (?IO)\
\\n   Str       pre     Pugs::Safe::safe_getc      safe ()\
\\n   Str       pre     Pugs::Safe::safe_readline  safe ()\
\\n   Int       pre     int     safe   (Int)\
\\n   List      pre     list    safe   (List)\
\\n   Hash      pre     hash    safe   (List)\
\\n   List      pre     pair    safe   (List)\
\\n   Scalar    pre     item    safe   (Scalar)\
\\n   Str       pre     Scalar::reverse safe   (Scalar)\
\\n   Any       pre     List::reverse safe   (Array)\
\\n   Any       pre     reverse safe   (Scalar, List)\
\\n   Any       pre     reverse safe   ()\
\\n   List      pre     eager   safe   (List)\
\\n   Int       spre    +^      safe   (Int)\
\\n   Int       spre    ~^      safe   (Str)\
\\n   Bool      spre    ?^      safe   (Bool)\
\\n   Ref       spre    \\      safe   (rw!Any)\
\\n   List      spre    ^       safe   (Scalar)\
\\n   List      post    ...     safe   (Str)\
\\n   List      post    ...     safe   (Scalar)\
\\n   Any       pre     undef     safe   ()\
\\n   Any       pre     undefine  safe   (?rw!Any)\
\\n   Str       pre     chop    safe   (Str)\
\\n   Str       pre     Scalar::chomp   safe   (Scalar)\
\\n   Any       pre     chomp   safe   (Scalar, List)\
\\n   Any       pre     chomp   safe   ()\
\\n   Any       right   =       safe   (rw!Any, Any)\
\\n   Int       pre     index   safe   (Str, Str, ?Int=0)\
\\n   Int       pre     rindex  safe   (Str, Str, ?Int)\
\\n   Int       pre     substr  safe   (rw!Str, Int, ?Int, ?Str)\
\\n   Str       pre     lc      safe   (Str)\
\\n   Str       pre     quotemeta safe   (Str)\
\\n   Str       pre     lcfirst safe   (Str)\
\\n   Str       pre     uc      safe   (Str)\
\\n   Str       pre     ucfirst safe   (Str)\
\\n   Str       pre     capitalize safe   (Str)\
\\n   Str       pre     crypt   safe   (Str, Str)\
\\n   Str       post    ++      safe   (rw!Str)\
\\n   Str       post    --      safe   (rw!Str)\
\\n   Num       post    ++      safe   (rw!Num)\
\\n   Num       post    --      safe   (rw!Num)\
\\n   Complex   post    i       safe   (Num)\
\\n   Str       spre    ++      safe   (rw!Str)\
\\n   Str       spre    --      safe   (rw!Str)\
\\n   Num       spre    ++      safe   (rw!Num)\
\\n   Num       spre    --      safe   (rw!Num)\
\\n   Bool      pre     not     safe   (Bool)\
\\n   Bool      pre     true    safe   (Bool)\
\\n   List      spre    gather  safe   (Code)\
\\n   List      pre     map     safe   (Code, List)\
\\n   List      pre     grep    safe   (Code, List)\
\\n   Scalar    pre     first   safe   (Code, List)\
\\n   List      pre     sort    safe   (Code, List)\
\\n   List      pre     reduce  safe   (Code, List)\
\\n   List      pre     produce safe   (Code, List)\
\\n   List      pre     sort    safe   (Array)\
\\n   List      pre     map     safe   (Array: Code)\
\\n   List      pre     grep    safe   (Array: Code)\
\\n   Scalar    pre     first   safe   (Array: Code)\
\\n   List      pre     sort    safe   (Array: Code)\
\\n   List      pre     reduce  safe   (Array: Code)\
\\n   List      pre     produce safe   (Array: Code)\
\\n   Any       pre     splice  safe   (rw!Array, ?Int=0)\
\\n   Any       pre     splice  safe   (rw!Array, Int, Int)\
\\n   Any       pre     splice  safe   (rw!Array, Int, Int, List)\
\\n   Int       pre     push    safe   (rw!Array, List)\
\\n   Int       pre     unshift safe   (rw!Array, List)\
\\n   Scalar    pre     List::pop     safe   (rw!Array)\
\\n   Scalar    pre     List::shift   safe   (rw!Array)\
\\n   Scalar    pre     sum     safe   (List)\
\\n   Scalar    pre     min     safe   (List)\
\\n   Scalar    pre     max     safe   (List)\
\\n   List      pre     uniq    safe   (List)\
\\n   Str       pre     join    safe   (Array: Str)\
\\n   Str       pre     join    safe   (Str, List)\
\\n   Any       pre     join    safe   (Thread)\
\\n   Bool      pre     detach  safe   (Thread)\
\\n   List      pre     cat     safe   (List)\
\\n   List      pre     zip     safe   (List)\
\\n   List      pre     each    safe   (List)\
\\n   List      pre     roundrobin    safe   (List)\
\\n   List      pre     keys    safe   (rw!Hash)\
\\n   List      pre     values  safe   (rw!Hash)\
\\n   List      pre     List::kv      safe,export   (rw!Hash)\
\\n   List      pre     pairs   safe   (rw!Hash)\
\\n   List      pre     keys    safe   (rw!Array)\
\\n   List      pre     values  safe   (rw!Array)\
\\n   List      pre     List::kv      safe,export   (rw!Array)\
\\n   List      pre     pairs   safe   (rw!Array)\
\\n   Scalar    pre     delete  safe   (rw!Hash: List)\
\\n   Scalar    pre     delete  safe   (rw!Array: List)\
\\n   Bool      pre     exists  safe   (rw!Hash: Str)\
\\n   Bool      pre     exists  safe   (rw!Array: Int)\
\\n   Str       pre     perl    safe   (rw!Any|Junction)\
\\n   Str       pre     guts    safe   (rw!Any|Junction)\
\\n   Any       pre     try     safe   (Code)\
\\n   Any       pre     lazy    safe   (Code)\
\\n   Any       pre     contend safe   (Code)\
\\n   Void      pre     defer   safe   ()\
\\n   Any       pre     Pugs::Internals::eval_perl6    safe   (Str)\
\\n   Any       pre     evalfile     unsafe (Str)\
\\n   Any       pre     Pugs::Internals::eval_parrot  unsafe (Str)\
\\n   Any       pre     Pugs::Internals::eval_perl5   safe (Str)\
\\n   Any       pre     Pugs::Internals::eval_haskell unsafe (Str)\
\\n   Any       pre     Pugs::Internals::eval_p6y unsafe (Str)\
\\n   Any       pre     Pugs::Internals::evalfile_p6y unsafe (Str)\
\\n   Any       pre     Pugs::Internals::eval_yaml    safe   (Str)\
\\n   Any       pre     Pugs::Internals::emit_yaml    unsafe   (rw!Any)\
\\n   Str       pre     yaml    safe   (rw!Any|Junction)\
\\n   Any       pre     Pugs::Internals::require unsafe (Str)\
\\n   Any       pre     Pugs::Internals::use     unsafe (Str)\
\\n   Any       pre     require unsafe (Str)\
\\n   Any       pre     use     unsafe (Str)\
\\n   Any       pre     require_haskell unsafe (Str)\
\\n   Any       pre     require_parrot  unsafe (Str)\
\\n   Any       pre     require_perl5   unsafe (Str)\
\\n   Any       pre     require_java    unsafe (Str)\
\\n   Any       pre     last    safe   (?Int=1)\
\\n   Any       pre     next    safe   (?Int=1)\
\\n   Any       pre     redo    safe   (?Int=1)\
\\n   Any       pre     continue    safe   (?Int=1)\
\\n   Any       pre     break    safe   (?Int=1)\
\\n   Any       pre     exit    safe   (?Int=0)\
\\n   Any       pre     srand   safe   (?Num)\
\\n   Num       pre     rand    safe   (?Num=1)\
\\n   Bool      pre     defined safe   (Any)\
\\n   Str       pre     WHAT     safe   (rw!Any|Junction)\
\\n   Str       pre     isa     safe   (rw!Any|Junction, Str)\
\\n   Str       pre     does    safe   (rw!Any|Junction, Str)\
\\n   Num       pre     time    safe   ()\
\\n   List      pre     times   safe   ()\
\\n   List      pre     Pugs::Internals::localtime   safe   (Num)\
\\n   Str       pre     want    safe   ()\
\\n   Str       pre     File::Spec::cwd     unsafe ()\
\\n   Str       pre     File::Spec::tmpdir  unsafe ()\
\\n   Str       pre     IO::next   unsafe (IO)\
\\n   Bool      pre     IO::print   unsafe (IO)\
\\n   Bool      pre     IO::print   unsafe (IO: List)\
\\n   Bool      pre     print   safe ()\
\\n   Bool      pre     print   safe (List)\
\\n   Bool      pre     IO::printf   unsafe (IO: Str, List)\
\\n   Bool      pre     printf   safe (Str, List)\
\\n   Str       pre     Pugs::Internals::sprintf safe   (Str, Num|Rat|Int|Str)\
\\n   Bool      pre     IO::say unsafe (IO)\
\\n   Bool      pre     IO::say unsafe (IO: List)\
\\n   Bool      pre     say     safe ()\
\\n   Bool      pre     say     safe (List)\
\\n   Bool      pre     Pugs::Safe::safe_print     safe     (Str)\
\\n   Bool      pre     flush   unsafe (IO)\
\\n   Bool      pre     IO::close   unsafe,export (IO:)\
\\n   Bool      pre     Socket::close   unsafe,export (Socket:)\
\\n   Bool      pre     die     safe   (?Object)\
\\n   Bool      pre     warn    safe   (List)\
\\n   Bool      pre     fail_   safe   (?Object)\
\\n   Bool      pre     fail    safe   (?Object)\
\\n   Socket    pre     listen  unsafe (Int)\
\\n   Socket    pre     connect unsafe (Str, Int)\
\\n   Any       pre     accept  unsafe (Any)\
\\n   List      pre     slurp   unsafe (Str)\
\\n   List      pre     slurp   unsafe (Handle)\
\\n   List      pre     readdir unsafe (Str)\
\\n   Bool      pre     Pugs::Internals::exec    unsafe (Str, Bool, List)\
\\n   Int       pre     run  unsafe (Str)\
\\n   Int       pre     run  unsafe (Str: List)\
\\n   Bool      pre     binmode unsafe (IO: ?Int=1)\
\\n   Void      pre     return  safe   ()\
\\n   Void      pre     return  safe   (rw!Any)\
\\n   Void      pre     return  safe   (List)\
\\n   Void      pre     leave   safe   ()\
\\n   Void      pre     leave   safe   (rw!Any)\
\\n   Void      pre     leave   safe   (List)\
\\n   Void      pre     yield   safe   ()\
\\n   Void      pre     yield   safe   (rw!Any)\
\\n   Void      pre     yield   safe   (List)\
\\n   Void      pre     take    safe   ()\
\\n   Void      pre     take    safe   (rw!Any)\
\\n   Void      pre     take    safe   (List)\
\\n   Junction  pre     any     safe   (List)\
\\n   Junction  pre     all     safe   (List)\
\\n   Junction  pre     one     safe   (List)\
\\n   Junction  pre     none    safe   (List)\
\\n   Bool      pre     sleep   unsafe (Int)\
\\n   Bool      pre     rmdir   unsafe (Str)\
\\n   Bool      pre     mkdir   unsafe (Str)\
\\n   Bool      pre     chdir   unsafe (Str)\
\\n   Int       pre     List::elems   safe,export   (rw!Array)\
\\n   Int       pre     List::end     safe,export   (Array)\
\\n   Int       pre     graphs  safe   (Str)\
\\n   Int       pre     codes   safe   (Str)\
\\n   Int       pre     chars   safe   (Str)\
\\n   Int       pre     bytes   safe   (Str)\
\\n   Int       pre     chmod   unsafe (Int, List)\
\\n   Scalar    pre     Pair::key     safe (rw!Pair)\
\\n   Scalar    pre     Pair::value   safe (rw!Pair)\
\\n   List      pre     keys    safe   (rw!Pair)\
\\n   List      pre     values  safe   (Pair|Junction)\
\\n   List      pre     Pair::kv      safe,export   (rw!Pair)\
\\n   List      pre     pairs   safe   (rw!Pair)\
\\n   Any       pre     pick    safe   (Any|Junction)\
\\n   List      pre     pick    safe   (Any|Junction: Int)\
\\n   Bool      pre     rename  unsafe (Str, Str)\
\\n   Bool      pre     symlink unsafe (Str, Str)\
\\n   Bool      pre     link    unsafe (Str, Str)\
\\n   Int       pre     unlink  unsafe (List)\
\\n   Str       pre     readlink unsafe (Str)\
\\n   List      pre     Str::split   safe   (Str)\
\\n   List      pre     Str::split   safe   (Str: Str)\
\\n   List      pre     Str::split   safe   (Str: Regex)\
\\n   List      pre     Str::split   safe   (Str: Str, Int)\
\\n   List      pre     Str::split   safe   (Str: Regex, Int)\
\\n   List      pre     split   safe   (Str, Str)\
\\n   List      pre     split   safe   (Str, Str, Int)\
\\n   List      pre     split   safe   (Regex, Str)\
\\n   List      pre     split   safe   (Regex, Str, Int)\
\\n   Str       spre    =       safe   (Any)\
\\n   List      spre    =       safe   (Any)\
\\n   Junction  list    |       safe   (Any|Junction)\
\\n   Junction  list    &       safe   (Any|Junction)\
\\n   Junction  list    ^       safe   (Any|Junction)\
\\n   Num       left    *       safe   (Num, Num)\
\\n   Num       left    /       safe   (Num, Num)\
\\n   Num       left    %       safe   (Num, Num)\
\\n   Str       left    x       safe   (Str, Int)\
\\n   List      left    xx      safe   (Any, Int)\
\\n   Int       left    +&      safe   (Int, Int)\
\\n   Int       left    +<      safe   (Int, Int)\
\\n   Int       left    +>      safe   (Int, Int)\
\\n   Str       left    ~&      safe   (Str, Str)\
\\n   Str       left    ~<      safe   (Str, Str)\
\\n   Str       left    ~>      safe   (Str, Str)\
\\n   Num       right   **      safe   (Num, Num)\
\\n   Num       left    +       safe   (Num, Num)\
\\n   Num       left    -       safe   (Num, Num)\
\\n   Str       left    ~       safe   (Str, Str)\
\\n   Int       left    +|      safe   (Int, Int)\
\\n   Int       left    +^      safe   (Int, Int)\
\\n   Str       left    ~|      safe   (Str, Str)\
\\n   Str       left    ~^      safe   (Str, Str)\
\\n   Bool      left    ?|      safe   (Bool, Bool)\
\\n   Bool      left    ?^      safe   (Bool, Bool)\
\\n   Bool      left    ?&      safe   (Bool, Bool)\
\\n   Pair      right   =>      safe   (Any, Any)\
\\n   Int       non     cmp     safe   (Any, Any)\
\\n   Int       non     leg     safe   (Str, Str)\
\\n   Int       non     <=>     safe   (Num, Num)\
\\n   List      non     ..      safe   (Scalar, Scalar)\
\\n   List      non     ..^     safe   (Scalar, Scalar)\
\\n   List      non     ^..     safe   (Scalar, Scalar)\
\\n   List      non     ^..^    safe   (Scalar, Scalar)\
\\n   Bool      chain   !=      safe   (Num, Num)\
\\n   Bool      chain   ==      safe   (Num, Num)\
\\n   Bool      chain   =:=     safe   (rw!Any, rw!Any)\
\\n   Bool      chain   ===     safe   (Any, Any)\
\\n   Bool      chain   eqv     safe   (Any, Any)\
\\n   Bool      chain   ~~      safe   (rw!Any, Any)\
\\n   Bool      chain   <       safe   (Num, Num)\
\\n   Bool      chain   <=      safe   (Num, Num)\
\\n   Bool      chain   >       safe   (Num, Num)\
\\n   Bool      chain   >=      safe   (Num, Num)\
\\n   Bool      chain   ne      safe   (Str, Str)\
\\n   Bool      chain   eq      safe   (Str, Str)\
\\n   Bool      chain   lt      safe   (Str, Str)\
\\n   Bool      chain   le      safe   (Str, Str)\
\\n   Bool      chain   gt      safe   (Str, Str)\
\\n   Bool      chain   ge      safe   (Str, Str)\
\\n   Scalar    left    &&      safe   (Bool, ~Bool)\
\\n   Scalar    left    ||      safe   (Bool, ~Bool)\
\\n   Scalar    left    ^^      safe   (Bool, Bool)\
\\n   Scalar    left    //      safe   (Bool, ~Bool)\
\\n   Scalar    left    .[]     safe   (Array, Int)\
\\n   Scalar    left    .{}     safe   (Hash, Str)\
\\n   List      list    Z       safe   (Array)\
\\n   List      list    X       safe   (Array)\
\\n   List      spre    <==     safe   (List)\
\\n   List      left    ==>     safe   (List, Code)\
\\n   Scalar    left    and     safe   (Bool, ~Bool)\
\\n   Scalar    left    or      safe   (Bool, ~Bool)\
\\n   Scalar    left    xor     safe   (Bool, Bool)\
\\n   Scalar    left    orelse  safe   (Bool, ~Bool)\
\\n   Scalar    left    andthen safe   (Bool, ~Bool)\
\\n   Str       pre     chr     safe   (Int)\
\\n   Int       pre     ord     safe   (Str)\
\\n   Str       pre     oct     safe   (Str)\
\\n   Object    pre     stat    unsafe  (Str)\
\\n   Object    pre     lstat   unsafe  (Str)\
\\n   Int       pre     from    safe   (Match)\
\\n   Int       pre     to      safe   (Match)\
\\n   List      pre     matches safe   (Match)\
\\n   Str       pre     oct     safe   (Int)\
\\n   Num       pre     log     safe   (Int)\
\\n   Num       pre     log     safe   (Num)\
\\n   Num       pre     log10   safe   (Num)\
\\n   Thread    pre     async   safe   (Code)\
\\n   Thread    pre     fork    unsafe ()\
\\n   Int       pre     sign    safe   (Num)\
\\n   Bool      pre     kill    safe   (Thread)\
\\n   Int       pre     kill    unsafe (Int, List)\
\\n   Object    pre     Object::new     safe,export   (Object: Named)\
\\n   Object    pre     BUILDALL   safe   (Object)\
\\n   Object    pre     DESTROYALL safe   (Object)\
\\n   Code      pre     TEMP    safe   (rw!Any)\
\\n   Object    pre     Object::clone   safe   (Object: Named)\
\\n   Class     pre     Object::HOW    safe,export   (Object)\
\\n   Object    pre     HOW::new     safe   (Object: Named)\
\\n   Object    pre     HOW::does     safe   (Object: List)\
\\n   Str       pre     Class::name    safe   (Class)\
\\n   Hash      pre     Class::traits  safe   (Class)\
\\n   Object    pre     WHICH      safe   (Any)\
\\n   Int       pre     Rat::numerator   safe   (Rat:)\
\\n   Int       pre     Rat::denominator safe   (Rat:)\
\\n   Bool      pre     Thread::yield   safe   (Thread)\
\\n   List      pre     Pugs::Internals::runShellCommand        unsafe (Str)\
\\n   List      pre     Pugs::Internals::runInteractiveCommand  unsafe (Str)\
\\n   Bool      pre     Pugs::Internals::hSetBinaryMode         unsafe (IO, Str)\
\\n   Void      pre     Pugs::Internals::hSeek                  unsafe (IO, Int, Int)\
\\n   Int       pre     IO::tell                                unsafe,export (IO)\
\\n   Bool      pre     Pugs::Internals::hIsOpen                unsafe (IO)\
\\n   Bool      pre     Pugs::Internals::hIsClosed              unsafe (IO)\
\\n   Bool      pre     Pugs::Internals::hIsReadable            unsafe (IO)\
\\n   Bool      pre     Pugs::Internals::hIsWritable            unsafe (IO)\
\\n   Bool      pre     Pugs::Internals::hIsSeekable            unsafe (IO)\
\\n   IO        pre     Pugs::Internals::openFile               unsafe (Str, Str)\
\\n   List      pre     Pugs::Internals::caller                 safe (Any, Int, Str)\
\\n   Any       pre     Pugs::Internals::check_for_io_leak      safe (Code)\
\\n   Bool      pre     Bool::True  safe   ()\
\\n   Bool      pre     Bool::False safe   ()\
\\n   Bool      pre     True  safe,macro   ()\
\\n   Bool      pre     False safe,macro   ()\
\\n   List      spre    prefix:[,]  safe   (List)\
\\n   List      spre    prefix:@<<    safe   (List)\
\\n   List      spre    prefix:$<<    safe   (List)\
\\n   List      spre    prefix:&<<    safe   (List)\
\\n   List      spre    prefix:%<<    safe   (List)\
\\n   Str       pre     Code::name    safe   (Code:)\
\\n   Int       pre     Code::arity   safe   (Code:)\
\\n   Str       pre     Code::assoc   safe   (Code:)\
\\n   Code::Exp pre     Code::body    safe   (Code:)\
\\n   Str       pre     Code::pos     safe   (Code:)\
\\n   Any       pre     Code::signature     safe   (Code:)\
\\n   IO::Dir   pre     opendir    unsafe (Str)\
\\n   Str       pre     IO::Dir::read       unsafe,export (IO::Dir:)\
\\n   List      pre     IO::Dir::read       unsafe,export (IO::Dir:)\
\\n   Str       pre     IO::Dir::readdir    unsafe,export (IO::Dir:)\
\\n   List      pre     IO::Dir::readdir    unsafe,export (IO::Dir:)\
\\n   Bool      pre     IO::Dir::close      unsafe,export (IO::Dir:)\
\\n   Bool      pre     IO::Dir::closedir   unsafe,export (IO::Dir:)\
\\n   Bool      pre     IO::Dir::rewind     unsafe,export (IO::Dir:)\
\\n   Bool      pre     IO::Dir::rewinddir  unsafe,export (IO::Dir:)\
\\n   Any       pre     Pugs::Internals::reduceVar  unsafe (Str)\
\\n   Str       pre     Pugs::Internals::rule_pattern safe (Regex)\
\\n   Hash      pre     Pugs::Internals::rule_adverbs safe (Regex)\
\\n   Int       pre     Pugs::Internals::install_pragma_value safe (Str, Int)\
\\n   Bool      pre     Pugs::Internals::current_pragma_value safe (Str)\
\\n   Bool      pre     Pugs::Internals::caller_pragma_value safe (Str)\
\\n   Num       pre     Pugs::Internals::base      safe (Int, Any)\
\\n   Any       pre     vv      safe (Any)\
\\n"
