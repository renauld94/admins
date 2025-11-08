# EPIC Geodashboard - Implementation Guide

**Status**: Phase 2 Ready to Build  
**Duration**: ~40 hours (3-4 days intensive)  
**Primary Tool**: Continue IDE (Ctrl+I, Ctrl+L, Tab)  
**Model**: llama3.2:3b (local), optional upgrades: deepseek-coder:6.7b, qwen2.5:7b

---

## Phase 2: Main Dashboard Implementation

### File Structure
```
/portfolio-deployment-enhanced/geospatial-viz/
├── index.html                 # Main dashboard (will create/enhance)
├── globe-3d.html             # 3D globe component
├── css/
│   ├── dashboard.css         # Main styling (glassmorphism)
│   ├── map-layers.css        # Map-specific styles
│   └── responsive.css        # Mobile optimization
├── js/
│   ├── app.js                # Main application logic
│   ├── map.js                # Leaflet map configuration
│   ├── globe.js              # Three.js globe (for globe-3d.html)
│   ├── realtime.js           # WebSocket/API polling
│   ├── analytics.js          # Statistics and charting
│   └── utils.js              # Helper functions
├── data/
│   ├── infrastructure.json   # Facility locations
│   ├── regions.json          # Regional data
│   └── cache/                # API response cache
└── assets/
    ├── icons/                # Non-emoji SVG icons
    └── fonts/                # Professional fonts
```

---

## HTML Structure (index.html)

### Recommended DOM Layout
```
<body>
  <!-- Header with branding -->
  <header class="dashboard-header"></header>

  <!-- Main container -->
  <main class="dashboard-container">
    <!-- Left sidebar: Statistics -->
    <aside class="sidebar-left">
      <div class="stats-panel">
        <div class="stat-card">Active Facilities</div>
        <div class="stat-card">Countries Covered</div>
        <div class="stat-card">Live Connections</div>
        <div class="stat-card">Data Points Streaming</div>
      </div>
    </aside>

    <!-- Center: Map -->
    <section class="map-container">
      <div id="leaflet-map"></div>
    </section>

    <!-- Right sidebar: Controls -->
    <aside class="sidebar-right">
      <div class="controls-panel">
        <!-- Layer toggles -->
        <!-- Time slider -->
        <!-- Legend -->
      </div>
    </aside>
  </main>

  <!-- Bottom: Timeline and legends -->
  <footer class="dashboard-footer">
    <div class="timeline-slider"></div>
  </footer>
</body>
```

---

## CSS System (Glassmorphism Design)

### Key Design Principles
```css
/* No emojis, professional dark theme */

/* Glassmorphism backdrop filter */
.glass-effect {
  background: rgba(255, 255, 255, 0.05);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 12px;
}

/* Color Variables */
:root {
  /* Primary Cyan */
  --cyan-primary: #00d4ff;
  --cyan-dark: #0099ff;
  --cyan-light: #00ffff;

  /* Backgrounds */
  --bg-dark-1: #050810;      /* Deepest */
  --bg-dark-2: #0a0e1a;      /* Very dark */
  --bg-dark-3: #1a1d2e;      /* Dark */
  --bg-glass: rgba(15, 20, 35, 0.8);

  /* Text */
  --text-primary: #e0e0e0;   /* Main text */
  --text-secondary: #9db4d3; /* Labels */
  --text-muted: #6b8cae;     /* Hints */

  /* Data Visualization */
  --severity-low: #00ff88;    /* Green */
  --severity-medium: #ffaa00; /* Orange */
  --severity-high: #ff6666;   /* Red */

  /* Earthquake Categories */
  --eq-minor: #ffff99;        /* M 2-4 */
  --eq-light: #ffaa00;        /* M 4-5 */
  --eq-moderate: #ff6600;     /* M 5-6 */
  --eq-strong: #cc0000;       /* M 6+ */
}

/* Typography */
body {
  font-family: "Segoe UI", -apple-system, system-ui, sans-serif;
  background-color: var(--bg-dark-1);
  color: var(--text-primary);
  line-height: 1.5;
}

h1 { font-size: 2rem; font-weight: 600; }
h2 { font-size: 1.5rem; font-weight: 600; }
h3 { font-size: 1.2rem; font-weight: 500; }

/* Buttons (No emojis) */
.btn {
  background: var(--cyan-primary);
  color: var(--bg-dark-1);
  padding: 10px 16px;
  border-radius: 8px;
  border: none;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn:hover {
  background: var(--cyan-light);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 212, 255, 0.3);
}

.btn-secondary {
  background: transparent;
  border: 1px solid var(--cyan-primary);
  color: var(--cyan-primary);
}

/* Stat Cards */
.stat-card {
  background: var(--bg-glass);
  border: 1px solid rgba(0, 212, 255, 0.2);
  border-radius: 12px;
  padding: 16px;
  margin-bottom: 12px;
  backdrop-filter: blur(10px);
}

.stat-card .label {
  color: var(--text-secondary);
  font-size: 0.9rem;
  margin-bottom: 8px;
}

.stat-card .value {
  color: var(--cyan-primary);
  font-size: 1.8rem;
  font-weight: 700;
}

.stat-card .change {
  color: var(--text-muted);
  font-size: 0.8rem;
  margin-top: 4px;
}

/* Toggle Switches */
.toggle-switch {
  position: relative;
  width: 48px;
  height: 24px;
  background: rgba(0, 212, 255, 0.2);
  border-radius: 12px;
  cursor: pointer;
  transition: background 0.3s;
}

.toggle-switch.active {
  background: var(--cyan-primary);
}

.toggle-switch::after {
  content: '';
  position: absolute;
  width: 20px;
  height: 20px;
  background: white;
  border-radius: 50%;
  top: 2px;
  left: 2px;
  transition: left 0.3s;
}

.toggle-switch.active::after {
  left: 26px;
}

/* Leaflet Map Styling */
.leaflet-container {
  background: var(--bg-dark-2);
}

.leaflet-control {
  background: var(--bg-glass) !important;
  border: 1px solid rgba(0, 212, 255, 0.2) !important;
  border-radius: 8px !important;
  backdrop-filter: blur(10px);
}

.leaflet-control button {
  background: var(--cyan-primary) !important;
  color: var(--bg-dark-1) !important;
}
```

