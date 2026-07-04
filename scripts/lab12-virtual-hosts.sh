#!/bin/bash
# Lab 12 — Simulate Multiple Domains (Virtual Hosting)
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Lab 12: Virtual Hosting (Multiple Domains) ==="

echo "[1/5] Creating site directories..."
sudo mkdir -p /var/www/site1 /var/www/site2

echo "[2/5] Copying site content..."
sudo cp "$PROJECT_DIR/site1/index.html" /var/www/site1/index.html
sudo cp "$PROJECT_DIR/site2/index.html" /var/www/site2/index.html

echo "[3/5] Installing multisite nginx config..."
sudo cp "$PROJECT_DIR/nginx/multisite" /etc/nginx/sites-available/multisite
sudo ln -sf /etc/nginx/sites-available/multisite /etc/nginx/sites-enabled/multisite

echo "[4/5] Testing and reloading nginx..."
sudo nginx -t
sudo systemctl reload nginx

PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || echo "YOUR_PUBLIC_IP")

echo "[5/5] Done!"
echo ""
echo "✅ Lab 12 complete!"
echo ""
echo "Option A — Add these lines to your laptop's /etc/hosts file:"
echo "  $PUBLIC_IP   site1.local"
echo "  $PUBLIC_IP   site2.local"
echo "Then visit http://site1.local/ and http://site2.local/"
echo ""
echo "Option B — Test with curl (no hosts file edit needed):"
echo "  curl -H 'Host: site1.local' http://$PUBLIC_IP/"
echo "  curl -H 'Host: site2.local' http://$PUBLIC_IP/"
