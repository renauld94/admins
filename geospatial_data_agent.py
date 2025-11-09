#!/usr/bin/env python3
"""
Geospatial Data Agent
- FastAPI application providing:
  - /health (health check)
  - /earthquakes (fetch USGS recent feed, filter magn >=4)
  - /weather (placeholder for RainViewer integration)
  - WebSocket /ws/realtime broadcasting earthquake events and simulated node pulses
  - /metrics (Prometheus metrics endpoint)

This is intentionally conservative: if external services (Ollama/Qwen) are not available,
the agent returns sensible placeholders.

Hardening features:
- CORS with configurable origins
- Rate limiting via slowapi
- Request timeouts
- Prometheus metrics for requests, errors, WS connections
"""
import asyncio
import os
import json
import logging
from typing import List, Dict, Any, Optional

import httpx
from fastapi import FastAPI, WebSocket, WebSocketDisconnect, Request
from fastapi.responses import JSONResponse, PlainTextResponse
from fastapi.middleware.cors import CORSMiddleware
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
from prometheus_client import Counter, Histogram, Gauge, generate_latest, CONTENT_TYPE_LATEST

# Rate limiter
limiter = Limiter(key_func=get_remote_address, default_limits=["100/minute"])

app = FastAPI(title="Geospatial Data Agent")
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# Prometheus metrics
# Try to create metrics, but handle case where they're already registered
try:
    http_requests_total = Counter('http_requests_total', 'Total HTTP requests', ['method', 'endpoint', 'status'])
except ValueError:
    # Already registered in this process
    from prometheus_client import REGISTRY
    http_requests_total = REGISTRY._names_to_collectors['http_requests_total']

try:
    http_request_duration_seconds = Histogram('http_request_duration_seconds', 'HTTP request duration', ['method', 'endpoint'])
except ValueError:
    from prometheus_client import REGISTRY
    http_request_duration_seconds = REGISTRY._names_to_collectors['http_request_duration_seconds']

try:
    ws_connections_active = Gauge('ws_connections_active', 'Active WebSocket connections')
except ValueError:
    from prometheus_client import REGISTRY
    ws_connections_active = REGISTRY._names_to_collectors['ws_connections_active']

try:
    usgs_poll_success = Counter('usgs_poll_success_total', 'Successful USGS polls')
except ValueError:
    from prometheus_client import REGISTRY
    usgs_poll_success = REGISTRY._names_to_collectors['usgs_poll_success_total']

try:
    usgs_poll_errors = Counter('usgs_poll_errors_total', 'Failed USGS polls')
except ValueError:
    from prometheus_client import REGISTRY
    usgs_poll_errors = REGISTRY._names_to_collectors['usgs_poll_errors_total']

try:
    model_calls_total = Counter('model_calls_total', 'Total model API calls', ['status'])
except ValueError:
    from prometheus_client import REGISTRY
    model_calls_total = REGISTRY._names_to_collectors['model_calls_total']

try:
    model_call_duration_seconds = Histogram('model_call_duration_seconds', 'Model call duration')
except ValueError:
    from prometheus_client import REGISTRY
    model_call_duration_seconds = REGISTRY._names_to_collectors['model_call_duration_seconds']

# CORS configuration - allow configurable origins for security
allowed_origins = os.getenv("CORS_ORIGINS", "*").split(",")
app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins if allowed_origins != ["*"] else ["*"],
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
        ws_connections_active.set(len(self.active))

    def disconnect(self, websocket: WebSocket):
        if websocket in self.active:
            self.active.remove(websocket)
        ws_connections_active.set(len(self.active))

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
@limiter.limit("60/minute")
async def health(request: Request):
    http_requests_total.labels(method="GET", endpoint="/health", status=200).inc()
    return {"status": "ok"}


@app.get("/metrics")
async def metrics():
    """Prometheus metrics endpoint"""
    return PlainTextResponse(generate_latest(), media_type=CONTENT_TYPE_LATEST)


@app.get("/earthquakes")
@limiter.limit("30/minute")
async def earthquakes(request: Request):
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
            http_requests_total.labels(method="GET", endpoint="/earthquakes", status=200).inc()
            return {"count": len(results), "events": results}
        except Exception as e:
            http_requests_total.labels(method="GET", endpoint="/earthquakes", status=502).inc()
            return JSONResponse(status_code=502, content={"error": "failed to fetch USGS", "details": str(e)})


@app.get("/weather")
@limiter.limit("30/minute")
async def weather(request: Request):
    # Placeholder endpoint for RainViewer integration
    http_requests_total.labels(method="GET", endpoint="/weather", status=200).inc()
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
                usgs_poll_success.inc()
            except Exception as e:
                # Log and count errors
                logger.warning(f"USGS poller error: {e}")
                usgs_poll_errors.inc()
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
                        import time
                        start = time.time()
                        r = await client.post(f"{effective_url}/api/generate", json=payload)
                        duration = time.time() - start
                        model_call_duration_seconds.observe(duration)
                        
                        if r.status_code != 200:
                            model_calls_total.labels(status="error").inc()
                            logger.warning("Model server returned status %s on attempt %s: %s", r.status_code, attempt, r.text[:200])
                        else:
                            model_calls_total.labels(status="success").inc()
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
@limiter.limit("20/minute")
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
            http_requests_total.labels(method="POST", endpoint="/analysis", status=400).inc()
            return JSONResponse(status_code=400, content={"error": "empty body"})
        s = raw.decode("utf-8", errors="ignore")
        import re
        s2 = re.sub(r'([,{\s])(\w+)\s*:', r'"\2":', s)
        try:
            payload = json.loads(s2)
        except Exception as e:
            http_requests_total.labels(method="POST", endpoint="/analysis", status=400).inc()
            return JSONResponse(status_code=400, content={"error": "invalid json", "details": str(e)})

    events = payload.get("events") if isinstance(payload, dict) else None
    if not events or not isinstance(events, list):
        http_requests_total.labels(method="POST", endpoint="/analysis", status=400).inc()
        return JSONResponse(status_code=400, content={"error": "invalid payload, expected 'events' list"})
    summary = await analyze_events_summary(events)
    http_requests_total.labels(method="POST", endpoint="/analysis", status=200).inc()
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