---

## JavaScript Architecture

### app.js - Main Application
```javascript
class GeospacialDashboard {
  constructor() {
    this.map = null;
    this.globe = null;
    this.apiBase = 'http://localhost:5100/api';
    this.dataCache = {};
    this.updateInterval = 30000; // 30 seconds
    this.activeLayersy = {
      earthquakes: true,
      weather: true,
      infrastructure: true,
      satellites: false
    };
  }

  async init() {
    // Initialize map, globe, data fetching, event listeners
  }

  async fetchData(endpoint) {
    // Fetch from backend agent with caching
  }

  updateStatistics() {
    // Update live stats (facilities, countries, connections)
  }

  handleLayerToggle(layer) {
    // Toggle layer visibility
  }

  setupWebSocket() {
    // Connect to real-time updates
  }
}
```

---

## API Backend Agent

### geospatial_data_agent.py Structure
```python
from fastapi import FastAPI, WebSocket
from fastapi.middleware.cors import CORSMiddleware
import httpx
import json
from datetime import datetime

app = FastAPI(title="Geospatial Data Service", version="1.0")

# Enable CORS for frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class DataAggregator:
    def __init__(self):
        self.earthquake_cache = None
        self.weather_cache = None
        self.update_times = {}

    async def fetch_earthquakes(self, min_magnitude=2.5):
        # Fetch from USGS endpoint
        pass

    async def fetch_weather_radar(self):
        # Fetch from RainViewer API
        pass

    async def fetch_infrastructure_status(self):
        # Fetch facility status
        pass

    async def analyze_with_ai(self, data_text):
        # Use llama3.2:3b for summarization/analysis
        pass

@app.get("/api/health")
async def health_check():
    # Return service status
    pass

@app.get("/api/earthquakes")
async def get_earthquakes():
    # Return earthquake data
    pass

@app.get("/api/weather")
async def get_weather():
    # Return weather radar data
    pass

@app.websocket("/ws/realtime")
async def websocket_endpoint(websocket: WebSocket):
    # Handle real-time updates
    pass
```

---

## Data Integration Points

### USGS Earthquake API
```javascript
async function fetchEarthquakes() {
  const response = await fetch(
    'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson'
  );
  const data = await response.json();
  
  return data.features.map(feature => ({
    id: feature.id,
    magnitude: feature.properties.mag,
    location: feature.properties.place,
    depth: feature.geometry.coordinates[2],
    lat: feature.geometry.coordinates[1],
    lng: feature.geometry.coordinates[0],
    timestamp: new Date(feature.properties.time),
    url: feature.properties.url
  }));
}

function getEarthquakeColor(magnitude) {
  if (magnitude < 4) return '#ffff99';    // Yellow
  if (magnitude < 5) return '#ffaa00';    // Orange
  if (magnitude < 6) return '#ff6600';    // Dark orange
  return '#cc0000';                       // Red
}
```

