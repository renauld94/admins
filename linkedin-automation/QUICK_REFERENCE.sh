#!/bin/bash
# Quick Reference - Universal CRM System
# Copy-paste commands for daily use

echo "=================================================================="
echo "🎯 UNIVERSAL CRM - QUICK REFERENCE"
echo "=================================================================="
echo ""

cat << 'EOF'
# ============================================================================
# SETUP (One-time)
# ============================================================================

# Complete automated setup (recommended)
./run-complete-setup.sh

# Or manual setup
./setup-crm-database.sh
python3 -m playwright install chromium

# ============================================================================
# DAILY LEAD GENERATION
# ============================================================================

# Find new leads (automatic CRM import)
./search-leads.sh

# Batch search with specific parameters
python3 batch_lead_search.py --quick --locations Vietnam Canada Singapore
python3 batch_lead_search.py --locations Vietnam --roles "Head of Data" "CTO"

# ============================================================================
# CRM OPERATIONS
# ============================================================================

# View dashboard
python3 crm_database.py dashboard

# Import leads manually
python3 crm_database.py import-leads outputs/batch_searches/<file>.json

# Import Moodle data
python3 crm_database.py import-moodle

# Add test data
python3 crm_database.py test

# ============================================================================
# LEAD OUTREACH
# ============================================================================

# View lead pipeline
python3 lead_generation_engine.py pipeline

# Generate outreach messages
python3 lead_generation_engine.py outreach <lead_id> connection
python3 lead_generation_engine.py outreach <lead_id> inmail
python3 lead_generation_engine.py outreach <lead_id> email

# ============================================================================
# DATABASE QUERIES
# ============================================================================

# Connect to database
psql universal_crm

# View active leads
psql universal_crm -c "SELECT * FROM active_leads_view LIMIT 20;"

# High-fit leads (score >= 8)
psql universal_crm -c "
SELECT p.full_name, p.job_title, o.name as company, l.fit_score
FROM leads l
JOIN people p ON l.person_id = p.id
JOIN organizations o ON l.organization_id = o.id
WHERE l.fit_score >= 8 AND l.lead_status = 'new'
ORDER BY l.fit_score DESC;
"

# Follow-up needed
psql universal_crm -c "
SELECT p.full_name, o.name, p.last_contact_date,
       NOW() - p.last_contact_date as days_since_contact
FROM people p
JOIN organizations o ON p.organization_id = o.id
WHERE p.relationship_stage IN ('warm', 'engaged')
  AND p.last_contact_date < NOW() - INTERVAL '14 days'
ORDER BY days_since_contact DESC;
"

# Job applications status
psql universal_crm -c "SELECT * FROM active_applications_view;"

# Client summary
psql universal_crm -c "SELECT * FROM client_summary_view;"

# ============================================================================
# TRACKING ACTIVITIES
# ============================================================================

# Track job application (Python interactive)
python3 -c "
from crm_database import UniversalCRM
crm = UniversalCRM()
crm.connect()
crm.track_job_application({
    'company': 'Example Corp',
    'title': 'Senior Data Engineer',
    'location': 'Remote',
    'url': 'https://example.com/jobs/123',
    'salary_min': 120000,
    'salary_max': 160000
})
crm.close()
"

# Add consulting project
python3 -c "
from crm_database import UniversalCRM
crm = UniversalCRM()
crm.connect()
crm.add_consulting_project({
    'client_name': 'HealthTech Inc',
    'project_name': 'MLOps Platform',
    'project_type': 'mlops',
    'contract_value': 75000
})
crm.close()
"

# Log interaction
python3 -c "
from crm_database import UniversalCRM
crm = UniversalCRM()
crm.connect()
crm.log_interaction({
    'person_id': 1,  # From database
    'interaction_type': 'email',
    'direction': 'outbound',
    'subject': 'Follow up on proposal',
    'notes': 'Sent updated proposal with timeline',
    'outcome': 'positive'
})
crm.close()
"

# ============================================================================
# DATABASE MAINTENANCE
# ============================================================================

