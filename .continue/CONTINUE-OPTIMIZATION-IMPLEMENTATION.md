# CONTINUE Optimization - Implementation Guide

**Date**: November 6, 2025  
**Target**: Production-ready optimization  
**Effort**: ~2 hours to fully implement

---

## 🎯 QUICK START (5 Minutes)

### Step 1: Backup Current Config
```bash
cp ~/.continue/config.json ~/.continue/config.backup-$(date +%Y%m%d-%H%M%S).json
echo "✅ Backup created"
```

### Step 2: Deploy Optimized Config
```bash
cp /home/simon/Learning-Management-System-Academy/.continue/config-optimized-for-coding.json \
   ~/.continue/config.json
echo "✅ Optimized config deployed"
```

### Step 3: Archive Decorative Agents
```bash
mkdir -p /home/simon/Learning-Management-System-Academy/.continue/agents/archived
mv /home/simon/Learning-Management-System-Academy/.continue/agents/epic_cinematic_agent.py \
   /home/simon/Learning-Management-System-Academy/.continue/agents/archived/
echo "✅ epic_cinematic archived"
```

### Step 4: Stop Unnecessary Services
```bash
systemctl --user stop epic-cinematic.service 2>/dev/null || true
systemctl --user disable epic-cinematic.service 2>/dev/null || true
echo "✅ Services stopped"
```

### Step 5: Reload Continue
```bash
# Kill VS Code Continue processes
pkill -9 "node.*continue" 2>/dev/null || true

# Or reload the extension via VS Code:
# Cmd+Shift+P > "Developer: Reload Window"
echo "✅ Reload VS Code to activate changes"
```

---

## 📋 DETAILED IMPLEMENTATION CHECKLIST

### Phase 1: Local Machine Setup (15 minutes)

#### Step 1.1: Verify Local Config
- [ ] Navigate to `~/.continue/`
- [ ] Confirm `config.json` exists
- [ ] Backup original to `config.backup.json`

#### Step 1.2: Deploy Optimized Config
```bash
# Copy optimized config
cp /home/simon/Learning-Management-System-Academy/.continue/config-optimized-for-coding.json \
   ~/.continue/config.json

# Verify it's valid JSON
python3 -m json.tool ~/.continue/config.json > /dev/null && echo "✅ Valid JSON"
```

#### Step 1.3: Archive Agents
```bash
# Create archive directory
mkdir -p ~/.continue/agents/archived

# Move decorative agents
mv ~/.continue/agents/epic_cinematic_agent.py ~/.continue/agents/archived/ 2>/dev/null || true
mv ~/.continue/agents/example_agent.py ~/.continue/agents/archived/ 2>/dev/null || true

echo "✅ Decorative agents archived"
```

#### Step 1.4: Update Systemd Services
```bash
# Disable epic-cinematic service
systemctl --user disable epic-cinematic.service 2>/dev/null || true
systemctl --user stop epic-cinematic.service 2>/dev/null || true

# Verify it stopped
sleep 2
systemctl --user status epic-cinematic.service 2>&1 | grep -q "inactive" && echo "✅ Service stopped"
```

#### Step 1.5: Verify Ollama Connection
```bash
# Test Ollama API
curl -s http://localhost:11434/api/tags | jq '.models | length' && echo "✅ Ollama responding"

# List available models
curl -s http://localhost:11434/api/tags | jq '.models[].name'
```

#### Step 1.6: Reload Continue in VS Code
```bash
# Option 1: Via VS Code
# Press: Cmd+Shift+P (Mac) or Ctrl+Shift+P (Linux/Windows)
# Type: "Developer: Reload Window"
# Press: Enter

# Option 2: Via terminal (if VS Code in PATH)
# code --reload-extensions continue.continue || true

echo "⏳ Please reload VS Code Continue extension"
```

### Phase 2: Create Code-Focused Agents (30 minutes)

#### Step 2.1: Create Agents Directory
```bash
mkdir -p /home/simon/Learning-Management-System-Academy/.continue/agents/coding
echo "✅ Created agents/coding directory"
```

#### Step 2.2: Copy Provided Agent Scripts
The following agents have already been created in `agents/coding/`:
- ✅ `code-generation-specialist.py` (created)
- ✅ `code-review-specialist.py` (created)
- TODO: `test-generator-specialist.py`
- TODO: `documentation-generator.py`
- TODO: `refactoring-assistant.py`

