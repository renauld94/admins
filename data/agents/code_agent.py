
from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
import requests
import json

app = FastAPI()
OLLAMA_API = "http://localhost:11434"
MODEL = "deepseek-coder:6.7b"

@app.get("/health")
async def health():
    return {"status": "ok", "agent": "code_agent", "model": MODEL}

@app.post("/generate")
async def generate_code(prompt: str):
    try:
        response = requests.post(
            f"{OLLAMA_API}/api/generate",
            json={"model": MODEL, "prompt": prompt},
            timeout=120
        )
        return response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/review")
async def review_code(code: str):
    prompt = f"Review this code and suggest improvements:\n{code}"
    try:
        response = requests.post(
            f"{OLLAMA_API}/api/generate",
            json={"model": MODEL, "prompt": prompt},
            timeout=120
        )
        return response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=5101)
