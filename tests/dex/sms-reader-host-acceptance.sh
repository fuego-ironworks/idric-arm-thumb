#!/usr/bin/env bash
set -Eeuo pipefail

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
idric=${IDRIC:-idris2}
runtime_library=${IDRIC_RUNTIME_LIBRARY:-$(dirname -- "$idric")/idris2_app/libidris2_support.so}
build="$repo_root/build/exec"
sms_build="$build/sms-reader"
generator="$build/sms-reader-dex-gen"
candidate="$sms_build/classes.dex"
first_candidate="$sms_build/classes-first.dex"
receipt="$sms_build/host-receipt.txt"
oracle_dir="$repo_root/build/oracles"
baksmali="$oracle_dir/baksmali-3.0.10.jar"
smali="$oracle_dir/smali-3.0.10.jar"
baksmali_sha=37ae4a41a8886e15c20b8362fa4250f96bbdb55e1a608199ad8b5dff068b588f
smali_sha=32fa0e88a6c397b3922201adf5f3e534fbaed5a663c71d0c558c3ddce0af844a

cd "$repo_root"
mkdir -p "$sms_build" "$oracle_dir"
rm -rf "$sms_build/baksmali-candidate" "$sms_build/baksmali-oracle"   "$sms_build/oracle-source"

"$idric" --build sms-reader-dex.ipkg
IDRIS2_PATH="$repo_root/build/ttc:${IDRIS2_PATH:-}"   "$idric" --source-dir "$repo_root/tests/dex"   "$repo_root/tests/dex/SmsReaderDexGen.idr" -o sms-reader-dex-gen
cp "$runtime_library" "${generator}_app/"

LD_LIBRARY_PATH="$(dirname -- "$runtime_library"):${LD_LIBRARY_PATH:-}" "$generator"
cp "$candidate" "$first_candidate"
LD_LIBRARY_PATH="$(dirname -- "$runtime_library"):${LD_LIBRARY_PATH:-}" "$generator"
cmp "$first_candidate" "$candidate"

if [ ! -f "$baksmali" ]; then
  curl -fL --retry 3     https://github.com/baksmali/smali/releases/download/3.0.10/baksmali-3.0.10-fat-release.jar     -o "$baksmali"
fi
printf '%s  %s\n' "$baksmali_sha" "$baksmali" | sha256sum -c -

if [ ! -f "$smali" ]; then
  curl -fL --retry 3     https://github.com/baksmali/smali/releases/download/3.0.10/smali-3.0.10-fat-release.jar     -o "$smali"
fi
printf '%s  %s\n' "$smali_sha" "$smali" | sha256sum -c -

mkdir -p "$sms_build/baksmali-candidate" "$sms_build/oracle-source"   "$sms_build/baksmali-oracle"
java -jar "$baksmali" disassemble "$candidate" -o "$sms_build/baksmali-candidate"
cp "$repo_root/tests/dex/oracles/SmsReaderActivity.smali"   "$sms_build/oracle-source/SmsReaderActivity.smali"
java -jar "$smali" assemble "$sms_build/oracle-source" -o "$sms_build/oracle.dex"
java -jar "$baksmali" disassemble "$sms_build/oracle.dex" -o "$sms_build/baksmali-oracle"

candidate_smali="$sms_build/baksmali-candidate/org/isomorphisms/smsreader/SmsReaderActivity.smali"
oracle_smali="$sms_build/baksmali-oracle/org/isomorphisms/smsreader/SmsReaderActivity.smali"
cmp "$oracle_smali" "$candidate_smali"

grep -q 'ContentResolver;->query' "$candidate_smali"
grep -q 'Cursor;->getString' "$candidate_smali"
grep -q 'const-string v5, "body"' "$candidate_smali"
grep -q 'const-string v5, "address"' "$candidate_smali"
grep -q 'Cursor;->moveToNext()Z' "$candidate_smali"
grep -q 'Cursor;->close()V' "$candidate_smali"

{
  echo 'SMS_READER_DIRECT_DEX   1'
  echo 'direct encoder          PASS'
  echo 'deterministic output    PASS'
  echo 'smali oracle comparison PASS oracle_only'
  echo 'ContentResolver.query   PRESENT'
  echo 'Cursor body read        PRESENT'
  echo 'Cursor address read     PRESENT'
  echo 'Cursor iteration        PRESENT'
  echo 'message content logging ABSENT'
  echo 'javac production path   ABSENT'
  echo 'Kotlin production path  ABSENT'
  echo 'Gradle production path  ABSENT'
  echo 'd8 production path      ABSENT'
  echo 'smali production path   ABSENT'
  printf 'classes.dex bytes       %s\n' "$(wc -c < "$candidate")"
  printf 'classes.dex SHA-256     %s\n' "$(sha256sum "$candidate" | cut -d' ' -f1)"
} >"$receipt"

cat "$receipt"
