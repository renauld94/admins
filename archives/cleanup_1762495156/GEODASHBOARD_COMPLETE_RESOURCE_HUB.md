# EPIC GEODASHBOARD - Complete Resource Hub

**Status**: 🚀 READY TO BUILD  
**Date**: November 7, 2025  
**Primary Tool**: Continue IDE + Codestral 22B

---

## QUICK DECISION MATRIX

| Aspect | PATH A (Recommended) | PATH B (Quick) |
|--------|-------------------|-----------------|
| Install Time | 5 min (Qwen) | 0 min |
| Build Time | 2h 5m | 2h |
| Models | Codestral + Qwen + Llama | Codestral + Llama |
| 2D Dashboard | ✅ Full | ✅ Full |
| 3D Globe | ✅ Full | ✅ Full |
| Backend Agent | ✅ Full with AI | ✅ Minimal |
| Quality | ⭐⭐⭐ Enterprise | ⭐⭐ Professional |
| WebSocket | ✅ Yes | ❌ No |
| AI Analysis | ✅ Yes (Qwen) | ❌ No |
| Recommendation | **CHOOSE THIS** | Good for speed |

---

## WHAT YOU'RE BUILDING

### 2D Dashboard (Leaflet Map)
```
Dashboard Features:
├── Left Sidebar (Statistics)
│   ├── Active Facilities (live counter)
│   ├── Countries Covered (auto-calculated)
│   ├── Live Connections (WebSocket counter)
│   └── Data Points Streaming (real-time)
│
├── Center Map (Leaflet)
│   ├── Base map (OpenStreetMap)
│   ├── Earthquake markers (color-coded by magnitude)
│   ├── Weather radar overlay (RainViewer)
│   ├── Infrastructure nodes (cyan dots)
│   ├── Satellite imagery (toggle)
│   └── Zoom/Pan controls
│
└── Right Sidebar (Controls)
    ├── Layer toggles (Weather, Earthquakes, Satellites)
    ├── Time slider (historical data)
    ├── Legend panel
    └── Settings
```

**Build Time**: 30 minutes with Continue  
**Model Used**: Codestral 22B (code generation)  
**Key Tools**: Leaflet.js, D3.js

### 3D Globe (Three.js)
```
Globe Features:
├── Rendering
│   ├── Realistic Earth texture (NASA Blue Marble)
│   ├── Dynamic lighting and shadows
│   ├── 1000+ infrastructure nodes (LOD)
│   ├── Animated data flow lines
│   └── Pulsing earthquake markers
│
├── Interactions
│   ├── Orbital camera (mouse drag)
│   ├── Zoom (scroll wheel)
│   ├── Node clustering (smart LOD)
│   └── Real-time data updates
│
└── Performance
    ├── 60fps target
    ├── Particle pooling
    ├── WebGL optimization
    └── Memory efficient
```

**Build Time**: 30 minutes with Continue  
**Model Used**: Codestral 22B (code generation)  
**Key Tools**: Three.js, WebGL

### Backend Agent (FastAPI)
```
Service Features:
├── Data Collection
│   ├── USGS Earthquake Feed (every 5 min)
│   ├── RainViewer Radar (every 10 min)
│   ├── Infrastructure Status (every 30 sec)
│   └── NASA Satellites (daily)
│
├── AI Analysis (Optional - uses Qwen2.5:7b if installed)
│   ├── Earthquake impact radius
│   ├── Weather pattern analysis
│   ├── Anomaly detection
│   └── Natural language summaries
│
├── API Endpoints
│   ├── GET /api/health
│   ├── GET /api/earthquakes
│   ├── GET /api/weather
│   ├── GET /api/infrastructure
│   ├── GET /api/satellites
│   ├── POST /api/analyze
│   └── WS /ws/realtime (WebSocket)
│
└── Infrastructure
    ├── Caching (5-30 min TTL)
    ├── Error recovery (retries)
    ├── Rate limiting
    ├── Logging
    └── Health checks
```

**Build Time**: 45 minutes with Continue  
**Models Used**: Codestral 22B (code), Qwen2.5:7b (data analysis)  
**Key Tools**: FastAPI, Ollama, WebSocket

---

## MODEL SPECIFICATIONS & SELECTION

### Codestral 22B (For Code Generation)

**Specifications**:
- **Size**: 12.6 GB (q4_0 quantization)
- **Context**: 32,768 tokens (huge!)
- **Speed**: 500-1000ms first token
- **Purpose**: Code generation, refactoring, autocomplete
- **Status**: ✅ INSTALLED

**Why Codestral for Frontend**:
- Specialized in code generation across 80+ languages
- Better at precise code than general models
- Lower hallucination rate with temp 0.1
- Excellent autocomplete accuracy
- Perfect for complex algorithms (map rendering, animations)

