# CONTINUE CONFIGURATION - CODESTRAL 22B Setup Guide

**Status**: Codestral 22B downloading (will be ~10GB)  
**Current Installed Models**: llama3.2:3b (2GB)  
**Current Continue Config**: Points to non-existent models

---

## The Situation

Your Continue config is beautiful but references models that aren't installed:
- ❌ qwen2.5-coder:7b (NOT INSTALLED)
- ❌ codellama:13b-instruct-q4_K_M (NOT INSTALLED)
- ❌ deepseek-coder:6.7b-instruct (NOT INSTALLED)
- ⏳ codestral:22b-v0.1-q4_0 (DOWNLOADING - will be ~10GB)
- ❌ phi3.5:3.8b (NOT INSTALLED)

**Only this is installed:**
- ✅ llama3.2:3b (2GB)

---

## Solution: Update Continue Config to Use llama3.2:3b NOW + Codestral Later

### Step 1: Update config.json - Remove Non-Existent Models

We'll create a **clean config** that uses llama3.2:3b for everything, then we'll update it when Codestral finishes.

**Create this new config (or ask me to update it):**

```json
{
  "models": [
    {
      "title": "Llama 3.2 3B (Code Generation)",
      "provider": "ollama",
      "model": "llama3.2:3b",
      "apiBase": "http://127.0.0.1:11434",
      "contextLength": 8192,
      "completionOptions": {
        "temperature": 0.1,
        "maxTokens": 4096
      }
    },
    {
      "title": "Llama 3.2 3B (Chat)",
      "provider": "ollama",
      "model": "llama3.2:3b",
      "apiBase": "http://127.0.0.1:11434",
      "contextLength": 8192,
      "completionOptions": {
        "temperature": 0.5,
        "maxTokens": 2048
      }
    },
    {
      "title": "Codestral 22B (COMING SOON)",
      "provider": "ollama",
      "model": "codestral:22b-v0.1-q4_0",
      "apiBase": "http://127.0.0.1:11434",
      "contextLength": 32000,
      "completionOptions": {
        "temperature": 0.1,
        "maxTokens": 4096
      }
    }
  ],
  "tabAutocompleteModel": {
    "title": "Llama 3.2 3B (Autocomplete)",
    "provider": "ollama",
    "model": "llama3.2:3b",
    "apiBase": "http://127.0.0.1:11434",
    "contextLength": 2048,
    "completionOptions": {
      "temperature": 0.3,
      "maxTokens": 100
    }
  },
  "embeddingsProvider": {
    "provider": "ollama",
    "model": "nomic-embed-text",
    "apiBase": "http://127.0.0.1:11434"
  },
  "mcpServers": {
    "ollama-code-assistant": {
      "command": "python3",
      "args": [
        "/home/simon/Learning-Management-System-Academy/.continue/agents/agents_continue/ollama_code_assistant.py"
      ],
      "env": {
        "NEURO_AGENT_TOKEN": "your-secure-token-here"
      }
    },
    "vietnamese-tutor": {
      "command": "python3",
      "args": [
        "/home/simon/Learning-Management-System-Academy/.continue/agents/agents_continue/vietnamese_tutor_agent.py"
      ],
      "env": {
        "OLLAMA_BASE_URL": "http://127.0.0.1:11434",
        "ASR_SERVICE_URL": "http://localhost:8000"
      }
    }
  },
  "customCommands": [
    {
      "name": "test",
      "prompt": "Write comprehensive unit tests for highlighted code.",
      "description": "Write unit tests"
    },
    {
      "name": "doc",
      "prompt": "Generate JSDoc documentation for highlighted code.",
      "description": "Generate documentation"
    },
    {
      "name": "geodashboard",
      "prompt": "Generate code for the geodashboard component: {highlighted}",
      "description": "Geodashboard code generation"
    }
  ],
  "allowAnonymousTelemetry": false,
  "disableIndexing": false
}
```

---

## Step 2: Check Download Progress

```bash
# Check if Codestral finished
ollama list | grep codestral

# Or watch progress
watch "du -sh ~/.ollama/models/manifests/registry.ollama.ai/library/codestral/"
```

---

## Step 3: When Codestral is Ready

Once download completes, Codestral will be automatically available in Continue without needing to restart.

```bash
# Test it
ollama run codestral:22b-v0.1-q4_0 "Generate a Python function to calculate distance between coordinates"
```

---

## Step 4: Continue Development with Codestral

Once installed, you'll have:

**Keyboard Shortcuts:**
```
Ctrl+I       - Code generation/refactoring (uses code role = Codestral)
Ctrl+L       - Chat (uses chat model)
Tab          - Autocomplete (uses tabAutocompleteModel = Llama 3.2 3B)
Ctrl+Shift+K - Apply edits
```

**For Geodashboard Development:**
```
// Generate Leaflet code
// ai: Create a Leaflet map with earthquake markers colored by magnitude

// Refactor for performance
// ai: Optimize this marker clustering to handle 10000+ points

// Generate tests
// ai: Write tests for the WebSocket RealtimeDataManager class

// API integration
// ai: Create a function to fetch and parse USGS earthquake data with error handling
```

---

## Temperature Recommendations (IMPORTANT)

### For Code Generation (Very Deterministic)
```json
{
  "temperature": 0.1,  // Almost always same output
  "topP": 0.9,
  "maxTokens": 4096
}
```

### For Chat/Exploration
```json
{
  "temperature": 0.5,  // Balanced creativity
  "topP": 0.95,
  "maxTokens": 2048
}
```

### For Autocomplete
```json
{
  "temperature": 0.3,  // Slightly deterministic
  "topP": 0.9,
  "maxTokens": 100
}
```

---

## Model Upgrade Path

### Now (While Codestral Downloads)
- Use: llama3.2:3b for everything

### When Codestral 22B Ready
- Code/Refactoring: Codestral 22B (best code generation)
- Autocomplete: llama3.2:3b (fast)
- Chat: llama3.2:3b (good conversational)

### Optional Future Upgrades
```bash
# Add more specialized models
ollama pull mistral:7b            # General purpose, fast
ollama pull qwen2.5:7b             # Best balance
ollama pull neural-chat:7b         # Conversational
```

---

## Quick Commands to Help

### Show installed models
```bash
ollama list
```

### Test Codestral (when ready)
```bash
ollama run codestral:22b-v0.1-q4_0 "Hello"
```

### Monitor download
```bash
watch "du -sh ~/.ollama"
```

### Show model details
```bash
ollama show codestral:22b-v0.1-q4_0
```

---

## Next: Update Continue Config

I can update your Continue config.json to:
1. Use only installed models (llama3.2:3b) right now
2. Support Codestral when it finishes
3. Include custom commands for geodashboard

**Should I:**
- [ ] Update config.json now with clean llama3.2:3b setup?
- [ ] Wait for Codestral to finish and then update?
- [ ] Both (clean now, add Codestral when ready)?

---

## Testing with Continue

Once updated, test with:

```
Ctrl+L

"Write a Python function to generate random earthquake data"
```

Should work immediately with llama3.2:3b!

---

**Current Status:**
- Codestral: ⏳ Downloading (~5-10 minutes remaining)
- Continue: ⚠️ Needs config update (references non-existent models)
- Geodashboard: ✅ Ready to build (waiting on Continue setup)

**Ready? Let me update config.json to use llama3.2:3b now!**
