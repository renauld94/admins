#!/usr/bin/env python3
"""
Code Generation Specialist Agent
Generates code from natural language descriptions using DeepSeek Coder 6.7B
Temperature: 0.15 (deterministic, professional output)
"""

import requests
import json
import sys
import argparse
from typing import Optional

OLLAMA_API = "http://localhost:11434"
MODEL = "deepseek-coder:6.7b"


def generate_code(
    prompt: str,
    language: str = "python",
    context: Optional[str] = None,
) -> str:
    """
    Generate code from a natural language prompt.
    
    Args:
        prompt: Natural language description of code to generate
        language: Programming language (python, javascript, typescript, java, sql, bash)
        context: Optional existing code context for reference
    
    Returns:
        Generated code as string
    """
    
    context_str = f"Context/Reference code:\n{context}\n" if context else ""
    full_prompt = f"""You are an expert {language} programmer. Generate professional, production-ready {language} code.

Requirements:
- Write clean, well-commented code
- Follow {language} best practices
- Include error handling where appropriate
- Use meaningful variable names
- Add docstrings/comments for complex logic

{context_str}User Request: {prompt}

Generate only the code, no explanations."""
    
    try:
        response = requests.post(
            f"{OLLAMA_API}/api/generate",
            json={
                "model": MODEL,
                "prompt": full_prompt,
                "stream": False,
                "options": {
                    "temperature": 0.15,
                    "top_p": 0.9,
                    "stop": ["\n\n```", "```\n\n", "User Request:"],
                }
            },
            timeout=60
        )
        response.raise_for_status()
        result = response.json()
        return result.get("response", "").strip()
    except Exception as e:
        return f"Error generating code: {str(e)}"


def main():
    parser = argparse.ArgumentParser(
        description="Generate code from natural language"
    )
    parser.add_argument(
        "prompt",
        help="Natural language description of code to generate"
    )
    parser.add_argument(
        "-l", "--language",
        default="python",
        choices=["python", "javascript", "typescript", "java", "sql", "bash"],
        help="Programming language (default: python)"
    )
    parser.add_argument(
        "-c", "--context",
        help="Optional existing code context"
    )
    
    args = parser.parse_args()
    
    print(f"🔧 Generating {args.language} code...\n")
    code = generate_code(args.prompt, args.language, args.context)
    print(code)
    print(f"\n✅ Code generation complete")


if __name__ == "__main__":
    main()
