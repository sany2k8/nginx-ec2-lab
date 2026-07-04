#!/bin/bash
# Lab 0 — Base Setup (run this once on a fresh EC2 instance)
set -e

echo "=== Lab 0: Base Setup ==="

echo "[1/4] Updating packages..."
sudo apt update

echo "[2/4] Installing nginx, nodejs, npm, apache2-utils, curl..."
sudo apt install -y nginx nodejs npm apache2-utils curl

echo "[3/4] Enabling and starting Nginx..."
sudo systemctl enable nginx
sudo systemctl start nginx
sudo systemctl status nginx --no-pager

echo "[4/4] Creating folder structure..."
sudo mkdir -p /var/www/html/{images,static,admin,internal}
sudo mkdir -p /var/www/media/uploads
sudo mkdir -p /opt/node-app /opt/node-app2
sudo chown -R "$USER":"$USER" /opt/node-app /opt/node-app2

echo ""
echo "✅ Lab 0 complete! Base setup is ready."
