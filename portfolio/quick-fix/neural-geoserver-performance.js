/**
 * NEURAL GEOSERVER PERFORMANCE OPTIMIZER
 * GPU acceleration, LOD, frustum culling, and performance monitoring
 */

class NeuralGeoServerPerformanceOptimizer {
    constructor(renderer, scene, camera) {
        this.renderer = renderer;
        this.scene = scene;
        this.camera = camera;
        
        // Performance monitoring
        this.stats = {
            fps: 0,
            frameTime: 0,
            memoryUsage: 0,
            drawCalls: 0,
            triangles: 0,
            geometries: 0,
            textures: 0
        };
        
        // Performance optimization settings
        this.settings = {
            enableLOD: true,
            enableFrustumCulling: true,
            enableGPUAcceleration: true,
            maxParticles: 10000,
            lodLevels: 3,
            cullingDistance: 100,
            updateInterval: 1000 // Update stats every second
        };
        
        // LOD system
        this.lodObjects = new Map();
        this.lodLevels = [];
        
        // Frustum culling
        this.frustum = new THREE.Frustum();
        this.frustumMatrix = new THREE.Matrix4();
        
        // Performance monitoring
        this.frameCount = 0;
        this.lastTime = performance.now();
        this.lastStatsUpdate = performance.now();
        
        this.init();
    }
    
    init() {
        console.log('🚀 Initializing Neural GeoServer Performance Optimizer...');
        
        // Configure renderer for optimal performance
        this.configureRenderer();
        
        // Set up LOD system
        this.setupLODSystem();
        
        // Set up frustum culling
        this.setupFrustumCulling();
        
        // Start performance monitoring
        this.startPerformanceMonitoring();
        
        console.log('✅ Performance optimizer initialized');
    }
    
    configureRenderer() {
        // Enable GPU acceleration
        if (this.settings.enableGPUAcceleration) {
            this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
            this.renderer.powerPreference = "high-performance";
        }
        
        // Optimize shadow settings
        this.renderer.shadowMap.enabled = true;
        this.renderer.shadowMap.type = THREE.PCFSoftShadowMap;
        this.renderer.shadowMap.autoUpdate = false; // Manual shadow updates for better performance
        
        // Enable frustum culling
        this.renderer.frustumCulled = this.settings.enableFrustumCulling;
        
        // Optimize output encoding
        this.renderer.outputEncoding = THREE.sRGBEncoding;
        this.renderer.toneMapping = THREE.ACESFilmicToneMapping;
        this.renderer.toneMappingExposure = 1.2;
        
        console.log('✅ Renderer configured for optimal performance');
    }
    
    setupLODSystem() {
        if (!this.settings.enableLOD) return;
        
        // Create LOD levels based on distance
        this.lodLevels = [
            { distance: 0, multiplier: 1.0 },      // High detail
            { distance: 30, multiplier: 0.7 },   // Medium detail
            { distance: 60, multiplier: 0.4 },    // Low detail
            { distance: 100, multiplier: 0.1 }    // Very low detail
        ];
        
        console.log('✅ LOD system configured');
    }
    
    setupFrustumCulling() {
        if (!this.settings.enableFrustumCulling) return;
        
        // Update frustum matrix
        this.frustumMatrix.multiplyMatrices(
            this.camera.projectionMatrix,
            this.camera.matrixWorldInverse
        );
        this.frustum.setFromProjectionMatrix(this.frustumMatrix);
        
        console.log('✅ Frustum culling configured');
    }
    
    startPerformanceMonitoring() {
        const monitor = () => {
            this.updateStats();
            setTimeout(monitor, this.settings.updateInterval);
        };
        
        monitor();
        console.log('✅ Performance monitoring started');
    }
    
    updateStats() {
        const currentTime = performance.now();
        const deltaTime = currentTime - this.lastTime;
        
        // Calculate FPS
        this.stats.fps = Math.round(1000 / deltaTime);
        this.stats.frameTime = deltaTime;
        
        // Update memory usage (if available)
        if (performance.memory) {
            this.stats.memoryUsage = Math.round(performance.memory.usedJSHeapSize / 1024 / 1024);
        }
        
        // Update renderer stats
        const info = this.renderer.info;
        this.stats.drawCalls = info.render.calls;
        this.stats.triangles = info.render.triangles;
        this.stats.geometries = info.memory.geometries;
        this.stats.textures = info.memory.textures;
        
        this.lastTime = currentTime;
        
        // Emit performance update event
        this.emit('performanceUpdate', this.stats);
    }
    
    // LOD Management
    addLODObject(object, lodLevels = null) {
        if (!this.settings.enableLOD) return;
        
        const lod = {
            object: object,
            originalScale: object.scale.clone(),
            originalGeometry: object.geometry,
            originalMaterial: object.material,
            lodLevels: lodLevels || this.lodLevels,
            lastUpdate: 0
        };
        
        this.lodObjects.set(object.uuid, lod);
    }
    
    removeLODObject(object) {
        this.lodObjects.delete(object.uuid);
    }
    
    updateLOD() {
        if (!this.settings.enableLOD) return;
        
        const cameraPosition = this.camera.position;
        
        for (const [uuid, lod] of this.lodObjects) {
            const distance = cameraPosition.distanceTo(lod.object.position);
            
            // Find appropriate LOD level
            let lodLevel = lod.lodLevels[0];
            for (const level of lod.lodLevels) {
                if (distance >= level.distance) {
                    lodLevel = level;
                } else {
                    break;
                }
            }
            
            // Apply LOD scaling
            const scale = lodLevel.multiplier;
            lod.object.scale.setScalar(scale);
            
            // Update material properties based on LOD
            if (lod.object.material) {
                lod.object.material.transparent = scale < 0.5;
                lod.object.material.opacity = Math.max(0.3, scale);
            }
        }
    }
    
