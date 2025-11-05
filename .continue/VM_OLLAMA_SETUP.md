# 🌐 Using Ollama on VM 159 (10.0.0.110)

**Date:** November 5, 2025  
**Status:** Models should run on VM, not local machine

---

## ✅ What's Done

1. **Removed all local Ollama models** (freed ~26GB)
   - llama3.2:3b
   - deepseek-coder-v2:16b
   - qwen2.5:7b-instruct
   - gemma2:9b

2. **Updated Continue config** to point to VM Ollama:
   - Changed `apiBase` from `http://localhost:11434` to `http://10.0.0.110:11434`
   - All models now query the VM instead of local machine

3. **Backup created:** `~/.continue/config.json.backup-local`

---

## 🔌 VPN Connection Required

**IMPORTANT:** VM 159 (10.0.0.110) is on your private network. You need VPN connected!

### Check VPN Status:
```bash
# Check if VPN is running
systemctl status wg-quick@wg0

# Or check if you can reach the VM
ping 10.0.0.110
curl http://10.0.0.110:11434/api/tags
```

### Connect VPN:
```bash
# If using WireGuard
sudo systemctl start wg-quick@wg0

# Or if you have a different VPN client
# (replace with your actual VPN connection command)
```

---

## 📋 VM 159 Current Models

Based on earlier checks, VM 159 has:
- **gemma2:9b** (5.4GB) - For Vietnamese AI services

---

## 🚀 Install Models on VM 159

### Option 1: SSH to VM and Install
```bash
# Connect to VM
ssh simonadmin@10.0.0.110

# Run installation script
cd /tmp
# Copy the install script to VM first, then run it
```

### Option 2: Remote Installation Script

I'll create a script that installs models on the VM remotely:

```bash
#!/bin/bash
# Install models on VM 159

VM_IP="10.0.0.110"
VM_USER="simonadmin"

# Test connection
if ! ping -c 1 $VM_IP &> /dev/null; then
    echo "❌ Cannot reach VM. Is VPN connected?"
    exit 1
fi

echo "✅ VM reachable, installing models..."

# Install models via SSH
ssh $VM_USER@$VM_IP << 'EOF'
echo "🚀 Installing models on VM..."

# Install OPTIMAL SET
ollama pull qwen2.5-coder:7b
ollama pull llama3.2:3b
ollama pull codegemma:7b
ollama pull mistral:7b-instruct-v0.3
ollama pull nomic-embed-text

echo "✅ Models installed!"
ollama list
EOF
```

---

## 🔧 Continue Configuration

Your Continue config now points to VM:

```json
{
  "models": [
    {
      "title": "Gemma2 9B",
      "provider": "ollama",
      "model": "gemma2:9b",
      "apiBase": "http://10.0.0.110:11434"
    }
  ],
  "tabAutocompleteModel": {
    "title": "Gemma2 9B",
    "provider": "ollama",
    "model": "gemma2:9b",
    "apiBase": "http://10.0.0.110:11434"
  },
  "embeddingsProvider": {
    "provider": "ollama",
    "model": "nomic-embed-text",
    "apiBase": "http://10.0.0.110:11434"
  }
}
```

After installing models on VM, update this config with new models.

---

## ⚙️ Recommended Models for VM 159

**VM 159 Specs:**
- Ubuntu 24.04.2
- 8 CPUs
- 48GB RAM (only 6% used!)
- 112GB disk (43% used after cleanup)
- **Good for 7B-16B models**

### OPTIMAL SET (~25GB total):
1. **qwen2.5-coder:7b** (4.7GB) - Best coder
2. **deepseek-coder-v2:16b** (9GB) - Advanced coding
3. **llama3.2:3b** (2GB) - Fast queries
4. **codegemma:7b** (5GB) - Autocomplete
5. **mistral:7b-instruct-v0.3** (4.1GB) - Reasoning
6. **gemma2:9b** (5.4GB) - Keep for Vietnamese AI
7. **nomic-embed-text** (~0.3GB) - Embeddings

**Total:** ~30GB (plenty of space on VM!)

---

## 🎯 Quick Setup Steps

### 1. Connect VPN
```bash
sudo systemctl start wg-quick@wg0
# Or use your VPN client
```

