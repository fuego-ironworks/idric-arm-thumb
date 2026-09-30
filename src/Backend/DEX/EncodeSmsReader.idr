module Backend.DEX.EncodeSmsReader

import Backend.DEX.Encode
import Backend.DEX.Hash
import Data.List
import Data.Maybe

%default covering

private
unsigned_mod : Integer -> Integer -> Integer
unsigned_mod value modulus =
  let reduced = value `mod` modulus
  in if reduced < 0 then reduced + modulus else reduced

private
u16le : Integer -> List Int
u16le value =
  let encoded = unsigned_mod value 65536
  in [cast (encoded `mod` 256), cast ((encoded `div` 256) `mod` 256)]

private
u32le : Integer -> List Int
u32le value =
  let encoded = unsigned_mod value 4294967296
  in [ cast (encoded `mod` 256)
     , cast ((encoded `div` 256) `mod` 256)
     , cast ((encoded `div` 65536) `mod` 256)
     , cast ((encoded `div` 16777216) `mod` 256)
     ]

private
uleb128 : Integer -> List Int
uleb128 value =
  if value < 0
    then []
    else
      let byte = value `mod` 128
          rest = value `div` 128
      in if rest == 0
           then [cast byte]
           else cast (byte + 128) :: uleb128 rest

private
align_up : Int -> Int -> Int
align_up offset alignment =
  let remainder = offset `mod` alignment
  in if remainder == 0 then offset else offset + alignment - remainder

private
padding : Int -> Int -> List Int
padding offset alignment =
  replicate (cast (align_up offset alignment - offset)) 0

private
replace_range : Int -> List Int -> List Int -> List Int
replace_range offset replacement bytes =
  take (cast offset) bytes ++ replacement ++
  drop (cast (offset + cast (length replacement))) bytes

private
words : List Integer -> List Int
words values = concat (map u16le values)

private
ascii_bytes : String -> Either String (List Int)
ascii_bytes value = traverse encode_character (unpack value)
  where
    encode_character : Char -> Either String Int
    encode_character character =
      let code = ord character
      in if code >= 1 && code <= 127
           then Right code
           else Left
             ("SMS reader DEX metadata must be non-NUL ASCII: " ++
              show character)

private
record StringLayout where
  constructor MkStringLayout
  bytes : List Int
  offsets : List (String, Int)
  first_offset : Int
  next_offset : Int

private
layout_strings_from :
  Int -> List String -> List Int -> List (String, Int) -> Maybe Int ->
  Either String StringLayout
layout_strings_from current [] accumulated offsets first =
  Right (MkStringLayout accumulated offsets (fromMaybe current first) current)
layout_strings_from current (value :: rest) accumulated offsets first = do
  encoded <- ascii_bytes value
  let item = uleb128 (cast (length (unpack value))) ++ encoded ++ [0]
  let next_first =
        case first of
          Nothing => Just current
          Just existing => Just existing
  layout_strings_from (current + cast (length item)) rest
    (accumulated ++ item) (offsets ++ [(value, current)]) next_first

private
layout_strings : Int -> List String -> Either String StringLayout
layout_strings start values =
  layout_strings_from start values [] [] Nothing

private
find_string_offset : String -> List (String, Int) -> Either String Int
find_string_offset requested [] =
  Left ("Missing SMS reader DEX string data for " ++ requested)
find_string_offset requested ((value, offset) :: rest) =
  if requested == value
    then Right offset
    else find_string_offset requested rest

private
record TypeListLayout where
  constructor MkTypeListLayout
  bytes : List Int
  offsets : List Int
  first_offset : Int
  next_offset : Int

private
layout_type_lists_from :
  Int -> List (List Int) -> List Int -> List Int -> Maybe Int -> TypeListLayout
layout_type_lists_from current [] accumulated offsets first =
  MkTypeListLayout accumulated offsets (fromMaybe current first) current
layout_type_lists_from current (types :: rest) accumulated offsets first =
  let start = align_up current 4
      pad = padding current 4
      item = u32le (cast (length types)) ++ concat (map (u16le . cast) types)
      next = start + cast (length item)
      next_first =
        case first of
          Nothing => Just start
          Just existing => Just existing
  in layout_type_lists_from next rest
       (accumulated ++ pad ++ item) (offsets ++ [start]) next_first