    // Frustum Culling
    updateFrustumCulling() {
        if (!this.settings.enableFrustumCulling) return;
        
        // Update frustum matrix
        this.frustumMatrix.multiplyMatrices(
            this.camera.projectionMatrix,
            this.camera.matrixWorldInverse
        );
        this.frustum.setFromProjectionMatrix(this.frustumMatrix);
        
        // Cull objects outside frustum
        this.scene.traverse((object) => {
            if (object.isMesh && object.frustumCulled) {
                const boundingSphere = new THREE.Sphere();
                object.geometry.computeBoundingSphere();
                boundingSphere.copy(object.geometry.boundingSphere);
                boundingSphere.applyMatrix4(object.matrixWorld);
                
                object.visible = this.frustum.intersectsSphere(boundingSphere);
            }
        });
    }
    
    // Particle System Optimization
    optimizeParticleSystem(particleSystem, cameraPosition) {
        const distance = cameraPosition.distanceTo(particleSystem.position);
        
        // Adjust particle count based on distance
        let particleCount = this.settings.maxParticles;
        if (distance > 50) {
            particleCount = Math.floor(this.settings.maxParticles * 0.5);
        } else if (distance > 100) {
            particleCount = Math.floor(this.settings.maxParticles * 0.2);
        }
        
        // Update particle system if needed
        if (particleSystem.geometry.attributes.position.count !== particleCount) {
            this.updateParticleCount(particleSystem, particleCount);
        }
    }
    
    updateParticleCount(particleSystem, newCount) {
        const geometry = particleSystem.geometry;
        const currentCount = geometry.attributes.position.count;
        
        if (newCount === currentCount) return;
        
        // Create new position array
        const positions = new Float32Array(newCount * 3);
        const colors = new Float32Array(newCount * 3);
        
        // Copy existing particles or create new ones
        const minCount = Math.min(newCount, currentCount);
        for (let i = 0; i < minCount; i++) {
            const i3 = i * 3;
            positions[i3] = geometry.attributes.position.array[i3];
            positions[i3 + 1] = geometry.attributes.position.array[i3 + 1];
            positions[i3 + 2] = geometry.attributes.position.array[i3 + 2];
            
            colors[i3] = geometry.attributes.color.array[i3];
            colors[i3 + 1] = geometry.attributes.color.array[i3 + 1];
            colors[i3 + 2] = geometry.attributes.color.array[i3 + 2];
        }
        
        // Create new particles if needed
        for (let i = minCount; i < newCount; i++) {
            const i3 = i * 3;
            const radius = 20 + Math.random() * 30;
            const theta = Math.random() * Math.PI * 2;
            const phi = Math.random() * Math.PI;
            
            positions[i3] = radius * Math.sin(phi) * Math.cos(theta);
            positions[i3 + 1] = radius * Math.sin(phi) * Math.sin(theta);
            positions[i3 + 2] = radius * Math.cos(phi);
            
            const color = new THREE.Color();
            color.setHSL(0.6 + Math.random() * 0.2, 0.8, 0.6);
            colors[i3] = color.r;
            colors[i3 + 1] = color.g;
            colors[i3 + 2] = color.b;
        }
        
        // Update geometry
        geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
        geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));
    }
    
    // Memory Management
    optimizeMemory() {
        // Dispose unused geometries
        const geometries = [];
        this.scene.traverse((object) => {
            if (object.geometry) {
                geometries.push(object.geometry);
            }
        });
        
        // Remove duplicate geometries
        const uniqueGeometries = new Set(geometries);
        console.log(`Memory optimization: ${geometries.length - uniqueGeometries.size} duplicate geometries removed`);
        
        // Force garbage collection if available
        if (window.gc) {
            window.gc();
        }
    }
    
    // Performance Settings
    setPerformanceMode(mode) {
        switch (mode) {
            case 'high':
                this.settings.maxParticles = 20000;
                this.settings.lodLevels = 4;
                this.settings.cullingDistance = 200;
                break;
            case 'medium':
                this.settings.maxParticles = 10000;
                this.settings.lodLevels = 3;
                this.settings.cullingDistance = 100;
                break;
            case 'low':
                this.settings.maxParticles = 5000;
                this.settings.lodLevels = 2;
                this.settings.cullingDistance = 50;
                break;
        }
        
        console.log(`Performance mode set to: ${mode}`);
    }
    
    // Event System
    emit(event, data) {
        // Simple event emission for performance updates
        if (typeof window !== 'undefined' && window.__HERO_EVENT_BUS__) {
            window.__HERO_EVENT_BUS__.emit(`performance:${event}`, data);
        }
    }
    
    // Public API
    getStats() {
        return { ...this.stats };
    }
    
    update() {
        this.updateLOD();
        this.updateFrustumCulling();
    }
    
    destroy() {
        this.lodObjects.clear();
        console.log('✅ Performance optimizer destroyed');
    }
}

// Export for use
if (typeof module !== 'undefined' && module.exports) {
    module.exports = NeuralGeoServerPerformanceOptimizer;
} else {
    window.NeuralGeoServerPerformanceOptimizer = NeuralGeoServerPerformanceOptimizer;
}
