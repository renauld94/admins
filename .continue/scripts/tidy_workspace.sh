#!/usr/bin/env bash
set -euo pipefail
# Lightweight workspace tidy script for .continue
ROOT_DIR="$(dirname "$(dirname "$0")")"
ARCHIVE_DIR="$ROOT_DIR/archived"
mkdir -p "$ARCHIVE_DIR"

echo "Archiving common temporary or backup files into $ARCHIVE_DIR"
shopt -s nullglob
for f in "$ROOT_DIR"/mcpServers/*-1.yaml "$ROOT_DIR"/*.bak "$ROOT_DIR"/*.orig "$ROOT_DIR"/*.old "$ROOT_DIR"/*.env.bak; do
    if [ -e "$f" ]; then
        echo " - archiving: $(basename "$f")"
        mv -v "$f" "$ARCHIVE_DIR/"
    fi
done

if [ -f "$ROOT_DIR/systemd/mcp-tunnel.env" ]; then
    echo "Setting restrictive permissions on systemd env file"
    chmod 600 "$ROOT_DIR/systemd/mcp-tunnel.env" || true
fi

echo "Tidy complete. Archive contents:" 
ls -l "$ARCHIVE_DIR" || true

exit 0
