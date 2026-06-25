# iOS release (App Store / TestFlight)

## Skillnad mot Android

| | Android | iOS |
|---|---------|-----|
| Signering | Egen `.keystore`-fil ni skapar och förvarar | Apple Developer-certifikat via Xcode |
| Uppdateringar | Samma keystore för alltid | Samma Apple Team + bundle ID |
| Build-artefakt | `.aab` | `.ipa` (via Archive) |
| IDE | Android Studio | Xcode (macOS krävs) |

## Förutsättningar

- Mac med Xcode
- [Apple Developer Program](https://developer.apple.com/programs/) (betald)
- Bundle ID: `se.bilenia.app` (matcha `capacitor.config.ts`)

## Synka web till iOS

Efter prod web-build (samma `www/` som Android):

```bash
NATIVE_BUILD_PROFILE=production bash scripts/build-web.sh
NATIVE_BUILD_PROFILE=production npx cap sync ios
npm run open:ios
```

Eller: `NATIVE_BUILD_PROFILE=production bash scripts/build-web.sh && NATIVE_BUILD_PROFILE=production npx cap sync ios`

## Första release

1. Öppna `ios/App/App.xcworkspace` i Xcode
2. **Signing & Capabilities** → välj Team, Automatic signing
3. Verifiera **Bundle Identifier** = `se.bilenia.app`
4. **Product → Archive**
5. **Distribute App** → App Store Connect / TestFlight

## Versioner vid uppdatering

I Xcode → target **App** → **General**:

| Fält | Xcode-nyckel | Regel |
|------|--------------|--------|
| Version | `MARKETING_VERSION` | Användarsynlig ("1.0.1") |
| Build | `CURRENT_PROJECT_VERSION` | Heltal, måste öka per uppladdning |

Samma värden finns i `ios/App/App.xcodeproj/project.pbxproj`.

Efter frontend-ändring: ny prod web-build → `cap sync ios` → ny Archive.

## Splash och ikoner på iOS

Genereras av `generate-native-assets.js` vid web-build:

- `Assets.xcassets/AppIcon.appiconset/`
- `Assets.xcassets/Splash.imageset/`
- `LaunchScreen.storyboard` refererar till Splash-bilden

Web-splash-animationen (`mobile-boot.js`) körs i WebView på iOS precis som Android.

## Deep links

Lägg `apple-app-site-association` på `https://app.bilenia.se` för Universal Links (samma paths som Android manifest: `/auctions`, `/notifications`).

## Checklista

- [ ] Privacy policy URL i App Store Connect
- [ ] Kamerabehörighet (`NSCameraUsageDescription` i Info.plist — redan satt)
- [ ] TestFlight intern test innan publicering
- [ ] Prod smoke test på fysisk iPhone
