# BILENIA native app shell

Capacitor-projekt som paketerar React-appen från [bilenia-dealer-panel](https://github.com/Captain-X01/bilenia-dealer-panel) till Android och iOS.

**Frontend** utvecklas i `bilenia-dealer-panel`. **Detta repo** innehåller native-projekt, build-skript och mobile boot (splash, hash-routing).

## Snabbstart (dev, Android)

```bash
cp .env.local-dev.example .env.local-dev
# Redigera VITE_API_BASE_URL (npm run print:api-host)
cp .env.local-dev .env

npm install
FRONTEND_REF=epic/mobile_app npm run fetch:frontend
NATIVE_BUILD_PROFILE=development bash scripts/build-web.sh
NATIVE_BUILD_PROFILE=development npx cap sync android
npm run open:android
```

På Windows: kör `bash scripts/...` direkt (npm-scripts med `VAR=value` fungerar dåligt i cmd).

## Snabbstart (prod store-build)

```bash
cp .env.production.example .env.production
# Verifiera FRONTEND_REF och VITE_*-URL:er

FRONTEND_REF=main_proxy npm run fetch:frontend   # efter merge till main_proxy
NATIVE_BUILD_PROFILE=production bash scripts/build-web.sh
NATIVE_BUILD_PROFILE=production npx cap sync android
NATIVE_BUILD_PROFILE=production npx cap sync ios
```

## Vad committas i git?

| Committa | Ignorera (genereras/lokalt) |
|----------|-----------------------------|
| `android/`, `ios/` (native-projekt, manifest, ikoner) | `www/` (web-build) |
| `scripts/`, `mobile-shell/`, `capacitor.config.ts` | `.frontend/` (klon) |
| `package.json`, `resources/` (referensbilder) | `node_modules/` |
| `*.example` env-mallar | `.env`, `.env.production`, `.env.local-dev` |
| | `android/*.keystore`, `keystore.properties` |
| | `android/app/src/main/assets/public` (kopieras vid sync) |

Se [docs/project-structure.md](docs/project-structure.md).

## Dokumentation

| Guide | Innehåll |
|-------|----------|
| [docs/building.md](docs/building.md) | Fetch, dev/prod-build, sync |
| [docs/release-android.md](docs/release-android.md) | Keystore, AAB, versionCode, uppdateringar |
| [docs/release-ios.md](docs/release-ios.md) | Xcode, Archive, TestFlight, versioner |
| [docs/env-setup.md](docs/env-setup.md) | .env-filer och FRONTEND_REF |
| [docs/keystore-android.md](docs/keystore-android.md) | Skapa och förvara release-keystore |
| [docs/frontend-branches.md](docs/frontend-branches.md) | epic/mobile_app vs main_proxy |

## npm-scripts

| Script | Beskrivning |
|--------|-------------|
| `fetch:frontend` | Klonar frontend till `.frontend/` |
| `build:web:dev` / `build:web:prod` | Bygger React → `www/` |
| `build:android:dev` / `build:android:prod` | Web-build + `cap sync android` |
| `build:ios:dev` / `build:ios:prod` | Web-build + `cap sync ios` |
| `sync:android:*` / `sync:ios:*` | Endast Capacitor sync |
| `keystore:android` | Skapar release-keystore (engång) |
| `print:api-host` | LAN-IP för dev API |
| `open:android` / `open:ios` | Öppna IDE |
