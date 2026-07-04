#!/bin/bash
# Lab 6 — Custom 404 Page
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Lab 6: Custom 404 Page ==="

echo "[1/3] Copying 404.html..."
sudo cp "$PROJECT_DIR/html/404.html" /var/www/html/404.html

echo "[2/3] Testing and reloading nginx..."
sudo nginx -t
sudo systemctl reload nginx

echo "[3/3] Done!"
echo ""
echo "✅ Lab 6 complete!"
echo "   Test: http://YOUR_PUBLIC_IP/does-not-exist → should show your custom 404 page."
