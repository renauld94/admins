# CT 150 Cleanup & Expansion Plan

## Overview
Prepare CT 150 (portfolio-web-1000150) to host the job search automation system alongside the existing portfolio web service.

## Current State
- **Disk**: 8 GB (7.52 GB used, 480 MB free) ❌ **TOO SMALL**
- **RAM**: 1 GB (used by portfolio web)
- **CPU**: 2 cores
- **Status**: Running, stable

## Target State  
- **Disk**: 15 GB (7.52 GB used, ~7.2 GB free) ✅ **SUFFICIENT**
- **RAM**: 1 GB (shared between both services)
- **CPU**: 2 cores
- **Status**: Running both portfolio web + job search automation

---

## Execution Plan

### Phase 1: Cleanup Inside CT 150 (5 minutes)

**Access CT 150:**
```bash
ssh -J [jump-user]@[jump-host] root@10.0.0.150
```

**Run cleanup commands:**
```bash
# APT package cache (~200-300 MB)
apt-get clean
apt-get autoclean
apt-get autoremove -y

# Old journal logs (~100-200 MB)
journalctl --vacuum=time=7d

# Old log archives (~50-100 MB)
rm -rf /var/log/*.*.gz /var/log/*.*.1 /var/log/*.*.2 2>/dev/null || true

# Temporary files (~50-100 MB)
rm -rf /tmp/* /var/tmp/* 2>/dev/null || true
rm -rf /var/cache/apt/archives/* 2>/dev/null || true

# Verify results
df -h /
```

**Expected Result**: ~1.5-2 GB free disk space

**Safety**: Only removes caches and old logs, NOT application data

---

### Phase 2: Expand Disk on Proxmox Host (7 minutes)

**Access PVE node:**
```bash
ssh root@pve
```

**Stop container:**
```bash
pct stop 150
```

**Expand logical volume (8 GB → 15 GB, +7 GB):**
```bash
lvresize -L +7G /dev/pve/vm-150-disk-0
```

**Start container:**
```bash
pct start 150
sleep 10
```

**Resize filesystem inside container:**
```bash
pct exec 150 -- resize2fs /dev/mapper/pve-vm--150--disk--0
```

**Verify expansion:**
```bash
pct exec 150 -- df -h /
```

**Expected Result**: 
- Filesystem: 15G total
- Free space: ~7-8 GB
- Status: Clean boot, all systems responsive

---

### Phase 3: Verify Expansion (3 minutes)

**SSH into CT 150:**
```bash
ssh root@10.0.0.150
```

**Check disk space:**
```bash
df -h /
# Expected: 15G total, 6-7 GB free
```

**Verify portfolio web still runs:**
```bash
systemctl status portfolio-web
# Expected: active (running)
```

**Check available memory:**
```bash
free -h
# Expected: 200-300 MB RAM available
```

**Test system operations:**
```bash
apt update
python3 --version
```

**Expected Results**:
- ✅ 6-7 GB free disk space
- ✅ Portfolio web service running
- ✅ 200-300 MB RAM available
- ✅ Package manager responsive
- ✅ Python available

---

## What Gets Cleaned

### Safe Removals (NO RISK)
| Component | Size | Commands |
|-----------|------|----------|
| APT cache | 200-300 MB | `apt-get clean && apt-get autoclean` |
| Journal logs | 100-200 MB | `journalctl --vacuum=time=7d` |
| Temp files | 50-100 MB | `rm -rf /tmp/* /var/tmp/*` |
| Old logs | 50-100 MB | `rm -rf /var/log/*.*.gz` |
| **Total** | **1.5-2 GB** | **~5-10 minutes** |

### NOT Removed (Safe)
- ✅ Application files
- ✅ Web assets
- ✅ Configuration files
- ✅ Database files
- ✅ User data

---

## Resource Comparison

| Metric | Before | After | Change | Status |
|--------|--------|-------|--------|--------|
| Disk Total | 8 GB | 15 GB | +7 GB | ✅ |
| Disk Free | 480 MB | 7.2 GB | +6.7 GB | ✅ |
| Disk Used % | 94% | 50% | -44% | ✅ |
| Available for new | 480 MB | 7.2 GB | +1400% | ✅ |
| CPU Cores | 2 | 2 | — | ✅ |
| Memory | 1 GB | 1 GB | — | ⚠️ Monitor |

