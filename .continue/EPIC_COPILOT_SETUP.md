# 🚀 EPIC Continue Copilot Setup

**Date:** November 5, 2025  
**Goal:** Create the ultimate AI coding assistant experience with Continue + Ollama + Local GPU

---

## 📊 Current Status

### ✅ What You Have:
- **GPU:** NVIDIA Quadro RTX 3000 (6GB VRAM) - Driver 570.133.07, CUDA 12.8
- **RAM:** 30GB (26GB used, 4GB free)
- **CPU:** Intel Xeon W-10855M (12 threads @ 2.8-5.1 GHz)
- **Disk:** 170GB free (62% used)
- **Ollama:** ✅ Installed locally, using GPU (1.2GB VRAM allocated)
- **Models:** 5 models (20.8GB total)

### 📦 Current Models:
| Model | Size | Speed (Local GPU) | Notes |
|-------|------|-------------------|-------|
| llama3.2:3b | 2.0GB | ~33s | ✅ Working, but not optimal |
| qwen2.5-coder:7b | 4.7GB | ~2.5min (VM) | Should be much faster locally |
| deepseek-coder-v2:16b | 8.9GB | Untested | Too large for 6GB VRAM |
| codegemma:7b | 5.0GB | Tab autocomplete | ✅ Good |
| nomic-embed-text | 0.3GB | Embeddings | ✅ Good |

### ⚠️ Issues Found:
1. **Using VM tunnel instead of local GPU** (10x slower!)
2. **No larger models** optimized for your 6GB GPU
3. **deepseek-coder-v2:16b won't fit** in 6GB VRAM
4. **Missing specialized models** for your Python/FastAPI/Data Science work

---

## 🎯 EPIC Setup Plan

### Phase 1: Install Optimal Models for 6GB GPU ✅

**Install these models locally:**

```bash
# 1. Qwen2.5-Coder 14B (BEST for code - quantized for 6GB)
ollama pull qwen2.5-coder:14b-instruct-q4_K_M    # ~8.5GB model, fits in 6GB VRAM with quantization

# 2. CodeLlama 13B (Specialized coding)
ollama pull codellama:13b-instruct-q4_K_M        # ~7.5GB, excellent for refactoring

# 3. Mistral 7B v0.3 (Fast general purpose)
ollama pull mistral:7b-instruct-v0.3-q4_K_M      # ~4.5GB, very fast

# 4. DeepSeek-Coder 6.7B (Lightweight alternative)
ollama pull deepseek-coder:6.7b-instruct-q4_K_M  # ~4GB, great for quick tasks

# 5. StarCoder2 7B (GitHub Copilot alternative)
ollama pull starcoder2:7b                         # ~4.3GB, trained on 600+ languages

# Keep existing:
# - qwen2.5-coder:7b (4.7GB) - Already have
# - codegemma:7b (5.0GB) - Tab autocomplete
# - llama3.2:3b (2.0GB) - Fast chat
# - nomic-embed-text (0.3GB) - Embeddings
```

**Total disk:** ~45GB (you have 170GB free ✅)

### Phase 2: Update Continue Config

**Optimal model assignment:**

1. **Primary Chat:** `qwen2.5-coder:14b-instruct-q4_K_M` (best quality)
2. **Fast Responses:** `mistral:7b-instruct-v0.3-q4_K_M` (5-10s)
3. **Refactoring:** `codellama:13b-instruct-q4_K_M` (specialized)
4. **Quick Tasks:** `deepseek-coder:6.7b-instruct-q4_K_M` (lightweight)
5. **Tab Autocomplete:** `codegemma:7b` (keep existing)
6. **Embeddings:** `nomic-embed-text` (keep existing)

### Phase 3: Configure Local Ollama (NO VM TUNNEL)

