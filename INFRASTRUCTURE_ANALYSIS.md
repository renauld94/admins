# 🏗️ Complete Infrastructure Analysis & Optimization Plan

**Analysis Date**: November 3, 2025  
**Server**: Hetzner i7-6700 FSN1-DC8 (136.243.155.166)

---

## 📊 CURRENT STATE SUMMARY

### Hardware Resources
- **CPU**: Intel Core i7-6700 (4 cores / 8 threads @ ~3.4GHz)
- **RAM**: 64GB DDR4
- **Storage**: 2x 512GB NVMe SSD (ZFS RAID mirror = 472GB usable)
- **Network**: 1 Gbit/s Intel I219-LM

### Proxmox Host Status
- **CPU Usage**: 18.2% (LOW - excellent headroom)
- **Memory**: 26GB / 62GB used (42% - healthy)
- **Load**: 0.23, 1.34, 2.31 (recent activity spike, now normal)
- **ZFS Pool**: **93% FULL** ⚠️ **CRITICAL** - Only 32.5GB free
- **Health**: ONLINE, no errors

---

## 🖥️ VM RESOURCE ALLOCATION

| VM ID | Name | vCPU | RAM | Disk Allocated | Disk Used | Status |
|-------|------|------|-----|----------------|-----------|--------|
| **159** | ubuntuai-1000110 | 8 | 49GB | 62GB + 300GB + 50GB | 84GB | ⚠️ **DISK WASTE** |
| 200 | nextcloud | 6 | 16GB | 332GB | 98GB | Running |
| 106 | geoneural | 8 | 16GB | 40GB | 40.6GB | Running |
| 9001 | moodle-lms | 4 | 8GB | 64GB | 55.6GB | Running |
| **TOTAL** | | **26/8** | **89/62GB** | **548GB** | **278GB** | **Over-allocated!** |

---

## 🔴 CRITICAL ISSUES IDENTIFIED

