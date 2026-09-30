#!/usr/bin/env bash
set -Eeuo pipefail

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/../../.." && pwd)
adb_command=${ADB:-adb}
receipt=${SMS_READER_PHONE_RECEIPT:-"$repo_root/build/exec/sms-reader/phone-receipt.txt"}
apk="$repo_root/build/exec/sms-reader/sms-reader.apk"
package=org.isomorphisms.smsreader
activity="$package/.SmsReaderActivity"

mkdir -p "$(dirname -- "$receipt")"

fail_phone() {
  local reason=$1
  {
    echo 'physical Android phone FAIL'
    printf 'reason                 %s\n' "$reason"
  } >"$receipt"
  cat "$receipt"
  exit 1
}

not_verified() {
  local reason=$1
  {
    echo 'physical Android SMS NOT_VERIFIED'
    printf 'reason                 %s\n' "$reason"
  } >"$receipt"
  cat "$receipt"
  exit 2
}

command -v "$adb_command" >/dev/null 2>&1 || fail_phone 'adb is unavailable'
"$adb_command" get-state >/dev/null 2>&1 || fail_phone 'no Android device is connected'

kernel_qemu=$("$adb_command" shell getprop ro.kernel.qemu 2>/dev/null | tr -d '\r')
boot_qemu=$("$adb_command" shell getprop ro.boot.qemu 2>/dev/null | tr -d '\r')
[[ $kernel_qemu != 1 ]] || fail_phone 'connected runtime is an emulator'
[[ $boot_qemu != 1 ]] || fail_phone 'connected runtime is an emulator'

phone_fingerprint=$("$adb_command" shell getprop ro.build.fingerprint | tr -d '\r')
[[ -n $phone_fingerprint ]] || fail_phone 'missing phone fingerprint'

cd "$repo_root"
IDRIC=${IDRIC:-idris2} bash tests/dex/sms-reader-host-acceptance.sh
bash tests/dex/sms-reader/build-apk.sh

"$adb_command" install -r "$apk" >/dev/null

# READ_SMS is dangerous and hard-restricted on current Android. Do not turn a
# failed sideload grant into a false compiler failure.
if ! "$adb_command" shell pm grant "$package" android.permission.READ_SMS >/dev/null 2>&1; then
  not_verified 'READ_SMS could not be granted to this sideloaded package; use an allowlisting installer or a privileged/rooted development device'
fi

granted=$("$adb_command" shell dumpsys package "$package" |
  grep -F 'android.permission.READ_SMS:' | head -n 1 || true)
case "$granted" in
  *granted=true*) ;;
  *) not_verified 'READ_SMS is not granted after pm grant' ;;
esac

"$adb_command" logcat -c
"$adb_command" shell am force-stop "$package"
"$adb_command" shell am start -W -n "$activity" >/dev/null
log=$("$adb_command" logcat -d -s IdricSmsCount:I '*:S' || true)
count=$(printf '%s\n' "$log" | sed -n 's/.*IdricSmsCount[^:]*: *\([0-9][0-9]*\).*/\1/p' | tail -n 1)

[[ -n $count ]] || fail_phone 'Activity ran but no IdricSmsCount receipt appeared'

{
  echo 'physical Android SMS PASS'
  printf 'phone fingerprint       %s\n' "$phone_fingerprint"
  printf 'SMS rows observed       %s\n' "$count"
  echo 'message contents logged NO'
  if [[ $count -gt 0 ]]; then
    echo 'body/address loop       EXECUTED'
  else
    echo 'body/address loop       NOT_VERIFIED empty_provider'
  fi
} >"$receipt"

cat "$receipt"
