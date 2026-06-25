#!/usr/bin/env node
const os = require("os");

const nets = os.networkInterfaces();
const ips = [];
for (const name of Object.keys(nets)) {
  for (const net of nets[name] || []) {
    if (net.family === "IPv4" && !net.internal) {
      ips.push({ name, address: net.address });
    }
  }
}

console.log("\nBilenia mobil dev — sätt i https-app.bilenia.se/.env:\n");
if (ips.length) {
  for (const { name, address } of ips) {
    console.log(`  # ${name}`);
    console.log(`  VITE_API_BASE_URL=http://${address}:5000/api/v1`);
    console.log(`  VITE_API_BASE_URL_SOCKET_IO=http://${address}:5000\n`);
  }
} else {
  console.log("  (ingen LAN-IP hittad)\n");
}
console.log("Android-emulator:");
console.log("  VITE_API_BASE_URL=http://10.0.2.2:5000/api/v1");
console.log("  VITE_API_BASE_URL_SOCKET_IO=http://10.0.2.2:5000\n");
console.log("USB + adb reverse tcp:5000 tcp:5000:");
console.log("  VITE_API_BASE_URL=http://localhost:5000/api/v1\n");
console.log("Backend måste lyssna på 0.0.0.0:5000 (inte bara 127.0.0.1).");
console.log("Öppna Windows-brandväggen för port 5000 om telefonen inte når PC:n.\n");
