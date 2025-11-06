#!/usr/bin/env python3
"""
Test Generator Specialist Agent
Generates comprehensive unit tests and test suites for code.
Uses DeepSeek Coder 6.7B for intelligent test creation.
"""

import sys
import json
import requests
from typing import Optional

OLLAMA_API_URL = "http://localhost:11434/api/generate"
MODEL = "deepseek-coder:6.7b"


def generate_tests(
    code: str,
    language: str = "python",
    test_framework: Optional[str] = None,
    coverage_target: int = 80,
) -> dict:
    """
    Generate comprehensive unit tests for code.
    
    Args:
        code: The code to test
        language: Programming language (default: python)
        test_framework: Testing framework (e.g., pytest, unittest, jest, mocha)
        coverage_target: Target code coverage percentage
    
    Returns:
        Dictionary with generated tests and recommendations
    """
    frameworks_map = {
        "python": "pytest",
        "javascript": "jest",
        "typescript": "jest",
        "java": "junit",
        "csharp": "nunit",
    }
    
    if not test_framework:
        test_framework = frameworks_map.get(language, "default")
    
    prompt = f"""You are an expert test engineer. Generate comprehensive unit tests for the following {language} code.

Target Framework: {test_framework}
Target Coverage: {coverage_target}%

Code to test:
```{language}
{code}
```

Generate tests that:
1. **Cover all functions/methods** with multiple test cases
2. **Test edge cases and error conditions** (empty inputs, None, invalid values)
3. **Verify return values and side effects**
4. **Include setup/teardown** where needed
5. **Use descriptive test names** that explain what's being tested
6. **Include assertions** with meaningful error messages
7. **Test performance** for critical functions if applicable
8. **Follow best practices** for the {test_framework} framework

Provide:
- Complete test suite code
- Test strategy explanation
- Coverage analysis
- Setup/teardown instructions
- Tips for maintaining tests"""
    
    payload = {
        "model": MODEL,
        "prompt": prompt,
        "stream": False,
        "temperature": 0.1,
        "top_p": 0.9,
    }
    
    try:
        response = requests.post(OLLAMA_API_URL, json=payload, timeout=300)
        response.raise_for_status()
        result = response.json()
        return {
            "status": "success",
            "language": language,
            "framework": test_framework,
            "tests": result.get("response", ""),
            "model": MODEL,
            "input_tokens": result.get("prompt_eval_count", 0),
            "output_tokens": result.get("eval_count", 0),
        }
    except requests.exceptions.RequestException as e:
        return {"status": "error", "error": str(e)}


def generate_integration_tests(
    components: list,
    language: str = "python",
    test_framework: Optional[str] = None,
) -> dict:
    """
    Generate integration tests for multiple components.
    
    Args:
        components: List of dicts with 'name' and 'code' keys
        language: Programming language
        test_framework: Testing framework
    
    Returns:
        Dictionary with integration test code
    """
    components_str = "\n".join(
        [f"## {c['name']}\n```{language}\n{c['code']}\n```" for c in components]
    )
    
    prompt = f"""You are an expert integration test engineer. Generate integration tests for these {language} components.

Components:
{components_str}

Generate integration tests that:
1. **Test interactions** between components
2. **Verify data flow** through the system
3. **Handle async operations** if applicable
4. **Test error propagation** across components
5. **Validate state management**
6. **Include performance benchmarks**

Use {test_framework or 'standard'} framework conventions."""
    
    payload = {
        "model": MODEL,
        "prompt": prompt,
        "stream": False,
        "temperature": 0.1,
        "top_p": 0.9,
    }
    
    try:
        response = requests.post(OLLAMA_API_URL, json=payload, timeout=300)
        response.raise_for_status()
        result = response.json()
        return {
            "status": "success",
            "tests": result.get("response", ""),
            "model": MODEL,
        }
    except requests.exceptions.RequestException as e:
        return {"status": "error", "error": str(e)}


def main():
    """CLI interface for test generator."""
    if len(sys.argv) < 2:
        print("Usage: test_generator_specialist.py <code_file> [language] [framework] [coverage]")
        print("Example: test_generator_specialist.py app.py python pytest 90")
        sys.exit(1)
    
    code_file = sys.argv[1]
    language = sys.argv[2] if len(sys.argv) > 2 else "python"
    framework = sys.argv[3] if len(sys.argv) > 3 else None
    coverage = int(sys.argv[4]) if len(sys.argv) > 4 else 80
    
    try:
        with open(code_file, "r") as f:
            code = f.read()
    except FileNotFoundError:
        print(f"Error: File '{code_file}' not found")
        sys.exit(1)
    
    print(f"\n🧪 Generating tests for {language} code: {code_file}")
    print(f"Framework: {framework or 'auto-detected'}, Target coverage: {coverage}%\n")
    
    result = generate_tests(code, language, framework, coverage)
    
    if result["status"] == "success":
        print(result["tests"])
        print(f"\n📊 Tokens used - Input: {result['input_tokens']}, Output: {result['output_tokens']}")
    else:
        print(f"Error: {result['error']}")
        sys.exit(1)


if __name__ == "__main__":
    main()