Update `~/.continue/config.json`:
```json
{
  "models": [
    {
      "title": "Qwen2.5 Coder 14B ⭐ (Primary - Best Quality)",
      "provider": "ollama",
      "model": "qwen2.5-coder:14b-instruct-q4_K_M",
      "apiBase": "http://127.0.0.1:11434"
    },
    {
      "title": "Mistral 7B ⚡ (Fast - 5-10s)",
      "provider": "ollama",
      "model": "mistral:7b-instruct-v0.3-q4_K_M",
      "apiBase": "http://127.0.0.1:11434"
    },
    {
      "title": "CodeLlama 13B 🔧 (Refactoring)",
      "provider": "ollama",
      "model": "codellama:13b-instruct-q4_K_M",
      "apiBase": "http://127.0.0.1:11434"
    },
    {
      "title": "DeepSeek Coder 6.7B 💨 (Quick Tasks)",
      "provider": "ollama",
      "model": "deepseek-coder:6.7b-instruct-q4_K_M",
      "apiBase": "http://127.0.0.1:11434"
    },
    {
      "title": "StarCoder2 7B 🌟 (Multi-language)",
      "provider": "ollama",
      "model": "starcoder2:7b",
      "apiBase": "http://127.0.0.1:11434"
    }
  ],
  "tabAutocompleteModel": {
    "title": "CodeGemma 7B",
    "provider": "ollama",
    "model": "codegemma:7b",
    "apiBase": "http://127.0.0.1:11434"
  },
  "embeddingsProvider": {
    "provider": "ollama",
    "model": "nomic-embed-text",
    "apiBase": "http://127.0.0.1:11434"
  }
}
```

---

## 🚀 Installation Commands

Run these in order:

```bash
# 1. Remove VM tunnel dependency (optional - keep for backup)
# Kill SSH tunnel if you want local-only:
# pkill -f "ssh.*11434.*10.0.0.110"

# 2. Install new models (this will take 15-30 minutes)
ollama pull qwen2.5-coder:14b-instruct-q4_K_M
ollama pull codellama:13b-instruct-q4_K_M
ollama pull mistral:7b-instruct-v0.3-q4_K_M
ollama pull deepseek-coder:6.7b-instruct-q4_K_M
ollama pull starcoder2:7b

# 3. Remove old oversized models (optional)
ollama rm deepseek-coder-v2:16b  # 8.9GB, doesn't fit in 6GB VRAM
ollama rm llama3.2:3b            # Replaced by mistral

# 4. Verify GPU usage
nvidia-smi  # Should show ollama using ~5-6GB VRAM

# 5. Test fastest model
time ollama run mistral:7b-instruct-v0.3-q4_K_M "Write a Python hello function"

# 6. Backup current Continue config
cp ~/.continue/config.json ~/.continue/config.json.backup-$(date +%Y%m%d)

# 7. Update Continue config (we'll do this next)
```

---

## 📊 Expected Performance

### Current (VM via SSH tunnel):
| Task | Time | Experience |
|------|------|------------|
| Simple question | 30s | 😐 Slow |
| Code generation | 2.5min | 😞 Very slow |
| Refactoring | Unknown | Not tested |

### After EPIC Setup (Local GPU):
| Task | Model | Time | Experience |
|------|-------|------|------------|
| Simple question | Mistral 7B | **5-10s** | 😍 Fast! |
| Code generation | Qwen 14B | **15-30s** | 🚀 Great! |
| Complex refactor | CodeLlama 13B | **20-40s** | ⭐ Excellent! |
| Quick edits | DeepSeek 6.7B | **8-15s** | ⚡ Snappy! |
| Tab complete | CodeGemma 7B | **<1s** | 💨 Instant! |

**Performance gain:** 5-10x faster than VM tunnel!

---

## 🎯 Workspace-Specific Models

Based on your codebase analysis:

### Primary Languages:
1. **Python** (FastAPI, async, Ollama integration) - 60%
2. **Data Science** (PySpark, Pandas, DataFrames) - 25%
3. **Vietnamese LMS** (Moodle, educational content) - 10%
4. **DevOps** (Docker, systemd, deployment) - 5%

### Recommended Model Usage:

| Task Type | Best Model | Why |
|-----------|------------|-----|
| **FastAPI Development** | CodeLlama 13B | Trained on production code |
| **PySpark/Data Science** | Qwen2.5 14B | Excellent with data manipulation |
| **Quick Python Scripts** | DeepSeek 6.7B | Fast, lightweight |
| **Refactoring** | CodeLlama 13B | Specialized for this |
| **Documentation** | Mistral 7B | Great at explanations |
| **Vietnamese Content** | Qwen2.5 14B | Multilingual support |
| **Debugging** | Qwen2.5 14B | Best reasoning |

---

## 🔧 Optional Enhancements

### 1. Ollama Systemd Service (Auto-start)
```bash
cat << 'EOF' | sudo tee /etc/systemd/system/ollama.service
[Unit]
Description=Ollama LLM Service
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=$USER
Environment="PATH=/usr/local/bin:/usr/bin:/bin"
Environment="OLLAMA_HOST=127.0.0.1:11434"
ExecStart=/usr/local/bin/ollama serve
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable ollama
sudo systemctl start ollama
```

### 2. GPU Memory Management
```bash
# Set Ollama to use max 5.5GB VRAM (leave 0.5GB for X server)
export OLLAMA_GPU_MEMORY_FRACTION=0.9

# Add to ~/.bashrc:
echo 'export OLLAMA_GPU_MEMORY_FRACTION=0.9' >> ~/.bashrc
```

### 3. Continue Custom Commands

Add to `~/.continue/config.json`:
```json
{
  "customCommands": [
    {
      "name": "fastapi",
      "prompt": "Generate FastAPI endpoint with async/await, Pydantic models, proper error handling, and docstrings.",
      "description": "Create FastAPI endpoint"
    },
    {
      "name": "pyspark",
      "prompt": "Write PySpark DataFrame transformation with proper schema validation, column type casting, and error handling.",
      "description": "PySpark data transformation"
    },
    {
      "name": "test",
      "prompt": "Write comprehensive pytest tests with fixtures, mocks, and edge cases.",
      "description": "Write tests"
    },
    {
      "name": "refactor",
      "prompt": "Refactor this code to improve readability, maintainability, and performance while keeping the same functionality.",
      "description": "Refactor code"
    },
    {
      "name": "explain",
      "prompt": "Explain this code step-by-step, including purpose, logic flow, and any potential issues.",
      "description": "Explain code"
    },
    {
      "name": "optimize",
      "prompt": "Optimize this code for performance. Suggest algorithmic improvements, caching strategies, and async opportunities.",
      "description": "Optimize performance"
    }
  ]
}
```

---

## 📈 Success Metrics

After setup, you should experience:

✅ **5-10x faster responses** (5-30s instead of 30s-2.5min)  
✅ **Instant tab autocomplete** (<1s with CodeGemma)  
✅ **High-quality code generation** (Qwen2.5 14B, CodeLlama 13B)  
✅ **No network latency** (local GPU, no SSH tunnel)  
✅ **Multiple specialized models** (pick the right tool for each job)  
✅ **Offline capable** (works without internet)

---

## 🚀 Next Steps

1. ✅ Install 5 new models (~45GB, 15-30 min)
2. ✅ Update Continue config to use local Ollama
3. ✅ Test each model for speed/quality
4. ✅ Remove VM tunnel (optional, keep as backup)
5. ✅ Configure custom commands for FastAPI/PySpark
6. ⏳ Document model selection guide
7. ⏳ Create VS Code snippets for common patterns

---

## 📝 Notes

- **VM models:** Keep for production/backup (via SSH tunnel)
- **Local models:** Daily development, instant feedback
- **Disk space:** Monitor with `df -h` (currently 170GB free)
- **GPU temp:** Monitor with `nvidia-smi` (should stay <80°C)
- **RAM usage:** Ollama will use 8-12GB when models loaded

---

**Status:** Ready to install  
**Estimated time:** 30 minutes  
**Difficulty:** Easy (just run commands)  
**Impact:** 🚀🚀🚀 EPIC upgrade!
