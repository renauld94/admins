#!/bin/bash
# Quick Reference - Job Search Automation Commands
# Use these commands to monitor and manage your job search system

# ============================================================================
# 🎯 QUICK START COMMANDS
# ============================================================================

# Navigate to toolkit
cd /home/simon/Learning-Management-System-Academy/job-search-toolkit

# Check system status
./monitor_automation.sh

# View live logs
tail -f outputs/logs/agent_20251110.log

# View cron jobs
crontab -l | grep job_search

# ============================================================================
# 🚀 MANUAL EXECUTION (For Testing)
# ============================================================================

# Run daily automation manually
python3 epic_job_search_agent.py daily

# Run weekly automation manually
python3 epic_job_search_agent.py weekly

# Check system status
python3 epic_job_search_agent.py status

# ============================================================================
# 📊 VIEW REPORTS & METRICS
# ============================================================================

# Daily metrics dashboard
python3 job_search_dashboard.py daily

# Weekly metrics dashboard
python3 job_search_dashboard.py weekly

# Full metrics dashboard
python3 job_search_dashboard.py full

# CRM network report
python3 networking_crm.py report

# Pending follow-ups
python3 networking_crm.py pending-followups

# ============================================================================
# 📝 LOG MANAGEMENT
# ============================================================================

# View today's agent logs
tail -f outputs/logs/agent_20251110.log

# View specific component logs
tail -f outputs/logs/job_scorer_20251110.log
tail -f outputs/logs/linkedin_orchestrator_20251110.log
tail -f outputs/logs/crm_20251110.log

# View all logs
ls -lah outputs/logs/

# Search logs for errors
grep ERROR outputs/logs/*.log

# ============================================================================
# ⏰ CRON MANAGEMENT
# ============================================================================

# View cron jobs
crontab -l

# Edit cron jobs
crontab -e

# Check cron service status
sudo systemctl status cron

# View cron execution history
sudo journalctl -u cron -f

# ============================================================================
# 💾 DATABASE MANAGEMENT
# ============================================================================

# List databases
ls -lah data/

# Check database status
sqlite3 data/job_search.db ".tables"

# Count records in job_search table
sqlite3 data/job_search.db "SELECT COUNT(*) FROM jobs;"

# Export jobs to CSV
sqlite3 data/job_search.db ".mode csv" ".output jobs_export.csv" \
  "SELECT * FROM jobs;" ".quit"

# ============================================================================
# 🔧 TROUBLESHOOTING
# ============================================================================

# Check if all components can be imported
python3 -c "
import epic_job_search_agent
import advanced_job_scorer
import networking_crm
print('✅ All components ready')
"

# Test database connectivity
sqlite3 data/job_search.db "SELECT datetime('now');"

# Check Python version
python3 --version

# Verify required dependencies
python3 -c "import requests, bs4, sqlite3; print('✅ Dependencies installed')"

# ============================================================================
# 📅 AUTOMATION SCHEDULE DETAILS
# ============================================================================

# Next daily run: Tomorrow at 07:00 UTC+7
# Next weekly run: This Sunday at 18:00 UTC+7

# Check when next run will occur
date -d "tomorrow 07:00"
date -d "next Sunday 18:00"

# ============================================================================
# 📊 SYSTEM HEALTH CHECK
# ============================================================================

# Full system health check
echo "Python:" && python3 --version
echo "Cron service:" && sudo systemctl is-active cron
echo "Log files:" && ls outputs/logs/*.log | wc -l
echo "Database files:" && ls data/*.db | wc -l
echo "Cron jobs:" && crontab -l | grep -c "job_search"

# ============================================================================
# 🆘 QUICK FIXES
# ============================================================================

# Fix permission issues
chmod 755 outputs/logs
chmod 755 data

# Create missing log directory
mkdir -p outputs/logs

# Restart cron service
sudo systemctl restart cron

# Check if cron is running
sudo systemctl is-active cron

# ============================================================================
# 📞 SUPPORT
# ============================================================================

# Read documentation
cat START_HERE.md
cat EPIC_AGENT_README.md
cat JOB_SEARCH_DEPLOYMENT_STATUS.md

# Check status file
cat JOB_SEARCH_DEPLOYMENT_STATUS.md

# ============================================================================
# NOTES
# ============================================================================

# Default log retention: Recent 16 files
# Database size: 188 KB total (4 databases)
# Max applications per day: 15
# Max LinkedIn connections per day: 30
# Max LinkedIn messages per day: 20

# ============================================================================
