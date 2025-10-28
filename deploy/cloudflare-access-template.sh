#!/usr/bin/env bash
# Cloudflare Access + Service Token template
# Usage:
#   export CF_API_TOKEN="<narrow-scoped-token>"
#   ./deploy/cloudflare-access-template.sh --zone simondatalab.de --app-host openwebui.simondatalab.de --name openwebui-mcp

set -euo pipefail

usage(){ cat <<'EOF'
Usage: $0 --zone ZONE --app-host HOST --name NAME
Creates a Cloudflare Access application and (optionally) a service token for machine access.
This script prints created IDs and the API responses. It does NOT persist secrets.
EOF
}

if [[ ${1:-} == "--help" ]] ; then usage; exit 0; fi

ZONE=""
HOST=""
NAME="openwebui-mcp"

while [[ $# -gt 0 ]]; do
	case "$1" in
		--zone) ZONE="$2"; shift 2;;
		--app-host) HOST="$2"; shift 2;;
		--name) NAME="$2"; shift 2;;
		*) echo "Unknown arg: $1"; usage; exit 1;;
	esac
done

if [[ -z "$ZONE" || -z "$HOST" ]]; then echo "zone and app-host are required"; usage; exit 1; fi

if [[ -z "${CF_API_TOKEN:-}" ]]; then echo "Please export CF_API_TOKEN with a Cloudflare API token"; exit 1; fi

# Lookup zone id
ZONE_ID=$(curl -sS -X GET "https://api.cloudflare.com/client/v4/zones?name=${ZONE}" \
	-H "Authorization: Bearer ${CF_API_TOKEN}" -H "Content-Type: application/json" | jq -r '.result[0].id // empty')

if [[ -z "$ZONE_ID" ]]; then echo "Could not find zone id for ${ZONE}"; exit 1; fi

echo "Zone ID: $ZONE_ID"

# Create Access Application (type required)
# Use type 'self_hosted' for services running on your host
APP_PAYLOAD=$(jq -n --arg name "$NAME" --arg domain "$HOST" '{name: $name, domain: $domain, type: "self_hosted", session_duration: "24h" }')

CREATE_APP_RESPONSE=$(curl -sS -X POST "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/access/apps" \
	-H "Authorization: Bearer ${CF_API_TOKEN}" -H "Content-Type: application/json" \
	--data "$APP_PAYLOAD")

APP_ID=$(echo "$CREATE_APP_RESPONSE" | jq -r '.result.id // empty')
if [[ -z "$APP_ID" ]]; then echo "Failed to create Access app:"; echo "$CREATE_APP_RESPONSE" | jq .; exit 1; fi

echo "Created Access App ID: $APP_ID"

echo "Full create app response:"; echo "$CREATE_APP_RESPONSE" | jq .

# Attempt to create a service token - requires Account ID
ACCOUNT_ID=$(curl -sS -X GET "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}" \
	-H "Authorization: Bearer ${CF_API_TOKEN}" -H "Content-Type: application/json" | jq -r '.result[0].account.id // empty')

if [[ -n "$ACCOUNT_ID" ]]; then
	echo "Account ID: $ACCOUNT_ID"
	SERVICE_TOKEN_NAME="${NAME}-service-token"
	TOKEN_PAYLOAD=$(jq -n --arg name "$SERVICE_TOKEN_NAME" '{name: $name, policies: []}')
	CREATE_TOKEN_RESPONSE=$(curl -sS -X POST "https://api.cloudflare.com/client/v4/accounts/${ACCOUNT_ID}/access/service_tokens" \
		-H "Authorization: Bearer ${CF_API_TOKEN}" -H "Content-Type: application/json" --data "$TOKEN_PAYLOAD")
	echo "Create service token response:"; echo "$CREATE_TOKEN_RESPONSE" | jq .
else
	echo "Could not determine Account ID for zone ${ZONE_ID}; skipping service token creation. You may need account-level permissions or to use org endpoints."
fi

echo "Script complete. Please copy any IDs you need and revoke the API token if it had broader scopes than necessary."