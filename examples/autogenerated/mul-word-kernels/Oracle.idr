module Oracle
import Data.Bits
import Data.Buffer
import System
import System.File.Buffer
%default total
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
record_line : String -> Integer -> Integer -> Integer -> String
record_line name left right result =
  "        .word " ++ show left ++ ", " ++ show right ++ ", " ++ show result ++ ", " ++ name
vectors : List (String,Integer,Integer,Integer)
vectors =
  [(name,left,right,word_result name left right)
    | name <- ["word_add","word_subtract","word_and","word_or","word_xor",
               "word_product_low","word_product_high","word_carry","word_borrow"],
      left <- word_values, right <- word_values] ++
  [("word_left_zero",4294967295,0,4294967295),
   ("word_left_31",3,0,2147483648), ("word_right_31",2147483648,0,1),
   ("word_maximum",0,0,4294967295)]
main : IO ()
main = do
  args <- getArgs
  [_,expectedPath] <- pure args | _ => exitWith (ExitFailure 8)
  Just expected <- newBuffer 916 | _ => exitWith (ExitFailure 8)
  traverse_ (\(index,(_,_,_,value)) => setBits32 expected (4*cast index) (cast value)) (zip [0..228] vectors)
  Right () <- writeBufferToFile expectedPath expected 916 | _ => exitWith (ExitFailure 8)
  putStrLn ".section .rodata"
  putStrLn ".p2align 2"
  putStrLn ".global word_test_vectors, word_test_vectors_end"
  putStrLn "word_test_vectors:"
  traverse_ (\(name,left,right,result) => putStrLn (record_line name left right result)) vectors
  putStrLn "word_test_vectors_end:"
  putStrLn ".section .note.GNU-stack,\"\",%progbits"
