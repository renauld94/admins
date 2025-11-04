#!/usr/bin/env python3
"""
Ollama Code Assistant Agent - Uses DeepSeek Coder for code generation and help
Connects to Ollama at VM 159 (10.0.0.110:11434)

Now includes MCP (Model Context Protocol) support for Continue extension.
"""
from fastapi import FastAPI, Depends, Header, HTTPException, Request
from fastapi.responses import StreamingResponse
from pydantic import BaseModel
import uvicorn
import os
import requests
import json
import asyncio
from datetime import datetime

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
CONTEXT_DIR = os.path.join(ROOT, 'workspace', 'agents', 'context', 'ollama-code-assistant')
os.makedirs(CONTEXT_DIR, exist_ok=True)

# Ollama configuration
OLLAMA_BASE_URL = "http://localhost:11434"
DEFAULT_MODEL = "deepseek-coder:6.7b"

app = FastAPI(title="Ollama Code Assistant Agent")


class CodeRequest(BaseModel):
    prompt: str
    language: str = "python"
    model: str = DEFAULT_MODEL
    temperature: float = 0.2
    max_tokens: int = 2000


class CodeReviewRequest(BaseModel):
    code: str
    language: str = "python"
    model: str = "llama3.1:8b"


class ExplainRequest(BaseModel):
    code: str
    language: str = "python"
    model: str = "qwen2.5:7b-instruct"


def get_expected_token():
    """Read token from env or workspace file."""
    token = os.environ.get('NEURO_AGENT_TOKEN')
    if token:
        return token
    token_file = os.path.join(ROOT, 'workspace', 'agents', '.token')
    try:
        with open(token_file, 'r', encoding='utf-8') as f:
            return f.read().strip()
    except Exception:
        return None


def require_token(authorization: str = Header(None)):
    """FastAPI dependency that validates Authorization: Bearer <token>."""
    expected = get_expected_token()
    if not expected:
        # No token configured; allow local access (developer mode)
        return True
    if not authorization:
        raise HTTPException(status_code=401, detail="Missing Authorization header")
    parts = authorization.split()
    if len(parts) != 2 or parts[0].lower() != 'bearer' or parts[1] != expected:
        raise HTTPException(status_code=403, detail="Invalid token")
    return True


def call_ollama(model: str, prompt: str, temperature: float = 0.2, max_tokens: int = 2000):
    """Call Ollama API to generate text."""
    try:
        response = requests.post(
            f"{OLLAMA_BASE_URL}/api/generate",
            json={
                "model": model,
                "prompt": prompt,
                "stream": False,
                "options": {
                    "temperature": temperature,
                    "num_predict": max_tokens
                }
            },
            timeout=120
        )
        
        if response.status_code == 200:
            data = response.json()
            return {
                "success": True,
                "response": data.get("response", ""),
                "model": model
            }
        else:
            return {
                "success": False,
                "error": f"Ollama API error: {response.status_code}",
                "details": response.text
            }
    except Exception as e:
        return {
            "success": False,
            "error": f"Connection error: {str(e)}"
        }


@app.get("/health")
def health():
    """Health check endpoint."""
    # Try to connect to Ollama
    try:
        response = requests.get(f"{OLLAMA_BASE_URL}/api/tags", timeout=5)
        if response.status_code == 200:
            models = response.json().get("models", [])
            return {
                "status": "ok",
                "agent": "ollama-code-assistant",
                "ollama_status": "connected",
                "available_models": len(models)
            }
    except:
        pass
    
    return {
        "status": "degraded",
        "agent": "ollama-code-assistant",
        "ollama_status": "disconnected"
    }


@app.get("/models")
def list_models(_auth: bool = Depends(require_token)):
    """List available Ollama models."""
    try:
        response = requests.get(f"{OLLAMA_BASE_URL}/api/tags", timeout=10)
        if response.status_code == 200:
            data = response.json()
            models = data.get("models", [])
            return {
                "success": True,
                "models": [
                    {
                        "name": m.get("name"),
                        "size": m.get("size"),
                        "modified": m.get("modified_at")
                    }
                    for m in models
                ]
            }
    except Exception as e:
        return {"success": False, "error": str(e)}


