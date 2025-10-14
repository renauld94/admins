# OpenWebUI Configuration Guide with API Key

## 🔑 API Key Configuration Options

### Option 1: Ollama (Local) - No API Key Needed
For your local Ollama server:
```
Connection Name: Ollama Server
Base URL: http://ollama:11434
API Key: (leave empty)
```

### Option 2: OpenAI API (Using Your Key)
If you want to use OpenAI's API instead of local Ollama:
```
Connection Name: OpenAI API
Base URL: https://api.openai.com/v1
API Key: sk-71b6787a347443f483ed1dfa9d07bc43
```

### Option 3: Hybrid Setup (Both Local + OpenAI)
You can configure both connections and switch between them:

1. **Ollama Connection** (for local models):
   ```
   Connection Name: Local Ollama
   Base URL: http://ollama:11434
   API Key: (empty)
   ```

2. **OpenAI Connection** (for cloud models):
   ```
   Connection Name: OpenAI Cloud
   Base URL: https://api.openai.com/v1
   API Key: sk-71b6787a347443f483ed1dfa9d07bc43
   ```

## 🎯 Recommended Setup

Since you have both local Ollama models AND an OpenAI API key, I recommend:

### Step 1: Add OpenAI Connection
1. Go to: https://openwebui.simondatalab.de/admin/settings/connections
2. Click "Add Connection"
3. Select "OpenAI" as provider
4. Configure:
   ```
   Connection Name: OpenAI API
   Base URL: https://api.openai.com/v1
   API Key: sk-71b6787a347443f483ed1dfa9d07bc43
   ```

### Step 2: Verify Ollama Connection
Check if Ollama connection already exists (should be automatic):
```
Connection Name: Ollama Server
Base URL: http://ollama:11434
API Key: (empty)
```

## 📋 Available Models After Setup

### Local Ollama Models:
- **deepseek-coder:6.7b** (3.8GB) - Free, excellent for coding
- **tinyllama:latest** (637MB) - Free, fast responses

### OpenAI Models (with your API key):
- **GPT-4** - Most capable model
- **GPT-3.5-turbo** - Fast and cost-effective
- **GPT-4-turbo** - Latest GPT-4 variant

## 💡 Usage Strategy

- **Use Ollama models** for:
  - Coding tasks (deepseek-coder)
  - Quick responses (tinyllama)
  - When you want to avoid API costs

- **Use OpenAI models** for:
  - Complex reasoning tasks
  - When you need the most advanced capabilities
  - When local models aren't sufficient

## 🔧 Next Steps

1. **Add the OpenAI connection** with your API key
2. **Test both connections** to ensure they work
3. **Choose models** based on your needs
4. **Monitor usage** to manage API costs

Would you like me to help you set up the OpenAI connection, or do you prefer to stick with just the local Ollama models?

