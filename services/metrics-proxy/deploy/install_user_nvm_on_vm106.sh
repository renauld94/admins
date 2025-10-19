#!/usr/bin/env bash
set -euo pipefail

# Non-root install using NVM + systemd --user

BASTION="${BASTION:-root@136.243.155.166:2222}"
TARGET_USER="${TARGET_USER:-simonadmin}"
TARGET_HOST="${TARGET_HOST:-10.0.0.106}" # vm106
TARGET_SSH_PORT="${TARGET_SSH_PORT:-22}"
PROM_URL_DEFAULT="${PROM_URL_DEFAULT:-http://10.0.0.150:9090}"

SSH_ARGS=("-o" "BatchMode=yes" "-o" "ConnectTimeout=10" -J "$BASTION" -p "$TARGET_SSH_PORT")
REMOTE="$TARGET_USER@$TARGET_HOST"

echo "Connecting to $REMOTE via bastion..."
ssh "${SSH_ARGS[@]}" "$REMOTE" 'echo ok' >/dev/null
echo "Connected. Proceeding with user-mode install..."

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

echo "Installing remotely (no sudo)..."
ssh "${SSH_ARGS[@]}" "$REMOTE" bash -lc "'
set -e
export HOME=~
APP_DIR=\"$HOME/apps/metrics-proxy\"
mkdir -p \"$APP_DIR\"
tar -xzf /tmp/metrics-proxy.tgz -C \"$APP_DIR\"

# Install NVM + Node 18 locally
if [ ! -d \"$HOME/.nvm\" ]; then
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi
export NVM_DIR=\"$HOME/.nvm\"
[ -s \"$NVM_DIR/nvm.sh\" ] && . \"$NVM_DIR/nvm.sh\"
nvm install 18
nvm use 18

cd \"$APP_DIR\"
npm install --omit=dev --no-audit --no-fund

# Create .env
cat > \"$APP_DIR/.env\" <<EOF
PROMETHEUS_BASE_URL=$PROM_URL
PORT=8088
ALLOWED_ORIGINS=https://www.simondatalab.de
ALLOWED_QUERIES=up,sum(rate(http_requests_total[5m]))
EOF

# Create systemd user unit
mkdir -p \"$HOME/.config/systemd/user\"
cat > \"$HOME/.config/systemd/user/metrics-proxy.service\" <<UNIT
[Unit]
Description=Metrics Proxy (user)
After=default.target

[Service]
Type=simple
Environment=NODE_ENV=production
Environment=PATH=$HOME/.nvm/versions/node/$(node -v | sed s/v//)/bin:$PATH
WorkingDirectory=$APP_DIR
ExecStart=$HOME/.nvm/versions/node/$(node -v | sed s/v//)/bin/node server.js
Restart=always
RestartSec=3

[Install]
WantedBy=default.target
UNIT

systemctl --user daemon-reload
systemctl --user enable --now metrics-proxy.service || true

echo \"If the service does not persist after logout, enable linger for the user on the host: sudo loginctl enable-linger $(whoami)\"
echo \"Service status:\"
systemctl --user status --no-pager --lines=0 metrics-proxy.service || true
'
"

echo "User-mode install complete. Next: add Cloudflare Tunnel route api.simondatalab.de -> http://10.0.0.106:8088"
