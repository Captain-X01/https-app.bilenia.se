# Native BankID return (ASWebAuthenticationSession + Custom Tabs)

## Short answers

| Question | Answer |
|----------|--------|
| iOS bundle is `se.bilenia.auctions` — does that matter? | **No for opening the app.** Bundle ID ≠ URL scheme. We register schemes `se.bilenia.app` **and** `se.bilenia.auctions` on iOS. |
| Android vs iOS return | **Both:** API `302` → `se.bilenia.app://auth?…`. Android Custom Tabs / iOS `ASWebAuthenticationSession` capture the scheme. |
| Same-device on iOS | Backend sends `login_hint=appswitch:resumeUrl:https://app.bilenia.se/bankid-return` (iOS native only). BankID opens that universal link → app foregrounds → auth sheet finishes. App ignores `/bankid-return` in deep-link handling. |
| Affects web? | **No.** Web still uses `https://FRONTEND_URL/auth` without nativeCode. |

## Why appswitch:resumeUrl?

Same-device BankID leaves the in-app browser for the BankID app. Without Idura’s app-switch `login_hint`, iOS resumes **Safari** instead of `ASWebAuthenticationSession` → Idura picker loop → eventually Safari with `no_account` / errors.

See: https://docs.idura.app/verify/integrations/swift/ (backend-initialized + BrowserManager)

## Flows

### Login / register (native)

1. iOS: `BileniaBrowser.startAuthSession(continueUrl)` / Android: `Browser.open(continueUrl)`
2. Idura authorize includes `appswitch:resumeUrl` on iOS
3. BankID same-device → BankID app → resume universal link → auth sheet continues
4. Idura → API callback → `nativeCode`
5. `302 Location: se.bilenia.app://auth?bankid=success&nativeCode=…` (or `bankidError=…`)
6. ASWebAuth / Custom Tabs deliver URL → exchange / show error **in the app**

## Universal link checklist

1. `https://app.bilenia.se/.well-known/apple-app-site-association` serves JSON (no redirect) with `AXRBPD8K5N.se.bilenia.auctions` and `/bankid-return*`
2. Verify Apple's CDN picked it up: `https://app-site-association.cdn-apple.com/a/v1/app.bilenia.se`
3. Reinstall the app after AASA changes (iOS caches it at install)

## Env

```
NATIVE_APP_URL_SCHEME=se.bilenia.app
NATIVE_APP_SWITCH_RESUME_URL=https://app.bilenia.se/bankid-return   # optional override
FRONTEND_URL=https://app.bilenia.se
BACKEND_PUBLIC_URL=https://api.bilenia.se/api/v1
IDURA_DOMAIN=bilenia.idura.broker
```

## Rebuild / deploy

1. Deploy **backend** (`nativeBankIdAuthorize` login_hint)
2. Deploy **frontend** (ASWebAuth path already in place)
3. Rebuild + reinstall native iOS
4. Confirm AASA via Apple CDN URL above
5. Test **same-device** login on iPhone; smoke Android + web
