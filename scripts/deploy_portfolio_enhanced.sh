#!/usr/bin/env bash
set -euo pipefail

# Deploy Enhanced Portfolio to www.simondatalab.de
# - Creates a timestamped backup on the server
# - Rsyncs local 'portfolio-deployment-enhanced' to /var/www/html
# - Preserves permissions and excludes dev artifacts
# - Supports optional SSH jump host
#
# Usage:
#   ./scripts/deploy_portfolio_enhanced.sh [--dry-run]
#
# Env overrides:
#   SERVER_USER=root
#   SERVER_HOST=136.243.155.166
#   SERVER_PATH=/var/www/html
#   JUMP_HOST="root@136.243.155.166:2222"  # optional (ProxyJump)
#   LOCAL_DIR=/home/simon/Learning-Management-System-Academy/portfolio-deployment-enhanced

DRY_RUN=false
if [[ ${1:-} == "--dry-run" ]]; then
  DRY_RUN=true
fi

# Defaults
SERVER_USER="${SERVER_USER:-root}"
SERVER_HOST="${SERVER_HOST:-10.0.0.150}"
SERVER_PATH="${SERVER_PATH:-/var/www/html}"
LOCAL_DIR="${LOCAL_DIR:-/home/simon/Learning-Management-System-Academy/portfolio-deployment-enhanced}"
JUMP_HOST="${JUMP_HOST:-}"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
info()  { echo -e "${BLUE}ℹ️  $*${NC}"; }
ok()    { echo -e "${GREEN}✅ $*${NC}"; }
warn()  { echo -e "${YELLOW}⚠️  $*${NC}"; }
fail()  { echo -e "${RED}❌ $*${NC}"; exit 1; }

# Validations
[[ -d "$LOCAL_DIR" ]] || fail "Local directory not found: $LOCAL_DIR"
[[ -f "$LOCAL_DIR/index.html" ]] || fail "index.html missing in $LOCAL_DIR"

SSH_ARGS=("-o" "BatchMode=yes" "-o" "ConnectTimeout=10")
if [[ -n "$JUMP_HOST" ]]; then
  SSH_ARGS+=("-J" "$JUMP_HOST")
fi
RSYNC_SSH="ssh ${SSH_ARGS[*]}"

REMOTE="$SERVER_USER@$SERVER_HOST"

info "Target: $REMOTE:$SERVER_PATH"
info "Source: $LOCAL_DIR"
$DRY_RUN && warn "DRY RUN ONLY - no changes will be made"

# Check connectivity
info "Testing SSH connectivity..."
if ! ssh "${SSH_ARGS[@]}" "$REMOTE" "echo ok" >/dev/null 2>&1; then
  fail "SSH connection failed to $REMOTE. Configure SSH keys or JUMP_HOST."
fi
ok "SSH connectivity verified"

# Create backup
TS=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/var/backups/portfolio/$TS"
info "Creating server backup at $BACKUP_DIR"
CMD_BACKUP="mkdir -p $BACKUP_DIR && cp -r $SERVER_PATH/* $BACKUP_DIR/ 2>/dev/null || true"
$DRY_RUN || ssh "${SSH_ARGS[@]}" "$REMOTE" "$CMD_BACKUP"
ok "Backup step complete"

# Rsync upload
info "Syncing files via rsync..."
RSYNC_FLAGS=("-avz" "--delete" "--progress" \
  "--exclude=.git" "--exclude=node_modules" "--exclude=.DS_Store" "--exclude=*.log")

if $DRY_RUN; then
  rsync -n "${RSYNC_FLAGS[@]}" -e "$RSYNC_SSH" "$LOCAL_DIR/" "$REMOTE:$SERVER_PATH/"
else
  rsync "${RSYNC_FLAGS[@]}" -e "$RSYNC_SSH" "$LOCAL_DIR/" "$REMOTE:$SERVER_PATH/"
fi
ok "Files synced"

# Permissions
info "Setting permissions..."
PERM_CMD="chown -R www-data:www-data $SERVER_PATH && find $SERVER_PATH -type d -exec chmod 755 {} \; && find $SERVER_PATH -type f -exec chmod 644 {} \;"
$DRY_RUN || ssh "${SSH_ARGS[@]}" "$REMOTE" "$PERM_CMD"
ok "Permissions set"

# Reload web server
info "Reloading web services (nginx/apache)..."
RELOAD_CMD="systemctl reload nginx 2>/dev/null || systemctl restart apache2 2>/dev/null || true"
$DRY_RUN || ssh "${SSH_ARGS[@]}" "$REMOTE" "$RELOAD_CMD"
ok "Web services reloaded"

# Health check
info "Performing health check..."
URLS=("http://$SERVER_HOST" "https://www.simondatalab.de/")
for u in "${URLS[@]}"; do
  if $DRY_RUN; then
    echo "[DRY-RUN] Would check $u"
  else
    CODE=$(curl -k -s -o /dev/null -w "%{http_code}" "$u" || true)
    echo "  $u -> $CODE"
  fi
done

ok "Deployment complete"
info "Backups: $BACKUP_DIR"
