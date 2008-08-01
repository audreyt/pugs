{-# OPTIONS_GHC -fglasgow-exts -fno-warn-orphans -fallow-overlapping-instances #-}

module Pugs.Prim.Match (
    op2Match, rxSplit, rxSplit_n, pkgParents, pkgParentClasses
) where
import Pugs.Internals
import Pugs.Embed
import Pugs.AST
import Pugs.Types
import Pugs.Config
import Pugs.Prim.Code
import Paths_Pugs
import qualified Data.Map as Map
import qualified Data.Array as Array
import qualified Pugs.Prim.FileTest as FileTest

-- XXX - kluge: before we figure out the parrot calling convention,
--       we'll simply inline the adverbs into the regex.
ruleWithAdverbs :: VRule -> Eval VStr
ruleWithAdverbs MkRulePGE{ rxRule = re, rxAdverbs = advs } = do
    when (null re) $
        fail "Null patterns are invalid; use <?null> or an empty string instead"
    hv      <- join $ doHash advs hash_fetch
    advs    <- forM (Map.assocs hv) $ \(k, v) -> do
        str <- case v of
            VBool True  -> return "1"
            VBool False -> return "0"
            _           -> fromVal v
        return $ \x -> ":" ++ k ++ "(" ++ str ++ ")[" ++ x ++ "]"
    return $ combine advs re
ruleWithAdverbs _ = fail "PCRE regexes can't be compiled to PGE regexes"

doMatch :: String -> VRule -> Eval VMatch
doMatch cs rule@MkRulePGE{ rxRule = ruleStr } = do
    pwd     <- io $ getDataFileName "blib6/pugs/perl5/lib"
    glob    <- askGlobal
    let syms = [ (cast $ v_name var, entry)
               | (var, entry) <- padToList glob
               , SRegex == v_sigil var
               , isGlobalVar var
               ]
    subrules <- forM syms $ \(name, entry) -> do
        ref         <- readPadEntry entry
        VRule rule  <- fromVal =<< readRef ref
        text        <- ruleWithAdverbs rule
        return (name, text)
    text <- ruleWithAdverbs rule
    rv   <- io $ fmap (fmap (fmap toUpper)) (getEnv "PUGS_REGEX_ENGINE")
    let ruleEngine | Just "PGE" <- rv   = evalPGE
                   | otherwise          = evalPCR
    pge  <- io $ ruleEngine pwd cs text subrules
            `catchIO` (\e -> return $ show e)
    rv  <- tryIO Nothing $ fmap Just (readIO $ decodeUTF8 pge)
    let matchToVal PGE_Fail = VMatch mkMatchFail
        matchToVal (PGE_String str) = VStr str
        matchToVal (PGE_Array ms) = VList (map matchToVal ms)
        matchToVal (PGE_Match from to pos named) = VMatch $
            mkMatchOk from to substr pos' named'
            where
            substr  = genericTake (to - from) (genericDrop from cs)
            pos'    = map matchToVal pos
            named'  = Map.map matchToVal $ Map.fromList named
    case rv of
        Just m  -> fromVal (matchToVal m)
        Nothing -> do
            io $ putStrLn ("*** Cannot parse regex: " ++ ruleStr ++ "\n*** Error: " ++ pge)
            return mkMatchFail

doMatch csChars MkRulePCRE{ rxRegex = re } = do
    result <- io $ executePCRE re csBytes
    case result of
        Left{} -> return mkMatchFail
        Right Nothing -> return mkMatchFail
        Right (Just rv) -> do
            let ((fromBytes, lenBytes):subs) = Array.elems rv
                substr str from len = take len (drop from str)
                subsMatch = [
                    VMatch $ if fBytes == -1 then mkMatchFail else mkMatchOk
                        fChars (fChars + lChars)
                        (substr csChars fChars lChars)
                        [] Map.empty
                    | (fBytes, lBytes) <- subs
                    , let fChars = chars $ take fBytes csBytes
                    , let lChars = chars $ substr csBytes fBytes lBytes
                    ]
                fromChars = chars $ take fromBytes csBytes
                lenChars  = chars $ substr csBytes fromBytes lenBytes
                chars = genericLength . decodeUTF8
            return $ mkMatchOk fromChars (fromChars + lenChars)
                (substr csChars fromChars lenChars) subsMatch Map.empty
    where
    csBytes = encodeUTF8 csChars

-- Used in op2Match
not_VRule :: Val -> Bool
not_VRule _y@(VRule _) = False
not_VRule _            = True

classType :: Type
classType = mkType "Class"

-- XXX - need to generalise this
op2Match :: Val -> Val -> Eval Val

op2Match x y@(VCode _) = do
    (arity :: Int) <- fromVal =<< op1CodeArity y
    res <- fromVal =<< case arity of
        0 -> do
            writeVar (cast "$*_") x
            evalExp $ App (Val y) Nothing []
        1 -> do
            evalExp $ App (Val y) Nothing [Val x]
        _ -> fail ("Unexpected arity in smart match: " ++ (show arity))
    return $ VBool $ res

op2Match x (VRef (MkRef (IScalar sv))) | scalar_iType sv == mkType "Scalar::Const" = do
    y' <- scalar_fetch' sv
    op2Match x y'

op2Match x (VRef (MkRef (IPair pv))) = do 
    -- Pair match: ~~ :e executes the -e filetest.
    (k, v)  <- pair_fetch pv
    isTrue  <- fromVal v :: Eval Bool
    testOp  <- fromVal k
    file    <- fromVal x
    rv      <- ($ file) $ case testOp of
        "r" -> FileTest.isReadable
        "w" -> FileTest.isWritable
        "x" -> FileTest.isExecutable
        "e" -> FileTest.exists
        "z" -> FileTest.sizeIsZero
        "s" -> FileTest.fileSize
        "M" -> FileTest.fileMTime
        "A" -> FileTest.fileATime
        "C" -> FileTest.fileCTime
        "f" -> FileTest.isFile
        "d" -> FileTest.isDirectory
        [op] | op `elem` "oRWXOlpSbctugkTB" -> FileTest.fileTestViaPerl5 testOp
        _   -> const $ die "Unknown file test operator" testOp
    if isTrue
        then return rv
        else fmap (castV . not) (fromVal rv)

op2Match x (VRef y) = do
    y' <- readRef y
    op2Match x y'

op2Match x@(VObject MkObject{ objType = cls }) y | cls == classType = do
    fetch   <- doHash x hash_fetchVal
    name    <- fromVal =<< fetch "name"
    op2Match (VType (mkType name)) y

op2Match x y@(VObject MkObject{ objType = cls }) | cls == classType = do
    fetch   <- doHash y hash_fetchVal
    name    <- fromVal =<< fetch "name"
    op2Match x (VType (mkType name))

-- '$x ~~ tr/x/y/' ==> $x = ~$x.trans('x' => 'y')
op2Match x (VSubst (MkTrans from to)) = do
    str <- fromVal x
    evalExp $ Syn "="
        [ Val x
        , App (_Var "&trans") (Just (Val (VStr str)))
            [ App (_Var "&infix:=>") Nothing
                [ Val (VStr from)
                , Val (VStr to)
                ]
            ]
        ]

op2Match x (VSubst (MkSubst rx subst)) | rxGlobal rx = do
    str         <- fromVal x
    (str', cnt) <- doReplace str 0
    if cnt == 0 then return (VBool False) else do
    ref     <- fromVal x
    writeRef ref $ VStr str'
    return $ castV cnt
    where
    doReplace :: String -> Int -> Eval (String, Int)
    doReplace str ok = do
        match <- str `doMatch` rx
        if not (matchOk match) then return (str, ok) else do
        glob    <- askGlobal
        matchSV <- findSymRef (cast "$/") glob
        writeRef matchSV (VMatch match)
        str'    <- fromVal =<< evalExp subst
        -- XXX - on zero-width match, advance the cursor and, if can't,
        --       don't even bother with the recursive call.
        case (matchTo match, matchFrom match) of
            (0, 0) -> if null str then return (str' ++ str, ok) else do
                (after', ok') <- doReplace (tail str) (ok + 1)
                return (concat [str' ++ (head str:after')], ok')
            (to, from) -> do
                (after', ok') <- doReplace (genericDrop to str) (ok + 1)
                return (concat [genericTake from str, str', after'], ok')

op2Match x (VSubst (MkSubst rx subst)) = do
    str     <- fromVal x
    ref     <- fromVal x
    match   <- str `doMatch` rx
    if not (matchOk match) then return (VBool False) else do
    glob    <- askGlobal
    matchSV <- findSymRef (cast "$/") glob
    writeRef matchSV (VMatch match)
    str'    <- fromVal =<< evalExp subst
    writeRef ref . VStr $ concat
        [ genericTake (matchFrom match) str
        , str'
        , genericDrop (matchTo match) str
        ]
    return $ VBool True

op2Match x (VRule rx) | rxGlobal rx = do
    str     <- fromVal x
    rv      <- matchOnce str
    cxt     <- asks envContext
    case rxStringify rx of
        True -> do
            strs <- mapM fromVal rv
            return $ case strs of
                [str]   -> VStr str
                _       -> VList $ map VStr strs
        _ | isSlurpyCxt cxt -> do
            return (VList rv)
        _ -> do
            return (VInt $ genericLength rv)
    where
    hasSubpatterns = case rx of
        MkRulePGE{}             -> True -- XXX bogus - use <p6rule> to parse itself
        MkRulePCRE{rxNumSubs=n} -> not (n == 0)
    matchOnce :: String -> Eval [Val]
    matchOnce str = do
        match <- str `doMatch` rx
        if not (matchOk match) then return [] else do
        let ret x = return $ if hasSubpatterns
                        then [ m | m@(VMatch MkMatch{ matchOk = True }) <- matchSubPos match ] ++ x
                        else (VMatch match):x
        case (matchTo match, matchFrom match) of
            (0, 0) -> if null str then ret [] else do
                rest <- matchOnce (tail str)
                ret rest
            (to, _) -> do
                rest <- matchOnce (genericDrop to str)
                ret rest

op2Match x (VRule rx) = do
    str     <- fromVal x
    match   <- str `doMatch` rx
    glob    <- askGlobal
    matchSV <- findSymRef (cast "$/") glob
    writeRef matchSV (VMatch match)
    ifListContext
        (return $ VList (matchSubPos match))
        (return $ VMatch match)

op2Match x@(VRule _) y | not_VRule y = do
    op2Match y x

op2Match (VType typ) (VType t) = do
    typs <- pkgParents (showType typ)
    return . VBool $ showType t `elem` (showType typ:typs)

op2Match x y@(VType _) = do
    typ <- fromVal x
    case x of
        VRef x | typ == mkType "Class" -> do
            x' <- readRef x
            op2Match x' y
        _ -> op2Match (VType typ) y

op2Match (VRef x) y = do
    x' <- readRef x
    op2Match x' y

op2Match x y = do
    op2Cmp (fromVal :: Val -> Eval VStr) (==) x y

op2Cmp :: (a -> Eval b) -> (b -> b -> VBool) -> a -> a -> Eval Val
op2Cmp f cmp x y = do
    x' <- f x
    y' <- f y
    return $ VBool $ x' `cmp` y'

rxSplit :: VRule -> String -> Eval [Val]
rxSplit _  [] = return []
rxSplit rx str = do
    match <- str `doMatch` rx
    if not (matchOk match) then return [VStr str] else do
    if matchFrom match == matchTo match
        then do
            let (c:cs) = str
            rest <- rxSplit rx cs
            return (VStr [c]:rest)
        else do
            let before = genericTake (matchFrom match) str
                after  = genericDrop (matchTo match) str
            rest <- rxSplit rx after
            return $ (VStr before:matchSubPos match) ++ rest

-- duplicated for now, pending über-Haskell-fu

rxSplit_n :: VRule -> String -> Int -> Eval [Val]
rxSplit_n _ [] _ = return []
rxSplit_n rx str n = do
    match <- str `doMatch` rx
    if or [ ( n == 1 ), ( not (matchOk match) ) ] then return [VStr str] else do
    if matchFrom match == matchTo match
        then do
            let (c:cs) = str
            rest <- rxSplit_n rx (cs) (n-1)
            return (VStr [c]:rest)
        else do
            let before = genericTake (matchFrom match) str
                after  = genericDrop (matchTo match) str
            rest <- rxSplit_n rx after (n-1)
            return $ (VStr before:matchSubPos match) ++ rest

pkgParents :: VStr -> Eval [VStr]
pkgParents pkg = do
    ref     <- readVar $ cast (':':'*':pkg)
    if ref == undef then return [] else do
    meta    <- readRef =<< fromVal ref
    fetch   <- doHash meta hash_fetchVal
    attrs   <- fromVal =<< fetch "is"
    attrs'  <- fromVal =<< fetch "does" -- XXX wrong
    pkgs    <- mapM pkgParents (attrs ++ attrs')
    return $ nub (pkg:concat pkgs)

-- XXX - copy and paste code; merge with above!
pkgParentClasses :: VStr -> Eval [VStr]
pkgParentClasses pkg = do
    ref     <- readVar $ cast (':':'*':pkg)
    if ref == undef then return [] else do
    meta    <- readRef =<< fromVal ref
    fetch   <- doHash meta hash_fetchVal
    attrs   <- fromVal =<< fetch "is"
    pkgs    <- mapM pkgParentClasses attrs
    return $ nub (pkg:concat pkgs)
