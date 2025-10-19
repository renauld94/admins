#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$HOME/apps/metrics-proxy"
ENV_FILE="$APP_DIR/.env"

if [ ! -d "$APP_DIR" ]; then
  echo "App directory not found: $APP_DIR" >&2
  exit 1
fi

mkdir -p "$APP_DIR"

# Preserve existing ALLOWED_QUERIES if present, else default to 'up'
ALLOWED_Q=$(grep -E '^ALLOWED_QUERIES=' "$ENV_FILE" 2>/dev/null | cut -d= -f2- || echo 'up')

cat > "$ENV_FILE" <<EOF
PROMETHEUS_BASE_URL=https://prometheus.simondatalab.de
PORT=8088
ALLOWED_ORIGINS=https://simondatalab.de,https://www.simondatalab.de
ALLOWED_QUERIES=$ALLOWED_Q
EOF

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

NODE_BIN="$(command -v node || true)"
if command -v nvm >/dev/null 2>&1; then
  NODE_BIN="$(nvm which 18)"
fi

if [ -z "$NODE_BIN" ] || [ ! -x "$NODE_BIN" ]; then
  echo "Node binary not found. Ensure Node 18 is installed via NVM." >&2
  exit 1
fi

cd "$APP_DIR"

# Stop any existing process
pkill -f "[n]ode .*server.js" || true
sleep 0.5

# Start
nohup "$NODE_BIN" server.js > "$APP_DIR/proxy.out" 2>&1 < /dev/null &
echo $! > "$APP_DIR/proxy.pid"
sleep 1

echo -n "Health: "
curl -fsS http://127.0.0.1:8088/health || echo "NO"
echo
echo "Targets (head):"
curl -fsS http://127.0.0.1:8088/metrics/targets | head -c 300 || true
echo