**Temperature Tuning**:
```json
{
  "code_generation": 0.1,    // Ultra-deterministic
  "autocomplete": 0.15,       // Predictable suggestions
  "refactoring": 0.2,         // Precise transformations
  "documentation": 0.3        // Structured comments
}
```

**Sample Prompt** (copy-paste ready):
```
// ai: Create a Leaflet layer function that displays earthquake markers
// - Input: array of GeoJSON earthquake features
// - Output: Leaflet layer with markers
// - Colors: magnitude 2-4 yellow, 4-5 orange, 5-6 red, 6+ dark red
// - Size increases with magnitude
// - Click shows popup with details
// - Production-ready, fully functional
```

---

### Qwen2.5:7b (For Backend Data Analysis)

**Specifications**:
- **Size**: 5.5 GB (unquantized)
- **Context**: 32,768 tokens (LARGEST available!)
- **Speed**: 300-600ms first token
- **Purpose**: Data analysis, summarization, insights
- **Status**: ❌ NOT INSTALLED (optional but recommended)

**Why Qwen for Backend**:
- Better at structured data & numerical analysis
- Larger context window than Codestral
- Excellent for multi-turn reasoning
- Better at summarization
- Perfect for data processing pipelines

**Temperature Tuning**:
```json
{
  "data_analysis": 0.3,       // Structured with reasoning
  "summarization": 0.4,       // Natural but consistent
  "anomaly_detection": 0.2    // Deterministic patterns
}
```

**Sample Prompt**:
```python
# ai: Analyze earthquake data and generate human-readable summary:
# Input: array of earthquake GeoJSON features with magnitude, depth, location
# Output: natural language summary including:
#   - Total count
#   - Strongest earthquake (magnitude, location)
#   - Geographic patterns
#   - Risk assessment
# Use concise professional tone, no emojis
```

**Installation**:
```bash
ollama pull qwen2.5:7b
# Takes 5-10 minutes, downloads 5.5 GB
```

---

### Llama 3.2 3B (Fallback)

**Status**: ✅ INSTALLED (2.0 GB)  
**Purpose**: Fallback if Codestral/Qwen unavailable  
**When Used**: Only as backup  

---

## AGENT ARCHITECTURE

### Required: GeospatialDataService Agent

**File**: `~/.continue/agents/agents_continue/geospatial_data_agent.py`

**Responsibilities**:
1. Fetch real-time earthquake data from USGS
2. Fetch weather radar frames from RainViewer
3. Aggregate infrastructure status
4. Perform AI analysis (if Qwen installed)
5. Stream updates via WebSocket
6. Cache responses intelligently
7. Handle errors gracefully

**Endpoints**:
```
GET  /api/health                 → Service status
GET  /api/earthquakes            → Latest earthquakes (GeoJSON)
GET  /api/earthquakes/{region}   → Regional earthquakes
GET  /api/weather                → Weather radar frames
GET  /api/infrastructure         → Facility locations
GET  /api/infrastructure/{region}→ Regional facilities
GET  /api/satellites             → Satellite imagery URLs
POST /api/analyze                → AI analysis (uses Qwen2.5:7b)
WS   /ws/realtime               → WebSocket for streaming updates
```

**Caching Strategy**:
```python
CACHE_TTL = {
    "earthquakes": 300,      # 5 minutes (data refreshes slowly)
    "weather": 600,          # 10 minutes (radar updates every 10min)
    "infrastructure": 30,    # 30 seconds (frequent updates)
    "satellites": 86400      # 1 day (daily refresh)
}
```

**Build Command in Continue**:
```python
# ai: Create FastAPI service for geodashboard that:
# - Provides /api/earthquakes endpoint (GeoJSON format)
# - Fetches from https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson
# - Caches responses (5 minute TTL)
# - Implements background refresh thread
# - Provides /api/weather endpoint for RainViewer radar
# - Implements WebSocket /ws/realtime for streaming
# - Uses Qwen2.5:7b for data analysis if available
# - Includes error handling and retries
# - Production-ready with logging
```

---

### Optional: Additional Agents

#### Globe3DRenderer Agent
**Purpose**: Pre-process data for 3D rendering  
**Build Time**: 20 minutes  
**Benefit**: Smoother 3D performance  
**When to Add**: Only if you want advanced optimization

#### StatisticsAggregator Agent
**Purpose**: Real-time metrics computation  
**Build Time**: 15 minutes  
**Benefit**: Live stat cards  
**When to Add**: If you want fully dynamic dashboard

---

## CONTINUE IDE USAGE GUIDE

### Three Main Commands

#### 1. Chat (Ctrl+L) - Architecture Discussions
```
Use when: Asking about design, architecture, best practices
Example: "ai: What's the optimal way to cluster 1000+ nodes in Three.js?"
Response: Detailed explanation with code examples
Result: Understand the approach, then implement with Ctrl+I
```