@app.post("/generate")
def generate_code(req: CodeRequest, _auth: bool = Depends(require_token)):
    """Generate code using Ollama model."""
    # Enhance prompt with language context
    enhanced_prompt = f"""You are an expert {req.language} programmer. Generate high-quality, clean code for the following task:

{req.prompt}

Provide only the code without explanations, using best practices for {req.language}."""

    result = call_ollama(req.model, enhanced_prompt, req.temperature, req.max_tokens)
    
    # Save to context
    if result.get("success"):
        output_file = os.path.join(CONTEXT_DIR, f"generated_{int(os.times().elapsed * 1000)}.{req.language}")
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(f"# Prompt: {req.prompt}\n")
            f.write(f"# Model: {req.model}\n\n")
            f.write(result["response"])
        result["saved_to"] = output_file
    
    return result


@app.post("/review")
def review_code(req: CodeReviewRequest, _auth: bool = Depends(require_token)):
    """Review code and provide suggestions."""
    prompt = f"""You are an expert code reviewer. Analyze the following {req.language} code and provide:
1. Code quality assessment
2. Potential bugs or issues
3. Performance improvements
4. Best practice recommendations
5. Security concerns (if any)

Code to review:
```{req.language}
{req.code}
```

Provide a structured review with specific, actionable feedback."""

    result = call_ollama(req.model, prompt, 0.3, 2000)
    return result


@app.post("/explain")
def explain_code(req: ExplainRequest, _auth: bool = Depends(require_token)):
    """Explain what code does."""
    prompt = f"""Explain what the following {req.language} code does in detail. Include:
1. Overall purpose
2. Step-by-step breakdown
3. Key algorithms or patterns used
4. Inputs and outputs
5. Any important edge cases

Code:
```{req.language}
{req.code}
```"""

    result = call_ollama(req.model, prompt, 0.2, 2000)
    return result


@app.post("/improve")
def improve_code(req: CodeRequest, _auth: bool = Depends(require_token)):
    """Improve existing code."""
    prompt = f"""You are an expert {req.language} programmer. Improve the following code by:
1. Adding error handling
2. Improving readability
3. Adding type hints/annotations
4. Optimizing performance
5. Following best practices

Original code:
{req.prompt}

Provide the improved code with brief comments explaining major changes."""

    result = call_ollama(req.model, prompt, 0.2, 2000)
    return result


@app.post("/debug")
def debug_code(req: CodeRequest, _auth: bool = Depends(require_token)):
    """Help debug code issues."""
    prompt = f"""You are an expert debugger for {req.language}. Analyze this code and error:

{req.prompt}

Provide:
1. Explanation of what's wrong
2. Root cause analysis
3. Fixed code
4. Prevention tips"""

    result = call_ollama(DEFAULT_MODEL, prompt, 0.2, 2000)
    return result


# ===== MCP (Model Context Protocol) Support =====

