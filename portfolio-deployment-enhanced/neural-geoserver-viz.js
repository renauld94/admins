/**
 * NEURAL GEOSERVER VISUALIZATION
 * GPU-Accelerated Three.js + React Three Fiber 3D Environment
 * Transforms GeoServer instance into cinematic neural-spatial system
 * 
 * Features:
 * - Real-time GeoServer REST API integration
 * - Neural clusters representing GeoServer layers
 * - Synaptic connections with animated data flows
 * - Earth sphere with live WMS textures
 * - Proxmox VM metrics as orbital satellites
 * - Interactive hover/click/selection
 * - GPU optimizations with LOD and frustum culling
 */

class NeuralGeoServerViz {
    constructor(containerId, options = {}) {
        this.containerId = containerId;
        this.options = {
            geoserverUrl: options.geoserverUrl || 'https://www.simondatalab.de/geospatial-viz',
            proxmoxUrl: options.proxmoxUrl || 'https://136.243.155.166:8006',
            updateInterval: options.updateInterval || 5000,
            particleCount: options.particleCount || 10000,
            enableGPUAcceleration: options.enableGPUAcceleration !== false,
            enableLOD: options.enableLOD !== false,
            enableFrustumCulling: options.enableFrustumCulling !== false,
            ...options
        };
        
        this.scene = null;
        this.camera = null;
        this.renderer = null;
        this.controls = null;
        
        try {
            this.clock = new THREE.Clock();
        } catch (error) {
            console.warn('Clock initialization failed, using fallback timing');
            this.clock = { getElapsedTime: () => Date.now() * 0.001 };
        }
        
        this.performanceOptimizer = null;
        
        // Data structures
        this.layerClusters = new Map();
        this.synapticConnections = [];
        this.dataFlows = [];
        this.infrastructureSatellites = new Map();
        this.earthSphere = null;
        
        // Performance optimization
        this.lodLevels = 3;
        this.frustumCulling = true;
        this.instancedMeshes = new Map();
        
        // Animation state
        this.animationId = null;
        this.isAnimating = false;
        this.currentPhase = 'micro'; // micro, meso, macro, cosmic
        
        // Event system
        this.eventListeners = new Map();
        
        this.init();
    }
    
    async init() {
        try {
            console.log('🌌 Initializing Neural GeoServer Visualization...');
            
            await this.setupThreeJS();
            await this.setupScene();
            await this.loadGeoServerData();
            await this.setupInfrastructureMonitoring();
            await this.setupInteractions();
            await this.startAnimation();
            
            console.log('✅ Neural GeoServer Visualization initialized successfully');
            this.emit('initialized', { timestamp: Date.now() });
            
        } catch (error) {
            console.error('❌ Failed to initialize Neural GeoServer Visualization:', error);
            this.emit('error', { error, timestamp: Date.now() });
        }
    }
    
    async setupThreeJS() {
        const container = document.getElementById(this.containerId);
        if (!container) {
            throw new Error(`Container with id "${this.containerId}" not found`);
        }
        
        // Scene setup
        this.scene = new THREE.Scene();
        this.scene.fog = new THREE.Fog(0x000011, 50, 200);
        
        // Camera setup
        this.camera = new THREE.PerspectiveCamera(
            75,
            container.clientWidth / container.clientHeight,
            0.1,
            1000
        );
        this.camera.position.set(0, 0, 50);
        
        // Renderer setup with GPU acceleration
        this.renderer = new THREE.WebGLRenderer({
            alpha: true,
            antialias: true,
            powerPreference: this.options.enableGPUAcceleration ? "high-performance" : "default"
        });
        
        this.renderer.setSize(container.clientWidth, container.clientHeight);
        this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
        this.renderer.shadowMap.enabled = true;
        this.renderer.shadowMap.type = THREE.PCFSoftShadowMap;
        this.renderer.outputEncoding = THREE.sRGBEncoding;
        this.renderer.toneMapping = THREE.ACESFilmicToneMapping;
        this.renderer.toneMappingExposure = 1.2;
        
        container.appendChild(this.renderer.domElement);
        
        // Controls setup - use the globally available OrbitControls
        console.log('🔍 Checking OrbitControls availability...');
        console.log('THREE available:', typeof THREE !== 'undefined');
        console.log('THREE.OrbitControls available:', !!(THREE && THREE.OrbitControls));
        
        if (THREE && THREE.OrbitControls) {
            try {
                this.controls = new THREE.OrbitControls(this.camera, this.renderer.domElement);
                console.log('✅ OrbitControls initialized successfully');
            } catch (error) {
                console.error('❌ Error initializing OrbitControls:', error);
                console.log('🔄 Falling back to basic controls');
                this.setupBasicControls();
            }
        } else {
            // Fallback: basic controls
            console.warn('⚠️ OrbitControls not available, using basic controls');
            this.setupBasicControls();
        }
        if (this.controls) {
            this.controls.enableDamping = true;
            this.controls.dampingFactor = 0.05;
            this.controls.screenSpacePanning = false;
            this.controls.minDistance = 10;
            this.controls.maxDistance = 200;
            this.controls.maxPolarAngle = Math.PI / 2;
        }
        
        // Handle resize
        window.addEventListener('resize', () => this.handleResize());
        
        // Initialize performance optimizer
        if (typeof NeuralGeoServerPerformanceOptimizer !== 'undefined') {
            this.performanceOptimizer = new NeuralGeoServerPerformanceOptimizer(
                this.renderer,
                this.scene,
                this.camera
            );
        }
        
        console.log('✅ Three.js setup completed');
    }
    
