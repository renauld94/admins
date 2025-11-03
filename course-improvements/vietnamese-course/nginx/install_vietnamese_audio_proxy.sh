#!/usr/bin/env bash
set -euo pipefail

# Install Vietnamese audio proxy snippet and enable it inside the existing
# Moodle nginx server block. Designed to run on the Moodle host as root
# (or via sudo).
#
# Usage on the Moodle VM:
#   sudo bash install_vietnamese_audio_proxy.sh
#
# What it does:
# - writes /etc/nginx/snippets/vietnamese_audio_location.conf
# - finds a site config with server_name containing moodle.simondatalab.de
# - backs up that site config
# - attempts to insert an `include /etc/nginx/snippets/vietnamese_audio_location.conf;`
#   line immediately after the matching server_name line
# - tests nginx and reloads it if the test passes

SNIPPET_PATH="/etc/nginx/snippets/vietnamese_audio_location.conf"

if [ "$EUID" -ne 0 ]; then
  echo "This script must be run with sudo or as root. Example: sudo $0"
  exit 2
fi

mkdir -p "$(dirname "$SNIPPET_PATH")"

cat > "$SNIPPET_PATH" <<'EOF'
# Proxy external audio backend into Moodle's site
location ^~ /vietnamese-audio/ {
    proxy_pass https://moodle.simondatalab.de/vietnamese-audio/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_cache_bypass $http_range;
    proxy_set_header Range $http_range;
    proxy_set_header If-Range $http_if_range;
}

# small health check endpoint
location = /_vietnamese_audio_health {
    return 200 'ok';
    add_header Content-Type text/plain;
}
EOF

echo "Wrote snippet to $SNIPPET_PATH"

# locate the site config that defines the Moodle server_name
SITECONF_CANDIDATES=$(grep -RIn --include="*.conf" "server_name" /etc/nginx || true)

TARGET_FILE=""
# prefer exact matches for moodle.simondatalab.de
if grep -RIn --include="*.conf" "server_name.*moodle.simondatalab.de" /etc/nginx >/dev/null 2>&1; then
  TARGET_FILE=$(grep -RIl --include="*.conf" "server_name.*moodle.simondatalab.de" /etc/nginx | head -n1)
fi

if [ -z "$TARGET_FILE" ]; then
  echo "Could not automatically find a site config containing 'moodle.simondatalab.de'."
  echo "Files that contain 'server_name' under /etc/nginx (first 30 lines):"
  echo "$SITECONF_CANDIDATES" | head -n 30 || true
  echo
  echo "Please open the appropriate site config and add this line inside the server block:"
  echo "    include /etc/nginx/snippets/vietnamese_audio_location.conf;"
  echo
  echo "Exiting without modifying site configs. The snippet file has been installed and can be included manually."
  exit 0
fi

echo "Found site config: $TARGET_FILE"

# backup
BACKUP="$TARGET_FILE.bak.$(date +%s)"
cp "$TARGET_FILE" "$BACKUP"
echo "Backed up $TARGET_FILE -> $BACKUP"

# try to insert include after the server_name line
sed -n '1,200p' "$TARGET_FILE" | head -n 200 >/dev/null 2>&1 || true

# Use sed to add the include after the server_name line containing moodle.simondatalab.de
if grep -q "server_name.*moodle.simondatalab.de" "$TARGET_FILE"; then
  sed -i '/server_name[[:space:]]\+.*moodle.simondatalab.de/ a\
    include /etc/nginx/snippets/vietnamese_audio_location.conf;\
' "$TARGET_FILE"
  echo "Inserted include into $TARGET_FILE"
else
  echo "Warning: expected server_name line not found when re-checking $TARGET_FILE."
  echo "Please add 'include /etc/nginx/snippets/vietnamese_audio_location.conf;' inside the Moodle server block manually."
  exit 1
fi

echo "Testing nginx configuration..."
if nginx -t; then
  echo "nginx config OK — reloading nginx"
  systemctl reload nginx
  echo "Reloaded nginx. Verify with:"
  echo "  curl -I 'https://moodle.simondatalab.de/_vietnamese_audio_health'"
  echo "  curl -I 'https://moodle.simondatalab.de/vietnamese-audio/colloquial_track_02.mp3'"
  exit 0
else
  echo "nginx -t failed. Restoring backup and printing diagnostics."
  cp "$BACKUP" "$TARGET_FILE"
  nginx -t || true
  echo "Recent nginx journalctl entries (last 200 lines):"
  journalctl -u nginx -n 200 --no-pager || true
  echo "Check /var/log/nginx/error.log for more details."
  exit 1
fi
