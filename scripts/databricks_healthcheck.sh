#!/usr/bin/env bash
set -euo pipefail

# Databricks Workspace Healthcheck
# Verifies env-based auth to a Databricks workspace and basic visibility of the Academy path.
# - Uses: DATABRICKS_URL, DATABRICKS_TOKEN, optional X-Databricks-Org-Id (ORG_ID)
# - Checks:
#   1) List academy folder
#   2) Check status of one representative notebook
#   3) (Optional) SCIM Me identity if available (best-effort)

# Usage:
#   export DATABRICKS_URL="https://<your-workspace-host>"
#   export DATABRICKS_TOKEN="<your-pat>"
#   export ORG_ID="<org-id>"   # Required for E2 workspaces
#   ./scripts/databricks_healthcheck.sh

WORKSPACE_PATH="/Workspace/Shared/J&J_Academy/J&J_Python_Academy"
CHECK_NOTEBOOK_PATH="$WORKSPACE_PATH/module-05-databricks/session-5.04-Running Notebooks/assignment.ipynb"

red() { printf "\033[31m%s\033[0m\n" "$*"; }
green() { printf "\033[32m%s\033[0m\n" "$*"; }
yellow() { printf "\033[33m%s\033[0m\n" "$*"; }

require_env() {
  local name="$1"; local val="${!name:-}";
  if [[ -z "$val" ]]; then
    red "Missing required env var: $name"
    exit 1
  fi
}

require_env DATABRICKS_URL
require_env DATABRICKS_TOKEN

# Headers
AUTH_HEADER=("-H" "Authorization: Bearer $DATABRICKS_TOKEN")
ORG_HEADER=()
if [[ -n "${ORG_ID:-}" ]]; then
  ORG_HEADER=("-H" "X-Databricks-Org-Id: $ORG_ID")
else
  yellow "ORG_ID not set; if your workspace requires it, requests may fail with 401."
fi

jq_check() {
  if ! command -v jq >/dev/null 2>&1; then
    yellow "jq not found. Install jq for prettier output. Proceeding without jq."
    return 1
  fi
  return 0
}

pass() { green "PASS: $*"; }
fail() { red "FAIL: $*"; exit 1; }
info() { echo "➤ $*"; }

# 1) List academy folder
info "Listing $WORKSPACE_PATH"
LIST_OUT=$(curl -sS -m 15 -G "${AUTH_HEADER[@]}" "${ORG_HEADER[@]}" \
  --data-urlencode "path=$WORKSPACE_PATH" \
  "$DATABRICKS_URL/api/2.0/workspace/list" || true)

if echo "$LIST_OUT" | grep -q '"objects"'; then
  pass "workspace/list succeeded"
  jq_check && echo "$LIST_OUT" | jq -r '.objects[] | "- \(.object_type) \(.path)"'
else
  echo "$LIST_OUT"
  fail "workspace/list did not return objects"
fi

# 2) Check one notebook status
info "Checking status of representative notebook: $CHECK_NOTEBOOK_PATH"
STATUS_OUT=$(curl -sS -m 15 -G "${AUTH_HEADER[@]}" "${ORG_HEADER[@]}" \
  --data-urlencode "path=$CHECK_NOTEBOOK_PATH" \
  "$DATABRICKS_URL/api/2.0/workspace/get-status" || true)

if echo "$STATUS_OUT" | grep -q 'object_type'; then
  TYPE=$(echo "$STATUS_OUT" | sed -n 's/.*"object_type"\s*:\s*"\([^"]*\)".*/\1/p')
  case "$TYPE" in
    NOTEBOOK|DIRECTORY|FILE)
      pass "get-status succeeded: object_type=$TYPE"
      ;;
    *)
      yellow "get-status returned object_type=$TYPE"
      ;;
  esac
  jq_check && echo "$STATUS_OUT" | jq -r '.'
else
  echo "$STATUS_OUT"
  fail "workspace/get-status failed for $CHECK_NOTEBOOK_PATH"
fi

# 3) Optional identity check via SCIM Me (best-effort; endpoint may vary)
info "Attempting SCIM Me identity check (best-effort)"
SCIM_OUT=$(curl -sS -m 10 "${AUTH_HEADER[@]}" "${ORG_HEADER[@]}" \
  -H "Accept: application/scim+json" \
  "$DATABRICKS_URL/api/2.0/preview/scim/v2/Me" || true)
if echo "$SCIM_OUT" | grep -q 'userName\|displayName\|id'; then
  pass "SCIM Me succeeded"
  jq_check && echo "$SCIM_OUT" | jq -r '{id, userName, displayName}'
else
  yellow "SCIM Me not available on this workspace or insufficient scope; skipping."
fi

info "Healthcheck completed."
