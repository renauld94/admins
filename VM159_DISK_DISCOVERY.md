# 🎉 MAJOR DISCOVERY: VM-159 Hidden Disk Analysis

**Date:** November 4, 2025  
**Disk:** sata0 (vm-159-disk-1) - 300GB allocated, 61GB used

---

## 📊 What's On This Disk

```
19GB    ollama_models/      ← Additional AI models!
17GB    swapfile            ← Can DELETE
12GB    docker/             ← Docker containers
8.5GB   ai-venv/            ← Python environment
1.6GB   openwebui-data/     ← OpenWebUI backend!
374MB   open-webui/         ← OpenWebUI source
4.2GB   ollama/             ← Ollama installation
636KB   installer_logs/
16KB    models/
```

**Total Used:** 61GB / 295GB (22% - plenty of room!)

---

## 🔍 KEY FINDINGS

### 1. **OpenWebUI IS HERE!** ✅
- **Backend data:** 1.6GB at `/mnt/vm159-disk1-inspect/openwebui-data/`
- **Source code:** 374MB at `/mnt/vm159-disk1-inspect/open-webui/`
- **Status:** Not running (VM can't access this disk due to SCSI LUN bug)
- **This explains the 504 error!**

### 2. **Extra Ollama Models!** ✅
- **19GB of models** in `ollama_models/`
- Likely includes larger models you tried to download before
- Could move to accessible disk

### 3. **Large Swapfile** ⚠️
- **17GB swapfile** - can be deleted (VM has 49GB RAM, doesn't need swap)
- **Recovery potential:** 17GB

### 4. **Docker Containers** 
- **12GB** of Docker data
- Contains OpenWebUI and other services
- Need Docker installed on accessible disk

---

## 🎯 THREE OPTIONS

### **Option A: FIX SCSI LUN (Complex but Best)**
**Pros:**
- Access full 300GB disk
- OpenWebUI works immediately
- 19GB of existing models available
- 220GB free space for HUGE models

**Cons:**
- Requires kernel parameter changes
- May need VM reconfiguration
- Technical complexity

**Steps:**
1. Research proper SCSI addressing for Ubuntu
2. Test with different controller types (VirtIO, IDE)
3. Or: Detach sata0, attach as scsi0 (requires disk shuffle)

---

### **Option B: MIGRATE DATA TO MAIN DISK (Recommended)**
**Pros:**
- Simpler and safer
- Get OpenWebUI working
- Access those 19GB models
- Keep current stable setup

**Cons:**
- Takes time to copy data
- Need 25-30GB free on main disk (you have 7.4GB)
- Must delete swapfile and some Docker data

**Steps:**
```bash
# 1. Mount this disk from Proxmox
mount /dev/zd32p1 /mnt/old-disk

# 2. Copy important data to main disk
rsync -av /mnt/old-disk/ollama_models/ /new/location/
rsync -av /mnt/old-disk/openwebui-data/ /new/location/

# 3. Delete swapfile (17GB recovery)
rm /mnt/old-disk/swapfile

# 4. After migration, DELETE disk-1 entirely
qm set 159 --delete sata0
zfs destroy rpool/data/vm-159-disk-1
# → Frees 67.8GB on Proxmox!
```

---

### **Option C: DELETE DISK & START FRESH (Fastest)**
**Pros:**
- Immediate 67.8GB recovery on Proxmox
- Clean slate
- Reinstall OpenWebUI on accessible disk

**Cons:**
- Lose 19GB of models (but can re-download)
- Lose OpenWebUI data (but can reconfigure)
- Some work lost

**Steps:**
```bash
# From Proxmox:
qm set 159 --delete sata0
zfs destroy rpool/data/vm-159-disk-1

# Proxmox: 93% → 79% (67.8GB freed)
# Then install OpenWebUI fresh on main disk
```

---

## 💡 MY RECOMMENDATION

**DO OPTION B (Migrate)**:

### **Phase 1: Free Up Space on Main Disk First**
```bash
# Clean more on main disk to make room
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.110 bash <<'EOF'
# Remove partial downloads if any
rm -rf /tmp/*
# Clean Docker if installed
docker system prune -af 2>/dev/null || true
EOF
```

### **Phase 2: Migrate Critical Data**
```bash
# From Proxmox host:
mount /dev/zd32p1 /mnt/source
mkdir -p /mnt/target

# Inside VM, make space:
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.110 \
  "mkdir -p ~/recovered-models ~/recovered-openwebui"

# Copy via Proxmox (faster):
# 1. Copy 19GB models
rsync -av --progress /mnt/source/ollama_models/ \
  /path/to/vm159/home/simonadmin/recovered-models/

# 2. Copy OpenWebUI data
rsync -av --progress /mnt/source/openwebui-data/ \
  /path/to/vm159/home/simonadmin/recovered-openwebui/
```

### **Phase 3: Delete Old Disk**
```bash
# After confirming data is safe:
umount /mnt/source
qm set 159 --delete sata0
zfs destroy rpool/data/vm-159-disk-1

# Result: Proxmox goes from 87% → ~73% (67.8GB freed!)
```

### **Phase 4: Expand Main Disk**
```bash
# With Proxmox space freed, expand VM disk:
qm resize 159 scsi0 +50G  # Add 50GB to main disk
# Inside VM, expand filesystem
sudo growpart /dev/sda 3
sudo pvresize /dev/sda3
sudo lvextend -L +50G /dev/ubuntu-vg/ubuntu-lv
sudo resize2fs /dev/ubuntu-vg/ubuntu-lv

# Result: VM goes from 37GB → 87GB usable!
```

---

## 📈 FINAL STATE (After Full Migration)

### **Proxmox:**
- Before: 93% full (439GB used)
- After cleanup: 87% (415GB used)  ← Current
- After disk deletion: **73% (348GB used, 124GB free)** ← Target

### **VM 159:**
- Before: 37GB total, 7.4GB free
- After expansion: **87GB total, 57GB free**

### **Models:**
- Current 4 models: ~18GB
- Recovered models: ~19GB
- **Total: 37GB of models!**
- **Free space for more: 20GB+**

### **OpenWebUI:**
- Status: Working (after migration)
- Data: Preserved from old disk
- Access: https://openwebui.simondatalab.de (will work!)

---

## 🚀 IMMEDIATE ACTIONS

**Want me to execute this plan?**

**Step 1:** Delete the 17GB swapfile (safe, immediate)
**Step 2:** Prepare migration of 19GB models
**Step 3:** Set up OpenWebUI on accessible disk
**Step 4:** Delete old disk → free 67.8GB on Proxmox
**Step 5:** Expand main disk → 87GB total
**Step 6:** Download 2-3 HUGE models!

---

## 🎓 BONUS: Models You Could Download After This

With 57GB free after expansion:

1. **llama3.1:70b** (40GB) - State of the art
2. **mixtral:8x7b** (26GB) - Expert mixture
3. **codellama:34b** (19GB) - Best code model
4. **qwen2.5:32b** (20GB) - Powerful reasoning

Or **10-15 smaller 7B models** for variety!

---

**Ready to execute? This will:**
- ✅ Fix OpenWebUI (504 → working)
- ✅ Recover 19GB of models
- ✅ Free 67.8GB on Proxmox
- ✅ Expand VM to 87GB
- ✅ Download huge models!

**Next command ready - say "GO" to proceed!**
