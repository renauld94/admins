
from fastapi import FastAPI, HTTPException
import requests

app = FastAPI()
OLLAMA_API = "http://localhost:11434"
MODEL = "qwen:7b"

@app.get("/health")
async def health():
    return {"status": "ok", "agent": "course_agent", "model": MODEL}

@app.post("/generate-lesson")
async def generate_lesson(topic: str, level: str):
    prompt = f"Create a {level} lesson on {topic} for Vietnamese students"
    try:
        response = requests.post(
            f"{OLLAMA_API}/api/generate",
            json={"model": MODEL, "prompt": prompt},
            timeout=120
        )
        return response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/quiz")
async def generate_quiz(topic: str, num_questions: int = 5):
    prompt = f"Create {num_questions} quiz questions on {topic}"
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
    uvicorn.run(app, host="0.0.0.0", port=5103)
