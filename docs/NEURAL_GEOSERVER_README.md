# 🌌 Neural GeoServer Visualization

A fully functional, GPU-accelerated Three.js + React Three Fiber 3D environment that transforms your GeoServer instance into a cinematic, interactive neural-spatial system.

## 🎯 Overview

This visualization renders GeoServer layers, requests, and collaborations as living neural structures connected through Earth-scale data pathways — a seamless blend of neuroscience-inspired visualization and real-time geospatial intelligence.

## ✨ Features

### Core Visualization
- **Neural Clusters**: GeoServer layers represented as 3D neuron clusters
- **Synaptic Connections**: Bezier curves connecting related layers with animated data flows
- **Earth Backdrop**: Real geospatial base with live WMS textures and atmospheric effects
- **Infrastructure Satellites**: Proxmox VM metrics displayed as orbital satellites

### Real-time Integration
- **GeoServer REST API**: Live data from `/rest/workspaces/{workspace}/layers.json`, `/rest/monitor/requests.json`, `/rest/about/status.json`
- **Dynamic Properties**: Layer type determines color, size reflects data volume, pulse rate shows query frequency
- **Data Flows**: Query traffic (WMS/WFS/WCS) as glowing impulses traveling along connections

### Interactive Features
- **Hover Effects**: Show GeoServer layer metadata via REST calls
- **Click Interactions**: Expand neuron clusters and preview layer thumbnails
- **Selection Tools**: Lasso/box selection triggers WFS GetFeature queries
- **Phase Transitions**: Micro → Meso → Macro → Cosmic view modes

### Performance Optimizations
- **GPU Acceleration**: High-performance rendering with WebGL optimizations
- **LOD System**: Level-of-detail management for optimal performance
- **Frustum Culling**: Only render visible objects
- **Instanced Meshes**: Efficient particle system rendering
- **Performance Monitoring**: Real-time FPS, memory, and draw call tracking

## 🏗️ Architecture

### File Structure
```
portfolio/hero-r3f-odyssey/
├── neural-geoserver-viz.js          # Main Three.js visualization class
├── neural-geoserver-r3f.jsx          # React Three Fiber components
├── neural-geoserver-styles.css       # Styling and animations
├── neural-geoserver-performance.js   # Performance optimization module
├── index.html                        # Updated HTML with neural GeoServer integration
└── deploy_neural_geoserver_local.sh  # Local deployment script
```

### Core Components

#### NeuralGeoServerViz Class
- Main visualization controller
- Handles Three.js scene setup, GeoServer API integration, and animation loops
- Manages neural clusters, synaptic connections, and infrastructure satellites

#### Performance Optimizer
- GPU acceleration configuration
- LOD (Level of Detail) management
- Frustum culling implementation
- Memory optimization and garbage collection

#### React Three Fiber Components
- `NeuralCluster`: Individual layer representations
- `SynapticConnection`: Animated connections between layers
- `EarthSphere`: 3D Earth with live textures
- `InfrastructureSatellite`: Proxmox VM representations
- `ParticleSystem`: GPU-accelerated particle effects

## 🚀 Installation & Usage

### Local Development
1. **Deploy Files**: Run the local deployment script
   ```bash
   ./deploy_neural_geoserver_local.sh
   ```

2. **Start Web Server**: Use any local web server
   ```bash
   # Python
   python -m http.server 8000
   
   # Node.js
   npx serve -p 8000
   
   # PHP
   php -S localhost:8000
   ```

3. **Access Visualization**: Open `http://localhost:8000/hero-r3f-odyssey/index.html`

### Production Deployment
```bash
# Using rsync
rsync -avz portfolio/ user@server:/var/www/html/

# Using scp
scp portfolio/* user@server:/var/www/html/

# Using git
git add . && git commit -m 'Deploy neural GeoServer viz' && git push
```

## 🔧 Configuration

### Initialization Options
```javascript
const viz = new NeuralGeoServerViz('hero-visualization', {
    geoserverUrl: 'https://www.simondatalab.de/geospatial-viz',
    proxmoxUrl: 'https://136.243.155.166:8006',
    particleCount: 10000,
    enableGPUAcceleration: true,
    enableLOD: true,
    enableFrustumCulling: true,
    updateInterval: 5000
});
```

### Performance Modes
```javascript
// High performance (20K particles, 4 LOD levels)
performanceOptimizer.setPerformanceMode('high');

// Medium performance (10K particles, 3 LOD levels)
performanceOptimizer.setPerformanceMode('medium');

// Low performance (5K particles, 2 LOD levels)
performanceOptimizer.setPerformanceMode('low');
```

## 🎮 Controls

