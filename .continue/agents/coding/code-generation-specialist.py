#!/usr/bin/env python3
"""
Code Generation Specialist Agent
Optimized for generating high-quality code with DeepSeek Coder
Temperature: 0.15 (deterministic, professional)

Usage:
  - Invoke via Continue slash command: /gen
  - Or run standalone: python3 code-generation-specialist.py
"""

import os
import sys
import json
import logging
from pathlib import Path
from typing import Optional, Dict, Any
import subprocess

# Configure logging
LOG_DIR = Path.home() / ".local" / "share" / "continue" / "agents" / "logs"
LOG_DIR.mkdir(parents=True, exist_ok=True)
LOG_FILE = LOG_DIR / "code-generation.log"

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s',
    handlers=[
        logging.FileHandler(LOG_FILE),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


class CodeGenerationSpecialist:
    """Specialized agent for code generation with DeepSeek Coder"""

    def __init__(self):
        self.model = "deepseek-coder:6.7b"
        self.temperature = 0.15
        self.max_tokens = 2048
        self.api_base = "http://127.0.0.1:11434"

    def generate_code(
        self,
        prompt: str,
        language: str = "python",
        context: Optional[str] = None
    ) -> str:
        """Generate code from a natural language prompt"""
        
        system_prompt = f"""You are an expert code generator specializing in {language}.
Your goal is to write clean, efficient, production-ready code.

REQUIREMENTS:
1. Follow {language} best practices and conventions
2. Include type hints (where applicable)
3. Add inline comments for complex logic
4. Write deterministic, testable code
5. Handle edge cases and errors
6. Match existing code style if context provided

OUTPUT: Return ONLY valid {language} code. No explanations, no markdown blocks."""

        full_prompt = prompt
        if context:
            full_prompt = f"Context:\n{context}\n\nGenerate:\n{prompt}"

        try:
            result = subprocess.run(
                [
                    "curl", "-s", "-X", "POST",
                    f"{self.api_base}/api/generate",
                    "-H", "Content-Type: application/json",
                    "-d", json.dumps({
                        "model": self.model,
                        "prompt": full_prompt,
                        "system": system_prompt,
                        "temperature": self.temperature,
                        "top_p": 0.85,
                        "top_k": 20,
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
                generated_code = response_data.get("response", "").strip()
                logger.info(f"Generated {len(generated_code)} chars of {language} code")
                return generated_code
            else:
                logger.error(f"API error: {result.stderr}")
                return ""

        except Exception as e:
            logger.error(f"Code generation failed: {e}")
            return ""

    def generate_function(
        self,
        name: str,
        description: str,
        parameters: Dict[str, str],
        language: str = "python"
    ) -> str:
        """Generate a function with given signature"""

        param_str = "\n".join([
            f"  {pname}: {ptype}  # {pdesc}"
            for pname, (ptype, pdesc) in parameters.items()
        ])

        prompt = f"""Generate a {language} function:

Function name: {name}
Description: {description}
Parameters:
{param_str}

Requirements:
- Implement robust logic with error handling
- Include docstring with type hints
- Return appropriate value
- Handle edge cases
"""
        return self.generate_code(prompt, language)

    def generate_class(
        self,
        name: str,
        description: str,
        methods: list,
        language: str = "python"
    ) -> str:
        """Generate a class with specified methods"""

        methods_str = "\n".join([
            f"- {method['name']}: {method['description']}"
            for method in methods
        ])

        prompt = f"""Generate a {language} class:

Class name: {name}
Description: {description}
Methods:
{methods_str}

Requirements:
- Include __init__ method with proper initialization
- Implement all specified methods
- Add docstrings with type hints
- Include error handling
- Use private methods (_) for internal logic
"""
        return self.generate_code(prompt, language)


def main():
    """Main entry point for CLI usage"""
    
    if len(sys.argv) < 2:
        print("Usage: python3 code-generation-specialist.py <language> '<prompt>'")
        print("Example: python3 code-generation-specialist.py python 'Function to calculate fibonacci numbers'")
        sys.exit(1)

    language = sys.argv[1]
    prompt = " ".join(sys.argv[2:])

    specialist = CodeGenerationSpecialist()
    logger.info(f"Generating {language} code for: {prompt}")
    
    code = specialist.generate_code(prompt, language)
    
    if code:
        print("\n" + "="*70)
        print(f"GENERATED {language.upper()} CODE")
        print("="*70)
        print(code)
        print("="*70)
    else:
        print("Code generation failed!")
        sys.exit(1)


if __name__ == "__main__":
    main()
