# PHASE 4 DEPLOYMENT - QUICK ACCESS INDEX

**Status:** ✅ READY FOR EXECUTION  
**Created:** 2025-11-10  
**Target:** CT 150 (10.0.0.150)

---

## 🚀 QUICK START (Copy & Paste)

```bash
# Step 1: Upload (30 seconds)
scp /tmp/CT150_COMPLETE_DEPLOY.sh root@10.0.0.150:/tmp/
scp /tmp/CT150_NETWORK_DEPLOY.sh root@10.0.0.150:/tmp/

# Step 2: Deploy (8-10 minutes)
ssh root@10.0.0.150
bash /tmp/CT150_COMPLETE_DEPLOY.sh

# Step 3: Configure Network (4-5 minutes)
bash /tmp/CT150_NETWORK_DEPLOY.sh

# Step 4: Test Access
curl http://10.0.0.150:8501/ -I
```

**Total Time:** ~15 minutes to live dashboard

---

## 📁 FILES REFERENCE

### Deployment Scripts (Ready to Upload)
| File | Size | Purpose | Location |
|------|------|---------|----------|
| `CT150_COMPLETE_DEPLOY.sh` | 15 KB | Main deployment | `/tmp/` |
| `CT150_NETWORK_DEPLOY.sh` | 9.3 KB | Network setup | `/tmp/` |
| `DEPLOYMENT_QUICK_REFERENCE.sh` | 9.5 KB | Execution guide | `/tmp/` |
| `PHASE4_EXECUTION_SUMMARY.sh` | Reference | Final summary | `/tmp/` |

### Documentation
| Document | Purpose | Location |
|----------|---------|----------|
| `PHASE_4_DEPLOYMENT_COMPLETE_PACKAGE.md` | Comprehensive guide with troubleshooting | Workspace |
| `PHASE_4_DEPLOYMENT_READY_COMPREHENSIVE_SUMMARY.md` | Executive summary & detailed breakdown | Workspace |
| `CT150_CLEANUP_EXPANSION_PLAN.md` | Disk management (PHASES 1-3) | Workspace |

---

## 🎯 WHAT GETS DEPLOYED

### To CT 150 at `/opt/job-search-automation/`
```
.venv/                          # Python 3.11 virtual environment
databases/
  ├── job_search.db            # Job opportunities
  ├── linkedin_contacts.db      # Network connections
  ├── resume_delivery.db        # Resume tracking
  ├── interview_scheduler.db    # Interview management
  ├── job_search_metrics.db     # Dashboard metrics
  └── networking_crm.db         # Contact management
logs/
  ├── dashboard.log
  ├── dashboard_error.log
  ├── job_discovery.log
  ├── linkedin_outreach.log
  └── resume_delivery.log
scripts/
  └── daily_automation.sh       # Cron script
streamlit_dashboard.py          # Dashboard
[+25 more Python modules]       # Application code
```

### System Services Created
- **Streamlit Dashboard** - Port 8501 (systemd service)
- **nginx Reverse Proxy** - Port 80 (automatic)
- **UFW Firewall Rules** - Ports 22, 80, 443, 8501

---

## 🎛️ ACCESS AFTER DEPLOYMENT

```bash
# Dashboard URLs
http://10.0.0.150:8501      # Direct Streamlit
http://10.0.0.150           # Via nginx proxy

# SSH Access
ssh root@10.0.0.150

# Service Management
ssh root@10.0.0.150 'systemctl status job-search-dashboard'
ssh root@10.0.0.150 'systemctl restart job-search-dashboard'

# View Logs
ssh root@10.0.0.150 'tail -f /opt/job-search-automation/logs/dashboard.log'
```

---

## ✅ VERIFICATION CHECKLIST

After deployment, verify:

- [ ] Dashboard accessible: `curl http://10.0.0.150:8501/ -I` → HTTP 200
- [ ] Service running: `systemctl status job-search-dashboard` → active
- [ ] Port listening: `ss -tuln | grep 8501` → LISTEN 127.0.0.1:8501
- [ ] Databases exist: `ls /opt/job-search-automation/databases/` → 6 .db files
- [ ] Browser test: Open `http://10.0.0.150:8501` → Dashboard loads
- [ ] nginx running: `systemctl status nginx` → active

---

## 🔧 TROUBLESHOOTING

