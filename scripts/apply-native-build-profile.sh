#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILE="${NATIVE_BUILD_PROFILE:-development}"

ANDROID_XML_DIR="${ROOT}/android/app/src/main/res/xml"
TARGET="${ANDROID_XML_DIR}/network_security_config.xml"

if [ "$PROFILE" = "production" ]; then
  cp "${ANDROID_XML_DIR}/network_security_config_prod.xml" "$TARGET"
  echo "Native build profile: production (cleartext disabled)"
else
  cp "${ANDROID_XML_DIR}/network_security_config_dev.xml" "$TARGET"
  echo "Native build profile: development (cleartext allowed for LAN API)"
fi
