# EPIC Geospatial Dashboard - Architecture & Model Recommendations

**Date**: November 7, 2025  
**Status**: Planning Phase  
**Live URL**: https://www.simondatalab.de/geospatial-viz/

---

## 🎯 Vision

Professional, no-emoji geospatial dashboard with:
- Real-time global infrastructure monitoring
- Advanced 3D globe with live data
- Weather radar, earthquake tracking, satellite imagery
- Professional dark theme (glassmorphism)
- Fast autocomplete and model recommendations
- Scalable backend for real-time updates

---

## 🏗️ Architecture Overview

```
┌──────────────────────────────────────────────────────────────┐
│ Frontend Layer (Portfolio)                                   │
├──────────────────────────────────────────────────────────────┤
│  • geospatial-viz/index.html (Main Dashboard)               │
│  • geospatial-viz/globe-3d.html (3D Globe with Three.js)    │
│  • Leaflet.js for map interactions                           │
│  • D3.js for data visualization                              │
│  • Real-time WebSocket/Polling for data updates              │
└─────────────────┬──────────────────────────────────────────┘
                  │
┌──────────────────┴──────────────────────────────────────────┐
│ Backend Layer (FastAPI Agent on localhost:5000)             │
├──────────────────────────────────────────────────────────────┤
│  • geospatial_data_agent.py (FastAPI + llama3.2:3b)         │
│  • Real-time API endpoints:                                  │
│    - /api/earthquakes (USGS feed)                            │
│    - /api/weather (RainViewer/OpenWeatherMap)               │
│    - /api/infrastructure (Custom monitoring)                 │
│    - /api/satellites (NASA GIBS)                             │
│  • WebSocket for live streaming                              │
│  • Data aggregation & processing                             │
└─────────────────┬──────────────────────────────────────────┘
                  │
┌──────────────────┴──────────────────────────────────────────┐
│ Local AI Model Layer (Ollama)                               │
├──────────────────────────────────────────────────────────────┤
│  ✅ llama3.2:3b (Recommended - available now)               │
│  🔧 Optional upgrades:                                       │
│    - deepseek-coder:6.7b (Better code generation)           │
│    - qwen2.5:7b (General purpose, faster)                   │
│    - mistral:7b (Creative content)                          │
└──────────────────────────────────────────────────────────────┘
```

---

## 🧠 Model Recommendations

### Current Setup (NOW AVAILABLE)
```
Model: llama3.2:3b
Location: http://127.0.0.1:11434
Context: 8192 tokens
Speed: Fast (good for real-time)
Cost: Free (local)
Use Case: Dashboard data processing, API responses
```

### Recommended Upgrades (Optional - Install via Ollama)

#### Tier 1: Best for Coding (Recommended for Continue)
```bash
ollama pull deepseek-coder:6.7b  # ~6.7GB
```
- **Best for**: Code generation, technical documentation
- **Temperature**: 0.1-0.3 (very deterministic)
- **Context**: 8192 tokens
- **Speed**: Medium
- **Recommendation**: Use for Continue extension

#### Tier 2: Best for General Purpose
```bash
ollama pull qwen2.5:7b  # ~5.5GB
```
- **Best for**: General queries, data processing
- **Temperature**: 0.3-0.5
- **Context**: 32768 tokens (largest!)
- **Speed**: Fast
- **Recommendation**: Use for dashboard data aggregation

#### Tier 3: Fast & Lightweight
```bash
ollama pull mistral:7b  # ~4.1GB
```
- **Best for**: Quick responses, real-time inference
- **Temperature**: 0.4-0.7
- **Context**: 8192 tokens
- **Speed**: Very fast
- **Recommendation**: Use for autocomplete suggestions

---

## 🎨 Frontend Components

### Main Dashboard (index.html)
**Features:**
- Professional dark theme with glassmorphism
- No emojis (text-only labels)
- Real-time stat cards (top-left):
  - Active Facilities
  - Countries Covered
  - Live Connections
  - Data Points Streaming
- Multi-layer map:
  - Base map (OpenStreetMap)
  - Infrastructure nodes (cyan)
  - Earthquake markers (color-coded by magnitude)
  - Weather radar overlay (RainViewer)
  - Satellite imagery toggle
- Control panel (bottom-left):
  - Weather Radar toggle
  - Earthquake toggle
  - Satellite imagery toggle
  - 3D Globe view button
- Time slider for historical radar
- Legend and zoom controls

### 3D Globe Component (globe-3d.html)
**Technology:** Three.js
**Features:**
- Rotating Earth with real-time illumination
- Infrastructure node clusters:
  - Americas (New York, São Paulo, Toronto)
  - Europe (London, Frankfurt, Amsterdam)
  - Asia-Pacific (Tokyo, Singapore, Sydney)
  - Middle East (Dubai, Mumbai)
  - Africa (Cape Town, Lagos, Cairo)
- Dynamic data flow connections (animated)
- Real-time status indicators
- Orbital camera controls
- 4K texture support
- Performance optimized for 60fps

---

## 🔧 Backend Agent Architecture

