#!/usr/bin/env python3
"""
Refactoring Assistant Agent
Suggests and implements code refactoring improvements.
Uses DeepSeek Coder 6.7B for intelligent code optimization.
"""

import sys
import json
import requests
from typing import Optional

OLLAMA_API_URL = "http://localhost:11434/api/generate"
MODEL = "deepseek-coder:6.7b"


def analyze_refactoring_opportunities(
    code: str,
    language: str = "python",
    focus_areas: Optional[list] = None,
) -> dict:
    """
    Analyze code and suggest refactoring improvements.
    
    Args:
        code: The code to analyze
        language: Programming language (default: python)
        focus_areas: Specific refactoring areas (complexity, duplication, efficiency, maintainability)
    
    Returns:
        Dictionary with refactoring suggestions
    """
    if not focus_areas:
        focus_areas = ["complexity", "duplication", "efficiency", "maintainability"]
    
    focus_str = ", ".join(focus_areas)
    
    prompt = f"""You are an expert code refactoring specialist. Analyze this {language} code and suggest improvements.

Focus areas: {focus_str}

Code to refactor:
```{language}
{code}
```

Provide:
1. **Code Metrics** - Complexity, duplication, performance baseline
2. **Refactoring Opportunities** - List each opportunity with:
   - What: Specific issue
   - Why: Why it's a problem
   - How: Concrete refactoring solution
   - Priority: High/Medium/Low
   - Effort: Estimated complexity to implement

3. **Refactored Examples** - Show before/after for top 3 improvements
4. **Design Patterns** - Suggest applicable patterns
5. **Performance Impact** - Estimated improvements
6. **Implementation Order** - Prioritized sequence for refactoring
7. **Testing Strategy** - How to verify refactoring works

Be specific with line numbers and exact code examples."""
    
    payload = {
        "model": MODEL,
        "prompt": prompt,
        "stream": False,
        "temperature": 0.25,
        "top_p": 0.9,
    }
    
    try:
        response = requests.post(OLLAMA_API_URL, json=payload, timeout=300)
        response.raise_for_status()
        result = response.json()
        return {
            "status": "success",
            "language": language,
            "focus": focus_areas,
            "analysis": result.get("response", ""),
            "model": MODEL,
            "input_tokens": result.get("prompt_eval_count", 0),
            "output_tokens": result.get("eval_count", 0),
        }
    except requests.exceptions.RequestException as e:
        return {"status": "error", "error": str(e)}


def refactor_for_performance(
    code: str,
    language: str = "python",
    constraints: Optional[str] = None,
) -> dict:
    """
    Generate performance-optimized version of code.
    
    Args:
        code: The code to optimize
        language: Programming language
        constraints: Special requirements or constraints
    
    Returns:
        Dictionary with optimized code
    """
    prompt = f"""You are an expert {language} performance specialist. Optimize this code for speed and efficiency.

Constraints: {constraints or 'None specified - optimize freely'}

Original code:
```{language}
{code}
```

Generate optimized code that:
1. **Reduces time complexity** where possible
2. **Minimizes memory usage**
3. **Eliminates unnecessary operations**
4. **Uses efficient data structures**
5. **Leverages built-in optimizations** in {language}
6. **Maintains readability and correctness**
7. **Includes performance comments**

Provide:
- Optimized code with comments
- Performance improvement breakdown (time/space)
- Benchmarking notes
- Trade-offs (if any)"""
    
    payload = {
        "model": MODEL,
        "prompt": prompt,
        "stream": False,
        "temperature": 0.25,
        "top_p": 0.9,
    }
    
    try:
        response = requests.post(OLLAMA_API_URL, json=payload, timeout=300)
        response.raise_for_status()
        result = response.json()
        return {
            "status": "success",
            "optimized_code": result.get("response", ""),
            "model": MODEL,
        }
    except requests.exceptions.RequestException as e:
        return {"status": "error", "error": str(e)}


def suggest_design_patterns(
    code: str,
    language: str = "python",
) -> dict:
    """
    Suggest applicable design patterns for code.
    
    Args:
        code: The code to analyze
        language: Programming language
    
    Returns:
        Dictionary with design pattern suggestions
    """
    prompt = f"""You are a software architecture expert. Analyze this {language} code and suggest design patterns.

Code:
```{language}
{code}
```

Suggest:
1. **Currently Applicable Patterns** - What patterns are already in use
2. **Missing Patterns** - What patterns would improve this code
3. **Anti-Patterns** - Any problematic patterns being used
4. **Pattern Implementations** - Code examples for suggested patterns
5. **Benefits** - How patterns improve:
   - Maintainability
   - Scalability
   - Testability
   - Reusability

Focus on practical, immediately applicable patterns for {language}."""
    
    payload = {
        "model": MODEL,
        "prompt": prompt,
        "stream": False,
        "temperature": 0.25,
        "top_p": 0.9,
    }
    
    try:
        response = requests.post(OLLAMA_API_URL, json=payload, timeout=300)
        response.raise_for_status()
        result = response.json()
        return {
            "status": "success",
            "patterns": result.get("response", ""),
            "model": MODEL,
        }
    except requests.exceptions.RequestException as e:
        return {"status": "error", "error": str(e)}


def main():
    """CLI interface for refactoring assistant."""
    if len(sys.argv) < 2:
        print("Usage: refactoring_assistant.py <code_file> [language] [focus_areas]")
        print("Example: refactoring_assistant.py app.py python complexity,duplication")
        print("\nFocus areas: complexity, duplication, efficiency, maintainability, all")
        sys.exit(1)
    
    code_file = sys.argv[1]
    language = sys.argv[2] if len(sys.argv) > 2 else "python"
    focus = sys.argv[3].split(",") if len(sys.argv) > 3 else None
    
    try:
        with open(code_file, "r") as f:
            code = f.read()
    except FileNotFoundError:
        print(f"Error: File '{code_file}' not found")
        sys.exit(1)
    
    print(f"\n🔧 Analyzing refactoring opportunities for {language}: {code_file}")
    print(f"Focus: {', '.join(focus or ['all'])}\n")
    
    result = analyze_refactoring_opportunities(code, language, focus)
    
    if result["status"] == "success":
        print(result["analysis"])
        print(f"\n📊 Tokens used - Input: {result['input_tokens']}, Output: {result['output_tokens']}")
    else:
        print(f"Error: {result['error']}")
        sys.exit(1)


if __name__ == "__main__":
    main()
