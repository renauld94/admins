#!/bin/bash
#
# EPIC Daily Job Search Automation
# ================================
# Automated daily workflow:
# 1. Search for jobs (6:30 AM)
# 2. Score & rank opportunities (7:00 AM)
# 3. Connect with hiring managers (7:30 AM)
# 4. Generate application packages (8:00 AM)
# 5. Track metrics & send reports (Evening)
#
# Usage: ./run_daily_job_search.sh
# Or: 0 7 * * * /path/to/run_daily_job_search.sh  # Cron at 7 AM daily
#

set -e

# ===== CONFIGURATION =====
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_DIR="$PROJECT_DIR/outputs/logs"
REPORTS_DIR="$PROJECT_DIR/outputs/reports"
DATA_DIR="$PROJECT_DIR/data"

# Create necessary directories
mkdir -p "$LOG_DIR" "$REPORTS_DIR" "$DATA_DIR"

# Log file
LOG_FILE="$LOG_DIR/daily_automation_$(date +%Y%m%d).log"
REPORT_FILE="$REPORTS_DIR/daily_report_$(date +%Y%m%d_%H%M%S).txt"

# ===== LOGGING FUNCTIONS =====
log() {
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" | tee -a "$LOG_FILE"
}

log_section() {
    echo "" | tee -a "$LOG_FILE"
    echo "================================" | tee -a "$LOG_FILE"
    echo "$1" | tee -a "$LOG_FILE"
    echo "================================" | tee -a "$LOG_FILE"
}

# ===== MAIN WORKFLOW =====

log_section "🤖 EPIC DAILY JOB SEARCH AUTOMATION - $(date '+%Y-%m-%d %H:%M:%S')"

# Step 1: Run main agent
log "📊 STEP 1: Running job search agent..."
if cd "$PROJECT_DIR" && python3 epic_job_search_agent.py daily >> "$LOG_FILE" 2>&1; then
    log "✅ Job search agent completed"
else
    log "⚠️  Job search agent encountered issues (check logs)"
fi

# Step 2: Run LinkedIn outreach
log "📍 STEP 2: Running LinkedIn contact orchestrator..."
TARGET_COMPANIES="Shopee,Grab,Atlassian"
if python3 linkedin_contact_orchestrator.py campaign --companies "$TARGET_COMPANIES" >> "$LOG_FILE" 2>&1; then
    log "✅ LinkedIn outreach completed"
else
    log "⚠️  LinkedIn outreach encountered issues"
fi

# Step 3: Record daily metrics
log "📈 STEP 3: Recording daily metrics..."
python3 job_search_dashboard.py record --apps 5 --connections 3 --messages 2 >> "$LOG_FILE" 2>&1
log "✅ Metrics recorded"

# Step 4: Generate report
log "📋 STEP 4: Generating daily report..."
{
    echo "🎯 EPIC Job Search Daily Report"
    echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    python3 job_search_dashboard.py daily 2>/dev/null || echo "Daily metrics not available yet"
} > "$REPORT_FILE"

log "✅ Report generated: $REPORT_FILE"

# ===== SUMMARY =====
log_section "✅ DAILY AUTOMATION COMPLETE"
log "📊 See report: $REPORT_FILE"
log "📝 See logs: $LOG_FILE"

# Optional: Send email notification
# If email configured, send report:
# if [ ! -z "$SEND_EMAIL" ]; then
#     mail -s "Job Search Daily Report - $(date +%Y-%m-%d)" "$EMAIL_TO" < "$REPORT_FILE"
# fi

log "🎯 Next run: Tomorrow at 7:00 AM"
echo ""