### File: `geospatial_data_agent.py`
**Location**: `.continue/agents/agents_continue/geospatial_data_agent.py`

**Endpoints:**
```
GET  /api/health                    - Service health check
GET  /api/earthquakes               - Latest earthquakes (USGS)
GET  /api/earthquakes/{region}      - Regional earthquake data
GET  /api/weather                   - Current weather/radar frames
GET  /api/infrastructure            - Live infrastructure status
GET  /api/infrastructure/{region}   - Regional infrastructure
GET  /api/satellites                - Active satellite data
WS   /ws/realtime                   - WebSocket for live updates
POST /api/analyze                   - NLP analysis (llama3.2:3b)
```

**Features:**
- Real-time data aggregation from:
  - USGS Earthquake feed (updated every 5 minutes)
  - RainViewer API (weather radar)
  - OpenWeatherMap API (optional)
  - NASA GIBS (satellite imagery)
  - Custom infrastructure monitoring
- Llama3.2:3b for:
  - Earthquake impact analysis
  - Data summarization
  - Natural language responses
  - Anomaly detection
- WebSocket support for real-time streaming
- Rate limiting and caching
- Error recovery & retries

---

## 🚀 Agents Recommended

### Primary Agent: Geospatial Data Agent
```python
# geospatial_data_agent.py
name = "geospatial-data-service"
role = "Real-time geospatial data aggregation and analysis"
port = 5100
model = "llama3.2:3b"  # Upgrade to qwen2.5:7b for better analysis
update_frequency = 30  # seconds
```

**Systemd Service:**
```ini
[Unit]
Description=Geospatial Data Service Agent
After=network.target ollama.service

[Service]
Type=simple
ExecStart=/usr/bin/python3 .continue/agents/agents_continue/geospatial_data_agent.py
Restart=always
RestartSec=10
StandardOutput=journal
Environment="PYTHONUNBUFFERED=1"

[Install]
WantedBy=multi-user.target
```

---

## 🔌 API Integration

### External Data Sources

#### 1. USGS Earthquake Feed (FREE)
```
API: https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/{period}.geojson
Updates: Every 5 minutes
Coverage: Global, M2.5+
Rate Limit: Unlimited
```

#### 2. RainViewer Weather Radar (FREE)
```
API: https://api.rainviewer.com/public/weather-maps.json
Tiles: https://tilecache.rainviewer.com/{path}/256/{z}/{x}/{y}/2/1_1.png
Coverage: Global (90% coverage)
Rate Limit: Generous free tier
```

#### 3. OpenWeatherMap (Optional - requires API key)
```
API: https://api.openweathermap.org/data/2.5/
Features: Current weather, forecast, air quality
Rate Limit: 1000 calls/day (free tier)
```

#### 4. NASA GIBS Satellite Imagery (FREE)
```
API: https://map1.vis.earthdata.nasa.gov/wmts-webmerc/
Layers: True Color, False Color, Night Lights
Coverage: Global, daily updates
```

#### 5. OpenWeatherMap Air Quality (Optional)
```
API: https://api.openweathermap.org/data/2.5/air_pollution
Resolution: City-level
```

---

## 🔥 Continue Integration

### Using Continue for Dashboard Development

**Keyboard Shortcuts:**
```
Ctrl+L (Chat)     - Ask about dashboard features
Ctrl+I (Edit)     - Refactor/improve code
Ctrl+K (Command)  - Quick actions
Tab               - Autocomplete (llama3.2:3b)
```

**Example Prompts:**
```
// Add earthquake impact analysis
// ai: Add function to calculate earthquake impact radius based on magnitude and depth

// Improve performance
// ai: Optimize the WebSocket update loop to handle 1000+ data points

// Generate documentation
// ai: Generate JSDoc for all map layer functions
```

### Recommended Temperature Settings for Dashboard Code
```json
{
  "Dashboard Code Generation": {
    "temperature": 0.1,  // Very deterministic, precise code
    "topP": 0.9,
    "context": 4096
  },
  "Documentation/Comments": {
    "temperature": 0.3,  // Slightly creative, natural language
    "topP": 0.95
  },
  "Refactoring Suggestions": {
    "temperature": 0.2,  // Deterministic improvements
    "topP": 0.9
  }
}
```

---

## 🎯 Autocomplete Recommendations

### For geospatial-viz code:
```
Temperature: 0.3 (default)
Max tokens: 50-100
Stop tokens: ["\n\n", ";", "}", "),"]
Context: 1024 tokens

Models that excel at autocomplete:
1. llama3.2:3b (current - good)
2. mistral:7b (recommended - very fast)
3. deepseek-coder:6.7b (best - very accurate)
```

### Enable Autocomplete in Continue Config:
Already configured in `~/.continue/config.json`:
```json
"tabAutocompleteModel": {
  "title": "Llama 3.2 3B (Autocomplete)",
  "provider": "ollama",
  "model": "llama3.2:3b",
  "contextLength": 2048,
  "completionOptions": {
    "temperature": 0.3,
    "maxTokens": 100
  }
}
```

