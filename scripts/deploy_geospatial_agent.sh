#!/usr/bin/env bash
# Deploy helper for Geospatial Data Agent (non-privileged steps)
# This script will create a venv, install requirements, and print the sudo commands needed to install the systemd unit.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENT_PY="$ROOT_DIR/geospatial_data_agent.py"
REQUIREMENTS="$ROOT_DIR/requirements-phase4.txt"
SYSTEMD_UNIT_SRC="$ROOT_DIR/systemd/geospatial-data-agent.service"

echo "[deploy] Root dir: $ROOT_DIR"

if [ ! -f "$AGENT_PY" ]; then
  echo "Agent file not found: $AGENT_PY" >&2
  exit 1
fi

python3 -m venv "$ROOT_DIR/.venv"
echo "Created virtualenv at $ROOT_DIR/.venv"
echo "Activating and installing requirements..."
source "$ROOT_DIR/.venv/bin/activate"
pip install --upgrade pip
pip install -r "$REQUIREMENTS"

echo "" 
echo "✅ Virtualenv ready. To run locally:" 
echo "  source $ROOT_DIR/.venv/bin/activate"
echo "  uvicorn geospatial_data_agent:app --host 0.0.0.0 --port 8000"
echo ""
echo "To install as a systemd service (requires sudo), run these commands:" 
echo "  sudo cp $SYSTEMD_UNIT_SRC /etc/systemd/system/geospatial-data-agent.service"
echo "  sudo systemctl daemon-reload"
echo "  sudo systemctl enable --now geospatial-data-agent.service"
echo "  sudo journalctl -u geospatial-data-agent.service -f"

echo "If you want me to attempt the sudo steps now, grant permission and I'll run them." 
