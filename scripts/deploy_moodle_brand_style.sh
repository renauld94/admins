#!/usr/bin/env bash
set -euo pipefail

# Deploy brand-aligned Moodle CSS/JS to vm9001 and inject via Additional HTML
# Aligns Moodle with simondatalab.de styles and removes emojis.

# Env/config (override via environment if needed)
JUMP_HOST=${JUMP_HOST:-"136.243.155.166"}
JUMP_PORT=${JUMP_PORT:-"2222"}
TARGET_USER=${TARGET_USER:-"simonadmin"}
TARGET_HOST=${TARGET_HOST:-"10.0.0.104"}
MOODLE_CONTAINER=${MOODLE_CONTAINER:-"moodle-databricks-fresh"}
CONTAINER_WWWROOT=${CONTAINER_WWWROOT:-"/opt/bitnami/moodle"}
CONTAINER_CLI=${CONTAINER_CLI:-"/opt/bitnami/moodle/admin/cli"}
CONTAINER_PHP=${CONTAINER_PHP:-"/opt/bitnami/php/bin/php"}

CSS_LOCAL_PATH="$(cd "$(dirname "$0")/.." && pwd)/learning-platform/moodle-simondatalab.css"
JS_LOCAL_PATH="$(cd "$(dirname "$0")/.." && pwd)/learning-platform/moodle-remove-emojis.js"

SSH_JUMP="-J root@${JUMP_HOST}:${JUMP_PORT}"
SSH_TARGET="${TARGET_USER}@${TARGET_HOST}"

echo "Uploading CSS/JS to vm9001 via jump host..."
scp -o "ProxyJump=root@${JUMP_HOST}:${JUMP_PORT}" "$CSS_LOCAL_PATH" "$SSH_TARGET:/tmp/moodle-simondatalab.css"
scp -o "ProxyJump=root@${JUMP_HOST}:${JUMP_PORT}" "$JS_LOCAL_PATH" "$SSH_TARGET:/tmp/moodle-remove-emojis.js"

echo "Copying files into Moodle container webroot and setting permissions..."
ssh $SSH_JUMP "$SSH_TARGET" bash -lc "\
  set -euo pipefail; \
  docker cp /tmp/moodle-simondatalab.css ${MOODLE_CONTAINER}:${CONTAINER_WWWROOT}/moodle-simondatalab.css; \
  docker cp /tmp/moodle-remove-emojis.js ${MOODLE_CONTAINER}:${CONTAINER_WWWROOT}/moodle-remove-emojis.js; \
  docker exec ${MOODLE_CONTAINER} bash -lc 'chown daemon:daemon ${CONTAINER_WWWROOT}/moodle-simondatalab.css ${CONTAINER_WWWROOT}/moodle-remove-emojis.js || chown www-data:www-data ${CONTAINER_WWWROOT}/moodle-simondatalab.css ${CONTAINER_WWWROOT}/moodle-remove-emojis.js; chmod 0644 ${CONTAINER_WWWROOT}/moodle-simondatalab.css ${CONTAINER_WWWROOT}/moodle-remove-emojis.js'; \
  rm -f /tmp/moodle-simondatalab.css /tmp/moodle-remove-emojis.js \
"

echo "Injecting into Additional HTML 'head' block via Moodle CLI inside container (append-safe)..."
PAYLOAD='<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin><link rel="stylesheet" href="/moodle-simondatalab.css"><script defer src="/moodle-remove-emojis.js"></script>'

echo "Preparing helper script inside container to set Additional HTML..."
ssh $SSH_JUMP "$SSH_TARGET" bash -lc "\
  docker exec ${MOODLE_CONTAINER} bash -lc 'cat > /tmp/set_additional_head.sh <<\'EOS' && chmod +x /tmp/set_additional_head.sh && /tmp/set_additional_head.sh && rm -f /tmp/set_additional_head.sh\n#!/usr/bin/env bash\nset -euo pipefail\nPHP=\"${CONTAINER_PHP}\"\nCLI=\"${CONTAINER_CLI}\"\nPAYLOAD=\"${PAYLOAD}\"\nCURRENT=\"$($CONTAINER_PHP $CONTAINER_CLI/cfg.php --component=core --name=additionalhtmlhead || true)\"\nif [[ \"$CURRENT\" != *\"moodle-simondatalab.css\"* ]]; then\n  NEW=\"${CURRENT}${PAYLOAD}\"\n  echo -n \"$NEW\" > /tmp/additional_head.html\n  VAL=\"$(tr -d "\\n" < /tmp/additional_head.html)\"\n  $PHP $CLI/cfg.php --component=core --name=additionalhtmlhead --set=\"$VAL\"\n  rm -f /tmp/additional_head.html\nelse\n  echo \"Already injected.\"\nfi\nEOS'"

echo "Purging caches via container CLI..."
ssh $SSH_JUMP "$SSH_TARGET" bash -lc "docker exec ${MOODLE_CONTAINER} ${CONTAINER_PHP} ${CONTAINER_CLI}/purge_caches.php"

echo "Verifying on homepage..."
CONTENT=$(ssh $SSH_JUMP "$SSH_TARGET" bash -lc "curl -sk https://moodle.simondatalab.de/ | head -n 1000")
echo "$CONTENT" | grep -q "moodle-simondatalab.css" && echo "✅ CSS linked" || echo "⚠️ CSS link not detected"
echo "$CONTENT" | grep -q "moodle-remove-emojis.js" && echo "✅ JS linked" || echo "⚠️ JS link not detected"

echo "Done. Visit https://moodle.simondatalab.de/ and verify style alignment."
