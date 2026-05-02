module Etna.Gens.Falsify where

import           Data.List.NonEmpty (NonEmpty(..))
import qualified Test.Falsify.Generator as F
import qualified Test.Falsify.Range     as FR

import Etna.Properties
  ( FloorArgs(..)
  , NonDigitString(..)
  , ReadsArgs(..)
  , FromFloatArgs(..)
  )

gen_floor_dangerously_small_negative :: F.Gen FloorArgs
gen_floor_dangerously_small_negative = do
  c   <- toIntegerW <$> F.inRange (FR.between (0, 1000000))
  neg <- F.bool True
  e   <- F.inRange (FR.between (0, 5000))
  pure (FloorArgs c neg e)
  where
    toIntegerW :: Word -> Integer
    toIntegerW = toInteger

gen_parse_empty_digit_string_rejected :: F.Gen NonDigitString
gen_parse_empty_digit_string_rejected = do
  n <- fromIntegral <$> F.inRange (FR.between (0 :: Word, 6 :: Word))
  cs <- F.list (FR.between (0, n)) (F.elem nonDigitNE)
  pure (NonDigitString cs)

gen_reads_unambiguous :: F.Gen ReadsArgs
gen_reads_unambiguous = do
  i <- F.list (FR.between (1, 5)) (F.elem digitNE)
  f <- F.list (FR.between (1, 5)) (F.elem digitNE)
  pure (ReadsArgs i f)

gen_from_float_digits_round_trip :: F.Gen FromFloatArgs
gen_from_float_digits_round_trip = do
  n <- F.inRange (FR.between (-100, 100))
  pure (FromFloatArgs n)

nonDigitNE :: NonEmpty Char
nonDigitNE = '+' :| ['-', '.', 'e', 'E', ' ']

digitNE :: NonEmpty Char
digitNE = '0' :| ['1', '2', '3', '4', '5', '6', '7', '8', '9']
