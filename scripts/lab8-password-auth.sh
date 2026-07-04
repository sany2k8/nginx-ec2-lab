#!/bin/bash
# Lab 8 — Password Protection
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Lab 8: Password Protection ==="

echo "[1/4] Creating htpasswd file (you'll be prompted for a password)..."
sudo htpasswd -c /etc/nginx/.htpasswd admin

echo "[2/4] Copying admin page..."
sudo mkdir -p /var/www/html/admin
sudo cp "$PROJECT_DIR/html/admin/index.html" /var/www/html/admin/index.html

echo "[3/4] Testing and reloading nginx..."
sudo nginx -t
sudo systemctl reload nginx

echo "[4/4] Done!"
echo ""
echo "✅ Lab 8 complete!"
echo "   Test: http://YOUR_PUBLIC_IP/admin/ → browser prompts for username/password."
echo "   Username: admin, Password: whatever you just set."
