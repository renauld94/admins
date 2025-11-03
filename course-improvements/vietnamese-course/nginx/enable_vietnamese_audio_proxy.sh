#!/usr/bin/env bash
set -euo pipefail

# Enable Vietnamese audio nginx proxy on the Moodle host.
# Usage: sudo ./enable_vietnamese_audio_proxy.sh

CONF_SRC="$(dirname "$0")/moodle_vietnamese_audio.conf"
CONF_DEST="/etc/nginx/sites-available/moodle_vietnamese_audio.conf"

if [ "$EUID" -ne 0 ]; then
  echo "This script must be run with sudo. Example: sudo $0"
  exit 2
fi

if [ ! -f "$CONF_SRC" ]; then
  echo "Config not found at $CONF_SRC"
  exit 1
fi

echo "Copying $CONF_SRC to $CONF_DEST"
cp "$CONF_SRC" "$CONF_DEST"
ln -sf "$CONF_DEST" /etc/nginx/sites-enabled/moodle_vietnamese_audio.conf

echo "Testing nginx configuration..."
nginx -t

echo "Reloading nginx..."
systemctl reload nginx

echo "Done. The proxy is enabled. Verify by curling the proxied file URL (example):"
echo "  curl -I 'https://moodle.simondatalab.de/vietnamese-audio/colloquial_track_02.mp3'"