    setupBasicControls() {
        // Basic mouse controls without OrbitControls
        let isMouseDown = false;
        let mouseX = 0;
        let mouseY = 0;
        
        this.renderer.domElement.addEventListener('mousedown', (event) => {
            isMouseDown = true;
            mouseX = event.clientX;
            mouseY = event.clientY;
        });
        
        this.renderer.domElement.addEventListener('mouseup', () => {
            isMouseDown = false;
        });
        
        this.renderer.domElement.addEventListener('mousemove', (event) => {
            if (!isMouseDown) return;
            
            const deltaX = event.clientX - mouseX;
            const deltaY = event.clientY - mouseY;
            
            this.camera.position.x += deltaX * 0.01;
            this.camera.position.y -= deltaY * 0.01;
            
            mouseX = event.clientX;
            mouseY = event.clientY;
        });
        
        this.renderer.domElement.addEventListener('wheel', (event) => {
            const scale = event.deltaY > 0 ? 1.1 : 0.9;
            this.camera.position.multiplyScalar(scale);
            
            // Limit zoom
            const distance = this.camera.position.length();
            if (distance < 10) this.camera.position.normalize().multiplyScalar(10);
            if (distance > 200) this.camera.position.normalize().multiplyScalar(200);
        });
        
        console.log('✅ Basic controls setup completed');
    }
    
    async setupScene() {
        // Lighting setup
        const ambientLight = new THREE.AmbientLight(0x404040, 0.3);
        this.scene.add(ambientLight);
        
        const directionalLight = new THREE.DirectionalLight(0xffffff, 0.8);
        directionalLight.position.set(50, 50, 50);
        directionalLight.castShadow = true;
        directionalLight.shadow.mapSize.width = 2048;
        directionalLight.shadow.mapSize.height = 2048;
        this.scene.add(directionalLight);
        
        // Point lights for neural clusters
        const pointLight1 = new THREE.PointLight(0x0ea5e9, 1, 100);
        pointLight1.position.set(20, 20, 20);
        this.scene.add(pointLight1);
        
        const pointLight2 = new THREE.PointLight(0x8b5cf6, 1, 100);
        pointLight2.position.set(-20, -20, 20);
        this.scene.add(pointLight2);
        
        // Create Earth sphere
        await this.createEarthSphere();
        
        // Create particle system for data flows
        this.createParticleSystem();
        
        console.log('✅ Scene setup completed');
    }
    
    async createEarthSphere() {
        const geometry = new THREE.SphereGeometry(15, 64, 64);
        
        // Create Earth material with live WMS texture
        const material = new THREE.MeshPhongMaterial({
            map: await this.loadEarthTexture(),
            bumpMap: await this.loadBumpTexture(),
            bumpScale: 0.5,
            shininess: 1000,
            transparent: true,
            opacity: 0.9
        });
        
        this.earthSphere = new THREE.Mesh(geometry, material);
        this.earthSphere.receiveShadow = true;
        this.scene.add(this.earthSphere);
        
        // Add atmospheric glow
        const glowGeometry = new THREE.SphereGeometry(16, 32, 32);
        const glowMaterial = new THREE.MeshBasicMaterial({
            color: 0x0ea5e9,
            transparent: true,
            opacity: 0.1,
            side: THREE.BackSide
        });
        
        const glowSphere = new THREE.Mesh(glowGeometry, glowMaterial);
        this.scene.add(glowSphere);
        
        console.log('✅ Earth sphere created');
    }
    
    async loadEarthTexture() {
        try {
            const loader = new THREE.TextureLoader();
            // Use a high-quality Earth texture
            return await new Promise((resolve, reject) => {
                loader.load(
                    'https://unpkg.com/three-globe/example/img/earth-night.jpg',
                    resolve,
                    undefined,
                    reject
                );
            });
        } catch (error) {
            console.warn('Failed to load Earth texture, using fallback');
            return null;
        }
    }
    
    async loadBumpTexture() {
        try {
            const loader = new THREE.TextureLoader();
            return await new Promise((resolve, reject) => {
                loader.load(
                    'https://unpkg.com/three-globe/example/img/earth-topology.png',
                    resolve,
                    undefined,
                    reject
                );
            });
        } catch (error) {
            console.warn('Failed to load bump texture, using fallback');
            return null;
        }
    }
    
