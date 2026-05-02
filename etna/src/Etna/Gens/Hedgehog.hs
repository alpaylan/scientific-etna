module Etna.Gens.Hedgehog where

import           Hedgehog (Gen)
import qualified Hedgehog.Gen   as Gen
import qualified Hedgehog.Range as Range

import Etna.Properties
  ( FloorArgs(..)
  , NonDigitString(..)
  , ReadsArgs(..)
  , FromFloatArgs(..)
  )

gen_floor_dangerously_small_negative :: Gen FloorArgs
gen_floor_dangerously_small_negative = do
  c   <- Gen.integral (Range.linear 0 1000000)
  neg <- Gen.bool
  e   <- Gen.int (Range.linear 0 5000)
  pure (FloorArgs c neg e)

gen_parse_empty_digit_string_rejected :: Gen NonDigitString
gen_parse_empty_digit_string_rejected = do
  s <- Gen.string (Range.linear 0 6) (Gen.element nonDigitChars)
  pure (NonDigitString s)

gen_reads_unambiguous :: Gen ReadsArgs
gen_reads_unambiguous = do
  i <- Gen.string (Range.linear 1 5) (Gen.element digitChars)
  f <- Gen.string (Range.linear 1 5) (Gen.element digitChars)
  pure (ReadsArgs i f)

gen_from_float_digits_round_trip :: Gen FromFloatArgs
gen_from_float_digits_round_trip = do
  n <- Gen.frequency
         [ (2, pure 0)
         , (8, Gen.int (Range.linearFrom 0 (-100) 100))
         ]
  pure (FromFloatArgs n)

nonDigitChars :: [Char]
nonDigitChars = "+-.eE "

digitChars :: [Char]
digitChars = "0123456789"