private
layout_type_lists : Int -> List (List Int) -> TypeListLayout
layout_type_lists start values =
  layout_type_lists_from start values [] [] Nothing

private
map_item : Integer -> Int -> Int -> List Int
map_item item_type count offset =
  u16le item_type ++ u16le 0 ++ u32le (cast count) ++ u32le (cast offset)

private
code_item : Int -> Int -> Int -> List Int -> List Int
code_item registers incoming outgoing instructions =
  u16le (cast registers) ++
  u16le (cast incoming) ++
  u16le (cast outgoing) ++
  u16le 0 ++
  u32le 0 ++
  u32le (cast (length instructions) `div` 2) ++
  instructions

private
sms_reader_strings : List String
sms_reader_strings =
  [ "<init>"
  , "I"
  , "IL"
  , "ILL"
  , "IdricSmsCount"
  , "L"
  , "LI"
  , "LL"
  , "LLLLL"
  , "Landroid/app/Activity;"
  , "Landroid/content/ContentResolver;"
  , "Landroid/content/Context;"
  , "Landroid/database/Cursor;"
  , "Landroid/net/Uri;"
  , "Landroid/os/Bundle;"
  , "Landroid/os/CancellationSignal;"
  , "Landroid/util/Log;"
  , "Ljava/lang/Integer;"
  , "Ljava/lang/String;"
  , "Lorg/isomorphisms/smsreader/SmsReaderActivity;"
  , "V"
  , "VL"
  , "Z"
  , "[Ljava/lang/String;"
  , "address"
  , "body"
  , "close"
  , "content://sms"
  , "getColumnIndex"
  , "getContentResolver"
  , "getCount"
  , "getString"
  , "i"
  , "moveToFirst"
  , "moveToNext"
  , "onCreate"
  , "parse"
  , "query"
  , "toString"
  ]

