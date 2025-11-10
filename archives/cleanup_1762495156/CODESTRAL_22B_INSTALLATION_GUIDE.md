# Installing Codestral 22B on Ollama - Complete Guide

**Date**: November 7, 2025  
**Goal**: Install `codestral:22b-v0.1-q4_0` and configure Continue to use it  
**Current Model**: llama3.2:3b (2.0 GB)  
**New Model**: Codestral 22B (much larger, better for code generation)

---

## ⚠️ Important: Storage Requirements

### Codestral 22B Variants
```
codestral:22b-v0.1-fp16        ~45 GB (Full precision - NOT RECOMMENDED)
codestral:22b-v0.1-q8_0        ~23 GB (8-bit quantization)
codestral:22b-v0.1-q6_K        ~16 GB (6-bit K quantization - RECOMMENDED)
codestral:22b-v0.1-q5_K_M      ~14 GB (5-bit K medium)
codestral:22b-v0.1-q4_K_M      ~11 GB (4-bit K medium - BEST BALANCE)
codestral:22b-v0.1-q4_0        ~10 GB (4-bit quantization - SMALLEST)
```

**Check Available Storage:**
```bash
df -h /var/lib/ollama  # or where Ollama models are stored
```

---

## Step 1: Install via Ollama CLI

### Option A: Pull via Ollama (Recommended - Easiest)
```bash
# Pull the smallest quantized version (10 GB)
ollama pull codestral:22b-v0.1-q4_0

# Or pull the recommended balanced version (11 GB)
ollama pull codestral:22b-v0.1-q4_K_M

# Or pull the best quality (14 GB)
ollama pull codestral:22b-v0.1-q5_K_M
```

### Option B: Manual GGUF Installation (Advanced)
If you have a pre-downloaded GGUF file, place it in:
```bash
~/.ollama/models/manifests/registry.ollama.ai/library/codestral/
# Then restart Ollama
```

---

## Step 2: Verify Installation

```bash
# Check if model was downloaded
ollama list | grep codestral

# Test the model
ollama run codestral:22b-v0.1-q4_0 "Generate a Python function"
```

---

## Step 3: Update Continue Configuration

### Current Config Location
`~/.continue/config.json`

### Add Codestral to Models
```json
{
  "models": [
    {
      "title": "Codestral 22B (Code Generation)",
      "provider": "ollama",
      "model": "codestral:22b-v0.1-q4_0",
      "contextLength": 32000,
      "completionOptions": {
        "temperature": 0.1,
        "maxTokens": 4096
      }
    }
  ]
}
```

### Add to Model Roles
```json
{
  "modelRoles": [
    {
      "role": "code",
      "model": "Codestral 22B (Code Generation)"
    },
    {
      "role": "edit",
      "model": "Codestral 22B (Code Generation)"
    }
  ]
}
```

---

## Step 4: Use in Continue

### Keyboard Shortcuts
```
Ctrl+K        - Inline code generation (uses code role)
Ctrl+I        - Edit/refactor code (uses edit role)
Ctrl+L        - Chat (can select Codestral)
Tab           - Autocomplete (if set as tabAutocompleteModel)
```

### In Chat, Select Model
Click the dropdown at bottom-left of Continue panel:
```
Agent: [Dropdown]
Codestral 22B (Code Generation) [Selected]
```

---

## Performance Tips

### Memory Management
```bash
# Codestral 22B requires ~22-45 GB RAM depending on quantization
# Monitor before running:
free -h

# If running low on memory, use smaller model:
ollama pull codestral:22b-v0.1-q4_0  # Only ~10 GB
```

### Temperature Settings for Code Quality
```json
{
  "code": {
    "temperature": 0.1,      // Very deterministic
    "topP": 0.9,             // Focus on likely tokens
    "maxTokens": 4096        // Larger context for complex code
  },
  "documentation": {
    "temperature": 0.3,      // Slightly creative
    "topP": 0.95
  },
  "debugging": {
    "temperature": 0.2,      // Very focused
    "topP": 0.9
  }
}
```

---

## Troubleshooting

