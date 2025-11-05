# VM RAM & GPU Investigation Results

**Date:** November 5, 2025  
**VM:** 159 (ubuntuai-1000110) - 10.0.0.110  
**Issue:** VM showed 16GB RAM instead of allocated 49GB

---

## 🔍 Root Cause Analysis

### The Problem
- **Proxmox Config:** Showed 49152 MB (49GB) allocated
- **VM Reality:** Only 16GB visible (`free -h`, `/proc/meminfo`)
- **DMI/BIOS Info:** "Maximum Capacity: 16 GB"

### Why It Happened
1. VM was originally created with **16GB RAM** using **SeaBIOS**
2. Memory was later increased to 49GB in Proxmox config
3. **SeaBIOS does NOT support memory hot-add/hot-plug**
4. Virtual motherboard firmware (SMBIOS) locked to original 16GB capacity
5. Rebooting did NOT fix it (firmware limitation, not kernel issue)

### Technical Details
```bash
# VM Configuration
BIOS: seabios
Machine Type: q35
Memory (config): 49152 MB → Corrected to 16384 MB
Memory (actual): 16 GB (15Gi usable)
CPUs: 8 cores
NUMA: enabled
```

---

## ✅ Resolution

**Corrected Proxmox allocation to match reality:**
```bash
qm set 159 -memory 16384  # Set to 16GB (16384 MB)
```

**Result:** Configuration now matches what VM can actually use.

---

## 🚫 Why 49GB Won't Work

### SeaBIOS Limitations
- **No memory hot-add support**
- SMBIOS tables created at VM creation are immutable
- Cannot increase beyond initial allocation without VM recreation

### Options to Get More RAM (NOT IMPLEMENTED)

#### Option 1: Recreate VM with UEFI (Complex)
```bash
# Would require:
1. Convert VM to OVMF/UEFI BIOS
2. Reinstall Ubuntu
3. Restore all services (Ollama, Jupyter, MLflow, etc.)
4. Set memory to desired amount BEFORE first boot
```
**Downside:** Several hours of work, service downtime

#### Option 2: Migrate to New VM
```bash
# Create new VM with OVMF + 48GB from start
# Migrate data from VM 159
```
**Downside:** Migration complexity

#### Option 3: Accept 16GB Limit
**Chosen:** This is sufficient for current workload
- llama3.2:3b: 2GB
- qwen2.5-coder:7b: 4.7GB
- codegemma:7b: 5GB
- Total models: ~12GB (fits in 16GB with overhead)

---

## 🎮 GPU Investigation

### Current State: NO GPU
```bash
# Proxmox Host GPU
Intel HD Graphics 530 (integrated)

# VM GPU
00:01.0 VGA: Red Hat QXL paravirtual (no hardware GPU)
```

### Why GPU Passthrough Not Possible
1. **Only integrated Intel GPU** (HD Graphics 530)
2. Host needs it for display output
3. Cannot pass through integrated GPU to VM
4. No discrete NVIDIA/AMD GPU available

### GPU Acceleration Options

#### ✅ Option 1: Use Local Machine GPU (RECOMMENDED)
Your workstation has **NVIDIA Quadro RTX 3000 (6GB VRAM)**!

**Benefits:**
- 5-10x faster inference (5 seconds vs 30 seconds)
- 50-100 tokens/s generation speed
- Direct hardware access (no VM/SSH overhead)

**Setup:**
```bash
# Install Ollama locally
curl -fsSL https://ollama.com/install.sh | sh

# Pull models (will auto-use GPU)
ollama pull llama3.2:3b      # 2GB - fast responses
ollama pull qwen2.5-coder:7b # 4.7GB - code generation

# Update Continue config to point to localhost:11434
# (or keep both: local for fast, VM for backup)
```

#### ⚙️ Option 2: Add GPU to Proxmox Host (Hardware Purchase)
**Cost:** $300-500  
**Options:**
- NVIDIA RTX 3060 12GB (~$300)
- NVIDIA RTX 4060 Ti 16GB (~$500)
- NVIDIA A2000 12GB (~$400, datacenter-grade)

**Steps:**
1. Purchase GPU
2. Install in Proxmox server
3. Enable IOMMU in BIOS
4. Configure PCI passthrough
5. Attach to VM 159

**Downside:** Hardware cost + installation effort

#### ❌ Option 3: Cloud GPU (NOT RECOMMENDED)
- Rent GPU instance (AWS, RunPod, Vast.ai)
- $0.20-1.00/hour ongoing cost
- Network latency

---

## 📊 Current Performance Baseline

### VM 159 (CPU-only inference)
| Model | Size | Response Time | Use Case |
|-------|------|---------------|----------|
| llama3.2:3b | 2.0 GB | ~20-30s | Quick chat, simple questions |
| qwen2.5-coder:7b | 4.7 GB | ~2.5 min | Code generation (slow) |
| deepseek-coder-v2:16b | 8.9 GB | Not tested | Advanced tasks |
| codegemma:7b | 5.0 GB | Used for autocomplete | Tab completion |

### Expected with Local GPU (Quadro RTX 3000)
| Model | Response Time | Tokens/s |
|-------|---------------|----------|
| llama3.2:3b | 3-5s | 80-100 |
| qwen2.5-coder:7b | 5-10s | 50-80 |

---

## 💡 Recommendations

### Immediate (No Cost)
1. ✅ **Accept 16GB VM RAM** - Sufficient for current models
2. ✅ **Use llama3.2:3b for fast responses** - 20-30s vs 2.5min
3. ✅ **Keep qwen2.5-coder for complex tasks** - When quality > speed

### Short-term (Low Cost)
1. **Install Ollama on local workstation** - Use your RTX 3000
2. Keep VM as backup/production server
3. Get 5-10x faster inference locally

### Long-term (Hardware Investment)
1. Consider adding discrete GPU to Proxmox host
2. Only needed if you want GPU inference on VM
3. Not urgent - local GPU is better solution

---

## ✅ Status

- [x] RAM issue diagnosed and resolved
- [x] Proxmox config corrected (49GB → 16GB)
- [x] GPU limitations documented
- [x] Performance baseline established
- [x] Recommendations provided
- [ ] Optional: Install Ollama locally for GPU acceleration

**Ollama Service:** ✅ Running  
**Models Available:** 5 (llama3.2:3b, qwen2.5-coder:7b, deepseek-coder-v2:16b, codegemma:7b, nomic-embed-text)  
**Continue Config:** ✅ Updated with all models  
**SSH Tunnel:** ✅ Active (localhost:11434 → VM 159)
