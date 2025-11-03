# Continue Extension Setup for VS Code

## Current Status
✅ Ollama service running on VM 159 (ubuntuai-1000110) at 10.0.0.110:11434
🔄 Models downloading: phi3:mini (✓), llama3.1:8b (in progress), qwen2.5:7b-instruct, deepseek-coder:6.7b, codellama:7b

## Step 1: Verify Ollama Models are Downloaded

```bash
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.110 "ollama list"
```

Expected output should show all models:
- phi3:mini
- llama3.1:8b
- qwen2.5:7b-instruct
- deepseek-coder:6.7b
- codellama:7b

## Step 2: Test Ollama Endpoint

```bash
curl http://10.0.0.110:11434/api/tags | jq .
```

## Step 3: Install Continue Extension in VS Code

1. Open VS Code
2. Go to Extensions (Ctrl+Shift+X)
3. Search for "Continue"
4. Install the official Continue extension

## Step 4: Configure Continue

Create or edit `~/.continue/config.json` with the following configuration:

```json
{
  "$schema": "https://raw.githubusercontent.com/continuedev/continue/main/config-schema.json",
  "models": [
    {
      "title": "DeepSeek Coder 6.7B (Primary)",
      "provider": "ollama",
      "model": "deepseek-coder:6.7b",
      "apiBase": "http://10.0.0.110:11434"
    },
    {
      "title": "Llama 3.1 8B",
      "provider": "ollama",
      "model": "llama3.1:8b",
      "apiBase": "http://10.0.0.110:11434"
    },
    {
      "title": "Qwen2.5 7B Instruct",
      "provider": "ollama",
      "model": "qwen2.5:7b-instruct",
      "apiBase": "http://10.0.0.110:11434"
    },
    {
      "title": "Phi3 Mini (Fast)",
      "provider": "ollama",
      "model": "phi3:mini",
      "apiBase": "http://10.0.0.110:11434"
    },
    {
      "title": "CodeLlama 7B",
      "provider": "ollama",
      "model": "codellama:7b",
      "apiBase": "http://10.0.0.110:11434"
    }
  ],
  "tabAutocompleteModel": {
    "title": "Llama 3.1 8B (Autocomplete)",
    "provider": "ollama",
    "model": "llama3.1:8b",
    "apiBase": "http://10.0.0.110:11434"
  },
  "contextProviders": [
    {
      "name": "diff",
      "params": {}
    },
    {
      "name": "folder",
      "params": {}
    },
    {
      "name": "code",
      "params": {}
    },
    {
      "name": "docs",
      "params": {}
    },
    {
      "name": "open",
      "params": {}
    },
    {
      "name": "terminal",
      "params": {}
    },
    {
      "name": "problems",
      "params": {}
    }
  ],
  "slashCommands": [
    {
      "name": "edit",
      "description": "Edit selected code"
    },
    {
      "name": "comment",
      "description": "Write comments for the selected code"
    },
    {
      "name": "share",
      "description": "Export the current chat session to markdown"
    },
    {
      "name": "cmd",
      "description": "Generate a shell command"
    },
    {
      "name": "commit",
      "description": "Generate a commit message"
    }
  ]
}
```

## Step 5: Reload VS Code

Press `Ctrl+Shift+P` → Type "Reload Window" → Press Enter

## Step 6: Test Continue Features

### Test Chat (Ctrl+L or Cmd+L)
1. Press `Ctrl+L` to open Continue chat
2. Type a question: "What is Python?"
3. Select "DeepSeek Coder 6.7B" from the model dropdown
4. Verify you get a response

### Test Code Edit (Ctrl+I or Cmd+I)
1. Open a Python file or create new one
2. Select some code
3. Press `Ctrl+I`
4. Type an instruction: "Add docstring to this function"
5. Verify the model edits your code

### Test Autocomplete
1. Start typing Python code
2. Wait a moment - autocomplete suggestions should appear
3. Press `Tab` to accept a suggestion

## Step 7: Configure OpenWebUI

1. Open https://openwebui.simondatalab.de in your browser
2. Log in
3. Go to Settings → Admin → Connections (or Settings → Models)
4. Add Ollama connection:
   - URL: `http://127.0.0.1:11434` (from VM's perspective)
   - Or: Configure via Docker networking
5. Click "Verify Connection"
6. All models should appear in the model selection dropdown

## Troubleshooting

### Continue can't connect to Ollama
- Verify VM 159 is accessible: `ping 10.0.0.110`
- Check Ollama service: `ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.110 "systemctl status ollama"`
- Test endpoint directly: `curl http://10.0.0.110:11434/api/tags`

### Models not appearing
- Check models are downloaded: `ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.110 "ollama list"`
- Verify apiBase URL in config.json is correct

### Autocomplete not working
- Ensure `tabAutocompleteModel` is configured in config.json
- Try reloading VS Code window
- Check Continue extension logs (Output panel → Continue)

### Performance issues
- Models run on CPU (no GPU detected on VM 159)
- Response times will be slower than GPU-accelerated inference
- Consider using smaller models (Phi3) for faster responses
- Current VM resources: 8 cores, 49GB RAM (good for CPU inference)

## Performance Optimization

Current Ollama settings from service status:
- `OLLAMA_NUM_PARALLEL=1` - Can increase for concurrent requests
- `OLLAMA_MAX_LOADED_MODELS=0` - Can set to 2-3 to keep models in memory
- `OLLAMA_CONTEXT_LENGTH=4096` - Reasonable for most tasks

To optimize, edit `/etc/systemd/system/ollama.service`:

```ini
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
Environment="OLLAMA_NUM_PARALLEL=4"
Environment="OLLAMA_MAX_LOADED_MODELS=3"
```

Then:
```bash
sudo systemctl daemon-reload
sudo systemctl restart ollama
```

## Model Recommendations

- **DeepSeek Coder 6.7B**: Best for code generation and editing
- **Llama 3.1 8B**: Good for autocomplete and general purpose
- **Qwen2.5 7B**: Excellent instruction following
- **Phi3 Mini**: Fastest responses, good for quick queries
- **CodeLlama 7B**: Specialized for code tasks

## Next Steps

1. ✅ Wait for all models to finish downloading
2. ✅ Configure Continue in VS Code
3. ✅ Test all features (Chat, Edit, Autocomplete)
4. Configure OpenWebUI connection
5. Create test workflows for your development needs
6. Monitor disk usage (currently 52% on root)
7. Consider performance tuning based on usage patterns
