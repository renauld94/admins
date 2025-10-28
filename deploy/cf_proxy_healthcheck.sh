#!/usr/bin/env bash
# Simple healthcheck for the CF service-token proxy
set -euo pipefail
PROXY_URL=${1:-http://127.0.0.1:49152}
UPSTREAM_TEST_PATH=${2:-/providers}

# Check env file permissions
ENVFILE="$HOME/.config/cf_proxy/env"
if [ -f "$ENVFILE" ]; then
  perms=$(stat -c '%a' "$ENVFILE")
  if [ "$perms" -ne 600 ]; then
    echo "WARNING: $ENVFILE permissions are $perms, expected 600"
  else
    echo "$ENVFILE permissions OK"
  fi
else
  echo "WARNING: $ENVFILE not found"
fi

# Check systemd service status (best effort)
if systemctl --version >/dev/null 2>&1; then
  if systemctl is-active --quiet cf_service_token_proxy.service; then
    echo "cf_service_token_proxy.service active"
  else
    echo "cf_service_token_proxy.service not active"
  fi
fi

# Perform a proxied GET to the upstream test path
resp_headers=$(mktemp)
resp_body=$(mktemp)
curl -sS -D "$resp_headers" -o "$resp_body" "$PROXY_URL$UPSTREAM_TEST_PATH" || true
status=$(sed -n '1p' "$resp_headers" | awk '{print $2}')
set_cookie=$(grep -i '^Set-Cookie:' "$resp_headers" || true)

if [ "$status" = "200" ]; then
  echo "Proxy fetch OK: $PROXY_URL$UPSTREAM_TEST_PATH returned $status"
  if echo "$set_cookie" | grep -qi CF_Authorization; then
    echo "CF_Authorization cookie present"
  else
    echo "No CF_Authorization cookie in response headers"
  fi
else
  echo "Proxy fetch returned status: $status"
  echo "Headers:"; sed -n '1,200p' "$resp_headers"
fi

rm -f "$resp_headers" "$resp_body"
