# scientific — ETNA Tasks

Total tasks: 16

## Task Index

| Task | Variant | Framework | Property | Witness |
|------|---------|-----------|----------|---------|
| 001 | `floor_dangerously_small_negative_7d02b9d` | quickcheck | `FloorDangerouslySmallNegative` | `witness_floor_dangerously_small_negative_case_neg_one_e_neg_400` |
| 002 | `floor_dangerously_small_negative_7d02b9d` | hedgehog | `FloorDangerouslySmallNegative` | `witness_floor_dangerously_small_negative_case_neg_one_e_neg_400` |
| 003 | `floor_dangerously_small_negative_7d02b9d` | falsify | `FloorDangerouslySmallNegative` | `witness_floor_dangerously_small_negative_case_neg_one_e_neg_400` |
| 004 | `floor_dangerously_small_negative_7d02b9d` | smallcheck | `FloorDangerouslySmallNegative` | `witness_floor_dangerously_small_negative_case_neg_one_e_neg_400` |
| 005 | `from_float_digits_zero_0f28347` | quickcheck | `FromFloatDigitsRoundTrip` | `witness_from_float_digits_round_trip_case_zero` |
| 006 | `from_float_digits_zero_0f28347` | hedgehog | `FromFloatDigitsRoundTrip` | `witness_from_float_digits_round_trip_case_zero` |
| 007 | `from_float_digits_zero_0f28347` | falsify | `FromFloatDigitsRoundTrip` | `witness_from_float_digits_round_trip_case_zero` |
| 008 | `from_float_digits_zero_0f28347` | smallcheck | `FromFloatDigitsRoundTrip` | `witness_from_float_digits_round_trip_case_zero` |
| 009 | `parse_empty_digit_string_b3af22f` | quickcheck | `ParseEmptyDigitStringRejected` | `witness_parse_empty_digit_string_rejected_case_empty` |
| 010 | `parse_empty_digit_string_b3af22f` | hedgehog | `ParseEmptyDigitStringRejected` | `witness_parse_empty_digit_string_rejected_case_empty` |
| 011 | `parse_empty_digit_string_b3af22f` | falsify | `ParseEmptyDigitStringRejected` | `witness_parse_empty_digit_string_rejected_case_empty` |
| 012 | `parse_empty_digit_string_b3af22f` | smallcheck | `ParseEmptyDigitStringRejected` | `witness_parse_empty_digit_string_rejected_case_empty` |
| 013 | `reads_unambiguous_8990216` | quickcheck | `ReadsUnambiguous` | `witness_reads_unambiguous_case_one_dot_zero` |
| 014 | `reads_unambiguous_8990216` | hedgehog | `ReadsUnambiguous` | `witness_reads_unambiguous_case_one_dot_zero` |
| 015 | `reads_unambiguous_8990216` | falsify | `ReadsUnambiguous` | `witness_reads_unambiguous_case_one_dot_zero` |
| 016 | `reads_unambiguous_8990216` | smallcheck | `ReadsUnambiguous` | `witness_reads_unambiguous_case_one_dot_zero` |

## Witness Catalog

- `witness_floor_dangerously_small_negative_case_neg_one_e_neg_400` — floor (scientific (-1) (-400)) must equal -1
- `witness_floor_dangerously_small_negative_case_neg_seven_e_neg_500` — floor (scientific (-7) (-500)) must equal -1
- `witness_floor_dangerously_small_negative_case_pos_one_e_neg_400` — floor (scientific 1 (-400)) must equal 0 (sanity)
- `witness_from_float_digits_round_trip_case_zero` — fromFloatDigits (0 :: Double) must equal Scientific 0 0
- `witness_from_float_digits_round_trip_case_one` — fromFloatDigits (1 :: Double) must equal Scientific 1 0 (sanity)
- `witness_from_float_digits_round_trip_case_neg_one` — fromFloatDigits (-1 :: Double) must equal Scientific (-1) 0 (sanity)
- `witness_parse_empty_digit_string_rejected_case_empty` — scientificP "" must produce no successful parse
- `witness_parse_empty_digit_string_rejected_case_dot` — scientificP "." must produce no successful parse
- `witness_parse_empty_digit_string_rejected_case_plus_dot` — scientificP "+." must produce no successful parse
- `witness_reads_unambiguous_case_one_dot_zero` — readP_to_S scientificP "1.0" must be a singleton
- `witness_reads_unambiguous_case_two_dot_five` — readP_to_S scientificP "2.5" must be a singleton
- `witness_reads_unambiguous_case_long` — readP_to_S scientificP "12345.67890" must be a singleton
