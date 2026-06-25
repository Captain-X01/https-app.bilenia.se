#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WWW="${ROOT}/www"
INDEX="${WWW}/index.html"
SHELL_SRC="${ROOT}/mobile-shell"
SHELL_DST="${WWW}/mobile-shell"

if [ ! -f "$INDEX" ]; then
  echo "Saknar www/index.html — kör build:web först." >&2
  exit 1
fi

rm -rf "$SHELL_DST"
mkdir -p "$SHELL_DST"
cp "${SHELL_SRC}/mobile-shell.css" "${SHELL_DST}/mobile-shell.css"
cp "${SHELL_SRC}/mobile-boot.js" "${SHELL_DST}/mobile-boot.js"

# Strip any previous mobile-shell injections
export ROOT
node <<'NODE'
const fs = require("fs");
const path = require("path");
const root = process.env.ROOT;
if (!root) {
  console.error("ROOT env missing");
  process.exit(1);
}
const indexPath = path.join(root, "www", "index.html");
let html = fs.readFileSync(indexPath, "utf8");

html = html
  .replace(/\s*<!-- bilenia-mobile-shell -->[\s\S]*?<script src="\.\/mobile-shell\/mobile-boot\.js"><\/script>\s*/g, "\n")
  .replace(/\s*<link rel="stylesheet" href="\.\/mobile-shell\/mobile-shell\.css" \/>\s*/g, "\n")
  .replace(/\s*<script src="\.\/mobile-shell\/mobile-boot\.js"><\/script>\s*/g, "\n")
  .replace(/\s*<script src="\.\/mobile-shell\/mobile-back\.js"><\/script>\s*/g, "\n");

const injection = `<!-- bilenia-mobile-shell -->
  <link rel="stylesheet" href="./mobile-shell/mobile-shell.css" />
  <script src="./mobile-shell/mobile-boot.js"></script>
  `;

if (!html.includes("mobile-shell/mobile-boot.js")) {
  html = html.replace(
    /<script type="module"/,
    injection + '<script type="module"'
  );
}

fs.writeFileSync(indexPath, html);
console.log("Patched www/index.html (mobile-boot before React bundle).");
NODE

echo "Patched www for native app."
