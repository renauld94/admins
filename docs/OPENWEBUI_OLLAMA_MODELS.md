# OpenWebUI + Ollama: Models Setup and MiniMax Integration

This guide helps you populate OpenWebUI with local Ollama models and integrate MiniMax cloud models when needed.

## 1) Pull local models with Ollama

Run this on the machine where Ollama and OpenWebUI are installed:

```bash
bash scripts/ollama_models_setup.sh
```

What it pulls by default:

- llama3.1:8b
- mistral:7b
- qwen2.5:7b-instruct
- phi3:mini
- minicpm-lm-2  ← If you meant “MiniMax M2” as MiniCPM-LM-2, this is the local Ollama model
- codellama:7b (optional code model)

Tip: You can edit `scripts/ollama_models_setup.sh` to add/remove models before running it.

## 2) Point OpenWebUI at Ollama

In OpenWebUI:

1. Settings → Models → Providers
2. Add provider: “Ollama”
3. Base URL: `http://127.0.0.1:11434` (or your server’s address)
4. Save, then click “Sync/Refresh models” so newly pulled models appear in the dropdown.

## 3) About “MiniMax M2” — two possibilities

There’s often confusion around “M2”. You likely mean one of these:

1. MiniCPM-LM-2 (local via Ollama)

- This is available as `minicpm-lm-2` and is already included in the setup script.
- After the pull, you’ll see `minicpm-lm-2` in OpenWebUI’s model list (via the Ollama provider).

1. MiniMax cloud model (OpenAI-compatible API)

- MiniMax provides hosted models via an OpenAI-compatible REST API (requires API key).
- To use MiniMax in OpenWebUI:
  - Settings → Models → Providers
  - Add provider: “OpenAI” (or “OpenAI compatible”)
  - Base URL: as documented by MiniMax (e.g., `https://api.minimax.chat/v1` – confirm with your account/docs)
  - API Key: your MiniMax key
  - Model name: the specific MiniMax model you intend to use (confirm in their docs, e.g., `abab6.5-chat` or newer).

Note: MiniMax cloud models are not pulled by Ollama; they are used via API. If you actually need the local “M2” model, use `minicpm-lm-2` in Ollama.

## 4) Quick sanity checks

Test Ollama locally:

```bash
curl -s http://127.0.0.1:11434/api/tags | jq '.models | length'
```

Test generating with a local model (replace the model name as you like):

```bash
curl -s http://127.0.0.1:11434/api/generate \
  -H 'Content-Type: application/json' \
  -d '{"model":"llama3.1:8b","prompt":"Say hello in one sentence."}'
```

If you configured MiniMax as an OpenAI provider, test it with their example curl from the MiniMax docs (ensuring your API key is set and the base URL is correct).

## 5) Troubleshooting

- Models don’t appear in OpenWebUI:
  - Confirm Ollama is running: `curl -s http://127.0.0.1:11434/api/tags`
  - In OpenWebUI, re-save the Ollama provider and click Refresh/Sync
  - Check network/firewall if OpenWebUI runs in a different container/VM

- Pull fails for a specific model:
  - Try a smaller quantized variant (e.g., `:q4_0` or documented alternative)
  - Remove the model from the list and re-run the script; continue with others

- “MiniMax M2” not found in Ollama:
  - Use `minicpm-lm-2` locally (Ollama) OR
  - Add MiniMax as an OpenAI-compatible provider with your API key (cloud)

---

Maintainer note: If your stack runs across Proxmox VMs/containers, ensure OpenWebUI can reach the Ollama host/port. For production, put both behind an internal network or service mesh and restrict public exposure.
