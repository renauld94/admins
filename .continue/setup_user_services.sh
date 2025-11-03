#!/usr/bin/env bash
# Idempotent helper to install .continue user systemd units and create a safe env template.
# This script will NOT enable or start services by default. To enable/start, set ENABLE_SERVICES=1

set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
USER_SYSTEMD_DIR="$HOME/.config/systemd/user"
ENV_FILE="$USER_SYSTEMD_DIR/mcp-tunnel.env"

echo "Preparing to copy systemd unit files to: $USER_SYSTEMD_DIR"
mkdir -p "$USER_SYSTEMD_DIR"

# Copy unit files
for f in poll-to-sse.gunicorn.service mcp-tunnel-autossh.service example-agent.service example-agent.timer; do
    if [ -f "$HERE/systemd/$f" ]; then
        cp "$HERE/systemd/$f" "$USER_SYSTEMD_DIR/"
        echo "Copied $f"
    else
        echo "Skipping $f - not present in $HERE/systemd"
    fi
done

# Copy drop-in env conf if present
if [ -d "$HERE/systemd/mcp-tunnel-autossh.service.d" ]; then
    mkdir -p "$USER_SYSTEMD_DIR/mcp-tunnel-autossh.service.d"
    cp -r "$HERE/systemd/mcp-tunnel-autossh.service.d/"* "$USER_SYSTEMD_DIR/mcp-tunnel-autossh.service.d/" || true
    echo "Copied drop-in files"
fi

# Create a safe env template if not exists
if [ -f "$ENV_FILE" ]; then
    echo "Env file already exists at $ENV_FILE - leaving untouched"
else
    cat > "$ENV_FILE" <<'EOF'
# MCP tunnel env file - fill these values before enabling the autossh unit
# Example:
# REMOTE_USER=simonadmin
# REMOTE_HOST=10.0.0.110
# PROXY_JUMP=root@136.243.155.166:2222
# IDENTITY=/home/simon/.ssh/id_ed25519_lms_academy
# LOCAL_PORT=11435
# REMOTE_PORT=11434

# Set your values below (remove the leading # on the ones you use)
REMOTE_USER=
REMOTE_HOST=
PROXY_JUMP=
IDENTITY=
LOCAL_PORT=11435
REMOTE_PORT=11434
EOF
    chmod 600 "$ENV_FILE"
    echo "Created env template at $ENV_FILE (permissions 600)"
fi

# Reload user systemd daemon
systemctl --user daemon-reload

echo "User systemd units copied. To enable and start, edit $ENV_FILE with your values and then run:" 
cat <<'CMD'
# Edit the env file, then:
# systemctl --user enable --now poll-to-sse.gunicorn.service mcp-tunnel-autossh.service
# (optionally) systemctl --user enable --now example-agent.timer
CMD

echo "If you want this script to enable/start the services automatically, rerun with ENABLE_SERVICES=1"

if [ "${ENABLE_SERVICES:-0}" = "1" ]; then
    if [ "$(uname)" = "Linux" ]; then
        echo "Enabling and starting services now..."
        systemctl --user enable --now poll-to-sse.gunicorn.service mcp-tunnel-autossh.service || true
        echo "(optional) enable example-agent.timer: systemctl --user enable --now example-agent.timer"
    else
        echo "Auto-enable not supported on this OS"
    fi
fi
