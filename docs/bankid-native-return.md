# Native BankID return (custom URL scheme)

## Short answers

| Question | Answer |
|----------|--------|
| iOS bundle is `se.bilenia.auctions` — does that matter? | **No for opening the app.** Bundle ID ≠ URL scheme. We register schemes `se.bilenia.app` **and** `se.bilenia.auctions` on iOS. Backend redirects use `se.bilenia.app://…` (same as Android package). |
| After BankID, does the app show auth again? | **Login/register:** yes — success *or* error → `se.bilenia.app://auth?…` → native `#/auth` (dialogs/toasts). **Signing:** → `se.bilenia.app://orders?…` → orders + success/failure dialog. |
| Affects web? | **No.** Web still uses `https://app.bilenia.se/auth` / `/orders` with cookies. Custom scheme only when `nativeClient` / native ticket flow. |
| Change Idura for login/register? | **No** — Idura allowlist stays API callbacks. |
| Change Idura for **signing**? | **Maybe.** Native signing sets `signatoryRedirectUri` to `https://<api>/api/v1/listings/contracts/sign-bankid/return?native=1`. If Idura has a strict redirect allowlist, add that HTTPS URL (not the custom scheme). Web signing still uses `IDURA_SIGNATURES_REDIRECT_URI` / `FRONTEND_URL/orders`. |

## Flows

### Login / register (native)

1. `Browser.open(continueUrl)`
2. Idura → API callback → `nativeCode`
3. `302 Location: se.bilenia.app://auth?bankid=success&nativeCode=…` (or `bankidError=…`)
4. App opens → exchange / show error

### Contract signing (native)

1. `native-start` → `Browser.open(continueUrl)`
2. Continue sets cookie → `/sign-bankid?nativeClient=1`
3. Create signature order with Idura redirect = **API return** (`…/sign-bankid/return?native=1`)
4. User signs in Idura
5. Idura → API return → `302 se.bilenia.app://orders?contractSignatureStatus=success|error&…`
6. App opens Orders → existing success/failure dialogs

## Env

```
NATIVE_APP_URL_SCHEME=se.bilenia.app
FRONTEND_URL=https://app.bilenia.se
BACKEND_PUBLIC_URL=https://api.bilenia.se/api/v1
# Web signing (unchanged):
# IDURA_SIGNATURES_REDIRECT_URI=https://app.bilenia.se/orders
```

## Idura checklist (signing only)

Add to allowed signatory redirect URIs if required:

`https://api.bilenia.se/api/v1/listings/contracts/sign-bankid/return`

(Exact host = your `BACKEND_PUBLIC_URL`.)

## Rebuild

1. Deploy backend  
2. Deploy frontend (deep-link parse)  
3. Rebuild native (AndroidManifest + iOS Info.plist schemes)  
4. Test login + contract sign on device  

## Verify scheme

```bash
adb shell am start -a android.intent.action.VIEW -d "se.bilenia.app://auth?bankid=success"
adb shell am start -a android.intent.action.VIEW -d "se.bilenia.app://orders?contractSignatureStatus=success"
```
