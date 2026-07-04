# Nginx + Node.js on EC2 — 12 Labs (No Domain Required)


This is a comprehensive guide to setting up Nginx as a reverse proxy for Node.js applications on an EC2 instance. It covers 12 labs that demonstrate various Nginx features and configurations. Everywhere you see `YOUR_PUBLIC_IP`, use your EC2 instance's public IPv4 address. Make sure your EC2 **Security Group** allows inbound TCP on port **80** (and later whatever custom ports you use, e.g. 3000/4000) from your IP or `0.0.0.0/0`.

---

## Project Structure

```
nginx-lab/
├── html/                    # Web content (deployed to /var/www/html/)
│   ├── index.html           # Lab 1 & 2 — main page
│   ├── 404.html             # Lab 6 — custom error page
│   ├── static/
│   │   ├── style.css        # Lab 2 — stylesheet
│   │   └── app.js           # Lab 2 — JavaScript
│   ├── images/              # Lab 4 — images (downloaded at runtime)
│   ├── admin/
│   │   └── index.html       # Lab 8 — password-protected page
│   └── internal/
│       └── index.html       # Lab 9 — IP-restricted page
├── media/uploads/           # Lab 0 — upload directory
├── node-app/                # Lab 3 — Express app on port 3000
│   ├── app.js
│   └── package.json
├── node-app2/               # Lab 11 — Express app on port 4000
│   ├── app.js
│   └── package.json
├── nginx/                   # Nginx configuration files
│   ├── default              # Labs 1–11 — main server block
│   └── multisite            # Lab 12 — virtual host config
├── site1/index.html         # Lab 12 — virtual host content
├── site2/index.html         # Lab 12 — virtual host content
├── scripts/                 # One-command bash scripts per lab
│   ├── lab0-setup.sh
│   ├── lab1-static-site.sh
│   ├── lab2-static-assets.sh
│   ├── lab3-reverse-proxy.sh
│   ├── lab4-images.sh
│   ├── lab5-verify-all.sh
│   ├── lab6-custom-404.sh
│   ├── lab7-redirect.sh
│   ├── lab8-password-auth.sh
│   ├── lab9-ip-restriction.sh
│   ├── lab10-gzip.sh
│   ├── lab11-multi-app.sh
│   └── lab12-virtual-hosts.sh
└── READEM.md                # This file
```

---

## Quick Start (Using Scripts)

Instead of running individual commands from each lab, you can use the
pre-built bash scripts. Clone this repo onto your EC2 instance and run them
in order:

```bash
git clone <your-repo-url> nginx-lab
cd nginx-lab

# Run labs sequentially
./scripts/lab0-setup.sh        # Install packages & create directories
./scripts/lab1-static-site.sh  # Deploy static HTML + nginx config
./scripts/lab2-static-assets.sh
./scripts/lab3-reverse-proxy.sh
# ... and so on up to lab12
```

Each script prints ✅ success messages and test URLs when done.

> **Note:** Lab 8 (`lab8-password-auth.sh`) is interactive — it will prompt
> you to set a password. Lab 9 (`lab9-ip-restriction.sh`) auto-detects your
> public IP.

---

## Manual Steps (Detailed Labs)

The sections below explain each lab in detail. If you prefer to understand
what each command does, follow the manual steps. Otherwise, just run the
corresponding script from `scripts/`.

---

## Lab 0 — Base Setup (do this once)

> **Script:** `./scripts/lab0-setup.sh`

```bash
sudo apt update
sudo apt install -y nginx nodejs npm apache2-utils curl

sudo systemctl enable nginx
sudo systemctl start nginx
sudo systemctl status nginx
```

Create the folder structure:

```bash
sudo mkdir -p /var/www/html/{images,static,admin,internal}
sudo mkdir -p /var/www/media/uploads
sudo mkdir -p /opt/node-app /opt/node-app2
sudo chown -R $USER:$USER /opt/node-app /opt/node-app2
```

All lab configs below get added to **one file**:

```bash
sudo nano /etc/nginx/sites-available/default
```

After *every* edit in this guide:

```bash
sudo nginx -t          # must say "syntax is ok" / "test is successful"
sudo systemctl reload nginx
```

---

## Lab 1 — Serve a Static Website

> **Script:** `./scripts/lab1-static-site.sh`

```bash
sudo nano /var/www/html/index.html
```

```html
<!DOCTYPE html>
<html>
<head><title>Nginx Practice</title></head>
<body>
  <h1>Welcome to EC2 + Nginx</h1>
  <p>This page is served by Nginx.</p>
</body>
</html>
```

Base server block:

```nginx
server {
    listen 80 default_server;
    server_name _;

    root /var/www/html;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

Test: `http://YOUR_PUBLIC_IP/` → shows the welcome page.

---

## Lab 2 — Static CSS and JavaScript

