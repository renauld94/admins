# PHASE 4: FastAPI Backend Agent with Qwen2.5:7b
## Real-Time Geospatial Data Analysis & WebSocket Streaming

---

## 🎯 OBJECTIVE

Build a **FastAPI backend** that integrates with Qwen2.5:7b for real-time data analysis, earthquake monitoring, weather integration, and WebSocket streaming to both 2D and 3D dashboards.

**File**: `/home/simon/Learning-Management-System-Academy/geospatial_data_agent.py`
**Timeline**: 45 minutes
**Model**: Qwen2.5:7b (4.68GB)
**API Model**: Codestral 22B for API scaffolding

---

## ARCHITECTURE OVERVIEW

```
┌─────────────────────────────────────────────────────┐
│          Frontend (index.html, globe-3d.html)       │
│              WebSocket Clients                      │
└────────────────┬────────────────────────────────────┘
                 │
           WebSocket /ws/realtime
           WebSocket /ws/realtime-3d
                 │
┌────────────────▼────────────────────────────────────┐
│          FastAPI Server (Port 8000)                 │
│  ┌──────────────────────────────────────────────┐   │
│  │ /health              GET                     │   │
│  │ /stats               GET (current stats)     │   │
│  │ /earthquakes         GET (USGS data)         │   │
│  │ /weather             GET (RainViewer data)   │   │
│  │ /ws/realtime         WebSocket (2D)          │   │
│  │ /ws/realtime-3d      WebSocket (3D)          │   │
│  │ /analyze             POST (Qwen2.5 analysis) │   │
│  └──────────────────────────────────────────────┘   │
└────┬──────────────┬──────────────────┬──────────────┘
     │              │                  │
  USGS API      RainViewer API    Qwen2.5:7b (localhost:11434)
     │              │                  │
Earthquakes    Weather Radar      Data Analysis
```

---

## STEP 1: Create FastAPI Application Structure

### Prompt for Ctrl+I

Create `/home/simon/Learning-Management-System-Academy/geospatial_data_agent.py`:

```
TASK: Create FastAPI application with Qwen2.5:7b integration

REQUIREMENTS:
1. FastAPI setup:
   - Port: 8000
   - Host: 0.0.0.0
   - CORS enabled for localhost:3000, localhost:5000
   - Background tasks for data fetching
   
2. Ollama connection:
   - Host: localhost:11434
   - Model: qwen2.5:7b
   - Timeout: 30 seconds
   - Fallback: Use Codestral if Qwen unavailable
   
3. Data caching:
   - Use dict-based cache with timestamps
   - TTL: earthquakes (60s), weather (300s), stats (30s)
   - Auto-refresh in background tasks
   
4. Error handling:
   - Try/catch for external API failures
   - Graceful fallback to cached data
   - Log all errors with timestamps
   - Return 503 if all data sources unavailable
   
5. Logging:
   - Use Python logging module
   - Log level: INFO
   - Output: console + rotating file log at ~/.geospatial/logs/agent.log

INITIAL CODE STRUCTURE:
- Import statements (fastapi, asyncio, aiohttp, logging)
- Global config object with API keys, timeouts
- Cache dictionary
- Ollama client helper functions
- FastAPI app initialization
```

**Expected Output**: ~150 lines (boilerplate + setup)

---

## STEP 2: Implement USGS Earthquake Integration

### Prompt for Ctrl+I

Add earthquake data fetching:

```
TASK: Integrate USGS Earthquake Hazards Program API

IMPLEMENTATION:
1. USGS API endpoint:
   - URL: https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson
   - Fetch: All earthquakes from past 24 hours
   - Parse: GeoJSON format
   
2. Data processing:
   - Filter: magnitude >= 3.0 only
   - Extract: latitude, longitude, magnitude, depth, time, location
   - Sort: by magnitude descending
   - Cache: 60 seconds TTL
   
3. Qwen2.5 analysis:
   - Input: earthquake list (magnitude, depth, location)
   - Prompt: "Analyze these earthquakes and provide:
     1. Risk assessment (low/medium/high)
     2. Affected regions summary
     3. Recommended action (if high risk)
     Format as JSON: {risk_level, affected_regions, recommendations}"
   - Model: qwen2.5:7b
   - Temperature: 0.3 (deterministic)
   
4. Response format:
   {
     "earthquakes": [
       {
         "latitude": float,
         "longitude": float,
         "magnitude": float,
         "depth": float,
         "time": "ISO8601",
         "location": string,
         "risk_level": "low|medium|high"
       }
     ],
     "analysis": {
       "summary": string,
       "affected_regions": [string],
       "recommendations": [string]
     },
     "last_updated": "ISO8601"
   }

5. Endpoints:
   - GET /earthquakes - return parsed + analyzed data
   - Background task: fetch every 60 seconds
```

