# EPIC Geodashboard - Model Selection & Agent Architecture Guide

**Date**: November 7, 2025  
**Primary Tool**: Continue IDE (Ctrl+I, Ctrl+L, Tab)  
**Status**: Ready for Implementation

---

## 🧠 Recommended Model Stack for Geodashboard

### Current Setup
```
Model                      Role                    Temperature  Context  Speed
────────────────────────────────────────────────────────────────────────────
Codestral 22B             Code Generation          0.1         16k      500-1000ms
                          Autocomplete             0.15        4k       Fast
                          Architecture Discuss     0.3         16k      Medium
```

### Recommended Additional Models (Optional)

#### Option A: Best for Data Analysis (RECOMMENDED)
```bash
ollama pull qwen2.5:7b
```
- **Size**: 5.5 GB
- **Purpose**: Data summarization, earthquake impact analysis, statistics generation
- **Temperature**: 0.3-0.5 (balanced)
- **Context**: 32,768 tokens (largest available)
- **Use Case**: Backend agent for real-time data processing
- **Why**: Better at structured data and numerical analysis than Codestral
- **Integration**: Use in `geospatial_data_agent.py` for AI-powered insights

#### Option B: Alternative (Faster but Less Capable)
```bash
ollama pull mistral:7b
```
- **Size**: 4.1 GB
- **Purpose**: Quick responses, general queries
- **Temperature**: 0.4 (balanced)
- **Context**: 8192 tokens
- **Speed**: Very fast (50-200ms first token)

### Recommended Setup for Geodashboard
```
┌─────────────────────────────────────────────┐
│ Continue IDE (Frontend Code Generation)    │
├─────────────────────────────────────────────┤
│ Model: Codestral 22B (Code, Autocomplete)  │
│ Temp: 0.1 (code), 0.15 (autocomplete)      │
│ Use: Ctrl+I (edit), Ctrl+L (chat), Tab     │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│ Dashboard Frontend (index.html + globe.js) │
├─────────────────────────────────────────────┤
│ Leaflet + D3.js (2D)                       │
│ Three.js (3D globe)                        │
│ WebSocket real-time updates                │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│ Backend Data Agent (FastAPI)               │
├─────────────────────────────────────────────┤
│ Model: Qwen2.5:7b (OPTIONAL - recommended) │
│ Temp: 0.3 (structured data analysis)       │
│ Port: 5100                                 │
│ Jobs: Data aggregation, AI insights        │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│ External Data Sources                      │
├─────────────────────────────────────────────┤
│ USGS Earthquakes (every 5 min)             │
│ RainViewer Weather Radar (every 10 min)    │
│ Infrastructure Monitoring (every 30 sec)   │
│ NASA GIBS Satellite (daily)                │
└─────────────────────────────────────────────┘
```

---

## 🤖 Agent Architecture for Geodashboard

### Agent 1: Geospatial Data Service Agent (Primary)

**File**: `.continue/agents/agents_continue/geospatial_data_agent.py`

```python
class GeospatialDataService(FastAPI):
    """
    Real-time geospatial data aggregation and AI analysis service.
    
    Models:
    - Codestral 22B: Frontend code templates (optional)
    - Qwen2.5:7b: Data analysis and summarization (PRIMARY)
    
    Endpoints:
    - GET  /api/health
    - GET  /api/earthquakes
    - GET  /api/earthquakes/{region}
    - GET  /api/weather
    - GET  /api/infrastructure
    - GET  /api/infrastructure/{region}
    - GET  /api/satellites
    - POST /api/analyze                    # Uses Qwen2.5:7b
    - WS   /ws/realtime                    # WebSocket streaming
    
    Features:
    - Real-time USGS earthquake feed
    - RainViewer weather radar layers
    - Infrastructure monitoring
    - AI-powered impact analysis (earthquakes, weather)
    - Caching (5-30 minute TTL based on data type)
    - Error recovery with exponential backoff
    - WebSocket support for live updates
    """
    
    def __init__(self):
        self.codestral = "http://localhost:11434"      # Fast code templates
        self.qwen = "http://localhost:11434"           # Data analysis
        self.cache_ttl = {
            "earthquakes": 300,      # 5 minutes
            "weather": 600,          # 10 minutes
            "infrastructure": 30,    # 30 seconds
            "satellites": 86400      # 1 day
        }
    
    async def fetch_earthquakes_with_ai(self):
        """
        Fetch earthquakes from USGS, use Qwen2.5:7b to:
        - Analyze impact radius based on magnitude/depth
        - Generate human-readable summaries
        - Identify clusters and patterns
        """
        pass
    
    async def fetch_weather_with_analysis(self):
        """
        Get RainViewer radar frames, use Qwen2.5:7b to:
        - Summarize weather patterns
        - Detect storms/anomalies
        - Predict intensity trends
        """
        pass
    
    async def websocket_streaming(self, websocket):
        """
        Stream updates via WebSocket:
        - New earthquakes (within 5 seconds)
        - Weather radar frames (every 10 seconds)
        - Infrastructure status changes (immediate)
        """
        pass
```