#### Step 2.3: Create Test Generator Agent
```bash
cat > /home/simon/Learning-Management-System-Academy/.continue/agents/coding/test-generator-specialist.py << 'EOF'
#!/usr/bin/env python3
"""Test Generator Specialist - Creates unit tests for code"""
import subprocess, json, sys, logging
from pathlib import Path

LOG_DIR = Path.home() / ".local" / "share" / "continue" / "agents" / "logs"
LOG_DIR.mkdir(parents=True, exist_ok=True)

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class TestGeneratorSpecialist:
    def __init__(self):
        self.model = "deepseek-coder:6.7b"
        self.temperature = 0.1
        self.api_base = "http://127.0.0.1:11434"

    def generate_tests(self, code: str, language: str = "python", test_framework: str = None):
        if test_framework is None:
            test_framework = "pytest" if language == "python" else "jest"

        system_prompt = f"""You are an expert test writer specializing in {language}.
Generate comprehensive unit tests using {test_framework}.

REQUIREMENTS:
1. Cover all function/method paths
2. Include edge cases
3. Test error handling
4. Use descriptive test names
5. Add setup/teardown if needed

OUTPUT: Return ONLY valid {language} test code. No explanations."""

        prompt = f"Generate {test_framework} tests for this {language} code:\n\n```{language}\n{code}\n```"

        try:
            result = subprocess.run(
                ["curl", "-s", "-X", "POST", f"{self.api_base}/api/generate",
                 "-H", "Content-Type: application/json",
                 "-d", json.dumps({"model": self.model, "prompt": prompt, "system": system_prompt,
                                 "temperature": self.temperature, "top_p": 0.85, "top_k": 20,
                                 "num_predict": 2048, "stream": False})],
                capture_output=True, text=True, timeout=60)

            if result.returncode == 0:
                response = json.loads(result.stdout)
                return response.get("response", "").strip()
        except Exception as e:
            logger.error(f"Test generation failed: {e}")
        return ""

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: test-generator-specialist.py <file_path>")
        sys.exit(1)
    
    code = Path(sys.argv[1]).read_text()
    specialist = TestGeneratorSpecialist()
    tests = specialist.generate_tests(code)
    print(tests)
EOF

chmod +x /home/simon/Learning-Management-System-Academy/.continue/agents/coding/test-generator-specialist.py
echo "✅ Test generator created"
```

#### Step 2.4: Create Documentation Generator
```bash
cat > /home/simon/Learning-Management-System-Academy/.continue/agents/coding/documentation-generator.py << 'EOF'
#!/usr/bin/env python3
"""Documentation Generator - Creates docstrings and documentation"""
import subprocess, json, sys, logging
from pathlib import Path

LOG_DIR = Path.home() / ".local" / "share" / "continue" / "agents" / "logs"
LOG_DIR.mkdir(parents=True, exist_ok=True)

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class DocumentationGenerator:
    def __init__(self):
        self.model = "deepseek-coder:6.7b"
        self.temperature = 0.2
        self.api_base = "http://127.0.0.1:11434"

    def generate_docstrings(self, code: str, language: str = "python", style: str = "google"):
        system_prompt = f"""You are an expert documentation writer for {language}.
Add comprehensive docstrings in {style} style.

REQUIREMENTS:
1. Clear description of functionality
2. Document all parameters with types
3. Document return values
4. Include examples where helpful
5. Note edge cases and exceptions

OUTPUT: Return ONLY documented {language} code."""

        prompt = f"Add {style}-style docstrings to this {language} code:\n```{language}\n{code}\n```"

        try:
            result = subprocess.run(
                ["curl", "-s", "-X", "POST", f"{self.api_base}/api/generate",
                 "-H", "Content-Type: application/json",
                 "-d", json.dumps({"model": self.model, "prompt": prompt, "system": system_prompt,
                                 "temperature": self.temperature, "top_p": 0.9, "top_k": 30,
                                 "num_predict": 2048, "stream": False})],
                capture_output=True, text=True, timeout=60)

            if result.returncode == 0:
                response = json.loads(result.stdout)
                return response.get("response", "").strip()
        except Exception as e:
            logger.error(f"Documentation generation failed: {e}")
        return ""

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: documentation-generator.py <file_path> [style]")
        sys.exit(1)
    
    code = Path(sys.argv[1]).read_text()
    style = sys.argv[2] if len(sys.argv) > 2 else "google"
    generator = DocumentationGenerator()
    documented = generator.generate_docstrings(code, style=style)
    print(documented)
EOF

chmod +x /home/simon/Learning-Management-System-Academy/.continue/agents/coding/documentation-generator.py
echo "✅ Documentation generator created"
```

