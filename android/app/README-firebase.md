# Firebase Android config

Gradle uses **only** `google-services.json` in this folder.

| File | Purpose |
|------|---------|
| `google-services.json` | Active config for the current build (prod or test). |
| `google-services.test.json` | Backup of the **test** Firebase Android app. Not read by Gradle. |

Swap manually before building — see [docs/building.md](../../docs/building.md#firebase--push-google-servicesjson).

Package name must stay `se.bilenia.app` (matches Play Console / `applicationId`).