### Error: "Model not found"
```bash
# Check if model exists
ollama list | grep codestral

# If not found, pull it:
ollama pull codestral:22b-v0.1-q4_0

# Restart Continue/VS Code
```

### Error: "Out of memory"
```bash
# Use smaller quantization
ollama pull codestral:22b-v0.1-q4_0

# Or fallback to llama3.2:3b
ollama pull llama3.2:3b
```

### Error: Slow responses
```bash
# Check if Ollama is busy with another model
pgrep -a ollama

# Kill and restart if needed
pkill -f ollama
sleep 2
ollama serve &
```

---

## Switching Between Models

### In Continue Config
```json
{
  "tabAutocompleteModel": {
    "title": "Llama 3.2 3B (Fast)",
    "provider": "ollama",
    "model": "llama3.2:3b"
  },
  "models": [
    {
      "title": "Codestral 22B (Best Code)",
      "provider": "ollama",
      "model": "codestral:22b-v0.1-q4_0",
      "roleName": "code"
    }
  ]
}
```

### Manual Selection in VS Code
```
Ctrl+' (backtick)  - Open terminal
Ctrl+K Ctrl+L      - Select language/model in Continue chat
```

---

## Timeline Expectations

### Download Time (on decent internet)
- Codestral 22B (10 GB): ~10-20 minutes
- Codestral 22B (14 GB): ~15-30 minutes
- Codestral 22B (45 GB): ~60+ minutes

### First Run Time
- Initial load: ~30-60 seconds (model loading into memory)
- Subsequent runs: ~5-15 seconds (already in memory)

---

## Recommended Configuration

### Best for Geodashboard Code Generation
```json
{
  "models": [
    {
      "title": "Codestral 22B",
      "provider": "ollama",
      "model": "codestral:22b-v0.1-q4_K_M",
      "contextLength": 32000,
      "completionOptions": {
        "temperature": 0.1,
        "maxTokens": 4096,
        "topP": 0.9
      }
    },
    {
      "title": "Llama 3.2 3B",
      "provider": "ollama",
      "model": "llama3.2:3b",
      "completionOptions": {
        "temperature": 0.5,
        "maxTokens": 2048
      }
    }
  ],
  "tabAutocompleteModel": {
    "title": "Llama 3.2 3B (Fast)",
    "provider": "ollama",
    "model": "llama3.2:3b"
  },
  "modelRoles": [
    {
      "role": "code",
      "model": "Codestral 22B"
    },
    {
      "role": "edit",
      "model": "Codestral 22B"
    },
    {
      "role": "chat",
      "model": "Llama 3.2 3B"
    }
  ]
}
```

---

## Using Continue for Geodashboard

Once Codestral 22B is installed:

### Keyboard Shortcuts
```
Ctrl+I  - Generate/refactor HTML/CSS/JS with Codestral
Ctrl+L  - Chat about architecture with Llama
Tab     - Fast autocomplete with Llama 3.2 3B
```

### Example Prompts for Geodashboard
```
// Generate Leaflet map code
// ai: Create a Leaflet map with earthquake markers and RainViewer weather overlay

// Refactor for performance
// ai: Optimize the marker clustering to handle 5000+ points smoothly

// Generate documentation
// ai: Generate comprehensive JSDoc for the RealtimeDataManager class

// Debug issues
// ai: Why is the WebSocket not reconnecting after disconnect? Fix it.
```

---

## Next Steps

1. **Install Codestral 22B** (choose smallest quantization)
2. **Verify Installation** with `ollama list`
3. **Update Continue Config** (I'll help you do this)
4. **Test in VS Code** - Use Ctrl+I to generate code
5. **Build Geodashboard** - Use Codestral for all code generation

---

## Progress Checklist

- [ ] Storage checked (`df -h`)
- [ ] Codestral 22B downloading or installed
- [ ] `ollama list` shows codestral model
- [ ] Continue config.json updated with Codestral
- [ ] VS Code restarted
- [ ] Ctrl+I tested with Codestral
- [ ] Ready to build geodashboard

---

**Note**: We're doing everything with Continue's help. Use the keyboard shortcuts liberally!

*Ready to install? Start with: `ollama pull codestral:22b-v0.1-q4_0`*
