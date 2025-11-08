
from fastapi import FastAPI, HTTPException
import requests
import json

app = FastAPI()
OLLAMA_API = "http://localhost:11434"
MODEL = "llama3.1:8b"

@app.get("/health")
async def health():
    return {"status": "ok", "agent": "data_agent", "model": MODEL}

@app.post("/analyze")
async def analyze_data(query: str):
    prompt = f"Analyze this data science question: {query}"
    try:
        response = requests.post(
            f"{OLLAMA_API}/api/generate",
            json={"model": MODEL, "prompt": prompt},
            timeout=120
        )
        return response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/visualize")
async def suggest_visualization(data_description: str):
    prompt = f"Suggest data visualizations for: {data_description}"
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
    uvicorn.run(app, host="0.0.0.0", port=5102)
