module Etna.Properties where

import Data.Scientific
  ( Scientific
  , scientific
  , scientificP
  , fromFloatDigits
  )
import Text.ParserCombinators.ReadP (readP_to_S)

import Etna.Result

------------------------------------------------------------------------------
-- Variant 1: floor_dangerously_small_negative_7d02b9d
-- Historical bug (commit 7d02b9d, 2014-05-05): for very small negative
-- exponents the dangerouslySmall short-circuit returned 0 unconditionally,
-- so floor (-1e-1000) returned 0 instead of -1.
------------------------------------------------------------------------------

-- | Property: for any non-zero coefficient and any exponent magnitude
-- in the @dangerouslySmall@ regime (we use @e <= -400@, well below the
-- @limit = maxExpt = 324@), the result of @floor s@ must agree with
-- the sign of the coefficient — 0 for positive, -1 for negative.
property_floor_dangerously_small_negative :: FloorArgs -> PropertyResult
property_floor_dangerously_small_negative (FloorArgs c neg e) =
  let coef    = if neg then negate (abs c + 1) else (abs c + 1)
      expnt   = -(abs e + 400)
      s       = scientific coef expnt
      got     = floor s :: Int
      want    = if neg then (-1 :: Int) else 0
  in if got == want
       then Pass
       else Fail $
              "floor (scientific " ++ show coef ++ " " ++ show expnt ++
              ") = " ++ show got ++ "; expected " ++ show want

-- | Generator inputs for the floor property.
data FloorArgs = FloorArgs
  { faC   :: !Integer
  , faNeg :: !Bool
  , faE   :: !Int
  } deriving (Show, Eq)

------------------------------------------------------------------------------
-- Variant 2: parse_empty_digit_string_b3af22f
-- Historical bug (commit b3af22f, 2014-10-27, GH-21): scientificP
-- accepted strings that contained no decimal digit (\"\", \".\", \"+\",
-- etc.) by silently producing a Scientific @0 0@. The fix made
-- foldDigits demand at least one decimal character.
------------------------------------------------------------------------------

-- | Property: scientificP must reject any string that contains no
-- decimal digit at all. Equivalently, @readP_to_S scientificP s@ is
-- empty for any such @s@.
property_parse_empty_digit_string_rejected :: NonDigitString -> PropertyResult
property_parse_empty_digit_string_rejected (NonDigitString s) =
  case readP_to_S scientificP s of
    [] -> Pass
    parses ->
      Fail $ "scientificP " ++ show s ++ " accepted as " ++ show parses ++
             "; expected no successful parse"

-- | Inputs for the parser-rejection property: strings drawn from a
-- digit-free alphabet so any successful parse exposes the bug.
newtype NonDigitString = NonDigitString { unNonDigit :: String }
  deriving (Show, Eq)

------------------------------------------------------------------------------
-- Variant 3: reads_unambiguous_8990216
-- Historical bug (commit 8990216, 2015-01-21): scientificP used 'mplus'
-- between the optional fractional branch and the no-fraction
-- continuation, producing two parses for any input with a fractional
-- part. The fix replaced 'mplus' with 'ReadP.<++' (left-biased).
------------------------------------------------------------------------------

-- | Property: for any string of the form
-- @<digits>.<digits>@ (no exponent, no leading sign), scientificP
-- returns exactly one parse. The buggy version returns two — one
-- consuming the fractional part, one stopping after the integer part.
property_reads_unambiguous :: ReadsArgs -> PropertyResult
property_reads_unambiguous (ReadsArgs intDigits fracDigits) =
  let s = intDigits ++ "." ++ fracDigits
      parses = readP_to_S scientificP s
  in case length parses of
       1 -> Pass
       _ -> Fail $ "readP_to_S scientificP " ++ show s ++
                   " returned " ++ show (length parses) ++
                   " parses: " ++ show parses ++
                   "; expected exactly 1"

-- | Inputs for the ambiguous-parse property. Both fields are non-empty
-- digit strings — the generators construct them so the joined input
-- always represents a well-formed scientific number.
data ReadsArgs = ReadsArgs
  { raInt  :: !String
  , raFrac :: !String
  } deriving (Show, Eq)

------------------------------------------------------------------------------
-- Variant 4: from_float_digits_zero_0f28347
-- Historical bug (commit 0f28347, 2016-03-10): fromFloatDigits 0
-- returned a non-normalized Scientific (coefficient 0, exponent -1),
-- not equal to @0 :: Scientific@ under the structural Eq instance.
-- The fix added @fromFloatDigits 0 = 0@.
------------------------------------------------------------------------------

-- | Property: fromFloatDigits and fromInteger agree on small integral
-- Doubles. In particular @fromFloatDigits (fromIntegral n :: Double)
-- == fromInteger (toInteger n)@ for any 'Int' @n@. The buggy version
-- breaks this for @n == 0@ because it produces an unnormalized result.
property_from_float_digits_round_trip :: FromFloatArgs -> PropertyResult
property_from_float_digits_round_trip (FromFloatArgs n) =
  let d    = fromIntegral n :: Double
      got  = fromFloatDigits d :: Scientific
      want = fromInteger (toInteger n) :: Scientific
  in if got == want
       then Pass
       else Fail $ "fromFloatDigits (" ++ show d ++ ") = " ++ show got ++
                   "; expected " ++ show want

-- | Inputs for the fromFloatDigits round-trip property.
newtype FromFloatArgs = FromFloatArgs { ffaN :: Int }
  deriving (Show, Eq)
