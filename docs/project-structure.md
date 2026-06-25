# Projektstruktur

## Översikt

```
https-app.bilenia.se/
├── android/              # Android Studio-projekt (Gradle, manifest, res/)
├── ios/                  # Xcode-projekt
├── www/                  # [genererad] Vite build + mobile-shell patch
├── .frontend/            # [genererad] Git-klon av bilenia-dealer-panel
├── mobile-shell/         # mobile-boot.js + CSS (splash, hash entry)
├── resources/            # icon.png + splash.png (output från assets-skript)
├── scripts/              # fetch, build, patch, keystore, assets
├── capacitor.config.ts   # App-id, plugins, dev/prod server
└── docs/                 # Guider
```

## Android vs iOS

Båda plattformarna delar **samma** `www/`-innehåll efter web-build. Skillnaden är native-skalet:

- **Android:** `AndroidManifest.xml`, nätverkssäkerhet (cleartext dev/prod), ikoner i `mipmap-*`, splash i `drawable-*`
- **iOS:** `Info.plist`, `LaunchScreen.storyboard`, `Assets.xcassets`

`npx cap sync` kopierar `www/` till varje plattform (Android: `assets/public`, iOS: `App/public`).

## Build-flöde

1. `fetch-frontend.sh` — klonar frontend, checkar ut `FRONTEND_REF`
2. `build-web.sh` — `npm run build:mobile` i klonen, kopierar `dist/` → `www/`
3. `patch-www-mobile.sh` — injicerar splash/boot i `index.html`
4. `generate-native-assets.js` — uppdaterar ikoner/splash i android/ + ios/
5. `cap sync android|ios` — kopierar web + uppdaterar plugins

## Splash (tre lager)

1. **Native statisk** — svart skärm / "BILENIA" (genereras till android res + iOS Splash.imageset)
2. **Capacitor SplashScreen** — `launchAutoHide: false`, döljs från `mobile-boot.js`
3. **Web-animation** — bokstäver animeras i `mobile-boot.js` (~3,6 s, första session utan login)

`resources/splash.png` är en referens-output; per-density-filer genereras från samma SVG-mall i skriptet.

## Vad ska in i git?

**Ja — committa:**

- Hela `android/` och `ios/` **utom** genererade sync-artefakter (redan i `android/.gitignore`: `assets/public`, `capacitor.config.json` i assets)
- `scripts/`, `mobile-shell/`, `capacitor.config.ts`, `package.json`
- Genererade ikoner/splash i `res/` och `Assets.xcassets` (så clone + sync fungerar utan extra steg)

**Nej — ignorera:**

- `www/` — alltid resultat av `build-web.sh`
- `.frontend/` — klon
- `node_modules/`
- Keystore och lösenordsfiler
- Lokala `.env*`
