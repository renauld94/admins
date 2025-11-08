# Codestral 22B Installation - Complete Summary

**Date**: November 7, 2025, 10:38 UTC  
**Status**: ✅ READY FOR CONTINUE INTEGRATION

---

## Installation Complete

### Models Now Available

```
Model                           Size          Purpose
─────────────────────────────────────────────────────────────
codestral:22b-v0.1-q4_0        12.6 GB       Primary (Code/Chat/Autocomplete)
llama3.2:3b                     2.0 GB        Fallback (All roles)
─────────────────────────────────────────────────────────────
Total                           14.6 GB       Both available at localhost:11434
```

**Installation Method**: `ollama pull codestral:22b-v0.1-q4_0`  
**Quantization**: q4_0 (4-bit quantized, 12.6GB)  
**Context Window**: 32k tokens  
**Download Time**: ~10 minutes (depends on network)

---

## Continue Configuration Updated

### Model Roles Configuration

```json
"models": [
  {
    "title": "Codestral 22B (Main)",
    "model": "codestral:22b-v0.1-q4_0",
    "temperature": 0.2,           // Very deterministic
    "contextLength": 16384
  },
  {
    "title": "Codestral 22B (Chat)",
    "model": "codestral:22b-v0.1-q4_0",
    "temperature": 0.4            // Balanced
  },
  {
    "title": "Codestral 22B (Code)",
    "model": "codestral:22b-v0.1-q4_0",
    "temperature": 0.1            // Ultra-deterministic
  }
]

"modelRoles": {
  "default": "Codestral 22B (Main)",
  "chat": "Codestral 22B (Chat)",
  "edit": "Codestral 22B (Code)",
  "autocomplete": "Codestral 22B (Autocomplete)",
  "fallbackDefault": "Llama 3.2 3B (Main - Fallback)",
  "fallbackChat": "Llama 3.2 3B (Chat - Fallback)",
  "fallbackEdit": "Llama 3.2 3B (Code - Fallback)"
}

"tabAutocompleteModel": {
  "model": "codestral:22b-v0.1-q4_0",
  "temperature": 0.15           // Deterministic completion
}
```

**File**: `~/.continue/config.json`  
**Status**: ✅ Valid JSON, all roles configured  
**Validation**: `python3 -m json.tool ~/.continue/config.json` → PASS

---

## Installer Script Created

**File**: `~/.continue/install_codestral_if_missing.sh`

**Features**:
- ✅ Idempotent (safe to run multiple times)
- ✅ Checks if Codestral already installed
- ✅ Verifies disk space (15GB minimum required)
- ✅ Streams download progress
- ✅ Logs all operations to `~/.continue/install_logs/codestral_install_*.log`
- ✅ Verifies installation after completion

**Usage**:
```bash
bash ~/.continue/install_codestral_if_missing.sh
```

**Last Run**: November 7, 10:38 UTC → ✅ SUCCESS

---

## Next Steps: Integrate with Continue

### Option 1: Auto-Detect (Recommended)
Continue should auto-detect Codestral via Ollama HTTP API at `http://localhost:11434`.

**Action**: 
1. Reload VS Code (`Ctrl+Shift+P` → "Developer: Reload Window")
2. Open Continue (Ctrl+L)
3. Click Models dropdown → should show "Codestral 22B (Main)" as available

### Option 2: Manual Configuration
If Continue doesn't auto-detect:

1. Open `.continue/config.json` in VS Code
2. Scroll to `"models"` section
3. Verify Codestral entries are present (they should be)
4. Save file
5. Restart Continue extension

---

## Temperature Tuning for Codestral

| Task | Temperature | Rationale |
|------|-------------|-----------|
| Code Generation | 0.1 | Very deterministic, consistent output |
| Autocomplete | 0.15 | Predictable suggestions, low hallucination |
| Chat/Discussion | 0.4 | Balanced, more creative but still coherent |
| Documentation | 0.3 | Structured yet natural language |
| Refactoring | 0.2 | Precise transformations with reasoning |

**Recommended**: Start with 0.1 for code tasks, 0.4 for exploratory chats.

---

## Performance Expectations

### Latency (First Token)
- **Codestral 22B**: ~500-1000ms (depends on system load)
- **Llama 3.2 3B**: ~100-300ms (faster, but less capable)

### Context Size
- **Codestral**: 32,768 tokens (much larger context)
- **Llama 3.2**: 8,192 tokens (sufficient for most tasks)

### Accuracy on Code Tasks
- **Codestral**: Specialized for code generation (trained on multiple programming languages)
- **Llama 3.2**: General purpose, good but not optimized for coding

---

## Testing Checklist