@app.get("/mcp/sse")
async def mcp_sse_endpoint(request: Request):
    """
    MCP Server-Sent Events endpoint for Continue extension.
    Provides tools for code generation, review, and explanation.
    """
    async def event_generator():
        # Send initial connection event
        yield f"event: connect\ndata: {json.dumps({'type': 'connect', 'timestamp': datetime.now().isoformat()})}\n\n"
        
        # Send tool list
        tools = {
            "jsonrpc": "2.0",
            "method": "tools/list",
            "result": {
                "tools": [
                    {
                        "name": "generate_code",
                        "description": "Generate code using AI models. Supports Python, JavaScript, Java, C++, etc.",
                        "inputSchema": {
                            "type": "object",
                            "properties": {
                                "prompt": {"type": "string", "description": "Description of code to generate"},
                                "language": {"type": "string", "description": "Programming language (default: python)"},
                                "model": {"type": "string", "description": "AI model to use (default: deepseek-coder:6.7b)"}
                            },
                            "required": ["prompt"]
                        }
                    },
                    {
                        "name": "review_code",
                        "description": "Review code for quality, bugs, performance, and security issues",
                        "inputSchema": {
                            "type": "object",
                            "properties": {
                                "code": {"type": "string", "description": "Code to review"},
                                "language": {"type": "string", "description": "Programming language"}
                            },
                            "required": ["code"]
                        }
                    },
                    {
                        "name": "explain_code",
                        "description": "Explain what code does in plain English",
                        "inputSchema": {
                            "type": "object",
                            "properties": {
                                "code": {"type": "string", "description": "Code to explain"},
                                "language": {"type": "string", "description": "Programming language"}
                            },
                            "required": ["code"]
                        }
                    },
                    {
                        "name": "list_models",
                        "description": "List available Ollama models",
                        "inputSchema": {
                            "type": "object",
                            "properties": {}
                        }
                    }
                ]
            }
        }
        
        yield f"event: tools\ndata: {json.dumps(tools)}\n\n"
        
        # Keep connection alive
        while True:
            if await request.is_disconnected():
                break
            
            # Send heartbeat every 30 seconds
            yield f"event: ping\ndata: {json.dumps({'timestamp': datetime.now().isoformat()})}\n\n"
            await asyncio.sleep(30)
    
    return StreamingResponse(
        event_generator(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no"
        }
    )


@app.post("/mcp/call")
async def mcp_call_tool(request: Request, _auth: bool = Depends(require_token)):
    """
    MCP tool invocation endpoint (JSON-RPC 2.0).
    Called by MCP clients to execute tools.
    """
    try:
        body = await request.json()
    except Exception as e:
        # Malformed/empty JSON in request — return a JSON-RPC error response
        # Avoid crashing the ASGI worker with an uncaught JSONDecodeError.
        from fastapi.responses import JSONResponse
        return JSONResponse(status_code=400, content={
            "jsonrpc": "2.0",
            "error": {"code": -32700, "message": "Parse error: invalid JSON body"},
            "id": None,
        })
    method = body.get("method")
    params = body.get("params", {})
    request_id = body.get("id", 1)
    
    result = None
    error = None
    
    try:
        if method == "tools/call":
            tool_name = params.get("name")
            tool_params = params.get("arguments", {})
            
            if tool_name == "generate_code":
                req = CodeRequest(
                    prompt=tool_params.get("prompt"),
                    language=tool_params.get("language", "python"),
                    model=tool_params.get("model", DEFAULT_MODEL)
                )
                result = generate_code(req, True)
            
            elif tool_name == "review_code":
                req = CodeReviewRequest(
                    code=tool_params.get("code"),
                    language=tool_params.get("language", "python")
                )
                result = review_code(req, True)
            
            elif tool_name == "explain_code":
                req = ExplainRequest(
                    code=tool_params.get("code"),
                    language=tool_params.get("language", "python")
                )
                result = explain_code(req, True)
            
            elif tool_name == "list_models":
                result = list_models(True)
            
            else:
                error = {"code": -32601, "message": f"Unknown tool: {tool_name}"}
        
        elif method == "tools/list":
            result = {
                "tools": [
                    {"name": "generate_code", "description": "Generate code using AI"},
                    {"name": "review_code", "description": "Review code quality"},
                    {"name": "explain_code", "description": "Explain code functionality"},
                    {"name": "list_models", "description": "List available models"}
                ]
            }
        
        else:
            error = {"code": -32601, "message": f"Unknown method: {method}"}
    
    except Exception as e:
        error = {"code": -32603, "message": f"Internal error: {str(e)}"}
    
    # JSON-RPC 2.0 response
    response = {
        "jsonrpc": "2.0",
        "id": request_id
    }
    
    if error:
        response["error"] = error
    else:
        response["result"] = result
    
    return response


if __name__ == "__main__":
    print(f"Starting Ollama Code Assistant Agent on port 5000")
    print(f"Connecting to Ollama at {OLLAMA_BASE_URL}")
    print(f"Default model: {DEFAULT_MODEL}")
    print(f"MCP endpoints: /mcp/sse (SSE), /mcp/call (JSON-RPC)")
    uvicorn.run(app, host="127.0.0.1", port=5000)
