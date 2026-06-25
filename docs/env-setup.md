# Miljövariabler (.env)

## Principer

- **Inga hemligheter** i mobil-shell `.env` — endast `VITE_*` som bakas in i JS-bundlen (synliga i APK/IPA).
- **Backend** `.env` (databas, JWT, Didit) är en helt annan fil på servern.
- **Committa** `*.example`-mallar. **Ignorera** faktiska `.env`-filer.

## Filer

| Fil | Committa? | Syfte |
|-----|-----------|--------|
| `.env.local-dev.example` | Ja | Mall för lokal dev-build |
| `.env.production.example` | Ja | Mall för prod store-build |
| `.env` / `.env.local-dev` | Nej | Din lokala dev-konfig |
| `.env.production` | Nej* | Prod `VITE_*` vid build |

\* Värdena är ändå publika i byggd app; vissa team committar `.env.production` för enkel CI. Vi ignorerar den som standard.

## Variabler

| Variabel | Beskrivning |
|----------|-------------|
| `FRONTEND_GIT_URL` | Git-URL till bilenia-dealer-panel |
| `FRONTEND_REF` | Branch/tag/commit att bygga (t.ex. `main_proxy`, `epic/mobile_app`) |
| `FRONTEND_OUT_DIR` | Valfritt, default `dist` |
| `VITE_API_BASE_URL` | REST API |
| `VITE_API_BASE_URL_SOCKET_IO` | Socket.IO |
| `VITE_WEB_APP_URL` | Webapp-URL (länkar, open-in-app) |
| `VITE_ENV` | `development` eller `production` |

## FRONTEND_REF — vilken branch?

Se [frontend-branches.md](frontend-branches.md).

Kort:

- **Utveckling:** `epic/mobile_app`
- **Store-releases:** `main_proxy` (efter att native-arbetet mergats dit)

## Setup ny utvecklare

```bash
cp .env.local-dev.example .env.local-dev
npm run print:api-host
# Redigera VITE_API_BASE_URL i .env.local-dev
cp .env.local-dev .env

cp .env.production.example .env.production
# Redigera vid behov för prod-byggen
```
