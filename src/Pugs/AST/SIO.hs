{-# OPTIONS_GHC -cpp -fglasgow-exts -fno-warn-orphans -funbox-strict-fields #-}

module Pugs.AST.SIO (
    MonadSTM(..),

    SIO,

    runSTM, runIO, liftIO, runSIO, stm, io,

    module Control.Concurrent.STM
) where
import Pugs.Internals
import Control.Concurrent.STM

instance Monad m => ((:>:) (m a)) (Identity a) where cast = return . runIdentity
instance ((:>:) (SIO a)) (STM a) where cast = liftSTM

data SIO a = MkSTM !(STM a) | MkIO !(IO a) | MkSIO !a
    deriving (Typeable)

{-# INLINE runSIO #-}
{-# SPECIALISE runSIO :: SIO () -> Maybe () #-}
{-# SPECIALISE runSIO :: SIO () -> Either String () #-}
runSIO :: Monad m => SIO a -> m a
runSIO MkSTM{}      = fail "Unsafe STM caught in pure computation"
runSIO MkIO{}       = fail "Unsafe IO caught in pure computation"
runSIO (MkSIO x)    = return x

{-# INLINE runSTM #-}
{-# SPECIALISE runSTM :: SIO () -> STM () #-}
runSTM :: SIO a -> STM a
runSTM (MkSTM stm)  = stm
runSTM MkIO{}       = fail "Unsafe IO caught in STM"
runSTM (MkSIO x)    = return x

{-# INLINE runIO #-}
{-# SPECIALISE runIO :: SIO () -> IO () #-}
runIO :: SIO a -> IO a
runIO (MkIO io)     = io
runIO (MkSTM stm)   = atomically stm
runIO (MkSIO x)     = return x

instance Monad SIO where
    return a = MkSIO a
    (MkIO io)   >>= k = MkIO $ do { a <- io; runIO (k a) }
    (MkSTM stm) >>= k = MkSTM $ do { a <- stm; runSTM (k a) }
    (MkSIO x)   >>= k = k x

instance Functor SIO where
    fmap = liftM

-- | Typeclass of monadic types that an @STM@ monad can be lifted to.
class (Monad m, Functor m) => MonadSTM m where
    liftSIO :: SIO a -> m a
    liftSIO = fail "liftSIO not detailed for this monad"
    {-# SPECIALISE liftSTM :: STM a -> STM a #-}
    {-# SPECIALISE liftSTM :: STM a -> IO a #-}
    {-# SPECIALISE liftSTM :: STM a -> SIO a #-}
    liftSTM :: STM a -> m a

instance MonadSTM STM where
    liftSTM = id
    liftSIO = runSTM

instance MonadSTM IO where
    liftSTM = atomically
    liftSIO = runIO

instance MonadSTM SIO where
    liftSTM stm = MkSTM stm
    liftSIO = id

instance MonadIO SIO where
    liftIO io = MkIO io

{-# INLINE stm #-}
stm :: (MonadSTM m) => STM a -> m a
stm = liftSTM

io :: (MonadIO m) => IO a -> m a
io = liftIO
