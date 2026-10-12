module Oracle
import Data.Bits
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
main : IO ()
main = do
  putStrLn ".section .rodata"
  putStrLn ".p2align 2"
  putStrLn ".global word_test_vectors, word_test_vectors_end"
  putStrLn "word_test_vectors:"
  traverse_ putStrLn
    [record_line name left right (word_result name left right)
      | name <- ["word_add","word_subtract","word_and","word_or","word_xor",
                 "word_product_low","word_product_high","word_carry","word_borrow"],
        left <- word_values, right <- word_values]
  putStrLn (record_line "word_left_zero" 4294967295 0 4294967295)
  putStrLn (record_line "word_left_31" 3 0 2147483648)
  putStrLn (record_line "word_right_31" 2147483648 0 1)
  putStrLn (record_line "word_maximum" 0 0 4294967295)
  putStrLn "word_test_vectors_end:"
  putStrLn ".section .note.GNU-stack,\"\",%progbits"
