module SmsReaderDexGen

import Backend.DEX.EncodeSmsReader
import System

%default covering

private
fail : String -> IO a
fail explanation = do
  putStrLn ("FAIL: " ++ explanation)
  exitFailure

main : IO ()
main = do
  result <- write_sms_reader_activity_dex "build/exec/sms-reader/classes.dex"
  case result of
    Left explanation => fail explanation
    Right () => putStrLn "PASS: direct SMS reader classes.dex generated"
