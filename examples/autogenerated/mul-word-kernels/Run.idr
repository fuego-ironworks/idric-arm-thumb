module Run
import Data.Buffer
import Data.List
import Data.String
import Data.So
import System
import System.Escape
import System.File
import System.File.Buffer
%default covering

save : String -> String -> IO ()
save path text = do
  Right () <- writeFile path text | _ => exitWith (ExitFailure 8)
  pure ()

copyResults : File -> File -> Buffer -> Int -> IO Int
copyResults source destination chunk number_of_bytes = do
  Right count <- readBufferData source chunk 0 4096 | _ => pure (-1)
  if count==0 then pure number_of_bytes else do
    Right () <- writeBufferData destination chunk 0 count | _ => pure (-1)
    copyResults source destination chunk (number_of_bytes+count)

binaryRun : List String -> String -> IO (Int,Int)
binaryRun args output = do
  Right destination <- openFile output WriteTruncate | _ => pure (8,-1)
  Right source <- popen (escapeCmd args) Read | _ => do closeFile destination; pure (8,-1)
  Just chunk <- newBuffer 4096 | _ => do closeFile destination; _ <- pclose source; pure (8,-1)
  count <- copyResults source destination chunk 0
  closeFile destination
  status <- pclose source
  pure (status,count)

one : String -> String -> String -> String -> IO Int
one qemu executable expected artifact_stem = do
  Right expected_file <- openFile expected Read | _ => pure 8
  expected_size <- fileSize expected_file
  closeFile expected_file
  Right number_of_expected_bytes <- pure expected_size | _ => pure 8
  (status,count) <- binaryRun [qemu,"-cpu","cortex-a9",executable] (artifact_stem ++ ".results.bin")
  save (artifact_stem ++ ".candidate.status") (show status ++ "\n")
  save (artifact_stem ++ ".result-bytes") (show count ++ "\n")
  (message, comparison) <- System.Escaped.run ["cmp",expected,artifact_stem ++ ".results.bin"]
  save (artifact_stem ++ ".comparison.stdout") message
  save (artifact_stem ++ ".comparison.status") (show comparison ++ "\n")
  pure (if status/=0 then status else if number_of_expected_bytes<=0 || count/=number_of_expected_bytes || comparison/=0 then 9 else 0)

finish : Int -> IO ()
finish 0 = pure ()
finish status =
  let exit_status = if status>0 && status<256 then status else 8 in
  case choose (not (exit_status==0)) of
    Left nonzero => exitWith (ExitFailure exit_status @{nonzero})
    Right _ => exitWith (ExitFailure 8)

patchLine : String -> String -> String -> String
patchLine before after text = unlines (map (\line => if line==before then after else line) (lines text))

mutate : String -> String -> String
mutate "wrong-add" = patchLine "        add.w   r0, r0, r1" "        sub.w   r0, r0, r1"
mutate "drop-high" = patchLine "        mov     r0, r3" "        movw    r0, #0"
mutate "drop-carry" = patchLine "        adc.w   r0, r0, r0" "        movw    r0, #0"
mutate "zero" = patchLine "        bx      lr" "        movw    r0, #0\n        bx      lr"
mutate _ = id

compile : String -> List String -> IO ()
compile clang inputs = do
  status <- System.Escaped.system ([clang,"--target=armv7a-linux-gnueabihf","-fuse-ld=lld",
    "-nostdlib","-static","-march=armv7-a","-mthumb","-mfpu=vfpv3-d16",
    "-mfloat-abi=softfp","-Wl,-e,_start","-Wl,--no-dynamic-linker"] ++ inputs)
  if status==0 then pure () else finish status