### RainViewer Weather Radar
```javascript
async function fetchWeatherRadar() {
  const response = await fetch('https://api.rainviewer.com/public/weather-maps.json');
  const data = await response.json();
  
  return {
    radar: data.radar,
    nowcast: data.nowcast,
    satellite: data.satellite
  };
}

function addWeatherRadarLayer(map, radarData) {
  const layer = L.tileLayer(
    `https://tilecache.rainviewer.com/${radarData.radar[radarData.radar.length - 1].path}/256/{z}/{x}/{y}/2/1_1.png`,
    {
      maxZoom: 19,
      attribution: 'RainViewer',
      opacity: 0.7
    }
  );
  
  map.addLayer(layer);
}
```

---

## Real-time Updates Strategy

### WebSocket Implementation
```javascript
class RealtimeDataManager {
  constructor(wsUrl = 'ws://localhost:5100/ws/realtime') {
    this.wsUrl = wsUrl;
    this.ws = null;
    this.reconnectAttempts = 0;
    this.maxReconnectAttempts = 5;
  }

  connect() {
    this.ws = new WebSocket(this.wsUrl);
    
    this.ws.onopen = () => {
      console.log('WebSocket connected');
      this.reconnectAttempts = 0;
    };

    this.ws.onmessage = (event) => {
      const update = JSON.parse(event.data);
      this.handleUpdate(update);
    };

    this.ws.onerror = (error) => {
      console.error('WebSocket error:', error);
    };

    this.ws.onclose = () => {
      this.reconnect();
    };
  }

  handleUpdate(update) {
    // Handle different update types
    switch(update.type) {
      case 'earthquake':
        this.updateEarthquakes(update.data);
        break;
      case 'weather':
        this.updateWeather(update.data);
        break;
      case 'infrastructure':
        this.updateInfrastructure(update.data);
        break;
    }
  }

  reconnect() {
    if (this.reconnectAttempts < this.maxReconnectAttempts) {
      this.reconnectAttempts++;
      setTimeout(() => this.connect(), 3000 * this.reconnectAttempts);
    }
  }
}
```

---

## Performance Optimization

### Lazy Loading & Virtualization
```javascript
// Only render visible markers
class MarkerCluster {
  constructor(map, markers) {
    this.map = map;
    this.markers = markers;
    this.clusters = [];
    this.clusterRadius = 80; // pixels
  }

  cluster() {
    // Group markers by proximity
    // Only render clusters visible in viewport
  }

  updateViewport() {
    const bounds = this.map.getBounds();
    // Only render clusters within bounds
  }
}
```

### Caching Strategy
```javascript
class DataCache {
  constructor() {
    this.cache = new Map();
    this.ttl = 5 * 60 * 1000; // 5 minutes
  }

  set(key, value) {
    this.cache.set(key, {
      value,
      timestamp: Date.now()
    });
  }

  get(key) {
    const item = this.cache.get(key);
    if (!item) return null;
    
    if (Date.now() - item.timestamp > this.ttl) {
      this.cache.delete(key);
      return null;
    }
    
    return item.value;
  }
}
```

---

## Continue Integration Examples

### Using Ctrl+I to Generate Code
```javascript
// Prompt: "ai: Create a function to cluster earthquake markers by magnitude and location"
// Result: Function with proper clustering logic, cache optimization

