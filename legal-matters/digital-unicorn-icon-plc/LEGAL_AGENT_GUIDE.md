# Legal Monitoring Agent - Setup & Operations Guide

## Overview

The **Legal Monitoring Agent** is an autonomous Python service running on VM159 that continuously:

1. **Captures** the Digital Unicorn website every 6 hours
2. **Verifies** integrity with SHA-256 cryptographic hashes
3. **Generates** daily legal reports with timestamped evidence
4. **Tracks** any changes to your image or page content
5. **Produces** court-ready documentation with chain-of-custody

All evidence is preserved under strict cryptographic and logging protocols suitable for legal proceedings.

---

## Quick Facts

| Item | Value |
|------|-------|
| **Case** | Digital Unicorn Services Co., Ltd. - Unauthorized Image Use (Contract 0925/CONSULT/DU) |
| **Your Name** | Simon Renauld |
| **Position** | Left figure in team section of https://digitalunicorn.fr/a-propos/ |
| **VM Host** | VM159 |
| **Service Name** | legal-monitoring.service |
| **Capture Interval** | Every 6 hours (automated) |
| **Report Interval** | Daily (automated) |
| **Evidence Dir** | `/home/simon/Learning-Management-System-Academy/legal-matters/digital-unicorn-icon-plc/legal_agent_monitoring/` |

---

## Installation on VM159

### Prerequisites
- Python 3.8+
- Sudo access
- Internet connection (for website capture)
- ~2GB disk space minimum for evidence storage

### Installation Steps

**Step 1: Clone/sync the workspace**
```bash
cd /home/simon
git clone <workspace-repo> Learning-Management-System-Academy
# or sync existing
```

**Step 2: Run deployment script**
```bash
bash /home/simon/Learning-Management-System-Academy/scripts/deploy_legal_monitoring_agent.sh
```

The script will:
- Install Playwright and dependencies
- Create monitoring directories
- Install the systemd service
- Start the service automatically
- Verify initial capture and report

**Step 3: Verify service is running**
```bash
sudo systemctl status legal-monitoring.service
```

Expected output:
```
● legal-monitoring.service - Legal Monitoring Agent - Digital Unicorn Case
   Loaded: loaded (/etc/systemd/system/legal-monitoring.service; enabled; vendor preset: enabled)
   Active: active (running) since Fri 2025-11-07 15:30:42 UTC; 5min ago
   ...
```

---

## Operations

### Check Service Status
```bash
# Quick status
sudo systemctl status legal-monitoring.service

# Full status with recent activity
sudo systemctl status legal-monitoring.service -l

# Auto-update status (live)
sudo systemctl status legal-monitoring.service --no-pager --all
```

### View Evidence Captures
```bash
# List all captures
ls -lh /home/simon/Learning-Management-System-Academy/legal-matters/digital-unicorn-icon-plc/legal_agent_monitoring/captures/

# View most recent PNG
open "/home/simon/Learning-Management-System-Academy/legal-matters/digital-unicorn-icon-plc/legal_agent_monitoring/captures/screenshot_*.png" | tail -1

# Verify file integrity (example)
sha256sum /home/simon/Learning-Management-System-Academy/legal-matters/digital-unicorn-icon-plc/legal_agent_monitoring/captures/screenshot_20251107_141529.png
```

### View Legal Reports
```bash
# List all reports
ls -lh /home/simon/Learning-Management-System-Academy/legal-matters/digital-unicorn-icon-plc/legal_agent_monitoring/reports/

# Read latest report
cat "/home/simon/Learning-Management-System-Academy/legal-matters/digital-unicorn-icon-plc/legal_agent_monitoring/reports/LEGAL_REPORT_$(date +%Y%m%d)_*.md" | tail -1

# View report in markdown viewer (VSCode)
code "/home/simon/Learning-Management-System-Academy/legal-matters/digital-unicorn-icon-plc/legal_agent_monitoring/reports/"
```

### View System Logs
```bash
# Recent service logs
sudo journalctl -u legal-monitoring.service -n 50

# Follow live logs (real-time)
sudo journalctl -u legal-monitoring.service -f

# Logs since last hour
sudo journalctl -u legal-monitoring.service --since "1 hour ago"

# View agent application logs
tail -f "/home/simon/Learning-Management-System-Academy/legal-matters/digital-unicorn-icon-plc/legal_agent_monitoring/logs/legal_agent_*.log"
```

