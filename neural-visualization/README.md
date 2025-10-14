# Neural Consciousness → Cosmic Intelligence

A cinematic Three.js visualization that evolves through five metamorphoses: neuron → brain → brain-cluster → Earth-anchored network → cosmic satellite infrastructure. Built with React Three Fiber (r3f) for production-ready performance.

## 🎯 Overview

This visualization represents the journey from individual expertise to distributed systems intelligence, showcasing:

- **Scene 1 (0-15s)**: Individual neuron with organic membrane movement and ion channels
- **Scene 2 (15-30s)**: Brain hemisphere with 100k+ neurons and synchronized firing patterns  
- **Scene 3 (30-50s)**: Multiple brains connecting across domains with knowledge transfer
- **Scene 4 (50-75s)**: Brain network anchored to Earth with geographic data flows
- **Scene 5 (75-90s)**: Cosmic infrastructure with satellites representing services

## 🚀 Quick Start

### Prerequisites

- Node.js 18+ 
- npm or yarn
- Modern GPU with WebGL 2.0 support

### Installation

```bash
# Clone and install dependencies
cd neural-visualization
npm install

# Start development server
npm run dev

# Open http://localhost:3000
```

### Production Build

```bash
npm run build
npm run preview
```

## 🔧 Configuration

### Environment Variables

Create a `.env` file in the project root:

```env
# Real-time data integration (set to 'false' for mock mode)
VITE_MOCK_DATA=true

# WebSocket for real-time metrics
VITE_WEBSOCKET_URL=ws://vm106-geoneural10.0.0.1.11:8080

# Proxmox API for VM monitoring
VITE_PROXMOX_API_URL=https://vm106-geoneural10.0.0.1.11:8006

# GeoServer for Earth textures and WMS data
VITE_GEOSERVER_WMS_URL=http://vm106-geoneural10.0.0.1.11:8080/geoserver

# Moodle WebSocket for learning analytics
VITE_MOODLE_STATS_WS=ws://vm106-geoneural10.0.0.1.11:3001
```

### Real Data Integration

To connect to your actual infrastructure:

1. **Proxmox Integration**:
   ```bash
   # Set up Proxmox API token
   export PROXMOX_TOKEN="your-pve-api-token"
   ```

2. **GeoServer Integration**:
   - Ensure GeoServer is running on specified URL
   - WMS/WFS/WCS services should be accessible
   - Earth textures will be fetched from GeoServer

3. **Moodle Integration**:
   - WebSocket server should provide real-time learning analytics
   - Events: login, course_access, quiz_complete, etc.

4. **WebSocket Integration**:
   - Main WebSocket for system metrics
   - Provides CPU, memory, disk, network data
   - Real-time query monitoring

## 🎮 Controls

### Interactive Features

- **Scene Navigation**: Click numbered buttons to jump between scenes
- **Timeline Scrubber**: Drag to navigate through the 90-second loop
- **Playback Controls**: Play/pause and speed adjustment (0.5x - 2x)
- **Display Options**: Toggle scene overlays and performance stats
- **Click Interactions**: 
  - Click neurons for metadata
  - Click brain nodes for user profiles
  - Click satellites for VM/service stats

### Keyboard Shortcuts

- `Space`: Play/pause
- `1-5`: Jump to scenes
- `+/-`: Speed up/down
- `O`: Toggle overlay
- `P`: Toggle performance stats

## 🎨 Technical Architecture

### Core Technologies

- **React Three Fiber**: React renderer for Three.js
- **@react-three/drei**: Useful helpers and abstractions
- **@react-three/postprocessing**: Post-processing effects
- **GSAP**: Smooth camera transitions
- **GLSL Shaders**: Custom neural firing and atmosphere effects

### Performance Optimizations

- **GPU Instancing**: 100k+ neurons rendered efficiently
- **LOD System**: Progressive detail for distant objects
- **Frustum Culling**: Only render visible geometry
- **Particle Pooling**: Reuse particle objects
- **GPGPU**: GPU computation for particle states
- **Texture Atlasing**: Minimize draw calls

### Shader System

- **NeuralFiringShader**: Organic membrane movement with simplex noise
- **BrainwaveShader**: Synchronized firing patterns and wave propagation
- **EarthAtmosphereShader**: Rayleigh scattering and Fresnel effects
- **Particle Shaders**: Additive blending for ion channels and data flows