> **Script:** `./scripts/lab2-static-assets.sh`

```bash
sudo nano /var/www/html/static/style.css
```
```css
body { background:#f3f3f3; font-family:Arial; }
h1 { color:green; }
button { padding:10px; }
```

```bash
sudo nano /var/www/html/static/app.js
```
```js
function hello(){ alert("Hello from JavaScript!"); }
```

Update `index.html` to reference them:

```html
<link rel="stylesheet" href="/static/style.css">
...
<button onclick="hello()">Click Me</button>
<script src="/static/app.js"></script>
```

Add to the server block:

```nginx
location /static/ {
    alias /var/www/html/static/;
}
```

Test: DevTools → Network shows `style.css` and `app.js` loading; clicking the
button pops an alert.

---

## Lab 3 — Reverse Proxy to Node.js

> **Script:** `./scripts/lab3-reverse-proxy.sh`

```bash
cd /opt/node-app
npm init -y
npm install express
nano app.js
```

```js
const express = require("express");
const app = express();

app.get("/", (req, res) => res.send("Hello from Express behind Nginx"));
app.get("/users", (req, res) => res.json([{id:1,name:"Alice"},{id:2,name:"Bob"}]));

app.listen(3000, () => console.log("App1 running on 3000"));
```

Run it (keep this terminal open, or see the "systemd" note at the bottom):

```bash
node app.js
```

In a second terminal, sanity check locally:

```bash
curl localhost:3000
```

Add to the server block:

```nginx
location /api/ {
    proxy_pass http://127.0.0.1:3000/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

Test: `http://YOUR_PUBLIC_IP/api/` and `http://YOUR_PUBLIC_IP/api/users`.

---

## Lab 4 — Serve Images

> **Script:** `./scripts/lab4-images.sh`

```bash
cd /tmp
wget https://picsum.photos/600 -O cat.jpg
wget https://picsum.photos/700 -O dog.jpg
sudo mv cat.jpg dog.jpg /var/www/html/images/
```

```nginx
location /images/ {
    alias /var/www/html/images/;
    autoindex on;
}
```

Test: `http://YOUR_PUBLIC_IP/images/cat.jpg` and `http://YOUR_PUBLIC_IP/images/`
(directory listing).

---

## Lab 5 — Static + Reverse Proxy Together

> **Script:** `./scripts/lab5-verify-all.sh`

This is just Labs 1–4 living in the **same** server block — nginx routes by
`location` prefix, so static files and the proxied API coexist naturally.
By this point your server block should look like:

```nginx
server {
    listen 80 default_server;
    server_name _;
    root /var/www/html;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    location /static/ {
        alias /var/www/html/static/;
    }

    location /images/ {
        alias /var/www/html/images/;
        autoindex on;
    }

    location /api/ {
        proxy_pass http://127.0.0.1:3000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Test all four: homepage, `/static/style.css`, `/images/`, `/api/users` — all
from one `curl`/browser session, no conflicts.

---

## Lab 6 — Custom 404 Page

> **Script:** `./scripts/lab6-custom-404.sh`

```bash
sudo nano /var/www/html/404.html
```

```html
<!DOCTYPE html>
<html><body><h1>404</h1><p>Page Not Found</p></body></html>
```

```nginx
error_page 404 /404.html;
location = /404.html {
    internal;
}
```

Test: `http://YOUR_PUBLIC_IP/does-not-exist` → your custom page, not nginx's
default.

---

## Lab 7 — Redirect

> **Script:** `./scripts/lab7-redirect.sh`

```nginx
location = /google {
    return 301 https://www.google.com;
}
```

Test: `http://YOUR_PUBLIC_IP/google` → redirects.

---

## Lab 8 — Password Protection

> **Script:** `./scripts/lab8-password-auth.sh` *(interactive — prompts for password)*

```bash
sudo htpasswd -c /etc/nginx/.htpasswd admin
# enter a password when prompted
```

```bash
sudo nano /var/www/html/admin/index.html
```
```html
<!DOCTYPE html><html><body><h1>Private Admin Area</h1></body></html>
```

```nginx
location /admin/ {
    auth_basic "Restricted";
    auth_basic_user_file /etc/nginx/.htpasswd;
    try_files $uri $uri/ =404;
}
```

Test: `http://YOUR_PUBLIC_IP/admin/` → browser prompts for the username/password
you set.

---

## Lab 9 — IP Restriction

> **Script:** `./scripts/lab9-ip-restriction.sh` *(auto-detects your public IP)*

Nginx can allow/deny by IP independently of (or combined with) password auth.

First find your own current public IP (run this on your laptop, not the EC2 box):

```bash
curl ifconfig.me
```

Protect the `/internal/` path so only your IP can reach it:

```bash
echo "Restricted to my IP only" | sudo tee /var/www/html/internal/index.html
```