**Expected Output**: ~200 lines (API + parsing + analysis)

---

## STEP 3: Add RainViewer Weather Integration

### Prompt for Ctrl+I

Add weather radar data:

```
TASK: Integrate RainViewer weather API for radar overlay

IMPLEMENTATION:
1. RainViewer setup:
   - API key: Use free tier (no auth required for basic data)
   - Endpoint: https://api.rainviewer.com/rest/v1/weather?lon={lon}&lat={lat}&key=free
   - Coverage: Global precipitation radar
   
2. Data processing:
   - Sample 10 global cities:
     Boston, Toronto, São Paulo, Tokyo, Singapore,
     Geneva, Beijing, Sydney, London, San Francisco
   - Fetch weather for each: temperature, precipitation, wind
   - Create grid-based precipitation map
   
3. Caching:
   - TTL: 300 seconds (5 minutes)
   - Cache by coordinate grid (not individual cities)
   
4. Qwen2.5 analysis:
   - Input: precipitation data + node locations
   - Prompt: "Analyze weather patterns affecting infrastructure:
     - Which nodes are in high precipitation areas?
     - Potential connectivity risks?
     - Recommended actions?
     Format as JSON: {at_risk_nodes: [], severity: 'low|medium|high'}"
   - Temperature: 0.3
   
5. Response format:
   {
     "weather": {
       "global_precipitation": [[float]],  # grid data
       "cities": [
         {
           "city": string,
           "temperature": float,
           "precipitation": float,
           "wind_speed": float
         }
       ]
     },
     "analysis": {
       "at_risk_nodes": [string],
       "severity": "low|medium|high",
       "recommendations": [string]
     },
     "last_updated": "ISO8601"
   }
   
6. Endpoints:
   - GET /weather - return weather + analysis
   - Background task: fetch every 300 seconds
```

**Expected Output**: ~180 lines (API + grid processing)

---

## STEP 4: Create Real-Time Statistics Engine

### Prompt for Ctrl+I

Implement statistics tracking:

```
TASK: Build real-time statistics collection and updates

STATISTICS TO TRACK:
1. Infrastructure stats:
   - Active nodes: count by type
   - Total connections: sum of active links
   - Global throughput: simulated (TB/s)
   - Average latency: simulated (ms)
   - Network uptime: percentage
   
2. Earthquake stats:
   - Total events (24h): count
   - Highest magnitude: float
   - Average depth: float
   - At-risk regions: count
   
3. Weather stats:
   - High precipitation areas: count
   - Affected nodes: count
   - Storm severity: "low|medium|high"
   
4. Data sources:
   - Use USGS + RainViewer data
   - Augment with simulated node metrics
   - Mix of real (earthquakes, weather) + simulated (throughput, latency)
   
5. Updates:
   - Recalculate every 30 seconds
   - Broadcast to connected WebSocket clients
   - Include timestamp
   
6. Response format:
   {
     "infrastructure": {
       "active_nodes": int,
       "nodes_by_type": {
         "Healthcare": int,
         "Research": int,
         "DataCenters": int,
         "Coastal": int
       },
       "connections": int,
       "throughput": "595 TB/s",
       "latency": "25 ms",
       "uptime": "99.9%"
     },
     "earthquakes": {...},
     "weather": {...},
     "timestamp": "ISO8601"
   }
   
7. Endpoints:
   - GET /stats - return current statistics
   - Background task: update every 30 seconds
   - Broadcast: send to all WebSocket clients
```

**Expected Output**: ~150 lines (stats collection + calculation)

---

## STEP 5: Implement WebSocket Handlers

### Prompt for Ctrl+I

Add real-time WebSocket streaming:

```
TASK: Create WebSocket endpoints for real-time dashboard updates

WEBSOCKET ENDPOINTS:

1. /ws/realtime (2D Dashboard):
   - Connect: 0.1s delay after connection
   - Send every 1 second:
     {
       "type": "stats_update",
       "data": {
         "active_nodes": int,
         "connections": int,
         "throughput": string,
         "uptime": string,
         "timestamp": "ISO8601"
       }
     }
   - Send on new earthquake (magnitude >= 5.0):
     {
       "type": "earthquake",
       "data": {
         "latitude": float,
         "longitude": float,
         "magnitude": float,
         "location": string,
         "risk_level": string
       }
     }
   - Send weather updates every 5 min:
     {
       "type": "weather_update",
       "data": {...}
     }
   
2. /ws/realtime-3d (3D Globe):
   - Connect: 0.1s delay
   - Send stats every 1 second
   - Send earthquake alerts with detailed analysis
   - Send connection status changes:
     {
       "type": "connection_update",
       "data": {
         "connection_id": string,
         "source": string,
         "target": string,
         "bandwidth": float,
         "active": bool
       }
     }

3. Connection management:
   - Track all connected clients
   - Graceful disconnect handling
   - Auto-reconnect support (client-side)
   - Broadcast to all clients
   - Timeout: 60 seconds (disconnect inactive)
   
4. Error handling:
   - Try/catch for send failures
   - Remove dead connections
   - Log all errors
   - Inform client of issues

5. Performance:
   - Use asyncio for non-blocking I/O
   - Batch updates where possible
   - Throttle high-frequency updates
   - Monitor memory for large client counts
```