function clusterEarthquakesByMagnitude(earthquakes) {
  const clusters = new Map();
  earthquakes.forEach(eq => {
    const key = `${Math.floor(eq.magnitude)}_${Math.floor(eq.lat)}_${Math.floor(eq.lng)}`;
    if (!clusters.has(key)) {
      clusters.set(key, []);
    }
    clusters.get(key).push(eq);
  });
  return Array.from(clusters.values());
}
```

### Using Ctrl+L for Documentation
```
User: "ai: Explain the best approach to handle real-time earthquake data updates in the dashboard"
Expected: Detailed explanation of WebSocket vs polling, with recommendations
```

### Using Tab for Autocomplete
```javascript
// Type: "const stats = await updateDashboard"
// Tab autocompletes to: "const stats = await updateDashboardStatistics();"
```

---

## Testing Checklist

### Frontend Tests
- [ ] Map loads without errors
- [ ] Earthquake markers display correctly
- [ ] Weather radar overlay works
- [ ] Controls toggle layers on/off
- [ ] Time slider updates data
- [ ] Statistics update in real-time
- [ ] Responsive on mobile
- [ ] No console errors

### Backend Tests
- [ ] `/api/health` returns 200
- [ ] `/api/earthquakes` returns valid GeoJSON
- [ ] `/api/weather` returns radar data
- [ ] `/api/infrastructure` returns facility data
- [ ] WebSocket connects and streams data
- [ ] Rate limiting works
- [ ] Error recovery/retries function

### Performance Tests
- [ ] Dashboard loads in <2s
- [ ] Map interaction smooth (60fps)
- [ ] 1000+ markers render smoothly
- [ ] WebSocket updates <500ms latency
- [ ] Memory usage <200MB
- [ ] CPU usage <20% idle

---

## Deployment Workflow

### Step 1: Prepare Backend
```bash
# Create systemd service for geospatial agent
cat > ~/.config/systemd/user/geospatial-data-agent.service << 'EOF'
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

[Install]
WantedBy=default.target
EOF

# Enable and start
systemctl --user daemon-reload
systemctl --user enable geospatial-data-agent.service
systemctl --user start geospatial-data-agent.service
```

### Step 2: Deploy Frontend
```bash
# Copy files to portfolio deployment
cp -v geospatial-viz/* /var/www/portfolio/geospatial-viz/

# Verify permissions
chmod -R 644 /var/www/portfolio/geospatial-viz/*.{html,css,js}
chmod -R 755 /var/www/portfolio/geospatial-viz/
```

### Step 3: Verify Live
```bash
# Check backend
curl -s http://localhost:5100/api/health | jq .

# Check frontend
curl -s https://www.simondatalab.de/geospatial-viz/ | head -20

# Monitor logs
journalctl --user -u geospatial-data-agent.service -f
```

---

## Common Continue Prompts

```
// Code Generation
// ai: Create a function to calculate the impact radius of an earthquake
// ai: Add error handling and retry logic to the API calls
// ai: Optimize the marker clustering algorithm

// Documentation
// ai: Generate JSDoc comments for all functions
// ai: Create a README explaining the architecture
// ai: Write deployment instructions

// Refactoring
// ai: Extract the data fetching logic into a separate module
// ai: Convert var/let to const where possible
// ai: Implement error boundaries for React components

// Testing
// ai: Create unit tests for the utility functions
// ai: Write integration tests for API endpoints
// ai: Generate test data fixtures
```

---

## Success Criteria

All of these must be true before launch:
- [x] Architecture documented
- [ ] HTML structure created
- [ ] CSS styling complete (glassmorphism)
- [ ] Leaflet map integrated
- [ ] Earthquake markers rendering
- [ ] Weather radar overlay working
- [ ] Backend agent running (port 5100)
- [ ] WebSocket connection stable
- [ ] Statistics updating live
- [ ] Performance >60fps
- [ ] Responsive design tested
- [ ] Deployed to production
- [ ] No console errors
- [ ] Live at https://www.simondatalab.de/geospatial-viz/

---

## Next Steps

1. **Create HTML/CSS** (Phase 2)
   - Copy provided HTML template
   - Implement glassmorphism styling
   - Use Continue: `Ctrl+I "Add professional styling with no emojis"`

2. **Implement Leaflet Map** (Phase 2)
   - Initialize map container
   - Add tile layer
   - Integrate earthquake data
   - Use Continue: `Ctrl+Tab` for autocomplete on layer functions

3. **Create Backend Agent** (Phase 3)
   - Set up FastAPI server
   - Integrate USGS API
   - Implement WebSocket
   - Use Continue: `Ctrl+L "Design the data flow for real-time updates"`

4. **Deploy & Test** (Phase 4)
   - Create systemd service
   - Deploy to portfolio
   - Monitor live data
   - Use Continue: `Ctrl+I "Generate deployment scripts"`

---

**Ready to implement? Start with "Create index.html with glassmorphism styling"**

Use Continue liberally:
- `Ctrl+I` for code generation
- `Ctrl+L` for architecture discussions
- `Tab` for intelligent autocomplete
- Every function, every component

*Model: llama3.2:3b (local, deterministic with temperature 0.2-0.3)*
