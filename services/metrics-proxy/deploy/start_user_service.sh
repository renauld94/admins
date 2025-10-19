#!/usr/bin/env bash
set -euo pipefail

# Start metrics-proxy as the current user using NVM-managed Node
# Expects the app to be at ~/apps/metrics-proxy and NVM installed in ~/.nvm

APP_DIR="$HOME/apps/metrics-proxy"
export NVM_DIR="$HOME/.nvm"

if [ ! -d "$APP_DIR" ]; then
  echo "App directory not found: $APP_DIR" >&2
  exit 1
fi

if [ ! -d "$NVM_DIR" ]; then
  echo "NVM not found at $NVM_DIR" >&2
  exit 1
fi

# shellcheck source=/dev/null
. "$NVM_DIR/nvm.sh"

NODE_BIN="$(nvm which 18)"
if [ ! -x "$NODE_BIN" ]; then
  echo "Node 18 binary not found: $NODE_BIN" >&2
  exit 1
fi

cd "$APP_DIR"

echo "Starting metrics-proxy with $NODE_BIN ..."
nohup "$NODE_BIN" server.js > "$APP_DIR/proxy.out" 2>&1 < /dev/null &
echo $! > "$APP_DIR/proxy.pid"
sleep 1

echo -n "Health: "
if command -v curl >/dev/null 2>&1; then
  curl -fsS http://127.0.0.1:8088/health || true
else
  echo "curl not available"
fi

echo
echo "Logs (tail):"
tail -n 50 "$APP_DIR/proxy.out" || true

echo "Started with PID $(cat "$APP_DIR/proxy.pid")"
