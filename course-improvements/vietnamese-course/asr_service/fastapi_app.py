from fastapi import FastAPI, File, UploadFile, HTTPException, Request
import uvicorn
import tempfile
import os

try:
    import whisper
except Exception:
    whisper = None

app = FastAPI(title="Vietnamese ASR Service")


@app.post("/transcribe")
async def transcribe(request: Request, file: UploadFile = File(...), model_size: str = "small"):
    """Accept a single audio upload and return a transcript (requires whisper installed).

    Returns JSON: { text: str, segments: [..] }
    """
    # Simple API key check (optional): set ASR_API_KEY env var to enable.
    configured_key = os.environ.get("ASR_API_KEY")
    # When ASR_API_KEY is set, require X-API-KEY header with that value.
    if configured_key:
        header_key = request.headers.get("x-api-key") or request.headers.get("X-API-KEY")
        if header_key != configured_key:
            raise HTTPException(status_code=401, detail="Missing or invalid API key")

    if whisper is None:
        raise HTTPException(status_code=500, detail="Whisper not installed on server. See README for setup.")

    suffix = os.path.splitext(file.filename)[1] or ".wav"
    with tempfile.NamedTemporaryFile(suffix=suffix, delete=False) as tmp:
        content = await file.read()
        tmp.write(content)
        tmp_path = tmp.name

    try:
        # If ASR_API_KEY is configured, validate header
        configured_key = os.environ.get("ASR_API_KEY")
        if configured_key:
            # header may be provided in the UploadFile request; check environ-backed header via os.environ is not possible here
            # To keep this function self-contained, read the header from the environment-injected REQUEST_HEADERS if present.
            # Use the presence of the HTTP_X_API_KEY environment var only for containerized environments that map headers —
            # but standard approach is to pass the Request object; for simplicity, check the X_API_KEY env override.
            header_key = None
            # Try to read a forwarded header value from environment (not always present)
            header_key = os.environ.get('HTTP_X_API_KEY') or os.environ.get('X_API_KEY')
            if header_key != configured_key:
                raise HTTPException(status_code=401, detail="Missing or invalid API key")

        model = whisper.load_model(model_size)
        result = model.transcribe(tmp_path)
        return {"text": result.get("text", ""), "segments": result.get("segments", [])}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        try:
            os.unlink(tmp_path)
        except Exception:
            pass


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
