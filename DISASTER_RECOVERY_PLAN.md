# EPIC Geodashboard — Disaster Recovery Plan

**Document Version:** 1.0  
**Last Updated:** November 9, 2025  
**Effective Date:** November 15, 2025  
**Classification:** Internal - Operational  
**Review Frequency:** Quarterly  

---

## Executive Summary

This document outlines the complete disaster recovery (DR) procedures for the EPIC Geodashboard production system. The plan ensures rapid recovery from various failure scenarios with minimal data loss and acceptable downtime targets.

**Recovery Time Objectives (RTO)**

| Scenario | RTO Target | Actual Capability |
|----------|-----------|-------------------|
| Backend Service Failure | 5 minutes | 2-5 minutes |
| Data Corruption | 30 minutes | 15-30 minutes |
| Regional Outage | 30 minutes | 20-30 minutes |
| Complete Data Loss | 4 hours | 2-4 hours |
| Database Failure | 15 minutes | 10-15 minutes |

**Recovery Point Objectives (RPO)**

| Data Type | RPO Target | Current |
|-----------|-----------|---------|
| Application Code | 1 hour | Git commits (hourly or on-demand) |
| Configuration | 1 hour | Versioned in git (.env tracked separately) |
| User Data | 24 hours | Daily backups at 2:00 AM UTC |
| Monitoring Data | 7 days | 200h Prometheus retention |
| Database | 24 hours | Daily automated backups |

---

## Table of Contents