#### 2. Edit/Generate (Ctrl+I) - Code Generation
```
Use when: Need code generated or refactored
Setup: Select code/comment or place cursor at empty line
Action: Press Ctrl+I, type your request
Example: "// ai: Create function to color-code earthquakes by magnitude"
Result: Complete, production-ready code inserted/replaced
```

#### 3. Autocomplete (Tab) - Smart Suggestions
```
Use when: Typing code, need completion
Setup: Start typing function/class/method
Action: Press Tab when suggestion appears
Example: L.marker(  → Tab → auto-completes parameters
Result: Faster coding with fewer typos
```

### Typical Build Session Flow

```
1. Open Continue (Ctrl+L)
   ├── Ask architecture question
   └── Read detailed response

2. Open HTML file
   ├── Press Ctrl+I
   ├── Paste HTML generation prompt
   └── Approve generated code

3. Write CSS
   ├── Use Tab for class name autocomplete
   ├── Use Ctrl+I for new CSS sections
   └── Continue suggests best practices

4. Write JavaScript
   ├── Press Tab frequently (L.marker, new THREE., etc.)
   ├── Use Ctrl+I for complex functions
   ├── Use Ctrl+L if stuck on logic
   └── Codestral generates optimized code

5. Test in browser
   ├── If error, use Ctrl+I to fix
   ├── If performance issue, use Ctrl+L for advice
   └── Iterate until perfect
```

---

## TEMPERATURE SETTINGS (Already Configured)

### For Frontend Code (Codestral)
```json
{
  "models": [
    {
      "title": "Codestral 22B (Code)",
      "provider": "ollama",
      "model": "codestral:22b-v0.1-q4_0",
      "apiBase": "http://localhost:11434",
      "completionOptions": {
        "temperature": 0.1,     // Ultra-deterministic
        "topP": 0.9,
        "maxTokens": 2000
      }
    },
    {
      "title": "Codestral 22B (Autocomplete)",
      "provider": "ollama",
      "model": "codestral:22b-v0.1-q4_0",
      "completionOptions": {
        "temperature": 0.15,    // Predictable suggestions
        "maxTokens": 100
      }
    }
  ]
}
```

### For Backend Analysis (Qwen2.5:7b)
```python
QWEN_SETTINGS = {
    "temperature": 0.3,        # Structured analysis
    "top_p": 0.9,
    "max_tokens": 500
}
```

---

## STEP-BY-STEP BUILD INSTRUCTIONS

### Pre-Build Setup (5 minutes)

```bash
# 1. Install Qwen2.5:7b (PATH A only)
ollama pull qwen2.5:7b

# 2. Verify Ollama has all models
curl -s http://127.0.0.1:11434/api/tags | jq '.models[] | {name, size}'
# Should show:
#   codestral:22b-v0.1-q4_0 (12.6 GB)
#   qwen2.5:7b              (5.5 GB)
#   llama3.2:3b             (2.0 GB)

# 3. Create directories
mkdir -p /portfolio-deployment-enhanced/geospatial-viz/{css,js,data}
mkdir -p ~/.continue/agents/agents_continue/geodashboard

# 4. Create empty files
touch /portfolio-deployment-enhanced/geospatial-viz/index.html
touch /portfolio-deployment-enhanced/geospatial-viz/globe-3d.html
touch ~/.continue/agents/agents_continue/geospatial_data_agent.py
```

### Phase 1: Architecture (30 minutes)

**In Continue Chat (Ctrl+L)**:

```
Prompt: I'm building an EPIC geodashboard with 2D map and 3D globe.
        Should I use WebSocket or polling for real-time updates?
        What's the best caching strategy?
        Any architectural considerations for 1000+ nodes?
        Should I use Qwen2.5:7b in backend for data analysis?

Expected: Codestral provides 5-minute detailed response
Outcome: You understand the architecture
Next: Proceed to Phase 2
```

### Phase 2: 2D Dashboard (30 minutes)

**Step 1**: Generate HTML (Ctrl+I)
```
File: /portfolio-deployment-enhanced/geospatial-viz/index.html
Prompt: // ai: Create professional glassmorphism HTML dashboard...
Result: Complete HTML structure (saves 10 min)
```

**Step 2**: Generate CSS (Ctrl+I)
```
File: css/dashboard.css
Prompt: /* ai: Create glassmorphism CSS with dark theme... */
Result: Complete, production-ready CSS
```

**Step 3**: Generate Leaflet Setup (Ctrl+I + Tab)
```
File: js/map.js
Prompts (one at a time):
  1. Map initialization
  2. addEarthquakeLayer function
  3. addWeatherRadarLayer function
  4. addInfrastructureLayer function
Use Tab frequently for autocomplete
Result: Complete map system
```

