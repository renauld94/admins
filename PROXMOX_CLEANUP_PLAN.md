# 🧹 Proxmox ZFS Cleanup Plan

**Date:** November 4, 2025  
**Current Status:** 93% FULL (439GB / 472GB used) - CRITICAL  
**Target:** Get below 80% (377GB used, 95GB free)  
**Need to Free:** ~62GB minimum

---

## 📊 Cleanup Opportunities (Total: 90.1GB Recoverable)

### 🔴 HIGH PRIORITY (Safe & High Impact)

#### 1. **Old Snapshot** → **15.8GB**
```bash
# Safe to delete (from Oct 30, 2025)
zfs destroy rpool/data/vm-9001-disk-0@pre-cleanup-2025-10-30
```
**Risk:** LOW (snapshot is 5 days old, VM is running fine)  
**Recovery:** 15.8GB

---

#### 2. **Duplicate Ubuntu ISOs** → **6.1GB**
```bash
# Keep only latest (ubuntu-24.04.3)
rm /var/lib/vz/template/iso/noble-live-server-amd64.iso        # 3.1GB
rm /var/lib/vz/template/iso/ubuntu-24.04.2-live-server-amd64.iso  # 3.0GB
```
**Risk:** LOW (you have the latest 24.04.3 version)  
**Recovery:** 6.1GB

---

#### 3. **APT Cache** → **1.3GB**
```bash
apt-get clean
apt-get autoclean
```
**Risk:** NONE (can always re-download)  
**Recovery:** 1.3GB

---

#### 4. **Journal Logs** → **1.7GB**
```bash
journalctl --vacuum-time=7d  # Keep only last 7 days
```
**Risk:** LOW (older logs rarely needed)  
**Recovery:** ~1.0GB

---

### 🟡 MEDIUM PRIORITY (Review Before Deleting)

#### 5. **Insta360/Media Files** → **50GB**
Located at `/rpool/media/insta360/`

**Largest files:**
- `VID_20250520_202420_182.mp4` (1.8GB)
- `The.Last.of.Us.S02E01.1080p.x265-ELiTE.mkv` (1.2GB)
- `VID_20250510_201009_006.mp4` (1009MB)
- Many 400-600MB video files

**Options:**
- Move to external storage (NAS, cloud)
- Delete if backed up elsewhere
- Keep if actively used

**Risk:** MEDIUM (personal videos, check if backed up first)  
**Recovery:** Up to 50GB

---

#### 6. **VM-159 Disk-1 (Inaccessible)** → **67.8GB**
This 300GB disk exists but VM can't access it (SCSI LUN issue).

**What to do:**
1. Mount it from Proxmox host to inspect contents
2. If contains old/duplicate data → DELETE
3. If contains important data → try to fix SCSI LUN or migrate

**Command to inspect:**
```bash
# This is a zvol, not mountable directly
# Need to check if it's actually being used
zfs get all rpool/data/vm-159-disk-1
```

**Risk:** UNKNOWN (need to inspect first)  
**Recovery:** 67.8GB (if safe to delete)

---

### 🟢 LOW PRIORITY (Minor Impact)

#### 7. **Template Cache** → **843MB**
```bash
rm -rf /var/lib/vz/template/cache/*
```
**Recovery:** 843MB

#### 8. **Proxmox Backup Cache** → **29MB**
```bash
rm -rf /var/cache/proxmox-backup/*
```
**Recovery:** 29MB

---

## ✅ Recommended Immediate Action Plan

### Phase 1: Quick Wins (Safe, 24GB recovery)
```bash
ssh root@136.243.155.166 -p 2222 bash <<'EOF'
echo "=== PHASE 1: SAFE CLEANUP ==="

# 1. Delete old snapshot (15.8GB)
echo "Destroying old snapshot..."
zfs destroy rpool/data/vm-9001-disk-0@pre-cleanup-2025-10-30

# 2. Remove duplicate ISOs (6.1GB)
echo "Removing old Ubuntu ISOs..."
rm /var/lib/vz/template/iso/noble-live-server-amd64.iso
rm /var/lib/vz/template/iso/ubuntu-24.04.2-live-server-amd64.iso

# 3. Clean APT cache (1.3GB)
echo "Cleaning APT cache..."
apt-get clean
apt-get autoclean

# 4. Clean journal logs (1.0GB)
echo "Cleaning old journal logs..."
journalctl --vacuum-time=7d

echo ""
echo "=== CLEANUP COMPLETE ==="
zpool list rpool
EOF
```

**Expected Result:** 
- Before: 93% full (439GB used, 32.5GB free)
- After: 88% full (415GB used, 56.5GB free)

---

### Phase 2: Media Review (Manual Decision)

**Backup first, then delete:**
```bash
# List all media files by size
ssh root@136.243.155.166 -p 2222 "du -ah /rpool/media/insta360/ | sort -h"

# Copy to external storage if needed
# Then delete: rm /rpool/media/insta360/[filename]
```

---

### Phase 3: VM-159 Disk-1 Investigation

**Check what's on the inaccessible 67.8GB disk:**
```bash
ssh root@136.243.155.166 -p 2222 bash <<'EOF'
echo "=== VM-159 DISK-1 DETAILS ==="
zfs get all rpool/data/vm-159-disk-1 | grep -E "(used|refer|creation|volsize)"

echo ""
echo "=== CHECKING IF IT'S IN USE ==="
qm config 159 | grep -i sata0
EOF
```

**Options:**
1. If old/unused → Delete (67.8GB recovery)
2. If needed → Fix SCSI LUN issue
3. If backup → Migrate data then delete

---

## 📈 Expected Outcomes

| Phase | Recovery | Final % | Status |
|-------|----------|---------|--------|
| **Current** | - | 93% (32.5GB free) | 🔴 CRITICAL |
| **Phase 1** | 24GB | 88% (56.5GB free) | 🟠 WARNING |
| **Phase 2** | +50GB | 77% (106.5GB free) | 🟢 HEALTHY |
| **Phase 3** | +67.8GB | 64% (174.3GB free) | 🟢 EXCELLENT |

---

## ⚠️ Safety Checklist

Before running Phase 1:
- [ ] Verify all VMs are running normally
- [ ] Check no critical services depend on deleted files
- [ ] Have Proxmox backup (external)
- [ ] Can access server console (not just SSH)

---

## 🚀 Execute Now?

**SAFE to run Phase 1 immediately** (24GB recovery, no risk).

Would you like me to:
1. ✅ **Run Phase 1 now** (safe cleanup)
2. ⏸️ **Investigate VM-159 disk-1 first** (understand before cleanup)
3. 📁 **Review media files** (manual decision needed)

---

**Next Command Ready:**
```bash
# Run this to execute Phase 1 (SAFE)
ssh root@136.243.155.166 -p 2222 bash <<'EOF'
zfs destroy rpool/data/vm-9001-disk-0@pre-cleanup-2025-10-30
rm /var/lib/vz/template/iso/noble-live-server-amd64.iso
rm /var/lib/vz/template/iso/ubuntu-24.04.2-live-server-amd64.iso
apt-get clean && apt-get autoclean
journalctl --vacuum-time=7d
zpool list rpool
EOF
```