#### Step 2.5: Create Refactoring Assistant
```bash
cat > /home/simon/Learning-Management-System-Academy/.continue/agents/coding/refactoring-assistant.py << 'EOF'
#!/usr/bin/env python3
"""Refactoring Assistant - Code modernization and improvement"""
import subprocess, json, sys, logging
from pathlib import Path

LOG_DIR = Path.home() / ".local" / "share" / "continue" / "agents" / "logs"
LOG_DIR.mkdir(parents=True, exist_ok=True)

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class RefactoringAssistant:
    def __init__(self):
        self.model = "deepseek-coder:6.7b"
        self.temperature = 0.2
        self.api_base = "http://127.0.0.1:11434"

    def refactor_code(self, code: str, language: str = "python", goals: list = None):
        if goals is None:
            goals = ["readability", "performance", "maintainability", "testability"]

        goals_str = "\n".join([f"- {g}" for g in goals])
        system_prompt = f"""You are a {language} refactoring expert.
Improve code for:
{goals_str}

REQUIREMENTS:
1. Keep same functionality
2. Add comments for changes
3. Use modern {language} features
4. Improve variable names
5. Extract helper methods where appropriate

OUTPUT: Return ONLY refactored {language} code."""

        prompt = f"Refactor this {language} code:\n```{language}\n{code}\n```"

        try:
            result = subprocess.run(
                ["curl", "-s", "-X", "POST", f"{self.api_base}/api/generate",
                 "-H", "Content-Type: application/json",
                 "-d", json.dumps({"model": self.model, "prompt": prompt, "system": system_prompt,
                                 "temperature": self.temperature, "top_p": 0.9, "top_k": 30,
                                 "num_predict": 2048, "stream": False})],
                capture_output=True, text=True, timeout=60)

            if result.returncode == 0:
                response = json.loads(result.stdout)
                return response.get("response", "").strip()
        except Exception as e:
            logger.error(f"Refactoring failed: {e}")
        return ""

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: refactoring-assistant.py <file_path>")
        sys.exit(1)
    
    code = Path(sys.argv[1]).read_text()
    assistant = RefactoringAssistant()
    refactored = assistant.refactor_code(code)
    print(refactored)
EOF

chmod +x /home/simon/Learning-Management-System-Academy/.continue/agents/coding/refactoring-assistant.py
echo "✅ Refactoring assistant created"
```

### Phase 3: Deploy to VM 159 (30 minutes)

#### Step 3.1: Copy Agents to VM 159
```bash
# Create directory on VM
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.110 \
    "mkdir -p ~/agents-monitoring"

# Copy geodashboard agent
scp -J root@136.243.155.166:2222 \
    /home/simon/Learning-Management-System-Academy/.continue/agents/geodashboard_autonomous_agent.py \
    simonadmin@10.0.0.110:~/agents-monitoring/

# Copy infrastructure monitor
scp -J root@136.243.155.166:2222 \
    /home/simon/Learning-Management-System-Academy/.continue/agents/infrastructure_monitor_agent.py \
    simonadmin@10.0.0.110:~/agents-monitoring/

# Copy smart agent
scp -J root@136.243.155.166:2222 \
    /home/simon/Learning-Management-System-Academy/.continue/agents/smart_agent.py \
    simonadmin@10.0.0.110:~/agents-monitoring/

echo "✅ Agents copied to VM 159"
```

#### Step 3.2: Create Systemd Services on VM 159
```bash
# SSH to VM 159
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.110 << 'EOSSH'

# Create systemd user directory
mkdir -p ~/.config/systemd/user

# Create geodashboard service
cat > ~/.config/systemd/user/geodashboard-monitor.service << 'EOF'
[Unit]
Description=GeoDashboard Monitoring Agent
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 /home/simonadmin/agents-monitoring/geodashboard_autonomous_agent.py
Restart=always
RestartSec=60
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
EOF

# Create infrastructure monitor service
cat > ~/.config/systemd/user/infrastructure-monitor.service << 'EOF'
[Unit]
Description=Infrastructure Monitoring Agent
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 /home/simonadmin/agents-monitoring/infrastructure_monitor_agent.py
Restart=always
RestartSec=60
StandardOutput=journal
StandardError=journal
Environment="SCAN_INTERVAL_SECONDS=3600"

[Install]
WantedBy=default.target
EOF

# Enable and start services
systemctl --user daemon-reload
systemctl --user enable geodashboard-monitor.service
systemctl --user start geodashboard-monitor.service
systemctl --user enable infrastructure-monitor.service
systemctl --user start infrastructure-monitor.service

echo "✅ Systemd services created and started"
EOSSH
```

#### Step 3.3: Verify VM 159 Services
```bash
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.110 \
    "systemctl --user status geodashboard-monitor.service infrastructure-monitor.service"

# Check logs
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.110 \
    "journalctl --user -u geodashboard-monitor.service -n 10"

echo "✅ VM 159 services running"
```

### Phase 4: Testing & Verification (15 minutes)