### Stop / Start Service
```bash
# Stop monitoring (temporary pause)
sudo systemctl stop legal-monitoring.service

# Start monitoring (resume)
sudo systemctl start legal-monitoring.service

# Restart service (hard reset)
sudo systemctl restart legal-monitoring.service

# Disable auto-start (permanent stop)
sudo systemctl disable legal-monitoring.service
```

---

## Evidence Chain of Custody

### File Structure
```
legal_agent_monitoring/
├── captures/
│   ├── screenshot_20251107_141529.png      # Full-page PNG (6h intervals)
│   ├── screenshot_20251107_141529.pdf      # Legal-ready PDF
│   ├── snapshot_20251107_141529.html       # HTML source code
│   ├── metadata_20251107_141529.json       # Capture metadata & hashes
│   └── [more captures...]
│
├── reports/
│   ├── LEGAL_REPORT_20251107_141529.md     # Auto-generated daily report
│   ├── LEGAL_REPORT_20251108_082430.md
│   └── [more reports...]
│
├── logs/
│   ├── legal_agent_20251107.log            # Agent application log
│   ├── service.log                         # Systemd service log
│   └── service_errors.log                  # Error log
│
└── monitoring_index.json                    # Master index with all hashes
```

### Cryptographic Verification

Each capture includes SHA-256 hashes for verification:

```bash
# View index with all hashes
cat /home/simon/Learning-Management-System-Academy/legal-matters/digital-unicorn-icon-plc/legal_agent_monitoring/monitoring_index.json

# Manually verify a PNG file
sha256sum /path/to/screenshot_*.png

# Output example:
# a1b2c3d4e5f6... /path/to/screenshot_20251107_141529.png
```

### Chain of Custody Certificate

When submitting to court, include:
1. **monitoring_index.json** – Master index with all hashes
2. **Screenshot files** (PNG/PDF) – Visual evidence
3. **LEGAL_REPORT_*.md** – Timestamped analysis
4. **Metadata JSONs** – Capture details and verification data

---

## Legal Escalation Timeline

### Current Status (as of Nov 7, 2025)
- ✅ **Website captures secured** with cryptographic hashes
- ⏰ **Final demand deadline:** Nov 7, 18:00 Vietnam time
- ❌ **Image still visible** (as of last capture)
- ✖️ **No response from Digital Unicorn**

### If No Settlement by Nov 10

**Option A: France (CNIL Complaint)**
```bash
# File CNIL complaint at https://www.cnil.fr/plainte
# Include: latest screenshot PDF + monitoring_index.json
# Expected CNIL response: 60–90 days
```

**Option B: Vietnam (Lawyer Letter)**
```bash
# Contact lawyer: Lê Trọng Long
# Send: monitoring index + all captures + legal report
# Expected legal letter turnaround: 3–5 business days
```

**Option C: Escalate to ICON/J&J**
```bash
# Forward evidence to ICON PLC procurement/legal
# Reference: Digital Unicorn is your subcontractor violating vendor compliance
# Expected response: 5–10 business days
```

---

## Troubleshooting

### Service Won't Start
```bash
# Check systemd errors
sudo journalctl -u legal-monitoring.service -n 50

# Common fixes:
# 1. Verify Python path
which python3
# Should return /usr/bin/python3 or similar

# 2. Install missing dependencies
pip3 install playwright
python3 -m playwright install chromium

# 3. Check file permissions
ls -la /home/simon/Learning-Management-System-Academy/.continue/agents/legal_monitoring_agent.py
# Should be readable and executable

# 4. Restart service
sudo systemctl restart legal-monitoring.service
```

### Captures Not Being Created
```bash
# Check capture directory
ls -la /home/simon/Learning-Management-System-Academy/legal-matters/digital-unicorn-icon-plc/legal_agent_monitoring/captures/

# If empty, check logs
tail -50 /home/simon/Learning-Management-System-Academy/legal-matters/digital-unicorn-icon-plc/legal_agent_monitoring/logs/legal_agent_*.log

# Common issues:
# - Network connectivity (check: curl https://digitalunicorn.fr/a-propos/)
# - Playwright browser not installed (fix: python3 -m playwright install chromium)
# - Disk space full (check: df -h)
```

