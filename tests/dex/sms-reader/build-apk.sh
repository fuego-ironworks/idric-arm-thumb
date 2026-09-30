#!/usr/bin/env bash
set -Eeuo pipefail

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/../../.." && pwd)
classes_dex=${1:-"$repo_root/build/exec/sms-reader/classes.dex"}
output=${2:-"$repo_root/build/exec/sms-reader/sms-reader.apk"}
android_home=${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}

[[ -f $classes_dex ]] || { echo "missing direct classes.dex: $classes_dex" >&2; exit 1; }
[[ -n $android_home ]] || { echo 'ANDROID_HOME/ANDROID_SDK_ROOT is required' >&2; exit 1; }

build_tools=${ANDROID_BUILD_TOOLS:-}
if [[ -z $build_tools ]]; then
  build_tools=$(find "$android_home/build-tools" -mindepth 1 -maxdepth 1 -type d |
    sort -V | tail -n 1)
fi
[[ -d $build_tools ]] || { echo 'Android build-tools not found' >&2; exit 1; }

aapt2="$build_tools/aapt2"
zipalign="$build_tools/zipalign"
apksigner="$build_tools/apksigner"
android_jar="$android_home/platforms/android-29/android.jar"
for required in "$aapt2" "$zipalign" "$apksigner" "$android_jar"; do
  [[ -e $required ]] || { echo "missing Android packaging input: $required" >&2; exit 1; }
done

work="$repo_root/build/exec/sms-reader/apk-work"
rm -rf "$work"
mkdir -p "$work" "$(dirname -- "$output")"

unsigned="$work/manifest.apk"
unaligned="$work/unaligned.apk"
aligned="$work/aligned.apk"
keystore="$work/debug.keystore"

"$aapt2" link   -I "$android_jar"   --manifest "$repo_root/tests/dex/sms-reader/AndroidManifest.xml"   --min-sdk-version 26   --target-sdk-version 29   -o "$unsigned"

cp "$unsigned" "$unaligned"
zip -q -j "$unaligned" "$classes_dex"

"$zipalign" -f -p 4 "$unaligned" "$aligned"
keytool -genkeypair -noprompt   -keystore "$keystore"   -storepass android   -keypass android   -alias androiddebugkey   -dname 'CN=Android Debug,O=Android,C=US'   -keyalg RSA   -keysize 2048   -validity 10000 >/dev/null 2>&1
"$apksigner" sign   --ks "$keystore"   --ks-pass pass:android   --key-pass pass:android   --out "$output"   "$aligned"
"$apksigner" verify --verbose "$output"
printf 'SMS reader APK          %s\n' "$output"
