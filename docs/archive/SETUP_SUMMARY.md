# Setup Summary: OpenWebUI + Ollama + Continue + MCP

**Date:** November 4, 2025  
**Target:** VM 159 (ubuntuai) @ 10.0.0.110  
**Public URL:** https://openwebui.simondatalab.de

---

## What's Running Now

- **Model Pull in Progress** on VM 159
  - Script: `scripts/ollama_models_setup.sh` executing via SSH
  - Models being pulled:
    - llama3.1:8b
    - mistral:7b
    - qwen2.5:7b-instruct
    - phi3:mini
    - minicpm-lm-2
    - deepseek-coder:6.7b
    - codellama:7b

---

## Next 5 Minutes (After Model Pull Completes)

### 1. Configure OpenWebUI Provider

In OpenWebUI UI:
- Settings → Models → Providers
- Add provider: **Ollama**
- Base URL: `http://127.0.0.1:11434` (or `http://10.0.0.110:11434` if accessed remotely)
- Save
- Click **Sync/Refresh models**

Expected: All 7 models appear in the dropdown.

### 2. Verify Models via API

Run locally:
```bash
OPENWEBUI_URL=https://openwebui.simondatalab.de \
OPENWEBUI_TOKEN=YOUR_ROTATED_JWT \
python3 scripts/list_openwebui_models.py
```

Expected output:
```
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

Copy config template:
```bash
mkdir -p ~/.continue
cp continue/config.json.template ~/.continue/config.json
```

Or manually create `~/.continue/config.json` with:
- **Chat model:** DeepSeek Coder 6.7B (Ollama)
- **Edit model:** DeepSeek Coder 6.7B (Ollama)
- **Autocomplete:** Llama3.1:8B (Ollama)
- **MCP server:** ProxmoxMCP wired with your paths

Quick sanity checks in VS Code:
- Chat (Ctrl+L): "What's 2+2?"
- Edit (Ctrl+I): Select code → "Refactor into a function"
- Autocomplete: Type and observe inline suggestions

### 4. Optional: Health Monitor Baseline

Test the homelab monitor (from VM 159 or locally):
```bash
OPENWEBUI_URL=https://openwebui.simondatalab.de \
MCP_URL=http://10.0.0.110:3002 \
python3 scripts/homelab_monitor.py
```

Expected:
```json
{
  "timestamp": "2025-11-04T...",
  "services": {
    "openwebui": "UP",
    "mcp_endpoint": "UP",
    "docker": "openwebui: Up ... ollama: Up ..."
  }
}
```

---

## MiniMax "M2" Note

- **Local (via Ollama):** `minicpm-lm-2` is included in the setup script
- **Cloud (via API):** Add MiniMax as an OpenAI-compatible provider in OpenWebUI:
  - Settings → Models → Providers → OpenAI
  - Base URL: as documented by MiniMax (e.g., `https://api.minimax.chat/v1`)
  - API Key: your MiniMax key
  - Model name: specific MiniMax model (e.g., `abab6.5-chat`)

See `docs/OPENWEBUI_OLLAMA_MODELS.md` for details.

---

## Security Checklist

- [ ] Rotate JWT/API key in OpenWebUI after verification (Settings → API Keys)
- [ ] Confirm `private/**` is git-ignored (sensitive chat.html encrypted and quarantined)
- [ ] Store tokens in environment variables or secret storage (not in code/config files)
- [ ] Review ProxmoxMCP permissions (least privilege via Proxmox API token)

---

## Files Added/Updated

- `scripts/ollama_models_setup.sh` — Model pull automation
- `scripts/list_openwebui_models.py` — API verification helper
- `scripts/homelab_monitor.py` — Health check baseline
- `docs/OPENWEBUI_OLLAMA_MODELS.md` — OpenWebUI + Ollama setup guide
- `docs/CONTINUE_SETUP.md` — Continue extension configuration
- `continue/config.json.template` — Ready-to-use Continue config

---

## What's Ready

- ✅ Sensitive data quarantined and encrypted (`private/backups/chat.html.*.gpg`)
- ✅ Git ignores private directory
- ✅ Proxmox MCP + Skywork guides aligned with your outline
- ✅ Quick Summary doc created
- ✅ LinkedIn carousel generated and ready to post
- ✅ Model setup script running on VM 159
- ✅ Continue config template prepared

---

## Pending Tasks

- [ ] Define MSA/SOW/NDA/DPA (contract artifacts)
  - Brief definitions provided earlier; create formal templates if needed
- [ ] Optional: MCP DNS route (CNAME mcp.simondatalab.de)
  - Create Cloudflare CNAME; verify public reachability

---

**Status:** Model pull executing on VM 159. Once complete, configure OpenWebUI provider → Sync models → Verify via API → Apply Continue config → Test chat/edit/autocomplete.

**ETA to green:** ~10-15 minutes (model downloads depend on bandwidth; verification + Continue setup < 5 min after that).
