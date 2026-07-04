#!/bin/bash
# Lab 2 — Static CSS and JavaScript
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Lab 2: Static CSS and JavaScript ==="

echo "[1/3] Copying static assets..."
sudo mkdir -p /var/www/html/static
sudo cp "$PROJECT_DIR/html/static/style.css" /var/www/html/static/style.css
sudo cp "$PROJECT_DIR/html/static/app.js" /var/www/html/static/app.js

echo "[2/3] Updating index.html (already includes CSS/JS references)..."
sudo cp "$PROJECT_DIR/html/index.html" /var/www/html/index.html

echo "[3/3] Testing and reloading nginx..."
sudo nginx -t
sudo systemctl reload nginx

echo ""
echo "✅ Lab 2 complete! Check DevTools → Network for style.css and app.js loading."
