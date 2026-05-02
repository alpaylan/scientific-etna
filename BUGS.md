# scientific — Injected Bugs

Arbitrary-precision scientific-notation numbers (basvandijk/scientific). Bug fixes mined from upstream history; modern HEAD is the base, each patch reverse-applies a fix to install the original bug. Four PBT backends drive the same property modules: QuickCheck, Hedgehog, Falsify, SmallCheck.

Total mutations: 4

## Bug Index

| # | Variant | Name | Location | Injection | Fix Commit |
|---|---------|------|----------|-----------|------------|
| 1 | `floor_dangerously_small_negative_7d02b9d` | `floor_dangerously_small_negative` | `src/Data/Scientific/Internal.hs:559` | `patch` | `7d02b9de9d10297be495aa23807457426a9d6163` |
| 2 | `from_float_digits_zero_0f28347` | `from_float_digits_zero` | `src/Data/Scientific/Internal.hs:692` | `patch` | `0f28347b4a3221a741f76a48f18ffb9de961e856` |
| 3 | `parse_empty_digit_string_b3af22f` | `parse_empty_digit_string` | `src/Data/Scientific/Internal.hs:921` | `patch` | `b3af22fc0617581d932bb82c65c0652f0632283d` |
| 4 | `reads_unambiguous_8990216` | `reads_unambiguous` | `src/Data/Scientific/Internal.hs:893` | `patch` | `8990216e351c56f8186ca12cffbc09af95238eef` |

## Property Mapping

| Variant | Property | Witness(es) |
|---------|----------|-------------|
| `floor_dangerously_small_negative_7d02b9d` | `FloorDangerouslySmallNegative` | `witness_floor_dangerously_small_negative_case_neg_one_e_neg_400`, `witness_floor_dangerously_small_negative_case_neg_seven_e_neg_500`, `witness_floor_dangerously_small_negative_case_pos_one_e_neg_400` |
| `from_float_digits_zero_0f28347` | `FromFloatDigitsRoundTrip` | `witness_from_float_digits_round_trip_case_zero`, `witness_from_float_digits_round_trip_case_one`, `witness_from_float_digits_round_trip_case_neg_one` |
| `parse_empty_digit_string_b3af22f` | `ParseEmptyDigitStringRejected` | `witness_parse_empty_digit_string_rejected_case_empty`, `witness_parse_empty_digit_string_rejected_case_dot`, `witness_parse_empty_digit_string_rejected_case_plus_dot` |
| `reads_unambiguous_8990216` | `ReadsUnambiguous` | `witness_reads_unambiguous_case_one_dot_zero`, `witness_reads_unambiguous_case_two_dot_five`, `witness_reads_unambiguous_case_long` |

## Framework Coverage

| Property | quickcheck | hedgehog | falsify | smallcheck |
|----------|---------:|-------:|------:|---------:|
| `FloorDangerouslySmallNegative` | ✓ | ✓ | ✓ | ✓ |
| `FromFloatDigitsRoundTrip` | ✓ | ✓ | ✓ | ✓ |
| `ParseEmptyDigitStringRejected` | ✓ | ✓ | ✓ | ✓ |
| `ReadsUnambiguous` | ✓ | ✓ | ✓ | ✓ |

## Bug Details

### 1. floor_dangerously_small_negative

- **Variant**: `floor_dangerously_small_negative_7d02b9d`
- **Location**: `src/Data/Scientific/Internal.hs:559` (inside `floor`)
- **Property**: `FloorDangerouslySmallNegative`
- **Witness(es)**:
  - `witness_floor_dangerously_small_negative_case_neg_one_e_neg_400` — floor (scientific (-1) (-400)) must equal -1
  - `witness_floor_dangerously_small_negative_case_neg_seven_e_neg_500` — floor (scientific (-7) (-500)) must equal -1
  - `witness_floor_dangerously_small_negative_case_pos_one_e_neg_400` — floor (scientific 1 (-400)) must equal 0 (sanity)
- **Source**: internal — Fix floor
  > RealFrac.floor on a Scientific with a dangerously-small (e <<-limit) negative coefficient must equal -1, not 0. Original commit short-circuited to 0 unconditionally; the fix added a sign check so negative inputs return -1.
- **Fix commit**: `7d02b9de9d10297be495aa23807457426a9d6163` — Fix floor
- **Invariant violated**: For any non-zero Scientific s with @-1 < s < 0@, @floor s == -1@.
- **How the mutation triggers**: Reverse-applying the patch deletes the @if c < 0 then -1 else 0@ branch, so the dangerouslySmall path always returns 0 — including for negative coefficients where -1 is correct.

