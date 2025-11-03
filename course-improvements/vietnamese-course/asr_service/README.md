# ASR Service (starter)

This folder contains a minimal FastAPI service that accepts a single audio file upload and returns a Whisper transcription.

Quick notes

- The service is a starter. Running Whisper on CPU is slow. For production, use a GPU-backed VM or smaller models.
- This service intentionally keeps things simple for easy deployment and review. Do not expose it without authentication in production.

Run locally (venv)

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
# install torch following your platform instructions if needed
python fastapi_app.py
```

Test upload (example)

```bash
curl -F "file=@/path/to/audio.wav" "http://localhost:8000/transcribe"
```

Deployment hints

- Containerize the app in a small Dockerfile and run behind nginx or a reverse proxy. Add authentication (Moodle OAuth or simple token) before production use.
- Optionally wrap it as an LTI or External Tool in Moodle and call the endpoint with instructor credentials.

Next steps I can do for you

- Provide a Dockerfile and systemd unit to deploy on your VM.
- Add a simple HTML upload page that teachers can embed into a Moodle `mod/page` and an example Moodle embedding snippet.
