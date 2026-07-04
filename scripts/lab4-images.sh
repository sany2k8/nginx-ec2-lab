#!/bin/bash
# Lab 4 — Serve Images
set -e

echo "=== Lab 4: Serve Images ==="

echo "[1/3] Downloading sample images..."
cd /tmp
wget -q https://picsum.photos/600 -O cat.jpg
wget -q https://picsum.photos/700 -O dog.jpg
sudo mv cat.jpg dog.jpg /var/www/html/images/

echo "[2/3] Testing and reloading nginx..."
sudo nginx -t
sudo systemctl reload nginx

echo "[3/3] Done!"
echo ""
echo "✅ Lab 4 complete!"
echo "   Test: http://YOUR_PUBLIC_IP/images/cat.jpg"
echo "   Test: http://YOUR_PUBLIC_IP/images/ (directory listing)"
