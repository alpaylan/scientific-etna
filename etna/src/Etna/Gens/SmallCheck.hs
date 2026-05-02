{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}

module Etna.Gens.SmallCheck where

import qualified Test.SmallCheck.Series as SC

import Etna.Properties
  ( FloorArgs(..)
  , NonDigitString(..)
  , ReadsArgs(..)
  , FromFloatArgs(..)
  )

series_floor_dangerously_small_negative :: Monad m => SC.Series m FloorArgs
series_floor_dangerously_small_negative = do
  c   <- SC.generate (\d -> map fromIntegral [0 .. min d 5 :: Int])
  neg <- SC.generate (\_ -> [True, False])
  e   <- SC.generate (\d -> [0 .. min d 5 :: Int])
  pure (FloorArgs c neg e)

series_parse_empty_digit_string_rejected :: Monad m => SC.Series m NonDigitString
series_parse_empty_digit_string_rejected =
  NonDigitString <$> SC.generate (\d -> nonDigitStrings (min d 4))

series_reads_unambiguous :: Monad m => SC.Series m ReadsArgs
series_reads_unambiguous = do
  i <- SC.generate (\d -> take (1 + min d 7) intSamples)
  f <- SC.generate (\d -> take (1 + min d 6) fracSamples)
  pure (ReadsArgs i f)
  where
    intSamples  = ["1", "0", "9", "12", "99", "100", "1234", "98765"]
    fracSamples = ["0", "5", "9", "25", "123", "9876", "00012"]

series_from_float_digits_round_trip :: Monad m => SC.Series m FromFloatArgs
series_from_float_digits_round_trip =
  FromFloatArgs <$> SC.generate (\d -> [-d .. d])

nonDigitStrings :: Int -> [String]
nonDigitStrings 0 = [""]
nonDigitStrings d =
  let rest = nonDigitStrings (d - 1)
  in [c : s | c <- "+-.eE ", s <- rest]

nonEmptyDigitStrings :: Int -> [String]
nonEmptyDigitStrings d =
  [c : s | c <- "0123456789",
           len <- [0 .. max 0 (d - 1)],
           s <- digitStrings len]

digitStrings :: Int -> [String]
digitStrings 0 = [""]
digitStrings d =
  [c : s | c <- "0123456789", s <- digitStrings (d - 1)]
