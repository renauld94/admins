# ✅ Setup Complete - Next Steps

**Date:** November 4, 2025  
**Status:** Models pulling to VM 159 (300GB disk)

---

## What Just Happened

✅ **Ollama installed** on VM 159  
✅ **Storage configured** to use `/mnt/newdisk` (300GB disk with 226GB free)  
✅ **First model pulled** successfully (llama3.1:8b)  
🔄 **Remaining 6 models downloading** now (10-15 min):
   - mistral:7b
   - qwen2.5:7b-instruct
   - phi3:mini
   - minicpm-lm-2
   - deepseek-coder:6.7b
   - codellama:7b

---

## Next 5 Minutes (After Models Finish)

### 1. Configure OpenWebUI Connection

1. Open <https://openwebui.simondatalab.de>
2. Go to **Settings** → **Models** → **Connections**
3. Click **"Add Connection"** or edit existing Ollama
4. Set URL: `http://127.0.0.1:11434`
5. Click **"Verify Connection"** → should show green checkmark
6. Click **Save**
7. Models appear automatically in the dropdown!

### 2. Verify Models via API

Run this from your local machine:

```bash
OPENWEBUI_URL=https://openwebui.simondatalab.de \
OPENWEBUI_TOKEN=YOUR_ROTATED_JWT \
python3 scripts/list_openwebui_models.py
```

Expected output:

```text
Models detected:
- codellama:7b
- deepseek-coder:6.7b
- llama3.1:8b
- minicpm-lm-2
- mistral:7b
- phi3:mini
- qwen2.5:7b-instruct
```

### 3. Set Up Continue Extension (VS Code)

```bash
# Copy the template config
mkdir -p ~/.continue
cp continue/config.json.template ~/.continue/config.json
```

Edit `~/.continue/config.json` and set the Ollama base URL:

```json
{
  "models": {
    "chat": {
      "provider": "ollama",
      "model": "deepseek-coder:6.7b",
      "baseUrl": "http://10.0.0.110:11434"
    }
  }
}
```

Or use the full template from `continue/config.json.template` with:
- **Chat/Edit:** DeepSeek Coder 6.7B
- **Autocomplete:** Llama3.1:8B
- **MCP Server:** ProxmoxMCP (already wired)

**Quick tests in VS Code:**
- Chat (Ctrl+L): "What's 2+2?"
- Edit (Ctrl+I): Select code → "Refactor into a function"
- Autocomplete: Type and watch inline suggestions

---

## Storage Summary

- **VM 159 root (`/`)**: 30GB (100% full - do NOT use for models)
- **VM 159 data disk (`/mnt/newdisk`)**: 300GB (226GB free after models)
- **Ollama models location**: `/mnt/newdisk/ollama/models`
- **Local machine**: 0 MB (no models stored locally)

All models live **only** on VM 159's 300GB disk. Your local machine connects remotely via:
- OpenWebUI: `https://openwebui.simondatalab.de` (port 3001 on VM)
- Ollama API: `http://10.0.0.110:11434` (for Continue/direct use)

---

## Security Checklist

- [ ] Rotate JWT/API key in OpenWebUI (Settings → API Keys)
- [ ] Verify `private/**` is git-ignored
- [ ] Store tokens in env vars, not in code
- [ ] Review ProxmoxMCP permissions (least privilege)

---

## Optional: MiniMax Cloud Models

If you want to use MiniMax's cloud models instead of local `minicpm-lm-2`:

1. OpenWebUI → Settings → Models → Connections
2. Add Connection: **OpenAI Compatible**
3. Base URL: `https://api.minimax.chat/v1` (or your MiniMax endpoint)
4. API Key: your MiniMax key
5. Model name: e.g., `abab6.5-chat`

See `docs/OPENWEBUI_OLLAMA_MODELS.md` for details.

---

## Files Created

- `scripts/ollama_models_setup.sh` — Model pull automation
- `scripts/list_openwebui_models.py` — API verification helper
- `scripts/homelab_monitor.py` — Health check baseline
- `scripts/setup_vm159_models.sh` — VM-specific setup script
- `docs/OPENWEBUI_OLLAMA_MODELS.md` — OpenWebUI + Ollama guide
- `docs/CONTINUE_SETUP.md` — Continue extension config
- `continue/config.json.template` — Ready-to-use Continue config
- `SETUP_SUMMARY.md` — Detailed setup notes
- `NEXT_STEPS.md` — This file

---

## What's Ready

✅ Sensitive data secured (`private/backups/chat.html.*.gpg`)  
✅ Git ignores private directory  
✅ Proxmox MCP + Skywork guides aligned  
✅ Quick Summary doc created  
✅ LinkedIn carousel ready to post  
✅ Ollama installed on VM 159 (300GB disk)  
✅ Models downloading (7 total, ~40GB)  
✅ Continue config template prepared  

---

## Pending

- [ ] Define MSA/SOW/NDA/DPA (contract templates)
- [ ] Optional: MCP DNS route (CNAME mcp.simondatalab.de)
- [ ] Verify models in OpenWebUI after download completes
- [ ] Test Continue chat/edit/autocomplete

---

**ETA:** Models finish in ~10-15 min → Configure OpenWebUI connection → Verify via API → Test Continue → DONE! 🚀
