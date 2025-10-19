#!/usr/bin/env bash
set -euo pipefail

# Install metrics-proxy on VM106 using ProxyJump
# Requirements: SSH access to vm106 via bastion.

BASTION="${BASTION:-root@136.243.155.166:2222}"
TARGET_USER="${TARGET_USER:-simonadmin}"
TARGET_HOST="${TARGET_HOST:-10.0.0.106}" # vm106
TARGET_SSH_PORT="${TARGET_SSH_PORT:-22}"
PROM_URL_DEFAULT="${PROM_URL_DEFAULT:-http://10.0.0.150:9090}"
API_DOMAIN="${API_DOMAIN:-api.simondatalab.de}"

SSH_ARGS=("-o" "BatchMode=yes" "-o" "ConnectTimeout=10" -J "$BASTION" -p "$TARGET_SSH_PORT")
REMOTE="$TARGET_USER@$TARGET_HOST"

echo "Connecting to $REMOTE via bastion..."
ssh "${SSH_ARGS[@]}" "$REMOTE" 'echo ok' >/dev/null
echo "Connected. Proceeding with installation..."

if [[ -z "${PROM_URL:-}" ]]; then
  read -r -p "Prometheus base URL [$PROM_URL_DEFAULT]: " PROM_URL
  PROM_URL="${PROM_URL:-$PROM_URL_DEFAULT}"
else
  echo "Using PROM_URL=$PROM_URL"
fi

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "Packaging project files..."
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
tar -C "$ROOT_DIR" -czf "$TMPDIR/metrics-proxy.tgz" package.json server.js .env.example

echo "Uploading files..."
scp "${SSH_ARGS[@]}" "$TMPDIR/metrics-proxy.tgz" "$REMOTE:/tmp/metrics-proxy.tgz"
scp "${SSH_ARGS[@]}" "$(dirname "$0")/metrics-proxy.service" "$REMOTE:/tmp/metrics-proxy.service"
scp "${SSH_ARGS[@]}" "$(dirname "$0")/nginx-metrics-proxy.conf" "$REMOTE:/tmp/nginx-metrics-proxy.conf"

echo "Installing on remote..."
ssh "${SSH_ARGS[@]}" "$REMOTE" bash -lc "'
set -e
sudo mkdir -p /opt/metrics-proxy
sudo tar -xzf /tmp/metrics-proxy.tgz -C /opt/metrics-proxy
cd /opt/metrics-proxy

# Install Node 18 if missing
if ! command -v node >/dev/null 2>&1 || [[ \
  $(node -v | sed s/v//) < 18 ]]; then
  curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
  sudo apt-get install -y nodejs
fi

sudo npm install --omit=dev --no-audit --no-fund

sudo cp /tmp/metrics-proxy.service /etc/systemd/system/metrics-proxy.service

# Create .env
sudo bash -c 'cat > /opt/metrics-proxy/.env' <<EOF
PROMETHEUS_BASE_URL=$PROM_URL
PORT=8088
ALLOWED_ORIGINS=https://www.simondatalab.de
ALLOWED_QUERIES=up,sum(rate(http_requests_total[5m]))
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now metrics-proxy.service

# Nginx
if ! command -v nginx >/dev/null 2>&1; then
  sudo apt-get update && sudo apt-get install -y nginx
fi
sudo cp /tmp/nginx-metrics-proxy.conf /etc/nginx/sites-available/metrics-proxy.conf
sudo sed -i "s/server_name .*/server_name $API_DOMAIN;/" /etc/nginx/sites-available/metrics-proxy.conf
sudo ln -sf /etc/nginx/sites-available/metrics-proxy.conf /etc/nginx/sites-enabled/metrics-proxy.conf
sudo nginx -t
sudo systemctl reload nginx

echo "Done. Consider enabling HTTPS (Certbot) for $API_DOMAIN."
'"

echo "Installation complete. Test endpoints:"
echo "  http://$API_DOMAIN/health"
echo "  http://$API_DOMAIN/metrics/targets"
