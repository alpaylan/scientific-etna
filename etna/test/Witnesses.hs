module Main where

import Etna.Result (PropertyResult(..))
import Etna.Witnesses
import System.Exit (exitFailure, exitSuccess)

cases :: [(String, PropertyResult)]
cases =
  [ ("witness_floor_dangerously_small_negative_case_neg_one_e_neg_400",
      witness_floor_dangerously_small_negative_case_neg_one_e_neg_400)
  , ("witness_floor_dangerously_small_negative_case_neg_seven_e_neg_500",
      witness_floor_dangerously_small_negative_case_neg_seven_e_neg_500)
  , ("witness_floor_dangerously_small_negative_case_pos_one_e_neg_400",
      witness_floor_dangerously_small_negative_case_pos_one_e_neg_400)
  , ("witness_parse_empty_digit_string_rejected_case_empty",
      witness_parse_empty_digit_string_rejected_case_empty)
  , ("witness_parse_empty_digit_string_rejected_case_dot",
      witness_parse_empty_digit_string_rejected_case_dot)
  , ("witness_parse_empty_digit_string_rejected_case_plus_dot",
      witness_parse_empty_digit_string_rejected_case_plus_dot)
  , ("witness_reads_unambiguous_case_one_dot_zero",
      witness_reads_unambiguous_case_one_dot_zero)
  , ("witness_reads_unambiguous_case_two_dot_five",
      witness_reads_unambiguous_case_two_dot_five)
  , ("witness_reads_unambiguous_case_long",
      witness_reads_unambiguous_case_long)
  , ("witness_from_float_digits_round_trip_case_zero",
      witness_from_float_digits_round_trip_case_zero)
  , ("witness_from_float_digits_round_trip_case_one",
      witness_from_float_digits_round_trip_case_one)
  , ("witness_from_float_digits_round_trip_case_neg_one",
      witness_from_float_digits_round_trip_case_neg_one)
  ]

main :: IO ()
main = do
  let failures =
        [ (n, msg) | (n, Fail msg) <- cases ] ++
        [ (n, "discard") | (n, Discard) <- cases ]
  if null failures
    then do
      putStrLn $ "OK: all " ++ show (length cases) ++ " witnesses passed"
      exitSuccess
    else do
      mapM_ (\(n, m) -> putStrLn (n ++ ": FAIL: " ++ m)) failures
      exitFailure
