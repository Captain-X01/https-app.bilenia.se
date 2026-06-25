# Frontend-branches och shell-byggen

## Två repos

| Repo | Roll |
|------|------|
| `bilenia-dealer-panel` | React-app, affärslogik, native UI-anpassningar |
| `https-app.bilenia.se` | Capacitor-skalet, bygger in frontend |

Shell-repot **klonar** frontend vid varje `fetch:frontend` — det är inte submodule.

## Branches i frontend

| Branch | Användning |
|--------|------------|
| `epic/mobile_app` | Pågående native-app-arbete |
| `main_proxy` | Prod-linje för webb (och mål för native efter merge) |

## Rekommenderat flöde inför release

1. **Merge** `epic/mobile_app` → `main_proxy` i `bilenia-dealer-panel` (PR, test på webb).
2. Sätt i shell `.env.production`:
   ```bash
   FRONTEND_REF=main_proxy
   ```
3. Bygg store-version från shell:
   ```bash
   FRONTEND_REF=main_proxy npm run fetch:frontend
   NATIVE_BUILD_PROFILE=production bash scripts/build-web.sh
   NATIVE_BUILD_PROFILE=production npx cap sync android
   NATIVE_BUILD_PROFILE=production npx cap sync ios
   ```

## Under aktiv native-utveckling

```bash
FRONTEND_REF=epic/mobile_app npm run fetch:frontend
```

Pusha till `epic/mobile_app`, fetcha om i shell — **samma keystore och samma shell-repo**, bara ny web-build i `www/`.

## Behöver vi merga innan iOS-sync?

**Tekniskt nej** — iOS och Android får samma `www/` oavsett branch. **Organisatoriskt ja** för första store-release: merge till `main_proxy` så prod-byggen alltid följer samma linje som webben.

## Framtida uppdateringar

1. Utveckla i `bilenia-dealer-panel` (feature branch → `main_proxy`).
2. Bump `versionCode` / `versionName` (Android) och `MARKETING_VERSION` (iOS).
3. `fetch` + prod build + sync + signera + ladda upp.

Frontend-ändringar kräver **inte** ny keystore — bara ny web-build och ny store-version.