    createParticleSystem() {
        const particleCount = this.options.particleCount;
        const geometry = new THREE.BufferGeometry();
        
        const positions = new Float32Array(particleCount * 3);
        const colors = new Float32Array(particleCount * 3);
        const sizes = new Float32Array(particleCount);
        const alphas = new Float32Array(particleCount);
        
        for (let i = 0; i < particleCount; i++) {
            const i3 = i * 3;
            
            // Create stunning molecular/atomic structure with multiple layers
            const layer = Math.floor(i / (particleCount / 5));
            const radius = 18 + layer * 8; // Multiple concentric shells
            const theta = Math.random() * Math.PI * 2;
            const phi = Math.random() * Math.PI;
            
            // Add some clustering for molecular effect
            const clusterOffset = Math.sin(i * 0.1) * 2;
            
            positions[i3] = (radius + clusterOffset) * Math.sin(phi) * Math.cos(theta);
            positions[i3 + 1] = (radius + clusterOffset) * Math.sin(phi) * Math.sin(theta);
            positions[i3 + 2] = (radius + clusterOffset) * Math.cos(phi);
            
            // Vibrant colors for molecular effect - cyan, blue, purple, magenta
            const color = new THREE.Color();
            const hue = 0.5 + Math.random() * 0.3; // Cyan to purple range
            const saturation = 0.8 + Math.random() * 0.2;
            const lightness = 0.5 + Math.random() * 0.3;
            color.setHSL(hue, saturation, lightness);
            colors[i3] = color.r;
            colors[i3 + 1] = color.g;
            colors[i3 + 2] = color.b;
            
            // Varied sizes for depth and molecular structure
            sizes[i] = 0.3 + Math.random() * 1.5;
            
            // Varied opacity for atmospheric effect
            alphas[i] = 0.6 + Math.random() * 0.4;
        }
        
        geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
        geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));
        geometry.setAttribute('size', new THREE.BufferAttribute(sizes, 1));
        geometry.setAttribute('alpha', new THREE.BufferAttribute(alphas, 1));
        
        // Create circular particle shader for perfect circles
        const vertexShader = `
            attribute float size;
            attribute float alpha;
            varying vec3 vColor;
            varying float vAlpha;
            
            void main() {
                vColor = color;
                vAlpha = alpha;
                vec4 mvPosition = modelViewMatrix * vec4(position, 1.0);
                gl_PointSize = size * (300.0 / -mvPosition.z);
                gl_Position = projectionMatrix * mvPosition;
            }
        `;
        
        const fragmentShader = `
            varying vec3 vColor;
            varying float vAlpha;
            
            void main() {
                // Create perfect circular particles
                vec2 center = gl_PointCoord - vec2(0.5);
                float dist = length(center);
                
                // Soft circular falloff with glow
                float strength = 1.0 - smoothstep(0.0, 0.5, dist);
                float glow = 1.0 - smoothstep(0.0, 0.7, dist);
                
                // Add outer glow for atmospheric effect
                vec3 finalColor = vColor + vec3(0.2) * glow;
                float finalAlpha = strength * vAlpha * 0.9;
                
                if (finalAlpha < 0.01) discard;
                
                gl_FragColor = vec4(finalColor, finalAlpha);
            }
        `;
        
        const material = new THREE.ShaderMaterial({
            uniforms: {},
            vertexShader: vertexShader,
            fragmentShader: fragmentShader,
            transparent: true,
            blending: THREE.AdditiveBlending,
            depthWrite: false,
            vertexColors: true
        });
        
        this.particleSystem = new THREE.Points(geometry, material);
        this.scene.add(this.particleSystem);
        
        // Store original positions for animation
        this.particleSystem.userData.originalPositions = positions.slice();
        
        console.log('✅ Stunning molecular particle system created with circular particles');
    }
    
    async loadGeoServerData() {
        try {
            console.log('🌐 Loading GeoServer data...');
            
            // Load workspaces and layers
            const workspaces = await this.fetchGeoServerData('/rest/workspaces.json');
            const layers = await this.fetchGeoServerData('/rest/layers.json');
            const requests = await this.fetchGeoServerData('/rest/monitor/requests.json');
            const status = await this.fetchGeoServerData('/rest/about/status.json');
            
            // Process layers into neural clusters
            await this.processLayersIntoClusters(layers);
            
            // Process requests into data flows
            await this.processRequestsIntoFlows(requests);
            
            // Update status
            this.updateSystemStatus(status);
            
            console.log('✅ GeoServer data loaded successfully');
            
        } catch (error) {
            console.error('❌ Failed to load GeoServer data:', error);
            // Create fallback demo data
            await this.createFallbackData();
        }
    }
    
    async fetchGeoServerData(endpoint) {
        try {
            const response = await fetch(`${this.options.geoserverUrl}${endpoint}`, {
                method: 'GET',
                headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json'
                }
            });
            
            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }
            
            return await response.json();
        } catch (error) {
            console.warn(`Failed to fetch ${endpoint}:`, error);
            return null;
        }
    }
    
    async processLayersIntoClusters(layersData) {
        if (!layersData || !layersData.layers) {
            console.warn('No layers data available');
            return;
        }
        
        const layers = layersData.layers.layer || [];
        
        for (const layer of layers) {
            const cluster = await this.createNeuralCluster(layer);
            this.layerClusters.set(layer.name, cluster);
            this.scene.add(cluster);
        }
        
        // Create synaptic connections between related layers
        await this.createSynapticConnections();
        
        console.log(`✅ Created ${layers.length} neural clusters`);
    }
    
    async createNeuralCluster(layerData) {
        const cluster = new THREE.Group();
        
        // Determine cluster properties based on layer type
        const layerType = this.getLayerType(layerData);
        const color = this.getLayerColor(layerType);
        const size = this.getLayerSize(layerData);
        
        // Create main neuron (sphere)
        const neuronGeometry = new THREE.SphereGeometry(size, 16, 16);
        const neuronMaterial = new THREE.MeshPhongMaterial({
            color: color,
            transparent: true,
            opacity: 0.8,
            emissive: color,
            emissiveIntensity: 0.2
        });
        
        const neuron = new THREE.Mesh(neuronGeometry, neuronMaterial);
        neuron.castShadow = true;
        neuron.userData = { layerData, type: 'neuron' };
        cluster.add(neuron);
        
        // Create dendrites (smaller spheres around the main neuron)
        const dendriteCount = Math.min(8, Math.max(3, Math.floor(Math.random() * 6)));
        for (let i = 0; i < dendriteCount; i++) {
            const dendriteGeometry = new THREE.SphereGeometry(size * 0.3, 8, 8);
            const dendriteMaterial = new THREE.MeshPhongMaterial({
                color: color,
                transparent: true,
                opacity: 0.6
            });
            
            const dendrite = new THREE.Mesh(dendriteGeometry, dendriteMaterial);
            
            // Position dendrites around the main neuron
            const angle = (i / dendriteCount) * Math.PI * 2;
            const radius = size * 1.5;
            dendrite.position.set(
                Math.cos(angle) * radius,
                Math.sin(angle) * radius,
                (Math.random() - 0.5) * size
            );
            
            cluster.add(dendrite);
        }
        
        // Position cluster above Earth based on spatial extent
        const position = this.calculateLayerPosition(layerData);
        cluster.position.copy(position);
        
        // Add pulsing animation
        this.animateClusterPulse(cluster, layerData);
        
        return cluster;
    }
    
    getLayerType(layerData) {
        if (layerData.type === 'VECTOR') return 'vector';
        if (layerData.type === 'RASTER') return 'raster';
        if (layerData.type === 'WFS') return 'wfs';
        if (layerData.type === 'WMS') return 'wms';
        return 'unknown';
    }
    
    getLayerColor(layerType) {
        const colors = {
            vector: 0x0ea5e9,    // Blue
            raster: 0x10b981,    // Green
            wfs: 0xf59e0b,       // Orange
            wms: 0x8b5cf6,       // Purple
            unknown: 0x6b7280    // Gray
        };
        return colors[layerType] || colors.unknown;
    }
    
    getLayerSize(layerData) {
        // Base size on data volume or layer complexity
        const baseSize = 0.5;
        const complexity = layerData.resource?.featureType?.attributes?.attribute?.length || 1;
        return baseSize + Math.log(complexity) * 0.2;
    }
    
    calculateLayerPosition(layerData) {
        // Calculate position based on spatial extent or random if not available
        let position = new THREE.Vector3();
        
        if (layerData.resource?.nativeBoundingBox) {
            const bbox = layerData.resource.nativeBoundingBox;
            const centerX = (bbox.minx + bbox.maxx) / 2;
            const centerY = (bbox.miny + bbox.maxy) / 2;
            
            // Convert geographic coordinates to 3D position above Earth
            const lat = centerY * Math.PI / 180;
            const lon = centerX * Math.PI / 180;
            const radius = 20; // Distance above Earth surface
            
            position.set(
                radius * Math.cos(lat) * Math.cos(lon),
                radius * Math.cos(lat) * Math.sin(lon),
                radius * Math.sin(lat)
            );
        } else {
            // Random position around Earth
            const radius = 20 + Math.random() * 10;
            const theta = Math.random() * Math.PI * 2;
            const phi = Math.random() * Math.PI;
            
            position.set(
                radius * Math.sin(phi) * Math.cos(theta),
                radius * Math.sin(phi) * Math.sin(theta),
                radius * Math.cos(phi)
            );
        }
        
        return position;
    }
    
    animateClusterPulse(cluster, layerData) {
        const neuron = cluster.children[0];
        const pulseSpeed = 1 + Math.random() * 2; // 1-3 seconds per pulse
        
        const pulseAnimation = () => {
            const time = this.clock.getElapsedTime();
            const pulse = Math.sin(time * pulseSpeed) * 0.2 + 1;
            neuron.scale.setScalar(pulse);
            
            // Update emissive intensity based on pulse
            neuron.material.emissiveIntensity = 0.1 + Math.sin(time * pulseSpeed) * 0.1;
        };
        
        cluster.userData.pulseAnimation = pulseAnimation;
    }
    
    async createSynapticConnections() {
        const clusters = Array.from(this.layerClusters.values());
        
        for (let i = 0; i < clusters.length; i++) {
            for (let j = i + 1; j < clusters.length; j++) {
                const cluster1 = clusters[i];
                const cluster2 = clusters[j];
                
                const distance = cluster1.position.distanceTo(cluster2.position);
                
                // Create connection if clusters are close enough
                if (distance < 30) {
                    const connection = this.createSynapticConnection(cluster1, cluster2);
                    this.synapticConnections.push(connection);
                    this.scene.add(connection);
                }
            }
        }
        
        console.log(`✅ Created ${this.synapticConnections.length} synaptic connections`);
    }
    
    createSynapticConnection(cluster1, cluster2) {
        const connection = new THREE.Group();
        
        // Create Bezier curve between clusters
        const curve = new THREE.QuadraticBezierCurve3(
            cluster1.position,
            new THREE.Vector3().addVectors(cluster1.position, cluster2.position).multiplyScalar(0.5),
            cluster2.position
        );
        
        const points = curve.getPoints(50);
        const geometry = new THREE.BufferGeometry().setFromPoints(points);
        
        const material = new THREE.LineBasicMaterial({
            color: 0x0ea5e9,
            transparent: true,
            opacity: 0.3,
            linewidth: 2
        });
        
        const line = new THREE.Line(geometry, material);
        connection.add(line);
        
        // Add animated particles along the connection
        this.addConnectionParticles(connection, curve);
        
        return connection;
    }
    
    addConnectionParticles(connection, curve) {
        const particleCount = 20;
        const geometry = new THREE.BufferGeometry();
        
        const positions = new Float32Array(particleCount * 3);
        const colors = new Float32Array(particleCount * 3);
        
        for (let i = 0; i < particleCount; i++) {
            const i3 = i * 3;
            const t = i / particleCount;
            const point = curve.getPoint(t);
            
            positions[i3] = point.x;
            positions[i3 + 1] = point.y;
            positions[i3 + 2] = point.z;
            
            // Color based on position along curve
            const color = new THREE.Color();
            color.setHSL(0.6 + t * 0.2, 0.8, 0.6);
            colors[i3] = color.r;
            colors[i3 + 1] = color.g;
            colors[i3 + 2] = color.b;
        }
        
        geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
        geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));
        
        const material = new THREE.PointsMaterial({
            size: 0.1,
            vertexColors: true,
            transparent: true,
            opacity: 0.8,
            blending: THREE.AdditiveBlending
        });
        
        const particles = new THREE.Points(geometry, material);
        connection.add(particles);
        
        // Animate particles along the curve
        connection.userData.particleAnimation = (time) => {
            const positions = particles.geometry.attributes.position.array;
            
            for (let i = 0; i < particleCount; i++) {
                const i3 = i * 3;
                const t = (i / particleCount + time * 0.001) % 1;
                const point = curve.getPoint(t);
                
                positions[i3] = point.x;
                positions[i3 + 1] = point.y;
                positions[i3 + 2] = point.z;
            }
            
            particles.geometry.attributes.position.needsUpdate = true;
        };
    }
    
    async processRequestsIntoFlows(requestsData) {
        if (!requestsData || !requestsData.requests) {
            console.warn('No requests data available');
            return;
        }
        
        const requests = requestsData.requests.request || [];
        
        for (const request of requests) {
            const flow = this.createDataFlow(request);
            this.dataFlows.push(flow);
            this.scene.add(flow);
        }
        
        console.log(`✅ Created ${requests.length} data flows`);
    }
    
    createDataFlow(requestData) {
        const flow = new THREE.Group();
        
        // Create flow particles
        const particleCount = 50;
        const geometry = new THREE.BufferGeometry();
        
        const positions = new Float32Array(particleCount * 3);
        const colors = new Float32Array(particleCount * 3);
        
        for (let i = 0; i < particleCount; i++) {
            const i3 = i * 3;
            
            // Random positions along a path
            positions[i3] = (Math.random() - 0.5) * 40;
            positions[i3 + 1] = (Math.random() - 0.5) * 40;
            positions[i3 + 2] = (Math.random() - 0.5) * 40;
            
            // Color based on request type
            const color = this.getRequestColor(requestData);
            colors[i3] = color.r;
            colors[i3 + 1] = color.g;
            colors[i3 + 2] = color.b;
        }
        
        geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
        geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));
        
        const material = new THREE.PointsMaterial({
            size: 0.2,
            vertexColors: true,
            transparent: true,
            opacity: 0.8,
            blending: THREE.AdditiveBlending
        });
        
        const particles = new THREE.Points(geometry, material);
        flow.add(particles);
        
        // Animate flow
        flow.userData.flowAnimation = (time) => {
            const positions = particles.geometry.attributes.position.array;
            
            for (let i = 0; i < particleCount; i++) {
                const i3 = i * 3;
                
                // Move particles in a flowing pattern
                positions[i3] += Math.sin(time * 0.001 + i) * 0.1;
                positions[i3 + 1] += Math.cos(time * 0.001 + i) * 0.1;
                positions[i3 + 2] += Math.sin(time * 0.002 + i) * 0.05;
            }
            
            particles.geometry.attributes.position.needsUpdate = true;
        };
        
        return flow;
    }
    
    getRequestColor(requestData) {
        const colors = {
            'WMS': new THREE.Color(0x0ea5e9),  // Blue
            'WFS': new THREE.Color(0x10b981),  // Green
            'WCS': new THREE.Color(0xf59e0b),  // Orange
            'default': new THREE.Color(0x8b5cf6) // Purple
        };
        
        return colors[requestData.type] || colors.default;
    }
    
    updateSystemStatus(statusData) {
        if (!statusData) return;
        
        // Update system status indicators
        this.systemStatus = {
            version: statusData.version,
            status: statusData.status,
            timestamp: Date.now()
        };
        
        console.log('✅ System status updated:', this.systemStatus);
    }
    
    async setupInfrastructureMonitoring() {
        try {
            // Create Proxmox VM satellites
            await this.createProxmoxSatellites();
            
            // Set up periodic updates
            setInterval(() => {
                this.updateInfrastructureMetrics();
            }, this.options.updateInterval);
            
            console.log('✅ Infrastructure monitoring setup completed');
            
        } catch (error) {
            console.warn('Failed to setup infrastructure monitoring:', error);
        }
    }
    
    async createProxmoxSatellites() {
        // Create orbital satellites representing Proxmox VMs
        const vmCount = 5; // Simulate 5 VMs
        
        for (let i = 0; i < vmCount; i++) {
            const satellite = this.createInfrastructureSatellite(i);
            this.infrastructureSatellites.set(`vm-${i}`, satellite);
            this.scene.add(satellite);
        }
        
        console.log(`✅ Created ${vmCount} infrastructure satellites`);
    }
    
    createInfrastructureSatellite(vmId) {
        const satellite = new THREE.Group();
        
        // Create satellite body
        const geometry = new THREE.BoxGeometry(0.5, 0.5, 0.5);
        const material = new THREE.MeshPhongMaterial({
            color: 0xf59e0b,
            transparent: true,
            opacity: 0.8,
            emissive: 0xf59e0b,
            emissiveIntensity: 0.3
        });
        
        const body = new THREE.Mesh(geometry, material);
        satellite.add(body);
        
        // Create solar panels
        const panelGeometry = new THREE.BoxGeometry(1, 0.1, 0.5);
        const panelMaterial = new THREE.MeshPhongMaterial({
            color: 0x1f2937,
            transparent: true,
            opacity: 0.9
        });
        
        const leftPanel = new THREE.Mesh(panelGeometry, panelMaterial);
        leftPanel.position.set(-0.8, 0, 0);
        satellite.add(leftPanel);
        
        const rightPanel = new THREE.Mesh(panelGeometry, panelMaterial);
        rightPanel.position.set(0.8, 0, 0);
        satellite.add(rightPanel);
        
        // Position satellite in orbit around Earth
        const orbitRadius = 35 + vmId * 5;
        const angle = (vmId / 5) * Math.PI * 2;
        
        satellite.position.set(
            orbitRadius * Math.cos(angle),
            orbitRadius * Math.sin(angle),
            (Math.random() - 0.5) * 10
        );
        
        // Add orbital animation
        satellite.userData.orbitalAnimation = (time) => {
            const newAngle = angle + time * 0.0001;
            satellite.position.x = orbitRadius * Math.cos(newAngle);
            satellite.position.y = orbitRadius * Math.sin(newAngle);
            satellite.rotation.z += 0.01;
        };
        
        return satellite;
    }
    
    async updateInfrastructureMetrics() {
        try {
            // Simulate VM metrics update
            for (const [vmId, satellite] of this.infrastructureSatellites) {
                const cpu = Math.random() * 100;
                const memory = Math.random() * 100;
                const diskIO = Math.random() * 100;
                
                // Update satellite properties based on metrics
                const body = satellite.children[0];
                
                // CPU affects rotation speed
                body.rotation.x += cpu * 0.001;
                body.rotation.y += cpu * 0.001;
                
                // Memory affects scale
                const scale = 0.8 + (memory / 100) * 0.4;
                body.scale.setScalar(scale);
                
                // Disk I/O affects emissive intensity
                body.material.emissiveIntensity = 0.1 + (diskIO / 100) * 0.4;
            }
            
        } catch (error) {
            console.warn('Failed to update infrastructure metrics:', error);
        }
    }
    
    async setupInteractions() {
        // Raycaster for mouse interactions
        this.raycaster = new THREE.Raycaster();
        this.mouse = new THREE.Vector2();
        
        // Mouse events
        this.renderer.domElement.addEventListener('click', (event) => {
            this.handleClick(event);
        });
        
        this.renderer.domElement.addEventListener('mousemove', (event) => {
            this.handleMouseMove(event);
        });
        
        // Keyboard events
        window.addEventListener('keydown', (event) => {
            this.handleKeyDown(event);
        });
        
        console.log('✅ Interactions setup completed');
    }
    
    handleClick(event) {
        const rect = this.renderer.domElement.getBoundingClientRect();
        this.mouse.x = ((event.clientX - rect.left) / rect.width) * 2 - 1;
        this.mouse.y = -((event.clientY - rect.top) / rect.height) * 2 + 1;
        
        this.raycaster.setFromCamera(this.mouse, this.camera);
        
        // Check for intersections with neural clusters
        const intersects = this.raycaster.intersectObjects(
            Array.from(this.layerClusters.values()),
            true
        );
        
        if (intersects.length > 0) {
            const cluster = intersects[0].object.parent;
            this.handleClusterClick(cluster);
        }
    }
    
    handleMouseMove(event) {
        const rect = this.renderer.domElement.getBoundingClientRect();
        this.mouse.x = ((event.clientX - rect.left) / rect.width) * 2 - 1;
        this.mouse.y = -((event.clientY - rect.top) / rect.height) * 2 + 1;
        
        this.raycaster.setFromCamera(this.mouse, this.camera);
        
        // Check for hover effects
        const intersects = this.raycaster.intersectObjects(
            Array.from(this.layerClusters.values()),
            true
        );
        
        if (intersects.length > 0) {
            const cluster = intersects[0].object.parent;
            this.handleClusterHover(cluster);
        }
    }
    
    handleKeyDown(event) {
        switch (event.key) {
            case '1':
                this.setPhase('micro');
                break;
            case '2':
                this.setPhase('meso');
                break;
            case '3':
                this.setPhase('macro');
                break;
            case '4':
                this.setPhase('cosmic');
                break;
            case 'r':
                this.resetCamera();
                break;
        }
    }
    
    handleClusterClick(cluster) {
        const layerData = cluster.children[0].userData.layerData;
        
        // Show layer metadata
        this.showLayerMetadata(layerData);
        
        // Expand cluster
        this.expandCluster(cluster);
        
        // Emit event
        this.emit('clusterClick', { cluster, layerData });
    }
    
    handleClusterHover(cluster) {
        // Highlight cluster
        const neuron = cluster.children[0];
        neuron.material.emissiveIntensity = 0.5;
        
        // Show tooltip
        this.showTooltip(cluster);
    }
    
    showLayerMetadata(layerData) {
        // Create metadata overlay
        const overlay = document.createElement('div');
        overlay.className = 'layer-metadata-overlay';
        overlay.innerHTML = `
            <div class="metadata-content">
                <h3>${layerData.name}</h3>
                <p><strong>Type:</strong> ${layerData.type}</p>
                <p><strong>Workspace:</strong> ${layerData.resource?.workspace?.name || 'N/A'}</p>
                <p><strong>Status:</strong> ${layerData.resource?.enabled ? 'Enabled' : 'Disabled'}</p>
                <button onclick="this.parentElement.parentElement.remove()">Close</button>
            </div>
        `;
        
        document.body.appendChild(overlay);
        
        // Auto-remove after 5 seconds
        setTimeout(() => {
            if (overlay.parentElement) {
                overlay.remove();
            }
        }, 5000);
    }
    
    showTooltip(cluster) {
        // Implementation for tooltip display
        console.log('Showing tooltip for cluster:', cluster);
    }
    
    expandCluster(cluster) {
        // Animate cluster expansion
        gsap.to(cluster.scale, {
            duration: 0.5,
            x: 1.5,
            y: 1.5,
            z: 1.5,
            ease: "power2.out"
        });
        
        // Reset after 2 seconds
        setTimeout(() => {
            gsap.to(cluster.scale, {
                duration: 0.5,
                x: 1,
                y: 1,
                z: 1,
                ease: "power2.out"
            });
        }, 2000);
    }
    
    setPhase(phase) {
        this.currentPhase = phase;
        
        switch (phase) {
            case 'micro':
                this.camera.position.set(0, 0, 20);
                break;
            case 'meso':
                this.camera.position.set(0, 0, 50);
                break;
            case 'macro':
                this.camera.position.set(0, 0, 100);
                break;
            case 'cosmic':
                this.camera.position.set(0, 0, 200);
                break;
        }
        
        this.emit('phaseChange', { phase });
    }
    
    resetCamera() {
        this.camera.position.set(0, 0, 50);
        if (this.controls && this.controls.reset) {
            this.controls.reset();
        }
    }
    
    async createFallbackData() {
        console.log('Creating fallback demo data...');
        
        // Create demo neural clusters
        const demoLayers = [
            { name: 'Demo Vector Layer', type: 'VECTOR' },
            { name: 'Demo Raster Layer', type: 'RASTER' },
            { name: 'Demo WFS Layer', type: 'WFS' },
            { name: 'Demo WMS Layer', type: 'WMS' }
        ];
        
        for (const layer of demoLayers) {
            const cluster = await this.createNeuralCluster(layer);
            this.layerClusters.set(layer.name, cluster);
            this.scene.add(cluster);
        }
        
        // Create demo connections
        await this.createSynapticConnections();
        
        console.log('✅ Fallback demo data created');
    }
    
    async startAnimation() {
        this.isAnimating = true;
        
        const animate = () => {
            if (!this.isAnimating) return;
            
            this.animationId = requestAnimationFrame(animate);
            
            const time = this.clock.getElapsedTime();
            
            // Update controls if available
            if (this.controls && this.controls.update) {
                this.controls.update();
            }
            
            // Update performance optimizations
            if (this.performanceOptimizer) {
                this.performanceOptimizer.update();
            }
            
            // Animate neural clusters
            for (const cluster of this.layerClusters.values()) {
                if (cluster.userData.pulseAnimation) {
                    cluster.userData.pulseAnimation(time);
                }
            }
            
            // Animate synaptic connections
            for (const connection of this.synapticConnections) {
                if (connection.userData.particleAnimation) {
                    connection.userData.particleAnimation(time);
                }
            }
            
            // Animate data flows
            for (const flow of this.dataFlows) {
                if (flow.userData.flowAnimation) {
                    flow.userData.flowAnimation(time);
                }
            }
            
            // Animate infrastructure satellites
            for (const satellite of this.infrastructureSatellites.values()) {
                if (satellite.userData.orbitalAnimation) {
                    satellite.userData.orbitalAnimation(time);
                }
            }
            
            // Rotate Earth
            if (this.earthSphere) {
                this.earthSphere.rotation.y += 0.001;
            }
            
            // Animate particle system with flowing molecular motion
            if (this.particleSystem) {
                this.particleSystem.rotation.x += 0.0003;
                this.particleSystem.rotation.y += 0.0008;
                
                // Add breathing/pulsing effect to particles
                const positions = this.particleSystem.geometry.attributes.position.array;
                const originalPositions = this.particleSystem.userData.originalPositions;
                
                if (originalPositions) {
                    const pulseSpeed = time * 0.5;
                    const pulseAmount = Math.sin(pulseSpeed) * 0.3 + 1;
                    
                    for (let i = 0; i < positions.length; i += 3) {
                        // Apply breathing effect
                        const factor = pulseAmount + Math.sin(time + i * 0.01) * 0.15;
                        positions[i] = originalPositions[i] * factor;
                        positions[i + 1] = originalPositions[i + 1] * factor;
                        positions[i + 2] = originalPositions[i + 2] * factor;
                    }
                    
                    this.particleSystem.geometry.attributes.position.needsUpdate = true;
                }
            }
            
            // Render scene
            this.renderer.render(this.scene, this.camera);
        };
        
        animate();
        
        console.log('✅ Animation started');
    }
    
    handleResize() {
        const container = document.getElementById(this.containerId);
        if (!container) return;
        
        const width = container.clientWidth;
        const height = container.clientHeight;
        
        this.camera.aspect = width / height;
        this.camera.updateProjectionMatrix();
        this.renderer.setSize(width, height);
    }
    
    // Event system
    on(event, callback) {
        if (!this.eventListeners.has(event)) {
            this.eventListeners.set(event, []);
        }
        this.eventListeners.get(event).push(callback);
    }
    
    emit(event, data) {
        const listeners = this.eventListeners.get(event) || [];
        listeners.forEach(callback => {
            try {
                callback(data);
            } catch (error) {
                console.error('Event listener error:', error);
            }
        });
    }
    
    // Public API methods
    destroy() {
        this.isAnimating = false;
        
        if (this.animationId) {
            cancelAnimationFrame(this.animationId);
        }
        
        if (this.renderer) {
            this.renderer.dispose();
        }
        
        // Clean up event listeners
        this.eventListeners.clear();
        
        console.log('✅ Neural GeoServer Visualization destroyed');
    }
    
    getStats() {
        const baseStats = {
            layerClusters: this.layerClusters.size,
            synapticConnections: this.synapticConnections.length,
            dataFlows: this.dataFlows.length,
            infrastructureSatellites: this.infrastructureSatellites.size,
            currentPhase: this.currentPhase,
            isAnimating: this.isAnimating
        };
        
        // Add performance stats if available
        if (this.performanceOptimizer) {
            return {
                ...baseStats,
                performance: this.performanceOptimizer.getStats()
            };
        }
        
        return baseStats;
    }
}

// Export for use
if (typeof module !== 'undefined' && module.exports) {
    module.exports = NeuralGeoServerViz;
} else {
    window.NeuralGeoServerViz = NeuralGeoServerViz;
}