### Dashboard Not Accessible
1. Check service: `ssh root@10.0.0.150 'systemctl status job-search-dashboard'`
2. Check logs: `ssh root@10.0.0.150 'tail -50 /opt/job-search-automation/logs/dashboard_error.log'`
3. Check port: `ssh root@10.0.0.150 'ss -tuln | grep 8501'`

### nginx Not Proxying
1. Test config: `ssh root@10.0.0.150 'nginx -t'`
2. Restart: `ssh root@10.0.0.150 'systemctl restart nginx'`
3. Check logs: `ssh root@10.0.0.150 'tail -20 /var/log/nginx/job-search_error.log'`

### Still Not Working?
See `PHASE_4_DEPLOYMENT_COMPLETE_PACKAGE.md` (detailed troubleshooting section)

---

## ⏰ AUTOMATION SETUP (After Deployment)

To enable daily automation:

```bash
ssh root@10.0.0.150
crontab -e

# Add this line:
0 7 * * * /opt/job-search-automation/scripts/daily_automation.sh
```

Schedule (UTC+7):
- 7:00 AM → Job discovery
- 7:15 AM → LinkedIn outreach
- 7:30 AM → Resume delivery

---

## 📊 WHAT THE DASHBOARD SHOWS

After deployment, view:

- **📈 Job Discovery** - Daily opportunities, avg score, top roles
- **💼 LinkedIn** - New connections, messages, profile views
- **📄 Resumes** - Tailored resumes generated, delivery status
- **🎯 Interviews** - Scheduled interviews, prep progress
- **📊 System** - Uptime, last run time, resource usage

---

## 🆘 HELP RESOURCES

| Issue | Command | Reference |
|-------|---------|-----------|
| Can't access dashboard | `curl http://10.0.0.150:8501/ -I` | Troubleshooting section above |
| Service not running | `systemctl status job-search-dashboard` | PHASE_4_DEPLOYMENT_COMPLETE_PACKAGE.md |
| Port not listening | `ss -tuln \| grep 8501` | Network diagnostics |
| Firewall issues | `ufw status` | UFW configuration guide |

---

## 📞 KEY CONTACTS / COMMANDS

```bash
# Full deployment status
ssh root@10.0.0.150 << 'EOF'
echo "=== SERVICE STATUS ==="
systemctl status job-search-dashboard --no-pager
echo ""
echo "=== PORTS LISTENING ==="
ss -tuln | grep -E '80|8501'
echo ""
echo "=== DATABASES ==="
ls -lh /opt/job-search-automation/databases/
echo ""
echo "=== DISK SPACE ==="
df -h /
echo ""
echo "=== MEMORY ==="
free -h
EOF

# Quick log check
ssh root@10.0.0.150 'tail -20 /opt/job-search-automation/logs/dashboard.log'

# Restart services
ssh root@10.0.0.150 'systemctl restart job-search-dashboard nginx'
```

---

## ⚡ IMPORTANT NOTES

1. **Deployment is idempotent** - Can re-run scripts if needed
2. **No data loss on redeployment** - Databases preserved
3. **Services auto-start** - No manual restart needed after reboot
4. **Logs rotate** - Check `/opt/job-search-automation/logs/`
5. **Can update code** - Copy new Python modules anytime
6. **Scale if needed** - Monitor resources after first week

---

## 🎉 SUCCESS CRITERIA

You'll know everything worked when:

1. ✅ `http://10.0.0.150:8501` loads in browser
2. ✅ Dashboard shows job metrics
3. ✅ Services show "active (running)"
4. ✅ 6 database files exist
5. ✅ No errors in logs
6. ✅ Can SSH and check status

---

## 📈 NEXT STEPS AFTER DEPLOYMENT

1. **Monitor first 24 hours** - Watch logs for any issues
2. **Test automation at 7 AM** - Verify cron job runs (if enabled)
3. **Add to crontab** - Enable daily automation
4. **Adjust thresholds** - Fine-tune job matching criteria if needed
5. **Set up alerts** - Monitor dashboard metrics
6. **Document credentials** - Store API keys securely

---

## 🚀 YOU'RE READY!

All scripts are created and tested. Execute the 3 commands above to go live.

**Questions?** See comprehensive documentation in workspace.

**Ready?** Run: `scp /tmp/CT150_COMPLETE_DEPLOY.sh root@10.0.0.150:/tmp/`

Let's go! 🎯
