#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT=$(cd "$(dirname "$0")/.." && pwd)
SYSTEMD_USER_DIR=${SYSTEMD_USER_DIR:-$HOME/.config/systemd/user}

echo "Installing Python requirements for poll-to-sse (user site)..."
python3 -m pip install --user -r "$REPO_ROOT/.continue/agents/requirements-poll-to-sse.txt"

echo "Creating systemd user directory: $SYSTEMD_USER_DIR"
mkdir -p "$SYSTEMD_USER_DIR"

echo "Copying unit files to $SYSTEMD_USER_DIR"
cp -v "$REPO_ROOT/.continue/systemd/"*.service "$SYSTEMD_USER_DIR/"

echo "Reloading systemd user units"
systemctl --user daemon-reload

echo "Enabling and starting poll-to-sse.service"
systemctl --user enable --now poll-to-sse.service || {
  echo "Failed to enable/start poll-to-sse.service. Check 'systemctl --user status poll-to-sse.service'"
}

# Handle tunnel service: only enable/start if REMOTE_USER and REMOTE_HOST are set in environment
if [ -n "${REMOTE_USER:-}" ] && [ -n "${REMOTE_HOST:-}" ]; then
  echo "REMOTE_USER and REMOTE_HOST detected in environment — creating drop-in and starting tunnel service"
  mkdir -p "$HOME/.config/systemd/user/mcp-tunnel-check.service.d"
  cat > "$HOME/.config/systemd/user/mcp-tunnel-check.service.d/env.conf" <<EOF
[Service]
Environment="REMOTE_USER=${REMOTE_USER}" "REMOTE_HOST=${REMOTE_HOST}" "PROXY_JUMP=${PROXY_JUMP:-}" "SSH_KEY=${SSH_KEY:-$HOME/.ssh/id_ed25519_mcp}"
EOF
  systemctl --user daemon-reload
  systemctl --user enable --now mcp-tunnel-check.service || echo "Failed to start mcp-tunnel-check.service"
else
  echo "REMOTE_USER and/or REMOTE_HOST not set. The tunnel service was not enabled."
  echo "Create a drop-in file at $HOME/.config/systemd/user/mcp-tunnel-check.service.d/env.conf with your tunnel settings, then run:"
  echo "  systemctl --user daemon-reload"
  echo "  systemctl --user enable --now mcp-tunnel-check.service"
  echo "Example drop-in contents (edit values):"
  cat <<'EX'
[Service]
Environment="REMOTE_USER=simonadmin" "REMOTE_HOST=10.0.0.110" "PROXY_JUMP=root@136.243.155.166:2222" "SSH_KEY=/home/simon/.ssh/id_ed25519_mcp"
EX
fi

echo "Done. Check service statuses with:"
echo "  systemctl --user status poll-to-sse.service mcp-tunnel-check.service --no-pager -l"
echo "Logs: journalctl --user -u poll-to-sse.service -f"
