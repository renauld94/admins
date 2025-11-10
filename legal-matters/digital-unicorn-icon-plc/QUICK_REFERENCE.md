# ⚖️ LEGAL AGENT QUICK REFERENCE CARD

## Current Evidence Status

| Item | Status | Location |
|------|--------|----------|
| Screenshot (PNG/PDF/HTML) | ✅ CAPTURED | `/website_captures/digitalunicorn_apropos_20251107_141529.*` |
| Metadata & Hashes | ✅ STORED | `/website_captures/metadata_20251107_141529.json` |
| Legal Agent Script | ✅ READY | `.continue/agents/legal_monitoring_agent.py` |
| Systemd Service | ✅ READY | `.continue/systemd/legal-monitoring.service` |
| Deployment Script | ✅ READY | `scripts/deploy_legal_monitoring_agent.sh` |
| Documentation | ✅ COMPLETE | `LEGAL_AGENT_GUIDE.md` |

---

## Deploy in 3 Commands

```bash
# 1. SSH to VM159
ssh simon@vm159.local

# 2. Run deployment
bash /home/simon/Learning-Management-System-Academy/scripts/deploy_legal_monitoring_agent.sh

# 3. Verify service running
sudo systemctl status legal-monitoring.service
```

**Time to deploy:** ~2 minutes  
**Agent runs:** 24/7 automatic  
**First capture:** Immediate  
**First report:** Within 24 hours

---

## Monitor While Running

```bash
# View latest captures (every 6 hours)
ls -lh ~/Learning-Management-System-Academy/legal-matters/digital-unicorn-icon-plc/legal_agent_monitoring/captures/ | tail -5

# View today's report
cat ~/Learning-Management-System-Academy/legal-matters/digital-unicorn-icon-plc/legal_agent_monitoring/reports/LEGAL_REPORT_$(date +%Y%m%d)_*.md

# Watch live service logs
sudo journalctl -u legal-monitoring.service -f
```

---

## Today's Email Reminder (Before 18:00 VN)

**Recipient:** lucas@digitalunicorn.fr, contact@digitalunicorn.fr, HR@, ha@, panos@  
**Subject:** Final Reminder – Unauthorized Use of Image & Outstanding Settlement – Legal Action Pending  
**Body:** See `/legal-matters/.../ESCALATION_ACTION_LOG_20251107.md` for exact wording  
**Deadline:** 18:00 Vietnam Time (GMT+7), November 7, 2025  

---

## Evidence Chain (For Court)

**When submitting to court, include:**
1. monitoring_index.json (master file with all SHA-256 hashes)
2. Latest screenshots (PNG 3–5 recent + PDF versions)
3. Daily legal report (LEGAL_REPORT_*.md from today)
4. Service logs (proof of continuous monitoring)
5. Metadata files (capture timestamps & hashes)

**Why this is strong:**
- ✅ Cryptographically verified (SHA-256)
- ✅ Timestamped with millisecond precision
- ✅ Automated (no human bias)
- ✅ Independent verification possible (Archive.ph)
- ✅ Continuous monitoring proves pattern

---

## If No Response by Nov 10

**Option A (France):** File CNIL complaint → https://www.cnil.fr/plainte  
**Option B (Vietnam):** Send lawyer letter via Lê Trọng Long  
**Option C (Pressure):** Escalate to ICON PLC procurement  

---

## Settlement Negotiation

**Opening position:** €8,000 (full amount)  
**Acceptable range:** €5,000–€7,000  
**Accept minimum:** €5,000 (with written release)  
**Terms:** Full payment + image removal proof + signed agreement

---

## Service Management

```bash
# Check status
sudo systemctl status legal-monitoring.service

# Stop service
sudo systemctl stop legal-monitoring.service

# Start service
sudo systemctl start legal-monitoring.service

# Restart service
sudo systemctl restart legal-monitoring.service

# Disable auto-start
sudo systemctl disable legal-monitoring.service

# View errors
sudo journalctl -u legal-monitoring.service -n 50
```

---

## File Locations Reference

```
Main directories:
📁 legal-matters/digital-unicorn-icon-plc/
   ├── 📄 FINAL_LEGAL_REPORT.docx          ← Main case report
   ├── 📄 ESCALATION_ACTION_LOG_20251107.md ← Email text
   ├── 📄 LEGAL_AGENT_GUIDE.md             ← Full operations guide
   ├── 📁 legal_agent_monitoring/          ← Continuous monitoring data
   │   ├── captures/                        ← Screenshots (every 6h)
   │   ├── reports/                         ← Daily legal reports
   │   └── logs/                            ← Activity logs
   └── 📁 website_captures/                ← Initial evidence

.continue/agents/
   └── legal_monitoring_agent.py           ← Main agent script

.continue/systemd/
   └── legal-monitoring.service            ← Systemd unit

scripts/
   ├── deploy_legal_monitoring_agent.sh    ← Full deployment
   └── deploy_legal_agent_quick.sh         ← Express deployment
```

---

## Key Dates

| Date | Deadline | Event |
|------|----------|-------|
| **Nov 7** | 18:00 VN | Image removal + payment demand deadline |
| **Nov 10** | EOD | If no response → escalate (CNIL/lawyer/ICON) |
| **Nov 17** | - | Consider court filing if no settlement |
| **Nov 24** | - | ~30 days evidence = very strong case |

---

## Emergency Procedures

**Service not starting?**
```bash
pip3 install playwright
python3 -m playwright install chromium
sudo systemctl restart legal-monitoring.service
```

**Need immediate capture?**
```bash
python3 /home/simon/Learning-Management-System-Academy/.continue/agents/legal_monitoring_agent.py
# Runs once then exits; service auto-restarts
```

**View evidence offline?**
```bash
# Export monitoring data
cp -r ~/Learning-Management-System-Academy/legal-matters/digital-unicorn-icon-plc/legal_agent_monitoring/ \
  ~/legal_evidence_backup_$(date +%Y%m%d)/
```

---

## Contact Info for Escalation

**Your Email:** sn.renauld@gmail.com  
**Vietnam Lawyer:** Lê Trọng Long (contact in evidence files)  
**CNIL (France):** https://www.cnil.fr/plainte  
**ICON PLC:** (escalation contact from earlier email evidence)  

---

## Success Indicators

✅ Service running 24/7 (check: `sudo systemctl status legal-monitoring.service`)  
✅ Captures created every 6 hours (check: `ls legal_agent_monitoring/captures/`)  
✅ Reports generated daily (check: `ls legal_agent_monitoring/reports/`)  
✅ Hashes verify correctly (check: `sha256sum` on files)  
✅ No errors in logs (check: `sudo journalctl -u legal-monitoring.service`)  

---

## Final Notes

- **This is evidence, not punishment.** You're documenting breach of contract + ignored demand.
- **Stay professional.** All correspondence should be factual, not emotional.
- **Settlement likely.** Once they see continuous automated monitoring + legal escalation, they usually negotiate.
- **You have leverage.** Unauthorized image use + nonpayment + ignored demands = strong case.
- **Timing matters.** Deploy agent TODAY before sending final email. Shows you're serious.

---

**Created:** November 7, 2025  
**Status:** READY TO DEPLOY  
**Next Action:** Send final email by 17:00 VN → Deploy agent → Monitor automatically

**Questions? See LEGAL_AGENT_GUIDE.md for comprehensive documentation.**
