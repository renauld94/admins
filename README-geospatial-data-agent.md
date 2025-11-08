# Geospatial Data Agent (Phase 4)

Files:
- `geospatial_data_agent.py` — FastAPI app with USGS polling, WebSocket broadcasting, and placeholder endpoints for weather/Qwen.
- `requirements-phase4.txt` — Python requirements for this agent.

Quick start (virtualenv recommended):

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements-phase4.txt
uvicorn geospatial_data_agent:app --host 0.0.0.0 --port 8000
```

Health check: `GET /health`
WebSocket: `ws://<host>:8000/ws/realtime` — agent will broadcast earthquake events when detected.