**Systemd Service**:
```ini
[Unit]
Description=Geospatial Data Service Agent
After=network.target ollama.service

[Service]
Type=simple
ExecStart=/usr/bin/python3 %h/.continue/agents/agents_continue/geospatial_data_agent.py
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
Environment="PYTHONUNBUFFERED=1"
Environment="OLLAMA_BASE_URL=http://localhost:11434"

[Install]
WantedBy=default.target
```

---

### Agent 2: 3D Globe Renderer (Optional, for Performance)

**File**: `.continue/agents/agents_continue/globe_3d_renderer_agent.py`

```python
class Globe3DRenderer:
    """
    Pre-processes 3D globe data for Three.js.
    Optional agent for high-performance rendering.
    
    Tasks:
    - Cluster infrastructure nodes by proximity
    - Generate data flow paths between nodes
    - Pre-compute camera animations
    - Optimize texture loading
    - Generate shader definitions
    """
    
    async def cluster_nodes(self, locations):
        """Use Qwen2.5:7b to intelligently group nodes by region"""
        pass
    
    async def generate_data_flows(self, connections):
        """Create smooth paths and animation timings"""
        pass
```

---

### Agent 3: Statistics Aggregator (Optional)

**File**: `.continue/agents/agents_continue/statistics_aggregator_agent.py`

```python
class StatisticsAggregator:
    """
    Real-time statistics computation.
    
    Metrics:
    - Active Facilities Count
    - Countries Covered
    - Live Connections
    - Data Points Streaming
    - Earthquake Summary (last 24h)
    - Weather Alerts
    - Infrastructure Health
    """
    
    async def compute_stats(self):
        """Use Qwen2.5:7b to generate natural language summaries"""
        pass
```

---

## 🎯 Implementation Workflow with Continue

### Phase 1: Architecture & Setup (30 minutes)

**Step 1**: Open Continue chat (Ctrl+L) and discuss architecture
```
User: "ai: I'm building an EPIC geodashboard with 2D Leaflet map and 3D Three.js globe. 
       Should I use Codestral for code generation and Qwen2.5:7b for backend data analysis? 
       What's the optimal model selection for autocomplete, code generation, and data processing?"

Expected Response: Codestral provides detailed architecture recommendations with code examples
```

**Step 2**: Create directory structure
```bash
mkdir -p ~/.continue/agents/agents_continue/geodashboard/{2d,3d,backend}
mkdir -p /var/www/portfolio/geospatial-viz/{css,js,data}
```

---

### Phase 2: 2D Dashboard (2-3 hours)

**File**: `/portfolio-deployment-enhanced/geospatial-viz/index.html`

**Using Continue for Rapid Development**:

1. **Generate HTML Structure** (Ctrl+I):
```javascript
// ai: Create a professional glassmorphism HTML dashboard for global infrastructure with:
// - 3-column layout (stats on left, map in center, controls on right)
// - Leaflet map container
// - Real-time stat cards (no emojis, professional text labels)
// - Layer toggle switches (weather, earthquakes, satellites)
// - Time slider for historical data
// - Legend panel
// Styling: Dark background (#050810), cyan accents (#00d4ff), 12px border radius
```

