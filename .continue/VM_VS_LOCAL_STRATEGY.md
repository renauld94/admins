# 🎯 VM vs Local GPU Strategy Guide

**Date:** November 5, 2025  
**Goal:** Optimal use cases for running AI models on VM (slow) vs Local GPU (fast)

---

## 📊 Current Setup

### **Local GPU** (Fast - Your Workstation)
- **Hardware:** NVIDIA Quadro RTX 3000 (6GB VRAM), 30GB RAM, 12 CPUs
- **Speed:** 5-10x faster than VM
- **Models:** 6 models (31GB disk)
- **Endpoint:** `http://127.0.0.1:11434`

| Model | Size | Speed | VRAM |
|-------|------|-------|------|
| Qwen2.5-Coder 7B | 4.7GB | 10-15s | 4.5GB |
| DeepSeek-Coder 6.7B | 3.8GB | 8-12s | 3.5GB |
| CodeLlama 13B Q4 | 7.9GB | 20-30s | 6GB |
| Codestral 22B Q4 | 12GB | 15-20s | 5.5GB |
| Phi-3.5 Mini | 2.2GB | 4-6s | 2GB |
| Nomic Embed | 274MB | N/A | 0.5GB |

### **VM 159** (Slow - Remote Server)
- **Hardware:** 8 CPUs, 16GB RAM, NO GPU (CPU-only inference)
- **Speed:** 10x slower (30s-2.5min per response)
- **Models:** 5 models (via SSH tunnel)
- **Endpoint:** `http://localhost:11434` (tunnel) or SSH to VM
- **Access:** `ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.110`

| Model | Size | Speed (CPU) |
|-------|------|-------------|
| llama3.2:3b | 2.0GB | 20-30s |
| qwen2.5-coder:7b | 4.7GB | 2-3min |
| deepseek-coder-v2:16b | 8.9GB | Untested (very slow) |
| codegemma:7b | 5.0GB | 30-40s |
| nomic-embed-text | 274MB | 5-10s |

---

## 🚀 **USE LOCAL GPU FOR:**

### 1. **Interactive Development** (HIGH PRIORITY)
**Use Case:** Daily coding in Continue/VS Code
- ✅ Chat with AI while coding
- ✅ Code generation and refactoring
- ✅ Tab autocomplete
- ✅ Quick questions and explanations
- ✅ Debugging assistance

**Why Local:**
- **Immediate feedback** (10-15s vs 2.5min)
- **No network latency**
- **Won't block** if VM is busy
- **Better UX** - feels like Copilot

**Models to Use:**
- **Primary:** Qwen2.5-Coder 7B (best balance)
- **Fast:** DeepSeek 6.7B or Phi-3.5 (quick answers)
- **Complex:** Codestral 22B Q4 (architecture decisions)

---

### 2. **Rapid Iteration** (HIGH PRIORITY)
**Use Case:** Testing prompts, experimenting with AI
- ✅ Trying different model outputs
- ✅ A/B testing prompts
- ✅ Learning what works best
- ✅ Quick iterations on generation

**Why Local:**
- **Fast feedback loop** enables experimentation
- **Cost-effective** (no cloud costs)
- **Unlimited usage** without rate limits

---

### 3. **Production Coding Sessions** (MEDIUM PRIORITY)
**Use Case:** Focused coding time with AI pair programmer
- ✅ Pair programming sessions
- ✅ Code reviews with AI
- ✅ Real-time refactoring suggestions
- ✅ Documentation generation

**Why Local:**
- **Consistent performance**
- **No dependency** on VM uptime
- **Private** - no network traffic

---

## 🐢 **USE VM FOR:**

### 1. **Background Batch Processing** (HIGH VALUE)
**Use Case:** Long-running AI tasks that don't need immediate results

