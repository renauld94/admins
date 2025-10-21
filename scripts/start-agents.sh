#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
AGENTS_DIR="$ROOT/workspace/agents"
LOGDIR="$ROOT/logs/agents"
AGENT_SCRIPTS="$ROOT/scripts/agents"

mkdir -p "$LOGDIR"

echo "Starting Neuro AI agents (Neuro AI Ecosystem) (local runner)..."

# Ensure workspace agents token exists; if not, create one and export for child processes
TOKEN_FILE="$ROOT/workspace/agents/.token"
if [ ! -f "$TOKEN_FILE" ]; then
  echo "No token found at $TOKEN_FILE — generating a new token"
  if command -v openssl >/dev/null 2>&1; then
    TOKEN=$(openssl rand -hex 24)
  else
    TOKEN=$(head -c 24 /dev/urandom | od -An -tx1 | tr -d ' \n')
  fi
  mkdir -p "$(dirname "$TOKEN_FILE")"
  echo "$TOKEN" > "$TOKEN_FILE"
  chmod 600 "$TOKEN_FILE"
else
  TOKEN=$(cat "$TOKEN_FILE")
fi
export NEURO_AGENT_TOKEN="$TOKEN"
echo "Using NEURO_AGENT_TOKEN from $TOKEN_FILE (exported to environment for agents)"

start_uvicorn() {
  local script="$1"
  local name="$2"
  local port="$3"
  local logfile="$LOGDIR/$name.log"

  if [ ! -f "$script" ]; then
    echo "Agent script $script not found, skipping $name"
    return
  fi

  echo "Launching $name on port $port (log: $logfile)"
  nohup python3 "$script" > "$logfile" 2>&1 &
  sleep 0.2
}

# Launch agents (ports match manifests in workspace/agents)
start_uvicorn "$AGENT_SCRIPTS/core_dev_server.py" core-dev 5101
start_uvicorn "$AGENT_SCRIPTS/data_science_server.py" data-science 5102
start_uvicorn "$AGENT_SCRIPTS/geo_intel_server.py" geo-intel 5103
start_uvicorn "$AGENT_SCRIPTS/web_lms_server.py" web-lms 5104
start_uvicorn "$AGENT_SCRIPTS/systemops_server.py" systemops 5105
start_uvicorn "$AGENT_SCRIPTS/legal_advisor_server.py" legal-advisor 5106

echo "Agents launch requested. Tail logs in $LOGDIR to inspect startup."
echo "For production use, create systemd units per agent or use a process manager."
