#!/bin/bash

#######################################################################
# PHASE 2: ROLLBACK DEPLOYMENT SCRIPT
# Emergency rollback for WMS implementation issues
#
# Date: November 10, 2025
# Usage: ./rollback-deployment.sh [commit-hash]
#######################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

GIT_REPO="/home/simon/Learning-Management-System-Academy"
ROLLBACK_LOG="rollback-$(date +%Y%m%d_%H%M%S).log"

#######################################################################
# FUNCTIONS
#######################################################################

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_action() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$ROLLBACK_LOG"
}

#######################################################################
# MAIN ROLLBACK LOGIC
#######################################################################

main() {
    print_header "⚠️  PHASE 2: EMERGENCY ROLLBACK SCRIPT"
    print_warning "WARNING: This script will revert WMS deployment changes"
    print_info "Started at: $(date '+%Y-%m-%d %H:%M:%S')"
    print_info "Log file: $ROLLBACK_LOG"
    
    log_action "Rollback script started"
    
    # Check git repository
    if [ ! -d "$GIT_REPO/.git" ]; then
        print_error "Git repository not found"
        exit 1
    fi
    
    cd "$GIT_REPO"
    
    # Get current commit info
    print_info "Current repository status:"
    print_info "Branch: $(git branch --show-current)"
    print_info "Commit: $(git log -1 --oneline)"
    
    # Determine which commit to revert to
    local target_commit="${1:-}"
    
    if [ -z "$target_commit" ]; then
        # Show recent commits and ask which to revert to
        print_info "Recent commits:"
        git log --oneline -10
        
        print_warning "Available rollback options:"
        print_info "1. Revert last commit (WMS deployment)"
        print_info "2. Revert to specific commit (enter commit hash)"
        print_info "3. Cancel rollback (Ctrl+C)"
        
        read -p "Enter commit hash to rollback to (or press Enter for last commit): " -r target_commit
        
        if [ -z "$target_commit" ]; then
            # Revert last commit
            target_commit="HEAD~1"
            print_info "Will revert to: $(git log -1 --oneline $target_commit)"
        fi
    fi
    
    # Confirm rollback
    print_warning "FINAL CONFIRMATION REQUIRED"
    print_info "This will revert to: $(git log -1 --oneline $target_commit)"
    read -p "Are you absolutely sure? Type 'YES' to confirm: " -r confirmation
    
    if [ "$confirmation" != "YES" ]; then
        print_error "Rollback cancelled"
        log_action "Rollback cancelled by user"
        exit 1
    fi
    
    # Perform rollback
    print_info "Reverting changes..."
    git revert --no-edit $(git log --oneline | head -1 | cut -d' ' -f1) 2>&1 | tee -a "$ROLLBACK_LOG"
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        print_success "Revert commit created"
        log_action "Revert commit created successfully"
    else
        print_error "Failed to create revert commit"
        log_action "Failed to create revert commit"
        
        # Offer manual rollback
        print_warning "Manual rollback options:"
        print_info "1. git reset --hard <commit-hash>"
        print_info "2. git rebase -i HEAD~2"
        
        exit 1
    fi
    
    # Push rollback
    print_info "Pushing rollback to main branch..."
    git push origin main 2>&1 | tee -a "$ROLLBACK_LOG"
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        print_success "Rollback pushed to main"
        log_action "Rollback successfully pushed to main"
    else
        print_error "Failed to push rollback"
        log_action "Failed to push rollback"
        
        print_warning "Manual push required:"
        print_info "Run: git push origin main --force"
        exit 1
    fi
    
    # Create rollback summary
    print_header "ROLLBACK SUMMARY"
    print_success "Rollback completed successfully"
    print_info "GitHub Actions will automatically redeploy"
    print_info "Monitor deployment at: https://github.com/renauld94/admins/actions"
    
    # Next steps
    print_header "POST-ROLLBACK STEPS"
    print_info "1. Monitor GitHub Actions for deployment completion"
    print_info "2. Verify production is stable"
    print_info "3. Review rollback log: $ROLLBACK_LOG"
    print_info "4. Investigate WMS issues:"
    print_info "   - Check PHASE_2_WMS_TESTING_GUIDE.md for diagnostics"
    print_info "   - Verify Geoserver connectivity"
    print_info "   - Check browser console for errors"
    print_info "   - Review PHASE_2_DEPLOYMENT_VALIDATION.md"
    print_info "5. Fix issues and redeploy"
    
    log_action "Rollback script completed successfully"
}

main "$@"
