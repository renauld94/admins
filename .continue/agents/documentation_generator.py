#!/usr/bin/env python3
"""
Documentation Generator Agent
Generates comprehensive documentation, docstrings, and API docs.
Uses DeepSeek Coder 6.7B for intelligent documentation creation.
"""

import sys
import json
import requests
from typing import Optional

OLLAMA_API_URL = "http://localhost:11434/api/generate"
MODEL = "deepseek-coder:6.7b"


def generate_docstrings(
    code: str,
    language: str = "python",
    doc_style: str = "auto",
) -> dict:
    """
    Generate docstrings and inline comments for code.
    
    Args:
        code: The code to document
        language: Programming language (default: python)
        doc_style: Documentation style (google, numpy, sphinx, jsdoc, auto)
    
    Returns:
        Dictionary with documented code
    """
    style_guidance = {
        "python": {
            "google": "Google-style docstrings with Args, Returns, Raises sections",
            "numpy": "NumPy-style docstrings with Parameters, Returns, Notes",
            "sphinx": "Sphinx reStructuredText format with :param:, :return:, :raises:",
            "auto": "Auto-detect best style for Python (Google preferred)",
        },
        "javascript": {
            "jsdoc": "JSDoc format with @param, @returns, @throws tags",
            "auto": "JSDoc format",
        },
        "typescript": {
            "jsdoc": "JSDoc format with type annotations",
            "auto": "JSDoc with TypeScript types",
        },
    }
    
    language_styles = style_guidance.get(language, {})
    style_info = language_styles.get(doc_style, "Auto-detect best style")
    
    prompt = f"""You are an expert technical writer. Add comprehensive documentation to this {language} code.

Documentation Style: {style_info}

Code to document:
```{language}
{code}
```

Generate:
1. **Docstrings for all functions/methods** with:
   - Clear description of purpose
   - All parameters with types and descriptions
   - Return value documentation
   - Exceptions/errors that can be raised
   - Usage examples for complex functions

2. **Inline comments** explaining:
   - Complex logic or algorithms
   - Why decisions were made (not just what)
   - Non-obvious implementation details
   - Performance considerations

3. **Module/file docstring** with:
   - Overall purpose and scope
   - Key components/classes
   - Usage examples
   - Dependencies and requirements

Follow {language} conventions and best practices for documentation.
Make documentation clear enough for new developers to understand."""
    
    payload = {
        "model": MODEL,
        "prompt": prompt,
        "stream": False,
        "temperature": 0.3,
        "top_p": 0.9,
    }
    
    try:
        response = requests.post(OLLAMA_API_URL, json=payload, timeout=300)
        response.raise_for_status()
        result = response.json()
        return {
            "status": "success",
            "language": language,
            "doc_style": doc_style,
            "documented_code": result.get("response", ""),
            "model": MODEL,
            "input_tokens": result.get("prompt_eval_count", 0),
            "output_tokens": result.get("eval_count", 0),
        }
    except requests.exceptions.RequestException as e:
        return {"status": "error", "error": str(e)}


def generate_api_documentation(
    code: str,
    language: str = "python",
    title: str = "API Documentation",
    base_url: Optional[str] = None,
) -> dict:
    """
    Generate API documentation for REST endpoints or public interfaces.
    
    Args:
        code: The code/endpoints to document
        language: Programming language
        title: API title
        base_url: Base URL for API examples
    
    Returns:
        Dictionary with formatted API documentation
    """
    prompt = f"""You are an expert API documentation writer. Generate comprehensive API documentation.

API Title: {title}
Base URL: {base_url or 'to be determined'}

Code/Endpoints:
```{language}
{code}
```

Generate documentation with:
1. **Overview** - Purpose and key features
2. **Authentication** - Required credentials/tokens
3. **Endpoints** - Full listing with:
   - HTTP method and path
   - Description
   - Parameters (query, path, body)
   - Response format and examples
   - Error codes and meanings
   - Rate limiting info
4. **Examples** - cURL, Python, JavaScript examples
5. **Error Handling** - Common errors and solutions
6. **Versioning** - API version and changelog
7. **SDK Info** - Available SDKs if applicable

Use clear, professional language suitable for developers."""
    
    payload = {
        "model": MODEL,
        "prompt": prompt,
        "stream": False,
        "temperature": 0.3,
        "top_p": 0.9,
    }
    
    try:
        response = requests.post(OLLAMA_API_URL, json=payload, timeout=300)
        response.raise_for_status()
        result = response.json()
        return {
            "status": "success",
            "api_docs": result.get("response", ""),
            "model": MODEL,
        }
    except requests.exceptions.RequestException as e:
        return {"status": "error", "error": str(e)}


def generate_readme(
    project_name: str,
    project_description: str,
    code_samples: Optional[list] = None,
) -> dict:
    """
    Generate a comprehensive README for a project.
    
    Args:
        project_name: Name of the project
        project_description: Description of what the project does
        code_samples: List of key code files/snippets
    
    Returns:
        Dictionary with README content
    """
    samples_section = ""
    if code_samples:
        samples_section = "\n".join(
            [f"## Key Files\n{s}" for s in code_samples]
        )
    
    prompt = f"""Generate a professional README.md for this project.

Project: {project_name}
Description: {project_description}

{samples_section}

Include sections:
1. **Title and Description** - Clear project overview
2. **Features** - Key capabilities
3. **Installation** - Setup instructions
4. **Quick Start** - Getting started guide
5. **Usage** - Examples and common tasks
6. **API Reference** - If applicable
7. **Configuration** - Environment variables, settings
8. **Contributing** - How to contribute
9. **License** - Licensing info
10. **Support/Contact** - How to get help

Make it engaging, clear, and professional for GitHub/GitLab."""
    
    payload = {
        "model": MODEL,
        "prompt": prompt,
        "stream": False,
        "temperature": 0.3,
        "top_p": 0.9,
    }
    
    try:
        response = requests.post(OLLAMA_API_URL, json=payload, timeout=300)
        response.raise_for_status()
        result = response.json()
        return {
            "status": "success",
            "readme": result.get("response", ""),
            "model": MODEL,
        }
    except requests.exceptions.RequestException as e:
        return {"status": "error", "error": str(e)}


def main():
    """CLI interface for documentation generator."""
    if len(sys.argv) < 2:
        print("Usage: documentation_generator.py <code_file> [language] [style]")
        print("Example: documentation_generator.py app.py python google")
        print("\nStyles: google, numpy, sphinx (Python); jsdoc (JavaScript/TypeScript)")
        sys.exit(1)
    
    code_file = sys.argv[1]
    language = sys.argv[2] if len(sys.argv) > 2 else "python"
    doc_style = sys.argv[3] if len(sys.argv) > 3 else "auto"
    
    try:
        with open(code_file, "r") as f:
            code = f.read()
    except FileNotFoundError:
        print(f"Error: File '{code_file}' not found")
        sys.exit(1)
    
    print(f"\n📚 Generating documentation for {language} code: {code_file}")
    print(f"Documentation style: {doc_style}\n")
    
    result = generate_docstrings(code, language, doc_style)
    
    if result["status"] == "success":
        print(result["documented_code"])
        print(f"\n📊 Tokens used - Input: {result['input_tokens']}, Output: {result['output_tokens']}")
    else:
        print(f"Error: {result['error']}")
        sys.exit(1)


if __name__ == "__main__":
    main()
