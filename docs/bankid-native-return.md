# Native BankID return (App Links / Universal Links)

After deploying frontend with updated `.well-known` files:

## Your checklist

1. **Backend env (prod)**
   - `FRONTEND_URL=https://app.bilenia.se`
   - `BACKEND_PUBLIC_URL=https://<er-api-host>/api/v1` (absolute; used in Browser.open continue URLs)
   - Idura prod redirect URIs = same callback paths as test, but prod API host

2. **Database**
   ```bash
   npx prisma migrate deploy
   ```
   (migration `20260927120000_add_native_auth_exchange`)

3. **Apple App Site Association**
   - File is served at `https://app.bilenia.se/.well-known/apple-app-site-association`
   - Replace `REPLACE_WITH_TEAM_ID` with your Apple Team ID (format `TEAMID.se.bilenia.auctions`)
   - Content-Type should be `application/json` (no `.json` extension)

4. **Android Digital Asset Links**
   - Confirm `https://app.bilenia.se/.well-known/assetlinks.json` matches release keystore SHA-256
   - Package: `se.bilenia.app`

5. **Rebuild native apps** after AndroidManifest App Link path changes (`/auth`, `/kyc`, `/orders`)

6. **Verify**
   - Android: `adb shell pm get-app-links se.bilenia.app`
   - iOS: open `https://app.bilenia.se/auth` from Notes → should offer app
   - BankID login/register/KYC/contract sign on device