1. [Disaster Scenarios](#disaster-scenarios)
2. [Backup Strategy](#backup-strategy)
3. [Recovery Procedures](#recovery-procedures)
4. [Failover Plan](#failover-plan)
5. [Testing & Validation](#testing--validation)
6. [Communication Protocol](#communication-protocol)
7. [Post-Incident Review](#post-incident-review)

---

## Disaster Scenarios

### Scenario 1: Backend Service Crashed

**Severity**: High (users cannot access API)  
**Detection Time**: < 1 minute (automated alerts)  
**RTO**: 5 minutes  
**RPO**: None (stateless service)

**Root Causes**
- Memory exhaustion (OOM kill)
- Unhandled exception in code
- Corrupted configuration file
- Disk full preventing logging

**Prevention**
- Memory limits: 2GB per worker
- Error handling in all endpoints
- Configuration validation on startup
- Disk space monitoring with alerts

**Recovery Steps**

```bash
# 1. Immediate action (< 1 minute)
ssh ubuntu@<prod-ip>

# 2. Check service status
sudo systemctl status epic-geodashboard
# If: "inactive (dead)" → proceed to step 3
# If: "active (running)" but unhealthy → skip to step 4

# 3. Restart service (if dead)
sudo systemctl restart epic-geodashboard
sleep 5

# 4. Verify recovery
curl -I https://<domain>/api/health
# Expected: HTTP 200 within 5 seconds

# 5. If still not responding, check logs
sudo journalctl -u epic-geodashboard -n 100 -p err

# 6. If errors indicate corruption, deploy from clean code
cd /opt/epic-geodashboard
git fetch origin main
git checkout origin/main -- backend/
sudo systemctl restart epic-geodashboard
```

**Validation Checklist**
- [ ] Service running: `systemctl is-active epic-geodashboard` → active
- [ ] API responding: `curl /api/health` → HTTP 200
- [ ] No errors in logs: `journalctl -u epic-geodashboard -p err | wc -l` → 0
- [ ] Response time < 100ms: `time curl /api/health`
- [ ] Monitor for 2 minutes: `watch -n 5 "systemctl status epic-geodashboard"`

**Rollback to Previous Version** (if new deployment caused issue)

```bash
# 1. Identify last known good commit
git log --oneline | head -5

# 2. Checkout previous version
git checkout <previous-commit-hash> -- backend/

# 3. Restart service
sudo systemctl restart epic-geodashboard

# 4. Verify
curl https://<domain>/api/health
```

**Escalation**
- If RTO exceeded: Failover to secondary backend instance
- If data corruption suspected: Restore from backup (Scenario 3)
- If repeated failures: Incident review required within 2 hours

---

### Scenario 2: Database Failure (PostgreSQL)

**Severity**: Critical (no data writes)  
**Detection Time**: < 1 minute  
**RTO**: 15 minutes  
**RPO**: 24 hours (latest backup)

**Root Causes**
- Database daemon crash
- Corrupted database files
- Connection pool exhaustion
- Out of disk space on database partition

**Prevention**
- Connection pooling (PgBouncer)
- Automatic failover to read replica
- Daily automated backups
- Disk space alerts (> 80%)

**Detection**

```bash
# Check if database is responding
psql -h localhost -U geodashboard_user -d geodashboard -c "SELECT 1;"

# Expected: Should see "?column?" output with value 1
# If error: Connection refused or timeout → proceed to recovery

# Check system
sudo systemctl status postgresql  # or docker ps for containerized DB
```

**Recovery Steps**

```bash
# 1. Immediate diagnosis
sudo systemctl status postgresql
sudo journalctl -u postgresql -n 50

# 2. Attempt automatic restart
sudo systemctl restart postgresql
sleep 10

# 3. Verify it started
sudo systemctl status postgresql
psql -h localhost -U geodashboard_user -d geodashboard -c "SELECT version();"

# 4. If still failed, check disk space
df -h | grep -i postgres

# 5. If disk full:
sudo du -sh /var/lib/postgresql/* | sort -hr
# Archive/delete old WAL files if needed
sudo find /var/lib/postgresql/*/main -name "*.wal" -mtime +7 -delete

# 6. Try restart again
sudo systemctl restart postgresql

# 7. If still failing, restore from backup
bash /opt/epic-geodashboard/scripts/restore_database_backup.sh backup-2025-11-08.tar.gz
```

**Restore from Backup**

```bash
# 1. Identify latest backup
ls -lh /opt/epic-geodashboard/backups/db/ | tail -5

# 2. Stop application to prevent writes during restore
sudo systemctl stop epic-geodashboard

# 3. Backup current corrupted database
sudo -u postgres pg_dump geodashboard > /tmp/corrupted-backup-$(date +%Y-%m-%d).sql

# 4. Drop corrupted database
sudo -u postgres psql -c "DROP DATABASE geodashboard;"

# 5. Restore from backup
sudo -u postgres psql -f /opt/epic-geodashboard/backups/db/geodashboard-backup-2025-11-08.sql

# 6. Verify restore
sudo -u postgres psql -d geodashboard -c "SELECT count(*) FROM earthquakes;"

# 7. Start application
sudo systemctl start epic-geodashboard

# 8. Verify connectivity
curl https://<domain>/api/earthquakes
```

**Validation Checklist**
- [ ] Database service running
- [ ] Can connect: `psql -h localhost -U user -d geodashboard -c "SELECT 1;"`
- [ ] Tables exist: `psql ... -c "\dt"`
- [ ] Application can connect: `curl /api/earthquakes` → valid response
- [ ] No data corruption: `psql ... -c "SELECT count(*) FROM earthquakes;"` → reasonable count

**Escalation**
- If RTO exceeded: Failover to read replica
- If multiple backup files corrupted: File system check needed
- If data integrity compromised: Security team review required

---

### Scenario 3: Data Corruption or Accidental Deletion

**Severity**: Critical (potential data loss)  
**Detection Time**: 5-60 minutes (depends on monitoring)  
**RTO**: 30 minutes  
**RPO**: 24 hours (daily backup)

**Root Causes**
- Accidental data deletion
- Application bug writing invalid data
- Database transaction failure
- Malware or unauthorized access

**Prevention**
- Write access controls (authentication required)
- Backup retention: Last 30 days
- Point-in-time recovery capability
- Monitoring for unusual delete patterns

**Detection**

```bash
# Indicators
# 1. Users report missing data
# 2. Dashboard shows sudden drop in metrics
# 3. Application errors mentioning missing tables
# 4. Database size suddenly shrinks

# Quick check
psql -d geodashboard -c "SELECT count(*) FROM earthquakes;" 
# Compare with known baseline (e.g., should be > 10000)

# Recent activity check
psql -d geodashboard -c "SELECT * FROM pg_stat_user_tables WHERE n_tup_del > n_tup_ins;"
```

**Recovery Steps**

```bash
# 1. IMMEDIATELY stop writes to prevent further loss
# Option A: Stop backend service
sudo systemctl stop epic-geodashboard

# Option B: Put database in read-only mode
sudo -u postgres psql -d geodashboard -c "ALTER DATABASE geodashboard SET default_transaction_read_only = on;"

# 2. Assess damage
# Before stopping, check recovery point
psql -d geodashboard -c "SELECT * FROM earthquakes LIMIT 5;"

# 3. Determine time of corruption
# Check application logs for when it started
sudo journalctl -u epic-geodashboard --since "2 hours ago" | grep -i "error\|failed"

# 4. Find backup closest to (but before) corruption
ls -lh /opt/epic-geodashboard/backups/db/
# Example: backup-2025-11-08-backup-before-corruption.tar.gz

# 5. Restore to point-in-time (if available)
# For PostgreSQL with WAL archiving:
# Create recovery.conf with recovery_target_time = '2025-11-09 10:00:00 UTC'
# Stop PostgreSQL, restore base backup, enable recovery, start PostgreSQL

# Simplified: Restore latest backup
sudo -u postgres pg_restore --clean --if-exists -d geodashboard /opt/epic-geodashboard/backups/db/geodashboard-latest.dump

# 6. Verify restored data
psql -d geodashboard -c "SELECT count(*) FROM earthquakes;"

# 7. Enable writes again
sudo systemctl start epic-geodashboard

# 8. Monitor for consistency
curl https://<domain>/api/earthquakes | jq '.data | length'
```

**Data Integrity Check**

```bash
# After restore, verify data integrity
psql -d geodashboard << EOF
-- Check for orphaned records
SELECT * FROM earthquakes WHERE created_at > CURRENT_TIMESTAMP;

-- Check for duplicates
SELECT magnitude, location, COUNT(*) 
FROM earthquakes 
GROUP BY magnitude, location 
HAVING COUNT(*) > 1;

-- Check data consistency
SELECT min(created_at), max(created_at) FROM earthquakes;
EOF
```

**Validation Checklist**
- [ ] Data restored to point before corruption
- [ ] Row count matches expectation
- [ ] No duplicate records
- [ ] Application can query data successfully
- [ ] Data timestamps are reasonable

**Escalation**
- If unable to locate corrupted point: Restore oldest available backup + communicate data loss
- If multiple backups corrupted: Investigate backup process failure
- If malware suspected: Security team + full system audit

---

### Scenario 4: Regional Infrastructure Failure

**Severity**: Critical (entire region down)  
**Detection Time**: < 2 minutes  
**RTO**: 30 minutes  
**RPO**: 24 hours  

**Root Causes**
- Cloud provider regional outage
- Networking infrastructure failure
- Power outage affecting data center
- Disaster (fire, flood, etc.)

**Prevention**
- Multi-region deployment
- Automated backup to secondary region
- DNS failover configuration
- Read-only replicas in alternate region

**Detection**

```bash
# Signs of regional outage
# 1. All services in region unreachable
# 2. Cloud provider status page shows outage
# 3. Monitoring system itself fails
# 4. On-call cannot SSH to any server

# Verification
ping <prod-ip>
# Expected: No response or timeout > 10s = likely outage

# Check cloud provider status
curl https://status.aws.amazon.com/
curl https://www.googlecloudstatus.com/
```

**Failover to Secondary Region**

```bash
# AUTOMATED FAILOVER SCRIPT (recommended)
# Pre-configured and tested monthly

sudo bash /opt/epic-geodashboard/scripts/failover-to-secondary-region.sh

# Script performs:
# 1. Verifies primary region down
# 2. Triggers restore on secondary region
# 3. Updates DNS records
# 4. Verifies secondary is operational
# 5. Sends notifications

# Expected time: 15-20 minutes for full failover
```

**Manual Failover Steps** (if automated failover fails)

```bash
# 1. SSH to secondary region instance
ssh ubuntu@<secondary-region-ip>

# 2. Download latest backup
aws s3 cp s3://company-backups/geodashboard/latest.tar.gz /tmp/

# 3. Extract and verify
cd /opt
sudo tar -xzf /tmp/latest.tar.gz

# 4. Restore configuration
cd epic-geodashboard
cat .env.backup | sudo tee .env > /dev/null

# 5. Start all services
sudo systemctl start epic-geodashboard
cd monitoring && docker-compose up -d

# 6. Verify services
curl https://<secondary-domain>/api/health

# 7. Update DNS (at domain registrar or Route53)
# Point A record to secondary region IP

# 8. Wait for DNS propagation (60-300 seconds)
nslookup <domain>
# Should resolve to secondary IP

# 9. Verify external access
curl -I https://<domain>

# 10. Monitor logs
sudo journalctl -u epic-geodashboard -f
docker-compose logs -f
```

**Validation Checklist**
- [ ] Secondary region services started
- [ ] Health checks passing
- [ ] DNS updated and propagated
- [ ] External users can access system
- [ ] No data loss (within RPO)
- [ ] Alerts configured in secondary region
- [ ] Monitoring stack operational

**Communication During Failover**
- [ ] Notify all stakeholders immediately
- [ ] Post status update every 5 minutes
- [ ] Declare recovered when all services operational
- [ ] Root cause analysis within 24 hours

**Escalation**
- If secondary also unreachable: Contact cloud provider support
- If DNS not updating: Contact domain registrar
- If data unavailable: Restore from remote backup repository

---

### Scenario 5: Storage/Filesystem Failure

**Severity**: Critical  
**Detection Time**: < 1 minute  
**RTO**: 30-60 minutes  
**RPO**: 24 hours  

**Root Causes**
- Disk failure in RAID array
- Filesystem corruption (fsck needed)
- Volume unmount/detach
- Out of inode space

**Prevention**
- RAID-1 mirroring for critical volumes
- Filesystem monitoring (inode usage, health checks)
- Automated snapshots (EBS, GCS, Azure)
- Volume replication

**Detection**

```bash
# Symptoms
# 1. Applications can't write: "No space left on device"
# 2. Read-only filesystem error
# 3. Disk visible but not mounted
# 4. I/O errors in dmesg

# Diagnostics
df -h
# Shows volume full or with 0 inodes

lsblk
# Shows disk but no mount point

sudo dmesg | tail -20
# Shows I/O errors

sudo fsck /dev/sda1
# May show corruption
```

**Recovery Steps**

```bash
# OPTION 1: Disk Full (safe to fix)

# 1. Identify large files/directories
du -sh /* | sort -hr

# 2. Cleanup old data
sudo journalctl --vacuum=7d
sudo find /var/log -name "*.log.*" -delete
docker system prune -a -f

# 3. Verify space freed
df -h

# 4. Restart affected services
sudo systemctl restart epic-geodashboard


# OPTION 2: Filesystem Corruption (requires downtime)

# 1. Stop all services
sudo systemctl stop epic-geodashboard
docker-compose down

# 2. Unmount filesystem
sudo umount /dev/sda1

# 3. Run filesystem check
sudo fsck -y /dev/sda1
# May take 5-10 minutes

# 4. Remount filesystem
sudo mount /dev/sda1 /opt

# 5. Start services
sudo systemctl start epic-geodashboard
docker-compose up -d


# OPTION 3: Disk Failed (needs hardware replacement)

# 1. Failover to secondary (if available)
# OR provision replacement disk

# 2. For replacement disk:
# Stop services
sudo systemctl stop epic-geodashboard

# Detach failed disk from cloud console
# Attach new disk of same size

# Partition and format new disk
sudo lsblk  # Identify new disk (e.g., /dev/sdb)
sudo mkfs.ext4 /dev/sdb1
sudo mount /dev/sdb1 /opt

# Restore from backup
sudo tar -xzf /opt/epic-geodashboard/backups/latest.tar.gz -C /

# Restart
sudo systemctl start epic-geodashboard
```

**Validation Checklist**
- [ ] Filesystem mounted and accessible
- [ ] No I/O errors in dmesg
- [ ] Services started successfully
- [ ] Can write to filesystem: `sudo touch /opt/test.txt && rm /opt/test.txt`
- [ ] Data integrity verified

**Prevention for Future**
- [ ] Switch to RAID-1 if not already
- [ ] Enable automated snapshots (daily)
- [ ] Set up inode usage alerts
- [ ] Implement log rotation limits

---

## Backup Strategy

### Backup Schedule

**Automated Backups**

| Backup Type | Frequency | Retention | Location |
|------------|-----------|-----------|----------|
| Full System | Daily @ 2:00 AM UTC | 30 days | Local: `/opt/epic-geodashboard/backups` |
| Database | Daily @ 2:00 AM UTC | 30 days | Local: `/opt/epic-geodashboard/backups/db` |
| Configuration | On-demand (post-deploy) | Git history | Git repository |
| Cloud Copy | Daily @ 3:00 AM UTC | 60 days | AWS S3 / GCS |
| Incremental | Every 6 hours | 7 days | Local (space-efficient) |

### Backup Contents

```
Full System Backup (backup-YYYY-MM-DD.tar.gz)
├── Application Code
│   ├── frontend/
│   ├── backend/
│   └── monitoring/
├── Configuration
│   ├── .env (encrypted)
│   ├── nginx/
│   └── docker-compose.yml
├── Database
│   └── geodashboard.sql.gz
└── Metadata
    ├── backup-manifest.json
    └── integrity-check.sha256
```

### Backup Verification

**Daily Verification Script**

```bash
#!/bin/bash
# Run: daily via cron

BACKUP_DIR="/opt/epic-geodashboard/backups"
TODAY=$(date +%Y-%m-%d)
BACKUP_FILE="$BACKUP_DIR/backup-$TODAY.tar.gz"

# Check backup exists
if [[ ! -f "$BACKUP_FILE" ]]; then
    echo "CRITICAL: Backup missing for $TODAY"
    # Send alert
    exit 1
fi

# Check size (should be > 200MB)
SIZE=$(du -b "$BACKUP_FILE" | cut -f1)
if [[ $SIZE -lt 209715200 ]]; then  # 200MB in bytes
    echo "WARNING: Backup unusually small: $SIZE bytes"
    exit 1
fi

# Verify integrity
if ! tar -tzf "$BACKUP_FILE" > /dev/null 2>&1; then
    echo "CRITICAL: Backup corruption detected"
    exit 1
fi

# Check cloud sync
aws s3 ls s3://company-backups/geodashboard/backup-$TODAY.tar.gz
if [[ $? -ne 0 ]]; then
    echo "WARNING: Cloud backup missing"
    exit 1
fi

echo "OK: Backup verified successfully"
```

**Manual Backup Verification**

```bash
# Test backup integrity
tar -tzf /opt/epic-geodashboard/backups/backup-2025-11-09.tar.gz | head -20

# Verify checksum
cd /opt/epic-geodashboard/backups
sha256sum -c backup-2025-11-09.sha256

# Restore to temporary location
mkdir /tmp/restore-test
cd /tmp/restore-test
tar -xzf /opt/epic-geodashboard/backups/backup-2025-11-09.tar.gz

# Verify content
ls -la  # Should have frontend/, backend/, etc.
file config/.env  # Should show ASCII text
```

### Backup Lifecycle

```
Day 1: Backup created locally
      ↓
Day 1 (3 AM UTC): Uploaded to cloud storage
      ↓
Day 1-30: Available for restore
      ↓
Day 31: Local backup deleted (space management)
      ↓
Day 31-60: Cloud backup retained
      ↓
Day 61: Cloud backup deleted
```

### Offsite Backup

**Automated Cloud Sync**

```bash
# Configure S3 sync in cron
# Run daily after backup creation

0 3 * * * aws s3 sync /opt/epic-geodashboard/backups s3://company-backups/geodashboard/ --delete

# Verify uploads
aws s3 ls s3://company-backups/geodashboard/ --recursive | tail -10
```

**Cross-Region Replication**

```bash
# For critical backups, replicate to secondary region

aws s3api put-bucket-replication \
  --bucket company-backups \
  --replication-configuration '{
    "Role": "arn:aws:iam::ACCOUNT:role/s3-replication",
    "Rules": [{
      "Status": "Enabled",
      "Priority": 1,
      "Destination": {
        "Bucket": "arn:aws:s3:::company-backups-secondary"
      }
    }]
  }'
```

---

## Recovery Procedures

### Quick Recovery Checklist

**1. Determine Recovery Scenario** (< 5 minutes)

- [ ] Is backend service down? → Scenario 1
- [ ] Is database down? → Scenario 2
- [ ] Is data corrupted? → Scenario 3
- [ ] Is entire region down? → Scenario 4
- [ ] Is disk full? → Scenario 5

**2. Declare Severity Level**

- [ ] Critical: RTO < 15 minutes, escalate to Manager
- [ ] High: RTO < 1 hour, page primary on-call
- [ ] Medium: RTO < 4 hours, notify team
- [ ] Low: RTO > 4 hours, log and track

**3. Execute Recovery**

- [ ] Follow appropriate scenario steps above
- [ ] Document actions taken
- [ ] Monitor recovery progress
- [ ] Verify systems operational

**4. Post-Recovery Validation**

- [ ] All services responding
- [ ] No errors in logs
- [ ] Data integrity verified
- [ ] Users can access system
- [ ] Monitoring normal

### Recovery Prioritization

```
1st Priority: Restore backend API (users can't access features)
2nd Priority: Restore database (data consistency)
3rd Priority: Restore monitoring (internal visibility)
4th Priority: Restore advanced features (degraded operation)
```

### Recovery Time Targets (SLA)

| Issue | Priority | Target RTO | Target RPO |
|-------|----------|-----------|-----------|
| Backend Down | P1 | 5 min | 0 (stateless) |
| Database Down | P1 | 15 min | 24 hours |
| Data Loss | P1 | 30 min | 24 hours |
| Region Down | P1 | 30 min | 24 hours |
| Degraded Performance | P2 | 1 hour | N/A |
| Minor Service Down | P3 | 4 hours | N/A |

---

## Failover Plan

### Automatic Failover

**Trigger Conditions**

```
Health check fails 3 times in 30 seconds
  ↓
Send alert: "Backend health check failure"
  ↓
Wait 2 minutes for manual intervention
  ↓
If still failed: Automatic restart
  ↓
If still failed: Initiate failover to secondary
```

**Failover Locations**

- Primary: `us-east-1` (AWS)
- Secondary: `us-west-2` (AWS)
- Tertiary: `eu-west-1` (AWS)

**DNS Failover**

```
Primary endpoint: api.geodashboard.com (us-east-1)
Failover DNS: 
  - Health check every 30 seconds
  - Failover latency: 60-120 seconds
  - If primary fails: Route to secondary
  - If secondary fails: Route to tertiary
```

**Failover Verification**

```bash
# Test DNS failover
nslookup api.geodashboard.com
# Simulate primary failure
# Wait 60 seconds
nslookup api.geodashboard.com
# Should now resolve to secondary IP
```

### Manual Failover

**When to Trigger**: If automatic failover fails or doesn't trigger

```bash
# 1. Verify primary truly down
ping <primary-ip>
curl -I https://<primary-domain>/api/health

# 2. Trigger manual failover
sudo /opt/epic-geodashboard/scripts/manual-failover.sh secondary

# 3. Verify secondary operational
curl -I https://api-secondary.geodashboard.com/api/health

# 4. Update DNS manually
aws route53 change-resource-record-sets \
  --hosted-zone-id Z1234567890ABC \
  --change-batch file:///tmp/failover-change.json

# 5. Monitor failover
watch -n 5 "curl -I https://api.geodashboard.com/api/health"

# 6. Expected: HTTP 200 from secondary within 60 seconds
```

---

## Testing & Validation

### Disaster Recovery Drill

**Schedule**: Monthly (2nd Wednesday, 2:00 AM UTC)

**Participants**
- DevOps team (primary)
- Backend team (standby)
- Operations team (observer)
- Manager (observer/escalation)

**Drill Procedure**

```bash
# Step 1: Simulate primary failure (30 seconds after drill start)
ssh <primary-prod-server>
sudo systemctl stop epic-geodashboard

# Step 2: Measure detection time
# Record when alert fires in Slack/PagerDuty

# Step 3: Measure failover time
# Measure time until secondary handling requests

# Step 4: Verify data consistency
# Query both systems, ensure no divergence

# Step 5: Execute recovery plan
# Restore primary, fail back

# Targets for drill:
# - Detection time: < 2 minutes
# - Failover time: < 10 minutes
# - Recovery time: < 20 minutes
```

**Post-Drill Report**

Document:
- [ ] Detection time
- [ ] Failover time
- [ ] Recovery time
- [ ] Any issues encountered
- [ ] Improvements needed
- [ ] Team sign-off

### Backup Restoration Test

**Quarterly Restoration Exercise**

```bash
# 1. Pick random backup from 30-60 days ago
BACKUP=$(ls /opt/epic-geodashboard/backups/ | shuf | head -1)

# 2. Create isolated test environment
# - New VM (same specs as production)
# - Production credentials (if needed)

# 3. Restore backup
tar -xzf /opt/epic-geodashboard/backups/$BACKUP -C /opt

# 4. Start services
sudo systemctl start epic-geodashboard
docker-compose up -d

# 5. Run health checks
bash scripts/health_check.sh

# 6. Verify data
curl http://localhost/api/health
curl http://localhost/api/earthquakes | jq '.data | length'

# 7. Results
# Success: Backup can be restored and verified
# Failure: Investigate and fix backup process
```

---

## Communication Protocol

### Incident Communication

**Immediate (Within 5 Minutes)**

```
To: All on-call staff, Slack #prod-incidents, status-page

From: Automated Alert System or On-Call Lead

Subject: [CRITICAL] Incident: Backend Service Unavailable

Details:
- Incident ID: INC-2025-11-09-001
- Severity: CRITICAL
- Affected Service: API Backend
- Status: INVESTIGATING
- ETA for update: 5 minutes
- Escalation: Contact DevOps Lead if unresolved
```

**Status Updates (Every 5-10 Minutes Until Resolved)**

```
Update #1 (10 minutes): Root cause identified - backend OOM
Update #2 (15 minutes): Restarted service, monitoring recovery
Update #3 (20 minutes): Service recovered, validating stability
```

**Resolution Notification (Within 30 Minutes)**

```
To: All affected parties

Subject: [RESOLVED] Incident: Backend Service Restored

Details:
- Incident ID: INC-2025-11-09-001
- Root Cause: Backend service out of memory (memory leak)
- Resolution: Service restarted, investigating root cause
- Duration: 15 minutes
- Data Loss: None
- Follow-up: Post-incident review scheduled
```

### Escalation Matrix

**Level 1** (5 minutes): Alert primary on-call  
**Level 2** (10 minutes): Page secondary on-call  
**Level 3** (15 minutes): Alert manager  
**Level 4** (20 minutes): Declare major incident, call war room  

### Post-Incident Communication

**Within 24 hours**: Publish post-incident report

```
Incident Report: Backend Service Failure (2025-11-09 02:00 UTC)

Timeline:
02:00 - Alert triggered
02:02 - Backend restart initiated  
02:05 - Service recovered
02:07 - Declared resolved

Root Cause:
- Memory leak in data processing routine
- Identified: Lines 142-156 of data_processor.py

Impact:
- Duration: 5 minutes
- Users affected: ~100
- Transactions lost: None (queued and retried)

Fix:
- Patch deployed: v1.2.1
- Memory limit increased to 4GB per worker

Preventions:
- Add memory usage test to CI/CD
- Implement automatic worker restart on OOM
- Increase monitoring frequency for memory

Owner: Backend Team Lead
Review Date: 2025-11-11
```

---

## Post-Incident Review

### Post-Incident Review (PIR) Process

**Trigger**: Any incident with RTO > 5 minutes or data loss

**Timeline**: Within 24-48 hours of resolution

**Participants**
- On-call engineer (who responded)
- Service owner (backend team lead)
- DevOps lead
- Manager (observer)

**Meeting Agenda** (60 minutes)

```
1. Timeline Review (10 min)
   - What happened and when
   - Detection time
   - Response actions

2. Root Cause Analysis (15 min)
   - Why did it happen
   - Underlying issues
   - Contributing factors

3. Impact Assessment (5 min)
   - Business impact
   - User impact
   - Financial impact

4. Prevention Items (15 min)
   - What should prevent this
   - Code changes needed
   - Process changes needed
   - Monitoring improvements

5. Action Items (10 min)
   - Owner for each item
   - Target completion date
   - Follow-up meeting date

6. Lessons Learned (5 min)
   - What did we learn
   - What will we do differently
```

### Action Item Tracking

**Template**

```
Action Item: Fix memory leak in data_processor.py

Owner: Backend Team Lead
Priority: P0 (Critical)
Target Date: 2025-11-13
Status: In Progress

Description:
Lines 142-156 of data_processor.py not releasing memory.
Need to review list comprehension and add explicit cleanup.

Acceptance Criteria:
- Memory test passes
- Deployed to production
- Monitored for 7 days without memory growth

Tracking: Add to sprint, include in code review
```

### Follow-Up Verification

**One Week After Incident**

```bash
# 1. Verify fix deployed
git log --oneline | grep memory-leak-fix

# 2. Verify monitoring shows improvement
# Check memory usage trend in Grafana (past 7 days)

# 3. Confirm no recurrence
grep "memory\|OOM" /var/log/app.log | grep "$(date -d '7 days ago' +%Y-%m-%d)"
# Should show 0 incidents

# 4. Confirm prevention measures in place
# Verify memory test runs in CI/CD
# Verify auto-restart configured

# 5. Update runbook with lessons learned
vi OPERATIONS_RUNBOOK.md
# Add: "If memory leak suspected, check data_processor.py memory cleanup"
```

---

## Appendix

### Critical Scripts Location

| Script | Purpose | Path |
|--------|---------|------|
| health_check.sh | Verify all services | `/opt/epic-geodashboard/scripts/health_check.sh` |
| backup.sh | Create backup manually | `/opt/epic-geodashboard/scripts/backup.sh` |
| restore.sh | Restore from backup | `/opt/epic-geodashboard/scripts/restore.sh` |
| failover.sh | Failover to secondary | `/opt/epic-geodashboard/scripts/failover-to-secondary-region.sh` |

### Emergency Contact Info

```
On-Call Phone Tree:
1. DevOps Lead: +1-555-DEV-0123
2. SRE Lead: +1-555-SRE-0456
3. Backend Lead: +1-555-BACK-0789
4. Operations Manager: +1-555-OPS-1234

Email: emergency@company.com
Slack: @ops-oncall
```

### Recovery Resource Links

- Prometheus Documentation: https://prometheus.io/docs/
- Docker Documentation: https://docs.docker.com/
- PostgreSQL Documentation: https://www.postgresql.org/docs/
- AWS Disaster Recovery: https://docs.aws.amazon.com/
- Let's Encrypt Auto-renewal: https://certbot.eff.org/

---

**Document Owner**: DevOps Team  
**Last Updated**: November 9, 2025  
**Next Review**: February 9, 2026  
**Status**: APPROVED FOR PRODUCTION