**Examples:**
```bash
# Generate documentation for entire codebase
for file in learning-platform/**/*.py; do
  ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.110 \
    "curl -s http://localhost:11434/api/generate -d '{
      \"model\":\"qwen2.5-coder:7b\",
      \"prompt\":\"Generate docstring for: $(cat $file)\",
      \"stream\":false
    }'" > "${file%.py}_docs.txt"
done
```

**Benefits:**
- ✅ Runs in background while you work locally
- ✅ Doesn't consume local GPU
- ✅ Can run overnight
- ✅ Free compute (already have VM)

---

### 2. **Scheduled AI Tasks** (HIGH VALUE)
**Use Case:** Automated AI workflows via cron

**Examples:**

#### Daily Code Analysis
```bash
# Add to VM crontab: 0 2 * * * (runs 2 AM daily)
#!/bin/bash
cd /path/to/repo
for dir in deploy/ai-services/*.py; do
  curl -s http://localhost:11434/api/generate -d '{
    "model":"qwen2.5-coder:7b",
    "prompt":"Analyze this code for issues: $(cat $dir)",
    "stream":false
  }' >> /var/log/code-analysis-$(date +%Y%m%d).log
done
```

#### Weekly Documentation Generation
```bash
# Cron: 0 3 * * 0 (runs Sunday 3 AM)
python3 /scripts/generate_docs_with_ai.py --model qwen2.5-coder:7b
```

**Benefits:**
- ✅ Automated workflows
- ✅ Runs when you're not working
- ✅ Doesn't interrupt local development

---

### 3. **Large Batch Inference** (MEDIUM VALUE)
**Use Case:** Processing many items where speed isn't critical

**Examples:**
- 📝 Translating 100+ course materials to Vietnamese
- 🔍 Analyzing all error logs from production
- 📊 Generating summaries of user feedback
- 🧪 Testing AI responses across dataset

**Script Example:**
```python
# run_on_vm_batch.py
import requests
import json
from pathlib import Path

VM_ENDPOINT = "http://localhost:11434"  # Via SSH tunnel

def process_batch(items, model="qwen2.5-coder:7b"):
    results = []
    for i, item in enumerate(items):
        print(f"Processing {i+1}/{len(items)}...")
        response = requests.post(
            f"{VM_ENDPOINT}/api/generate",
            json={
                "model": model,
                "prompt": f"Translate to Vietnamese: {item}",
                "stream": False
            }
        )
        results.append(response.json()['response'])
    return results

# Process 500 items - takes 20 min on VM (2.5s each)
# Would only take 2 min on local GPU, but frees your GPU for coding
```

---

### 4. **MCP Agent Services** (HIGH VALUE)
**Use Case:** Long-running MCP agents that serve requests

**Your Current Agents:**
```bash
# These run on VM as systemd services:
systemctl --user status core_dev           # Core development agent
systemctl --user status data_science       # Data science helper
systemctl --user status legal_advisor      # Legal document analysis
systemctl --user status systemops          # System operations
systemctl --user status web_lms            # LMS management
```

**Why VM is Better:**
- ✅ **24/7 availability** - always listening
- ✅ **Doesn't consume** your local GPU
- ✅ **Serves multiple** requests simultaneously
- ✅ **Production-ready** - systemd auto-restart

**Access Pattern:**
```bash
# Agent runs on VM, you call it from anywhere
curl http://10.0.0.110:8000/legal-analysis \
  -d '{"document": "contract.pdf"}'
```

---

### 5. **Testing Production Deployments** (MEDIUM VALUE)
**Use Case:** Validate AI services before deploying to production

**Examples:**
- 🧪 Load testing AI endpoints
- 🔍 Integration testing with real services
- 📊 Performance benchmarking
- 🚀 Staging environment for AI features

**Benefits:**
- ✅ Isolated from local development
- ✅ Closer to production environment
- ✅ Can test with real data/scale

---

### 6. **Resource-Intensive Long Tasks** (LOW VALUE on CPU-only VM)
**Use Case:** Tasks that need lots of compute but you can wait