||| Direct DEX proof that Edriç can cross the ordinary Android framework
||| boundary needed for a read-only SMS reader.
|||
||| The generated Activity:
|||   * calls ContentResolver.query("content://sms", null, null, null);
|||   * logs only the number of rows under the tag IdricSmsCount;
|||   * obtains the "body" and "address" column indexes;
|||   * walks the cursor and calls getString for both columns on every row;
|||   * closes the cursor.
|||
||| Message text and addresses are deliberately not written to logcat.
||| READ_SMS permission handling belongs to APK/install acceptance, not DEX.
public export
encode_sms_reader_activity_dex : Either String (List Int)
encode_sms_reader_activity_dex = do
  let strings = sms_reader_strings
  let string_ids_off = 112
  let type_ids_off = string_ids_off + 4 * cast (length strings)
  let proto_ids_off = type_ids_off + 4 * 15
  let method_ids_off = proto_ids_off + 12 * 10
  let class_defs_off = method_ids_off + 8 * 15
  let data_off = class_defs_off + 32

  -- Parameter type lists, in proto_id order excluding parameterless protos:
  -- 1 (String)I
  -- 2 (String,String)I
  -- 4 (Uri,String[],Bundle,CancellationSignal)Cursor
  -- 5 (String)Uri
  -- 6 (I)String
  -- 8 (Bundle)V
  let type_lists =
        layout_type_lists data_off
          [ [10]
          , [10, 10]
          , [5, 14, 6, 7]
          , [10]
          , [0]
          , [6]
          ]
  case type_lists.offsets of
    [proto1_off, proto2_off, proto4_off, proto5_off, proto6_off, proto8_off] => do
      -- Method ids, fixed by DEX sort order:
      --  0 Activity.<init>()V
      --  1 Activity.onCreate(Bundle)V
      --  2 ContentResolver.query(Uri,String[],Bundle,CancellationSignal)Cursor
      --  3 Context.getContentResolver()ContentResolver
      --  4 Cursor.close()V
      --  5 Cursor.getColumnIndex(String)I
      --  6 Cursor.getCount()I
      --  7 Cursor.getString(I)String
      --  8 Cursor.moveToFirst()Z
      --  9 Cursor.moveToNext()Z
      -- 10 Uri.parse(String)Uri
      -- 11 Log.i(String,String)I
      -- 12 Integer.toString(I)String
      -- 13 SmsReaderActivity.<init>()V
      -- 14 SmsReaderActivity.onCreate(Bundle)V

      let init_instructions =
            words
              [ 0x1070, 0, 0
              , 0x000e
              ]

      -- v8/p0 = this, v9/p1 = Bundle.
      -- Branch offsets are DEX code-unit offsets from the branch opcode.
      let oncreate_instructions =
            words
              [ 0x206f, 1, 0x0098                 -- super.onCreate(p0,p1)
              , 0x106e, 3, 0x0008                 -- getContentResolver(p0)
              , 0x010c                            -- move-result-object v1
              , 0x051a, 27                        -- v5 = "content://sms"
              , 0x1071, 10, 0x0005                -- Uri.parse(v5)
              , 0x000c                            -- move-result-object v0
              , 0x0212                            -- v2 = null
              , 0x256e, 2, 0x2201                 -- resolver.query(v0,v2,v2,v2)
              , 0x030c                            -- move-result-object v3
              , 0x0338, 51                        -- if-eqz v3, done
              , 0x1072, 6, 0x0003                 -- cursor.getCount()
              , 0x040a                            -- move-result v4
              , 0x1071, 12, 0x0004                -- Integer.toString(v4)
              , 0x050c                            -- move-result-object v5
              , 0x001a, 4                         -- v0 = "IdricSmsCount"
              , 0x2071, 11, 0x0050                -- Log.i(v0,v5)
              , 0x040a                            -- discard Log.i result
              , 0x051a, 25                        -- v5 = "body"
              , 0x2072, 5, 0x0053                 -- getColumnIndex(v5)
              , 0x060a                            -- body index v6
              , 0x051a, 24                        -- v5 = "address"
              , 0x2072, 5, 0x0053                 -- getColumnIndex(v5)
              , 0x070a                            -- address index v7
              , 0x1072, 8, 0x0003                 -- moveToFirst()
              , 0x040a                            -- move-result v4
              , 0x0438, 16                        -- if-eqz v4, close
              , 0x2072, 7, 0x0063                 -- loop: getString(body index)
              , 0x050c                            -- body v5 (not logged)
              , 0x2072, 7, 0x0073                 -- getString(address index)
              , 0x050c                            -- address v5 (not logged)
              , 0x1072, 9, 0x0003                 -- moveToNext()
              , 0x040a                            -- move-result v4
              , 0x0439, -12                       -- if-nez v4, loop
              , 0x1072, 4, 0x0003                 -- close
              , 0x000e                            -- done: return-void
              ]

      let init_code = code_item 1 1 1 init_instructions
      let oncreate_code = code_item 10 2 5 oncreate_instructions

      let init_code_off = align_up type_lists.next_offset 4
      let after_init = init_code_off + cast (length init_code)
      let oncreate_code_off = align_up after_init 4
      let after_oncreate = oncreate_code_off + cast (length oncreate_code)
      let code_bytes =
            padding type_lists.next_offset 4 ++ init_code ++
            padding after_init 4 ++ oncreate_code

      strings_layout <- layout_strings after_oncreate strings

      let class_data_bytes =
            uleb128 0 ++ uleb128 0 ++ uleb128 1 ++ uleb128 1 ++
            -- direct: constructor, absolute method id 13
            uleb128 13 ++ uleb128 0x10001 ++ uleb128 (cast init_code_off) ++
            -- virtual: protected onCreate, absolute method id 14
            uleb128 14 ++ uleb128 0x4 ++ uleb128 (cast oncreate_code_off)

      let class_data_off = strings_layout.next_offset
      let before_map = class_data_off + cast (length class_data_bytes)
      let map_off = align_up before_map 4
      let map_count = 11
      let map_bytes =
            u32le (cast map_count) ++ concat
              [ map_item 0x0000 1 0
              , map_item 0x0001 (cast (length strings)) string_ids_off
              , map_item 0x0002 15 type_ids_off
              , map_item 0x0003 10 proto_ids_off
              , map_item 0x0005 15 method_ids_off
              , map_item 0x0006 1 class_defs_off
              , map_item 0x1001 6 type_lists.first_offset
              , map_item 0x2001 2 init_code_off
              , map_item 0x2002 (cast (length strings)) strings_layout.first_offset
              , map_item 0x2000 1 class_data_off
              , map_item 0x1000 1 map_off
              ]

      let file_size = map_off + cast (length map_bytes)
      let data_size = file_size - data_off

      string_id_bytes <-
        traverse
          (\value => do
            offset <- find_string_offset value strings_layout.offsets
            Right (u32le (cast offset)))
          strings

      -- type_ids, ordered by descriptor string index.
      let type_id_bytes =
            map u32le [1, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 22, 23]

      -- proto_ids ordered by result type then parameter type list.
      let proto_id_bytes =
            [ u32le 1  ++ u32le 0  ++ u32le 0
            , u32le 2  ++ u32le 0  ++ u32le (cast proto1_off)
            , u32le 3  ++ u32le 0  ++ u32le (cast proto2_off)
            , u32le 5  ++ u32le 2  ++ u32le 0
            , u32le 8  ++ u32le 4  ++ u32le (cast proto4_off)
            , u32le 7  ++ u32le 5  ++ u32le (cast proto5_off)
            , u32le 6  ++ u32le 10 ++ u32le (cast proto6_off)
            , u32le 20 ++ u32le 12 ++ u32le 0
            , u32le 21 ++ u32le 12 ++ u32le (cast proto8_off)
            , u32le 22 ++ u32le 13 ++ u32le 0
            ]

      -- method_ids ordered by class, name, prototype.
      let method_id_bytes =
            [ u16le 1  ++ u16le 7 ++ u32le 0
            , u16le 1  ++ u16le 8 ++ u32le 35
            , u16le 2  ++ u16le 4 ++ u32le 37
            , u16le 3  ++ u16le 3 ++ u32le 29
            , u16le 4  ++ u16le 7 ++ u32le 26
            , u16le 4  ++ u16le 1 ++ u32le 28
            , u16le 4  ++ u16le 0 ++ u32le 30
            , u16le 4  ++ u16le 6 ++ u32le 31
            , u16le 4  ++ u16le 9 ++ u32le 33
            , u16le 4  ++ u16le 9 ++ u32le 34
            , u16le 5  ++ u16le 5 ++ u32le 36
            , u16le 8  ++ u16le 2 ++ u32le 32
            , u16le 9  ++ u16le 6 ++ u32le 38
            , u16le 11 ++ u16le 7 ++ u32le 0
            , u16le 11 ++ u16le 8 ++ u32le 35
            ]

      let class_def_bytes =
            u32le 11 ++ u32le 0x1 ++
            u32le 1 ++ u32le 0 ++
            u32le 0xffffffff ++ u32le 0 ++
            u32le (cast class_data_off) ++ u32le 0

      let header =
            [100, 101, 120, 10, 48, 51, 53, 0] ++
            replicate 4 0 ++ replicate 20 0 ++
            u32le (cast file_size) ++ u32le 112 ++ u32le 0x12345678 ++
            u32le 0 ++ u32le 0 ++ u32le (cast map_off) ++
            u32le (cast (length strings)) ++ u32le (cast string_ids_off) ++
            u32le 15 ++ u32le (cast type_ids_off) ++
            u32le 10 ++ u32le (cast proto_ids_off) ++
            u32le 0 ++ u32le 0 ++
            u32le 15 ++ u32le (cast method_ids_off) ++
            u32le 1 ++ u32le (cast class_defs_off) ++
            u32le (cast data_size) ++ u32le (cast data_off)

      let unsigned_file =
            header ++ concat string_id_bytes ++ concat type_id_bytes ++
            concat proto_id_bytes ++ concat method_id_bytes ++ class_def_bytes ++
            type_lists.bytes ++ code_bytes ++ strings_layout.bytes ++
            class_data_bytes ++ padding before_map 4 ++ map_bytes

      if cast (length unsigned_file) /= file_size
        then
          Left
            ("Internal SMS reader DEX layout mismatch: planned " ++
             show file_size ++ " bytes, encoded " ++ show (length unsigned_file))
        else Right ()

      let signature = sha1 (drop 32 unsigned_file)
      if length signature /= 20
        then Left "Internal SHA-1 implementation did not return 20 bytes"
        else Right ()
      let signed_file = replace_range 12 signature unsigned_file
      let checksum = adler32 (drop 12 signed_file)
      Right (replace_range 8 (u32le checksum) signed_file)
    _ => Left "Internal SMS reader type-list layout mismatch"

||| Write the direct SMS reader classes.dex candidate.
public export
write_sms_reader_activity_dex : String -> IO (Either String ())
write_sms_reader_activity_dex path =
  case encode_sms_reader_activity_dex of
    Left explanation => pure (Left explanation)
    Right bytes => write_dex path bytes
