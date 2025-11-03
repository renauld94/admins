#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(dirname "$0")"
PY="$(command -v python3 || true)"
if [ -z "$PY" ]; then
  echo "python3 not found" >&2
  exit 2
fi

exec "$PY" "$SCRIPT_DIR/example_agent.py" --once