### Phase 3: 3D Globe (30 minutes)

**Step 1**: Generate Three.js Scene (Ctrl+I)
```
File: js/globe.js
Prompt: // ai: Create Three.js 3D globe with realistic Earth...
Result: Scene setup with lighting
```

**Step 2**: Add Infrastructure Nodes (Ctrl+I)
```
Prompt: // ai: Add infrastructure nodes as point cloud...
Result: Point cloud rendering with updates
```

**Step 3**: Add Data Flow Animation (Ctrl+I)
```
Prompt: // ai: Create animated data flow lines with particles...
Result: Smooth animations (60fps target)
```

**Step 4**: Add Controls (Ctrl+I)
```
Prompt: // ai: Implement orbital camera controls...
Result: Mouse drag to rotate, scroll to zoom
```

### Phase 4: Backend Agent (45 minutes)

**Step 1**: Create FastAPI Service (Ctrl+I)
```
File: ~/.continue/agents/agents_continue/geospatial_data_agent.py
Prompt: # ai: Create FastAPI service for geodashboard...
Result: Base service with endpoints
```

**Step 2**: Add USGS Earthquake Fetch (Ctrl+I)
```
Prompt: # ai: Add function to fetch USGS earthquakes...
Result: Real-time earthquake data with caching
```

**Step 3**: Add WebSocket Streaming (Ctrl+I)
```
Prompt: # ai: Add WebSocket /ws/realtime endpoint...
Result: Live streaming to frontend
```

**Step 4**: Add Qwen2.5:7b Analysis (Ctrl+I - if installed)
```
Prompt: # ai: Add function using Qwen2.5:7b for earthquake analysis...
Result: AI-powered insights
```

### Phase 5: Deploy & Test (15 minutes)

**Terminal**:
```bash
# Create systemd service
cat > ~/.config/systemd/user/geospatial-data-agent.service << 'EOF'
[Unit]
Description=Geospatial Data Service
After=network.target ollama.service

[Service]
Type=simple
ExecStart=/usr/bin/python3 %h/.continue/agents/agents_continue/geospatial_data_agent.py
Restart=always
RestartSec=10

[Install]
WantedBy=default.target
EOF

# Start service
systemctl --user daemon-reload
systemctl --user enable geospatial-data-agent.service
systemctl --user start geospatial-data-agent.service

# Verify
curl -s http://localhost:5100/api/health | jq
```

**Browser**:
```
Open: https://www.simondatalab.de/geospatial-viz/
Test checklist:
  [ ] Map loads
  [ ] Earthquakes appear
  [ ] Weather radar works
  [ ] Stats update
  [ ] 3D globe smooth (60fps)
  [ ] WebSocket connected
```

---

## SUCCESS METRICS

**When Complete, You'll Have**:

✅ **2D Dashboard**
- Professional glassmorphism design (no emojis)
- Real-time earthquake markers (magnitude color-coded)
- Weather radar overlay (RainViewer API)
- Infrastructure nodes visualization
- Live statistics updating
- Full responsiveness (mobile + desktop)
- Smooth interactions (0ms lag)

✅ **3D Globe**
- Realistic Earth texture (NASA Blue Marble)
- 1000+ nodes rendering at 60fps
- Smooth orbital camera controls
- Animated data flow visualization
- Real-time earthquake pulsing
- Performance optimized

✅ **Backend Service**
- Real-time USGS earthquake data (5-minute refresh)
- RainViewer weather radar integration
- Infrastructure status monitoring
- WebSocket for live streaming
- Intelligent caching (5-30min TTL)
- AI analysis (if Qwen installed)
- Proper error handling & logging

✅ **Continue Integration Throughout**
- Used Ctrl+I for rapid code generation
- Tab autocomplete saved time
- Ctrl+L for architecture discussions
- Generated production-ready code
- Minimal manual corrections needed

---

## RECOMMENDED CHOICE: PATH A

**Why PATH A**:
1. Only 5 more minutes than PATH B
2. Professional-grade result
3. AI-powered backend insights
4. WebSocket real-time updates
5. Perfect learning opportunity

**Timeline**:
```
5 min   - Install Qwen2.5:7b
30 min  - Build 2D Dashboard
30 min  - Build 3D Globe
45 min  - Build Backend Agent
15 min  - Deploy & Test
────────────────────────
2:05h   - COMPLETE SYSTEM
```

---

## IMMEDIATE NEXT STEP

**Reply to continue:**
- "A" → Full build with Qwen + backend agent
- "B" → Quick build Codestral only
- "GO" → I'll install Qwen and prepare everything for you

**Let's build the EPIC geodashboard! 🚀**