2. **Generate CSS** (Ctrl+I):
```css
/* ai: Create glassmorphism CSS with:
  - Dark theme variables (--bg-dark-1 through --bg-dark-3)
  - Cyan color scheme (#00d4ff, #0099ff)
  - Glass effect with backdrop-filter and rgba
  - Responsive grid layout: sidebar-left (250px) | map (1fr) | sidebar-right (300px)
  - Smooth animations and hover effects
  - No emojis, professional appearance
  - Mobile responsive (media query for <768px)
*/
```

3. **Generate Leaflet Map Setup** (Ctrl+I):
```javascript
// ai: Create a Leaflet map initialization with:
// - OpenStreetMap base layer (dark tile server)
// - Earthquake markers with color coding (magnitude 2-4: yellow, 4-5: orange, 5-6: red, 6+: dark red)
// - Infrastructure nodes with cyan markers
// - RainViewer weather radar overlay (optional toggle)
// - Satellite imagery layer (toggle-able)
// - Zoom controls, attribution
// - Click handlers for markers showing detailed info
// Return complete, production-ready code
```

**Autocomplete Usage** (Tab):
- After `const map = L.map(` → Tab for auto-completion
- After `L.tileLayer(` → Tab suggests correct parameters
- After `L.marker(` → Tab auto-fills with proper structure

---

### Phase 3: 3D Globe (2-3 hours)

**File**: `/portfolio-deployment-enhanced/geospatial-viz/globe-3d.html`

**Using Continue**:

```javascript
// ai: Create a Three.js 3D rotating Earth globe with:
// - Procedurally generated textured Earth
// - Real-time infrastructure node clusters (red dots on surface)
// - Animated data flow lines between nodes (cyan colors)
// - Smooth orbital camera controls (mouse drag to rotate, scroll to zoom)
// - Real-time earthquake markers (pulsing red spheres)
// - Performance optimized (60fps target, use LOD for nodes)
// - Stats panel showing FPS, active nodes, data points
// - Integration with backend WebSocket for live updates
// Make it beautiful and production-ready
```

**Break It Into Smaller Prompts**:

1. First: "ai: Generate Three.js scene setup with Earth geometry and realistic textures"
2. Then: "ai: Add infrastructure nodes as point clouds with real-time updates"
3. Then: "ai: Create data flow animation between nodes using Bezier curves"
4. Then: "ai: Implement orbital camera controls with mouse and scroll"
5. Finally: "ai: Optimize rendering for 1000+ nodes at 60fps"

**Autocomplete**:
- Tab after `new THREE.` → suggests correct class
- Tab after `geometry.` → suggests all available properties
- Tab after `material.` → auto-completes shader properties

---

### Phase 4: Backend Data Agent (1-2 hours)

**File**: `.continue/agents/agents_continue/geospatial_data_agent.py`

**Using Continue**:

```python
# ai: Create a FastAPI service that:
# - Fetches real-time earthquakes from USGS API
# - Caches responses (5-minute TTL)
# - Provides REST endpoints: /api/earthquakes, /api/weather, /api/infrastructure
# - Implements WebSocket at /ws/realtime for streaming updates
# - Uses Qwen2.5:7b for data analysis and summarization
# - Includes error handling, retries, rate limiting
# - Returns properly formatted GeoJSON for Leaflet
# Production-ready with logging and health checks
```

**Smaller Prompts**:

1. "ai: Create FastAPI base with Ollama integration for Qwen2.5:7b model"
2. "ai: Add USGS earthquake fetching with caching and background refresh"
3. "ai: Implement WebSocket endpoint for real-time updates"
4. "ai: Add Qwen2.5:7b analysis for earthquake impact summarization"
5. "ai: Create systemd service file for auto-start and monitoring"

---

## 📊 Model Temperature Recommendations for Geodashboard

