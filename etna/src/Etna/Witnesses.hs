module Etna.Witnesses where

import Etna.Properties
import Etna.Result

------------------------------------------------------------------------------
-- Variant 1
------------------------------------------------------------------------------

witness_floor_dangerously_small_negative_case_neg_one_e_neg_400 :: PropertyResult
witness_floor_dangerously_small_negative_case_neg_one_e_neg_400 =
  property_floor_dangerously_small_negative (FloorArgs 0 True 0)

witness_floor_dangerously_small_negative_case_neg_seven_e_neg_500 :: PropertyResult
witness_floor_dangerously_small_negative_case_neg_seven_e_neg_500 =
  property_floor_dangerously_small_negative (FloorArgs 6 True 100)

witness_floor_dangerously_small_negative_case_pos_one_e_neg_400 :: PropertyResult
witness_floor_dangerously_small_negative_case_pos_one_e_neg_400 =
  property_floor_dangerously_small_negative (FloorArgs 0 False 0)

------------------------------------------------------------------------------
-- Variant 2
------------------------------------------------------------------------------

witness_parse_empty_digit_string_rejected_case_empty :: PropertyResult
witness_parse_empty_digit_string_rejected_case_empty =
  property_parse_empty_digit_string_rejected (NonDigitString "")

witness_parse_empty_digit_string_rejected_case_dot :: PropertyResult
witness_parse_empty_digit_string_rejected_case_dot =
  property_parse_empty_digit_string_rejected (NonDigitString ".")

witness_parse_empty_digit_string_rejected_case_plus_dot :: PropertyResult
witness_parse_empty_digit_string_rejected_case_plus_dot =
  property_parse_empty_digit_string_rejected (NonDigitString "+.")

------------------------------------------------------------------------------
-- Variant 3
------------------------------------------------------------------------------

witness_reads_unambiguous_case_one_dot_zero :: PropertyResult
witness_reads_unambiguous_case_one_dot_zero =
  property_reads_unambiguous (ReadsArgs "1" "0")

witness_reads_unambiguous_case_two_dot_five :: PropertyResult
witness_reads_unambiguous_case_two_dot_five =
  property_reads_unambiguous (ReadsArgs "2" "5")

witness_reads_unambiguous_case_long :: PropertyResult
witness_reads_unambiguous_case_long =
  property_reads_unambiguous (ReadsArgs "12345" "67890")

------------------------------------------------------------------------------
-- Variant 4
------------------------------------------------------------------------------

witness_from_float_digits_round_trip_case_zero :: PropertyResult
witness_from_float_digits_round_trip_case_zero =
  property_from_float_digits_round_trip (FromFloatArgs 0)

witness_from_float_digits_round_trip_case_one :: PropertyResult
witness_from_float_digits_round_trip_case_one =
  property_from_float_digits_round_trip (FromFloatArgs 1)

witness_from_float_digits_round_trip_case_neg_one :: PropertyResult
witness_from_float_digits_round_trip_case_neg_one =
  property_from_float_digits_round_trip (FromFloatArgs (-1))