### 2. Test VM Connection
```bash
curl http://10.0.0.110:11434/api/tags
```

### 3. SSH to VM and Install Models
```bash
ssh simonadmin@10.0.0.110

# Once on VM:
ollama pull qwen2.5-coder:7b
ollama pull llama3.2:3b  
ollama pull codegemma:7b
ollama pull mistral:7b-instruct-v0.3
ollama pull deepseek-coder-v2:16b
ollama pull nomic-embed-text

# Check installation
ollama list
```

### 4. Update Continue Config
Add new models to `~/.continue/config.json`:
```json
{
  "models": [
    {
      "title": "Qwen2.5 Coder 7B (Primary)",
      "provider": "ollama",
      "model": "qwen2.5-coder:7b",
      "apiBase": "http://10.0.0.110:11434"
    },
    {
      "title": "DeepSeek Coder V2 16B",
      "provider": "ollama",
      "model": "deepseek-coder-v2:16b",
      "apiBase": "http://10.0.0.110:11434"
    },
    {
      "title": "Llama 3.2 3B (Fast)",
      "provider": "ollama",
      "model": "llama3.2:3b",
      "apiBase": "http://10.0.0.110:11434"
    },
    {
      "title": "Code Gemma 7B",
      "provider": "ollama",
      "model": "codegemma:7b",
      "apiBase": "http://10.0.0.110:11434"
    },
    {
      "title": "Mistral 7B",
      "provider": "ollama",
      "model": "mistral:7b-instruct-v0.3",
      "apiBase": "http://10.0.0.110:11434"
    },
    {
      "title": "Gemma2 9B (Vietnamese)",
      "provider": "ollama",
      "model": "gemma2:9b",
      "apiBase": "http://10.0.0.110:11434"
    }
  ],
  "tabAutocompleteModel": {
    "title": "Code Gemma 7B",
    "provider": "ollama",
    "model": "codegemma:7b",
    "apiBase": "http://10.0.0.110:11434"
  },
  "embeddingsProvider": {
    "provider": "ollama",
    "model": "nomic-embed-text",
    "apiBase": "http://10.0.0.110:11434"
  }
}
```

### 5. Restart VS Code
```bash
# In VS Code: Ctrl+Shift+P → "Developer: Reload Window"
```

---

## 🔍 Troubleshooting

### Cannot Reach VM
```bash
# Check VPN
systemctl status wg-quick@wg0

# Test connectivity
ping 10.0.0.110
curl http://10.0.0.110:11434/api/tags
```

### Ollama Not Running on VM
```bash
ssh simonadmin@10.0.0.110
systemctl --user status ollama
# Or
sudo systemctl status ollama
```

### Models Not Appearing in Continue
1. Ensure VPN is connected
2. Check VM Ollama is running: `curl http://10.0.0.110:11434/api/tags`
3. Restart VS Code window
4. Check Continue logs: View → Output → Continue

---

## 📊 Performance Expectations

**Network Latency:** Models run on VM, responses sent over network
- **Local network:** ~1-2ms latency (negligible)
- **Over internet/VPN:** ~20-50ms latency (still fast!)

**Benefits:**
- ✅ Your local machine stays light (no model storage)
- ✅ VM has more resources (48GB RAM vs 30GB local)
- ✅ Can access from multiple devices
- ✅ Centralized model management

---

## 🎯 Next Steps

1. **Connect VPN** to reach 10.0.0.110
2. **SSH to VM** and install recommended models
3. **Update Continue config** with new models
4. **Restart VS Code** to load new configuration
5. **Test** by asking Continue to generate code

---

## 💡 Alternative: Run Models Locally When Not on VPN

If you're not connected to VPN, you can temporarily use local models:

```bash
# Switch to local Ollama
sed -i 's|http://10.0.0.110:11434|http://localhost:11434|g' ~/.continue/config.json

# Install minimal local model for offline work
ollama pull qwen2.5-coder:7b

# Switch back to VM later
sed -i 's|http://localhost:11434|http://10.0.0.110:11434|g' ~/.continue/config.json
```

---

**Current Status:**
- ✅ Local models removed (freed 26GB)
- ✅ Continue configured to use VM
- ⏳ Need VPN connection to proceed
- ⏳ Need to install models on VM

**Ready to connect VPN and install models on VM!** 🚀