---

## 📊 Technology Stack

### Frontend
- **HTML5** - Structure
- **CSS3** - Styling (glassmorphism, gradients)
- **Vanilla JavaScript** - Interactions
- **Leaflet.js** - Map library
- **D3.js** - Data visualization
- **Three.js** - 3D globe rendering
- **Chart.js** - Time-series charts (optional)

### Backend
- **Python 3.9+** - Language
- **FastAPI** - Web framework
- **Pydantic** - Data validation
- **Requests** - HTTP client
- **WebSockets** - Real-time updates
- **Ollama** - Local AI integration

### Infrastructure
- **Ollama** - Local model serving
- **Docker** (optional) - Containerization
- **Nginx** - Reverse proxy (already configured)
- **Systemd** - Process management

---

## 🎨 Design System

### Color Palette (No Emojis)
```css
/* Primary */
--cyan-primary: #00d4ff;
--cyan-secondary: #0099ff;

/* Backgrounds */
--bg-dark-1: #050810;
--bg-dark-2: #0a0e1a;
--bg-dark-3: #1a1d2e;

/* Text */
--text-primary: #e0e0e0;
--text-secondary: #9db4d3;

/* Data Visualization */
--earthquake-minor: #ffff99;    /* Yellow - minor */
--earthquake-moderate: #ffaa00; /* Orange - moderate */
--earthquake-strong: #ff6600;   /* Dark orange - strong */
--earthquake-major: #cc0000;    /* Red - major */
--weather-light: #00ccff;       /* Cyan - light rain */
--weather-heavy: #0066ff;       /* Blue - heavy rain */
```

### Typography (Professional, No Emojis)
```css
Headers: "Global Infrastructure Network"
Labels: "Active Facilities", "Countries", "Connections"
Buttons: "Weather Radar", "Earthquakes", "Satellites"
```

---

## 📈 Implementation Timeline

### Phase 1: Core Dashboard (Week 1)
- [ ] Create professional HTML/CSS structure
- [ ] Integrate Leaflet.js map
- [ ] Add real-time stat cards
- [ ] Implement weather radar overlay
- [ ] Add earthquake markers with color coding

### Phase 2: Advanced Features (Week 2)
- [ ] Create FastAPI backend agent
- [ ] Implement WebSocket for real-time updates
- [ ] Add 3D globe component
- [ ] Integrate satellite imagery
- [ ] Build time slider for radar history

### Phase 3: Optimization & Polish (Week 3)
- [ ] Performance optimization
- [ ] Mobile responsiveness
- [ ] Accessibility (A11y) improvements
- [ ] Documentation generation with Continue
- [ ] Deployment and testing

---

## 🧪 Testing Strategy

### Functional Tests
- [ ] Earthquake data loads and updates
- [ ] Weather radar displays correctly
- [ ] Infrastructure nodes appear and update
- [ ] 3D globe rotates smoothly
- [ ] WebSocket connections handle disconnection

### Performance Tests
- [ ] Dashboard loads in <2 seconds
- [ ] 60fps animation on 3D globe
- [ ] Real-time updates <500ms latency
- [ ] Handles 1000+ data points smoothly

### Cross-Browser Tests
- [ ] Chrome/Edge 90+
- [ ] Firefox 90+
- [ ] Safari 14+
- [ ] Mobile browsers

---

## 🚀 Deployment Steps

```bash
# 1. Start Ollama with llama3.2:3b
ollama serve

# 2. Start geospatial data agent
systemctl --user start geospatial-data-agent.service

# 3. Deploy to production
bash scripts/deploy_improved_portfolio.sh

# 4. Verify live
curl -s http://localhost:5100/api/health
curl -s https://www.simondatalab.de/geospatial-viz/
```

---

## 📚 Documentation to Generate

Using Continue (Ctrl+L):
```
// ai: Generate API documentation for geospatial_data_agent.py
// ai: Create user guide for geodashboard features
// ai: Write deployment instructions for systemd service
// ai: Document model selection criteria
```

---

## 🎯 Success Metrics

- ✅ Dashboard loads in <2 seconds
- ✅ Real-time data updates every 30-60 seconds
- ✅ No console errors
- ✅ Smooth 60fps animations
- ✅ Mobile responsive (tested on iOS/Android)
- ✅ Professional appearance (no emojis)
- ✅ API endpoints responding <500ms
- ✅ WebSocket updates <200ms latency

---

## 📋 Checklist Before Launch

- [ ] All models installed and configured
- [ ] Backend agent running and healthy
- [ ] Frontend loads without errors
- [ ] Real-time data updating
- [ ] 3D globe rendering smoothly
- [ ] Continue integration tested
- [ ] Documentation complete
- [ ] Deployed to production
- [ ] Live at https://www.simondatalab.de/geospatial-viz/

---

**Next Steps:**
1. Review this architecture
2. Approve model recommendations
3. Begin Phase 1 implementation
4. Use Continue for code generation and documentation

---

*Generated: November 7, 2025*  
*Ready for implementation with Continue IDE assistance*
