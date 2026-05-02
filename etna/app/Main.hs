{-# LANGUAGE LambdaCase          #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import           Control.Exception     (SomeException, try)
import           Data.IORef            (newIORef, readIORef, modifyIORef')
import           Data.Time.Clock       (diffUTCTime, getCurrentTime)
import           System.Environment    (getArgs)
import           System.Exit           (exitWith, ExitCode(..))
import           System.IO             (hFlush, stdout)
import           Text.Printf           (printf)

import           Etna.Result           (PropertyResult(..))
import qualified Etna.Properties       as P
import qualified Etna.Witnesses        as W
import qualified Etna.Gens.QuickCheck  as GQ
import qualified Etna.Gens.Hedgehog    as GH
import qualified Etna.Gens.Falsify     as GF
import qualified Etna.Gens.SmallCheck  as GS

import qualified Test.QuickCheck                   as QC
import qualified Hedgehog                          as HH
import qualified Test.Falsify.Generator            as FG
import qualified Test.Falsify.Interactive          as FI
import qualified Test.Falsify.Property             as FP
import qualified Test.SmallCheck                   as SC
import qualified Test.SmallCheck.Drivers           as SCD
import qualified Test.SmallCheck.Series            as SCS

allProperties :: [String]
allProperties =
  [ "FloorDangerouslySmallNegative"
  , "ParseEmptyDigitStringRejected"
  , "ReadsUnambiguous"
  , "FromFloatDigitsRoundTrip"
  ]

data Outcome = Outcome
  { oStatus :: String
  , oTests  :: Int
  , oCex    :: Maybe String
  , oErr    :: Maybe String
  }

main :: IO ()
main = do
  argv <- getArgs
  case argv of
    [tool, prop] -> dispatch tool prop
    _            -> do
      putStrLn "{\"status\":\"aborted\",\"error\":\"usage: etna-runner <tool> <property>\"}"
      hFlush stdout
      exitWith (ExitFailure 2)

dispatch :: String -> String -> IO ()
dispatch tool prop
  | prop /= "All" && prop `notElem` allProperties =
      emit tool prop "aborted" 0 0 Nothing (Just $ "unknown property: " ++ prop)
  | otherwise = do
      let targets = if prop == "All" then allProperties else [prop]
      mapM_ (runOne tool) targets

runOne :: String -> String -> IO ()
runOne tool prop = do
  t0 <- getCurrentTime
  result <- try (driver tool prop) :: IO (Either SomeException Outcome)
  t1 <- getCurrentTime
  let us = round ((realToFrac (diffUTCTime t1 t0) :: Double) * 1e6) :: Int
  case result of
    Left e  -> emit tool prop "aborted" 0 us Nothing (Just (show e))
    Right (Outcome status tests cex err) ->
      emit tool prop status tests us cex err

driver :: String -> String -> IO Outcome
driver "etna"       p = runWitnesses p
driver "quickcheck" p = runQuickCheck p
driver "hedgehog"   p = runHedgehog   p
driver "falsify"    p = runFalsify    p
driver "smallcheck" p = runSmallCheck p
driver tool         _ = pure (Outcome "aborted" 0 Nothing (Just ("unknown tool: " ++ tool)))

------------------------------------------------------------------------------
-- Witness replay
------------------------------------------------------------------------------
runWitnesses :: String -> IO Outcome
runWitnesses prop = case witnessesFor prop of
  []    -> pure (Outcome "aborted" 0 Nothing (Just ("no witnesses for " ++ prop)))
  cs    -> go cs 0
  where
    go [] n = pure (Outcome "passed" n Nothing Nothing)
    go ((name, r):rest) n = case r of
      Pass     -> go rest (n + 1)
      Discard  -> go rest (n + 1)
      Fail msg -> pure (Outcome "failed" (n + 1) (Just name) (Just msg))

witnessesFor :: String -> [(String, PropertyResult)]
witnessesFor "FloorDangerouslySmallNegative" =
  [ ("witness_floor_dangerously_small_negative_case_neg_one_e_neg_400",
      W.witness_floor_dangerously_small_negative_case_neg_one_e_neg_400)
  , ("witness_floor_dangerously_small_negative_case_neg_seven_e_neg_500",
      W.witness_floor_dangerously_small_negative_case_neg_seven_e_neg_500)
  , ("witness_floor_dangerously_small_negative_case_pos_one_e_neg_400",
      W.witness_floor_dangerously_small_negative_case_pos_one_e_neg_400)
  ]
witnessesFor "ParseEmptyDigitStringRejected" =
  [ ("witness_parse_empty_digit_string_rejected_case_empty",
      W.witness_parse_empty_digit_string_rejected_case_empty)
  , ("witness_parse_empty_digit_string_rejected_case_dot",
      W.witness_parse_empty_digit_string_rejected_case_dot)
  , ("witness_parse_empty_digit_string_rejected_case_plus_dot",
      W.witness_parse_empty_digit_string_rejected_case_plus_dot)
  ]
witnessesFor "ReadsUnambiguous" =
  [ ("witness_reads_unambiguous_case_one_dot_zero",
      W.witness_reads_unambiguous_case_one_dot_zero)
  , ("witness_reads_unambiguous_case_two_dot_five",
      W.witness_reads_unambiguous_case_two_dot_five)
  , ("witness_reads_unambiguous_case_long",
      W.witness_reads_unambiguous_case_long)
  ]
witnessesFor "FromFloatDigitsRoundTrip" =
  [ ("witness_from_float_digits_round_trip_case_zero",
      W.witness_from_float_digits_round_trip_case_zero)
  , ("witness_from_float_digits_round_trip_case_one",
      W.witness_from_float_digits_round_trip_case_one)
  , ("witness_from_float_digits_round_trip_case_neg_one",
      W.witness_from_float_digits_round_trip_case_neg_one)
  ]
witnessesFor _ = []

------------------------------------------------------------------------------
-- QuickCheck
------------------------------------------------------------------------------
runQuickCheck :: String -> IO Outcome
runQuickCheck "FloorDangerouslySmallNegative" =
  qcDrive (QC.forAll GQ.gen_floor_dangerously_small_negative
            (qcProp P.property_floor_dangerously_small_negative))
runQuickCheck "ParseEmptyDigitStringRejected" =
  qcDrive (QC.forAll GQ.gen_parse_empty_digit_string_rejected
            (qcProp P.property_parse_empty_digit_string_rejected))
runQuickCheck "ReadsUnambiguous" =
  qcDrive (QC.forAll GQ.gen_reads_unambiguous
            (qcProp P.property_reads_unambiguous))
runQuickCheck "FromFloatDigitsRoundTrip" =
  qcDrive (QC.forAll GQ.gen_from_float_digits_round_trip
            (qcProp P.property_from_float_digits_round_trip))
runQuickCheck p = pure (Outcome "aborted" 0 Nothing (Just ("unknown property: " ++ p)))

qcProp :: (a -> PropertyResult) -> a -> QC.Property
qcProp f args = case f args of
  Pass     -> QC.property True
  Discard  -> QC.discard
  Fail msg -> QC.counterexample msg (QC.property False)

qcDrive :: QC.Property -> IO Outcome
qcDrive p = do
  result <- QC.quickCheckWithResult
              QC.stdArgs { QC.maxSuccess = 200, QC.chatty = False } p
  case result of
    QC.Success { QC.numTests = n } -> pure (Outcome "passed" n Nothing Nothing)
    QC.Failure { QC.numTests = n, QC.failingTestCase = tc } ->
      pure (Outcome "failed" n (Just (concat tc)) Nothing)
    QC.GaveUp  { QC.numTests = n } ->
      pure (Outcome "aborted" n Nothing (Just "QuickCheck gave up"))
    QC.NoExpectedFailure { QC.numTests = n } ->
      pure (Outcome "aborted" n Nothing (Just "no expected failure"))

------------------------------------------------------------------------------
-- Hedgehog
------------------------------------------------------------------------------
runHedgehog :: String -> IO Outcome
runHedgehog "FloorDangerouslySmallNegative" =
  hhDrive GH.gen_floor_dangerously_small_negative
          P.property_floor_dangerously_small_negative
runHedgehog "ParseEmptyDigitStringRejected" =
  hhDrive GH.gen_parse_empty_digit_string_rejected
          P.property_parse_empty_digit_string_rejected
runHedgehog "ReadsUnambiguous" =
  hhDrive GH.gen_reads_unambiguous
          P.property_reads_unambiguous
runHedgehog "FromFloatDigitsRoundTrip" =
  hhDrive GH.gen_from_float_digits_round_trip
          P.property_from_float_digits_round_trip
runHedgehog p = pure (Outcome "aborted" 0 Nothing (Just ("unknown property: " ++ p)))

hhDrive :: (Show a) => HH.Gen a -> (a -> PropertyResult) -> IO Outcome
hhDrive gen f = do
  let test = HH.property $ do
        args <- HH.forAll gen
        case f args of
          Pass     -> pure ()
          Discard  -> HH.discard
          Fail msg -> do
            HH.annotate msg
            HH.failure
  ok <- HH.check test
  if ok
    then pure (Outcome "passed" 200 Nothing Nothing)
    else pure (Outcome "failed" 1 Nothing Nothing)

------------------------------------------------------------------------------
-- Falsify
------------------------------------------------------------------------------
runFalsify :: String -> IO Outcome
runFalsify "FloorDangerouslySmallNegative" =
  fsDrive GF.gen_floor_dangerously_small_negative
          P.property_floor_dangerously_small_negative
runFalsify "ParseEmptyDigitStringRejected" =
  fsDrive GF.gen_parse_empty_digit_string_rejected
          P.property_parse_empty_digit_string_rejected
runFalsify "ReadsUnambiguous" =
  fsDrive GF.gen_reads_unambiguous
          P.property_reads_unambiguous
runFalsify "FromFloatDigitsRoundTrip" =
  fsDrive GF.gen_from_float_digits_round_trip
          P.property_from_float_digits_round_trip
runFalsify p = pure (Outcome "aborted" 0 Nothing (Just ("unknown property: " ++ p)))

fsDrive :: (Show a) => FG.Gen a -> (a -> PropertyResult) -> IO Outcome
fsDrive gen f = do
  let prop = do
        args <- FP.gen gen
        case f args of
          Pass     -> pure ()
          Discard  -> FP.discard
          Fail msg -> FP.testFailed (show args ++ ": " ++ msg)
  mFailure <- FI.falsify prop
  case mFailure of
    Nothing  -> pure (Outcome "passed" 100 Nothing Nothing)
    Just msg -> pure (Outcome "failed" 1 (Just msg) Nothing)

------------------------------------------------------------------------------
-- SmallCheck
------------------------------------------------------------------------------
runSmallCheck :: String -> IO Outcome
runSmallCheck "FloorDangerouslySmallNegative" =
  scDrive GS.series_floor_dangerously_small_negative
          P.property_floor_dangerously_small_negative
runSmallCheck "ParseEmptyDigitStringRejected" =
  scDrive GS.series_parse_empty_digit_string_rejected
          P.property_parse_empty_digit_string_rejected
runSmallCheck "ReadsUnambiguous" =
  scDrive GS.series_reads_unambiguous
          P.property_reads_unambiguous
runSmallCheck "FromFloatDigitsRoundTrip" =
  scDrive GS.series_from_float_digits_round_trip
          P.property_from_float_digits_round_trip
runSmallCheck p = pure (Outcome "aborted" 0 Nothing (Just ("unknown property: " ++ p)))

scDrive :: (Show a) => SCS.Series IO a -> (a -> PropertyResult) -> IO Outcome
scDrive series f = do
  countRef <- newIORef (0 :: Int)
  let depth = 5
      check args = SC.monadic $ do
        modifyIORef' countRef (+1)
        pure $ case f args of
          Pass    -> True
          Discard -> True
          Fail _  -> False
      smTest = SC.over series check
  res <- try (SCD.smallCheckM depth smTest)
           :: IO (Either SomeException (Maybe SCD.PropertyFailure))
  n <- readIORef countRef
  case res of
    Left e          -> pure (Outcome "failed" n Nothing (Just (show e)))
    Right Nothing   -> pure (Outcome "passed" n Nothing Nothing)
    Right (Just pf) -> pure (Outcome "failed" n (Just (show pf)) Nothing)

------------------------------------------------------------------------------
-- Output
------------------------------------------------------------------------------
emit :: String -> String -> String -> Int -> Int -> Maybe String -> Maybe String -> IO ()
emit tool prop status tests us cex err = do
  let q = quoteJSON
      esc Nothing  = "null"
      esc (Just s) = q s
  printf "{\"status\":%s,\"tests\":%d,\"discards\":0,\"time\":\"%dus\",\"counterexample\":%s,\"error\":%s,\"tool\":%s,\"property\":%s}\n"
    (q status) tests us (esc cex) (esc err) (q tool) (q prop)
  hFlush stdout

quoteJSON :: String -> String
quoteJSON s = '"' : concatMap esc s ++ "\""
  where
    esc '"'  = "\\\""
    esc '\\' = "\\\\"
    esc '\n' = "\\n"
    esc '\r' = "\\r"
    esc '\t' = "\\t"
    esc c | fromEnum c < 0x20 = printf "\\u%04x" (fromEnum c)
          | otherwise = [c]
