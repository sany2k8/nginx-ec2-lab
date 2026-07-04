#!/bin/bash
# Lab 5 — Static + Reverse Proxy Together (verification only)
# This lab is about confirming Labs 1–4 coexist — no new config needed.
set -e

echo "=== Lab 5: Verify Static + Reverse Proxy Together ==="
echo ""
echo "This lab verifies that Labs 1–4 all work from the same server block."
echo "The nginx config already has all the location blocks in place."
echo ""

# Get public IP
PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || echo "YOUR_PUBLIC_IP")

echo "Running quick checks against localhost..."
echo ""

echo "--- Homepage ---"
curl -s -o /dev/null -w "  HTTP %{http_code}  " http://localhost/ && echo "✓" || echo "✗"

echo "--- Static CSS ---"
curl -s -o /dev/null -w "  HTTP %{http_code}  " http://localhost/static/style.css && echo "✓" || echo "✗"

echo "--- Images directory ---"
curl -s -o /dev/null -w "  HTTP %{http_code}  " http://localhost/images/ && echo "✓" || echo "✗"

echo "--- API (needs node app running) ---"
curl -s -o /dev/null -w "  HTTP %{http_code}  " http://localhost/api/ && echo "✓" || echo "✗ (is node app running?)"

echo ""
echo "✅ Lab 5 verification complete!"
echo "   Also test from your browser: http://$PUBLIC_IP/"
