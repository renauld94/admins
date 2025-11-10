# PHASE 3: Three.js 3D Globe Implementation
## Replace Cesium with Modern Three.js (Temperature: 0.1)

---

## 🎯 OBJECTIVE

Replace the existing Cesium-based 3D globe (which has WebGL errors) with a high-performance **Three.js** implementation supporting 1000+ infrastructure nodes at 60fps.

**File**: `/home/simon/Learning-Management-System-Academy/globe-3d.html`
**Timeline**: 30 minutes
**Model**: Codestral 22B (12.6GB)
**Key Libraries**: Three.js, D3.js, WebGL

---

## STEP 1: Create New Three.js Globe Base

### Prompt for Ctrl+I

Create new file `/home/simon/Learning-Management-System-Academy/globe-3d.html` from scratch:

```
TASK: Create a complete Three.js 3D globe visualization

REQUIREMENTS:
1. Use Three.js for 3D rendering (no Cesium)
2. Globe parameters:
   - Radius: 100 units
   - Segments: 128x128 for smooth surface
   - Realistic Earth texture (NASA Blue Marble)
   - Slight atmosphere effect (outer glow)
   
3. Camera controls:
   - Orbital camera (mouse drag to rotate)
   - Scroll wheel to zoom (min 120, max 400 units distance)
   - Double-click to reset view
   - Smooth damping (0.05 factor)
   
4. Lighting:
   - Main light from sun position
   - Ambient light for night side
   - Spot light for atmospheric effect
   
5. Performance:
   - requestAnimationFrame for 60fps
   - Frustum culling enabled
   - LOD system for distant nodes
   
6. Container setup:
   - Full viewport (no header needed)
   - Dark background matching existing aesthetic
   - Responsive to window resize

EXTERNAL ASSETS:
- Three.js: https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js
- OrbitControls: https://cdn.jsdelivr.net/npm/three@0.128/examples/js/controls/OrbitControls.js
- Earth texture: https://cdn.jsdelivr.net/npm/three-globe@2.24/example/img/earth-blue-marble.jpg
```

**Expected Output**: ~400 lines (complete Three.js setup)

---

## STEP 2: Add Infrastructure Node Visualization

### Prompt for Ctrl+I

After Three.js initialization, add:

```
TASK: Visualize 25 infrastructure nodes on 3D globe with optimization

NODES DATA:
- 5 Healthcare nodes (Boston, Toronto, São Paulo, Tokyo, Singapore)
- 5 Research nodes (Geneva, Beijing, Sydney, London, San Francisco)
- 5 Data Centers (Frankfurt, Amsterdam, Dubai, Sydney, Singapore)
- 10 Coastal nodes (Miami, Rotterdam, Shanghai, Mumbai, Barcelona, Istanbul, LA, Hong Kong, Santos, Port Said)

VISUALIZATION:
1. Node markers:
   - Healthcare: Red (#ff6b6b), sphere radius 3 units
   - Research: Teal (#4ecdc4), sphere radius 3 units
   - Data Centers: Blue (#45b7d1), sphere radius 3 units
   - Coastal: Green (#96ceb4), sphere radius 3 units
   
2. Glow effects:
   - Each node has glowing halo (pointLight + emissive material)
   - Intensity: 0.8, distance: 20 units
   - Color matches node type
   
3. Animation:
   - Nodes pulse gently (sin curve, 2s period)
   - Pulsing amplitude: ±0.5 scale
   - Rotation synced with globe
   
4. Interactivity:
   - Hover over node: highlight (increase scale 1.2x, brightness +0.2)
   - Click node: show popup with name, type, stats
   - Popup auto-dismiss after 5 seconds or on click elsewhere
   
5. Performance optimization:
   - Use InstancedMesh for same-colored nodes
   - Frustum culling for off-screen nodes
   - LOD: simplify nodes when zoom > 300 units away
   - Max 60fps constant (use timeDelta for smooth motion)

NODE COORDINATES:
[See production data in index.html lines ~340-365]
```

