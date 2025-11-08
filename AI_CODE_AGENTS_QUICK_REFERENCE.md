# AI Code Agents: Quick Reference Guide

## Overview

5 specialized AI agents deployed on VM 159 for intelligent code development. All agents use DeepSeek Coder 6.7B model via Ollama.

---

## Agent Quick Reference

### 🔨 Code Generation Specialist
**Generates production-ready code from natural language**

```bash
# Local usage
python3 .continue/agents/code_generation_specialist.py \
  "Create a REST endpoint for user authentication" \
  python

# VM 159 usage
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.110 \
  "python3 ~/vm159-agents/code_generation_specialist.py \
   'Your request' python"
```

**Supported languages:** Python, JavaScript, TypeScript, Java, SQL, Bash  
**Temperature:** 0.15 (deterministic)  
**Best for:** New functions, endpoints, utilities

---

### 📋 Code Review Specialist
**Intelligent code quality and security analysis**

```bash
# Review specific file
python3 .continue/agents/code_review_specialist.py \
  app.py python \
  "security,performance"

# Focus areas options:
# - security: Vulnerabilities, access control, data safety
# - performance: Algorithm efficiency, resource usage
# - style: Code conventions, readability
# - maintainability: Clarity, structure, reusability
```

**Temperature:** 0.2 (analytical)  
**Best for:** Code audits, security checks, performance optimization

---

### 🧪 Test Generator Specialist
**Generate comprehensive unit and integration tests**

```bash
# Generate unit tests
python3 .continue/agents/test_generator_specialist.py \
  app.py python pytest 90

# Arguments:
# - Code file to test
# - Language (python, javascript, typescript, java, csharp)
# - Framework (pytest, jest, junit, nunit)
# - Coverage target (1-100%)
```

**Temperature:** 0.1 (deterministic)  
**Frameworks:** pytest, jest, junit, nunit  
**Best for:** Test-driven development, coverage improvement, regression testing

---

### 📚 Documentation Generator
**Generate docstrings, API docs, and README files**

```bash
# Generate docstrings with Google style
python3 .continue/agents/documentation_generator.py \
  app.py python google

# Docstring styles:
# - google: Google-style with Args/Returns/Raises
# - numpy: NumPy-style with Parameters/Returns/Notes
# - sphinx: reStructuredText for Sphinx docs
# - jsdoc: JSDoc format (JavaScript/TypeScript)
# - auto: Auto-detect best style
```

**Temperature:** 0.3 (creative)  
**Best for:** API documentation, onboarding docs, code clarity

---

### 🔧 Refactoring Assistant
**Suggest code improvements and optimization strategies**

```bash
# Analyze refactoring opportunities
python3 .continue/agents/refactoring_assistant.py \
  app.py python \
  "complexity,duplication,efficiency"

# Focus areas:
# - complexity: Reduce cyclomatic complexity
# - duplication: Remove repeated code
# - efficiency: Performance optimization
# - maintainability: Improve clarity and structure
```

**Temperature:** 0.25 (balanced suggestions)  
**Best for:** Code cleanup, performance tuning, architecture review

---

## Integration with CONTINUE Extension

### Keybinding Setup

Add to VS Code `keybindings.json`:

```json
[
  {
    "key": "ctrl+shift+g",
    "command": "continue.runCommand",
    "args": {
      "command": "python3 ~/.continue/agents/code_generation_specialist.py"
    }
  },
  {
    "key": "ctrl+shift+r",
    "command": "continue.runCommand",
    "args": {
      "command": "python3 ~/.continue/agents/code_review_specialist.py"
    }
  },
  {
    "key": "ctrl+shift+t",
    "command": "continue.runCommand",
    "args": {
      "command": "python3 ~/.continue/agents/test_generator_specialist.py"
    }
  },
  {
    "key": "ctrl+shift+d",
    "command": "continue.runCommand",
    "args": {
      "command": "python3 ~/.continue/agents/documentation_generator.py"
    }
  },
  {
    "key": "ctrl+shift+f",
    "command": "continue.runCommand",
    "args": {
      "command": "python3 ~/.continue/agents/refactoring_assistant.py"
    }
  }
]
```

---

## Python API Usage

### Example: Code Generation

```python
from code_generation_specialist import generate_code

result = generate_code(
    prompt="Create a function that validates email addresses",
    language="python",
    context="Use regex for validation"
)

if result["status"] == "success":
    print(result["generated_code"])
    print(f"Tokens: {result['input_tokens']} → {result['output_tokens']}")
```