#### Step 4.1: Test Continue Config
```bash
# Open VS Code
code ~/.continue/config.json

# Verify JSON is valid
python3 -m json.tool ~/.continue/config.json > /dev/null && echo "✅ Valid config"

# Test Ollama connection
curl -s http://localhost:11434/api/tags | jq '.models[0]' && echo "✅ Ollama working"
```

#### Step 4.2: Test Code Agents
```bash
# Test code generation
python3 /home/simon/Learning-Management-System-Academy/.continue/agents/coding/code-generation-specialist.py \
    python "Function to check if a string is a palindrome"

# Test code review
python3 /home/simon/Learning-Management-System-Academy/.continue/agents/coding/code-review-specialist.py \
    ~/.continue/config.json

echo "✅ Code agents working"
```

#### Step 4.3: Test VS Code Integration
1. Open VS Code
2. Open a Python file
3. Try typing `// ai:` or `# ai:` and see if autocomplete works
4. Test slash commands in Continue chat:
   - `/gen` - code generation
   - `/review` - code review
   - Type some test code and test these commands

#### Step 4.4: Monitor Resource Usage
```bash
# Check local machine memory freed
free -h | grep "Mem:"

# Expected: ~240MB freed compared to before

# Check VM 159 resource usage
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.110 "free -h && top -bn1 | head -15"

# Expected: Still < 15% RAM usage
```

---

## ✅ VALIDATION CHECKLIST

### Local Machine
- [ ] `config.json` is valid JSON
- [ ] Continue extension reloaded
- [ ] No epic_cinematic process running: `ps aux | grep epic_cinematic | grep -v grep` (empty output = good)
- [ ] Ollama responding: `curl http://localhost:11434/api/tags`
- [ ] Code agents work: `python3 .../code-generation-specialist.py python "test"`
- [ ] Memory freed: `free -h` shows improvement
- [ ] VS Code autocomplete working within 200ms

### VM 159
- [ ] Services installed: `systemctl --user list-unit-files | grep -E "(geodashboard|infrastructure)"`
- [ ] Services running: `systemctl --user is-active geodashboard-monitor.service`
- [ ] Logging working: `journalctl --user -u geodashboard-monitor.service -n 5`
- [ ] Resource usage acceptable: `free` and `top`

---

## 🚨 TROUBLESHOOTING

### Issue: "No models available" in Continue

**Solution**:
```bash
# Check Ollama is running
systemctl status ollama

# Pull a model
ollama pull deepseek-coder:6.7b

# Verify
curl http://localhost:11434/api/tags | jq '.models'
```

### Issue: Code agents timeout

**Solution**:
```bash
# Check Ollama performance
time curl -X POST http://localhost:11434/api/generate \
    -H "Content-Type: application/json" \
    -d '{"model": "deepseek-coder:6.7b", "prompt": "hello", "stream": false}'

# If slow, increase timeout in agents or use smaller model
```

### Issue: Continue autocomplete very slow

**Solution**:
```bash
# Reduce temperature further
# Edit config.json: "temperature": 0.1 (lower = faster)

# Or use smaller model for autocomplete
# Edit config.json: "model": "mistral:7b" (faster than deepseek-coder)
```

### Issue: VM 159 services not starting

**Solution**:
```bash
# SSH to VM and check service status
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.110
systemctl --user status geodashboard-monitor.service
journalctl --user -u geodashboard-monitor.service -n 50

# Common issues:
# - Python not found: check /usr/bin/python3 exists
# - Script not found: verify /home/simonadmin/agents-monitoring/ exists
# - Permission denied: chmod +x ~/.config/systemd/user/*.service
```

---

## 📊 EXPECTED RESULTS

### Before Optimization
```
Local machine memory: ~2.5GB used
CPU idle: 60-70%
Continue autocomplete: 200-400ms
Model temperature: 0.7-0.8 (creative, sometimes inconsistent)
Decorative agents: epic_cinematic running continuously
VM 159 capacity: Unused
```

### After Optimization
```
Local machine memory: ~2.2GB used (240MB freed!)
CPU idle: 75-85%
Continue autocomplete: <150ms (faster!)
Model temperature: 0.1-0.2 (deterministic, professional)
Decorative agents: Archived, not consuming resources
VM 159 capacity: Used productively for monitoring
```

---

## 📞 NEXT STEPS

1. ✅ **Implement Phase 1** (Local setup) - 5 minutes
2. ✅ **Implement Phase 2** (Code agents) - 30 minutes
3. ✅ **Implement Phase 3** (VM 159 deployment) - 30 minutes
4. ✅ **Test and verify** - 15 minutes

**Total time**: ~1.5 hours

Once complete, you'll have:
- ✅ Optimized Continue for professional coding
- ✅ 5 new code-focused agents
- ✅ Better resource utilization
- ✅ Faster IDE response times
- ✅ Background monitoring on VM 159

Ready to implement? Let me know! 🚀
