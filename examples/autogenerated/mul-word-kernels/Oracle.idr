module Oracle
import Data.Bits
import Data.Buffer
import Data.List
import Data.String
import System
import System.File
import System.File.Buffer
%default covering

word_base : Integer
word_base = 4294967296
word_values : List Integer
word_values = [0,1,2,2147483648,4294967295]
word_result : String -> Integer -> Integer -> Integer
word_result "word_add" left right = (left+right) `mod` word_base
word_result "word_subtract" left right = (left+word_base-right) `mod` word_base
word_result "word_and" left right = left .&. right
word_result "word_or" left right = left .|. right
word_result "word_xor" left right = xor left right
word_result "word_product_low" left right = (left*right) `mod` word_base
word_result "word_product_high" left right = (left*right) `div` word_base
word_result "word_carry" left right = (left+right) `div` word_base
word_result "word_borrow" left right = if left<right then 1 else 0
word_result _ left right = 0

record WordVector where
  constructor V
  name : String
  first, second, third, fourth, result : Integer

vectors : List WordVector
vectors =
  [V name left right 0 0 (word_result name left right)
    | name <- ["word_add","word_subtract","word_and","word_or","word_xor",
               "word_product_low","word_product_high","word_carry","word_borrow"],
      left <- word_values, right <- word_values] ++
  [V "word_left_zero" 4294967295 0 0 0 4294967295,
   V "word_left_31" 3 0 0 0 2147483648, V "word_right_31" 2147483648 0 0 0 1,
   V "word_maximum" 0 0 0 0 4294967295] ++
  [V "word_add_chain" lower_left lower_right higher_left higher_right
     ((higher_left+higher_right+(lower_left+lower_right) `div` word_base) `mod` word_base)
    | (lower_left,lower_right,higher_left,higher_right) <-
      [(4294967295,1,4294967295,0),(4294967295,1,5,7)]] ++
  [V "word_borrow_chain" lower_left lower_right higher_left higher_right
     ((higher_left+word_base-higher_right-(if lower_left<lower_right then 1 else 0)) `mod` word_base)
    | (lower_left,lower_right,higher_left,higher_right) <- [(0,1,0,0),(0,1,1,0)]]

record_line : WordVector -> String
record_line (V name first second third fourth result) =
  "        .word " ++ show first ++ ", " ++ show second ++ ", " ++ show third ++ ", " ++ show fourth ++ ", " ++ show result ++ ", " ++ name

emit_vectors : String -> List WordVector -> IO ()
emit_vectors expected_path values = do
  if null values then exitWith (ExitFailure 8) else pure ()
  let number_of_bytes = 4*cast (length values)
  Just expected <- newBuffer number_of_bytes | _ => exitWith (ExitFailure 8)
  traverse_ (\(index,vector) => setBits32 expected (4*cast index) (cast vector.result))
    (zip (the (List Nat) [0..pred (length values)]) values)
  Right () <- writeBufferToFile expected_path expected number_of_bytes | _ => exitWith (ExitFailure 8)
  putStrLn ".section .rodata"
  putStrLn ".p2align 2"
  putStrLn ".global word_test_vectors, word_test_vectors_end, word_test_vector_count"
  putStrLn "word_test_vectors:"
  traverse_ (putStrLn . record_line) values
  putStrLn "word_test_vectors_end:"
  putStrLn "word_test_vector_count:"
  putStrLn ("        .word " ++ show (length values))
  putStrLn ".section .note.GNU-stack,\"\",%progbits"

record ProductRow where
  constructor Product
  identity : String
  left, right, product : Integer

parse_row : String -> Maybe ProductRow
parse_row text = do
  ["mul",identity,left_width,right_width,left_text,right_text,product_text] <- pure (words text)
    | _ => Nothing
  left <- parseInteger left_text
  right <- parseInteger right_text
  product <- parseInteger product_text
  pure (Product identity left right product)

word_profile : ProductRow -> Bool
word_profile row = row.left>=0 && row.right>=0 && row.left<word_base && row.right<word_base

emit_corpus : String -> String -> String -> IO ()
emit_corpus corpus_path expected_path refusal_path = do
  Right contents <- readFile corpus_path | _ => exitWith (ExitFailure 8)
  Just rows <- pure (traverse parse_row (drop 1 (lines contents))) | _ => exitWith (ExitFailure 8)
  if length rows==65704 && all (\row => row.product==row.left*row.right) rows
    then pure () else exitWith (ExitFailure 8)
  let admitted = filter word_profile rows
  let refused = filter (not . word_profile) rows
  Right () <- writeFile refusal_path
    (unlines ("id\treason" :: map (\row => row.identity ++ "\tout-of-Word32-domain") refused))
    | _ => exitWith (ExitFailure 8)
  let values = concatMap (\row => [V "word_product_low" row.left row.right 0 0 (row.product `mod` word_base), V "word_product_high" row.left row.right 0 0 (row.product `div` word_base)]) admitted
  emit_vectors expected_path values

main : IO ()
main = do
  args <- getArgs
  case args of
    [_,"words",expected_path] => emit_vectors expected_path vectors
    [_,"corpus",corpus_path,expected_path,refusal_path] => emit_corpus corpus_path expected_path refusal_path
    _ => exitWith (ExitFailure 8)