negative : String -> String -> String -> String -> String -> Int -> IO Bool
negative self qemu executable expected artifact_stem required = do
  (message,status) <- System.Escaped.run [self,"one",qemu,executable,expected,artifact_stem]
  save (artifact_stem ++ ".outer.stdout") message
  save (artifact_stem ++ ".outer.status") (show status ++ "\n")
  Right child <- readFile (artifact_stem ++ ".candidate.status") | _ => pure False
  Right comparison <- readFile (artifact_stem ++ ".comparison.status") | _ => pure False
  let detected = status==required && child==show required ++ "\n" && (required/=57 || comparison=="0\n")
  putStrLn ((if detected then "PASS " else "FAIL ") ++ artifact_stem ++ " status=" ++ show status)
  pure detected

mutants : String -> String -> String -> String -> String -> String -> String -> String -> IO ()
mutants self clang qemu assembly vectors harness expected directory = do
  Right original <- readFile assembly | _ => finish 8
  Right originalHarness <- readFile harness | _ => finish 8
  arithmetic <- traverse (\name => do
    let artifact_stem = directory ++ "/" ++ name
    let changed = mutate name original
    if changed==original then finish 8 else pure ()
    save (artifact_stem ++ ".S") changed
    compile clang [artifact_stem ++ ".S",vectors,harness,"-o",artifact_stem]
    negative self qemu artifact_stem expected artifact_stem 43) ["wrong-add","drop-high","drop-carry","zero"]
  let artifact_stem = directory ++ "/forced-exit"
  let changed = patchLine "        movs r0, #0" "        movs r0, #57" originalHarness
  if changed==originalHarness then finish 8 else pure ()
  save (artifact_stem ++ ".S") changed
  compile clang [assembly,vectors,artifact_stem ++ ".S","-o",artifact_stem]
  forced <- negative self qemu artifact_stem expected artifact_stem 57
  if all id arithmetic && forced then pure () else finish 9

reject_source : Int -> String -> String -> String -> String -> IO ()
reject_source required driver source name artifact_stem = do
  -- The existing System.run/popen interface fixes the process-shell boundary.
  -- Arguments remain escaped; only stderr is joined to the captured stream.
  (message,status) <- System.run (escapeCmd [driver,"--cg","arm-thumb","--source-dir",
    "tests/source",source,"-o",name] ++ " 2>&1")
  save (artifact_stem ++ ".stdout") message
  save (artifact_stem ++ ".status") (show status ++ "\n")
  save (artifact_stem ++ ".required.status") (show required ++ "\n")
  present <- exists (artifact_stem ++ ".arm-thumb.S")
  if status==required && isInfixOf "Word shifts require a constant count from 0 through 31" message && not present
    then putStrLn ("PASS refused " ++ name ++ " status=" ++ show status) else finish 9

main : IO ()
main = do
  args <- getArgs
  case args of
    [_,"one",qemu,executable,expected,artifact_stem] => finish !(one qemu executable expected artifact_stem)
    [self,"mutants",clang,qemu,assembly,vectors,harness,expected,directory] =>
      mutants self clang qemu assembly vectors harness expected directory
    [_,"reject",driver,source,name,artifact_stem] => do
      reject_source 1 driver source name artifact_stem
    [_,"reject-corrupt",driver,source,name,artifact_stem] =>
      reject_source 0 driver source name artifact_stem
    [self,"reject-proof",driver,source,name,artifact_stem] => do
      (message,status) <- System.Escaped.run [self,"reject-corrupt",driver,source,name,artifact_stem]
      save (artifact_stem ++ ".corrupt-outer.stdout") message
      save (artifact_stem ++ ".corrupt-outer.status") (show status ++ "\n")
      Right child <- readFile (artifact_stem ++ ".status") | _ => finish 9
      if status==9 && child=="1\n" then putStrLn "PASS corrupted rejection expectation fails through outer runner"
        else finish 9
    _ => do putStrLn "usage: Run one QEMU ELF EXPECTED PREFIX | Run mutants CLANG QEMU ASSEMBLY VECTORS HARNESS EXPECTED DIRECTORY"
            finish 8
