# Android release-keystore

## Vad är en keystore?

En krypterad fil som innehåller **signeringsnyckeln** för er app. Google Play verifierar att varje uppdatering är signerad med samma nyckel som originalversionen.

**Fil:** `android/bilenia-release.keystore` (gitignored)  
**Alias:** `bilenia` (standard i vårt skript)

## Lösenord — vad är det?

Ni väljer **själva** två lösenord när `keytool` frågar (eller när ni fyller `keystore.properties`):

| Lösenord | Syfte |
|----------|--------|
| **Keystore password** | Låser upp hela `.keystore`-filen |
| **Key password** | Låser upp nyckeln med alias `bilenia` |

De **kan vara samma** — vanligt och enklare. Välj ett starkt lösenord och spara i password manager.

**Google kan inte återställa** förlorad keystore eller glömda lösenord.

## Skapa keystore (engång)

Kör i terminal (interaktivt — ni fyller i lösenord själva):

```bash
npm run keystore:android
```

Eller manuellt:

```bash
keytool -genkey -v \
  -keystore android/bilenia-release.keystore \
  -alias bilenia \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

`validity 10000` ≈ 27 år.

### Efter skapande

1. **Backup** `bilenia-release.keystore` till säker plats (inte bara på en laptop)
2. Spara lösenord säkert
3. Skapa `android/keystore.properties` från mallen:

```bash
cp android/keystore.properties.example android/keystore.properties
```

## Samma keystore vid ombyggen?

**Ja — alltid samma keystore** för `se.bilenia.app` på Play Store.

När ni:

- ändrar frontend i `bilenia-dealer-panel`
- kör `fetch` + prod build igen
- laddar upp ny AAB med högre `versionCode`

…använder ni **samma** `bilenia-release.keystore`. Endast appinnehållet (`www/`) ändras.

Ny keystore = ny app i Play Stores ögon (kan inte uppdatera befintlig listing).

## Var används keystore?

- **Gradle release build** — läser `android/keystore.properties` (se `android/app/build.gradle`)
- **Android Studio** — "Generate Signed Bundle" kan peka på samma fil

## Vad ska INTE committas

- `android/bilenia-release.keystore`
- `android/keystore.properties`
- Lösenord i chat, CI-loggar eller dokumentation

Mallen `keystore.properties.example` med platshållare **kan** committas.

## Förlorad keystore?

Utan backup kan ni **inte** publicera uppdateringar** till befintlig app. Kontakta Google Play support för extremfall (key reset-program) — undvik genom backup.
