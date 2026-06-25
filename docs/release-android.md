# Android release (Google Play)

## Keystore — engång

Se [keystore-android.md](keystore-android.md) för detaljer.

**Kort:** Samma keystore används för **alla framtida uppdateringar** på Play Store. Byt aldrig keystore för samma `applicationId` (`se.bilenia.app`) — Google accepterar bara uppdateringar signerade med samma nyckel.

Frontend-ändringar och ombyggen påverkar **inte** keystore — bara innehållet i `www/`.

## Första release

### 1. Skapa keystore (interaktivt)

```bash
npm run keystore:android
```

`keytool` frågar om:

- **Keystore-lösenord** — välj ett starkt lösenord du sparar (t.ex. i password manager)
- **Key-lösenord** — kan vara samma som keystore-lösenord
- Namn, organisation, land (t.ex. `SE`) — metadata i certifikatet

Spara `android/bilenia-release.keystore` **utanför repot** (backup på säker plats).

### 2. keystore.properties

```bash
cp android/keystore.properties.example android/keystore.properties
```

Fyll i **samma lösenord** du valde i steg 1:

```properties
storeFile=../bilenia-release.keystore
storePassword=DITT_KEYSTORE_LÖSENORD
keyAlias=bilenia
keyPassword=DITT_KEY_LÖSENORD
```

### 3. Prod-build

```bash
FRONTEND_REF=main_proxy npm run fetch:frontend
NATIVE_BUILD_PROFILE=production bash scripts/build-web.sh
NATIVE_BUILD_PROFILE=production npx cap sync android
```

### 4. Signed AAB i Android Studio

1. `npm run open:android`
2. **Build → Generate Signed Bundle / APK**
3. Välj **Android App Bundle**
4. Välj `bilenia-release.keystore` + lösenord
5. Release build variant

Ladda upp `.aab` till [Google Play Console](https://play.google.com/console).

## Versioner vid uppdatering

Redigera `android/app/build.gradle`:

```gradle
defaultConfig {
    versionCode 2        // Heltal — MÅSTE öka varje uppladdning
    versionName "1.0.1"  // Visas för användare (valfritt format)
}
```

| Fält | Regel |
|------|--------|
| `versionCode` | Strikt ökande heltal (1, 2, 3, …) |
| `versionName` | Fri text ("1.0.1", "1.1.0") |

Efter ändring: prod build + ny signed AAB.

## Checklista store-listing

- [ ] Privacy policy: `https://app.bilenia.se/privacy`
- [ ] Support: `https://app.bilenia.se/contact`
- [ ] Screenshots (telefon + ev. tablet)
- [ ] `assetlinks.json` på `app.bilenia.se` för App Links (`/auctions`, `/notifications`)
- [ ] Prod smoke test på fysisk enhet

## Dev vs release-signering

| Build | Signering |
|-------|-----------|
| Debug / dev install | Android Studio debug key |
| Play Store | `bilenia-release.keystore` via `keystore.properties` eller Studio wizard |

`build.gradle` kopplar release-signering automatiskt om `keystore.properties` finns.
