#!/usr/bin/env bash
set -euo pipefail
# Auto tidy and light hardening for .continue workspace
# - runs existing tidy_workspace.sh
# - archives legacy files from .continue/systemd and .continue/mcpServers
# - sets restrictive perms on known env files
# - prints a short report

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ARCHIVE_DIR="$ROOT_DIR/archived"
ARCHIVE_SYSTEMD="$ARCHIVE_DIR/systemd"
ARCHIVE_MCP="$ARCHIVE_DIR/mcpServers"

echo "Running base tidy..."
"$ROOT_DIR/scripts/tidy_workspace.sh"

mkdir -p "$ARCHIVE_SYSTEMD" "$ARCHIVE_MCP"

echo "Archiving legacy systemd files..."
shopt -s nullglob
for f in "$ROOT_DIR"/systemd/*~ "$ROOT_DIR"/systemd/*.bak "$ROOT_DIR"/systemd/*.orig "$ROOT_DIR"/systemd/*-dev* "$ROOT_DIR"/systemd/*old*; do
    if [ -e "$f" ]; then
        echo " - archiving: $(basename "$f")"
        mv -v "$f" "$ARCHIVE_SYSTEMD/"
    fi
done

echo "Archiving legacy mcpServers backups..."
for f in "$ROOT_DIR"/mcpServers/*-1.yaml "$ROOT_DIR"/mcpServers/*~ "$ROOT_DIR"/mcpServers/*.bak; do
    if [ -e "$f" ]; then
        echo " - archiving: $(basename "$f")"
        mv -v "$f" "$ARCHIVE_MCP/"
    fi
done

echo "Setting restrictive permissions on env files (if present)"
if [ -f "$ROOT_DIR/systemd/mcp-tunnel.env" ]; then
    chmod 600 "$ROOT_DIR/systemd/mcp-tunnel.env" || true
    echo " - set 600 on $ROOT_DIR/systemd/mcp-tunnel.env"
fi
if [ -f "$HOME/.config/systemd/user/mcp-tunnel.env" ]; then
    chmod 600 "$HOME/.config/systemd/user/mcp-tunnel.env" || true
    echo " - set 600 on $HOME/.config/systemd/user/mcp-tunnel.env"
fi

echo "Checking for private SSH key (won't modify without confirmation):"
KEY_PATH="$HOME/.ssh/id_ed25519_lms_academy"
if [ -f "$KEY_PATH" ]; then
    ls -l "$KEY_PATH"
    echo "If you want, run: chmod 600 $KEY_PATH"
else
    echo " - no key at $KEY_PATH"
fi

echo "Auto tidy complete. Archives:"
ls -l "$ARCHIVE_DIR" || true

exit 0