### 2. from_float_digits_zero

- **Variant**: `from_float_digits_zero_0f28347`
- **Location**: `src/Data/Scientific/Internal.hs:692` (inside `fromFloatDigits`)
- **Property**: `FromFloatDigitsRoundTrip`
- **Witness(es)**:
  - `witness_from_float_digits_round_trip_case_zero` — fromFloatDigits (0 :: Double) must equal Scientific 0 0
  - `witness_from_float_digits_round_trip_case_one` — fromFloatDigits (1 :: Double) must equal Scientific 1 0 (sanity)
  - `witness_from_float_digits_round_trip_case_neg_one` — fromFloatDigits (-1 :: Double) must equal Scientific (-1) 0 (sanity)
- **Source**: internal — Introduce a special case for 0 in fromFloatDigits
  > fromFloatDigits 0 must equal @0 :: Scientific@. The original code went through Numeric.floatToDigits, which returned ([0], 0), and constructed an unnormalized Scientific 0 (-1). Under the structural Eq instance this is /= Scientific 0 0. The fix added a dedicated equation @fromFloatDigits 0 = 0@.
- **Fix commit**: `0f28347b4a3221a741f76a48f18ffb9de961e856` — Introduce a special case for 0 in fromFloatDigits
- **Invariant violated**: fromFloatDigits (fromIntegral n :: Double) == fromInteger (toInteger n) for every Int n.
- **How the mutation triggers**: Reverse-applying the patch removes the @fromFloatDigits 0 = 0@ equation. The fall-through path produces Scientific 0 (-1), which is /= the canonical fromInteger 0 = Scientific 0 0.

### 3. parse_empty_digit_string

- **Variant**: `parse_empty_digit_string_b3af22f`
- **Location**: `src/Data/Scientific/Internal.hs:921` (inside `foldDigits`)
- **Property**: `ParseEmptyDigitStringRejected`
- **Witness(es)**:
  - `witness_parse_empty_digit_string_rejected_case_empty` — scientificP "" must produce no successful parse
  - `witness_parse_empty_digit_string_rejected_case_dot` — scientificP "." must produce no successful parse
  - `witness_parse_empty_digit_string_rejected_case_plus_dot` — scientificP "+." must produce no successful parse
- **Source**: internal — Fix parsing of empty digit string (#21)
  > scientificP must reject any string containing zero decimal digits. The original foldDigits accepted empty input by returning the accumulator z, so parsing "" or "." succeeded with Scientific 0 0. The fix forces foldDigits to consume at least one decimal character.
- **Fix commit**: `b3af22fc0617581d932bb82c65c0652f0632283d` — Fix parsing of empty digit string (#21)
- **Invariant violated**: readP_to_S scientificP s == [] for any string s that contains no decimal digit.
- **How the mutation triggers**: Reverse-applying the patch removes the leading @ReadP.satisfy isDecimal@ from foldDigits, so scientificP accepts "", ".", "+.", etc., as valid (zero) inputs.

### 4. reads_unambiguous

- **Variant**: `reads_unambiguous_8990216`
- **Location**: `src/Data/Scientific/Internal.hs:893` (inside `scientificP`)
- **Property**: `ReadsUnambiguous`
- **Witness(es)**:
  - `witness_reads_unambiguous_case_one_dot_zero` — readP_to_S scientificP "1.0" must be a singleton
  - `witness_reads_unambiguous_case_two_dot_five` — readP_to_S scientificP "2.5" must be a singleton
  - `witness_reads_unambiguous_case_long` — readP_to_S scientificP "12345.67890" must be a singleton
- **Source**: internal — Stop 'reads' from producing ambiguous parses.
  > scientificP must produce exactly one parse for any string that is a valid integer-followed-by-fraction. The original used 'mplus' between the optional fractional branch and the no-fraction continuation, returning two parses. The fix replaced 'mplus' with the left-biased 'ReadP.<++'.
- **Fix commit**: `8990216e351c56f8186ca12cffbc09af95238eef` — Stop 'reads' from producing ambiguous parses.
- **Invariant violated**: length (readP_to_S scientificP s) == 1 for any string of the form <digits>.<digits>.
- **How the mutation triggers**: Reverse-applying the patch swaps the optional-fraction combinator from '<++' (committed choice) back to 'mplus' (non-deterministic), producing two parses for any input with a fractional part — one consuming the fraction, one stopping at the integer.
