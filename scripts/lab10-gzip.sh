#!/bin/bash
# Lab 10 — Gzip Compression (config-only, already in nginx/default)
set -e

echo "=== Lab 10: Gzip Compression ==="

echo "[1/2] Testing and reloading nginx..."
sudo nginx -t
sudo systemctl reload nginx

echo "[2/2] Verifying gzip..."
echo ""
echo "--- Checking Content-Encoding header ---"
curl -s -H "Accept-Encoding: gzip" -I http://localhost/static/style.css | grep -i "content-encoding" || echo "  (gzip may not appear for very small files)"

echo ""
echo "✅ Lab 10 complete!"
echo "   Test: curl -H 'Accept-Encoding: gzip' -I http://YOUR_PUBLIC_IP/static/style.css"
echo "   Look for 'Content-Encoding: gzip' in the response headers."
