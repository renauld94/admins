#!/usr/bin/env python3
"""
Code Review Specialist Agent
Analyzes code for quality, security, performance, and best practices.
Uses DeepSeek Coder 6.7B for intelligent code analysis.
"""

import sys
import json
import requests
from typing import Optional

OLLAMA_API_URL = "http://localhost:11434/api/generate"
MODEL = "deepseek-coder:6.7b"


def review_code(
    code: str,
    language: str = "python",
    focus_areas: Optional[list] = None,
) -> dict:
    """
    Analyze code for quality issues, security concerns, and improvements.
    
    Args:
        code: The code to review
        language: Programming language (default: python)
        focus_areas: List of areas to focus on (e.g., ['security', 'performance', 'style'])
    
    Returns:
        Dictionary with review results including issues, suggestions, and rating
    """
    if not focus_areas:
        focus_areas = ["security", "performance", "style", "maintainability"]
    
    focus_str = ", ".join(focus_areas)
    
    prompt = f"""You are an expert {language} code reviewer. Analyze the following code thoroughly.

Focus areas: {focus_str}

Code to review:
```{language}
{code}
```

Provide a structured review with:
1. **Issues Found**: List any bugs, security vulnerabilities, or problems
2. **Performance Notes**: Optimization opportunities
3. **Style & Best Practices**: Code quality improvements
4. **Maintainability**: Refactoring suggestions
5. **Overall Rating**: Score 1-10 with explanation
6. **Top 3 Recommendations**: Most important improvements

Be specific with line numbers and examples where possible."""
    
    payload = {
        "model": MODEL,
        "prompt": prompt,
        "stream": False,
        "temperature": 0.2,
        "top_p": 0.9,
    }
    
    try:
        response = requests.post(OLLAMA_API_URL, json=payload, timeout=300)
        response.raise_for_status()
        result = response.json()
        return {
            "status": "success",
            "language": language,
            "review": result.get("response", ""),
            "model": MODEL,
            "input_tokens": result.get("prompt_eval_count", 0),
            "output_tokens": result.get("eval_count", 0),
        }
    except requests.exceptions.RequestException as e:
        return {"status": "error", "error": str(e)}


def batch_review(files_with_code: list) -> list:
    """
    Review multiple code files or snippets.
    
    Args:
        files_with_code: List of dicts with 'name', 'code', 'language' keys
    
    Returns:
        List of review results
    """
    results = []
    for item in files_with_code:
        review = review_code(
            code=item.get("code", ""),
            language=item.get("language", "python"),
            focus_areas=item.get("focus_areas"),
        )
        review["file"] = item.get("name", "unknown")
        results.append(review)
    return results


def main():
    """CLI interface for code review agent."""
    if len(sys.argv) < 2:
        print("Usage: code_review_specialist.py <code_file> [language] [focus_areas]")
        print("Example: code_review_specialist.py app.py python security,performance")
        sys.exit(1)
    
    code_file = sys.argv[1]
    language = sys.argv[2] if len(sys.argv) > 2 else "python"
    focus_areas = sys.argv[3].split(",") if len(sys.argv) > 3 else None
    
    try:
        with open(code_file, "r") as f:
            code = f.read()
    except FileNotFoundError:
        print(f"Error: File '{code_file}' not found")
        sys.exit(1)
    
    print(f"\n🔍 Reviewing {language} code from: {code_file}")
    print(f"Focus areas: {', '.join(focus_areas or ['all'])}\n")
    
    result = review_code(code, language, focus_areas)
    
    if result["status"] == "success":
        print(result["review"])
        print(f"\n📊 Tokens used - Input: {result['input_tokens']}, Output: {result['output_tokens']}")
    else:
        print(f"Error: {result['error']}")
        sys.exit(1)


if __name__ == "__main__":
    main()
