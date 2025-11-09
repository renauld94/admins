# EPIC Geodashboard — Real-Time Geospatial Visualization System

[![CI](https://github.com/renauld94/admins/actions/workflows/ci_playwright.yml/badge.svg?branch=deploy/viz-build-2025-11-08)](https://github.com/renauld94/admins/actions/workflows/ci_playwright.yml)

**A production-ready, hardened geospatial data platform** featuring:
- 🌍 **3D globe visualization** (Three.js) with real-time earthquake mapping
- 🚀 **FastAPI backend** with WebSocket broadcasting
- 📊 **Prometheus metrics** and monitoring
- 🔒 **Rate limiting** and CORS protection
- 🧪 **Headless testing** with Playwright
- 🎨 **ES module bundling** for production

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [Architecture](#architecture)
3. [Frontend Setup](#frontend-setup)
4. [Backend Setup](#backend-setup)
5. [Running Tests](#running-tests)
6. [Production Deployment](#production-deployment)
7. [Monitoring](#monitoring)
8. [Environment Variables](#environment-variables)
9. [Troubleshooting](#troubleshooting)

---

## Quick Start

**Prerequisites:** Python 3.11+, Node.js 16+, npm

```bash
# 1. Clone and enter the repo
git clone https://github.com/renauld94/admins.git
cd admins
git checkout deploy/viz-build-2025-11-08

# 2. Install backend dependencies
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements-phase4.txt

# 3. Start the FastAPI backend
python geospatial_data_agent.py
# Backend running at http://localhost:8000

# 4. (In another terminal) Serve the frontend
cd portfolio-deployment-enhanced/geospatial-viz
python3 -m http.server 9000
# Frontend at http://localhost:9000/globe-3d-threejs.html
```

---

## Architecture

### System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    EPIC Geodashboard                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Frontend (Three.js + ES Modules)                          │
│  ├─ 3D Globe (globe-threejs.js)                           │
│  ├─ WebSocket client                                       │
│  ├─ Real-time event mapping                                │
│  └─ dist/globe-bundle.js (production)                      │
│                                                             │
│  Backend (FastAPI)                                          │
│  ├─ /health — Health check                                │
│  ├─ /earthquakes — USGS data (mag ≥4.0)                   │
│  ├─ /ws/realtime — WebSocket broadcast                    │
│  ├─ /metrics — Prometheus metrics                          │
│  └─ USGS poller (60s interval)                            │
│                                                             │
│  Data Sources                                               │
│  ├─ USGS Earthquake Feed (real-time)                      │
│  └─ Optional: Ollama/Qwen AI analysis                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Tech Stack

- **Frontend:** Three.js r153, OrbitControls, ES modules, esbuild
- **Backend:** FastAPI, httpx, slowapi (rate limiting), prometheus-client
- **Testing:** Playwright (headless), GitHub Actions CI
- **Deployment:** systemd services, nginx reverse proxy

---

## Frontend Setup

### Development Mode

```bash
cd portfolio-deployment-enhanced/geospatial-viz

# Install dependencies (if not done)
npm install

# Serve locally (no build needed in dev)
python3 -m http.server 9000

# Open: http://localhost:9000/globe-3d-threejs.html
```

### Production Build

```bash
cd portfolio-deployment-enhanced/geospatial-viz

# Build the bundle
npm run build
# Output: dist/globe-bundle.js (minified + sourcemap)

# Test the build
npm start  # Serves on port 9000
```

### Bundle Contents

- `dist/globe-bundle.js` — minified Three.js + globe code (~9.4 KB)
- `dist/globe-bundle.js.map` — source map (~28 KB)
- `earth_day.jpg` — texture (local; not committed to repo)

---

## Backend Setup

### Installation

```bash
# Create virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements-phase4.txt
```

**Dependencies:**
- `fastapi[all]==0.95.2`
- `uvicorn[standard]==0.22.0`
- `httpx==0.24.1`
- `slowapi==0.1.9` (rate limiting)
- `prometheus-client==0.20.0` (metrics)

### Running the Backend

```bash
# Development mode
python geospatial_data_agent.py

# Production mode (via uvicorn)
uvicorn geospatial_data_agent:app --host 0.0.0.0 --port 8000 --log-level info

# With systemd (production)
sudo systemctl start geospatial-data-agent
sudo systemctl status geospatial-data-agent
```

### API Endpoints

| Endpoint | Method | Rate Limit | Description |
|----------|--------|------------|-------------|
| `/health` | GET | 60/min | Health check |
| `/earthquakes` | GET | 30/min | Recent earthquakes (mag ≥4.0) |
| `/weather` | GET | 30/min | Placeholder (RainViewer coming) |
| `/analysis` | POST | 20/min | AI analysis of events |
| `/ws/realtime` | WebSocket | - | Real-time event broadcast |
| `/metrics` | GET | - | Prometheus metrics |

### WebSocket Protocol

**Client → Server:** Ping messages (keep-alive)
```json
"ping"
```

**Server → Client:** Event broadcasts
```json
{
  "type": "earthquakes",
  "count": 3,
  "events": [
    {
      "id": "us7000example",
      "mag": 4.5,
      "place": "10 km NE of Example City",
      "time": 1699564800000,
      "coords": {"lon": -118.5, "lat": 34.2, "depth": 10}
    }
  ],
  "analysis": {
    "avg_mag": 4.3,
    "max_mag": 4.5,
    "count": 3,
    "text_summary": "AI-generated insight..."
  }
}
```

---

## Running Tests

### Headless Smoke Test (Local)

```bash
cd portfolio-deployment-enhanced/geospatial-viz

# Ensure frontend is served on port 9000
python3 -m http.server 9000 &

# Run headless test
python3 ci/headless_capture.py

# Verify output: no page errors, HTTP 200 responses
```

### CI (GitHub Actions)

CI runs automatically on push/PR to `main`:
1. Checks out code
2. Installs dependencies
3. Builds the bundle (`npm run build`)
4. Runs Playwright headless smoke test
5. Fails if console errors or 4xx/5xx responses detected

**Workflow:** `.github/workflows/ci_playwright.yml`

### Manual Test Commands

```bash
# Frontend syntax check
cd portfolio-deployment-enhanced/geospatial-viz
npm run build  # Should complete without errors

# Backend syntax check
python -m py_compile geospatial_data_agent.py

# Backend unit tests (coming soon)
pytest tests/
```

---

## Production Deployment

### Systemd Service (Backend)

**File:** `systemd/geospatial-data-agent.service`

```ini
[Unit]
Description=Geospatial Data Agent (FastAPI)
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/opt/geodashboard
Environment="PATH=/opt/geodashboard/.venv/bin"
ExecStart=/opt/geodashboard/.venv/bin/uvicorn geospatial_data_agent:app --host 0.0.0.0 --port 8000
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

**Installation:**
```bash
sudo cp systemd/geospatial-data-agent.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable geospatial-data-agent
sudo systemctl start geospatial-data-agent
```

### Nginx Reverse Proxy

**Config:** `/etc/nginx/sites-available/geodashboard`

```nginx
server {
    listen 80;
    server_name geodashboard.example.com;

    # Redirect HTTP → HTTPS
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name geodashboard.example.com;

    ssl_certificate /etc/letsencrypt/live/geodashboard.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/geodashboard.example.com/privkey.pem;

    # Frontend static files
    location / {
        root /opt/geodashboard/portfolio-deployment-enhanced/geospatial-viz;
        try_files $uri $uri/ =404;
    }

    # Backend API
    location /api/ {
        proxy_pass http://localhost:8000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # WebSocket
    location /ws/ {
        proxy_pass http://localhost:8000/ws/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

**Enable:**
```bash
sudo ln -s /etc/nginx/sites-available/geodashboard /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

## Monitoring

### Prometheus Metrics

The backend exposes metrics at `/metrics` in Prometheus format:

**Key Metrics:**
- `http_requests_total` — Request counter (method, endpoint, status)
- `http_request_duration_seconds` — Request latency histogram
- `ws_connections_active` — Active WebSocket connections
- `usgs_poll_success_total` — Successful USGS polls
- `usgs_poll_errors_total` — Failed USGS polls
- `model_calls_total` — AI model calls (success/error)
- `model_call_duration_seconds` — Model call latency

### Prometheus Configuration

**prometheus.yml snippet:**
```yaml
scrape_configs:
  - job_name: 'geodashboard'
    static_configs:
      - targets: ['localhost:8000']
    metrics_path: '/metrics'
    scrape_interval: 15s
```

### Grafana Dashboard

Import dashboards for:
- HTTP request rates and error rates
- WebSocket connection count
- USGS poller health
- P50/P95/P99 latencies

### Alerting Rules

**Example alert (Prometheus):**
```yaml
groups:
  - name: geodashboard
    rules:
      - alert: USGSPollerDown
        expr: rate(usgs_poll_errors_total[5m]) > 0.1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "USGS poller failing"
          description: "{{ $value }} errors/sec over 5 minutes"
```

---

## Environment Variables

### Backend Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `EARTHQUAKE_MIN_MAG` | `4.0` | Minimum earthquake magnitude to include |
| `USGS_POLL_INTERVAL` | `60` | USGS poll interval (seconds) |
| `OLLAMA_URL` | - | Optional AI model endpoint (e.g., `http://127.0.0.1:11434`) |
| `OLLAMA_MODEL` | `qwen2.5:7b` | AI model name |
| `ANALYSIS_ENABLED` | `false` | Enable AI analysis (`true`/`false`) |
| `MODEL_RETRIES` | `2` | Model call retry attempts |
| `MODEL_TIMEOUT` | `15.0` | Model call timeout (seconds) |
| `CORS_ORIGINS` | `*` | Allowed CORS origins (comma-separated) |

**Example:**
```bash
export EARTHQUAKE_MIN_MAG=5.0
export CORS_ORIGINS="https://geodashboard.example.com,https://app.example.com"
export ANALYSIS_ENABLED=true
export OLLAMA_URL="http://127.0.0.1:11434"
python geospatial_data_agent.py
```

---

## Troubleshooting

### Frontend Issues

**Problem:** "THREE.ShaderPass is not a constructor"
- **Cause:** Legacy postprocessing scripts not mapped to `THREE` namespace
- **Fix:** Ensure `three-loader.js` is loaded (maps globals to `THREE`)

**Problem:** Module resolution errors
- **Cause:** Import maps not loaded or incorrect CDN URLs
- **Fix:** Check `globe-3d-threejs.html` has import map for `"three"`

**Problem:** Texture 404
- **Cause:** `earth_day.jpg` not in local `dist/` folder
- **Fix:** Download texture or use solid color fallback

### Backend Issues

**Problem:** Rate limit errors (429)
- **Cause:** Too many requests from same IP
- **Fix:** Adjust `slowapi` limits or implement Redis-backed rate limiter

**Problem:** WebSocket disconnects
- **Cause:** Client not sending keep-alive pings
- **Fix:** Implement periodic ping from client (every 30s)

**Problem:** USGS poller errors
- **Cause:** Network issues or USGS API rate limiting
- **Fix:** Check logs; increase `USGS_POLL_INTERVAL`

**Problem:** Model call timeouts
- **Cause:** Ollama/model endpoint slow or unavailable
- **Fix:** Increase `MODEL_TIMEOUT` or disable analysis (`ANALYSIS_ENABLED=false`)

### Performance Issues

**Problem:** High memory usage
- **Cause:** Large WebSocket connection pool or texture memory
- **Fix:** Limit WS connections, optimize textures (compress/resize)

**Problem:** Slow globe rendering
- **Cause:** Too many instanced meshes or shader complexity
- **Fix:** Reduce instance count, simplify shaders, use LOD

---

## Development Roadmap

### Completed ✅
- [x] 3D globe with instanced mesh rendering
- [x] WebSocket real-time broadcasting
- [x] FastAPI backend with USGS integration
- [x] Rate limiting and CORS protection
- [x] Prometheus metrics endpoint
- [x] ES module bundling with esbuild
- [x] Headless CI testing with Playwright
- [x] Three.js postprocessing compatibility fixes

### In Progress 🚧
- [ ] Production nginx deployment
- [ ] Prometheus server + Grafana dashboards
- [ ] Alerting rules setup

### Planned 📋
- [ ] RainViewer weather overlay integration
- [ ] Unit tests for backend endpoints
- [ ] React/TS build pipeline for neural-visualization
- [ ] Docker containerization
- [ ] Kubernetes deployment manifests
- [ ] CDN hosting for static assets

---

## Contributing

1. Fork the repo
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make changes and test locally
4. Run headless tests (`python ci/headless_capture.py`)
5. Commit with conventional commits (`feat:`, `fix:`, `docs:`)
6. Push and open a PR

**Code Style:**
- Python: PEP 8, type hints preferred
- JavaScript: ES6+, 2-space indentation
- Commits: Conventional Commits format

---

## License

This project is part of a private consulting engagement. All rights reserved.

---

## Support

For issues or questions:
- Open a GitHub Issue
- Contact: simonrenauld.data@gmail.com

**Last Updated:** November 9, 2025
**Version:** 1.0.0 (deploy/viz-build-2025-11-08)