```json
{
  "frontend": {
    "codestral_code_generation": {
      "task": "Generate HTML/CSS/JS for dashboard components",
      "temperature": 0.1,
      "context": 4096,
      "max_tokens": 2000,
      "rationale": "Very deterministic, consistent styling"
    },
    "codestral_autocomplete": {
      "task": "Tab completion in HTML/CSS/JS files",
      "temperature": 0.15,
      "context": 1024,
      "max_tokens": 100,
      "rationale": "Predictable suggestions, low hallucination"
    },
    "codestral_refactoring": {
      "task": "Improve existing code quality",
      "temperature": 0.2,
      "context": 2048,
      "max_tokens": 1000,
      "rationale": "Precise transformations"
    }
  },
  "backend": {
    "qwen2.5_data_analysis": {
      "task": "Analyze earthquake/weather data, generate insights",
      "temperature": 0.3,
      "context": 8192,
      "max_tokens": 500,
      "rationale": "Structured analysis with some creativity"
    },
    "qwen2.5_summarization": {
      "task": "Generate human-readable summaries of data",
      "temperature": 0.4,
      "context": 4096,
      "max_tokens": 300,
      "rationale": "Natural language with variety"
    },
    "codestral_backend_code": {
      "task": "Generate Python FastAPI code",
      "temperature": 0.1,
      "context": 4096,
      "max_tokens": 2000,
      "rationale": "Production code must be deterministic"
    }
  }
}
```

---

## 🚀 Step-by-Step Build Instructions

### Step 1: Install Qwen2.5:7b (OPTIONAL but RECOMMENDED)
```bash
# Takes ~5-10 minutes, downloads 5.5GB
ollama pull qwen2.5:7b

# Verify
curl -s http://127.0.0.1:11434/api/tags | jq '.models[].name'
# Expected output includes: "qwen2.5:7b"
```

### Step 2: Update Continue Config to Use Both Models
```bash
# Edit ~/.continue/config.json to add Qwen2.5:7b backend role
# (we'll do this if you confirm)
```

### Step 3: Create Geodashboard Directory
```bash
mkdir -p /portfolio-deployment-enhanced/geospatial-viz/{css,js,data}
touch /portfolio-deployment-enhanced/geospatial-viz/{index.html,globe-3d.html}
touch ~/.continue/agents/agents_continue/geospatial_data_agent.py
```

### Step 4: Start Building with Continue
1. Open VS Code
2. Press `Ctrl+L` to open Continue chat
3. Use prompts from Phase 2-4 above
4. Press `Ctrl+I` to generate/refactor code
5. Press `Tab` for autocomplete suggestions

### Step 5: Test Incrementally
```bash
# Test 2D dashboard
open https://localhost/geospatial-viz/

# Test 3D globe
open https://localhost/geospatial-viz/globe-3d.html

# Test backend agent
curl -s http://localhost:5100/api/health | jq
curl -s http://localhost:5100/api/earthquakes | jq '.features[0]'
```

---

## 📋 Continue Prompts Library (Copy-Paste Ready)

### Prompts for 2D Dashboard

```javascript
// Prompt 1: HTML Structure
// ai: Create professional glassmorphism dashboard HTML with no emojis
// 3 columns: left sidebar (stats), center (map), right sidebar (controls)
// Dark theme, cyan accents, responsive design

// Prompt 2: Map Layer Functions
// ai: Create Leaflet layer functions:
// - addEarthquakeLayer(map, earthquakes)
// - addWeatherRadarLayer(map, radarUrl)
// - addInfrastructureLayer(map, facilities)
// - addSatelliteLayer(map)
// Each layer should be toggle-able, color-coded, with proper legends

// Prompt 3: Statistics Panel
// ai: Create real-time statistics panel that displays:
// - Active Facilities (updates every 30 seconds)
// - Countries Covered (auto-count from data)
// - Live Connections (WebSocket stream count)
// - Data Points Streaming (counter)
// Use glassmorphism styling with smooth animations
```

### Prompts for 3D Globe

