#!/bin/bash
#
# EPIC Weekly Job Search Analysis
# ================================
# Weekly workflow:
# 1. Analyze metrics
# 2. Review pending follow-ups
# 3. Generate insights
# 4. Update CRM
# 5. Generate comprehensive report
#
# Usage: ./run_weekly_job_search.sh
# Or: 0 18 * * 0 /path/to/run_weekly_job_search.sh  # Cron at 6 PM Sunday
#

set -e

# ===== CONFIGURATION =====
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_DIR="$PROJECT_DIR/outputs/logs"
REPORTS_DIR="$PROJECT_DIR/outputs/reports"

mkdir -p "$LOG_DIR" "$REPORTS_DIR"

LOG_FILE="$LOG_DIR/weekly_automation_$(date +%Y%W).log"
REPORT_FILE="$REPORTS_DIR/weekly_report_$(date +%Y%m%d_%H%M%S).txt"

# ===== LOGGING =====
log() {
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" | tee -a "$LOG_FILE"
}

log_section() {
    echo "" | tee -a "$LOG_FILE"
    echo "╔════════════════════════════════╗" | tee -a "$LOG_FILE"
    echo "║ $1" | tee -a "$LOG_FILE"
    echo "╚════════════════════════════════╝" | tee -a "$LOG_FILE"
}

# ===== MAIN WORKFLOW =====

log_section "EPIC WEEKLY JOB SEARCH ANALYSIS"

# Step 1: Run main agent weekly workflow
log "🤖 Running weekly agent workflow..."
if cd "$PROJECT_DIR" && python3 epic_job_search_agent.py weekly >> "$LOG_FILE" 2>&1; then
    log "✅ Weekly workflow completed"
else
    log "⚠️  Weekly workflow encountered issues"
fi

# Step 2: CRM follow-ups
log "🤝 Processing CRM follow-ups..."
python3 networking_crm.py pending-followups >> "$LOG_FILE" 2>&1 || true
log "✅ CRM updated"

# Step 3: Generate analytics report
log "📊 Generating comprehensive analytics..."
{
    echo "📊 EPIC JOB SEARCH WEEKLY REPORT"
    echo "Week of: $(date -d 'last monday' '+%Y-%m-%d')"
    echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    echo "═══════════════════════════════════════════════════"
    python3 job_search_dashboard.py full 2>/dev/null || echo "Dashboard not available"
    echo "═══════════════════════════════════════════════════"
    echo ""
    echo "Next run: $(date -d 'next sunday 18:00' '+%Y-%m-%d %H:%M')"
} > "$REPORT_FILE"

log "✅ Report saved: $REPORT_FILE"

# Step 4: Print report to console
log "📋 WEEKLY SUMMARY:"
cat "$REPORT_FILE" | tail -30

# ===== COMPLETION =====
log_section "✅ WEEKLY ANALYSIS COMPLETE"
log "📝 Full report: $REPORT_FILE"
log "📊 For daily updates, run: python3 job_search_dashboard.py daily"

echo ""
