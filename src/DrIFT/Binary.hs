{-# OPTIONS_GHC -fglasgow-exts -w #-}
--
-- (c) The University of Glasgow 2002
--
-- Binary I/O library, with special tweaks for GHC
--
-- Based on the nhc98 Binary library, which is copyright
-- (c) Malcolm Wallace and Colin Runciman, University of York, 1998.
-- Under the terms of the license for that software, we must tell you
-- where you can obtain the original version of the Binary library, namely
--     http://www.cs.york.ac.uk/fp/nhc98/

-- arch-tag: 1418e09a-9a18-4dca-a0fc-9262c9d97beb

module DrIFT.Binary
  ( {-type-}  Bin,
    {-class-} Binary(..),
    {-type-}  BinHandle,

   openBinIO, openBinIO_,
   openBinMem,
--   closeBin,

   seekBin,
   tellBin,
   castBin,

   writeBinMem,
   readBinMem,

   isEOFBin,

   -- for writing instances:
   putByte,
   getByte,

   -- lazy Bin I/O
   lazyGet,
   lazyPut,

   -- GHC only:
   ByteArray(..),
   getByteArray,
   putByteArray,

   --getBinFileWithDict,	-- :: Binary a => FilePath -> IO a
   --putBinFileWithDict,	-- :: Binary a => FilePath -> ModuleName -> a -> IO ()

  ) where


import Data.Array.IO
import Data.Array
import Data.Bits
import Data.Int
import Data.Word
import Data.IORef
import Data.Char		( ord, chr )
import Control.Monad		( when )
import Control.Exception	( throwDyn )
import System.IO as IO
import System.IO.Unsafe		( unsafeInterleaveIO )
import System.IO.Error		( mkIOError, eofErrorType )
import GHC.Real			( Ratio(..) )
import GHC.Exts
import GHC.IOBase	 	( IO(..) )
import GHC.Word			( Word8(..) )
import System.IO		( openBinaryFile )
import UTF8.PackedString
--import Atom
import Time
import Monad
import Data.Array.IArray
import Data.Array.Base
import Foreign.Storable
import Control.Concurrent.STM


{-
#if __GLASGOW_HASKELL__ < 503
type BinArray = MutableByteArray RealWorld Int
newArray_ bounds     = stToIO (newCharArray bounds)
unsafeWrite arr ix e = stToIO (writeWord8Array arr ix e)
unsafeRead  arr ix   = stToIO (readWord8Array arr ix)
#if __GLASGOW_HASKELL__ < 411
newByteArray#        = newCharArray#
#endif
hPutArray h arr sz   = hPutBufBAFull h arr sz
hGetArray h sz       = hGetBufBAFull h sz

mkIOError :: IOErrorType -> String -> Maybe Handle -> Maybe FilePath -> Exception
mkIOError t location maybe_hdl maybe_filename
  = IOException (IOError maybe_hdl t location ""
#if __GLASGOW_HASKELL__ > 411
		         maybe_filename
#endif
  		)
eofErrorType = EOF


#ifndef SIZEOF_HSWORD
#define SIZEOF_HSWORD WORD_SIZE_IN_BYTES
#endif

#else
type BinArray = IOUArray Int Word8
#endif
-}

--  #define SIZEOF_HSINT 4

type BinArray = IOUArray Int Word8
---------------------------------------------------------------
--		BinHandle
---------------------------------------------------------------

data BinHandle
  = BinMem {		-- binary data stored in an unboxed array
     off_r :: !FastMutInt,		-- the current offset
     sz_r  :: !FastMutInt,		-- size of the array (cached)
     arr_r :: !(IORef BinArray) 	-- the array (bounds: (0,size-1))
    }
	-- XXX: should really store a "high water mark" for dumping out
	-- the binary data to a file.

  | BinIO {		-- binary data stored in a file
     off_r :: !FastMutInt,		-- the current offset (cached)
     hdl   :: !IO.Handle		-- the file handle (must be seekable)
   }
	-- cache the file ptr in BinIO; using hTell is too expensive
	-- to call repeatedly.  If anyone else is modifying this Handle
	-- at the same time, we'll be screwed.

--getUserData :: BinHandle -> UserData
--getUserData bh = bh_usr bh

--setUserData :: BinHandle -> UserData -> BinHandle
--setUserData bh us = bh { bh_usr = us }


---------------------------------------------------------------
--		Bin
---------------------------------------------------------------

newtype Bin a = BinPtr Int 
  deriving (Eq, Ord, Show, Bounded)

castBin :: Bin a -> Bin b
castBin (BinPtr i) = BinPtr i

---------------------------------------------------------------
--		class Binary
---------------------------------------------------------------

class Binary a where
    put_   :: BinHandle -> a -> IO ()
    put    :: BinHandle -> a -> IO (Bin a)
    get    :: BinHandle -> IO a

    -- define one of put_, put.  Use of put_ is recommended because it
    -- is more likely that tail-calls can kick in, and we rarely need the
    -- position return value.
    put_ bh a = do put bh a; return ()
    put bh a  = do p <- tellBin bh; put_ bh a; return p

putAt  :: Binary a => BinHandle -> Bin a -> a -> IO ()
putAt bh p x = do seekBin bh p; put bh x; return ()

getAt  :: Binary a => BinHandle -> Bin a -> IO a
getAt bh p = do seekBin bh p; get bh

openBinIO_ :: IO.Handle -> IO BinHandle
openBinIO_ h = openBinIO h 

openBinIO :: IO.Handle -> IO BinHandle
openBinIO h = do
  r <- newFastMutInt
  writeFastMutInt r 0
  return (BinIO  r h)

openBinMem :: Int -> IO BinHandle
openBinMem size
 | size <= 0 = error "Data.Binary.openBinMem: size must be >= 0"
 | otherwise = do
   arr <- newArray_ (0,size-1)
   arr_r <- newIORef arr
   ix_r <- newFastMutInt
   writeFastMutInt ix_r 0
   sz_r <- newFastMutInt
   writeFastMutInt sz_r size
   return (BinMem ix_r sz_r arr_r)

tellBin :: BinHandle -> IO (Bin a)
tellBin (BinIO   r _)   = do ix <- readFastMutInt r; return (BinPtr ix)
tellBin (BinMem  r _ _) = do ix <- readFastMutInt r; return (BinPtr ix)

seekBin :: BinHandle -> Bin a -> IO ()
seekBin (BinIO  ix_r h) (BinPtr p) = do 
  writeFastMutInt ix_r p
  hSeek h AbsoluteSeek (fromIntegral p)
seekBin h@(BinMem  ix_r sz_r a) (BinPtr p) = do
  sz <- readFastMutInt sz_r
  if (p >= sz)
	then do expandBin h p; writeFastMutInt ix_r p
	else writeFastMutInt ix_r p

isEOFBin :: BinHandle -> IO Bool
isEOFBin (BinMem  ix_r sz_r a) = do
  ix <- readFastMutInt ix_r
  sz <- readFastMutInt sz_r
  return (ix >= sz)
isEOFBin (BinIO  ix_r h) = hIsEOF h

writeBinMem :: BinHandle -> FilePath -> IO ()
writeBinMem (BinIO  _ _) _ = error "Data.Binary.writeBinMem: not a memory handle"
writeBinMem (BinMem  ix_r sz_r arr_r) fn = do
  h <- openBinaryFile fn WriteMode
  arr <- readIORef arr_r
  ix  <- readFastMutInt ix_r
  hPutArray h arr ix
  hClose h

readBinMem :: FilePath -> IO BinHandle
-- Return a BinHandle with a totally undefined State
readBinMem filename = do
  h <- openBinaryFile filename ReadMode
  filesize' <- hFileSize h
  let filesize = fromIntegral filesize'
  arr <- newArray_ (0,filesize-1)
  count <- hGetArray h arr filesize
  when (count /= filesize)
        (error ("Binary.readBinMem: only read " ++ show count ++ " bytes"))
  hClose h
  arr_r <- newIORef arr
  ix_r <- newFastMutInt
  writeFastMutInt ix_r 0
  sz_r <- newFastMutInt
  writeFastMutInt sz_r filesize
  return (BinMem ix_r sz_r arr_r)

-- expand the size of the array to include a specified offset
expandBin :: BinHandle -> Int -> IO ()
expandBin (BinMem  ix_r sz_r arr_r) off = do
   sz <- readFastMutInt sz_r
   let sz' = head (dropWhile (<= off) (iterate (* 2) sz))
   arr <- readIORef arr_r
   arr' <- newArray_ (0,sz'-1)
   sequence_ [ unsafeRead arr i >>= unsafeWrite arr' i | i <- [ 0 .. sz-1 ] ]
   writeFastMutInt sz_r sz'
   writeIORef arr_r arr'
   return ()
expandBin (BinIO  _ _) _ = return ()
	-- no need to expand a file, we'll assume they expand by themselves.

-- -----------------------------------------------------------------------------
-- Low-level reading/writing of bytes

putWord8 :: BinHandle -> Word8 -> IO ()
putWord8 h@(BinMem  ix_r sz_r arr_r) w = do
    ix <- readFastMutInt ix_r
    sz <- readFastMutInt sz_r
	-- double the size of the array if it overflows
    if (ix >= sz) 
        then do 
            expandBin h ix
            putWord8 h w
        else do 
            arr <- readIORef arr_r
            unsafeWrite arr ix w
            writeFastMutInt ix_r (ix+1)
            return ()

putWord8 (BinIO  ix_r h) w = do
    ix <- readFastMutInt ix_r
    hPutChar h (chr (fromIntegral w))	-- XXX not really correct
    writeFastMutInt ix_r (ix+1)
    return ()

getWord8 :: BinHandle -> IO Word8
getWord8 (BinMem  ix_r sz_r arr_r) = do
    ix <- readFastMutInt ix_r
    sz <- readFastMutInt sz_r
    when (ix >= sz)  $
	ioError (mkIOError eofErrorType "Data.Binary.getWord8" Nothing Nothing)
    arr <- readIORef arr_r
    w <- unsafeRead arr ix
    writeFastMutInt ix_r (ix+1)
    return w
getWord8 (BinIO  ix_r h) = do
    ix <- readFastMutInt ix_r
    c <- hGetChar h
    writeFastMutInt ix_r (ix+1)
    return $! (fromIntegral (ord c))	-- XXX not really correct

{-# INLINE putByte #-}
putByte :: BinHandle -> Word8 -> IO ()
putByte bh w = putWord8 bh w

{-# INLINE getByte #-}
getByte :: BinHandle -> IO Word8
getByte = getWord8

-- -----------------------------------------------------------------------------
-- Primitve Word writes

instance Binary Word8 where
  put_ = putWord8
  get  = getWord8

instance Binary Word16 where
  put_ h w = do -- XXX too slow.. inline putWord8?
    putByte h (fromIntegral (w `shiftR` 8))
    putByte h (fromIntegral (w .&. 0xff))
  get h = do
    w1 <- getWord8 h
    w2 <- getWord8 h
    return $! ((fromIntegral w1 `shiftL` 8) .|. fromIntegral w2)


instance Binary Word32 where
  put_ h w = do
    putByte h (fromIntegral (w `shiftR` 24))
    putByte h (fromIntegral ((w `shiftR` 16) .&. 0xff))
    putByte h (fromIntegral ((w `shiftR` 8)  .&. 0xff))
    putByte h (fromIntegral (w .&. 0xff))
  get h = do
    w1 <- getWord8 h
    w2 <- getWord8 h
    w3 <- getWord8 h
    w4 <- getWord8 h
    return $! ((fromIntegral w1 `shiftL` 24) .|. 
	       (fromIntegral w2 `shiftL` 16) .|. 
	       (fromIntegral w3 `shiftL`  8) .|. 
	       (fromIntegral w4))


instance Binary Word64 where
  put_ h w = do
    putByte h (fromIntegral (w `shiftR` 56))
    putByte h (fromIntegral ((w `shiftR` 48) .&. 0xff))
    putByte h (fromIntegral ((w `shiftR` 40) .&. 0xff))
    putByte h (fromIntegral ((w `shiftR` 32) .&. 0xff))
    putByte h (fromIntegral ((w `shiftR` 24) .&. 0xff))
    putByte h (fromIntegral ((w `shiftR` 16) .&. 0xff))
    putByte h (fromIntegral ((w `shiftR`  8) .&. 0xff))
    putByte h (fromIntegral (w .&. 0xff))
  get h = do
    w1 <- getWord8 h
    w2 <- getWord8 h
    w3 <- getWord8 h
    w4 <- getWord8 h
    w5 <- getWord8 h
    w6 <- getWord8 h
    w7 <- getWord8 h
    w8 <- getWord8 h
    return $! ((fromIntegral w1 `shiftL` 56) .|. 
	       (fromIntegral w2 `shiftL` 48) .|. 
	       (fromIntegral w3 `shiftL` 40) .|. 
	       (fromIntegral w4 `shiftL` 32) .|. 
	       (fromIntegral w5 `shiftL` 24) .|. 
	       (fromIntegral w6 `shiftL` 16) .|. 
	       (fromIntegral w7 `shiftL`  8) .|. 
	       (fromIntegral w8))

-- -----------------------------------------------------------------------------
-- Primitve Int writes

instance Binary Int8 where
  put_ h w = put_ h (fromIntegral w :: Word8)
  get h    = do w <- get h; return $! (fromIntegral (w::Word8))

instance Binary Int16 where
  put_ h w = put_ h (fromIntegral w :: Word16)
  get h    = do w <- get h; return $! (fromIntegral (w::Word16))

instance Binary Int32 where
  put_ h w = put_ h (fromIntegral w :: Word32)
  get h    = do w <- get h; return $! (fromIntegral (w::Word32))

instance Binary Int64 where
  put_ h w = put_ h (fromIntegral w :: Word64)
  get h    = do w <- get h; return $! (fromIntegral (w::Word64))

-- -----------------------------------------------------------------------------
-- Instances for standard types

instance Binary () where
    put_ bh () = return ()
    get  _     = return ()
--    getF bh p  = case getBitsF bh 0 p of (_,b) -> ((),b)

instance Binary Bool where
    put_ bh b = putByte bh (fromIntegral (fromEnum b))
    get  bh   = do x <- getWord8 bh; return $! (toEnum (fromIntegral x))
--    getF bh p = case getBitsF bh 1 p of (x,b) -> (toEnum x,b)

instance Binary Char where
    put_  bh c = put_ bh (fromIntegral (ord c) :: Word32)
    get  bh   = do x <- get bh; return $! (chr (fromIntegral (x :: Word32)))
--    getF bh p = case getBitsF bh 8 p of (x,b) -> (toEnum x,b)

instance Binary Int where
--  #if SIZEOF_HSINT == 4
    put_ bh i = put_ bh (fromIntegral i :: Int32)
    get  bh = do
	x <- get bh
	return $! (fromIntegral (x :: Int32))
--  #elif SIZEOF_HSINT == 8
--    put_ bh i = put_ bh (fromIntegral i :: Int64)
--    get  bh = do
--	x <- get bh
--	return $! (fromIntegral (x :: Int64))
--  #else
--  #error "unsupported sizeof(HsInt)"
--  #endif

instance Binary ClockTime where
    put_ bh ct = do
	let t = toUTCTime ct
	put_ bh (ctYear t)
	put_ bh (fromEnum $ ctMonth t)
	put_ bh (ctDay t)
	put_ bh (ctHour t)
	put_ bh (ctMin t)
	put_ bh (ctSec t)
    get bh = do
	year <- get bh
	month <- fmap toEnum $ get bh 
	day <- get bh 
	hour <- get bh 
	min <- get bh 
	sec <- get bh 
	return $ toClockTime $ (toUTCTime epoch) {ctYear = year, ctDay = day, ctMonth = month, ctHour = hour, ctMin = min, ctSec = sec}
epoch = toClockTime $ CalendarTime { ctYear = 1970, ctMonth = January, ctDay = 0, ctHour = 0, ctMin = 0, ctSec = 0, ctTZ = 0, ctPicosec = 0, ctWDay = undefined, ctYDay = undefined, ctTZName = undefined, ctIsDST = undefined}

instance Binary PackedString where
    put_ bh (PS a) = put_ bh a
    get bh = fmap PS $ get bh 

--put_ bh $ (snd $ Data.Array.IArray.bounds a) + 1
--mapM_ (put_ bh) (Data.Array.IArray.elems a)
--sz <- get bh
--x <- sequence $ replicate sz (get bh)
--return $ PS (Data.Array.IArray.listArray (0,sz - 1) x) 

--put_ bh ps = put_ bh (unpackPS ps) 
--get bh = liftM packString $ get bh
--put_ bh ps = putNList_ bh (unpackPS ps) 
--get bh = liftM packString $ getNList bh
    
-- putNList_ bh xs = do
--     put_ bh (length xs)
--     mapM_ (put_ bh) xs
-- 
-- getNList bh = do
--     l <- get bh
--     sequence $ replicate l (get bh)

{-
instance Binary [Char] where
    put_ bh cs = put_ bh (packString cs)
    get bh = do
        ps <- get bh
        return $ unpackPS ps
-}

instance Binary a => Binary [a] where
    put_ bh []     = putByte bh 0
    put_ bh (x:xs) = do putByte bh 1; put_ bh x; put_ bh xs
    get bh         = do h <- getWord8 bh
                        case h of
                          0 -> return []
                          _ -> do x  <- get bh
                                  xs <- get bh
                                  return (x:xs)

instance (Binary a, Binary b) => Binary (a,b) where
    put_ bh (a,b) = do put_ bh a; put_ bh b
    get bh        = do a <- get bh
                       b <- get bh
                       return (a,b)

instance (Binary a, Binary b, Binary c) => Binary (a,b,c) where
    put_ bh (a,b,c) = do put_ bh a; put_ bh b; put_ bh c
    get bh          = do a <- get bh
                         b <- get bh
                         c <- get bh
                         return (a,b,c)

instance (Binary a, Binary b, Binary c, Binary d) => Binary (a,b,c,d) where
    put_ bh (a,b,c,d) = do put_ bh a; put_ bh b; put_ bh c; put_ bh d
    get bh          = do a <- get bh
                         b <- get bh
                         c <- get bh
                         d <- get bh
                         return (a,b,c,d)

instance Binary a => Binary (Maybe a) where
    put_ bh Nothing  = putByte bh 0
    put_ bh (Just a) = do putByte bh 1; put_ bh a
    get bh           = do 
        h <- getWord8 bh
        case h of
            0 -> return Nothing
            _ -> do 
                x <- get bh 
                return (Just x)

instance (Binary a, Binary b) => Binary (Either a b) where
    put_ bh (Left  a) = do putByte bh 0; put_ bh a
    put_ bh (Right b) = do putByte bh 1; put_ bh b
    get bh            = do h <- getWord8 bh
                           case h of
                             0 -> do a <- get bh ; return (Left a)
                             _ -> do b <- get bh ; return (Right b)



-- these flatten the start element. hope that's okay!
instance Binary (UArray Int Word8) where
    put_ bh@(BinIO ix_r h) ua = do
        let sz = rangeSize (Data.Array.IO.bounds ua)
        ix <- readFastMutInt ix_r 
        put_ bh sz
        ua <- unsafeThaw ua
        hPutArray h ua sz
        writeFastMutInt ix_r (ix + sz + 4)
    put_ bh (UArray s e ba) = do
        let sz = (rangeSize (s,e))
        put_ bh sz
        case sz of
            I# i -> putByteArray bh ba i
    get bh@(BinIO ix_r h) = do
        ix <- readFastMutInt ix_r 
        sz <- get bh 
        ba <- newArray_ (0, sz - 1)
        hGetArray h ba sz 
        writeFastMutInt ix_r (ix + sz + 4)
        ba <- unsafeFreeze ba 
        return ba
    get  bh = do
        sz <- get bh 
        BA ba <- getByteArray bh sz
        return $ UArray 0 (sz - 1) ba

 {-

instance (Ix a, Binary a) => Binary (UArray a Word8) where
    put_ bh (UArray s e ba) = do
        put_ bh s
        put_ bh e
        case (rangeSize (s,e)) of
            I# i -> putByteArray bh ba i
    get  bh = do
        s <- get bh 
        e <- get bh
        BA ba <- getByteArray bh (rangeSize (s,e))
        return $ UArray s e ba

-} 
--  #ifdef __GLASGOW_HASKELL__

instance Binary Integer where
    put_ bh (S# i#) = do putByte bh 0; put_ bh (I# i#)
    put_ bh (J# s# a#) = do
 	p <- putByte bh 1;
	put_ bh (I# s#)
	let sz# = sizeofByteArray# a#  -- in *bytes*
	put_ bh (I# sz#)  -- in *bytes*
	putByteArray bh a# sz#
   
    get bh = do 
	b <- getByte bh
	case b of
	  0 -> do (I# i#) <- get bh
		  return (S# i#)
	  _ -> do (I# s#) <- get bh
		  sz <- get bh
		  (BA a#) <- getByteArray bh sz
		  return (J# s# a#)

putByteArray :: BinHandle -> ByteArray# -> Int# -> IO ()
putByteArray bh a s# = loop 0#
  where loop n# 
	   | n# ==# s# = return ()
	   | otherwise = do
	   	putByte bh (indexByteArray a n#)
		loop (n# +# 1#)

getByteArray :: BinHandle -> Int -> IO ByteArray
getByteArray bh (I# sz) = do
  (MBA arr) <- newByteArray sz 
  let loop n
	   | n ==# sz = return ()
	   | otherwise = do
		w <- getByte bh 
		writeByteArray arr n w
		loop (n +# 1#)
  loop 0#
  freezeByteArray arr


data ByteArray = BA ByteArray#
data MBA = MBA (MutableByteArray# RealWorld)

newByteArray :: Int# -> IO MBA
newByteArray sz = IO $ \s ->
  case newByteArray# sz s of { (# s, arr #) ->
  (# s, MBA arr #) }

freezeByteArray :: MutableByteArray# RealWorld -> IO ByteArray
freezeByteArray arr = IO $ \s ->
  case unsafeFreezeByteArray# arr s of { (# s, arr #) ->
  (# s, BA arr #) }

writeByteArray :: MutableByteArray# RealWorld -> Int# -> Word8 -> IO ()

writeByteArray arr i (W8# w) = IO $ \s ->
  case writeWord8Array# arr i w s of { s ->
  (# s, () #) }

indexByteArray a# n# = W8# (indexWord8Array# a# n#)

instance (Integral a, Binary a) => Binary (Ratio a) where
    put_ bh (a :% b) = do put_ bh a; put_ bh b
    get bh = do a <- get bh; b <- get bh; return (a :% b)
--  #endif

instance Binary (Bin a) where
  put_ bh (BinPtr i) = put_ bh i
  get bh = do i <- get bh; return (BinPtr i)

-- -----------------------------------------------------------------------------
-- Lazy reading/writing

lazyPut :: Binary a => BinHandle -> a -> IO ()
lazyPut bh a = do
	-- output the obj with a ptr to skip over it:
    pre_a <- tellBin bh
    put_ bh pre_a	-- save a slot for the ptr
    put_ bh a		-- dump the object
    q <- tellBin bh 	-- q = ptr to after object
    putAt bh pre_a q 	-- fill in slot before a with ptr to q
    seekBin bh q	-- finally carry on writing at q

lazyGet :: Binary a => BinHandle -> IO a
lazyGet bh = do
    p <- get bh		-- a BinPtr
    p_a <- tellBin bh
    a <- unsafeInterleaveIO (getAt bh p_a)
    seekBin bh p -- skip over the object for now
    return a

 
{-
---------------------------------------------------------
--		Reading and writing FastStrings
---------------------------------------------------------

putFS bh (FastString id l ba) = do
  put_ bh (I# l)
  putByteArray bh ba l
putFS bh s = error ("Binary.put_(FastString): " ++ unpackFS s)
	-- Note: the length of the FastString is *not* the same as
	-- the size of the ByteArray: the latter is rounded up to a
	-- multiple of the word size.
  
{- -- possible faster version, not quite there yet:
getFS bh@BinMem{} = do
  (I# l) <- get bh
  arr <- readIORef (arr_r bh)
  off <- readFastMutInt (off_r bh)
  return $! (mkFastSubStringBA# arr off l)
-}
getFS bh = do
  (I# l) <- get bh
  (BA ba) <- getByteArray bh (I# l)
  return $! (mkFastSubStringBA# ba 0# l)

{-
instance Binary FastString where
  put_ bh f@(FastString id l ba) =
    case getUserData bh of { 
	UserData { ud_next = j_r, ud_map = out_r, ud_dict = dict} -> do
    out <- readIORef out_r
    let uniq = getUnique f
    case lookupUFM out uniq of
	Just (j,f)  -> put_ bh j
	Nothing -> do
	   j <- readIORef j_r
	   put_ bh j
	   writeIORef j_r (j+1)
	   writeIORef out_r (addToUFM out uniq (j,f))
    }
  put_ bh s = error ("Binary.put_(FastString): " ++ show (unpackFS s))

  get bh = do 
	j <- get bh
	return $! (ud_dict (getUserData bh) ! j)
-}
-}

{-
instance Binary Atom where
    get bh = do
        ps <- get bh
        a <- fromPackedStringIO ps
        return a
    put_ bh a = put_ bh (toPackedString a)
-}        

sSIZEOF_HSINT = sizeOf (undefined :: Int)

data FastMutInt = FastMutInt (MutableByteArray# RealWorld)

newFastMutInt :: IO FastMutInt
newFastMutInt = IO $ \s ->
  case newByteArray# size s of { (# s, arr #) ->
  (# s, FastMutInt arr #) }
  where I# size = sSIZEOF_HSINT

{-# INLINE readFastMutInt  #-}
readFastMutInt :: FastMutInt -> IO Int
readFastMutInt (FastMutInt arr) = IO $ \s ->
  case readIntArray# arr 0# s of { (# s, i #) ->
  (# s, I# i #) }

{-# INLINE writeFastMutInt  #-}
writeFastMutInt :: FastMutInt -> Int -> IO ()
writeFastMutInt (FastMutInt arr) (I# i) = IO $ \s ->
  case writeIntArray# arr 0# i s of { s ->
  (# s, () #) }

----------------------------------------------------------------------------
-- Pugs Additions

instance Binary Double where
    put_ bh n = put_ bh (decodeFloat n)
    get  bh   = fmap (uncurry encodeFloat) (get bh)

instance Binary a => Binary (TVar a) where
    put_ bh v = put_ bh =<< (atomically $ readTVar v)
    get  bh   = atomically . newTVar =<< get bh

instance Binary a => Binary (IORef a) where
    put_ bh v = put_ bh =<< readIORef v
    get  bh   = newIORef =<< get bh