## 📊 Data Integration

### Real-time Metrics

The visualization consumes live data from multiple sources:

```typescript
interface SystemMetrics {
  cpu: number        // CPU usage percentage
  memory: number     // Memory usage percentage  
  disk: number       // Disk usage percentage
  network: number    // Network activity
}

interface GeoServerQuery {
  id: number
  type: 'WMS' | 'WFS' | 'WCS' | 'WPS'
  timestamp: number
  responseTime: number
}

interface MoodleEvent {
  id: number
  type: 'login' | 'course_access' | 'quiz_complete'
  user?: string
  course?: string
  score?: number
  timestamp: number
}
```

### WebSocket Protocol

```json
{
  "type": "system_metrics",
  "payload": {
    "cpu": 75.2,
    "memory": 68.4,
    "disk": 45.1,
    "network": 23.7
  }
}
```

## 🎬 Video Export

### Automated Export

```bash
# Export 90-second loop as MP4
npm run export

# This creates:
# - exports/frame_000000.png through frame_005399.png
# - Uses FFmpeg to combine into video
```

### Manual FFmpeg Export

```bash
# High quality export
ffmpeg -r 60 -i exports/frame_%06d.png \
  -c:v libx264 -pix_fmt yuv420p -crf 18 \
  -preset slow \
  neural_cosmic_visualization.mp4

# Web-optimized export  
ffmpeg -r 60 -i exports/frame_%06d.png \
  -c:v libx264 -pix_fmt yuv420p -crf 23 \
  -preset medium -movflags +faststart \
  neural_cosmic_visualization_web.mp4
```

## 🏗️ Project Structure

```
src/
├── components/           # Reusable UI components
│   ├── CameraController.tsx
│   ├── ControlsPanel.tsx
│   ├── LoadingScreen.tsx
│   ├── ParticleSystem.tsx
│   ├── PerformanceMonitor.tsx
│   ├── SceneManager.tsx
│   └── SceneOverlay.tsx
├── scenes/               # Individual scene components
│   ├── SceneNeuron.tsx
│   ├── SceneBrain.tsx
│   ├── SceneCluster.tsx
│   ├── SceneEarth.tsx
│   └── SceneOrbit.tsx
├── shaders/              # GLSL shader modules
│   ├── NeuralFiringShader.ts
│   ├── BrainwaveShader.ts
│   └── EarthAtmosphereShader.ts
├── hooks/                # Custom React hooks
│   └── useDataIntegration.ts
├── App.tsx              # Main application
└── main.tsx             # Entry point
```

## 🔍 Debugging

### Performance Monitoring

Enable performance stats to monitor:
- FPS (target: 60)
- Draw calls (target: <200)
- Triangle count (target: <50k)
- Memory usage

### Common Issues

1. **Low FPS**: Reduce particle count or disable post-processing
2. **WebGL Errors**: Check GPU compatibility and driver updates
3. **Memory Leaks**: Ensure proper cleanup in useEffect hooks
4. **Data Connection**: Verify WebSocket URLs and API tokens

### Debug Mode

```bash
# Enable debug logging
VITE_DEBUG=true npm run dev
```

## 🌐 Deployment

### Static Hosting

```bash
npm run build
# Deploy dist/ folder to any static host
```

### Docker Deployment

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["npm", "run", "preview"]
```

### CDN Integration

The visualization can be embedded in existing websites:

```html
<iframe 
  src="https://your-domain.com/neural-visualization"
  width="100%" 
  height="600px"
  frameborder="0">
</iframe>
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open Pull Request

### Development Guidelines

- Follow React Three Fiber best practices
- Optimize for 60 FPS performance
- Use TypeScript for type safety
- Write GLSL shaders with proper comments
- Test on multiple devices/browsers

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Three.js Community**: For the amazing WebGL framework
- **React Three Fiber**: For the React integration
- **GSAP**: For smooth animations
- **GeoServer**: For geospatial data services
- **Proxmox**: For virtualization platform
- **Moodle**: For learning management system

## 📞 Support

For questions or issues:
- Create an issue on GitHub
- Check the troubleshooting section
- Review the performance optimization guide

---

**"From neural networks to global data networks"** - A visualization of distributed intelligence systems.
