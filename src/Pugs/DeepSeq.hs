{-# OPTIONS_GHC -fglasgow-exts -fallow-overlapping-instances -fallow-undecidable-instances -fno-warn-orphans #-}

{-|
    Deep sequential evaluation for data structures.

>   All that is gold does not glitter,
>   Not all those who wander are lost;
>   The old that is strong does not wither,
>   Deep roots are not reached by the frost.

-}

module Pugs.DeepSeq (
    module Data.DeepSeq,
) where
import Pugs.AST
import Pugs.Types
import Pugs.Internals (ByteString)
import Data.DeepSeq

instance DeepSeq Val where
    deepSeq VUndef x = x
    deepSeq (VBool a) x = deepSeq a x
    deepSeq (VInt a) x = deepSeq a x
    deepSeq (VRat a) x = deepSeq a x
    deepSeq (VNum a) x = deepSeq a x
    deepSeq (VComplex a) x = deepSeq a x
    deepSeq (VStr a) x = deepSeq a x
    deepSeq (VList a) x = deepSeq a x
    deepSeq (VJunc a) x = deepSeq a x
    deepSeq (VError a b) x =  deepSeq a $ deepSeq b x
    deepSeq (VControl a) x = deepSeq a x
    deepSeq a x = seq a x

instance DeepSeq ByteString where
    deepSeq = seq

instance DeepSeq VComplex where
    deepSeq = seq

instance DeepSeq VRat where
    deepSeq = seq

instance DeepSeq VControl where
    deepSeq = seq

instance DeepSeq VJunc where
    deepSeq = seq -- XXX Wrong

instance DeepSeq Pos where
    deepSeq = seq
