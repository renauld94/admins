# ASR Deployment & Docker Compose

This file contains quick deploy instructions and notes for running the ASR FastAPI service in Docker Compose and securing it with an API key.

Steps

1. Copy `.env.example` to `.env` and set a strong secret for `ASR_API_KEY`.

```bash
cp .env.example .env
# Edit .env and set ASR_API_KEY=your-strong-key
```

2. Build and start the service with Docker Compose:

```bash
docker compose up --build -d
```

3. Test the service with the API key (replace <key>):

```bash
curl -H "x-api-key: <key>" -F "file=@/path/to/audio.wav" http://localhost:8000/transcribe
```

Notes

- The `ASR_API_KEY` environment variable enables simple token-based auth. When set, requests must include the header `x-api-key` with the same value. This is intended as a minimal protection layer — for production, integrate with Moodle OAuth, an LTI tool, or a reverse-proxy that enforces auth.
- Whisper models are large; plan for disk and memory. On CPU, transcription can be slow; prefer a GPU VM if you need low latency.
- For high-throughput use, add a queue (Redis/RQ) and worker processes to transcribe asynchronously and store results.

If you want, I can add a Docker Compose setup for nginx + basic auth or an example LTI wrapper. Tell me which and I will add the files.
