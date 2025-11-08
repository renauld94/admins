
from fastapi import FastAPI, HTTPException
import requests

app = FastAPI()
OLLAMA_API = "http://localhost:11434"
MODEL = "mistral:7b"

@app.get("/health")
async def health():
    return {"status": "ok", "agent": "tutor_agent", "model": MODEL}

@app.post("/explain")
async def explain_concept(topic: str):
    prompt = f"Explain {topic} in simple, clear language suitable for students"
    try:
        response = requests.post(
            f"{OLLAMA_API}/api/generate",
            json={"model": MODEL, "prompt": prompt},
            timeout=120
        )
        return response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/answer")
async def answer_question(question: str):
    prompt = f"Answer this student question thoughtfully: {question}"
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
    uvicorn.run(app, host="0.0.0.0", port=5104)
