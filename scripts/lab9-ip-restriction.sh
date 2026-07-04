#!/bin/bash
# Lab 9 — IP Restriction
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Lab 9: IP Restriction ==="

echo "[1/4] Detecting your public IP..."
MY_IP=$(curl -s ifconfig.me)
echo "  Your IP: $MY_IP"

echo "[2/4] Copying internal page..."
sudo mkdir -p /var/www/html/internal
sudo cp "$PROJECT_DIR/html/internal/index.html" /var/www/html/internal/index.html

echo "[3/4] Updating nginx config with your IP..."
# Replace the placeholder IP in the nginx config
sudo sed -i "s|allow 203.0.113.45/32;|allow ${MY_IP}/32;|g" /etc/nginx/sites-available/default

echo "[4/4] Testing and reloading nginx..."
sudo nginx -t
sudo systemctl reload nginx

echo ""
echo "✅ Lab 9 complete!"
echo "   Your IP ($MY_IP) is now allowed to access /internal/."
echo "   Test: http://YOUR_PUBLIC_IP/internal/ → works from your machine."
echo "   From any other IP → 403 Forbidden."
