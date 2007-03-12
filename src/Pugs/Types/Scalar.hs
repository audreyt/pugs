
class (Typeable a) => ScalarClass a where
    scalar_iType :: a -> Type
    scalar_iType = const $ mkType "Scalar"
    scalar_fetch :: a -> Eval VScalar
    scalar_store :: a -> VScalar -> Eval ()
    scalar_const :: a -> Maybe VScalar
    scalar_clone :: a -> STM a
    scalar_clone = return
    scalar_fetch' :: a -> Eval VScalar
    scalar_fetch' x = scalar_fetch x
    scalar_type  :: a -> Eval Type
    scalar_type x = do
        v <- scalar_fetch x
        evalValType v

instance ScalarClass IScalarProxy where
    scalar_iType = const $ mkType "Scalar::Proxy"
    scalar_fetch = fst
    scalar_store = snd
    scalar_const = const Nothing

instance ScalarClass IScalar where
    scalar_fetch = stm . readTVar
    scalar_store = (stm .) . writeTVar
    scalar_const = const Nothing
    scalar_clone sv = newTVar =<< readTVar sv

instance ScalarClass IScalarLazy where
    scalar_iType = const $ mkType "Scalar::Lazy"
    scalar_fetch = return . maybe undef id
    scalar_store d _ = retConstError $ VStr $ show d
    scalar_const = const Nothing

instance ScalarClass IScalarCwd where
    scalar_iType = const $ mkType "Scalar::Cwd"
    scalar_fetch _ = do
        str <- io getCurrentDirectory
        return $ VStr str
    scalar_store _ val = do
        str <- fromVal val
        tryIO () $ setCurrentDirectory str
    scalar_const = const Nothing

instance ScalarClass VScalar where
    scalar_iType = const $ mkType "Scalar::Const"
    -- scalar_fetch v@(VRef (MkRef IPair{})) = return v
    scalar_fetch (VRef (MkRef (IScalar sv))) = scalar_fetch sv
    scalar_fetch v = return v
    scalar_store d _ = retConstError d
    scalar_const = Just
    scalar_type (VRef (MkRef (IScalar sv))) = scalar_type sv
    scalar_type v = return $ valType v
    scalar_fetch' v = return v

