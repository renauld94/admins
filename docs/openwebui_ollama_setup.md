# OpenWebUI Ollama Configuration Guide

## 🎯 Setting up Ollama Models in OpenWebUI

### Step 1: Access OpenWebUI Admin Panel
1. Go to: https://openwebui.simondatalab.de/admin/settings/connections
2. Log in with your admin credentials

### Step 2: Add Ollama Connection
1. Click **"Add Connection"** or **"New Connection"**
2. Select **"Ollama"** as the provider type

### Step 3: Configure Ollama Settings
Use these exact settings:

```
Connection Name: Ollama Server
Base URL: http://ollama:11434
API Key: (leave empty)
```

**Important Notes:**
- Use `http://ollama:11434` (not https) - this is the internal Docker network address
- The container name `ollama` is used for internal Docker communication
- No API key is needed for local Ollama instances

### Step 4: Available Models
Your Ollama server has these models available:

1. **deepseek-coder:6.7b** (3.8GB)
   - Excellent for coding tasks
   - 7B parameter model
   - Q4_0 quantization

2. **tinyllama:latest** (637MB)
   - Fast responses for quick tasks
   - 1B parameter model
   - Q4_0 quantization

### Step 5: Test the Connection
1. Save the connection settings
2. OpenWebUI should automatically detect the available models
3. Try sending a test message to verify the connection works

### Step 6: Model Configuration (Optional)
You can configure model-specific settings:
- **Temperature**: 0.7 (default)
- **Max Tokens**: 2048 for tinyllama, 4096 for deepseek-coder
- **Top P**: 0.9
- **Top K**: 40

## 🔧 Troubleshooting

### If Connection Fails:
1. **Check Docker Network**: Ensure both containers are on the same network
2. **Verify Container Names**: Confirm `ollama` container is running
3. **Check Ports**: Verify port 11434 is accessible

### Docker Network Check:
```bash
# Check if containers are on the same network
docker network ls
docker network inspect ai-net
```

### Container Status:
```bash
# Check Ollama container
docker ps | grep ollama

# Check OpenWebUI container  
docker ps | grep open-webui
```

## 📋 Expected Result
After successful configuration:
- ✅ Models appear in the model selection dropdown
- ✅ You can start conversations with both models
- ✅ deepseek-coder:6.7b handles complex coding tasks
- ✅ tinyllama:latest provides fast responses

## 🚀 Next Steps
1. Test both models with sample prompts
2. Configure user permissions if needed
3. Set up model-specific prompts or system messages
4. Consider adding more models if needed

---

**Need Help?** If you encounter any issues, check the OpenWebUI logs or run the diagnostic script: `./diagnose_ollama.sh`

