# Bygga mobilappen

## Förutsättningar

- Node.js 18+
- Git Bash (Windows) eller macOS/Linux shell
- Android Studio (Android) / Xcode (iOS, endast macOS)
- Java `keytool` (ingår i JDK) för release-keystore

## Miljöfiler

| Fil | Profil | Användning |
|-----|--------|------------|
| `.env` eller `.env.local-dev` | development | LAN-API, cleartext HTTP tillåtet |
| `.env.production` | production | HTTPS prod-API, store-safe |

Kopiera från `*.example`-mallarna. Se [env-setup.md](env-setup.md).

## 1. Hämta frontend

```bash
FRONTEND_REF=epic/mobile_app npm run fetch:frontend
# eller efter merge:
FRONTEND_REF=main_proxy npm run fetch:frontend
```

Klonen hamnar i `.frontend/bilenia-dealer-panel` (gitignored).

## 2. Bygga webb (→ www/)

### Dev (fysisk enhet / emulator mot lokal backend)

```bash
# Sätt .env med LAN-IP (npm run print:api-host)
NATIVE_BUILD_PROFILE=development bash scripts/build-web.sh
```

### Prod (Play Store / App Store)

```bash
NATIVE_BUILD_PROFILE=production bash scripts/build-web.sh
```

Detta kör även `patch-www-mobile.sh` och `generate-native-assets.js`.

## 3. Synka till native

### Android

```bash
NATIVE_BUILD_PROFILE=production bash scripts/apply-native-build-profile.sh
NATIVE_BUILD_PROFILE=production npx cap sync android
npm run open:android
```

Eller kort: `NATIVE_BUILD_PROFILE=production bash scripts/build-web.sh && ... sync` via npm på macOS/Linux:

```bash
npm run build:android:prod   # fungerar i Git Bash på Windows om env sätts i script
```

**Windows:** använd bash-raderna ovan direkt.

### iOS (macOS)

```bash
NATIVE_BUILD_PROFILE=production bash scripts/build-web.sh
NATIVE_BUILD_PROFILE=production npx cap sync ios
npm run open:ios
```

## Vanliga npm-kommandon

```bash
npm run fetch:frontend
npm run build:web:dev
npm run build:web:prod
npm run build:android:dev
npm run build:android:prod
npm run build:ios:dev
npm run build:ios:prod
npm run print:api-host
npm run assets:native    # endast ikoner/splash, kräver befintlig www/favicon.ico
```

## Utveckla frontend parallellt

Redigera i din lokala checkout av `bilenia-dealer-panel` (`epic/mobile_app`). Efter commit/push:

```bash
FRONTEND_REF=epic/mobile_app npm run fetch:frontend
NATIVE_BUILD_PROFILE=development bash scripts/build-web.sh
NATIVE_BUILD_PROFILE=development npx cap sync android
```

## Felsökning

| Problem | Åtgärd |
|---------|--------|
| API nås inte från telefon | `npm run print:api-host`, brandvägg, backend på `0.0.0.0:5000` |
| Emulator Android | `VITE_API_BASE_URL=http://10.0.2.2:5000/api/v1` |
| USB + adb | `adb reverse tcp:5000 tcp:5000` + `localhost` i .env |
| `npm run build:android:prod` failar på Windows | Kör `bash scripts/build-web.sh` med `NATIVE_BUILD_PROFILE` |
| Xcode: `missing package product 'CapacitorApp'` | `cap sync ios` kördes på Windows → backslashes i `ios/App/CapApp-SPM/Package.swift`. Kör **endast på Mac**: `node scripts/fix-ios-spm-paths.js` (eller `npm run sync:ios:prod`), sedan Xcode **File → Packages → Reset Package Caches**. Kräver `npm install` i shell-repot så `node_modules/` finns. |
| iOS sync generellt | Kör **aldrig** `cap sync ios` på Windows — endast macOS. Android sync fungerar på Windows. |