### Quick Verification
```bash
# 1. Test Ollama API
curl -s http://127.0.0.1:11434/api/tags | jq '.models[].name'
# Expected output:
#   "codestral:22b-v0.1-q4_0"
#   "llama3.2:3b"

# 2. Test Continue config validity
python3 -m json.tool ~/.continue/config.json > /dev/null && echo "✅ Valid"

# 3. Check install logs
tail -50 ~/.continue/install_logs/codestral_install_*.log
```

### Continue Integration Test
1. **In VS Code**:
   - Press `Ctrl+L` (Continue chat)
   - Look for model selector → should show Codestral
   - Type: `// ai: Write a function to reverse a string in Python`
   - Expected: Codestral generates Python code

2. **Autocomplete Test**:
   - Open any `.js` or `.py` file
   - Type: `const greeting = `
   - Press `Tab`
   - Expected: Continue autocompletes based on context

3. **Edit/Refactor Test**:
   - Select some code
   - Press `Ctrl+I` (Continue edit)
   - Type: `// ai: Add error handling to this function`
   - Expected: Codestral modifies code inline

---

## Disk Space Management

### Current Usage
```
Codestral:    12.6 GB
Llama 3.2:     2.0 GB
Total:        14.6 GB
Available:   145.4 GB (of 160 GB)
Remaining:   145.4 GB (91%)
```

### Optional: Install Additional Models

If you want more model options (not required now):

```bash
# Very fast (3.8B parameters)
ollama pull phi3.5:3.8b

# Fast general purpose (7B)
ollama pull qwen2.5:7b

# Mistral variant (7B)
ollama pull mistral:7b

# Larger Codestral variant (if needed)
ollama pull codestral:22b-v0.1  # Unquantized (full precision, 45GB+)
```

**Storage note**: Each additional model takes 5-50GB depending on quantization. You have room for 9-10 more models.

---

## Troubleshooting

### Issue: "Model not found" in Continue
**Solution**: 
1. Verify Ollama is running: `curl http://127.0.0.1:11434/api/tags`
2. Check `.continue/config.json` has Codestral entries
3. Reload VS Code (`Ctrl+Shift+P` → "Developer: Reload Window")

### Issue: Slow responses from Codestral
**Solution**:
1. Check system RAM: `free -h` (need 16GB+ for Codestral comfortably)
2. Check GPU usage: `nvidia-smi` (if GPU available)
3. Reduce `contextLength` in config.json if over 16k
4. Use Llama fallback (`"edit": "Llama 3.2 3B (Code - Fallback)"`) for quicker iterations

### Issue: "Address already in use" errors
**Solution**: 
1. Check if Ollama already running: `lsof -i :11434`
2. Kill if needed: `kill -9 <PID>`
3. Restart: `ollama serve`

---

## For EPIC Geodashboard Implementation

Now ready to use Codestral for the geodashboard build:

### Recommended Prompts for Code Generation

```javascript
// ai: Create a Leaflet map layer function that displays earthquake markers with color coding by magnitude
// Expected: Codestral returns well-structured, documented code

// ai: Add error handling and retry logic to the USGS API fetch function
// Expected: Proper try-catch, exponential backoff, logging

// ai: Generate TypeScript types for the earthquake data structure
// Expected: Well-typed interfaces with JSDoc comments
```

### Temperature Settings for Geodashboard

```json
{
  "code": 0.1,        // Very deterministic for map layer functions
  "autocomplete": 0.15, // Predictable suggestions
  "documentation": 0.3   // Natural but structured
}
```

---

## Command Reference

```bash
# Verify models installed
ollama list

# Check model via HTTP
curl -s http://127.0.0.1:11434/api/tags | jq

# Pull specific model version
ollama pull codestral:22b-v0.1-q4_0

# Run model directly (for testing)
ollama run codestral

# View system status
ollama ps

# Check logs
journalctl -u ollama -f  # if running as service
tail -f ~/.ollama/logs   # if running in foreground
```

---

## Files Created/Modified

| File | Action | Status |
|------|--------|--------|
| `~/.continue/config.json` | Updated with Codestral models | ✅ |
| `~/.continue/config.json.backup` | Preserved (auto-created) | ✅ |
| `~/.continue/install_codestral_if_missing.sh` | Created (idempotent) | ✅ |
| `~/.continue/install_logs/codestral_install_1762486671.log` | Installer log | ✅ |

---

## Summary

✅ **Codestral 22B successfully installed and configured**
- Model: `codestral:22b-v0.1-q4_0` (12.6GB)
- Available at: `http://localhost:11434`
- Continue config: Updated with Codestral primary roles + Llama fallbacks
- Status: Ready for immediate use

✅ **Next Action**: 
- Reload VS Code or Continue extension
- Test model availability in Continue IDE
- Begin EPIC geodashboard implementation with Continue integration

---

**Installer Logs**: `~/.continue/install_logs/`  
**Configuration**: `~/.continue/config.json`  
**Documentation**: This file

*Ready to build the EPIC geodashboard with Codestral power-assist!*