### Reports Not Generating
```bash
# Check if reports directory exists and is writable
ls -la /home/simon/Learning-Management-System-Academy/legal-matters/digital-unicorn-icon-plc/legal_agent_monitoring/reports/

# If empty after 24 hours, check agent logs
tail -100 /home/simon/Learning-Management-System-Academy/legal-matters/digital-unicorn-icon-plc/legal_agent_monitoring/logs/legal_agent_*.log
grep -i "report" /home/simon/Learning-Management-System-Academy/legal-matters/digital-unicorn-icon-plc/legal_agent_monitoring/logs/legal_agent_*.log
```

### High CPU/Memory Usage
```bash
# Check resource usage
ps aux | grep legal_monitoring_agent.py

# The service has resource limits (set in systemd):
# - MemoryMax=1G (max 1GB RAM)
# - CPUQuota=50% (max 50% CPU)

# If limits are exceeded, service may stop:
sudo journalctl -u legal-monitoring.service | grep -i "memory\|cpu"

# Solution: Reduce capture interval or increase resource limits in:
# /etc/systemd/system/legal-monitoring.service
```

---

## Manual Capture & Report Generation

If you need an immediate capture outside the 6-hour interval:

```bash
# Run agent once manually (then exit)
python3 /home/simon/Learning-Management-System-Academy/.continue/agents/legal_monitoring_agent.py

# This will:
# 1. Perform one capture immediately
# 2. Generate a legal report
# 3. Exit (service will restart automatically)
```

---

## Integration with Other Systems

### Dashboard Integration
The monitoring index can be integrated into a web dashboard for real-time status:

```bash
# Export monitoring data as JSON
cat /home/simon/Learning-Management-System-Academy/legal-matters/digital-unicorn-icon-plc/legal_agent_monitoring/monitoring_index.json
```

### Slack/Email Alerts (Optional)
To get notified when changes are detected, add webhook integration:

```python
# In legal_monitoring_agent.py, after detecting changes:
import requests
webhook_url = "YOUR_SLACK_WEBHOOK_URL"
requests.post(webhook_url, json={"text": f"⚠️ Website change detected: {changes}"})
```

---

## Backup & Archiving

### Backup Evidence Regularly
```bash
# Compress all captures and reports
tar -czf /backup/legal_evidence_backup_$(date +%Y%m%d).tar.gz \
  /home/simon/Learning-Management-System-Academy/legal-matters/digital-unicorn-icon-plc/legal_agent_monitoring/

# Upload to secure storage (e.g., encrypted USB, cloud backup)
```

### Archive to External Storage
```bash
# Burn to DVD or external drive for legal filing
cp -r /home/simon/Learning-Management-System-Academy/legal-matters/digital-unicorn-icon-plc/legal_agent_monitoring/ \
  /mnt/external_drive/digital_unicorn_legal_evidence_$(date +%Y%m%d)/
```

---

## Legal Submission Checklist

When submitting evidence to court/authorities:

- [ ] **monitoring_index.json** – Master file with all SHA-256 hashes
- [ ] **Latest LEGAL_REPORT_*.md** – Timestamped analysis
- [ ] **Screenshot PDFs** (last 3–5 captures) – Visual evidence of image
- [ ] **Metadata JSON files** – Capture details
- [ ] **Service logs** – Proof of continuous monitoring
- [ ] **Cease-and-desist letters** (dated Nov 4, Nov 5) – Demands sent to Digital Unicorn
- [ ] **Email responses (or lack thereof)** – Proof of ignored demands
- [ ] **Archive.ph snapshot** – Independent third-party verification

---

## Contact & Support

**Legal Case:** Digital Unicorn Services Co., Ltd. - Unauthorized Image Use  
**Consultant:** Simon Renauld  
**Email:** sn.renauld@gmail.com  
**Case Contract:** 0925/CONSULT/DU  

**Vietnam Lawyer:** Lê Trọng Long  
**Escalation Contact (ICON PLC):** From evidence files  

---

## References

**Vietnamese Civil Code (2015):**
- Article 32: Protection of personal image and dignity
- Article 351: Performance of contractual obligations
- Article 592: Violation of personal rights

**GDPR (EU):**
- Article 6: Lawful basis for processing
- Article 17: Right to erasure

**French Law:**
- CNIL: French Data Protection Authority
- Civil Code Article 1240: Tort liability

---

**Last Updated:** November 7, 2025  
**Version:** 1.0  
**Status:** ACTIVE MONITORING - 24/7
