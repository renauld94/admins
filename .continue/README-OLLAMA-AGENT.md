# 🤖 Ollama Code Assistant Agent

AI-powered code assistant using your Ollama models on VM 159 (10.0.0.110:11434).

## Features

- **Code Generation** - Generate code from natural language prompts
- **Code Review** - Get AI feedback on code quality and best practices
- **Code Explanation** - Understand what code does
- **Code Improvement** - Enhance existing code with type hints, error handling, etc.
- **Debugging Help** - Analyze and fix code errors

## Models Used

- **deepseek-coder:6.7b** - Primary model for code generation and debugging
- **llama3.1:8b** - Code review and analysis
- **qwen2.5:7b-instruct** - Code explanations

## Quick Start

### 1. Install and Start

```bash
cd .continue
./setup_ollama_agent.sh
```

This will:
- ✅ Check Python dependencies (installs fastapi, uvicorn, requests if needed)
- ✅ Test Ollama connection
- ✅ Create necessary directories
- ✅ Start the agent on http://127.0.0.1:5110

### 2. Test the Agent

```bash
cd .continue/agents
python3 test_ollama_agent.py
```

Expected output:
```
🤖 Ollama Code Assistant Agent Test Suite
✅ PASS - Health Check
✅ PASS - List Models
✅ PASS - Generate Code
✅ PASS - Review Code
✅ PASS - Explain Code
```

## API Endpoints

### Health Check
```bash
curl http://127.0.0.1:5110/health
```

### List Available Models
```bash
curl http://127.0.0.1:5110/models
```

### Generate Code
```bash
curl -X POST http://127.0.0.1:5110/generate \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Write a function to validate email addresses",
    "language": "python",
    "model": "deepseek-coder:6.7b"
  }'
```

### Review Code
```bash
curl -X POST http://127.0.0.1:5110/review \
  -H "Content-Type: application/json" \
  -d '{
    "code": "def add(a, b): return a + b",
    "language": "python"
  }'
```

### Explain Code
```bash
curl -X POST http://127.0.0.1:5110/explain \
  -H "Content-Type: application/json" \
  -d '{
    "code": "list(map(lambda x: x**2, range(10)))",
    "language": "python"
  }'
```

### Improve Code
```bash
curl -X POST http://127.0.0.1:5110/improve \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "def divide(a, b): return a / b",
    "language": "python"
  }'
```

### Debug Code
```bash
curl -X POST http://127.0.0.1:5110/debug \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "This code crashes: for i in range(10): print(list[i])",
    "language": "python"
  }'
```

## Management

### Start Agent
```bash
cd .continue
./setup_ollama_agent.sh
```

### Stop Agent
```bash
pkill -f ollama_code_assistant.py
```

### View Logs
```bash
tail -f /tmp/ollama-agent.log
```

### Install as System Service

```bash
sudo cp .continue/systemd/ollama-code-assistant.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable ollama-code-assistant
sudo systemctl start ollama-code-assistant
sudo systemctl status ollama-code-assistant
```

## Integration Examples

### Python Client
```python
import requests

def generate_code(prompt, language="python"):
    response = requests.post(
        "http://127.0.0.1:5110/generate",
        json={"prompt": prompt, "language": language}
    )
    return response.json()

# Use it
result = generate_code("Create a REST API endpoint for user login")
if result["success"]:
    print(result["response"])
```

### Shell Script
```bash
#!/bin/bash
PROMPT="Write a bash function to backup a directory"
curl -X POST http://127.0.0.1:5110/generate \
  -H "Content-Type: application/json" \
  -d "{\"prompt\": \"$PROMPT\", \"language\": \"bash\"}" \
  | python3 -c "import sys, json; print(json.load(sys.stdin)['response'])"
```

## Generated Code Storage

All generated code is automatically saved to:
```
.continue/workspace/agents/context/ollama-code-assistant/
```

Files are named with timestamps for easy reference.

## Configuration

Edit `agents_continue/ollama_code_assistant.py` to customize:

```python
# Ollama server URL
OLLAMA_BASE_URL = "http://10.0.0.110:11434"

# Default model
DEFAULT_MODEL = "deepseek-coder:6.7b"
```

## Troubleshooting

### Agent won't start
Check dependencies:
```bash
pip3 install fastapi uvicorn requests --user
```

### Can't connect to Ollama
Verify Ollama is accessible:
```bash
curl http://10.0.0.110:11434/api/tags
```

Check if VM 159 is reachable:
```bash
ping 10.0.0.110
```

### Slow responses
This is normal for CPU inference. Expected response times:
- Simple code: 5-10 seconds
- Complex code: 15-30 seconds
- Reviews/Explanations: 10-20 seconds

Use `phi3:mini` model for faster (but less detailed) responses.

## Advanced Usage

### Chain Multiple Operations
```python
import requests

# 1. Generate code
gen = requests.post("http://127.0.0.1:5110/generate", json={
    "prompt": "Create a function to parse CSV files"
}).json()

# 2. Review the generated code
review = requests.post("http://127.0.0.1:5110/review", json={
    "code": gen["response"]
}).json()

# 3. Improve based on review
improved = requests.post("http://127.0.0.1:5110/improve", json={
    "prompt": gen["response"]
}).json()

print("Final code:", improved["response"])
```

### Custom Model Selection
```python
# Use different models for different tasks
requests.post("http://127.0.0.1:5110/generate", json={
    "prompt": "Complex algorithm",
    "model": "llama3.1:8b"  # More capable but slower
})

requests.post("http://127.0.0.1:5110/generate", json={
    "prompt": "Simple utility function",
    "model": "phi3:mini"  # Faster for simple tasks
})
```

## Architecture

```
┌──────────────┐         ┌──────────────────┐         ┌──────────────┐
│   Client     │ ──HTTP─>│  Agent (5110)    │ ──HTTP─>│   Ollama     │
│              │         │  FastAPI Server  │         │  (VM 159)    │
│ - Python     │<────────│  - Routes        │<────────│  :11434      │
│ - curl       │         │  - Validation    │         │              │
│ - Scripts    │         │  - Context Save  │         │ 4 Models:    │
└──────────────┘         └──────────────────┘         │ - DeepSeek   │
                                                       │ - Llama3.1   │
                                                       │ - Qwen2.5    │
                                                       │ - Phi3       │
                                                       └──────────────┘
```

## Next Steps

1. ✅ Start the agent with `./setup_ollama_agent.sh`
2. ✅ Run tests with `python3 agents/test_ollama_agent.py`
3. Try generating code for your projects
4. Integrate into your development workflow
5. Create custom agents for specific tasks

## Related

- **Ollama Setup**: See `OLLAMA_SETUP_COMPLETE.md`
- **Continue Extension**: Use with VS Code for inline AI assistance
- **Other Agents**: Check `agents_continue/` for more specialized agents

---

**Ready to code with AI! 🚀**

Start the agent and let AI assist your development workflow!