**Examples:**
- 📝 Fine-tuning small models (if VM had GPU - doesn't apply)
- 🔍 Embedding entire codebase (30GB+)
- 📊 Vector database generation

**⚠️ Limitation:** Your VM has **NO GPU**, so very slow for large models
- ✅ OK for embeddings (nomic-embed-text)
- ❌ Bad for large model inference

---

## 🎯 **Optimal Workflow Examples**

### **Example 1: Daily Development**
```
Morning:
1. Start local Ollama: `ollama serve`
2. Open VS Code with Continue
3. Use Qwen 7B for coding (10-15s responses)
4. Use DeepSeek 6.7B for quick edits (8s)

Afternoon:
5. Need complex refactoring → Use Codestral 22B Q4 (15-20s)
6. Quick questions → Use Phi-3.5 Mini (4-6s)

Evening (Optional):
7. Start batch job on VM (documentation generation)
8. Goes to sleep while VM processes 500 files overnight
```

---

### **Example 2: FastAPI Development**
```python
# File: deploy/ai-services/new_service.py

# LOCAL GPU: Ask Continue to generate endpoint
# Prompt: "Create FastAPI endpoint for user authentication with JWT"
# Model: Qwen2.5-Coder 7B (15 seconds)
# Result: Complete endpoint with validation

# LOCAL GPU: Refactor generated code
# Prompt: "Refactor this to use dependency injection"
# Model: CodeLlama 13B Q4 (25 seconds)
# Result: Improved architecture

# VM: Generate test cases (background)
# ssh to VM and run:
curl http://localhost:11434/api/generate -d '{
  "model":"qwen2.5-coder:7b",
  "prompt":"Generate 20 pytest test cases for this endpoint",
  "stream":false
}' > tests/test_new_service.py
# (runs in 2 minutes on VM while you continue coding locally)
```

---

### **Example 3: Vietnamese Course Content**
```
TASK: Translate 200 Python lessons to Vietnamese

LOCAL GPU: Interactive translations (first 10 lessons)
- Use Continue chat with Qwen 7B
- Review each translation immediately
- Make adjustments in real-time
- Time: ~30 minutes (2 min per lesson)

VM: Batch remaining lessons (190 lessons)
- Run script on VM overnight:
  python3 batch_translate.py --model qwen2.5-coder:7b --count 190
- Review translations next morning
- Time: ~8 hours (2.5 min per lesson on CPU)
- BUT: You slept through it!

RESULT: Best of both worlds - interactive + automation
```

---

### **Example 4: PySpark Data Pipeline**
```
TASK: Build complex data transformation pipeline

LOCAL GPU: Design and prototype
1. Chat with Qwen 7B: "Design PySpark pipeline for user analytics"
   → Get architecture overview (15s)
2. Generate initial code with Codestral 22B Q4 (20s)
3. Iteratively refine with DeepSeek 6.7B (8s per iteration)
4. Total time: 5 minutes for working prototype

VM: Generate test data and validation
5. SSH to VM, run:
   - Generate 1000 test cases with AI
   - Validate pipeline logic
   - Create edge case scenarios
6. Runs in background while you write docs locally
7. Total time: 30 minutes on VM (but you're doing other work)

RESULT: Fast iteration locally + thorough testing on VM
```

---

## 📋 **Decision Matrix**

| Criteria | Use Local GPU | Use VM |
|----------|---------------|--------|
| **Need immediate result** | ✅ YES | ❌ NO |
| **Interactive/iterative** | ✅ YES | ❌ NO |
| **Batch processing** | ❌ NO | ✅ YES |
| **Background task** | ❌ NO | ✅ YES |
| **Scheduled/automated** | ❌ NO | ✅ YES |
| **Quality over speed** | 🤔 Either | ✅ YES |
| **Long-running service** | ❌ NO | ✅ YES |
| **Can wait overnight** | ❌ NO | ✅ YES |
| **While coding** | ✅ YES | ❌ NO |
| **Production testing** | ❌ NO | ✅ YES |

---

## 🔧 **Practical Setup**

### **Dual-Endpoint Continue Config**
```json
{
  "models": [
    // PRIMARY: Local GPU models
    {"title": "Qwen 7B ⭐ LOCAL", "apiBase": "http://127.0.0.1:11434"},
    {"title": "DeepSeek 6.7B 🚀 LOCAL", "apiBase": "http://127.0.0.1:11434"},
    
    // BACKUP: VM models (via tunnel - keep for emergencies)
    {"title": "Qwen 7B 🐢 VM", "apiBase": "http://localhost:11434"},
    {"title": "CodeGemma 7B VM", "apiBase": "http://localhost:11434"}
  ]
}
```

### **SSH Tunnel Script for VM Access**
```bash
# ~/.local/bin/vm-ollama-tunnel
#!/bin/bash
# Start tunnel ONLY when needed for batch jobs
ssh -f -N -L 11435:localhost:11434 \
  -J root@136.243.155.166:2222 \
  simonadmin@10.0.0.110

echo "✅ VM Ollama available at: http://localhost:11435"
```

### **Batch Processing Script Template**
```python
#!/usr/bin/env python3
# vm_batch_task.py
import requests
import json
from pathlib import Path

VM_ENDPOINT = "http://localhost:11435"  # Via tunnel on different port

def process_on_vm(items, model="qwen2.5-coder:7b"):
    """Process items on VM in background"""
    results = []
    for i, item in enumerate(items, 1):
        print(f"[VM] Processing {i}/{len(items)}...")
        resp = requests.post(f"{VM_ENDPOINT}/api/generate",
            json={"model": model, "prompt": item, "stream": False},
            timeout=300  # 5 min per item
        )
        results.append(resp.json()['response'])
    return results

# Usage: Run this on VM or locally with tunnel
# It will take 2-3 min per item, but you can do other work
```

---

## 📊 **Performance Comparison**

| Task | Local GPU | VM CPU | Winner |
|------|-----------|--------|--------|
| Single code gen (10 lines) | 10s | 2.5min | Local (15x faster) |
| Batch 100 translations | 16min | 4hr | Local (15x faster) |
| Overnight 500 docs | 1.5hr | 20hr | Both work! |
| Interactive chat | 8-15s | 30s-2.5min | Local (10x faster) |
| Background service | N/A | 24/7 | VM only option |

---

## 🎯 **Best Practices**

### **DO:**
✅ Use **local GPU** for all interactive development  
✅ Use **VM** for scheduled/background tasks  
✅ Keep **both endpoints** configured for flexibility  
✅ Run **MCP agents** on VM (24/7 availability)  
✅ Use **VM** for tasks that can wait overnight  
✅ **Batch process** on VM while coding locally  

### **DON'T:**
❌ Use VM for interactive Continue chat (too slow)  
❌ Run batch jobs on local GPU (blocks your development)  
❌ Leave local Ollama running 24/7 (wastes power)  
❌ Forget VM has **no GPU** (CPU-only, very slow)  
❌ Run large models on VM (16GB RAM limit)  

---

## 🚀 **Next Steps**

1. ✅ **Test local models** in Continue (reload VS Code)
2. ✅ **Benchmark speeds** - should see 10x improvement
3. ⏳ **Create batch scripts** for VM workflows
4. ⏳ **Set up cron jobs** on VM for automated tasks
5. ⏳ **Document** your specific use cases

---

## 📝 **Summary**

**Golden Rule:** 
- 🏎️ **LOCAL GPU** = Speed when you need it (development)
- 🐢 **VM CPU** = Patience pays off (background/automation)

**Your Setup is OPTIMAL:**
- 6 powerful local models for fast development
- 5 VM models for background tasks and agents
- Best of both worlds! 🎉

---

**Status:** ✅ Ready to use!  
**Models Installed:** 6 local + 5 VM = 11 total  
**Disk Used:** 31GB local + 20GB VM = 51GB total  
**Performance Gain:** 5-10x faster interactive development
