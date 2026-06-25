/**
 * Generates Android/iOS launcher icons, splash images, and Play Store icon.
 */
const fs = require("fs");
const path = require("path");
const sharp = require("sharp");

const ROOT = path.join(__dirname, "..");
const BRAND_BG = "#000000";
const BRAND_TEXT = "#ffffff";
const ICON_BG = "#ffffff";
const BRAND_FONT =
  "Inter, Helvetica Neue, Helvetica, Arial, sans-serif";

const ANDROID_MIPMAP = {
  mdpi: 48,
  hdpi: 72,
  xhdpi: 96,
  xxhdpi: 144,
  xxxhdpi: 192,
};

const ANDROID_SPLASH = {
  "drawable-port-mdpi": { w: 320, h: 480 },
  "drawable-port-hdpi": { w: 480, h: 800 },
  "drawable-port-xhdpi": { w: 720, h: 1280 },
  "drawable-port-xxhdpi": { w: 1080, h: 1920 },
  "drawable-port-xxxhdpi": { w: 1440, h: 2560 },
  "drawable-land-mdpi": { w: 480, h: 320 },
  "drawable-land-hdpi": { w: 800, h: 480 },
  "drawable-land-xhdpi": { w: 1280, h: 720 },
  "drawable-land-xxhdpi": { w: 1920, h: 1080 },
  "drawable-land-xxxhdpi": { w: 2560, h: 1440 },
};

/** Full-screen native fallback splash (web overlay does the animation). */
function splashSvg(width, height) {
  const fontSize = Math.round(Math.min(width, height) * 0.08);
  const letterSpacing = Math.round(fontSize * 0.1);
  return Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}">
  <rect width="100%" height="100%" fill="${BRAND_BG}"/>
  <text x="50%" y="50%" dominant-baseline="middle" text-anchor="middle"
    font-family="${BRAND_FONT}" font-weight="700"
    font-size="${fontSize}" fill="${BRAND_TEXT}" letter-spacing="${letterSpacing}">BILENIA</text>
</svg>`);
}

/**
 * Launcher icon: BILENIA scaled into adaptive-icon safe zone (~66% circle).
 */
function launcherIconSvg(size, { transparentBg = false } = {}) {
  const pad = size * 0.18;
  const inner = size - pad * 2;
  const fontSize = Math.round(inner * 0.2);
  const letterSpacing = Math.round(fontSize * 0.08);
  const bg = transparentBg
    ? ""
    : `<rect width="100%" height="100%" fill="${ICON_BG}"/>`;
  return Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="${size}" height="${size}" viewBox="0 0 ${size} ${size}">
  ${bg}
  <text x="50%" y="52%" dominant-baseline="middle" text-anchor="middle"
    font-family="${BRAND_FONT}" font-weight="700"
    font-size="${fontSize}" fill="#000000" letter-spacing="${letterSpacing}">BILENIA</text>
</svg>`);
}

/** Google Play Store listing icon — 512×512, full canvas wordmark. */
function playStoreIconSvg(size = 512) {
  const fontSize = Math.round(size * 0.145);
  const letterSpacing = Math.round(fontSize * 0.09);
  return Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="${size}" height="${size}" viewBox="0 0 ${size} ${size}">
  <rect width="100%" height="100%" fill="${ICON_BG}"/>
  <text x="50%" y="51%" dominant-baseline="middle" text-anchor="middle"
    font-family="${BRAND_FONT}" font-weight="700"
    font-size="${fontSize}" fill="#000000" letter-spacing="${letterSpacing}">BILENIA</text>
</svg>`);
}

async function ensureDir(dir) {  await fs.promises.mkdir(dir, { recursive: true });
}

async function generateIcons() {
  const legacySplashPng = path.join(
    ROOT,
    "android",
    "app",
    "src",
    "main",
    "res",
    "drawable",
    "splash.png"
  );
  if (fs.existsSync(legacySplashPng)) {
    await fs.promises.unlink(legacySplashPng);
  }

  const resourcesDir = path.join(ROOT, "resources");
  await ensureDir(resourcesDir);

  await sharp(launcherIconSvg(1024)).png().toFile(path.join(resourcesDir, "icon.png"));
  await sharp(playStoreIconSvg(512))
    .png()
    .toFile(path.join(resourcesDir, "play-store-icon-512.png"));

  await sharp(splashSvg(2732, 2732)).png().toFile(path.join(resourcesDir, "splash.png"));

  for (const [folder, size] of Object.entries(ANDROID_MIPMAP)) {
    const dir = path.join(ROOT, "android", "app", "src", "main", "res", `mipmap-${folder}`);
    await ensureDir(dir);

    const legacy = await sharp(launcherIconSvg(size)).png().toBuffer();
    await fs.promises.writeFile(path.join(dir, "ic_launcher.png"), legacy);
    await fs.promises.writeFile(path.join(dir, "ic_launcher_round.png"), legacy);

    const foreground = await sharp(launcherIconSvg(size, { transparentBg: true }))
      .png()
      .toBuffer();
    await fs.promises.writeFile(path.join(dir, "ic_launcher_foreground.png"), foreground);
  }

  for (const [folder, { w, h }] of Object.entries(ANDROID_SPLASH)) {
    const dir = path.join(ROOT, "android", "app", "src", "main", "res", folder);
    await ensureDir(dir);
    await sharp(splashSvg(w, h)).png().toFile(path.join(dir, "splash.png"));
  }

  const iosIcon = path.join(ROOT, "ios", "App", "App", "Assets.xcassets", "AppIcon.appiconset", "AppIcon-512@2x.png");
  await sharp(launcherIconSvg(1024)).png().toFile(iosIcon);

  const iosSplashDir = path.join(ROOT, "ios", "App", "App", "Assets.xcassets", "Splash.imageset");
  await ensureDir(iosSplashDir);
  await sharp(splashSvg(2732, 2732)).png().toFile(path.join(iosSplashDir, "splash-2732x2732.png"));
  await fs.promises.writeFile(
    path.join(iosSplashDir, "Contents.json"),
    JSON.stringify(
      {
        images: [{ idiom: "universal", filename: "splash-2732x2732.png", scale: "1x" }],
        info: { author: "xcode", version: 1 },
      },
      null,
      2
    )
  );

  console.log("Native icons and splash images generated.");
  console.log(`  Play Store icon: ${path.join(resourcesDir, "play-store-icon-512.png")}`);
}

generateIcons().catch((err) => {
  console.error(err);
  process.exit(1);
});
