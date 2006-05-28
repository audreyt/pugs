{-# OPTIONS_GHC -cpp -fglasgow-exts #-}
--
-- Module      : ByteString.Base
-- License     : BSD-style
-- Maintainer  : dons@cse.unsw.edu.au
-- Stability   : experimental
-- Portability : portable, requires ffi and cpp
-- Tested with : GHC 6.4.1 and Hugs March 2005
-- 

-- | A module containing semi-public ByteString internals. This exposes
-- the ByteString representation and low level construction functions.
-- Modules which extend the ByteString system will need to use this module
-- while ideally most users will be able to make do with the public interface
-- modules.
--
module Data.ByteString.Base (

        -- * The @ByteString@ type and representation
        ByteString(..),             -- instances: Eq, Ord, Show, Read, Data, Typeable

        -- * Unchecked access
        unsafeHead,             -- :: ByteString -> Word8
        unsafeTail,             -- :: ByteString -> ByteString
        unsafeIndex,            -- :: ByteString -> Int -> Word8
        unsafeTake,             -- :: Int -> ByteString -> ByteString
        unsafeDrop,             -- :: Int -> ByteString -> ByteString

        -- * Low level introduction and elimination
        generate,               -- :: Int -> (Ptr Word8 -> IO Int) -> IO ByteString
        create,                 -- :: Int -> (Ptr Word8 -> IO ()) -> ByteString
        mallocByteString,
        fromForeignPtr,         -- :: ForeignPtr Word8 -> Int -> ByteString
        toForeignPtr,           -- :: ByteString -> (ForeignPtr Word8, Int, Int)
        skipIndex,              -- :: ByteString -> Int

#if defined(__GLASGOW_HASKELL__)
        packCStringFinalizer,   -- :: Ptr Word8 -> Int -> IO () -> IO ByteString
        packAddress,            -- :: Addr# -> ByteString
        unsafePackAddress,      -- :: Int -> Addr# -> ByteString
        unsafeFinalize,         -- :: ByteString -> IO ()
#endif

        -- * Utilities
        inlinePerformIO,            -- :: IO a -> a

        countOccurrences,           -- :: (Storable a, Num a) => Ptr a -> Ptr Word8 -> Int -> IO ()

        -- * Standard C Functions
        c_strlen,                   -- :: CString -> CInt
        c_malloc,                   -- :: CInt -> IO (Ptr Word8)
        c_free,                     -- :: Ptr Word8 -> IO ()

#if !defined(__GLASGOW_HASKELL__)
        c_free_finalizer,           -- :: FunPtr (Ptr Word8 -> IO ())
#endif

        memchr,                     -- :: Ptr Word8 -> Word8 -> CSize -> Ptr Word8
        memcmp,                     -- :: Ptr Word8 -> Ptr Word8 -> CSize -> IO CInt
        memcpy,                     -- :: Ptr Word8 -> Ptr Word8 -> CSize -> IO ()
        memset,                     -- :: Ptr Word8 -> Word8 -> CSize -> IO (Ptr Word8)

        -- * cbits functions
        c_reverse,                  -- :: Ptr Word8 -> Ptr Word8 -> CInt -> IO ()
        c_intersperse,              -- :: Ptr Word8 -> Ptr Word8 -> CInt -> Word8 -> IO ()
        c_maximum,                  -- :: Ptr Word8 -> CInt -> Word8
        c_minimum,                  -- :: Ptr Word8 -> CInt -> Word8
        c_count,                    -- :: Ptr Word8 -> CInt -> Word8 -> CInt

        -- * Internal GHC magic
#if defined(__GLASGOW_HASKELL__)
        getProgArgv,                -- :: Ptr CInt -> Ptr (Ptr CString) -> IO ()
        memcpy_ptr_baoff,           -- :: Ptr a -> RawBuffer -> CInt -> CSize -> IO (Ptr ())
#endif

        -- * Chars
        w2c, c2w, isSpaceWord8

  ) where

import Foreign.ForeignPtr
import Foreign.Ptr
import Foreign.Storable         (Storable(..))
import Foreign.C.Types
import Foreign.C.String         (CString)

import Control.Exception        (assert)

import Data.Char                (ord)
import Data.Word                (Word8)

#if defined(__GLASGOW_HASKELL__)
import qualified Foreign.Concurrent as FC (newForeignPtr)

import Data.Generics            (Data(..), Typeable(..))
import GHC.Prim                 (Addr#)
import GHC.Ptr                  (Ptr(..))
import GHC.Base                 (realWorld#,unsafeChr)
import GHC.IOBase
#else
import Data.Char                (chr)
import System.IO.Unsafe         (unsafePerformIO)
#endif

-- CFILES stuff is Hugs only
{-# CFILES cbits/fpstring.c #-}

-- -----------------------------------------------------------------------------
--
-- Useful macros, until we have bang patterns
--

#define STRICT1(f) f a | a `seq` False = undefined
#define STRICT2(f) f a b | a `seq` b `seq` False = undefined
#define STRICT3(f) f a b c | a `seq` b `seq` c `seq` False = undefined
#define STRICT4(f) f a b c d | a `seq` b `seq` c `seq` d `seq` False = undefined
#define STRICT5(f) f a b c d e | a `seq` b `seq` c `seq` d `seq` e `seq` False = undefined

-- -----------------------------------------------------------------------------

-- | A space-efficient representation of a Word8 vector, supporting many
-- efficient operations.  A 'ByteString' contains 8-bit characters only.
--
-- Instances of Eq, Ord, Read, Show, Data, Typeable
--
data ByteString = PS {-# UNPACK #-} !(ForeignPtr Word8)
                     {-# UNPACK #-} !Int                -- offset
                     {-# UNPACK #-} !Int                -- length

#if defined(__GLASGOW_HASKELL__)
    deriving (Data, Typeable)
#endif

-- ---------------------------------------------------------------------
--
-- Extensions to the basic interface
--

-- | A variety of 'head' for non-empty ByteStrings. 'unsafeHead' omits the
-- check for the empty case, so there is an obligation on the programmer
-- to provide a proof that the ByteString is non-empty.
unsafeHead :: ByteString -> Word8
unsafeHead (PS x s _) = inlinePerformIO $ withForeignPtr x $ \p -> peekByteOff p s
{-# INLINE unsafeHead #-}

-- | A variety of 'tail' for non-empty ByteStrings. 'unsafeTail' omits the
-- check for the empty case. As with 'unsafeHead', the programmer must
-- provide a separate proof that the ByteString is non-empty.
unsafeTail :: ByteString -> ByteString
unsafeTail (PS ps s l) = PS ps (s+1) (l-1)
{-# INLINE unsafeTail #-}

-- | Unsafe 'ByteString' index (subscript) operator, starting from 0, returning a 'Word8'
-- This omits the bounds check, which means there is an accompanying
-- obligation on the programmer to ensure the bounds are checked in some
-- other way.
unsafeIndex :: ByteString -> Int -> Word8
unsafeIndex (PS x s _) i = inlinePerformIO $ withForeignPtr x $ \p -> peekByteOff p (s+i)
{-# INLINE unsafeIndex #-}

-- | A variety of 'take' which omits the checks on @n@ so there is an
-- obligation on the programmer to provide a proof that @0 <= n <= 'length' xs@.
unsafeTake :: Int -> ByteString -> ByteString
unsafeTake n (PS x s l) =
  assert (0 <= n && n <= l) $ PS x s n
{-# INLINE unsafeTake #-}

-- | A variety of 'drop' which omits the checks on @n@ so there is an
-- obligation on the programmer to provide a proof that @0 <= n <= 'length' xs@.
unsafeDrop  :: Int -> ByteString -> ByteString
unsafeDrop n (PS x s l) =
  assert (0 <= n && n <= l) $ PS x (s+n) (l-n)
{-# INLINE unsafeDrop #-}

-- ---------------------------------------------------------------------
-- Low level constructors

-- | /O(1)/ Build a ByteString from a ForeignPtr
fromForeignPtr :: ForeignPtr Word8 -> Int -> ByteString
fromForeignPtr fp l = PS fp 0 l

-- | /O(1)/ Deconstruct a ForeignPtr from a ByteString
toForeignPtr :: ByteString -> (ForeignPtr Word8, Int, Int)
toForeignPtr (PS ps s l) = (ps, s, l)

-- | /O(1)/ 'skipIndex' returns the internal skipped index of the
-- current 'ByteString' from any larger string it was created from, as
-- an 'Int'.
skipIndex :: ByteString -> Int
skipIndex (PS _ s _) = s
{-# INLINE skipIndex #-}

-- | A way of creating ForeignPtrs outside the IO monad. The @Int@
-- argument gives the final size of the ByteString. Unlike 'generate'
-- the ByteString is not reallocated if the final size is less than the
-- estimated size. Also, unlike 'generate' ByteString's created this way
-- are managed on the Haskell heap.
create :: Int -> (Ptr Word8 -> IO ()) -> ByteString
create l write_ptr = inlinePerformIO $ do
    fp <- mallocByteString (l+1)
    withForeignPtr fp $ \p -> write_ptr p
    return $ PS fp 0 l
{-# INLINE create #-}

-- | Given the maximum size needed and a function to make the contents
-- of a ByteString, generate makes the 'ByteString'. The generating
-- function is required to return the actual final size (<= the maximum
-- size), and the resulting byte array is realloced to this size.  The
-- string is padded at the end with a null byte.
--
-- generate is the main mechanism for creating custom, efficient
-- ByteString functions, using Haskell or C functions to fill the space.
--
generate :: Int -> (Ptr Word8 -> IO Int) -> IO ByteString
generate i f = do
    fp      <- mallocByteString i
    (ptr,n) <- withForeignPtr fp $ \p -> do
        i' <- f p
        if i' == i
            then return (fp,i')
            else do fp_ <- mallocByteString i'      -- realloc
                    withForeignPtr fp_ $ \p' -> memcpy p' p (fromIntegral i')
                    return (fp_,i')
    return (PS ptr 0 n)

-- Wrapper of mallocForeignPtrArray. Any ByteString allocated this way
-- is padded with a null byte.
mallocByteString :: Int -> IO (ForeignPtr Word8)
mallocByteString l = do
    fp <- mallocForeignPtrArray (l+1)
    withForeignPtr fp $ \p -> poke (p `plusPtr` l) (0::Word8)
    return fp

{-
--
-- On the C malloc heap. Less fun.
--
generate i f = do
    p <- mallocArray (i+1)
    i' <- f p
    p' <- reallocArray p (i'+1)
    poke (p' `plusPtr` i') (0::Word8)    -- XXX so CStrings work
    fp <- newForeignFreePtr p'
    return $ PS fp 0 i'
-}

#if defined(__GLASGOW_HASKELL__)
-- | /O(n)/ Pack a null-terminated sequence of bytes, pointed to by an
-- Addr\# (an arbitrary machine address assumed to point outside the
-- garbage-collected heap) into a @ByteString@. A much faster way to
-- create an Addr\# is with an unboxed string literal, than to pack a
-- boxed string. A unboxed string literal is compiled to a static @char
-- []@ by GHC. Establishing the length of the string requires a call to
-- @strlen(3)@, so the Addr# must point to a null-terminated buffer (as
-- is the case with "string"# literals in GHC). Use 'unsafePackAddress'
-- if you know the length of the string statically.
--
-- An example:
--
-- > literalFS = packAddress "literal"#
--
packAddress :: Addr# -> ByteString
packAddress addr# = inlinePerformIO $ do
    p <- newForeignPtr_ cstr
    return $ PS p 0 (fromIntegral $ c_strlen cstr)
  where
    cstr = Ptr addr#
{-# INLINE packAddress #-}

-- | /O(1)/ 'unsafePackAddress' provides constant-time construction of
-- 'ByteStrings' -- which is ideal for string literals. It packs a
-- null-terminated sequence of bytes into a 'ByteString', given a raw
-- 'Addr\#' to the string, and the length of the string. Make sure the
-- length is correct, otherwise use the safer 'packAddress' (where the
-- length will be calculated once at runtime).
unsafePackAddress :: Int -> Addr# -> ByteString
unsafePackAddress len addr# = inlinePerformIO $ do
    p <- newForeignPtr_ cstr
    return $ PS p 0 len
    where cstr = Ptr addr#

-- | /O(1)/ Construct a 'ByteString' given a C Ptr Word8 buffer, a
-- length, and an IO action representing a finalizer. This function is
-- not available on Hugs.
--
packCStringFinalizer :: Ptr Word8 -> Int -> IO () -> IO ByteString
packCStringFinalizer p l f = do
    fp <- FC.newForeignPtr p f
    return $ PS fp 0 l

-- | Explicitly run the finaliser associated with a 'ByteString'.
-- Further references to this value may generate invalid memory
-- references. This operation is unsafe, as there may be other
-- 'ByteStrings' referring to the same underlying pages. If you use
-- this, you need to have a proof of some kind that all 'ByteString's
-- ever generated from the underlying byte array are no longer live.
unsafeFinalize :: ByteString -> IO ()
unsafeFinalize (PS p _ _) = finalizeForeignPtr p

#endif

------------------------------------------------------------------------

-- | Conversion between 'Word8' and 'Char'. Should compile to a no-op.
w2c :: Word8 -> Char
#if !defined(__GLASGOW_HASKELL__)
w2c = chr . fromIntegral
#else
w2c = unsafeChr . fromIntegral
#endif
{-# INLINE w2c #-}

-- | Unsafe conversion between 'Char' and 'Word8'. This is a no-op and
-- silently truncates to 8 bits Chars > '\255'. It is provided as
-- convenience for ByteString construction.
c2w :: Char -> Word8
c2w = fromIntegral . ord
{-# INLINE c2w #-}

-- Selects white-space characters in the Latin-1 range
-- ordered by frequency
-- Idea from Ketil
isSpaceWord8 :: Word8 -> Bool
isSpaceWord8 w = case w of
    0x20 -> True -- SPACE
    0x0A -> True -- LF, \n
    0x09 -> True -- HT, \t
    0x0C -> True -- FF, \f
    0x0D -> True -- CR, \r
    0x0B -> True -- VT, \v
    0xA0 -> True -- spotted by QC..
    _    -> False
{-# INLINE isSpaceWord8 #-}

------------------------------------------------------------------------
-- | Just like unsafePerformIO, but we inline it. Big performance gains as
-- it exposes lots of things to further inlining
--
{-# INLINE inlinePerformIO #-}
inlinePerformIO :: IO a -> a
#if defined(__GLASGOW_HASKELL__)
inlinePerformIO (IO m) = case m realWorld# of (# _, r #) -> r
#else
inlinePerformIO = unsafePerformIO
#endif

-- | Count the number of occurrences of each byte.
--
{-# SPECIALIZE countOccurrences :: Ptr CSize -> Ptr Word8 -> Int -> IO () #-}
countOccurrences :: (Storable a, Num a) => Ptr a -> Ptr Word8 -> Int -> IO ()
STRICT3(countOccurrences)
countOccurrences counts str l = go 0
 where
    STRICT1(go)
    go i | i == l    = return ()
         | otherwise = do k <- fromIntegral `fmap` peekElemOff str i
                          x <- peekElemOff counts k
                          pokeElemOff counts k (x + 1)
                          go (i + 1)

-- ---------------------------------------------------------------------
-- 
-- Standard C functions
--

foreign import ccall unsafe "string.h strlen" c_strlen
    :: CString -> CInt

foreign import ccall unsafe "stdlib.h malloc" c_malloc
    :: CInt -> IO (Ptr Word8)

foreign import ccall unsafe "static stdlib.h free" c_free
    :: Ptr Word8 -> IO ()

#if !defined(__GLASGOW_HASKELL__)
foreign import ccall unsafe "static stdlib.h &free" c_free_finalizer
    :: FunPtr (Ptr Word8 -> IO ())
#endif

foreign import ccall unsafe "string.h memchr" memchr
    :: Ptr Word8 -> Word8 -> CSize -> Ptr Word8

foreign import ccall unsafe "string.h memcmp" memcmp
    :: Ptr Word8 -> Ptr Word8 -> CSize -> IO CInt

foreign import ccall unsafe "string.h memcpy" memcpy
    :: Ptr Word8 -> Ptr Word8 -> CSize -> IO ()

foreign import ccall unsafe "string.h memset" memset
    :: Ptr Word8 -> Word8 -> CSize -> IO (Ptr Word8)


-- ---------------------------------------------------------------------
--
-- Uses our C code
--

foreign import ccall unsafe "static fpstring.h reverse" c_reverse
    :: Ptr Word8 -> Ptr Word8 -> CInt -> IO ()

foreign import ccall unsafe "static fpstring.h intersperse" c_intersperse
    :: Ptr Word8 -> Ptr Word8 -> CInt -> Word8 -> IO ()

foreign import ccall unsafe "static fpstring.h maximum" c_maximum
    :: Ptr Word8 -> CInt -> Word8

foreign import ccall unsafe "static fpstring.h minimum" c_minimum
    :: Ptr Word8 -> CInt -> Word8

foreign import ccall unsafe "static fpstring.h count" c_count
    :: Ptr Word8 -> CInt -> Word8 -> CInt

-- ---------------------------------------------------------------------
-- MMap

{-
foreign import ccall unsafe "static fpstring.h my_mmap" my_mmap
    :: Int -> Int -> IO (Ptr Word8)

foreign import ccall unsafe "static unistd.h close" c_close
    :: Int -> IO Int

#  if !defined(__OpenBSD__)
foreign import ccall unsafe "static sys/mman.h munmap" c_munmap
    :: Ptr Word8 -> Int -> IO Int
#  endif
-}

-- ---------------------------------------------------------------------
-- Internal GHC Haskell magic

#if defined(__GLASGOW_HASKELL__)
foreign import ccall unsafe "RtsAPI.h getProgArgv"
    getProgArgv :: Ptr CInt -> Ptr (Ptr CString) -> IO ()

foreign import ccall unsafe "__hscore_memcpy_src_off"
   memcpy_ptr_baoff :: Ptr a -> RawBuffer -> CInt -> CSize -> IO (Ptr ())
#endif