**Expected Output**: ~300 lines (node rendering + interaction)

---

## STEP 3: Add Data Flow Animations

### Prompt for Ctrl+I

Add visualization of connections between nodes:

```
TASK: Animate data flow lines between connected infrastructure nodes

CONNECTIONS:
1. Create network graph:
   - Each healthcare node connects to nearest 2 research facilities
   - Each research facility connects to nearest 3 data centers
   - Data centers interconnected in mesh topology
   - Coastal nodes bridge to nearest data centers
   
2. Line rendering:
   - Use THREE.Line with custom shader
   - Base color: rgba(0, 212, 255, 0.3)
   - Width: 2 pixels
   - Dashed pattern optional
   
3. Data flow animation:
   - Particle-like glowing dots travel along lines
   - Speed: 5-15 units/sec (varies by line type)
   - Brightness varies with throughput (simulated)
   - Color: cyan → magenta gradient based on latency
   
4. Performance:
   - Use BufferGeometry for efficient rendering
   - Limit to 100 visible connections at a time
   - LOD: simplify at zoom levels
   - Update particle positions only when visible

VISUALIZATION EFFECT:
- Healthcare ↔ Research: green flow
- Research ↔ Data Center: blue flow  
- Data Center ↔ Coastal: cyan flow
- Inter-data-center: magenta flow (high priority)
```

**Expected Output**: ~250 lines (connection graph + animation)

---

## STEP 4: Add Real-Time Data Panel

### Prompt for Ctrl+I

Add HTML overlay with live statistics (similar to 2D dashboard):

```
TASK: Add real-time statistics panel overlay

HTML OVERLAY:
1. Top-left: Node statistics
   - Total Nodes: [count]
   - Active Connections: [count]
   - Global Throughput: [value] TB
   - Average Latency: [value] ms
   
2. Top-right: Selected node details (when hovering)
   - Node Name: [text]
   - Node Type: [category]
   - Connected To: [count]
   - Throughput: [value] MB/s
   - Status: Online/Offline
   
3. Bottom-left: Network statistics
   - Uptime: 99.9%
   - Total Data Transferred: [value] PB
   - Peak Throughput: [value] TB/s
   
4. Styling:
   - Dark semi-transparent background (glassmorphism)
   - Cyan accent borders
   - Font: same as 2D dashboard (Inter)
   - Responsive to node selection

5. Animations:
   - Stats update smoothly (animated numbers)
   - Transitions: 0.3s ease
   - Selected node panel slides in from side
```

**Expected Output**: ~150 lines (HTML + CSS overlay + JS sync)

---

## STEP 5: Add WebSocket Real-Time Integration

### Prompt for Ctrl+I

Connect 3D globe to backend WebSocket:

```
TASK: Integrate WebSocket for real-time 3D updates

WEBSOCKET CONNECTION:
1. Connect to: ws://localhost:8000/ws/realtime-3d
2. Message types:
   - node_update: {nodeId, status, throughput, latency}
   - connection_update: {connectionId, bandwidth, active}
   - earthquake: {lat, lng, magnitude, depth}
   
3. Node updates:
   - Update node color/brightness based on status
   - Animate node size change for throughput changes
   - Log all state changes

4. Earthquake visualization:
   - Add temporary marker at earthquake location
   - Pulse animation at magnitude intensity
   - Marker auto-removes after 30 seconds
   - Color: red for high magnitude, orange for low
   
5. Reconnection logic:
   - Auto-reconnect every 5 seconds if disconnected
   - Show connection status in bottom-right corner
   - Green dot = connected, red dot = disconnected, yellow = connecting

6. Error handling:
   - Log all WebSocket errors
   - Fallback to static data if WebSocket fails
   - Retry count displayed to user
```

**Expected Output**: ~180 lines (WebSocket handler)

---

## STEP 6: Add Navigation Controls

### Prompt for Ctrl+I

Create UI controls for globe navigation:

```
TASK: Add control panel for globe navigation and visualization options

CONTROLS (in fixed sidebar):
1. Navigation buttons:
   - "Center on World" (reset view)
   - "Healthcare Network" (zoom to healthcare nodes)
   - "Research Facilities" (zoom to research nodes)
   - "Data Centers" (zoom to data centers)
   - "Coastal Nodes" (zoom to coastal nodes)
   
2. Visibility toggles:
   - Show/hide nodes (category-based)
   - Show/hide data flows
   - Show/hide earthquakes
   - Show/hide network statistics
   
3. View options:
   - "Day/Night Mode" (switch lighting)
   - "Satellite View" (different texture)
   - "Wireframe Mode" (debug)
   - "Auto-rotate" (continuous globe spin)
   
4. Performance display:
   - FPS counter (top-right corner)
   - Node count
   - Connection count
   - Memory usage (if available)

5. Styling:
   - Glassmorphism buttons (consistent with 2D)
   - Tooltip on hover
   - Keyboard shortcuts displayed

KEYBOARD SHORTCUTS:
- '1' - Healthcare
- '2' - Research
- '3' - Data Centers
- '4' - Coastal
- 'w' - Toggle wireframe
- 'r' - Auto-rotate
- 'Home' - Reset view
- 'h' - Go to 2D dashboard
```

**Expected Output**: ~200 lines (controls + handlers + styling)

---

## STEP 7: Testing & Optimization

### Final Checks

Use **Ctrl+L** to chat:

```
Performance optimization checklist for Three.js globe:
1. What's the current frame rate?
2. How many draw calls per frame?
3. Memory usage estimate?
4. Suggestions for mobile optimization?
5. Is the WebSocket sync causing lag?
6. Should we use WebWorkers for data parsing?
```

---

## ✅ SUCCESS CRITERIA

Your Three.js globe should have:

- ✅ Smooth rotating Earth (no WebGL errors like Cesium)
- ✅ 25+ infrastructure nodes with color-coded categories
- ✅ Pulsing animation on all nodes
- ✅ Glowing data flow lines between connected nodes
- ✅ Particle animations traveling along connections
- ✅ Real-time statistics panel (top-left corner)
- ✅ Selected node details panel (appears on hover)
- ✅ WebSocket connection for live updates
- ✅ Navigation controls (zoom to categories, reset)
- ✅ **60 FPS constant** (way better than Cesium)
- ✅ Responsive design (works on tablets)
- ✅ <2MB JavaScript payload (optimized)

---

## 🔗 LINK BETWEEN 2D & 3D

Add navigation at top of both files:

**In index.html** (2D):
```html
<a href="globe-3d.html" onclick="switchTo3D()">Switch to 3D Globe</a>
```

**In globe-3d.html** (3D):
```html
<a href="index.html" onclick="switchTo2D()">Back to 2D Map</a>
```

---

## 📊 PHASE 3 TIMELINE

| Task | Time | Status |
|------|------|--------|
| Three.js base setup | 5 min | Ready |
| Node visualization | 7 min | Ready |
| Data flow animation | 6 min | Ready |
| Real-time panel | 4 min | Ready |
| WebSocket integration | 4 min | Ready |
| Navigation controls | 3 min | Ready |
| Testing & optimization | 1 min | Ready |
| **TOTAL** | **30 min** | ✅ |

---

## 🚀 NEXT PHASE (Phase 4)

Once Phase 3 complete:

**Phase 4**: Build FastAPI Backend Agent
- Create `geospatial_data_agent.py`
- Integrate Qwen2.5:7b for data analysis
- WebSocket server for real-time streaming
- Time: 45 minutes

---

## 💾 SAVE & COMMIT

```bash
cd /home/simon/Learning-Management-System-Academy
git add globe-3d.html
git commit -m "Phase 3: Three.js 3D globe with infrastructure nodes, data flow animations, real-time WebSocket sync"
```

---

**Status**: 🟢 Ready to begin Phase 3. Use Ctrl+I to create new globe-3d.html!
