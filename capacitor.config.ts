import type { CapacitorConfig } from '@capacitor/cli';
import { KeyboardResize } from '@capacitor/keyboard';

/**
 * NATIVE_BUILD_PROFILE=production → store-safe defaults (HTTPS only, no cleartext).
 * Default / development → LAN HTTP backend during local device testing.
 *
 * Set automatically by `npm run build:web:prod` / `build:android:prod`.
 * Dev builds use `build:web:dev` / `build:android:dev` (LAN HTTP, cleartext allowed).
 */
const isProductionBuild =
  process.env.NATIVE_BUILD_PROFILE === 'production' ||
  process.env.VITE_ENV === 'production';

const config: CapacitorConfig = {
  appId: 'se.bilenia.app',
  appName: 'BILENIA',
  webDir: 'www',
  android: {
    allowMixedContent: !isProductionBuild,
  },
  ...(isProductionBuild
    ? {
        server: {
          androidScheme: 'https',
          cleartext: false,
        },
      }
    : {
        // http://localhost WebView + http:// LAN API avoids mixed-content blocks in dev
        server: {
          androidScheme: 'http',
          cleartext: true,
        },
      }),
  plugins: {
    CapacitorHttp: {
      enabled: true,
    },
    SplashScreen: {
      launchAutoHide: false,
      backgroundColor: '#000000',
      showSpinner: false,
      androidScaleType: 'CENTER_CROP',
    },
    StatusBar: {
      overlaysWebView: true,
    },
    Keyboard: {
      resize: KeyboardResize.Body,
      resizeOnFullScreen: true,
    },
  },
};

export default config;
