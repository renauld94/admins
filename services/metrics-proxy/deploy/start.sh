#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$(cd "$(dirname "$0")/.." && pwd)"
export NVM_DIR="$HOME/.nvm"

if [ -f "$NVM_DIR/nvm.sh" ]; then
  # shellcheck source=/dev/null
  . "$NVM_DIR/nvm.sh"
fi

NODE_BIN="$(command -v node || true)"
if command -v nvm >/dev/null 2>&1; then
  NODE_BIN="$(nvm which 18)"
fi

if [ -z "$NODE_BIN" ] || [ ! -x "$NODE_BIN" ]; then
  echo "Node binary not found. Ensure Node 18 is installed via NVM." >&2
  exit 1
fi

cd "$APP_DIR"
exec "$NODE_BIN" server.js