```nginx
location /internal/ {
    allow 203.0.113.45/32;   # replace with YOUR laptop's public IP
    deny all;
    try_files $uri $uri/ =404;
}
```

Test:
- From your own machine: `http://YOUR_PUBLIC_IP/internal/` → works.
- From your phone on mobile data (different IP), or `curl` from another host
  → **403 Forbidden**.

You can combine both auth methods on one location (both must pass):

```nginx
location /admin/ {
    allow 203.0.113.45/32;
    deny all;
    auth_basic "Restricted";
    auth_basic_user_file /etc/nginx/.htpasswd;
}
```

---

## Lab 10 — Gzip Compression

> **Script:** `./scripts/lab10-gzip.sh`

Add near the top of the `server { }` block (or in `http { }` in `nginx.conf`
for a global effect):

```nginx
gzip on;
gzip_types
    text/plain
    text/css
    application/json
    application/javascript;
```

Test:

```bash
curl -H "Accept-Encoding: gzip" -I http://YOUR_PUBLIC_IP/static/style.css
```

Look for `Content-Encoding: gzip` in the response headers.

---

## Lab 11 — Reverse Proxy to Multiple Applications

> **Script:** `./scripts/lab11-multi-app.sh`

Spin up a **second** Node app on a different port:

```bash
cd /opt/node-app2
npm init -y
npm install express
nano app.js
```

```js
const express = require("express");
const app = express();

app.get("/", (req, res) => res.send("Hello from App 2 (port 4000)"));
app.get("/status", (req, res) => res.json({ app: "app2", status: "ok" }));

app.listen(4000, () => console.log("App2 running on 4000"));
```

```bash
node app.js
```

Now route two different apps through two different paths on the **same**
nginx server:

```nginx
location /api/ {
    proxy_pass http://127.0.0.1:3000/;
    proxy_set_header Host $host;
}

location /app2/ {
    proxy_pass http://127.0.0.1:4000/;
    proxy_set_header Host $host;
}
```

Test:
- `http://YOUR_PUBLIC_IP/api/` → App 1
- `http://YOUR_PUBLIC_IP/app2/` → App 2
- `http://YOUR_PUBLIC_IP/app2/status` → App 2's JSON

This is the "path-based" way to fan a single nginx instance out to multiple
backend services — the same pattern scales to as many apps/ports as you like.

---

## Lab 12 — Simulate Multiple Domains (Without Buying One)

> **Script:** `./scripts/lab12-virtual-hosts.sh`

Real name-based virtual hosting keys off the `Host` header, which nginx reads
via `server_name`. You can test this fully without owning a domain, two ways.

### Option A — Edit your local machine's `hosts` file (closest to the real thing)

On your **laptop** (not the EC2 instance):

- Linux/Mac: `sudo nano /etc/hosts`
- Windows: `C:\Windows\System32\drivers\etc\hosts` (edit as Administrator)

Add:

```
YOUR_PUBLIC_IP   site1.local
YOUR_PUBLIC_IP   site2.local
```

On the EC2 box, create two server blocks distinguished by `server_name`:

```bash
sudo nano /etc/nginx/sites-available/multisite
```

```nginx
server {
    listen 80;
    server_name site1.local;

    root /var/www/site1;
    index index.html;
}

server {
    listen 80;
    server_name site2.local;

    root /var/www/site2;
    index index.html;
}
```

```bash
sudo mkdir -p /var/www/site1 /var/www/site2
echo "<h1>Site 1</h1>" | sudo tee /var/www/site1/index.html
echo "<h1>Site 2</h1>" | sudo tee /var/www/site2/index.html

sudo ln -s /etc/nginx/sites-available/multisite /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
```

Test in your browser: `http://site1.local/` and `http://site2.local/` now
show different content, from the same IP and same nginx instance.

### Option B — No hosts-file edit, just `curl` with a fake Host header

Useful for quick testing without touching your local machine at all:

```bash
curl -H "Host: site1.local" http://YOUR_PUBLIC_IP/
curl -H "Host: site2.local" http://YOUR_PUBLIC_IP/
```

Both hit the same nginx `listen 80`, but get routed to different `server {}`
blocks based purely on the `Host` header — exactly how real domain-based
hosting works once you eventually point real DNS at this IP.

---

## Wrap-up: Verifying Everything

```bash
sudo nginx -t
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

## Notes for going further

- **Keep Node apps running after logout**: use `pm2` (`npm i -g pm2; pm2 start app.js`)
  or a `systemd` unit — otherwise `node app.js` dies when your SSH session ends.
- **HTTPS**: needs a real domain (Let's Encrypt won't issue certs for bare IPs
  or `.local` fake hosts) — a natural next step once you register one.
- **Multiple domains for real**: once you own domains, Lab 12's `server_name`
  blocks work unchanged — just point real DNS `A` records at `YOUR_PUBLIC_IP`
  instead of editing `/etc/hosts`.