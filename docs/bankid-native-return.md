# Native BankID return (custom URL scheme + iOS HTTPS bridge)

## Short answers

| Question | Answer |
|----------|--------|
| iOS bundle is `se.bilenia.auctions` — does that matter? | **No for opening the app.** Bundle ID ≠ URL scheme. We register schemes `se.bilenia.app` **and** `se.bilenia.auctions` on iOS. |
| Android vs iOS return | **Android:** `302` → `se.bilenia.app://auth?…` (Custom Tabs). **iOS:** `302` → `https://app.bilenia.se/auth?…&nativeReturn=1` then Auth auto-opens `se.bilenia.app://…` (same-device BankID returns via Safari). |
| After BankID, does the app show auth again? | **Login/register:** yes — success *or* error → native `#/auth` (dialogs/toasts). **Signing:** → `se.bilenia.app://orders?…` → orders + success/failure dialog. |
| Affects web? | **No.** Web still uses `https://FRONTEND_URL/auth` *without* `nativeReturn=1`. |
| Change Idura for login/register? | **No** — Idura allowlist stays API callbacks. |
| Change Idura for **signing**? | **Maybe.** Native signing sets `signatoryRedirectUri` to `https://<api>/api/v1/listings/contracts/sign-bankid/return?native=1`. If Idura has a strict redirect allowlist, add that HTTPS URL (not the custom scheme). Web signing still uses `IDURA_SIGNATURES_REDIRECT_URI` / `FRONTEND_URL/orders`. |

## Why iOS HTTPS bridge?

Same-device BankID on iPhone leaves SFSafariViewController and often resumes in **Safari**. A custom-scheme `302` from the in-app browser never runs; session errors used to dump users on plain `/auth` with a misleading error. iOS native sessions send `nativePlatform=ios` so API callbacks redirect to the HTTPS bridge (`nativeReturn=1` + `nativeCode` / errors). Auth.tsx auto-fires the custom scheme and shows “Öppna appen”.

## Flows

### Login / register (native Android)

1. `Browser.open(continueUrl)`
2. Idura → API callback → `nativeCode`
3. `302 Location: se.bilenia.app://auth?bankid=success&nativeCode=…` (or `bankidError=…`)
4. App opens → exchange / show error

### Login / register (native iOS)

1. Same as Android through Idura
2. API callback → `302 https://app.bilenia.se/auth?bankid=success&nativeCode=…&nativeReturn=1`
3. Safari loads Auth → auto `se.bilenia.app://auth?…` (+ dialog fallback)
4. App opens → exchange / show error

### Contract signing (native)

Unchanged for now: still custom-scheme return to `/orders`. Revisit if same-device signing fails on iOS the same way.

## Env

```
NATIVE_APP_URL_SCHEME=se.bilenia.app
FRONTEND_URL=https://app.bilenia.se
BACKEND_PUBLIC_URL=https://api.bilenia.se/api/v1
```

## Rebuild / deploy

1. Deploy **backend** (platform-aware redirects)
2. Deploy **frontend** (`nativePlatform` on start + Auth auto deep-link)
3. Rebuild native iOS with the new web assets
4. Test **same-device** and **other-device** login/register on iPhone; smoke Android + web
