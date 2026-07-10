#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILE="${NATIVE_BUILD_PROFILE:-development}"

ANDROID_XML_DIR="${ROOT}/android/app/src/main/res/xml"
TARGET="${ANDROID_XML_DIR}/network_security_config.xml"
MANIFEST="${ROOT}/android/app/src/main/AndroidManifest.xml"

set_manifest_cleartext() {
  local value="$1"
  if [ ! -f "$MANIFEST" ]; then
    echo "Warning: AndroidManifest not found at $MANIFEST" >&2
    return 0
  fi
  # GNU sed (Linux/Git Bash) vs BSD sed (macOS): different -i syntax; use -E not \| alternation.
  local pattern="s/android:usesCleartextTraffic=\"(true|false)\"/android:usesCleartextTraffic=\"${value}\"/"
  if [[ "${OSTYPE:-}" == darwin* ]]; then
    sed -i '' -E "$pattern" "$MANIFEST"
  else
    sed -i -E "$pattern" "$MANIFEST"
  fi
}

if [ "$PROFILE" = "production" ]; then
  cp "${ANDROID_XML_DIR}/network_security_config_prod.xml" "$TARGET"
  set_manifest_cleartext "false"
  echo "Native build profile: production (cleartext disabled)"
else
  cp "${ANDROID_XML_DIR}/network_security_config_dev.xml" "$TARGET"
  set_manifest_cleartext "true"
  echo "Native build profile: development (cleartext allowed for LAN API)"
fi
