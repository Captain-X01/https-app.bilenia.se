#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KEYSTORE="${ROOT}/android/bilenia-release.keystore"

if [ -f "$KEYSTORE" ]; then
  echo "Keystore finns redan: ${KEYSTORE}" >&2
  echo "Ta backup — utan denna fil kan ni inte uppdatera appen på Play Store." >&2
  exit 1
fi

echo "Skapar release-keystore för BILENIA Android-app..."
echo ""
echo "Du väljer SJÄLVA lösenorden (keytool frågar interaktivt):"
echo "  - Keystore password  = låser .keystore-filen"
echo "  - Key password       = kan vara samma; låser alias 'bilenia'"
echo "Spara lösenord + fil som backup UTANFÖR repot."
echo "Samma keystore används för alla framtida Play Store-uppdateringar."
echo "Se docs/keystore-android.md"
echo ""

keytool -genkey -v \
  -keystore "$KEYSTORE" \
  -alias bilenia \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000

echo ""
echo "Klart. Nästa steg:"
echo "  1. cp android/keystore.properties.example android/keystore.properties"
echo "  2. Fyll i lösenord i keystore.properties"
echo "  3. npm run build:android:prod   # prod store build"
echo "     npm run build:android:dev    # dev test build (LAN API)"
echo "  4. Android Studio → Build → Generate Signed Bundle (AAB)"