**Expected Output**: ~250 lines (WebSocket handlers)

---

## STEP 6: Add Qwen2.5 Analysis Engine

### Prompt for Ctrl+I

Deepen Qwen2.5 integration:

```
TASK: Create Qwen2.5:7b analysis engine for complex queries

ANALYSIS SYSTEM:
1. System prompt for Qwen2.5:
   "You are an expert geospatial data analyst specializing in infrastructure,
   earthquakes, and weather impacts. Provide concise, actionable insights.
   Format responses as JSON when requested. Temperature: 0.3 (deterministic)."

2. Analysis types:

   A. Earthquake impact analysis:
   - Input: earthquake list + infrastructure locations
   - Task: Calculate impact radius, affected nodes, severity
   - Output: risk assessment, recommended actions
   
   B. Weather impact analysis:
   - Input: precipitation/weather data + node locations
   - Task: Identify at-risk nodes, connectivity impacts
   - Output: affected nodes, severity, mitigation steps
   
   C. Network optimization:
   - Input: current network state + statistics
   - Task: Suggest load balancing, redundancy improvements
   - Output: optimization recommendations
   
   D. Anomaly detection:
   - Input: historical stats vs current
   - Task: Identify unusual patterns
   - Output: anomalies found, cause analysis
   
3. Ollama client helper:
   async def analyze_with_qwen(prompt: str) -> str:
     - Connect to http://localhost:11434
     - Model: qwen2.5:7b
     - Temperature: 0.3
     - Stream: false (full response)
     - Timeout: 30s
     - Fallback: return default response if fails
     
4. Endpoints:
   - POST /analyze (body: {query: str, data_type: str})
   - Returns: {analysis: str, confidence: float}
   
5. Performance:
   - Run analysis in background task
   - Cache results for 5 minutes
   - Return immediately with "processing" status
   - Send result via WebSocket when ready
```

**Expected Output**: ~200 lines (analysis engine + Ollama client)

---

## STEP 7: Background Tasks & Scheduling

### Prompt for Ctrl+I

Implement continuous data refresh:

```
TASK: Create background tasks for continuous data updates

BACKGROUND TASKS:
1. Earthquake fetcher (every 60 seconds):
   - Fetch latest from USGS
   - Parse GeoJSON
   - Analyze with Qwen2.5
   - Update cache
   - Broadcast significant events (mag >= 5.0)
   
2. Weather updater (every 300 seconds):
   - Fetch from RainViewer
   - Process for 10 sample cities
   - Analyze with Qwen2.5
   - Update cache
   - Broadcast to WebSocket clients
   
3. Statistics calculator (every 30 seconds):
   - Recalculate infrastructure stats
   - Aggregate earthquake data
   - Aggregate weather data
   - Combine into single stats object
   - Broadcast to WebSocket clients
   
4. Health checker (every 10 seconds):
   - Check Ollama connectivity
   - Check external API availability
   - Log issues
   - Update status flag
   
5. Scheduler implementation:
   - Use APScheduler or asyncio.create_task
   - Run tasks concurrently (non-blocking)
   - Handle task failures gracefully
   - Log all task executions
   - Prevent duplicate simultaneous runs
   
6. Startup/shutdown:
   - Start all tasks on app startup
   - Stop gracefully on app shutdown
   - Save state before shutdown
```

**Expected Output**: ~180 lines (scheduler + task definitions)

---

## STEP 8: Health & Status Endpoints

### Prompt for Ctrl+I

Add monitoring endpoints:

```
TASK: Create health check and status endpoints

ENDPOINTS:

1. GET /health
   Response:
   {
     "status": "healthy|degraded|unhealthy",
     "uptime_seconds": int,
     "timestamp": "ISO8601",
     "services": {
       "ollama": "✓|✗",
       "usgs_api": "✓|✗",
       "rainviewer_api": "✓|✗"
     }
   }

2. GET /stats
   Response: [see Step 4 format]
   
3. GET /earthquakes
   Response: [see Step 2 format]
   
4. GET /weather
   Response: [see Step 3 format]
   
5. GET /metrics (Prometheus format)
   Metrics:
   - websocket_connections (gauge)
   - earthquakes_processed (counter)
   - weather_updates (counter)
   - qwen_analysis_calls (counter)
   - api_response_time_ms (histogram)
   
6. Error responses:
   - 503 Service Unavailable (if data sources fail)
   - 504 Gateway Timeout (if Ollama timeout)
   - 429 Too Many Requests (rate limiting)
```

**Expected Output**: ~100 lines (endpoints + response formatting)

---

## STEP 9: Systemd Service Setup

### Prompt for Ctrl+I

Create service file for auto-start:

```
TASK: Create systemd service file for geospatial agent

FILE: /etc/systemd/system/geospatial-agent.service

CONTENT:
[Unit]
Description=Simon Data Lab Geospatial Agent
After=network.target ollama.service
Wants=ollama.service

[Service]
Type=simple
User=simon
WorkingDirectory=/home/simon/Learning-Management-System-Academy
ExecStart=/usr/bin/python3 -m uvicorn geospatial_data_agent:app --host 0.0.0.0 --port 8000 --workers 4
Restart=always
RestartSec=10
StandardOutput=append:/var/log/geospatial-agent.log
StandardError=append:/var/log/geospatial-agent.log
Environment="PYTHONUNBUFFERED=1"

[Install]
WantedBy=multi-user.target

POST-INSTALL COMMANDS:
sudo systemctl daemon-reload
sudo systemctl enable geospatial-agent
sudo systemctl start geospatial-agent
sudo systemctl status geospatial-agent
```

**Expected Output**: Service file content

---

## ✅ SUCCESS CRITERIA

Your FastAPI backend should have:

- ✅ Health endpoint responding (GET /health)
- ✅ Real-time earthquake data from USGS (updated every 60s)
- ✅ Weather radar data from RainViewer (updated every 300s)
- ✅ Statistics endpoint (GET /stats)
- ✅ Qwen2.5 analysis for earthquakes (risk assessment)
- ✅ Qwen2.5 analysis for weather impacts (at-risk nodes)
- ✅ WebSocket /ws/realtime broadcasting stats (every 1s)
- ✅ WebSocket /ws/realtime-3d with detailed updates
- ✅ Background tasks running concurrently
- ✅ Error handling + graceful fallbacks
- ✅ Ollama connectivity verified
- ✅ Systemd service auto-starts on reboot
- ✅ Logging to file + console
- ✅ <5MB Python code (optimized)

---

## 🧪 TESTING CHECKLIST

Before moving to Phase 5:

```bash
# 1. Test FastAPI startup
curl http://localhost:8000/health

# 2. Test USGS integration
curl http://localhost:8000/earthquakes | jq

# 3. Test weather integration
curl http://localhost:8000/weather | jq

# 4. Test stats
curl http://localhost:8000/stats | jq

# 5. Test WebSocket (in browser console)
let ws = new WebSocket('ws://localhost:8000/ws/realtime');
ws.onmessage = (msg) => console.log(msg.data);

# 6. Check logs
tail -f ~/.geospatial/logs/agent.log
```

---

## 📊 PHASE 4 TIMELINE

| Task | Time | Status |
|------|------|--------|
| FastAPI boilerplate | 5 min | Ready |
| USGS earthquake API | 8 min | Ready |
| RainViewer weather API | 8 min | Ready |
| Real-time stats | 6 min | Ready |
| WebSocket handlers | 8 min | Ready |
| Qwen2.5 analysis engine | 6 min | Ready |
| Background tasks | 5 min | Ready |
| Health endpoints | 3 min | Ready |
| **TOTAL** | **45 min** | ✅ |

---

## 🔗 NEXT PHASE (Phase 5)

Once Phase 4 complete:

**Phase 5**: Deploy & Validate
- Start systemd service
- Test all endpoints
- Verify WebSocket connections
- Confirm 2D + 3D dashboard updates
- Time: 15 minutes

---

## 💾 SAVE & COMMIT

```bash
cd /home/simon/Learning-Management-System-Academy
git add geospatial_data_agent.py
git add /etc/systemd/system/geospatial-agent.service
git commit -m "Phase 4: FastAPI backend with Qwen2.5:7b integration, WebSocket real-time streaming, USGS earthquakes, RainViewer weather"
```

---

**Status**: 🟢 Ready for Phase 4. Use Ctrl+I with the prompts above!