---

## Deployment Requirements

### For Job Search System on CT 150
- **Disk space**: 2.5-3 GB ✅ (will have 7 GB free)
- **Python**: 3.11+ ✅ (will install)
- **RAM**: 400-600 MB ⚠️ (tight with portfolio web)
- **Cron**: Available ✅
- **Network**: 10.0.0.150 ✅

### Monitoring Recommendations
After deployment, monitor:
- Memory usage (both services combined)
- Disk usage growth
- CPU load during automation runs
- Portfolio web performance

---

## Timeline

| Phase | Duration | Downtime | Status |
|-------|----------|----------|--------|
| Cleanup inside CT | 5 min | None | Container running |
| Stop container | <1 min | 1 min | Portfolio web down |
| Expand disk | 2 min | During stop/start | LVM operation |
| Resize filesystem | 2 min | During stop/start | Filesystem resize |
| Start container | 2 min | 1 min total | Container rebooting |
| Verify | 3 min | None | Container running |
| **Total** | **15 min** | **~1 min** | |

---

## Risk Assessment

### Low Risk ✅
- Cleanup only removes caches/logs (standard maintenance)
- Disk expansion uses LVM (reversible if needed)
- Filesystem resize is standard operation
- Portfolio web data remains untouched

### Medium Risk ⚠️
- Brief downtime (~1 minute) during stop/start
- Both services share 1 GB RAM (monitor after deployment)
- Filesystem resize could fail if disk is corrupted (unlikely)

### Mitigation
- Proxmox snapshots enabled before expansion
- Test portfolio web after restart
- Monitor resources post-deployment
- Can scale to separate CT if RAM becomes bottleneck

---

## Next Steps

### After Successful Verification
1. ✅ Cleanup complete
2. ✅ Disk expanded to 15 GB
3. ✅ Portfolio web verified running
4. 🚀 Deploy job search system:
   - Python 3.11 venv
   - All 27 modules
   - 6 SQLite databases
   - Streamlit dashboard
   - Nginx reverse proxy
   - SSL/TLS certificate
   - Systemd services
   - Cron jobs (7 AM, 7:15 AM, 7:30 AM UTC+7)
   - Firewall rules
   - Backup scripts

### Deployment Time: 10-15 minutes

### Access After Deployment
- **Dashboard**: http://10.0.0.150:8501
- **SSH**: root@10.0.0.150
- **Logs**: /var/log/job-search-automation/
- **Cron**: Automated (no manual intervention needed)

---

## Important Notes

1. **Backup**: Ensure Proxmox snapshots are enabled before starting
2. **Downtime**: ~1 minute during stop/start phase
3. **Data Safety**: Only caches removed, no application data touched
4. **Portfolio Web**: Will restart - must verify it works after
5. **Resource Sharing**: Both services will share resources
   - Can scale to separate CT if performance issues arise
   - Monitor memory usage post-deployment

---

## Troubleshooting

### If Cleanup Fails
```bash
# Check available space before cleanup
df -h /
du -sh /*

# Manual cleanup
apt-get clean
rm -rf /var/log/*.*.gz
```

### If Disk Expansion Fails
```bash
# Check LVM status
lvdisplay
pvdisplay

# Verify disk device name
df / | tail -1
```

### If Container Won't Start
```bash
# Check logs
pct status 150
pct config 150

# Manual fsck
fsck -y /dev/mapper/pve-vm--150--disk--0
```

---

## Confirmation Checklist

Before proceeding, confirm:
- [ ] Read entire plan
- [ ] Backup/snapshots enabled in Proxmox
- [ ] Access credentials ready (SSH, Proxmox)
- [ ] Willing to accept ~1 minute downtime
- [ ] Portfolio web can be monitored after
- [ ] Ready to deploy job search system

---

**Status**: Ready to execute ✅  
**Created**: 2025-11-10  
**Estimated Completion**: 2025-11-10 + 15 minutes  
**Target**: Operational job search system running on CT 150 by Nov 10
