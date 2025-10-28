#!/usr/bin/env bash
set -euo pipefail

# Simple tunnel + health check script for MCP service on remote VM via ProxyJump
# Configure via environment variables or edit defaults below.

JUMP_HOST=${JUMP_HOST:-136.243.155.166}
JUMP_PORT=${JUMP_PORT:-2222}
JUMP_USER=${JUMP_USER:-root}
TARGET_HOST=${TARGET_HOST:-10.0.0.110}
TARGET_USER=${TARGET_USER:-simonadmin}
IDENTITY=${IDENTITY:-$HOME/.ssh/id_ed25519_mcp}
LOCAL_PORT=${LOCAL_PORT:-11434}
REMOTE_PORT=${REMOTE_PORT:-11434}
HEALTH_PATH=${HEALTH_PATH:-/api/tags}
SLEEP_INTERVAL=${SLEEP_INTERVAL:-10}

SSH_CMD=(ssh -f -N -o "ProxyJump=${JUMP_USER}@${JUMP_HOST}:${JUMP_PORT}" -i "${IDENTITY}" -L ${LOCAL_PORT}:127.0.0.1:${REMOTE_PORT} ${TARGET_USER}@${TARGET_HOST})

check_local() {
  curl -sSf "http://127.0.0.1:${LOCAL_PORT}${HEALTH_PATH}" >/dev/null 2>&1
}

is_tunnel_running() {
  # check if something is listening on LOCAL_PORT bound to localhost
  ss -ltn '( sport = :'"${LOCAL_PORT}"' )' >/dev/null 2>&1 || return 1
  return 0
}

start_tunnel() {
  echo "Starting SSH tunnel: ${SSH_CMD[*]}"
  "${SSH_CMD[@]}" || {
    echo "Failed to start ssh tunnel" >&2
    return 1
  }
}

echo "MCP tunnel health-check loop (CTRL-C to stop). Local port=${LOCAL_PORT} -> ${TARGET_HOST}:${REMOTE_PORT} via ${JUMP_HOST}:${JUMP_PORT}"
while true; do
  if check_local; then
    echo "$(date -Is) OK: MCP health endpoint responded"
  else
    echo "$(date -Is) WARN: health check failed"
    if is_tunnel_running; then
      echo "Tunnel appears to be open, but service not responding. Will retry in ${SLEEP_INTERVAL}s."
    else
      echo "Tunnel not present. Attempting to start tunnel..."
      start_tunnel || echo "Failed to create tunnel. Will retry in ${SLEEP_INTERVAL}s."
    fi
  fi
  sleep ${SLEEP_INTERVAL}
done
