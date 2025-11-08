#!/usr/bin/env python3
"""
Geospatial Data Agent
- FastAPI application providing:
  - /health (health check)
  - /earthquakes (fetch USGS recent feed, filter magn >=4)
  - /weather (placeholder for RainViewer integration)
  - WebSocket /ws/realtime broadcasting earthquake events and simulated node pulses

This is intentionally conservative: if external services (Ollama/Qwen) are not available,
the agent returns sensible placeholders.
"""
import asyncio
import os
import json
import logging
from typing import List, Dict, Any, Optional

import httpx
from fastapi import FastAPI, WebSocket, WebSocketDisconnect, Request
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Geospatial Data Agent")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

USGS_URL = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson"
EARTHQUAKE_MIN_MAG = float(os.getenv("EARTHQUAKE_MIN_MAG", "4.0"))
OLLAMA_URL = os.getenv("OLLAMA_URL")  # optional, e.g. http://127.0.0.1:11434
OLLAMA_MODEL = os.getenv("OLLAMA_MODEL", "qwen2.5:7b")
ANALYSIS_ENABLED = os.getenv("ANALYSIS_ENABLED", "false").lower() in ("1","true","yes")
MODEL_RETRIES = int(os.getenv("MODEL_RETRIES", "2"))
MODEL_TIMEOUT = float(os.getenv("MODEL_TIMEOUT", "15.0"))

# logger for model/agent events
logger = logging.getLogger("geospatial_data_agent")
if not logger.handlers:
    # allow uvicorn/fastapi to configure handlers; ensure our logger is set
    logging.basicConfig()
logger.setLevel(logging.INFO)

