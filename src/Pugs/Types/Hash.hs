type HashIndex = VStr

class (Typeable a) => HashClass a where
    hash_iType :: a -> Type
    hash_iType = const $ mkType "Hash"
    hash_fetch       :: a -> Eval VHash
    hash_fetch hv = do
        keys <- hash_fetchKeys hv
        vals <- mapM (hash_fetchVal hv) keys
        let ps = keys `zip` vals
        return (length ps `seq` Map.fromList ps)
    hash_store       :: a -> VHash -> Eval ()
    hash_store hv vals = do
        hash_clear hv
        forM_ (Map.assocs vals) $ \(key, val) -> do
            hash_storeVal hv key val
    hash_fetchElem   :: a -> HashIndex -> Eval (IVar VScalar) -- autovivify
    hash_fetchElem hv key = do
        return $ proxyScalar (hash_fetchVal hv key) (hash_storeVal hv key)
    hash_storeElem   :: a -> HashIndex -> IVar VScalar -> Eval () -- binding
    hash_storeElem hv idx sv = do
        val <- readIVar sv
        hash_storeVal hv idx val
    hash_fetchVal    :: a -> HashIndex -> Eval Val
    hash_fetchVal hv key = do
        rv <- hash_existsElem hv key
        if rv then readIVar =<< hash_fetchElem hv key
              else return undef
    hash_storeVal    :: a -> HashIndex -> Val -> Eval ()
    hash_storeVal hv key val = do
        sv <- hash_fetchElem hv key
        writeIVar sv val
    hash_fetchKeys   :: a -> Eval [HashIndex]
    hash_fetchKeys hv = do
        vals <- hash_fetch hv
        return $ Map.keys vals
    hash_fetchSize   :: a -> Eval Int
    hash_fetchSize hv = do
        vals <- hash_fetch hv
        return $ Map.size vals
    hash_deleteElem  :: a -> HashIndex -> Eval ()
    hash_existsElem  :: a -> HashIndex -> Eval VBool
    hash_existsElem hv idx = do
        keys <- hash_fetchKeys hv
        return $ idx `elem` keys
    hash_clear       :: a -> Eval ()
    hash_clear hv = do
        keys <- hash_fetchKeys hv
        mapM_ (hash_deleteElem hv) keys
    hash_isEmpty     :: a -> Eval VBool
    hash_isEmpty hv = do
        keys <- hash_fetchKeys hv
        return $ null keys 
    hash_clone :: a -> STM a
    hash_clone = return

instance HashClass (IVar VPair) where
    hash_iType = const $ mkType "Pair"
    hash_fetch pv = do
        (k, v)  <- readIVar pv
        str     <- fromVal k
        return $ Map.singleton str v
    hash_fetchVal pv idx = do
        (k, v)  <- readIVar pv
        str     <- fromVal k
        if str == idx
            then return v
            else return undef
    hash_storeVal _ _ _ = retConstError undef
    hash_deleteElem _ _ = retConstError undef

instance HashClass VHash where
    hash_iType = const $ mkType "Hash::Const"
    hash_fetch = return
    hash_fetchKeys = return . Map.keys
    hash_fetchVal hv idx = return $ Map.findWithDefault undef idx hv
    hash_clear _ = retConstError undef
    hash_store _ _ = retConstError undef
    hash_storeVal _ _ _ = retConstError undef
    hash_storeElem _ _ _ = retConstError undef
    hash_deleteElem _ _ = retConstError undef

instance HashClass IHashEnv where
    hash_iType = const $ mkType "Hash::Env"
    hash_fetch _ = do
        envs <- io getEnvironment
        return . Map.map (VStr . decodeUTF8) $ Map.fromList envs
    hash_fetchVal _ key = tryIO undef $ do
        str <- getEnv key
        return $ fromMaybe VUndef (fmap (VStr . decodeUTF8) str)
    hash_storeVal _ key val = do
        str <- fromVal val
        io $ setEnv key (encodeUTF8 str) True
    hash_existsElem _ key = tryIO False $ do
        str <- getEnv key
        return (isJust str)
    hash_deleteElem _ key = do
        io $ unsetEnv key

encodeKey, decodeKey :: HashIndex -> HashIndex
encodeKey x = x
decodeKey x = x

instance HashClass IHash where
    hash_iType = const $ mkType "Hash"
    hash_clone hv = do
        ps  <- unsafeIOToSTM $ H.toList hv
        ps' <- forM ps $ \(k, sv) -> do
            sv' <- cloneIVar sv
            return (k, sv')
        unsafeIOToSTM $ H.fromList H.hashString ps'
    hash_fetch hv = do
        ps  <- io $ H.toList hv
        ps' <- forM ps $ \(k, sv) -> do
            val <- readIVar sv
            return (decodeKey k, val)
        return (length ps' `seq` Map.fromList ps')
    hash_fetchKeys hv = do
        fmap (map (decodeKey . fst)) (io $ H.toList hv)
    hash_fetchElem hv idx = do
        let idx' = encodeKey idx
        r <- io $ H.lookup hv idx'
        case r of
             Just sv -> return sv
             Nothing -> do
                sv <- newScalar undef
                io $ H.insert hv idx' sv
                return sv
    hash_storeElem hv idx sv = do
        io $ H.insert hv (encodeKey idx) sv
    hash_deleteElem hv idx = do
        io $ H.delete hv (encodeKey idx)
        return ()
    hash_existsElem hv idx = do
        io $ fmap isJust (H.lookup hv (encodeKey idx))

instance HashClass PerlSV where
    hash_iType = const $ mkType "Hash::Perl"
    hash_fetchVal sv key = do
        keySV   <- fromVal $ castV key
        perl5EvalApply "sub { $_[0]->{$_[1]} }" [sv, keySV]
    hash_clear sv = do
        perl5EvalApply "sub { undef %{$_[0]} }" [sv]
        return ()
    hash_storeVal sv key val = do
        keySV   <- fromVal $ castV key
        valSV   <- fromVal val
        perl5EvalApply "sub { $_[0]->{$_[1]} = $_[2] }" [sv, keySV, valSV]
        return ()
    hash_fetchKeys sv = do
        keysSV  <- perl5EvalApply "sub { join $/, keys %{$_[0]} }" [sv]
        keysStr <- fromVal keysSV
        return $ lines keysStr
    hash_deleteElem sv key = do
        keySV   <- fromVal $ castV key
        perl5EvalApply "sub { delete $_[0]->{$_[1]} }" [sv, keySV]
        return ()
    hash_isEmpty sv = do
        fromVal =<< perl5EvalApply "sub { !!%{$_[0]} }" [sv]
