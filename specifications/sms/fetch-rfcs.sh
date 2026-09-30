#!/usr/bin/env bash
set -Eeuo pipefail

here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
destination="$here/rfc"
mkdir -p "$destination"

for number in 5724 3966 3986 5234; do
  curl -fL --retry 3     "https://www.rfc-editor.org/rfc/rfc${number}.txt"     -o "$destination/rfc${number}.txt"
done

printf 'RFC text copied from RFC Editor into %s\n' "$destination"
