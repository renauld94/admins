#!/usr/bin/env bash
set -euo pipefail
# Helper to ensure the per-user ssh-agent service is running and add a private key.
# Usage:
#   ./add_ssh_key_to_agent.sh [path-to-key]

KEY_PATH="${1:-$HOME/.ssh/id_ed25519_lms_academy}"

if [ -z "${XDG_RUNTIME_DIR-}" ]; then
  echo "XDG_RUNTIME_DIR not set. Are you running under a user systemd session?"
  exit 1
fi

SOCK="$XDG_RUNTIME_DIR/ssh-agent.sock"

if [ ! -S "$SOCK" ]; then
  echo "ssh-agent socket not found at $SOCK — starting ssh-agent.service (user)..."
  systemctl --user daemon-reload || true
  systemctl --user enable --now ssh-agent.service
  sleep 0.5
fi

if [ ! -f "$KEY_PATH" ]; then
  echo "Key not found: $KEY_PATH"
  exit 2
fi

echo "Adding key to agent (you may be prompted for a passphrase): $KEY_PATH"
ssh-add "$KEY_PATH"
echo "Done. Use 'ssh-add -l' to list loaded identities."