### Keyboard Shortcuts
- `1`: Micro view (neural clusters)
- `2`: Meso view (data flows)
- `3`: Macro view (Earth-scale network)
- `4`: Cosmic view (distributed infrastructure)
- `R`: Reset camera position

### Mouse Interactions
- **Left Click**: Select and expand neural clusters
- **Hover**: Show layer metadata tooltips
- **Drag**: Orbit camera around the scene
- **Scroll**: Zoom in/out

## 📊 Performance Monitoring

### Real-time Stats
```javascript
const stats = viz.getStats();
console.log('Performance Stats:', stats.performance);
// {
//   fps: 60,
//   frameTime: 16.67,
//   memoryUsage: 45,
//   drawCalls: 150,
//   triangles: 50000,
//   geometries: 25,
//   textures: 10
// }
```

### Event System
```javascript
// Listen for performance updates
viz.on('performanceUpdate', (stats) => {
    console.log('FPS:', stats.fps);
    console.log('Memory:', stats.memoryUsage + 'MB');
});

// Listen for cluster interactions
viz.on('clusterClick', (data) => {
    console.log('Clicked layer:', data.layerData.name);
});
```

## 🌐 API Integration

### GeoServer Endpoints
- **Layers**: `/rest/layers.json` - Layer definitions and metadata
- **Requests**: `/rest/monitor/requests.json` - Real-time request monitoring
- **Status**: `/rest/about/status.json` - System status and health
- **Workspaces**: `/rest/workspaces.json` - Workspace information

### Proxmox Integration
- **VM Metrics**: CPU, memory, disk I/O from Proxmox API
- **Orbital Animation**: VMs as satellites orbiting Earth
- **Real-time Updates**: Metrics refresh every 5 seconds

## 🎨 Visual Design

### Color Scheme
- **Vector Layers**: Blue (`#0ea5e9`)
- **Raster Layers**: Green (`#10b981`)
- **WFS Layers**: Orange (`#f59e0b`)
- **WMS Layers**: Purple (`#8b5cf6`)
- **Unknown Types**: Gray (`#6b7280`)

### Animation Principles
- **Pulsing**: Neural clusters pulse based on query frequency
- **Flow**: Data flows animate along synaptic connections
- **Orbital**: Infrastructure satellites orbit Earth
- **Rotation**: Earth rotates slowly for spatial context

## 🔍 Troubleshooting

### Common Issues

#### Visualization Not Loading
1. Check browser console for errors
2. Verify Three.js is loaded: `typeof THREE !== 'undefined'`
3. Check GeoServer API connectivity
4. Ensure proper file permissions

#### Performance Issues
1. Reduce particle count: `particleCount: 5000`
2. Enable performance mode: `setPerformanceMode('low')`
3. Check GPU acceleration: `enableGPUAcceleration: true`
4. Monitor memory usage in browser dev tools

#### API Connection Problems
1. Verify GeoServer URL accessibility
2. Check CORS settings on GeoServer
3. Test REST endpoints manually
4. Check network connectivity

### Debug Mode
```javascript
// Enable debug logging
window.NeuralGeoServerViz.DEBUG = true;

// Monitor events
viz.on('error', (error) => {
    console.error('Visualization Error:', error);
});
```

## 📈 Future Enhancements

### Planned Features
- **WebSocket Integration**: Real-time data streaming
- **Advanced Interactions**: Multi-selection, drag-and-drop
- **Custom Shaders**: Advanced visual effects
- **Mobile Optimization**: Touch controls and responsive design
- **Export Functionality**: Screenshot and video recording

### Integration Opportunities
- **Moodle API**: User session visualization
- **Grafana Metrics**: Additional monitoring data
- **MLflow**: Model performance visualization
- **JupyterHub**: Notebook execution tracking

## 🤝 Contributing

### Development Setup
1. Clone the repository
2. Install dependencies: `npm install`
3. Start development server: `npm run dev`
4. Make changes and test locally
5. Deploy using deployment scripts

### Code Style
- Use ES6+ JavaScript features
- Follow Three.js best practices
- Implement proper error handling
- Add comprehensive comments
- Write performance-optimized code

## 📄 License

This project is part of the Learning Management System Academy and follows the same licensing terms.

## 🙏 Acknowledgments

- **Three.js**: 3D graphics library
- **React Three Fiber**: React integration for Three.js
- **GeoServer**: Open source geospatial server
- **Proxmox**: Virtualization platform
- **Neuroscience Inspiration**: Brain network visualization concepts

---

**🌌 From Neural Networks to Global Data Networks** - Transforming complex geospatial data into intuitive, interactive visualizations that bridge the gap between scientific precision and practical engineering.
