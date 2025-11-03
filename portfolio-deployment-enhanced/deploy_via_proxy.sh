#!/usr/bin/env bash
set -euo pipefail

# deploy_via_proxy.sh
# Creates a remote backup, runs rsync --dry-run to preview changes, and (optionally)
# performs the real rsync to deploy the local folder to the remote webroot via an SSH ProxyJump.
# Usage:
#   ./deploy_via_proxy.sh               # interactive (will ask before doing the real rsync)
#   ./deploy_via_proxy.sh --auto       # run non-interactively (assumes yes to proceed)
#   ./deploy_via_proxy.sh --help       # show help

# Default configuration - edit as needed or pass environment variables to override
JUMP_HOST=${JUMP_HOST:-root@136.243.155.166}
TARGET_USER=${TARGET_USER:-simonadmin}
TARGET_HOST=${TARGET_HOST:-10.0.0.150}
REMOTE_PATH=${REMOTE_PATH:-/var/www/html}
LOCAL_PATH=${LOCAL_PATH:-$(pwd)}
SSH_OPTS=${SSH_OPTS:-"-o StrictHostKeyChecking=accept-new"}
RSYNC_EXCLUDES=(".git" "node_modules")
AUTO=${1:-}

function usage(){
  cat <<EOF
Usage: $0 [--auto]

Environment overrides supported via env vars:
  JUMP_HOST (default: $JUMP_HOST)
  TARGET_USER (default: $TARGET_USER)
  TARGET_HOST (default: $TARGET_HOST)
  REMOTE_PATH (default: $REMOTE_PATH)
  LOCAL_PATH (default: current dir)

What this script will do:
  1) Test SSH connectivity to the jump host.
  2) Test SSH connectivity to the target via ProxyJump.
  3) Create a timestamped remote tar.gz backup of the remote webroot (/var/www/html).
  4) Run rsync --dry-run and show the changes that would be applied.
  5) If you confirm, run the real rsync to deploy the files.
  6) Optionally reload nginx on the target.

Examples:
  JUMP_HOST=root@1.2.3.4 LOCAL_PATH=./ ./deploy_via_proxy.sh
  ./deploy_via_proxy.sh --auto
EOF
}

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  usage
  exit 0
fi

if [[ "$1" == "--auto" ]]; then
  AUTO=1
fi

echo "Deploy helper starting"
echo "Local path: $LOCAL_PATH"
echo "Jump host: $JUMP_HOST"
echo "Target: $TARGET_USER@$TARGET_HOST"
echo "Remote path: $REMOTE_PATH"

# 1) connectivity to jump host
echo "\n1) Checking connectivity to jump host ($JUMP_HOST)"
if ! ssh -o ConnectTimeout=10 ${JUMP_HOST%%@*} true 2>/dev/null; then
  echo "ERROR: cannot connect to jump host $JUMP_HOST from this machine. Aborting."
  exit 2
fi

echo "Jump host reachable. Proceeding to test target via ProxyJump."

# 2) connectivity to target via ProxyJump
echo "\n2) Checking connectivity to target via proxy jump"
if ! ssh -o ConnectTimeout=12 -o StrictHostKeyChecking=accept-new -J ${JUMP_HOST} ${TARGET_USER}@${TARGET_HOST} 'echo TARGET_OK' 2>/dev/null; then
  echo "ERROR: cannot reach ${TARGET_USER}@${TARGET_HOST} via ProxyJump ${JUMP_HOST} from this machine. Aborting."
  exit 3
fi

echo "Target reachable via proxy. Will create a remote backup."

# 3) Create remote backup
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_PATH="/tmp/site-backup-${TIMESTAMP}.tar.gz"

echo "\n3) Creating remote backup at $BACKUP_PATH"
ssh -o StrictHostKeyChecking=accept-new -J ${JUMP_HOST} ${TARGET_USER}@${TARGET_HOST} \
  "set -euo pipefail; if [ -d \"${REMOTE_PATH}\" ]; then mkdir -p /tmp && tar -czf '${BACKUP_PATH}' -C \"$(dirname ${REMOTE_PATH})\" \"$(basename ${REMOTE_PATH})\" && echo BACKUP_OK:${BACKUP_PATH}; else echo NO_DIR:${REMOTE_PATH}; fi"

# If the backup command failed it will exit because of set -e; if it succeeded, we should have a backup path printed above.

# 4) rsync dry-run
EXCLUDE_ARGS=()
for e in "${RSYNC_EXCLUDES[@]}"; do
  EXCLUDE_ARGS+=(--exclude="$e")
done

echo "\n4) Running rsync --dry-run (preview). This will show what would change on the remote side."
set -x
rsync -avz --delete "${EXCLUDE_ARGS[@]}" -e "ssh -o StrictHostKeyChecking=accept-new -J ${JUMP_HOST}" "${LOCAL_PATH%/}/" "${TARGET_USER}@${TARGET_HOST}:${REMOTE_PATH}" --dry-run
set +x

if [[ -z "$AUTO" ]]; then
  read -p $'Proceed with real rsync deploy? (y/N) ' -r
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborting deploy (user declined). The remote backup remains at: $BACKUP_PATH"
    exit 0
  fi
else
  echo "--auto supplied; proceeding with real rsync"
fi

# 5) real rsync
echo "\n5) Running real rsync to deploy files"
set -x
rsync -avz --delete "${EXCLUDE_ARGS[@]}" -e "ssh -o StrictHostKeyChecking=accept-new -J ${JUMP_HOST}" "${LOCAL_PATH%/}/" "${TARGET_USER}@${TARGET_HOST}:${REMOTE_PATH}"
set +x

# 6) optionally reload nginx
if [[ -z "$AUTO" ]]; then
  read -p $'Reload nginx on the target now? (may require sudo) (y/N) ' -r
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Reloading nginx"
    ssh -o StrictHostKeyChecking=accept-new -J ${JUMP_HOST} ${TARGET_USER}@${TARGET_HOST} "sudo systemctl reload nginx || true"
  else
    echo "Skipped nginx reload."
  fi
else
  echo "--auto supplied; skipping interactive nginx prompt. To reload manually: ssh -o StrictHostKeyChecking=accept-new -J ${JUMP_HOST} ${TARGET_USER}@${TARGET_HOST} 'sudo systemctl reload nginx || true'"
fi

echo "\nDeploy complete. Remote backup: $BACKUP_PATH"

exit 0
