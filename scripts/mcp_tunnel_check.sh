#!/usr/bin/env bash
set -euo pipefail

# Simple tunnel + health check script for MCP service on remote VM via ProxyJump
# Configure via environment variables or edit defaults below.

JUMP_HOST=${JUMP_HOST:-136.243.155.166}
JUMP_PORT=${JUMP_PORT:-2222}
JUMP_USER=${JUMP_USER:-root}
TARGET_HOST=${TARGET_HOST:-10.0.0.110}
TARGET_USER=${TARGET_USER:-simonadmin}
# Identity selection: prefer explicitly-set IDENTITY, then project key, then common defaults
if [ -n "${IDENTITY:-}" ]; then
  : # keep user-provided
elif [ -f "$HOME/.ssh/id_ed25519_mcp" ]; then
  IDENTITY="$HOME/.ssh/id_ed25519_mcp"
elif [ -f "$HOME/.ssh/id_rsa" ]; then
  IDENTITY="$HOME/.ssh/id_rsa"
elif [ -f "$HOME/.ssh/id_ed25519" ]; then
  IDENTITY="$HOME/.ssh/id_ed25519"
else
  # fallback to expected path (may prompt for password if not present)
  IDENTITY="$HOME/.ssh/id_ed25519_mcp"
fi
LOCAL_PORT=${LOCAL_PORT:-11434}
REMOTE_PORT=${REMOTE_PORT:-11434}
HEALTH_PATH=${HEALTH_PATH:-/api/tags}
SLEEP_INTERVAL=${SLEEP_INTERVAL:-10}

# We'll prefer autossh if available for more reliable persistent forwards, otherwise fall back to ssh.
# SSH_CMD is built dynamically in start_tunnel().

check_local() {
  curl -sSf "http://127.0.0.1:${LOCAL_PORT}${HEALTH_PATH}" >/dev/null 2>&1
}

dump_curl_debug() {
  echo "$(date -Is) --- CURL DEBUG START ---" >> /tmp/mcp_tunnel_debug.log
  curl -vS "http://127.0.0.1:${LOCAL_PORT}${HEALTH_PATH}" >> /tmp/mcp_tunnel_debug.log 2>&1 || true
  echo "$(date -Is) --- CURL DEBUG END ---" >> /tmp/mcp_tunnel_debug.log
}

is_tunnel_running() {
  # check if something is listening on LOCAL_PORT bound to localhost
  # use a simple, portable grep on ss output instead of complex ss filter syntax
  if ss -ltn 2>/dev/null | grep -q "127.0.0.1:${LOCAL_PORT}\\|:${LOCAL_PORT}\b"; then
    return 0
  fi
  return 1
}

start_tunnel() {
  local cmd
  # Decide whether to include verbose flags based on DEBUG_SSH_VERBOSE env (non-empty/1 enables -v -v)
  local verbose_flags=()
  if [ -n "${DEBUG_SSH_VERBOSE:-}" ] && [ "${DEBUG_SSH_VERBOSE}" != "0" ]; then
    verbose_flags=( -v -v )
  fi

  if command -v autossh >/dev/null 2>&1; then
    # -M 0 disables the monitoring port (we let systemd monitor the process)
    # -f -N run in background without executing a remote command
    cmd=(autossh -M 0 "${verbose_flags[@]}" -f -N -o "ExitOnForwardFailure=yes" -o "ServerAliveInterval=30" -o "ServerAliveCountMax=3" -o "ProxyJump=${JUMP_USER}@${JUMP_HOST}:${JUMP_PORT}" -i "${IDENTITY}" -L ${LOCAL_PORT}:127.0.0.1:${REMOTE_PORT} ${TARGET_USER}@${TARGET_HOST})
  else
    # fallback to ssh with safer options
    cmd=(ssh "${verbose_flags[@]}" -f -N -o "ExitOnForwardFailure=yes" -o "ServerAliveInterval=30" -o "ServerAliveCountMax=3" -o "ProxyJump=${JUMP_USER}@${JUMP_HOST}:${JUMP_PORT}" -i "${IDENTITY}" -L ${LOCAL_PORT}:127.0.0.1:${REMOTE_PORT} ${TARGET_USER}@${TARGET_HOST})
  fi

  echo "$(date -Is) INFO: Starting tunnel: ${cmd[*]}" >> /tmp/mcp_tunnel_debug.log
  # Start in a subshell so we can capture stdout/stderr and handle failures
  ("${cmd[@]}" >> /tmp/mcp_tunnel_debug.log 2>&1) || {
    echo "$(date -Is) ERROR: Failed to start tunnel with command: ${cmd[*]}" >> /tmp/mcp_tunnel_debug.log
    return 1
  }
  # give the forward a moment to establish and the local listener to appear
  sleep 2
  echo "$(date -Is) INFO: start_tunnel returned, checking listener..." >> /tmp/mcp_tunnel_debug.log
}

echo "MCP tunnel health-check loop (CTRL-C to stop). Local port=${LOCAL_PORT} -> ${TARGET_HOST}:${REMOTE_PORT} via ${JUMP_HOST}:${JUMP_PORT}"
while true; do
    if check_local; then
      echo "$(date -Is) OK: MCP health endpoint responded"
    else
      echo "$(date -Is) WARN: health check failed"
      # capture verbose curl output to help debugging transient failures
      dump_curl_debug
      if is_tunnel_running; then
        echo "Tunnel appears to be open, but service not responding. Will retry in ${SLEEP_INTERVAL}s."
      else
        echo "Tunnel not present. Attempting to start tunnel..."
        start_tunnel || echo "Failed to create tunnel. Will retry in ${SLEEP_INTERVAL}s."
      fi
    fi
  sleep ${SLEEP_INTERVAL}
done