### Example: Code Review

```python
from code_review_specialist import review_code

code_to_review = """
def process_data(data):
    for item in data:
        x = item * 2
        print(x)
"""

result = review_code(
    code=code_to_review,
    language="python",
    focus_areas=["performance", "style"]
)

print(result["review"])
```

### Example: Test Generation

```python
from test_generator_specialist import generate_tests

code_under_test = """
def add(a, b):
    return a + b
"""

result = generate_tests(
    code=code_under_test,
    language="python",
    test_framework="pytest",
    coverage_target=100
)

print(result["tests"])
```

---

## Best Practices

### ✅ DO

- Start with Code Generation for new functions
- Use Code Review before committing code
- Generate tests alongside implementation
- Keep focus areas specific (2-3 at a time)
- Use context when generating related code
- Review agent suggestions before applying

### ❌ DON'T

- Use Code Generation for entire applications (break into modules)
- Ignore Code Review security warnings
- Skip test generation for critical functions
- Use excessively broad focus areas
- Trust agent output without verification
- Generate code without understanding it

---

## Performance Notes

### Temperature Tuning

Each agent uses optimized temperatures:

| Agent | Temperature | Characteristics |
|-------|-------------|-----------------|
| Code Generation | 0.15 | Predictable, consistent |
| Code Review | 0.2 | Analytical, thorough |
| Test Generation | 0.1 | Deterministic, comprehensive |
| Documentation | 0.3 | Creative, varied |
| Refactoring | 0.25 | Balanced, pragmatic |

Lower temperatures = more deterministic, useful for code  
Higher temperatures = more creative, useful for documentation

### API Response Times

- **Typical:** 5-30 seconds per request
- **Large files (>1000 LOC):** 30-60 seconds
- **Timeout:** 300 seconds (5 minutes)

**Tips for faster responses:**
- Keep code samples under 500 LOC
- Use specific focus areas
- Provide clear, concise prompts

---

## Troubleshooting

### Agent Not Found

```bash
# Check if agent is deployed
ls -l ~/vm159-agents/*_specialist.py

# Check permissions
chmod +x ~/vm159-agents/*_specialist.py
```

### Ollama Connection Error

```bash
# Verify Ollama is running
curl http://localhost:11434/api/tags

# Check model is available
ollama list | grep deepseek-coder

# Restart Ollama if needed
ollama serve
```

### Syntax Error in Generated Code

- Ask agent to include error handling
- Specify Python version for compatibility
- Request inline comments for clarity
- Review output before using

### Poor Quality Suggestions

- Provide more context in prompts
- Use specific focus areas
- Increase code sample size for analysis
- Ask for multiple options and pick best

---

## Advanced Usage

### Batch Processing

```python
from code_review_specialist import batch_review

files = [
    {"name": "app.py", "code": "...", "language": "python"},
    {"name": "utils.py", "code": "...", "language": "python"},
]

results = batch_review(files)
for result in results:
    print(f"{result['file']}: {result['review']}")
```

### Custom Focus Areas

Create custom focus profiles:

```python
# Security-focused review
security_review = review_code(
    code=code,
    language="python",
    focus_areas=["security", "access_control", "data_safety"]
)

# Performance-focused review
perf_review = review_code(
    code=code,
    language="python",
    focus_areas=["performance", "efficiency", "complexity"]
)
```

### Integration with Pre-commit

Add to `.git/hooks/pre-commit`:

```bash
#!/bin/bash
# Auto-review changed Python files

for file in $(git diff --cached --name-only | grep ".py$"); do
    python3 ~/.continue/agents/code_review_specialist.py \
        "$file" python security
    
    if [ $? -ne 0 ]; then
        echo "Code review failed for $file"
        exit 1
    fi
done
```

---

## File Locations

| Location | Purpose |
|----------|---------|
| `~/.continue/agents/` | Local agents |
| `~/vm159-agents/` | Remote VM 159 deployment |
| `.continue/config.json` | CONTINUE extension config |
| `~/.continue/config.json.backup` | Config backup (Phase 3) |

---

## Support & Resources

- **Configuration:** `.continue/config.json`
- **Model Docs:** https://github.com/deepseek-ai/deepseek-coder
- **Ollama Docs:** https://ollama.ai/
- **CONTINUE Docs:** https://docs.continue.dev/

---

**Last Updated:** November 6, 2024  
**Agent Version:** Phase 4  
**Model:** DeepSeek Coder 6.7B  
**Status:** Production Ready ✅
