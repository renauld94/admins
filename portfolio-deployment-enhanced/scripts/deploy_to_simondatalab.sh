#!/usr/bin/env bash
set -euo pipefail

# deploy_to_simondatalab.sh
# Safe, idempotent deployment helper using rsync over SSH.
# Edit or pass environment variables when running.

# Usage examples:
#   DRY_RUN=1 ./scripts/deploy_to_simondatalab.sh
#   REMOTE_USER=www-data REMOTE_HOST=simondatalab.de REMOTE_PATH=/var/www/simondatalab.de \
#       SSH_PORT=22 ./scripts/deploy_to_simondatalab.sh
#   # Use SSH agent or SSH key: ssh-add /path/to/key

REMOTE_USER="${REMOTE_USER:-youruser}"
REMOTE_HOST="${REMOTE_HOST:-example.com}"
REMOTE_PATH="${REMOTE_PATH:-/var/www/html}"    # remote webroot or site directory
SSH_PORT="${SSH_PORT:-22}"
DRY_RUN="${DRY_RUN:-0}"

SRC_DIR="$(cd "$(dirname "$0")/.." && pwd)/portfolio-deployment-enhanced/"
EXCLUDES=(".git" "node_modules" "*.log" "deploy/*.key" "*.pem" "README.md")

RSYNC_EXCLUDE_ARGS=()
for e in "${EXCLUDES[@]}"; do
  RSYNC_EXCLUDE_ARGS+=(--exclude="$e")
done

SSH_CMD="ssh -p ${SSH_PORT} -o StrictHostKeyChecking=accept-new"
RSYNC_OPTS=(--archive --compress --delete --partial --human-readable --omit-dir-times --no-perms --progress)

if [ "$DRY_RUN" != "0" ]; then
  RSYNC_OPTS+=(--dry-run)
  echo "*** DRY RUN enabled - no files will be transferred. Remove DRY_RUN to perform real deploy."
fi

echo "Source: $SRC_DIR"
echo "Destination: ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH} (port ${SSH_PORT})"

echo "Preparing to rsync..."

rsync "${RSYNC_OPTS[@]}" "${RSYNC_EXCLUDE_ARGS[@]}" -e "$SSH_CMD" "$SRC_DIR" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}"

if [ "$DRY_RUN" != "0" ]; then
  echo "Dry run complete. Inspect the rsync output above. To deploy remove DRY_RUN or set DRY_RUN=0."
  exit 0
fi

echo "Files synced."

# Optional post-deploy hooks (uncomment and adapt if you have remote commands to run)
# echo "Running remote post-deploy tasks..."
# ${SSH_CMD} ${REMOTE_USER}@${REMOTE_HOST} <<'SSH'
#   # e.g. chown -R www-data:www-data /var/www/simondatalab.de
#   # systemctl reload nginx
# SSH

echo "Deployment finished. Verify on https://www.simondatalab.de/"
