/**
 * Capacitor `cap sync ios` on Windows writes backslashes into Package.swift paths.
 * Swift Package Manager on macOS requires forward slashes → "missing package product CapacitorApp".
 */
const fs = require('fs');
const path = require('path');

const root = path.join(__dirname, '..');
const packageSwift = path.join(root, 'ios', 'App', 'CapApp-SPM', 'Package.swift');

if (!fs.existsSync(packageSwift)) {
  process.exit(0);
}

const original = fs.readFileSync(packageSwift, 'utf8');
const fixed = original.replace(/path: "([^"]+)"/g, (_, p) =>
  `path: "${p.replace(/\\/g, '/')}"`,
);

if (fixed !== original) {
  fs.writeFileSync(packageSwift, fixed);
  console.log('Fixed Windows-style paths in ios/App/CapApp-SPM/Package.swift');
}
