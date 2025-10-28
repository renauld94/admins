#!/usr/bin/env bash
set -euo pipefail

# Usage: CF_API_TOKEN=... ./patch-cloudflare-access-app.sh ACCOUNT_ID APP_ID
# This script will GET the Access app JSON, add read_service_tokens_from_header:"Authorization"
# if not present, and PUT the updated app back. It saves a backup to /tmp.

if [ -z "${CF_API_TOKEN:-}" ]; then
  echo "ERROR: CF_API_TOKEN must be set in the environment. Export it and re-run."
  exit 2
fi
if [ "$#" -ne 2 ]; then
  echo "Usage: CF_API_TOKEN=... $0 ACCOUNT_ID APP_ID"
  exit 2
fi
ACCOUNT_ID="$1"
APP_ID="$2"
TMPDIR="/tmp/cf_access_patch_${APP_ID}_$(date +%s)"
mkdir -p "$TMPDIR"

echo "Fetching Access app for account $ACCOUNT_ID app $APP_ID..."
curl -sS -H "Authorization: Bearer $CF_API_TOKEN" \
  "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/access/apps/$APP_ID" -o "$TMPDIR/app.json"

if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq is required but not found. Install it (apt install jq) and re-run.";
  exit 3
fi

jq -e . "$TMPDIR/app.json" >/dev/null || { echo "Failed to fetch or parse app JSON"; exit 4; }
jq '.result' "$TMPDIR/app.json" > "$TMPDIR/app_result.json"

HAS_FIELD=$(jq 'has("read_service_tokens_from_header")' "$TMPDIR/app_result.json")
if [ "$HAS_FIELD" = "true" ]; then
  echo "App already has read_service_tokens_from_header; nothing to change. Backup: $TMPDIR"
  exit 0
fi

# Create patched body
jq '. + {"read_service_tokens_from_header":"Authorization"}' "$TMPDIR/app_result.json" > "$TMPDIR/app_patch.json"

# PUT back
echo "Putting updated app JSON back to Cloudflare (will not print token or secrets)..."
PUT_RESP="$TMPDIR/put_response.json"
curl -sS -X PUT -H "Authorization: Bearer $CF_API_TOKEN" -H "Content-Type: application/json" \
  --data-binary @"$TMPDIR/app_patch.json" \
  "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/access/apps/$APP_ID" -o "$PUT_RESP"

if jq -e '.success == true' "$PUT_RESP" >/dev/null 2>&1; then
  echo "SUCCESS: Access app updated. Backup and artifacts in $TMPDIR"
  echo "You can now test by sending Authorization: '{\"cf-access-client-id\":\"<CLIENT_ID>\",\"cf-access-client-secret\":\"<CLIENT_SECRET>\"}'"
  exit 0
else
  echo "FAILED to update Access app; response:"; jq . "$PUT_RESP"
  exit 5
fi
