#!/usr/bin/env bash
# Deploy infrastructure-beautiful.html to simondatalab.de via rsync+ssh
# Usage:
#   REMOTE_USER=user REMOTE_HOST=www.simondatalab.de REMOTE_PATH=/var/www/html/infrastructure ./scripts/deploy_to_simondatalab.sh [--dry-run]

set -euo pipefail

DRY_RUN=0
if [[ ${1:-} == "--dry-run" || ${1:-} == "-n" ]]; then
  DRY_RUN=1
fi

: "${REMOTE_USER:?Please set REMOTE_USER environment variable (ssh user)}"
: "${REMOTE_HOST:?Please set REMOTE_HOST environment variable (e.g. www.simondatalab.de)}"
: "${REMOTE_PATH:?Please set REMOTE_PATH environment variable (target path on remote)}"

SOURCE_FILE="infrastructure-beautiful.html"
DEPLOY_DIR="deploy"

if [[ -d "$DEPLOY_DIR" ]]; then
  SRC="$DEPLOY_DIR/"
else
  if [[ ! -f "$SOURCE_FILE" ]]; then
    echo "ERROR: Neither $DEPLOY_DIR/ nor $SOURCE_FILE found. Nothing to deploy."
    exit 2
  fi
  SRC="$SOURCE_FILE"
fi

RSYNC_OPTS=( -avz --delete --compress-level=6 )
if [[ $DRY_RUN -eq 1 ]]; then
  RSYNC_OPTS+=( --dry-run )
fi

echo "Deploying $SRC -> ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}"

rsync "${RSYNC_OPTS[@]}" -e "ssh" "$SRC" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}"

if [[ $DRY_RUN -eq 1 ]]; then
  echo "Dry run complete. No files transferred." 
else
  echo "Deployment complete." 
fi
