#!/bin/bash
# CSS Production Deployment Script
# Vietnamese Language Course - Moodle 10
# Generated: 2025-11-09
# WARNING: This script modifies production files. Review before executing.

set -e  # Exit on error

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  CSS PRODUCTION DEPLOYMENT - Vietnamese Course Design System  ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Configuration
SOURCE_CSS="/home/simon/Learning-Management-System-Academy/staging/moodle_visual_style.css"
PRODUCTION_CSS="/var/www/moodle/theme/boost/css/vietnamese_course.css"
BACKUP_DIR="/var/www/moodle/theme/boost/css/backups"
CONFIG_FILE="/var/www/moodle/theme/boost/config.php"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Pre-deployment checks
echo "Step 1: Pre-Deployment Checks"
echo "================================"

if [ ! -f "$SOURCE_CSS" ]; then
    log_error "Source CSS file not found: $SOURCE_CSS"
    exit 1
fi
log_info "Source CSS file exists"

if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    log_info "Created backup directory: $BACKUP_DIR"
fi

# Backup existing CSS
echo ""
echo "Step 2: Backup Existing CSS"
echo "=============================="
if [ -f "$PRODUCTION_CSS" ]; then
    cp "$PRODUCTION_CSS" "$BACKUP_DIR/vietnamese_course.css.$TIMESTAMP.backup"
    log_info "Backed up existing CSS to: $BACKUP_DIR/vietnamese_course.css.$TIMESTAMP.backup"
else
    log_warning "No existing CSS found at $PRODUCTION_CSS"
fi

# Copy CSS to production
echo ""
echo "Step 3: Deploy CSS to Production"
echo "===================================="
cp "$SOURCE_CSS" "$PRODUCTION_CSS"
log_info "Copied CSS to: $PRODUCTION_CSS"

# Set permissions
chmod 644 "$PRODUCTION_CSS"
log_info "Set permissions to 644"

# Update Moodle config
echo ""
echo "Step 4: Update Moodle Configuration"
echo "====================================="
if grep -q "vietnamese_course" "$CONFIG_FILE"; then
    log_info "CSS already referenced in config.php"
else
    log_warning "Ensure config.php includes: \$THEME->sheets = array('vietnamese_course');"
    log_warning "MANUAL STEP REQUIRED: Add to /var/www/moodle/theme/boost/config.php"
fi

# Clear Moodle caches
echo ""
echo "Step 5: Clear Moodle Caches"
echo "=============================="
if command -v php &> /dev/null; then
    cd /var/www/moodle
    php admin/cli/purge_caches.php
    log_info "Caches cleared"
else
    log_warning "PHP not found. Caches must be cleared manually or via Moodle admin panel"
fi

# Verification
echo ""
echo "Step 6: Verify Deployment"
echo "=========================="
if [ -f "$PRODUCTION_CSS" ]; then
    CSS_SIZE=$(wc -c < "$PRODUCTION_CSS")
    log_info "CSS file deployed (Size: $CSS_SIZE bytes)"
    
    # Check for colors
    if grep -q "E8423C" "$PRODUCTION_CSS"; then
        log_info "Vietnamese Red color found ✓"
    fi
    if grep -q "C4A73C" "$PRODUCTION_CSS"; then
        log_info "Heritage Gold color found ✓"
    fi
    if grep -q "1A3A52" "$PRODUCTION_CSS"; then
        log_info "Professional Blue color found ✓"
    fi
    if grep -q "7BA68F" "$PRODUCTION_CSS"; then
        log_info "Heritage Green color found ✓"
    fi
else
    log_error "CSS file not deployed!"
    exit 1
fi

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                   ✅ DEPLOYMENT COMPLETE                      ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "NEXT STEPS:"
echo "  1. Navigate to: https://moodle.local/course/view.php?id=10"
echo "  2. Verify Vietnamese colors displayed correctly"
echo "  3. Test responsive design on mobile/tablet"
echo "  4. Run QA verification checklist"
echo "  5. Get stakeholder approval"
echo ""
echo "ROLLBACK (if needed):"
echo "  cp $BACKUP_DIR/vietnamese_course.css.$TIMESTAMP.backup $PRODUCTION_CSS"
echo "  php /var/www/moodle/admin/cli/purge_caches.php"
echo ""