# Backup database
pg_dump universal_crm > backup_$(date +%Y%m%d).sql

# Restore database
psql universal_crm < backup_20251104.sql

# List all tables
psql universal_crm -c "\dt"

# Describe table structure
psql universal_crm -c "\d+ organizations"
psql universal_crm -c "\d+ people"
psql universal_crm -c "\d+ leads"

# Check database size
psql universal_crm -c "
SELECT pg_size_pretty(pg_database_size('universal_crm')) as size;
"

# Count records in each table
psql universal_crm -c "
SELECT 
    schemaname,
    tablename,
    n_tup_ins as inserts,
    n_tup_upd as updates,
    n_live_tup as current_rows
FROM pg_stat_user_tables
ORDER BY n_live_tup DESC;
"

# ============================================================================
# USEFUL SQL QUERIES
# ============================================================================

# Top 10 organizations by contact count
psql universal_crm -c "
SELECT o.name, COUNT(DISTINCT p.id) as contacts
FROM organizations o
LEFT JOIN people p ON o.id = p.organization_id
GROUP BY o.name
ORDER BY contacts DESC
LIMIT 10;
"

# Lead conversion rate
psql universal_crm -c "
SELECT 
    lead_status,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentage
FROM leads
GROUP BY lead_status
ORDER BY count DESC;
"

# Revenue by industry
psql universal_crm -c "
SELECT 
    o.industry,
    COUNT(DISTINCT cp.id) as projects,
    SUM(cp.contract_value) as total_revenue
FROM organizations o
JOIN consulting_projects cp ON o.id = cp.organization_id
GROUP BY o.industry
ORDER BY total_revenue DESC NULLS LAST;
"

# Moodle engagement by organization
psql universal_crm -c "
SELECT 
    o.name,
    COUNT(DISTINCT me.person_id) as students,
    COUNT(DISTINCT me.course_id) as courses,
    AVG(me.progress_percentage) as avg_progress
FROM organizations o
JOIN moodle_enrollments me ON o.id = me.organization_id
GROUP BY o.name
ORDER BY students DESC;
"

# Infrastructure services by client
psql universal_crm -c "
SELECT 
    o.name as client,
    COUNT(DISTINCT is.id) as services,
    string_agg(DISTINCT is.service_type, ', ') as types
FROM organizations o
JOIN infrastructure_services is ON o.id = is.organization_id
WHERE is.status = 'active'
GROUP BY o.name
ORDER BY services DESC;
"

# ============================================================================
# MONITORING & ANALYTICS
# ============================================================================

# Weekly activity summary
psql universal_crm -c "
SELECT 
    DATE(metric_date) as date,
    new_leads_count,
    outreach_sent_count,
    responses_received_count,
    applications_submitted,
    opportunities_created
FROM daily_metrics
WHERE metric_date >= NOW() - INTERVAL '7 days'
ORDER BY metric_date DESC;
"

# Response rate analysis
psql universal_crm -c "
SELECT 
    DATE_TRUNC('week', sent_date) as week,
    COUNT(*) as messages_sent,
    SUM(CASE WHEN replied THEN 1 ELSE 0 END) as replies,
    ROUND(SUM(CASE WHEN replied THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as response_rate
FROM outreach_messages
WHERE sent_date >= NOW() - INTERVAL '3 months'
GROUP BY DATE_TRUNC('week', sent_date)
ORDER BY week DESC;
"

# ============================================================================
# FILES & DOCUMENTATION
# ============================================================================

# View complete guide
cat CRM_DATABASE_GUIDE.md | less

# View system summary
cat SYSTEM_SUMMARY.md | less

# View lead generation guide
cat START_HERE_LEADS.md | less

# View database schema
cat database/schema.sql | less

# Check latest lead search results
ls -lht outputs/batch_searches/

# View latest high-fit leads
cat outputs/batch_searches/*_high_fit.json | jq '.[0:10]'

EOF

echo ""
echo "=================================================================="
echo "Copy any command above and paste into your terminal!"
echo "=================================================================="
