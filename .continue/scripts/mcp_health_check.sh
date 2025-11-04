#!/usr/bin/env bash
# Simple health check for MCP agent and SSH tunnel
# - Checks SSE endpoint and Ollama API tags
# - If either fails, attempts to restart user services

set -euo pipefail

SSE_URL="http://127.0.0.1:5000/mcp/sse"
OLLAMA_URL="http://127.0.0.1:11434/api/tags"

log() { echo "[$(date -Iseconds)] $*"; }

check_sse() {
  # Try a short SSE connection and expect 'event: connect'
  # Note: grep -q may cause curl to receive SIGPIPE when it finds a match,
  # so we explicitly check the grep exit code only
  local output
  output=$(curl -s --max-time 5 "$SSE_URL" 2>/dev/null || true)
  if echo "$output" | grep -q "event: connect"; then
    return 0
  else
    return 1
  fi
}

check_ollama() {
  if curl -s --max-time 5 "$OLLAMA_URL" | grep -q "\"models\""; then
    return 0
  else
    return 1
  fi
}

restart_services() {
  log "Attempting to restart mcp-agent and mcp-tunnel (user services)"
    systemctl --user restart mcp-agent.service
    systemctl --user restart mcp-tunnel.service
    # Give services more time to come back up. Poll for up to 20s.
    local waited=0
    local max_wait=20
    local interval=2
    while [ $waited -lt $max_wait ]; do
      if check_sse 2>/dev/null; then
        log "SSE recovered after $waited seconds"
        return 0
      fi
      sleep $interval
      waited=$((waited + interval))
    done
    # final check
    if check_sse 2>/dev/null; then
      return 0
    else
      return 1
    fi
}

main() {
  log "Running MCP health check"
  if check_sse; then
    log "SSE endpoint OK"
  else
    log "SSE endpoint DOWN"
    restart_services
    sleep 2
    if check_sse; then
      log "SSE recovered after restart"
    else
      log "SSE still down after restart"
    fi
  fi

  if check_ollama; then
    log "Ollama API OK"
  else
    log "Ollama API DOWN - attempting restart of tunnel"
    systemctl --user restart mcp-tunnel.service || true
    sleep 2
    if check_ollama; then
      log "Ollama recovered after tunnel restart"
    else
      log "Ollama still unreachable"
    fi
  fi
}

main "$@"
