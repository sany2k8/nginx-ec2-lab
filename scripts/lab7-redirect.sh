#!/bin/bash
# Lab 7 — Redirect (config-only, already in nginx/default)
set -e

echo "=== Lab 7: Redirect ==="

echo "[1/2] Testing and reloading nginx..."
sudo nginx -t
sudo systemctl reload nginx

echo "[2/2] Verifying redirect..."
echo ""
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/google)
echo "  GET /google → HTTP $HTTP_CODE (expect 301)"

echo ""
echo "✅ Lab 7 complete!"
echo "   Test: http://YOUR_PUBLIC_IP/google → redirects to Google."
