#!/usr/bin/env bash
set -euo pipefail

# deploy_portfolio.sh
# Atomic deploy helper for simondatalab portfolio + infrastructure page
# Usage:
#   ./deploy/deploy_portfolio.sh \ 
#     --user simon --host example.com --remote-root /var/www/simondatalab.de \
#     --port 22 --local-folder ./portfolio-deployment-enhanced --infra-file ./infrastructure-diagram.html
#
# The script will:
#  - rsync the local folder to a timestamped temp dir on the remote host
#  - rsync the infra HTML file alongside it
#  - SSH into the remote host to create a tar backup of the current webroot
#  - atomically move the new files into place and set ownership
#  - print a rollback command in case something goes wrong
#
# IMPORTANT: Review the commands printed by --dry-run before running for real.

show_help(){
  sed -n '1,120p' "$0" | sed -n '1,40p'
}

DRY_RUN=0
SSH_PORT=22
LOCAL_FOLDER="./portfolio-deployment-enhanced"
INFRA_FILE="./infrastructure-diagram.html"
REMOTE_USER=""
REMOTE_HOST=""
REMOTE_ROOT=""
BACKUP_DIR="/var/backups/simondatalab"
PROXY_JUMP=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --user) REMOTE_USER="$2"; shift 2;;
    --host) REMOTE_HOST="$2"; shift 2;;
    --remote-root) REMOTE_ROOT="$2"; shift 2;;
    --port) SSH_PORT="$2"; shift 2;;
    --local-folder) LOCAL_FOLDER="$2"; shift 2;;
    --infra-file) INFRA_FILE="$2"; shift 2;;
  --backup-dir) BACKUP_DIR="$2"; shift 2;;
  --proxy-jump) PROXY_JUMP="$2"; shift 2;;
  --dry-run) DRY_RUN=1; shift 1;;
    -h|--help) show_help; exit 0;;
    *) echo "Unknown arg: $1"; show_help; exit 1;;
  esac
done

if [[ -z "$REMOTE_USER" || -z "$REMOTE_HOST" || -z "$REMOTE_ROOT" ]]; then
  echo "Missing required args. Usage: --user <user> --host <host> --remote-root <path> [--port <22>] [--dry-run]"
  exit 2
fi

TS=$(date -u +%Y%m%dT%H%M%SZ)
DEPLOY_TMP="/tmp/simondatalab-deploy-${TS}"

echo "Preparing deploy"
echo "  remote: ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_ROOT}"
echo "  tmp: ${DEPLOY_TMP}"
echo "  local folder: ${LOCAL_FOLDER}"
echo "  infra file: ${INFRA_FILE}"
echo "  dry-run: ${DRY_RUN}"

RSYNC_OPTS=( -az --delete --exclude='.git' )

# Build SSH extra args (ProxyJump if provided)
SSH_EXTRA_ARGS="-p ${SSH_PORT}"
if [[ -n "${PROXY_JUMP}" ]]; then
  SSH_EXTRA_ARGS+=" -J ${PROXY_JUMP}"
fi

SSH_CMD=(ssh ${SSH_EXTRA_ARGS} "${REMOTE_USER}@${REMOTE_HOST}")

if [[ ${DRY_RUN} -eq 1 ]]; then
  echo "DRY RUN: showing commands that would be executed"
  echo rsync "${RSYNC_OPTS[@]}" -e "ssh ${SSH_EXTRA_ARGS}" "${LOCAL_FOLDER}/" "${REMOTE_USER}@${REMOTE_HOST}:${DEPLOY_TMP}/portfolio-deployment-enhanced/"
  echo rsync -az -e "ssh ${SSH_EXTRA_ARGS}" "${INFRA_FILE}" "${REMOTE_USER}@${REMOTE_HOST}:${DEPLOY_TMP}/"
  echo "Then ssh ${REMOTE_USER}@${REMOTE_HOST} would run a safe swap and backup sequence."
  exit 0
fi

echo "Step 1: upload files to remote temp dir"
mkdir -p /tmp || true
rsync "${RSYNC_OPTS[@]}" -e "ssh ${SSH_EXTRA_ARGS}" "${LOCAL_FOLDER}/" "${REMOTE_USER}@${REMOTE_HOST}:${DEPLOY_TMP}/portfolio-deployment-enhanced/"
rsync -az -e "ssh ${SSH_EXTRA_ARGS}" "${INFRA_FILE}" "${REMOTE_USER}@${REMOTE_HOST}:${DEPLOY_TMP}/"

echo "Step 2: perform remote swap (backup current webroot, move new files into place)"
REMOTE_SCRIPT=$(cat <<'EOF'
set -euo pipefail
TS_REPLACE="${TS}"
WEBROOT="${REMOTE_ROOT}"
DEPLOY_TMP="${DEPLOY_TMP}"
BACKUP_DIR="${BACKUP_DIR}"

echo "On remote: creating backup dir"
sudo mkdir -p "${BACKUP_DIR}"
echo "Creating tarball backup of current webroot (if exists)"
if [ -d "${WEBROOT}" ]; then
  sudo tar -C "$(dirname "${WEBROOT}")" -czf "${BACKUP_DIR}/simondatalab.de_${TS_REPLACE}.tar.gz" "$(basename "${WEBROOT}")"
  echo "Backup written to ${BACKUP_DIR}/simondatalab.de_${TS_REPLACE}.tar.gz"
  sudo mv "${WEBROOT}" "${WEBROOT}.old_${TS_REPLACE}" || true
else
  echo "No existing webroot found at ${WEBROOT}; creating directory"
  sudo mkdir -p "${WEBROOT}"
fi

echo "Moving new files into place"
sudo rsync -a "${DEPLOY_TMP}/" "${WEBROOT}/"

echo "Ensure ownership (www-data:www-data)"
sudo chown -R www-data:www-data "${WEBROOT}"

echo "Cleaning up temp files"
sudo rm -rf "${DEPLOY_TMP}"

echo "Deploy complete. Backup stored at ${BACKUP_DIR}/simondatalab.de_${TS_REPLACE}.tar.gz"
EOF
)

echo "Executing remote swap via SSH..."
ssh ${SSH_EXTRA_ARGS} "${REMOTE_USER}@${REMOTE_HOST}" "${REMOTE_SCRIPT}"

echo
echo "Deploy finished. If you need to rollback, here is a quick rollback hint (run on remote):"
echo "  sudo rm -rf ${REMOTE_ROOT} && sudo mv ${REMOTE_ROOT}.old_${TS} ${REMOTE_ROOT} && sudo chown -R www-data:www-data ${REMOTE_ROOT}"

echo "Done."
