#!/bin/bash
# Lab 11 — Reverse Proxy to Multiple Applications
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Lab 11: Reverse Proxy to Multiple Applications ==="

echo "[1/4] Copying node-app2 files to /opt/node-app2/..."
cp "$PROJECT_DIR/node-app2/app.js" /opt/node-app2/app.js
cp "$PROJECT_DIR/node-app2/package.json" /opt/node-app2/package.json

echo "[2/4] Installing npm dependencies..."
cd /opt/node-app2
npm install

echo "[3/4] Testing and reloading nginx..."
sudo nginx -t
sudo systemctl reload nginx

echo "[4/4] Starting the second Node app..."
echo "  Run in a separate terminal:  node /opt/node-app2/app.js"
echo "  Or use pm2:                  pm2 start /opt/node-app2/app.js --name app2"

echo ""
echo "✅ Lab 11 complete!"
echo "   Test: http://YOUR_PUBLIC_IP/api/       → App 1 (port 3000)"
echo "   Test: http://YOUR_PUBLIC_IP/app2/      → App 2 (port 4000)"
echo "   Test: http://YOUR_PUBLIC_IP/app2/status → App 2 JSON"
