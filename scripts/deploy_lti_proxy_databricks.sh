#!/usr/bin/env bash
set -euo pipefail

# Deploy LTI proxy container to vm9001 (behind the jump host)
JUMP_HOST=${JUMP_HOST:-"136.243.155.166"}
JUMP_PORT=${JUMP_PORT:-"2222"}
TARGET_USER=${TARGET_USER:-"simonadmin"}
TARGET_HOST=${TARGET_HOST:-"10.0.0.104"}
REMOTE_DIR=${REMOTE_DIR:-"/home/${TARGET_USER}/lti-proxy-dbx"}
IMAGE_TAG=${IMAGE_TAG:-"lti-proxy-dbx:latest"}
HOST_PORT=${HOST_PORT:-"8081"}

ROOT=$(cd "$(dirname "$0")/.." && pwd)
SRCDIR="$ROOT/services/lti-proxy-databricks"

# Package context
TMP_TAR="/tmp/lti-proxy-dbx.tar"
rm -f "$TMP_TAR"
tar -C "$SRCDIR" -cf "$TMP_TAR" .

# Ship files and build remotely
ssh -J root@${JUMP_HOST}:${JUMP_PORT} ${TARGET_USER}@${TARGET_HOST} bash -lc "mkdir -p ${REMOTE_DIR}"
scp -o "ProxyJump=root@${JUMP_HOST}:${JUMP_PORT}" "$TMP_TAR" ${TARGET_USER}@${TARGET_HOST}:/tmp/
ssh -J root@${JUMP_HOST}:${JUMP_PORT} ${TARGET_USER}@${TARGET_HOST} bash -lc "\
  tar -C ${REMOTE_DIR} -xf /tmp/lti-proxy-dbx.tar && rm -f /tmp/lti-proxy-dbx.tar && \
  docker build -t ${IMAGE_TAG} ${REMOTE_DIR} && \
  docker rm -f lti-proxy-dbx || true && \
  docker run -d --restart unless-stopped --name lti-proxy-dbx -p ${HOST_PORT}:8080 ${IMAGE_TAG}
"

echo "LTI proxy deployed on vm9001 port ${HOST_PORT}. Configure Moodle tool URLs to https://moodle.simondatalab.de:${HOST_PORT}"