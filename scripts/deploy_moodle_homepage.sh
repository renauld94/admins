#!/usr/bin/env bash
set -euo pipefail

# Deploy the homepage bundle and geospatial dashboard to the Moodle theme on Proxmox host.
# Uses SSH ProxyJump to reach the internal VM. Adjust variables below or export them before running.
#
# Required (set via env or edit here):
#   JUMP_HOST="136.243.155.166"    # Public jump host (Proxmox)
#   JUMP_PORT="2222"               # SSH port on jump host
#   TARGET_USER="simonadmin"       # User on the internal VM
#   TARGET_HOST="10.0.0.104"       # Internal VM IP/host reachable from jump host
#   THEME_ROOT="/opt/learning-platform/moodle/theme"   # Host bind-mount path for Moodle code
#
# Optional:
#   THEME_NAME="jnjboost"          # Theme symlink name (will resolve latest versioned dir)
#   MOODLE_ROOT="/opt/learning-platform/moodle"        # Moodle root inside host bind mount
#   MOODLE_PHP="/opt/bitnami/php/bin/php"             # PHP binary inside VM/container
#
# Example:
#   JUMP_HOST=136.243.155.166 JUMP_PORT=2222 TARGET_USER=simonadmin TARGET_HOST=10.0.0.104 \
#   bash scripts/deploy_moodle_homepage.sh

JUMP_HOST=${JUMP_HOST:-"136.243.155.166"}
JUMP_PORT=${JUMP_PORT:-"2222"}
TARGET_USER=${TARGET_USER:-"simonadmin"}
TARGET_HOST=${TARGET_HOST:-"10.0.0.104"}
THEME_ROOT=${THEME_ROOT:-"/opt/learning-platform/moodle/theme"}
THEME_NAME=${THEME_NAME:-"jnjboost"}
MOODLE_ROOT=${MOODLE_ROOT:-"/opt/learning-platform/moodle"}
MOODLE_PHP=${MOODLE_PHP:-"/usr/bin/php"}

SRC_DIR_HOME="$(cd "$(dirname "$0")/.." && pwd)/moodle-homepage"

if [[ ! -d "$SRC_DIR_HOME" ]]; then
  echo "ERROR: Source dir not found: $SRC_DIR_HOME" >&2
  exit 1
fi

SSH_JUMP="-J root@${JUMP_HOST}:${JUMP_PORT}"
SSH_TARGET="${TARGET_USER}@${TARGET_HOST}"

# Resolve latest versioned theme directory on the target (e.g., jnjboost.20250908_124759)
set +e
THEME_DIR=$(ssh $SSH_JUMP "$SSH_TARGET" bash -c "
set -euo pipefail
THEME_ROOT='$THEME_ROOT'
THEME_NAME='$THEME_NAME'
LATEST=\$(ls -d \${THEME_ROOT}/\${THEME_NAME}.* 2>/dev/null | sort -V | tail -n1 || true)
if [[ -z \"\$LATEST\" ]]; then
  # fall back to unversioned
  if [[ -d \${THEME_ROOT}/\${THEME_NAME} ]]; then
    echo \"\${THEME_ROOT}/\${THEME_NAME}\"
  else
    echo ''; exit 1
  fi
else
  echo \"\$LATEST\"
fi
")
RC=$?
set -e

if [[ $RC -ne 0 || -z "$THEME_DIR" ]]; then
  echo "ERROR: Could not resolve theme directory on target under $THEME_ROOT/$THEME_NAME*" >&2
  exit 2
fi

echo "Resolved theme directory: $THEME_DIR"

# Create temp directory and copy files
TEMP_DIR="/tmp/moodle_deploy_$$"
ssh $SSH_JUMP "$SSH_TARGET" "mkdir -p $TEMP_DIR"

# Copy files to temp directory first
scp -o "ProxyJump=root@${JUMP_HOST}:${JUMP_PORT}" \
  "$SRC_DIR_HOME/index.html" "$SRC_DIR_HOME/styles.css" "$SRC_DIR_HOME/app.js" \
  "$SSH_TARGET:$TEMP_DIR/"

scp -o "ProxyJump=root@${JUMP_HOST}:${JUMP_PORT}" \
  "$SRC_DIR_HOME/geospatial-viz/index.html" \
  "$SSH_TARGET:$TEMP_DIR/geoviz.html"

# Move files with sudo and set permissions
ssh $SSH_JUMP "$SSH_TARGET" "
sudo cp $TEMP_DIR/* \"$THEME_DIR/\"
sudo mkdir -p \"$THEME_DIR/geospatial-viz\"
sudo cp $TEMP_DIR/geoviz.html \"$THEME_DIR/geospatial-viz/index.html\"
sudo chown -R daemon:daemon \"$THEME_DIR\"
rm -rf $TEMP_DIR
"

# Purge Moodle caches and Mustache cache; restart Moodle service
ssh $SSH_JUMP "$SSH_TARGET" bash -c "cd \"$MOODLE_ROOT\" && sudo $MOODLE_PHP admin/cli/purge_caches.php"
ssh $SSH_JUMP "$SSH_TARGET" bash -c "sudo rm -rf /opt/learning-platform/moodledata/localcache/mustache/* || true"
ssh $SSH_JUMP "$SSH_TARGET" bash -c "sudo /opt/bitnami/ctlscript.sh restart moodle || sudo systemctl restart bitnami || true"

echo "Deployment complete. Visit your site to verify:"
echo "  Frontpage:   http://$JUMP_HOST:8086/"
echo "  Geospatial:  http://$JUMP_HOST:8086/theme/$THEME_NAME/geospatial-viz/index.html"
