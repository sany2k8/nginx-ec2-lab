#!/bin/bash
# Lab 1 — Serve a Static Website
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Lab 1: Serve a Static Website ==="

echo "[1/3] Copying index.html to /var/www/html/..."
sudo cp "$PROJECT_DIR/html/index.html" /var/www/html/index.html

echo "[2/3] Writing nginx config..."
sudo cp "$PROJECT_DIR/nginx/default" /etc/nginx/sites-available/default

echo "[3/3] Testing and reloading nginx..."
sudo nginx -t
sudo systemctl reload nginx

echo ""
echo "✅ Lab 1 complete! Visit http://YOUR_PUBLIC_IP/ to see the welcome page."
