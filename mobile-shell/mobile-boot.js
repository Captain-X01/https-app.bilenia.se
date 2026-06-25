/**
 * Native-only: splash (once per session), hash-based cold-start entry, no reload loops.
 * Uses #/routes — matches createHashRouter in capacitor build.
 */
const AUTH_PATH = "/auth";
const DASHBOARD_PATH = "/dashboard";
const STORAGE_KEY = "bilenia_native_auth";
const PUBLIC_ENTRY_PATHS = new Set(["/", "/index.html", ""]);
const SPLASH_SESSION_KEY = "bilenia_splash_shown";
const NATIVE_SESSION_KEY = "bilenia_native_app_session";
/** Total splash time (+50% vs previous 2400ms) */
const MIN_SPLASH_MS = 3600;
const LETTER_STAGGER_S = 0.16;

const ROUTABLE_PREFIXES = [
  "/auth",
  "/dashboard",
  "/verify-email",
  "/accept-terms",
  "/reset-password",
  "/how-it-works",
  "/privacy",
  "/contact",
  "/sell-car",
  "/buy-car",
  "/auctions",
  "/orders",
  "/settings",
  "/support",
  "/favorites",
  "/notifications",
  "/admin",
  "/car-test",
  "/list-or-value-car",
  "/dealer-portal",
];

function isNativeApp() {
  const cap = window.Capacitor;
  return Boolean(cap?.isNativePlatform?.());
}

function hasStoredTokens() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return false;
    const parsed = JSON.parse(raw);
    return Boolean(parsed?.accessToken && parsed?.refreshToken);
  } catch {
    return false;
  }
}

function getColdStartPath() {
  return hasStoredTokens() ? DASHBOARD_PATH : AUTH_PATH;
}

function getHashPath() {
  const raw = window.location.hash.replace(/^#/, "");
  return raw.split("?")[0] || "";
}

function isRoutableHash(hashPath) {
  if (!hashPath || hashPath === "/") return false;
  return ROUTABLE_PREFIXES.some(
    (p) => hashPath === p || hashPath.startsWith(p + "/")
  );
}

function setHashRoute(target) {
  window.location.replace("/#" + target);
}

/** Set initial hash route; keep pathname at / so Capacitor always serves index.html. */
function ensureNativeEntry() {
  const hadSession = sessionStorage.getItem(NATIVE_SESSION_KEY);
  const tokensPresent = hasStoredTokens();

  if (tokensPresent) {
    console.info("[Bilenia boot] refresh token found in localStorage");
  } else {
    console.info("[Bilenia boot] no refresh token in localStorage");
  }

  if (tokensPresent) {
    sessionStorage.setItem(NATIVE_SESSION_KEY, "1");
    const hashPath = getHashPath();
    if (
      !hadSession ||
      hashPath === AUTH_PATH ||
      !hashPath ||
      hashPath === "/"
    ) {
      if (hashPath !== DASHBOARD_PATH) {
        setHashRoute(DASHBOARD_PATH);
      }
    }
    return;
  }

  sessionStorage.removeItem(NATIVE_SESSION_KEY);

  const hashPath = getHashPath();
  if (isRoutableHash(hashPath)) return;

  const pathname = window.location.pathname.replace(/\/+$/, "") || "/";
  let target = getColdStartPath();

  if (pathname === DASHBOARD_PATH || pathname === AUTH_PATH) {
    target = pathname;
  } else if (!PUBLIC_ENTRY_PATHS.has(pathname)) {
    return;
  }

  setHashRoute(target);
}

function shouldShowSplash() {
  if (hasStoredTokens()) return false;
  try {
    if (sessionStorage.getItem(SPLASH_SESSION_KEY)) return false;
    sessionStorage.setItem(SPLASH_SESSION_KEY, "1");
  } catch {
    /* private mode / unavailable */
  }
  return true;
}

function hideNativeSplash() {
  try {
    const plugin = window.Capacitor?.Plugins?.SplashScreen;
    if (plugin?.hide) plugin.hide();
  } catch {
    /* optional */
  }
}

function lockSplashViewport() {
  document.documentElement.classList.add("bilenia-splash-active");
}

function unlockSplashViewport() {
  document.documentElement.classList.remove("bilenia-splash-active");
}

function mountSplash() {
  document.documentElement.classList.add("bilenia-native-app");
  lockSplashViewport();

  const root = document.createElement("div");
  root.id = "bilenia-mobile-splash";

  const wordEl = document.createElement("div");
  wordEl.className = "bilenia-splash-word";
  wordEl.setAttribute("aria-label", "BILENIA");

  "BILENIA".split("").forEach((ch, i) => {
    const span = document.createElement("span");
    let extra = "";
    if (i % 2 === 1) extra = " flicker";
    if (i === 6) extra = " glow";
    span.className = "char" + extra;
    span.textContent = ch;
    span.style.animationDelay = `${i * LETTER_STAGGER_S}s`;
    wordEl.appendChild(span);
  });

  root.appendChild(wordEl);
  document.body.appendChild(root);
  return root;
}

function clearSplashBackgroundOverrides() {
  document.documentElement.style.removeProperty("background");
  if (document.body) document.body.style.removeProperty("background");
}

function hideWebSplash(overlay) {
  overlay.classList.add("is-hidden");
  setTimeout(() => {
    overlay.remove();
    unlockSplashViewport();
    clearSplashBackgroundOverrides();
  }, 500);
}

function startNativeBoot() {
  document.documentElement.classList.add("bilenia-native-app");
  ensureNativeEntry();

  const showSplash = shouldShowSplash();
  const started = Date.now();

  const start = () => {
    hideNativeSplash();

    if (!showSplash) return;

    const overlay = mountSplash();
    const wait = Math.max(0, MIN_SPLASH_MS - (Date.now() - started));
    setTimeout(() => hideWebSplash(overlay), wait);
  };

  if (document.body) start();
  else document.addEventListener("DOMContentLoaded", start, { once: true });
}

/** Capacitor bridge may not exist when this script first runs in <head>. */
function runWhenCapacitorReady() {
  if (isNativeApp()) {
    startNativeBoot();
    return;
  }

  const deadline = Date.now() + 4000;
  const poll = () => {
    if (isNativeApp()) {
      startNativeBoot();
      return;
    }
    if (Date.now() < deadline) {
      requestAnimationFrame(poll);
      return;
    }
    /* WebView without Capacitor flag — still try hash entry */
    startNativeBoot();
  };
  poll();
}

runWhenCapacitorReady();