### 1. **VM 159 Storage Waste** ⚠️
**Problem**: 350GB allocated but only 84GB actually used
- `vm-159-disk-0` (scsi0): 16.3GB used / 62GB allocated = **45.7GB wasted**
- `vm-159-disk-1` (sata0): 67.8GB used / 300GB allocated = **232.2GB wasted** 
- `vm-159-disk-2` (scsi1): 56KB used / 50GB allocated = **50GB wasted**
- **TOTAL WASTE**: **327.9GB** (73% of VM's allocation!)

**Root Cause**: SCSI LUN mapping issue - Ubuntu can only see disk-0, other disks unreachable

### 2. **Proxmox ZFS 93% Full** 🔥
**Danger Zone**: Only 32.5GB free on 472GB pool
- Minimum safe: 10-15% free for ZFS performance
- Current: 7% free = **CRITICAL**
- Impact: Performance degradation, snapshot issues, no room for growth

### 3. **CPU Over-subscription**
- Physical cores: 4 (8 threads)
- Allocated vCPUs: 26
- Ratio: **3.25:1** (acceptable for mixed workloads)
- Impact: Minimal - actual usage is low

### 4. **Memory Over-commitment**
- Physical RAM: 62GB
- Allocated: 89GB
- Over-commit: **27GB** (43%)
- Status: **DANGEROUS** - Could cause swapping if all VMs peak

### 5. **OpenWebUI Down**
- URL: https://openwebui.simondatalab.de
- Status: **504 Gateway Timeout** (backend not running)
- Likely location: Not found on any VM
- Docker not installed on VM 159

---

## 💾 STORAGE BREAKDOWN

### ZFS Datasets (Top Space Consumers)
```
rpool/data/vm-200-disk-0      98.0GB  (Nextcloud - largest)
rpool/ROOT/pve-1              91.4GB  (Proxmox root - bloated!)
rpool/data/vm-159-disk-1      67.8GB  (Inaccessible to VM!)
rpool/data/vm-9001-disk-0     55.6GB  (Moodle)
rpool/media                   52.2G   (Media files)
rpool/data/vm-106-disk-0      40.6GB  (GeoNeural)
rpool/data/vm-159-disk-0      16.3GB  (AI VM - actual usage)
rpool/data/nextcloud-data     12.1GB  (Nextcloud data)
```

---

## 🎯 OPTIMIZATION RECOMMENDATIONS

### IMMEDIATE ACTIONS (Critical - Do Now)

#### 1. **Free Up Proxmox Root Space** 🔥
```bash
# Clean APT cache
apt-get clean
apt-get autoclean

# Remove old kernels (keep current + 1 backup)
pve-eselect-kvers

# Clean journal logs (keep 2 days)
journalctl --vacuum-time=2d

# Check for large files
du -sh /var/* | sort -h | tail -20
```
**Expected Recovery**: 5-20GB

#### 2. **Remove VM 159 Unused Disks**
```bash
# disk-1 (300GB SATA) - inaccessible, has 67.8GB data
# Options:
# A) Delete if data not critical
qm set 159 --delete sata0
zfs destroy rpool/data/vm-159-disk-1

# B) Try to access data first (mount on different VM/host)

# disk-2 (50GB SCSI) - nearly empty, safe to remove
qm set 159 --delete scsi1  
zfs destroy rpool/data/vm-159-disk-2
```
**Recovery**: 50GB immediately + 232GB if disk-1 deleted

#### 3. **Expand VM 159 Root Disk Properly**
Current issue: Configured 62GB but VM sees 40GB
```bash
# From Proxmox host:
qm stop 159
qm resize 159 scsi0 +30G  # Expand to 92GB total
qm start 159

# Inside VM after boot:
sudo growpart /dev/sda 3
sudo pvresize /dev/sda3
sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv
sudo resize2fs /dev/ubuntu-vg/ubuntu-lv
```
**Gain**: ~30GB usable space for models

### SHORT-TERM ACTIONS (This Week)

#### 4. **Download Larger Models** (If space allows)
Current: 4 models @ ~18GB total, 7.4GB free

**Options with current space**:
- ✅ Keep current 4 models
- ⚠️ Can't fit llama3.1:70b (40GB) or mixtral:8x7b (26GB)

**Options after disk expansion (+30GB)**:
- Could add codellama:13b (~7.3GB)
- Could add llama3.1:13b (~7.5GB)
- Could add qwen2.5:14b (~8.7GB)

#### 5. **Set Up OpenWebUI**
```bash
# Install Docker on VM 159
curl -fsSL https://get.docker.com | sh
systemctl enable --now docker

# Run OpenWebUI
docker run -d \
  --name open-webui \
  --restart always \
  -p 3000:8080 \
  -e OLLAMA_BASE_URL=http://localhost:11434 \
  -v open-webui:/app/backend/data \
  ghcr.io/open-webui/open-webui:main
```

#### 6. **Monitor & Alert Setup**
```bash
# Set up disk space alerts
zpool set threshold=85 rpool

# Monitor VM 159 performance
ssh simonadmin@10.0.0.110 \
  "watch -n 5 'df -h / && echo && free -h && echo && systemctl status ollama'"
```

### LONG-TERM OPTIMIZATIONS

#### 7. **Storage Expansion Options**
**Option A**: Add external storage box (Hetzner Storage Box)
- Cost: ~€3-10/month for 100GB-1TB
- Mount via NFS/SMB for model storage
- Keeps local ZFS for VMs only

**Option B**: Upgrade server storage
- Current: 2x 512GB NVMe (~€280 value)
- Upgrade: 2x 2TB NVMe (~€600)
- Gain: 1.4TB usable after ZFS mirror
- Cost: €600 + migration downtime

**Option C**: Reduce VM disk allocations
- VM 200 (Nextcloud): 332GB allocated, 98GB used = **234GB waste**
- Could shrink by 200GB (advanced - risky)

#### 8. **Performance Tuning**
**VM 159 Ollama Optimization**:
```bash
# Increase concurrent requests
Environment="OLLAMA_NUM_PARALLEL=8"

# Keep 2 models in RAM
Environment="OLLAMA_MAX_LOADED_MODELS=2"  

# Increase context size
Environment="OLLAMA_CONTEXT_LENGTH=8192"
```

**ZFS Optimization**:
```bash
# Enable compression on VM disks (if not already)
zfs set compression=lz4 rpool/data/vm-159-disk-0

# Disable sync for faster writes (slightly risky)
zfs set sync=disabled rpool/data/vm-159-disk-0
```

#### 9. **GPU Acceleration** (Future)
Current: CPU-only inference (~5-15 sec per query)
- Intel i7-6700 has no PCIe slots for GPU
- Could use USB eGPU (Thunderbolt - but no TB on server)
- **Not feasible without hardware upgrade**

#### 10. **Resource Rebalancing**
**Memory**:
- VM 159: 49GB → Could reduce to 32GB (still plenty)
- Recovered: 17GB for host/other VMs

**CPU**:
- Current over-subscription is fine
- Monitor actual usage before changes

---

## 📈 CAPACITY PLANNING

### Current Utilization
- **CPU**: 18% avg (excellent)
- **RAM**: 42% (healthy)  
- **Storage**: **93%** ⚠️ **CRITICAL**
- **Network**: Unknown (need monitoring)

### After Immediate Actions
- **Storage**: ~70-75% (healthy with cleanup + disk removal)
- **VM 159 space**: 37GB → 67GB (with expansion)
- **Model capacity**: 4 current + room for 2-3 more

### Growth Headroom
- **Can add**: 1-2 more small VMs
- **Cannot add**: Large VMs or significant storage
- **Bottleneck**: Storage (ZFS pool size)

---

## ✅ ACTION CHECKLIST

### Priority 1 - Critical (Do Today)
- [ ] Clean Proxmox root filesystem (expect 5-20GB recovery)
- [ ] Remove vm-159-disk-2 (50GB recovery)
- [ ] Decide on vm-159-disk-1 (300GB - inspect data first!)
- [ ] Monitor ZFS usage: `watch zpool list`

### Priority 2 - Important (This Week)
- [ ] Fix VM 159 disk resize issue (gain 30GB usable)
- [ ] Install and configure OpenWebUI
- [ ] Download 1-2 additional quality models
- [ ] Set up monitoring/alerts for disk usage

### Priority 3 - Nice to Have (This Month)
- [ ] Optimize Ollama settings for performance
- [ ] Configure ZFS compression on all VM disks
- [ ] Review and optimize other VM disk allocations
- [ ] Document model performance benchmarks

---

## 🎓 MODELS RECOMMENDATION

### Current Setup (Optimal for 37GB disk)
1. **llama3.1:8b** (4.9GB) - Best general purpose
2. **qwen2.5:7b-instruct** (4.7GB) - Best instruction following
3. **mistral:7b-instruct** (4.4GB) - Fast & high quality
4. **deepseek-coder:6.7b** (3.8GB) - Best for code

### If Expanded to 67GB (Future)
Add ONE of these:
- **codellama:13b** (7.3GB) - Better code than current
- **llama3.1:13b** (7.5GB) - More capable than 8b
- **qwen2.5:14b** (8.7GB) - Smarter reasoning
- **mixtral:8x22b** (requires 47GB) - State of the art (tight fit!)

### Do NOT Download (Too Large)
- ❌ llama3.1:70b (40GB) - won't fit
- ❌ mixtral:8x7b-instruct (26GB) - won't fit  
- ❌ qwen2.5:72b (42GB) - way too large

---

## 📞 SUPPORT RESOURCES

**Proxmox Documentation**: https://pve.proxmox.com/pve-docs/  
**Ollama Models**: https://ollama.com/library  
**OpenWebUI**: https://docs.openwebui.com/  
**ZFS Tuning**: https://openzfs.github.io/openzfs-docs/

**Hetzner Support**: https://robot.hetzner.com (for server specs/upgrades)

---

## 🏁 CONCLUSION

### What's Good ✅
- Excellent CPU headroom (18% usage)
- Healthy memory usage (42%)
- 4 quality AI models running well
- Fast NVMe storage with ZFS protection

### What's Critical ⚠️
- **Storage at 93%** - immediate action required
- **350GB wasted** in VM 159 unusable disks
- **OpenWebUI down** - needs setup
- **Over-allocated resources** - risky but manageable

### Recommended Focus
1. **Free up space** (cleanup + remove unused disks)
2. **Fix VM 159 disk** (get to 67GB usable)
3. **Set up OpenWebUI** (better UX than Continue alone)
4. **Monitor and maintain** (prevent future issues)

**Your infrastructure is powerful but storage-constrained. Address storage first, then optimize!**