class ConnectionManager:
    def __init__(self):
        self.active: List[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active.append(websocket)

    def disconnect(self, websocket: WebSocket):
        if websocket in self.active:
            self.active.remove(websocket)

    async def broadcast(self, message: Dict[str, Any]):
        data = json.dumps(message)
        for ws in list(self.active):
            try:
                await ws.send_text(data)
            except Exception:
                try:
                    await ws.close()
                except Exception:
                    pass
                self.disconnect(ws)

manager = ConnectionManager()


@app.get("/health")
async def health():
    return {"status": "ok"}


@app.get("/earthquakes")
async def earthquakes():
    """Fetch USGS feed and return magnitude >= EARTHQUAKE_MIN_MAG
    Returns a compact list of events with mag, place, time, coords
    """
    async with httpx.AsyncClient(timeout=20.0) as client:
        try:
            r = await client.get(USGS_URL)
            r.raise_for_status()
            payload = r.json()
            features = payload.get("features", [])
            results = []
            for f in features:
                props = f.get("properties", {})
                geom = f.get("geometry", {})
                mag = props.get("mag") or 0
                if mag and mag >= EARTHQUAKE_MIN_MAG:
                    coords = geom.get("coordinates", [None, None, None])
                    results.append({
                        "id": f.get("id"),
                        "mag": mag,
                        "place": props.get("place"),
                        "time": props.get("time"),
                        "coords": {"lon": coords[0], "lat": coords[1], "depth": coords[2]},
                    })
            return {"count": len(results), "events": results}
        except Exception as e:
            return JSONResponse(status_code=502, content={"error": "failed to fetch USGS", "details": str(e)})


@app.get("/weather")
async def weather():
    # Placeholder endpoint for RainViewer integration
    return {"status": "placeholder", "note": "RainViewer integration coming in Phase 4"}


@app.websocket("/ws/realtime")
async def ws_realtime(websocket: WebSocket):
    await manager.connect(websocket)
    try:
        while True:
            # keep connection alive; expect pings from clients
            await websocket.receive_text()
    except WebSocketDisconnect:
        manager.disconnect(websocket)


async def usgs_poller(interval: int = 60):
    """Background task: poll USGS every `interval` seconds and broadcast new events."""
    seen = set()
    async with httpx.AsyncClient(timeout=20.0) as client:
        while True:
            try:
                r = await client.get(USGS_URL)
                r.raise_for_status()
                payload = r.json()
                features = payload.get("features", [])
                new_events = []
                for f in features:
                    fid = f.get("id")
                    if fid in seen:
                        continue
                    props = f.get("properties", {})
                    mag = props.get("mag") or 0
                    if mag and mag >= EARTHQUAKE_MIN_MAG:
                        geom = f.get("geometry", {})
                        coords = geom.get("coordinates", [None, None, None])
                        ev = {"id": fid, "mag": mag, "place": props.get("place"), "time": props.get("time"),
                              "coords": {"lon": coords[0], "lat": coords[1], "depth": coords[2]}}
                        new_events.append(ev)
                        seen.add(fid)
                if new_events:
                    # Optionally run analysis (aggregate summary) — non-blocking best-effort
                    analysis = None
                    if ANALYSIS_ENABLED:
                        try:
                            analysis = await analyze_events_summary(new_events)
                        except Exception:
                            analysis = None

                    # Broadcast summary to WS clients
                    payload = {"type": "earthquakes", "count": len(new_events), "events": new_events}
                    if analysis:
                        payload["analysis"] = analysis
                    await manager.broadcast(payload)
            except Exception:
                # ignore errors; try again next interval
                pass
            await asyncio.sleep(interval)


@app.on_event("startup")
async def startup_event():
    # Start USGS poller in background
    interval = int(os.getenv("USGS_POLL_INTERVAL", "60"))
    asyncio.create_task(usgs_poller(interval=interval))


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("geospatial_data_agent:app", host="0.0.0.0", port=8000, log_level="info")


async def analyze_events_summary(events: List[Dict[str, Any]], model_url: Optional[str] = None, model_name: Optional[str] = None) -> Dict[str, Any]:
    """Produce a small analysis summary of a list of events.
    If OLLAMA_URL is configured and reachable, attempt to call it for richer analysis.
    Otherwise, return a quick aggregate summary.
    """
    # Basic aggregate
    mags = [e.get("mag", 0) for e in events]
    avg_mag = sum(mags) / len(mags) if mags else 0
    max_mag = max(mags) if mags else 0
    summary = {"avg_mag": avg_mag, "max_mag": max_mag, "count": len(events)}

    # If configured, try to call Ollama or other model endpoint for textual summary
    # Determine effective model endpoint/name: prefer provided args, fall back to env
    effective_url = model_url or OLLAMA_URL
    effective_model = model_name or OLLAMA_MODEL

    if effective_url:
        try:
            # Ollama-style API: POST {"model": <name>, "prompt": <str>, "max_tokens": <int>} to /api/generate
            prompt = (
                f"You are a geospatial analyst. Summarize {len(events)} earthquake events. "
                f"Average magnitude {avg_mag:.2f}, maximum {max_mag:.2f}. Provide 3 short insights (1-2 sentences each) and a suggested action." 
            )
            payload = {"model": effective_model, "prompt": prompt, "max_tokens": 150}
            # Try the remote model with retries and backoff to handle transient errors.
            attempt = 0
            text = None
            async with httpx.AsyncClient(timeout=MODEL_TIMEOUT) as client:
                while attempt <= MODEL_RETRIES and not text:
                    attempt += 1
                    try:
                        logger.info(f"Model call attempt {attempt}/{MODEL_RETRIES} to %s", effective_url)
                        r = await client.post(f"{effective_url}/api/generate", json=payload)
                        if r.status_code != 200:
                            logger.warning("Model server returned status %s on attempt %s: %s", r.status_code, attempt, r.text[:200])
                        else:
                            # parse response
                            try:
                                j = r.json()
                            except Exception:
                                j = None
                            # Robust extraction helper: walk common response shapes and return textual content.
                            def extract_text(obj):
                                if obj is None:
                                    return None
                                if isinstance(obj, str):
                                    s = obj.strip()
                                    return s if s else None
                                if isinstance(obj, dict):
                                    for key in ("text", "output", "result", "content", "summary", "answer"):
                                        if key in obj:
                                            t = extract_text(obj[key])
                                            if t:
                                                return t
                                    if "choices" in obj and isinstance(obj["choices"], list):
                                        parts = []
                                        for choice in obj["choices"]:
                                            t = extract_text(choice)
                                            if t:
                                                parts.append(t)
                                        if parts:
                                            return "\n".join(parts)
                                    if "message" in obj:
                                        return extract_text(obj["message"])
                                    if "data" in obj:
                                        return extract_text(obj["data"])
                                    for v in obj.values():
                                        t = extract_text(v)
                                        if t:
                                            return t
                                    return None
                                if isinstance(obj, list):
                                    parts = []
                                    for item in obj:
                                        t = extract_text(item)
                                        if t:
                                            parts.append(t)
                                    if parts:
                                        return "\n".join(parts)
                                    return None
                                return None

                            text = extract_text(j) or (str(j) if j is not None else None)
                            if text:
                                summary["text_summary"] = text
                                logger.info("Model call succeeded on attempt %s", attempt)
                                break
                    except Exception as e:
                        logger.warning("Model call attempt %s failed: %s", attempt, str(e))
                    # backoff before retrying
                    if not text and attempt <= MODEL_RETRIES:
                        backoff = min(2 ** attempt, 10)
                        logger.info("Backing off %s seconds before retry", backoff)
                        await asyncio.sleep(backoff)
        except Exception:
            # Ignore model errors; return basic summary
            pass

    return summary


@app.post("/analysis")
async def analysis_endpoint(request: Request):
    """Accept a JSON payload with 'events' list and return analysis summary.
    This endpoint reads and parses the request body manually to be tolerant of
    slightly malformed clients that send non-standard JSON shapes. It will
    attempt a normal json decode first and fall back to a naive coercion,
    similar to `/analysis_raw`.
    Example: { "events": [ {"mag":4.5, "coords": {"lat":.., "lon":..} }, ... ] }
    """
    try:
        # Try the normal JSON path first
        payload = await request.json()
    except Exception:
        # Fallback: read raw body and attempt to coerce/repair common non-JSON shapes
        raw = await request.body()
        if not raw:
            return JSONResponse(status_code=400, content={"error": "empty body"})
        s = raw.decode("utf-8", errors="ignore")
        import re
        s2 = re.sub(r'([,{\s])(\w+)\s*:', r'"\2":', s)
        try:
            payload = json.loads(s2)
        except Exception as e:
            return JSONResponse(status_code=400, content={"error": "invalid json", "details": str(e)})

    events = payload.get("events") if isinstance(payload, dict) else None
    if not events or not isinstance(events, list):
        return JSONResponse(status_code=400, content={"error": "invalid payload, expected 'events' list"})
    summary = await analyze_events_summary(events)
    return summary


@app.post("/analysis_raw")
async def analysis_raw(request):
    """Fallback endpoint: read raw body and attempt to parse JSON manually.
    Useful when clients send slightly malformed content-type or inconsistent payloads.
    """
    try:
        raw = await request.body()
        if not raw:
            return JSONResponse(status_code=400, content={"error": "empty body"})
        try:
            payload = json.loads(raw)
        except Exception as e:
            # Try to coerce some common non-JSON shapes (best-effort)
            s = raw.decode('utf-8', errors='ignore')
            # If keys are unquoted like {events:[{mag:...}]}, attempt to quote keys (very naive)
            import re
            s2 = re.sub(r'([,{\s])(\w+)\s*:', r'"\2":', s)
            try:
                payload = json.loads(s2)
            except Exception:
                return JSONResponse(status_code=400, content={"error": "invalid json", "details": str(e)})

        events = payload.get('events') if isinstance(payload, dict) else None
        if not events or not isinstance(events, list):
            return JSONResponse(status_code=400, content={"error": "invalid payload, expected 'events' list"})
        summary = await analyze_events_summary(events)
        return summary
    except Exception as e:
        return JSONResponse(status_code=500, content={"error": "internal", "details": str(e)})


@app.post("/analysis_model_test")
async def analysis_model_test(request: Request):
    """Test endpoint: accept events plus optional model_url and model_name in the payload
    and run `analyze_events_summary` using those values. Useful for testing remote
    model endpoints without changing environment variables.
    Payload example:
    { "events": [...], "model_url": "http://127.0.0.1:11434", "model_name": "qwen2.5:7b" }
    """
    try:
        try:
            payload = await request.json()
        except Exception:
            raw = await request.body()
            if not raw:
                return JSONResponse(status_code=400, content={"error": "empty body"})
            try:
                payload = json.loads(raw)
            except Exception as e:
                return JSONResponse(status_code=400, content={"error": "invalid json", "details": str(e)})

        events = payload.get("events") if isinstance(payload, dict) else None
        if not events or not isinstance(events, list):
            return JSONResponse(status_code=400, content={"error": "invalid payload, expected 'events' list"})

        model_url = payload.get("model_url")
        model_name = payload.get("model_name")

        summary = await analyze_events_summary(events, model_url=model_url, model_name=model_name)
        return summary
    except Exception as e:
        return JSONResponse(status_code=500, content={"error": "internal", "details": str(e)})
