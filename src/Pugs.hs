{-# OPTIONS_GHC -fglasgow-exts -fallow-overlapping-instances #-}

{-|
    Public API for the Pugs system.

>   Dance all ye joyful, now dance all together!
>   Soft is the grass, and let foot be like feather!
>   The river is silver, the shadows are fleeting;
>   Merry is May-time, and merry our meeting.

-}

module Pugs (
    module Pugs,
    Command(..),
    banner,
    liftSTM,
    printCommandLineHelp,
    intro,
    initializeShell,
    getCommand,
    pretty,
    printInteractiveHelp,
) where
import Pugs.Internals
import Pugs.Config
import Pugs.Run
import Pugs.AST
import Pugs.Types
import Pugs.Eval
import Pugs.External
import Pugs.Shell
import Pugs.Parser.Program
import Pugs.Help
import Pugs.Pretty
import Pugs.CodeGen
import Pugs.Embed
import qualified Data.Map as Map
import Data.IORef
import System.FilePath (joinFileName, splitFileName)

{-|
The entry point of Pugs. Uses 'Pugs.Run.runWithArgs' to normalise the command-line
arguments and pass them to 'run'.
-}
pugsMain :: IO ()
pugsMain = do
    let ?debugInfo = Nothing
    mainWith run

defaultProgramName :: String
defaultProgramName = "<interactive>"

runFile :: String -> IO ()
runFile file = do
    withArgs [file] pugsMain

run :: [String] -> IO ()
run xs = let ?debugInfo = Nothing in run' xs

-- see also Run/Args.hs
run' :: (?debugInfo :: DebugInfo) => [String] -> IO ()
run' ("-d":rest)                 = do
    info <- fmap Just (liftSTM $ newTVar Map.empty)
    let ?debugInfo = info
    run' rest
run' ("-l":rest)                 = run' rest
run' ("-w":rest)                 = run' rest
run' ("-I":_:rest)               = run' rest

-- XXX should raise an error here:
-- run ("-I":[])                     = do
--                                    print "Empty -I"

run' ("-h":_)                  = printCommandLineHelp
run' ("-V":_)                  = printConfigInfo []
run' ("-V:":item:_)            = printConfigInfo [item]
run' ("-v":_)                  = banner

-- turn :file: and "-e":frag into a common subroutine/token
run' ("-c":"-e":prog:_)          = doCheck "-e" prog
run' ("-c":file:_)               = readFile file >>= doCheck file

-- -CPIL1.Perl5 outputs PIL formatted as Perl 5.
run' ("-C":backend:args) | (== map toLower backend) `any` ["js","perl5","js-perl5"] = do
    exec <- getArg0
    doHelperRun backend ("--compile-only":("--pugs="++exec):args)
run' ("-C":backend:"-e":prog:_)           = doCompileDump backend "-e" prog
run' ("-C":backend:file:_)                = readFile file >>= doCompileDump backend file

run' ("-B":backend:_) | (== map toLower backend) `any` ["js","perl5","js-perl5"] = do
    exec <- getArg0
    args <- getArgs
    doHelperRun backend (("--pugs="++exec):args)
run' ("-B":backend:"-e":prog:_)           = doCompileRun backend "-e" prog
run' ("-B":backend:file:_)                = readFile file >>= doCompileRun backend file

run' ("--external":mod:"-e":prog:_)       = doExternal mod "-e" prog
run' ("--external":mod:file:_)            = readFile file >>= doExternal mod file

run' ("-e":prog:args)                     = do doRun "-e" args prog
-- -E is like -e, but not accessible as a normal parameter and used only
-- internally:
--   "-e foo bar.pl" executes "foo" with @*ARGS[0] eq "bar.pl",
--   "-E foo bar.pl" executes "foo" and then bar.pl.
-- XXX - Wrong -- Need to preserve environment across -E runs
run' ("-E":prog:rest)            = run' ("-e":prog:[]) >> run' rest
run' ("-":args)                  = do doRun "-" args =<< readStdin
run' (file:args)                 = readFile file >>= doRun file args
run' []                          = do
    isTTY <- hIsTerminalDevice stdin
    if isTTY
        then do banner >> intro >> repLoop
        else run' ["-"]

readStdin :: IO String
readStdin = do
    eof     <- isEOF
    if eof then return [] else do
    ch      <- getChar
    rest    <- readStdin
    return (ch:rest)

repLoop :: IO ()
repLoop = do
    initializeShell
    tvEnv <- liftSTM . newTVar . noEnvDebug =<< tabulaRasa defaultProgramName
    fix $ \loop -> do
        command <- getCommand
        let parseEnv f prog = do
                env <- liftSTM (readTVar tvEnv)
                doParse env f defaultProgramName prog
            resetEnv = do
                tabulaRasa defaultProgramName
                env <- fmap noEnvDebug (tabulaRasa defaultProgramName)
                liftSTM (writeTVar tvEnv env)
        case command of
            CmdQuit           -> putStrLn "Leaving pugs."
            CmdLoad fn        -> doLoad tvEnv fn >> loop
            CmdRun opts prog  -> doRunSingle tvEnv opts prog >> loop
            CmdParse prog     -> parseEnv pretty prog >> loop
            CmdParseRaw prog  -> parseEnv show prog >> loop
            CmdHelp           -> printInteractiveHelp >> loop
            CmdReset          -> resetEnv >> loop

mainWith :: ([String] -> IO a) -> IO ()
mainWith run = do
    hSetBuffering stdout NoBuffering
    when (isJust _DoCompile) $ do
        writeIORef (fromJust _DoCompile) doCompile
    runWithArgs run
    globalFinalize

-- convenience functions for GHCi
eval :: String -> IO ()
eval prog = do
    args <- getArgs
    runProgramWith id (putStrLn . encodeUTF8 . pretty) defaultProgramName args (encodeUTF8 prog)

parse :: String -> IO ()
parse prog = do
    env <- tabulaRasa defaultProgramName
    doParse env (encodeUTF8 . pretty) "-" (encodeUTF8 prog)

dump :: String -> IO ()
dump = (doParseWith $ \env _ -> print $ envBody env) "-"

globalFinalize :: IO ()
globalFinalize = join $ readIORef _GlobalFinalizer

dumpGlob :: String -> IO ()
dumpGlob = (doParseWith $ \env _ -> do
    glob <- liftSTM $ readTVar $ envGlobal env
    print $ filterUserDefinedPad glob) "-"

{-|
Create a \'blank\' 'Env' for our program to execute in. Of course,
'prepareEnv' actually declares quite a few symbols in the environment,
e.g. \'\@\*ARGS\', \'\$\*PID\', \'\$\*ERR\' etc.

('Tabula rasa' is Latin for 'a blank slate'.)
-}
tabulaRasa :: String -> IO Env
tabulaRasa name = prepareEnv name []

doCheck :: FilePath -> String -> IO ()
doCheck = doParseWith $ \_ name -> do
    putStrLn $ name ++ " syntax OK"

doExternal :: String -> FilePath -> String -> IO ()
doExternal mod = doParseWith $ \env _ -> do
    str <- externalize mod $ envBody env
    putStrLn str

doCompile :: String -> FilePath -> String -> IO String
doCompile backend = doParseWith $ \env _ -> do
    globRef <- liftSTM $ do
        glob <- readTVar $ envGlobal env
        newTVar $ filterUserDefinedPad glob
    codeGen backend env{ envGlobal = globRef }

initCompile :: IO ()
initCompile = do
    compPrelude <- getEnv "PUGS_COMPILE_PRELUDE"
    writeIORef _BypassPreludePC $ case compPrelude of
        Nothing     -> True
        Just ""     -> True
        Just "0"    -> True
        _           -> False

doCompileDump :: String -> FilePath -> String -> IO ()
doCompileDump backend file prog = do
    initCompile
    str <- doCompile backend' file prog
    putStr str
    where
    backend' = capitalizeWord backend
    capitalizeWord []     = []
    capitalizeWord (c:cs) = toUpper c:(map toLower cs)

doCompileRun :: String -> FilePath -> String -> IO ()
doCompileRun backend file prog = do
    initCompile
    str <- doCompile backend' file prog
    evalEmbedded backend' str
    where
    backend' = capitalizeWord backend
    capitalizeWord []     = []
    capitalizeWord (c:cs) = toUpper c:(map toLower cs)

doHelperRun :: String -> [String] -> IO ()
doHelperRun backend args =
    case map toLower backend of
        "js"    -> if (args' == [])
                   then (doExecuteHelper "jspugs.pl"  args)
                   else (doExecuteHelper "runjs.pl"   args)
        "perl5" ->       doExecuteHelper "v6.pm" args
        "js-perl5" -> doExecuteHelper "runjs.pl" (jsPerl5Args ++ args)
        _       ->       fail ("unknown backend: " ++ backend)
    where
    args' = f args
    jsPerl5Args = words "--run=jspm --perl5"
    f [] = []
    f (bjs:rest)      | "-BJS" `isPrefixOf` map toUpper bjs = f rest
    f ("-B":js:rest)  | "JS" `isPrefixOf` map toUpper  js = f rest
    f (pugspath:rest) | "--pugs=" `isPrefixOf` pugspath = f rest
    f (x:xs) = x:f xs

doExecuteHelper :: FilePath -> [String] -> IO ()
doExecuteHelper helper args = do
    let searchPaths = concatMap (\x -> map (x++) suffixes) [["."], ["..", ".."], [getConfig "sourcedir"], [getConfig "privlib", "auto", "pugs"], [getConfig "sitelib", "auto", "pugs"]]
    mbin <- findHelper searchPaths
    case mbin of
        Just binary -> do
            exitWith =<< executeFile' perl5 True (binary:args) Nothing
        _ -> fail ("Couldn't find helper program " ++ helper ++ " (searched in " ++ show (map (foldl1 joinFileName) searchPaths) ++ ")")
    where
    suffixes =
        [ []
        , ["perl5", "Pugs-Compiler-Perl6", "lib"]
                                   --  $sourcedir/perl5/Pugs-Compiler-Perl6/v6.pm
        , ["perl5", "PIL2JS"]      --  $sourcedir/perl5/PIL2JS/jspugs.pl
        , ["perl5", "lib"]         --  $pugslibdir/perl5/lib/jspugs.pl
        ]
    perl5 = getConfig "perl5path"
    findHelper :: [[FilePath]] -> IO (Maybe FilePath)
    findHelper []     = return Nothing
    {- interesting riddle: how to do the following monadically?
    findHelper (x:xs)
        | fileExists $ file  x = Just $ file  x
        | fileExists $ file' x = Just $ file' x
        | otherwise            = findHelper xs
    -}
    findHelper (x:xs) = do -- not lazy, but that's not really important here
        filex  <- fileExists (file  x)
        filex' <- fileExists (file' x)
        case () of
            _
                | filex     -> return $ Just $ file  x
                | filex'    -> return $ Just $ file' x
                | otherwise -> findHelper xs
    file  x = foldl1 joinFileName (x ++ [helper])
    file' x = (file x) ++ (getConfig "exe_ext")
    fileExists path = do
        let (p,f) = splitFileName path
        dir <- (fmap Just $ getDirectoryContents p) `catch` (const $ return Nothing)
        case dir of
            Just dir' -> return $ f `elem` dir'
            _         -> return False

doParseWith :: (Env -> FilePath -> IO a) -> FilePath -> String -> IO a
doParseWith f name prog = do
    env <- tabulaRasa name
    f' $ parseProgram env name prog
    where
    f' env | Val err@(VError _ _) <- envBody env = do
        hPutStrLn stderr $ pretty err
        globalFinalize
        exitFailure
    f' env = f env name

doParse :: Env -> (Exp -> String) -> FilePath -> String -> IO ()
doParse env prettyFunc name prog = do
    case envBody $ parseProgram env name prog of
        (Val err@(VError _ _)) -> putStrLn $ pretty err
        exp -> putStrLn $ prettyFunc exp

doLoad :: TVar Env -> String -> IO ()
doLoad env fn = do
    runImperatively env (evaluate exp)
    return ()
    where
    exp = App (_Var "&require") Nothing [Val $ VStr fn]

doRunSingle :: TVar Env -> RunOptions -> String -> IO ()
doRunSingle menv opts prog = (`catch` handler) $ do
    exp     <- makeProper =<< parse
    if exp == Noop then return () else do
    env     <- theEnv
    rv      <- runImperatively env (evaluate exp)
    result  <- case rv of
        VControl (ControlEnv env') -> do
            ref <- liftSTM $ do
                pad <- readTVar (envGlobal env')
                readTVar $ fromJust (findSym (cast "$*_") pad)
            val <- runEvalIO env' $ readRef ref
            liftSTM $ writeTVar menv env'
            return val
        _ -> return rv
    printer env result
    where
    parse = do
        env <- liftSTM $ readTVar menv
        return $ envBody $ parseProgram env defaultProgramName $
          (dropTrailingSemi prog)
    dropTrailingSemi = reverse . dropWhile (`elem` " \t\r\n;") . reverse
    theEnv = do
        ref <- if runOptSeparately opts
                then (liftSTM . newTVar) =<< tabulaRasa defaultProgramName
                else return menv
        debug <- if runOptDebug opts
                then fmap Just (liftSTM $ newTVar Map.empty)
                else return Nothing
        liftSTM $ modifyTVar ref $ \e -> e{ envDebug = debug }
        return ref
    printer env = if runOptShowPretty opts
        then \val -> do
            final <- runImperatively env (fromVal' val)
            putStrLn $ pretty final
        else print
    makeProper exp = case exp of
        Val err@(VError (VStr msg) _)
            | runOptShowPretty opts
            , any (== "unexpected end of input") (lines msg) -> do
            cont <- readline "....> "
            case cont of
                Just line   -> do
                    doRunSingle menv opts (prog ++ ('\n':line))
                    return Noop
                _           -> fail $ pretty err
        Val err@VError{} -> fail $ pretty err
        _ | runOptSeparately opts -> return exp
        _ -> return $ makeDumpEnv exp
    -- XXX Generalize this into structural folding
    makeDumpEnv (Stmts x exp)     = Stmts x   $ makeDumpEnv exp
    makeDumpEnv (Ann ann exp)     = Ann ann   $ makeDumpEnv exp
    makeDumpEnv (Pad x y exp)     = Pad x y   $ makeDumpEnv exp
    makeDumpEnv (Sym x y exp)     = Sym x y   $ makeDumpEnv exp
    makeDumpEnv exp = Stmts exp (Syn "env" [])
    handler err | isUserError err = do
        putStrLn "Internal error while running expression:"
        putStrLn $ ioeGetErrorString err
                | otherwise = ioError err

runImperatively :: TVar Env -> Eval Val -> IO Val
runImperatively menv eval = do
    env <- liftSTM $ readTVar menv
    runEvalIO env $ do
        val <- eval
        newEnv <- ask
        liftSTM $ writeTVar menv newEnv
        return val

doRun :: (?debugInfo :: DebugInfo) => String -> [String] -> String -> IO ()
doRun = do
    runProgramWith (\e -> e{ envDebug = ?debugInfo }) end
    where
    end err@(VError _ _)  = do
        hPutStrLn stderr $ encodeUTF8 $ pretty err
        globalFinalize
        exitFailure
    end (VControl (ControlExit exit)) = do
        globalFinalize
        exitWith exit
    end _ = return ()

noEnvDebug :: Env -> Env
noEnvDebug e = e{ envDebug = Nothing }

runProgramWith ::
    (Env -> Env) -> (Val -> IO a) -> VStr -> [VStr] -> String -> IO a
runProgramWith fenv f name args prog = do
    env <- prepareEnv name args
    val <- runEnv $ parseProgram (fenv env) name prog
    f val

createConfigLine :: String -> String
createConfigLine item = "\t" ++ item ++ ": " ++ (Map.findWithDefault "UNKNOWN" item config)

printConfigInfo :: [String] -> IO ()
printConfigInfo [] = do
    libs <- getLibs
    putStrLn $ unlines $
        ["This is " ++ version ++ " built for " ++ getConfig "archname"
        ,""
        ,"Summary of pugs configuration:" ]
        ++ map (\x -> createConfigLine x) (map (fst) (Map.toList config))
        ++ [ "" ]
        ++ [ "@*INC:" ] ++ libs

printConfigInfo (item:_) = do
        putStrLn $ createConfigLine item

compPIR :: String -> IO ()
compPIR prog = do
    pir <- doCompile "PIR" "-" prog
    putStr $ (subMain ++ (last $ split subMain pir))
    where
    subMain = ".sub main"

runPIR :: String -> IO ()
runPIR prog = do
    pir <- doCompile "PIR" "-" prog
    writeFile "a.pir" pir
    evalParrotFile "a.pir"

{-
withInlinedIncludes :: String -> IO String
withInlinedIncludes prog = do
    libs <- getLibs
    expandInc libs prog
    where
    expandInc :: [FilePath] -> String -> IO String
    expandInc incs str = case breakOnGlue "\nuse " ('\n':str) of
        Nothing -> case breakOnGlue "\nrequire " ('\n':str) of
            Nothing -> return str
            Just (pre, post) -> do
                let (mod, (_:rest)) = span (/= ';') (dropWhile isSpace post)
                mod'    <- includeInc incs mod
                rest'   <- expandInc incs rest
                return $ pre ++ mod' ++ rest'
        Just (pre, post) -> do
            let (mod, (_:rest)) = span isAlphaNum (dropWhile isSpace post)
            mod'    <- includeInc incs mod
            rest'   <- expandInc incs rest
            return $ pre ++ "\n{" ++ mod' ++ "\n}\n" ++ rest'
    includeInc :: [FilePath] -> String -> IO String
    includeInc _ ('v':_) = return []
    includeInc incs name = do
        let name' = concat (intersperse "/" names) ++ ".pm"
            names = split "::" name
        pathName    <- requireInc incs name' (errMsg name incs)
        readFile pathName
    errMsg fn incs = "Can't locate " ++ fn ++ " in @*INC (@*INC contains: " ++ unwords incs ++ ")."
-}
