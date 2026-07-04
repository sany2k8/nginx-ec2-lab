#!/bin/bash
# Lab 3 — Reverse Proxy to Node.js
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Lab 3: Reverse Proxy to Node.js ==="

echo "[1/4] Copying node-app files to /opt/node-app/..."
cp "$PROJECT_DIR/node-app/app.js" /opt/node-app/app.js
cp "$PROJECT_DIR/node-app/package.json" /opt/node-app/package.json

echo "[2/4] Installing npm dependencies..."
cd /opt/node-app
npm install

echo "[3/4] Testing and reloading nginx..."
sudo nginx -t
sudo systemctl reload nginx

echo "[4/4] Starting the Node app..."
echo "  Run in a separate terminal:  node /opt/node-app/app.js"
echo "  Or use pm2:                  pm2 start /opt/node-app/app.js --name app1"

echo ""
echo "✅ Lab 3 complete!"
echo "   Test: http://YOUR_PUBLIC_IP/api/"
echo "   Test: http://YOUR_PUBLIC_IP/api/users"