```javascript
// Prompt 1: Three.js Setup
// ai: Create Three.js scene with:
// - Realistic Earth texture (use NASA Blue Marble or similar)
// - Dark space background
// - Lighting setup for depth perception
// - Optimized for 1000+ nodes
// Return complete, working code

// Prompt 2: Node Clustering
// ai: Implement smart clustering for infrastructure nodes:
// - Show individual nodes when zoomed in
// - Cluster nodes when zoomed out
// - Use color gradients (cyan to red) based on activity level
// - Smooth LOD transitions

// Prompt 3: Data Flow Animation
// ai: Create animated data flow lines between nodes:
// - Use cubic Bezier curves for paths
// - Pulsing animated particles along lines
// - Cyan colors with glow effect
// - Performance optimized (particle pooling)
```

### Prompts for Backend

```python
# Prompt 1: FastAPI Foundation
# ai: Create FastAPI service with:
# - CORS enabled for frontend
# - Ollama integration (http://localhost:11434)
# - Health check endpoint
# - Logging to file and console
# - Error handling with proper status codes
# Return production-ready starter code

# Prompt 2: USGS Integration
# ai: Implement USGS earthquake data fetching:
# - Cache responses (5-minute TTL)
# - Background thread for periodic updates
# - GeoJSON format for Leaflet
# - Error handling and retries
# - Use Qwen2.5:7b to analyze and summarize earthquake data

# Prompt 3: WebSocket Streaming
# ai: Add WebSocket endpoint (/ws/realtime) that:
# - Streams new earthquakes within 5 seconds of detection
# - Sends weather radar updates every 10 seconds
# - Broadcasts infrastructure status changes
# - Handles disconnections gracefully
# - Uses JSON format compatible with frontend
```

---

## 🎯 Expected Outcome

After following this guide with Continue autocomplete and code generation:

✅ **2D Dashboard**
- Professional glassmorphism design (no emojis)
- Real-time earthquake markers with magnitude color coding
- Weather radar overlay from RainViewer
- Infrastructure node visualization
- Time slider for historical data
- Responsive design (desktop + mobile)

✅ **3D Globe**
- Rotating Earth with realistic textures
- 1000+ infrastructure nodes rendered smoothly
- Animated data flow visualization
- Orbital camera controls
- 60fps performance target

✅ **Backend Service**
- Real-time data aggregation (USGS, RainViewer, infrastructure)
- AI-powered insights using Qwen2.5:7b
- WebSocket streaming for live updates
- Caching and error recovery
- Systemd auto-start service

✅ **Continue Integration**
- High-quality code generation with Codestral
- Smart autocomplete (Tab)
- Architecture discussions (Ctrl+L)
- Rapid refactoring (Ctrl+I)

---

## 🔄 Recommended Model Setup (Final)

**Install Now:**
```bash
ollama pull qwen2.5:7b  # Optional but highly recommended
```

**Already Installed:**
```bash
codestral:22b-v0.1-q4_0  # Primary for code generation
llama3.2:3b              # Fallback for all tasks
```

**Models Summary**:
| Model | Purpose | Size | Install Time |
|-------|---------|------|--------------|
| Codestral 22B | Code generation, autocomplete | 12.6GB | Done ✅ |
| Qwen2.5:7b | Data analysis, insights | 5.5GB | 5-10 min (optional) |
| Llama 3.2 3B | Fallback for any task | 2.0GB | Done ✅ |

---

## Ready to Build?

**Next Steps:**
1. ✅ Codestral installed and configured
2. ⏳ (Optional) Install Qwen2.5:7b for backend data analysis
3. 🚀 Start Phase 1: Architecture & Setup (30 min)
4. 🚀 Continue to Phase 2-4 using the prompts above
5. 🚀 Deploy to production

**Questions?**
- Model selection: Use Codestral for all frontend code, Qwen2.5:7b (optional) for backend data analysis
- Autocomplete: Yes, Continue Tab will work throughout with Codestral
- Agents: Create 1 primary (GeospatialDataService), 2 optional (Globe3DRenderer, StatisticsAggregator)

---

**Let's build! Choose one to start:**
- A) Install Qwen2.5:7b now, then begin Phase 1
- B) Skip Qwen and use Codestral + Llama only, begin Phase 1
- C) Something else?

