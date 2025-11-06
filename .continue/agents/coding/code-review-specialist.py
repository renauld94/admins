#!/usr/bin/env python3
"""
Code Review & Analysis Specialist Agent
Analyzes code for bugs, performance, security, and best practices
Temperature: 0.2 (thoughtful, careful analysis)

Usage:
  - Invoke via Continue slash command: /review
  - Or run standalone: python3 code-review-specialist.py <file_path>
"""

import os
import sys
import json
import logging
from pathlib import Path
from typing import Optional, List, Dict, Any
import subprocess

# Configure logging
LOG_DIR = Path.home() / ".local" / "share" / "continue" / "agents" / "logs"
LOG_DIR.mkdir(parents=True, exist_ok=True)
LOG_FILE = LOG_DIR / "code-review.log"

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s',
    handlers=[
        logging.FileHandler(LOG_FILE),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


class CodeReviewSpecialist:
    """Specialized agent for code review and analysis"""

    def __init__(self):
        self.model = "deepseek-coder:6.7b"
        self.temperature = 0.2
        self.max_tokens = 2048
        self.api_base = "http://127.0.0.1:11434"

    def review_code(
        self,
        code: str,
        language: str = "python",
        focus: Optional[List[str]] = None
    ) -> Dict[str, Any]:
        """
        Review code for issues and improvements
        
        Focus areas: ['performance', 'security', 'readability', 'bugs', 'best_practices']
        """

        if focus is None:
            focus = ['bugs', 'performance', 'security', 'readability', 'best_practices']

        focus_str = "\n".join([f"- {f}" for f in focus])

        system_prompt = f"""You are an expert {language} code reviewer.
Analyze the provided code and provide constructive feedback.

ANALYSIS AREAS:
{focus_str}

OUTPUT FORMAT:
Return JSON with this structure:
{{
  "summary": "Brief 1-2 sentence overview",
  "rating": 1-10,
  "issues": [
    {{"severity": "critical|high|medium|low", "type": "bug|performance|security|style", "description": "...", "suggestion": "..."}}
  ],
  "strengths": ["strength 1", "strength 2"],
  "improvements": ["improvement 1", "improvement 2"],
  "security_notes": "...",
  "performance_notes": "..."
}}

Be specific and actionable. No rambling explanations."""

        prompt = f"Review this {language} code:\n\n```{language}\n{code}\n```"

        try:
            result = subprocess.run(
                [
                    "curl", "-s", "-X", "POST",
                    f"{self.api_base}/api/generate",
                    "-H", "Content-Type: application/json",
                    "-d", json.dumps({
                        "model": self.model,
                        "prompt": prompt,
                        "system": system_prompt,
                        "temperature": self.temperature,
                        "top_p": 0.9,
                        "top_k": 30,
                        "num_predict": self.max_tokens,
                        "stream": False
                    })
                ],
                capture_output=True,
                text=True,
                timeout=30
            )

            if result.returncode == 0:
                response_data = json.loads(result.stdout)
                response_text = response_data.get("response", "").strip()
                
                # Try to parse JSON response
                try:
                    review_json = json.loads(response_text)
                    logger.info(f"Code review complete. Rating: {review_json.get('rating')}/10")
                    return review_json
                except json.JSONDecodeError:
                    logger.warning("Response not valid JSON, returning raw text")
                    return {"raw_response": response_text}
            else:
                logger.error(f"API error: {result.stderr}")
                return {"error": result.stderr}

        except Exception as e:
            logger.error(f"Code review failed: {e}")
            return {"error": str(e)}

    def suggest_refactoring(self, code: str, language: str = "python") -> str:
        """Suggest refactoring improvements"""

        system_prompt = f"""You are a {language} code refactoring expert.
Suggest specific refactoring improvements for the given code.

OUTPUT: Return ONLY refactored code with comments explaining key changes.
No explanations or markdown blocks."""

        prompt = f"""Refactor this {language} code to improve:
1. Readability
2. Maintainability
3. Performance
4. Testability

Code:
```{language}
{code}
```"""

        try:
            result = subprocess.run(
                [
                    "curl", "-s", "-X", "POST",
                    f"{self.api_base}/api/generate",
                    "-H", "Content-Type: application/json",
                    "-d", json.dumps({
                        "model": self.model,
                        "prompt": prompt,
                        "system": system_prompt,
                        "temperature": self.temperature,
                        "top_p": 0.9,
                        "top_k": 30,
                        "num_predict": 2048,
                        "stream": False
                    })
                ],
                capture_output=True,
                text=True,
                timeout=30
            )

            if result.returncode == 0:
                response_data = json.loads(result.stdout)
                return response_data.get("response", "").strip()
            else:
                logger.error(f"API error: {result.stderr}")
                return ""

        except Exception as e:
            logger.error(f"Refactoring suggestion failed: {e}")
            return ""

    def check_security(self, code: str, language: str = "python") -> List[Dict[str, str]]:
        """Check code for security vulnerabilities"""

        system_prompt = f"""You are a {language} security expert.
Analyze code for security vulnerabilities and issues.

Common issues to check:
- SQL injection risks
- Path traversal vulnerabilities
- Input validation gaps
- Hardcoded secrets/credentials
- Unsafe deserialization
- Missing authentication/authorization
- Cross-site scripting (XSS) risks

OUTPUT: Return JSON array of security issues."""

        prompt = f"Check this {language} code for security issues:\n\n```{language}\n{code}\n```"

        try:
            result = subprocess.run(
                [
                    "curl", "-s", "-X", "POST",
                    f"{self.api_base}/api/generate",
                    "-H", "Content-Type: application/json",
                    "-d", json.dumps({
                        "model": self.model,
                        "prompt": prompt,
                        "system": system_prompt,
                        "temperature": 0.15,
                        "top_p": 0.85,
                        "top_k": 20,
                        "num_predict": 1024,
                        "stream": False
                    })
                ],
                capture_output=True,
                text=True,
                timeout=30
            )

            if result.returncode == 0:
                response_data = json.loads(result.stdout)
                response_text = response_data.get("response", "").strip()
                
                try:
                    issues = json.loads(response_text)
                    if isinstance(issues, list):
                        return issues
                    else:
                        return [issues]
                except json.JSONDecodeError:
                    return [{"raw_response": response_text}]
            else:
                return [{"error": result.stderr}]

        except Exception as e:
            logger.error(f"Security check failed: {e}")
            return [{"error": str(e)}]


def main():
    """Main entry point for CLI usage"""
    
    if len(sys.argv) < 2:
        print("Usage: python3 code-review-specialist.py <file_path> [focus_area]")
        print("Focus areas: bugs, performance, security, readability, best_practices")
        sys.exit(1)

    file_path = sys.argv[1]
    
    if not Path(file_path).exists():
        print(f"Error: File not found: {file_path}")
        sys.exit(1)

    code = Path(file_path).read_text()
    
    # Detect language from extension
    ext = Path(file_path).suffix.lower()
    language_map = {
        '.py': 'python',
        '.js': 'javascript',
        '.ts': 'typescript',
        '.java': 'java',
        '.go': 'go',
        '.rs': 'rust',
        '.cpp': 'cpp',
        '.c': 'c',
    }
    language = language_map.get(ext, 'python')

    focus = sys.argv[2:] if len(sys.argv) > 2 else None

    specialist = CodeReviewSpecialist()
    logger.info(f"Reviewing {language} code from: {file_path}")
    
    review = specialist.review_code(code, language, focus)
    
    print("\n" + "="*70)
    print(f"CODE REVIEW: {file_path}")
    print("="*70)
    print(json.dumps(review, indent=2))
    print("="*70)


if __name__ == "__main__":
    main()
