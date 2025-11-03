#!/usr/bin/env bash
set -euo pipefail
# Simple helper to test Cloudflare Access protected app `openwebui.simondatalab.de`.
# Usage:
#   CF_ACCESS_CLIENT_ID=xxx CF_ACCESS_CLIENT_SECRET=yyy /.continue/scripts/check_openwebui_cloudflare.sh
#   or
#   /.continue/scripts/check_openwebui_cloudflare.sh --show-cmds

TARGET_URL="https://openwebui.simondatalab.de/"

print_help(){
  cat <<'EOF'
Usage: check_openwebui_cloudflare.sh [--show-cmds] [--bypass ORIGIN_IP]

This helper attempts to diagnose Cloudflare Access 403 issues for openwebui.simondatalab.de.

Modes:
  --show-cmds        Print the exact curl commands to run (safe, no secrets required).
  --bypass ORIGIN_IP  Try to contact the origin server directly by forcing DNS resolution
                      (useful if you control the origin and want to bypass Cloudflare for testing).

Environment variables (optional):
  CF_ACCESS_CLIENT_ID      Cloudflare Access Service Token client id
  CF_ACCESS_CLIENT_SECRET  Cloudflare Access Service Token client secret
  CF_API_TOKEN             Cloudflare Global API token (for log queries, optional)

Examples:
  # Test with Access service token in env
  CF_ACCESS_CLIENT_ID=xxx CF_ACCESS_CLIENT_SECRET=yyy ./check_openwebui_cloudflare.sh

  # Print helper curl commands you can run manually
  ./check_openwebui_cloudflare.sh --show-cmds

  # Bypass Cloudflare by resolving to origin IP (replace ORIGIN_IP)
  ./check_openwebui_cloudflare.sh --bypass 10.0.0.5

EOF
}

if [ "${1-}" = "--help" ] || [ "${1-}" = "-h" ]; then
  print_help
  exit 0
fi

SHOW_CMDS=0
BYPASS_IP=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --show-cmds) SHOW_CMDS=1; shift ;;
    --bypass) BYPASS_IP="$2"; shift 2 ;;
    *) echo "Unknown arg: $1"; print_help; exit 2 ;;
  esac
done

echo "Target: $TARGET_URL"

if [ "$SHOW_CMDS" -eq 1 ]; then
  cat <<EOF
# If you have a Cloudflare Access Service Token (recommended for API clients), run:
CF-ACCESS headers:
  Cf-Access-Client-Id: <CF_ACCESS_CLIENT_ID>
  Cf-Access-Client-Secret: <CF_ACCESS_CLIENT_SECRET>

curl example (replace placeholders):
  curl -v \
    -H "Cf-Access-Client-Id: <CF_ACCESS_CLIENT_ID>" \
    -H "Cf-Access-Client-Secret: <CF_ACCESS_CLIENT_SECRET>" \
    "$TARGET_URL"

# To fetch Cloudflare logs or audit (requires CLOUDFLARE API token):
  # List zones and find zone id, then query logs (see Cloudflare docs)

# To bypass Cloudflare and hit origin directly (if you know ORIGIN_IP):
  curl -v --resolve openwebui.simondatalab.de:443:<ORIGIN_IP> "$TARGET_URL"

EOF
  exit 0
fi

if [ -n "$BYPASS_IP" ]; then
  echo "Attempting bypass (resolve to $BYPASS_IP) — this contacts the origin directly if reachable"
  curl -v --max-time 15 --resolve openwebui.simondatalab.de:443:$BYPASS_IP "$TARGET_URL" || true
  exit 0
fi

if [ -n "${CF_ACCESS_CLIENT_ID-}" ] && [ -n "${CF_ACCESS_CLIENT_SECRET-}" ]; then
  echo "Using CF Access service token headers from environment to query the app..."
  curl -v --max-time 15 \
    -H "Cf-Access-Client-Id: $CF_ACCESS_CLIENT_ID" \
    -H "Cf-Access-Client-Secret: $CF_ACCESS_CLIENT_SECRET" \
    "$TARGET_URL" || true
  exit 0
fi

echo "No CF Access service token provided in environment. Running a normal GET to show Cloudflare blocking page..."
curl -v --max-time 15 "$TARGET_URL" || true

echo
echo "Next steps:"
echo " - If you're the Cloudflare admin, create a Cloudflare Access Service Token and run this script with CF_ACCESS_CLIENT_ID/SECRET set."
echo " - Or run with --show-cmds to see the exact curl commands to run manually."
