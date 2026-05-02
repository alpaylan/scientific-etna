module Etna.Gens.QuickCheck where

import qualified Test.QuickCheck as QC

import Etna.Properties
  ( FloorArgs(..)
  , NonDigitString(..)
  , ReadsArgs(..)
  , FromFloatArgs(..)
  )

gen_floor_dangerously_small_negative :: QC.Gen FloorArgs
gen_floor_dangerously_small_negative = do
  c   <- QC.choose (0, 1000000) :: QC.Gen Integer
  neg <- QC.arbitrary
  e   <- QC.choose (0, 5000)
  pure (FloorArgs c neg e)

gen_parse_empty_digit_string_rejected :: QC.Gen NonDigitString
gen_parse_empty_digit_string_rejected = do
  n <- QC.choose (0, 6)
  cs <- QC.vectorOf n (QC.elements nonDigitChars)
  pure (NonDigitString cs)

gen_reads_unambiguous :: QC.Gen ReadsArgs
gen_reads_unambiguous = do
  iLen <- QC.choose (1, 5)
  fLen <- QC.choose (1, 5)
  is <- QC.vectorOf iLen (QC.elements digitChars)
  fs <- QC.vectorOf fLen (QC.elements digitChars)
  pure (ReadsArgs is fs)

gen_from_float_digits_round_trip :: QC.Gen FromFloatArgs
gen_from_float_digits_round_trip = do
  n <- QC.frequency [(2, pure 0), (8, QC.choose (-100, 100))]
  pure (FromFloatArgs n)

nonDigitChars :: [Char]
nonDigitChars = "+-.eE "

digitChars :: [Char]
digitChars = "0123456789"
