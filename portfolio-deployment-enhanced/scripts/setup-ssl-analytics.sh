#!/usr/bin/env bash
# setup-ssl-analytics.sh
# Helper script to provision Let's Encrypt SSL for analytics.simondatalab.de
# and place an Nginx sample server block. Run as root on the web server where
# analytics.simondatalab.de will be served.

set -euo pipefail

DOMAIN="analytics.simondatalab.de"
EMAIL="simon@simondatalab.de" # change if needed
NGINX_SITES_AVAILABLE="/etc/nginx/sites-available"
NGINX_SITES_ENABLED="/etc/nginx/sites-enabled"

echo "This script will:
 - Ensure certbot is installed
 - Create/renew Let's Encrypt certificate for $DOMAIN
 - Drop a sample Nginx config for the analytics host
 - Reload nginx to apply changes
\nRun this on the server where $DOMAIN resolves to (as root)."

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or with sudo." >&2
  exit 1
fi

# Install certbot (Debian/Ubuntu) if missing
if ! command -v certbot >/dev/null 2>&1; then
  echo "Installing certbot (snapd) ..."
  apt update
  apt install -y snapd
  snap install core
  snap refresh core
  snap install --classic certbot
  ln -s /snap/bin/certbot /usr/bin/certbot || true
fi

# Create Nginx sample (only if not present)
NGINX_CONF="$NGINX_SITES_AVAILABLE/$DOMAIN"
if [ ! -f "$NGINX_CONF" ]; then
  cat > "$NGINX_CONF" <<'NGINX_SAMPLE'
server {
    listen 80;
    server_name analytics.simondatalab.de;

    # Serve static umami script or proxy to umami backend
    # OPTIONAL: root /var/www/analytics;
    # OPTIONAL: try_files $uri $uri/ =404;

    # If Umami is proxied to a backend container, example:
    # location / {
    #   proxy_pass http://127.0.0.1:3000;
    #   proxy_set_header Host $host;
    #   proxy_set_header X-Real-IP $remote_addr;
    # }

    # Redirect all HTTP to HTTPS
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name analytics.simondatalab.de;

    # ssl_certificate and ssl_certificate_key will be managed by certbot

    # Example location serving the umami.js static file:
    root /var/www/analytics;
    index index.html;

    location / {
      try_files $uri $uri/ =404;
    }

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    add_header X-Content-Type-Options nosniff;
    add_header X-Frame-Options SAMEORIGIN;
    add_header Referrer-Policy no-referrer-when-downgrade;
}
NGINX_SAMPLE
  ln -sf "$NGINX_CONF" "$NGINX_SITES_ENABLED/$DOMAIN"
  echo "Dropped Nginx sample at $NGINX_CONF and enabled it."
else
  echo "Nginx config $NGINX_CONF already exists, skipping creation."
fi

# Ensure nginx config is valid
nginx -t

# Obtain cert with certbot (webroot). Make sure /var/www/analytics is writable and served by nginx.
WEBROOT="/var/www/analytics"
mkdir -p "$WEBROOT"
chown www-data:www-data "$WEBROOT" || true

echo "Requesting Let's Encrypt certificate for $DOMAIN (this will attempt a http-01 challenge)..."
certbot certonly --webroot -w "$WEBROOT" -d "$DOMAIN" --email "$EMAIL" --agree-tos --non-interactive || {
  echo "certbot failed. Check DNS and that $DOMAIN points to this server, then retry." >&2
  exit 1
}

# Ask certbot to install (or we can modify nginx to include cert paths)
CERT_PATH="/etc/letsencrypt/live/$DOMAIN/fullchain.pem"
KEY_PATH="/etc/letsencrypt/live/$DOMAIN/privkey.pem"

if [ -f "$CERT_PATH" ]; then
  echo "Certificate issued at $CERT_PATH"
  # Add ssl paths to nginx conf if not already present
  if ! grep -q "ssl_certificate" "$NGINX_CONF" 2>/dev/null; then
    sed -i "/server_name analytics.simondatalab.de;/a \    ssl_certificate $CERT_PATH;\n    ssl_certificate_key $KEY_PATH;\n    ssl_protocols TLSv1.2 TLSv1.3;\n    ssl_prefer_server_ciphers off;\n" "$NGINX_CONF"
  fi
  nginx -t && systemctl reload nginx
  echo "Nginx reloaded. Certificate installed."
else
  echo "Certificate not found at $CERT_PATH. Please inspect certbot output." >&2
  exit 1
fi

cat <<EOF
Done.
Verify with:
  openssl s_client -connect analytics.simondatalab.de:443 -servername analytics.simondatalab.de | openssl x509 -noout -dates -subject -issuer
  curl -I https://analytics.simondatalab.de/umami.js

If your Umami server is running elsewhere (e.g. container), adjust the Nginx proxy_pass block instead of static root.
EOF
