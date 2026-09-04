#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILE="${NATIVE_BUILD_PROFILE:-development}"

ANDROID_XML_DIR="${ROOT}/android/app/src/main/res/xml"
TARGET="${ANDROID_XML_DIR}/network_security_config.xml"
MANIFEST="${ROOT}/android/app/src/main/AndroidManifest.xml"
GRADLE="${ROOT}/android/app/build.gradle"
PBXPROJ="${ROOT}/ios/App/App.xcodeproj/project.pbxproj"

if [ "$PROFILE" = "production" ] && [ -f "${ROOT}/.env.production" ]; then
  set -a
  # shellcheck disable=SC1091
  source "${ROOT}/.env.production"
  set +a
fi

sed_inplace() {
  local pattern="$1"
  local file="$2"
  # GNU sed (Linux/Git Bash) vs BSD sed (macOS): different -i syntax; use -E not \| alternation.
  if [[ "${OSTYPE:-}" == darwin* ]]; then
    sed -i '' -E "$pattern" "$file"
  else
    sed -i -E "$pattern" "$file"
  fi
}

set_manifest_cleartext() {
  local value="$1"
  if [ ! -f "$MANIFEST" ]; then
    echo "Warning: AndroidManifest not found at $MANIFEST" >&2
    return 0
  fi
  sed_inplace "s/android:usesCleartextTraffic=\"(true|false)\"/android:usesCleartextTraffic=\"${value}\"/" "$MANIFEST"
}

apply_store_version() {
  local version_name="${NATIVE_VERSION_NAME:-}"
  local version_code="${NATIVE_VERSION_CODE:-}"

  if [ -z "$version_name" ] && [ -z "$version_code" ]; then
    return 0
  fi

  if [ -n "$version_code" ] && [[ ! "$version_code" =~ ^[0-9]+$ ]]; then
    echo "Ogiltigt NATIVE_VERSION_CODE: ${version_code} (måste vara heltal)" >&2
    exit 1
  fi

  if [ -n "$version_name" ] && [ -f "$GRADLE" ]; then
    sed_inplace "s/versionName \"[^\"]+\"/versionName \"${version_name}\"/" "$GRADLE"
  fi
  if [ -n "$version_code" ] && [ -f "$GRADLE" ]; then
    sed_inplace "s/versionCode [0-9]+/versionCode ${version_code}/" "$GRADLE"
  fi

  if [ -n "$version_name" ] && [ -f "$PBXPROJ" ]; then
    sed_inplace "s/MARKETING_VERSION = [^;]+;/MARKETING_VERSION = ${version_name};/" "$PBXPROJ"
  fi
  if [ -n "$version_code" ] && [ -f "$PBXPROJ" ]; then
    sed_inplace "s/CURRENT_PROJECT_VERSION = [0-9]+;/CURRENT_PROJECT_VERSION = ${version_code};/" "$PBXPROJ"
  fi

  echo "Native store version: ${version_name:-unchanged} (${version_code:-unchanged})"
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

apply_store_version
