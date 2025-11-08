/**
 * EPIC NEURAL TO COSMOS VISUALIZATION - ENHANCED
 * TRULY EPIC VERSION: Glowing particles, 3D globe, dramatic lighting, cosmic web
 * Journey: Neurons → Brain → Network (with globe) → Cosmos
 */

class EpicNeuralToCosmosVizEnhanced {
    constructor(containerId, options = {}) {
        this.containerId = containerId;
        this.options = {
            autoTransition: options.autoTransition !== false,
            transitionDuration: options.transitionDuration || 28000,
            particleCount: options.particleCount || 5000,
            enableInteraction: options.enableInteraction !== false,
            deferInit: options.deferInit || false,
            ...options
        };
        
        this.scene = null;
        this.camera = null;
        this.renderer = null;
        this.controls = null;
        this.composer = null; // Post-processing
        this.clock = new THREE.Clock();
        
        this.phases = {
            neuron: {},
            brain: {},
            network: {},
            cosmos: {}
        };
        
        this.currentPhase = 'neuron';
        this.transitionProgress = 0;
        this.isTransitioning = false;
        this.isMobile = /Mobi|Android/i.test(navigator.userAgent || '');
        this.reduceMotion = (typeof window !== 'undefined' && window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches) || false;
        
        if (!this.options.deferInit) {
            this.init();
        } else {
            console.info('[EpicVizEnhanced] Deferred initialization enabled');
        }
    }

    async runDeferredInit() {
        try {
            await this.setupThreeJS();
            await this.createPhases();
            this.setupPostProcessing();
            this.setupInteractions();
            this.startAnimation();
            
            if (this.options.autoTransition) {
                this.startAutoTransition();
            }
            
            console.log('✅ Enhanced epic visualization deferred initialization completed');
        } catch (error) {
            console.error('❌ Deferred initialization failed:', error);
            this.showFallback();
        }
    }
    
    async init() {
        console.log('🌌 Initializing Enhanced Epic Neural to Cosmos Visualization...');
        
        try {
            await this.setupThreeJS();
            await this.createPhases();
            this.setupPostProcessing();
            this.setupInteractions();
            this.startAnimation();
            
            if (this.options.autoTransition) {
                this.startAutoTransition();
            }
            
            console.log('✅ Enhanced epic visualization initialized successfully');
        } catch (error) {
            console.error('❌ Failed to initialize:', error);
            this.showFallback();
        }
    }
    
    async setupThreeJS() {
        const container = document.getElementById(this.containerId);
        if (!container) {
            throw new Error(`Container with id "${this.containerId}" not found`);
        }
        
        this.container = container;
        
        // Scene with deeper space feel
        this.scene = new THREE.Scene();
        this.scene.background = new THREE.Color(0x000005);
        this.scene.fog = new THREE.Fog(0x000005, 100, 500);
        
        // Camera
        this.camera = new THREE.PerspectiveCamera(
            65,
            container.clientWidth / container.clientHeight,
            0.1,
            3000
        );
        this.camera.position.set(0, 0, 60);
        this.cameraBaseZ = this.camera.position.z;
        
        // Advanced WebGL Renderer - with error handling
        let renderer;
        try {
            renderer = new THREE.WebGLRenderer({ 
                alpha: true, 
                antialias: true,
                powerPreference: "high-performance",
                precision: "highp"
            });
        } catch (err) {
            console.error('❌ Failed to create WebGL renderer (high-performance):', err);
            try {
                console.log('Trying fallback: default performance preference...');
                renderer = new THREE.WebGLRenderer({ 
                    alpha: true, 
                    antialias: false,
                    powerPreference: "default"
                });
            } catch (fallbackErr) {
                console.error('❌ Failed to create WebGL renderer (fallback):', fallbackErr);
                throw new Error('WebGL context unavailable - your browser may not support 3D graphics');
            }
        }
        
        this.renderer = renderer;
        this.renderer.setSize(container.clientWidth, container.clientHeight);
        this.renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
        
        // Enhanced tone mapping for glow effects
        this.renderer.outputEncoding = THREE.sRGBEncoding;
        this.renderer.toneMapping = THREE.ReinhardToneMapping;
        this.renderer.toneMappingExposure = 1.8;
        
        container.appendChild(this.renderer.domElement);
        
        if (this.options.enableInteraction) {
            this.setupControls();
        }
        
        this.setupLighting();
        window.addEventListener('resize', () => this.handleResize());
        
        console.log('✅ THREE.js setup completed');
    }
    
    setupControls() {
        if (THREE && THREE.OrbitControls) {
            this.controls = new THREE.OrbitControls(this.camera, this.renderer.domElement);
            this.controls.enableDamping = true;
            this.controls.dampingFactor = this.isMobile ? 0.08 : 0.05;
            this.controls.minDistance = 15;
            this.controls.maxDistance = 800;
            this.controls.autoRotate = !this.isMobile;
            this.controls.autoRotateSpeed = this.isMobile ? 0.3 : 0.6;
        }
    }
    
    setupLighting() {
        // Ambient light - subtle
        const ambientLight = new THREE.AmbientLight(0x0a0a2e, 0.2);
        this.scene.add(ambientLight);
        
        // Directional light for structure
        const directionalLight = new THREE.DirectionalLight(0x6495ed, 0.6);
        directionalLight.position.set(100, 100, 100);
        this.scene.add(directionalLight);
        
        // Cyan point light (left)
        this.cyanLight = new THREE.PointLight(0x00ffff, 3, 200);
        this.cyanLight.position.set(80, 40, 80);
        this.scene.add(this.cyanLight);
        
        // Magenta point light (right)
        this.magentaLight = new THREE.PointLight(0xff00ff, 3, 200);
        this.magentaLight.position.set(-80, 40, 80);
        this.scene.add(this.magentaLight);
        
        // Violet light (top)
        this.violetLight = new THREE.PointLight(0x9d4edd, 2, 150);
        this.violetLight.position.set(0, 100, 0);
        this.scene.add(this.violetLight);
    }
    
    setupPostProcessing() {
        if (!THREE.EffectComposer) {
            console.warn('EffectComposer not available, skipping post-processing');
            return;
        }
        
        try {
            this.composer = new THREE.EffectComposer(this.renderer);
            this.composer.addPass(new THREE.RenderPass(this.scene, this.camera));
            
            // Add bloom for glow effect if available
            if (THREE.UnrealBloomPass) {
                const bloomPass = new THREE.UnrealBloomPass(
                    new THREE.Vector2(window.innerWidth, window.innerHeight),
                    1.5,  // strength
                    0.4,  // radius
                    0.85  // threshold
                );
                this.composer.addPass(bloomPass);
            }
            
            console.log('✅ Post-processing setup completed');
        } catch (e) {
            console.warn('Post-processing setup failed:', e);
        }
    }
    
    async createPhases() {
        console.log('🎨 Creating enhanced phase systems...');
        
        await this.createNeuronPhase();
        await this.createBrainPhase();
        await this.createNetworkPhase();
        await this.createCosmosPhase();
        
        this.activatePhase('neuron');
    }
    
    async createNeuronPhase() {
        const phase = this.phases.neuron;
        
        // Individual neurons with strong glow
        const neuronCount = this._scaledCount(120, 40);
        const geometry = new THREE.BufferGeometry();
        const positions = new Float32Array(neuronCount * 3);
        const colors = new Float32Array(neuronCount * 3);
        const sizes = new Float32Array(neuronCount);
        
        for (let i = 0; i < neuronCount; i++) {
            const i3 = i * 3;
            
            // Organic radial distribution
            const radius = 8 + Math.random() * 25;
            const theta = Math.random() * Math.PI * 2;
            const phi = Math.random() * Math.PI;
            
            positions[i3] = radius * Math.sin(phi) * Math.cos(theta);
            positions[i3 + 1] = radius * Math.sin(phi) * Math.sin(theta);
            positions[i3 + 2] = radius * Math.cos(phi);
            
            // Electric cyan to bright blue
            const color = new THREE.Color().setHSL(0.55 + Math.random() * 0.1, 1.0, 0.6);
            colors[i3] = color.r;
            colors[i3 + 1] = color.g;
            colors[i3 + 2] = color.b;
            
            sizes[i] = 3 + Math.random() * 6;
        }
        
        geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
        geometry.attributes.position.setUsage(THREE.DynamicDrawUsage);
        geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));
        geometry.setAttribute('size', new THREE.BufferAttribute(sizes, 1));
        
        const material = new THREE.PointsMaterial({
            size: 1.5,
            vertexColors: true,
            transparent: true,
            opacity: 0.95,
            blending: THREE.AdditiveBlending,
            sizeAttenuation: true
        });
        
        phase.particleSystem = new THREE.Points(geometry, material);
        
        // Strong synaptic connections
        this.createNeuralConnections(phase, positions, neuronCount);
        
        console.log('✅ Enhanced neuron phase created');
    }
    
    createNeuralConnections(phase, positions, count) {
        const connections = [];
        const connectionCount = Math.floor(count * 3);
        
        const sharedMat = new THREE.LineBasicMaterial({
            color: 0x00ffff,
            transparent: true,
            opacity: 0.6,
            blending: THREE.AdditiveBlending,
            depthWrite: false,
            toneMapped: false,
            linewidth: 2
        });
        
        for (let i = 0; i < connectionCount; i++) {
            const startIdx = Math.floor(Math.random() * count) * 3;
            const endIdx = Math.floor(Math.random() * count) * 3;
            
            if (startIdx === endIdx) continue;
            
            const start = new THREE.Vector3(
                positions[startIdx],
                positions[startIdx + 1],
                positions[startIdx + 2]
            );
            
            const end = new THREE.Vector3(
                positions[endIdx],
                positions[endIdx + 1],
                positions[endIdx + 2]
            );
            
            const curve = new THREE.QuadraticBezierCurve3(
                start,
                new THREE.Vector3().addVectors(start, end).multiplyScalar(0.5).add(
                    new THREE.Vector3(
                        (Math.random() - 0.5) * 15,
                        (Math.random() - 0.5) * 15,
                        (Math.random() - 0.5) * 15
                    )
                ),
                end
            );
            
            const points = curve.getPoints(25);
            const geometry = new THREE.BufferGeometry().setFromPoints(points);
            
            const line = new THREE.Line(geometry, sharedMat);
            connections.push(line);
        }
        
        phase.connections = connections;
    }
    
    async createBrainPhase() {
        const phase = this.phases.brain;
        
        // Brain clusters with strong colors
        const clusterCount = this._scaledCountInt(12, 6);
        const neuronsPerCluster = this._scaledCountInt(40, 15);
        const totalNeurons = clusterCount * neuronsPerCluster;
        
        const geometry = new THREE.BufferGeometry();
        const positions = new Float32Array(totalNeurons * 3);
        const colors = new Float32Array(totalNeurons * 3);
        const sizes = new Float32Array(totalNeurons);
        
        let index = 0;
        
        for (let cluster = 0; cluster < clusterCount; cluster++) {
            const clusterRadius = 35;
            const clusterAngle = (cluster / clusterCount) * Math.PI * 2;
            const clusterHeight = (Math.random() - 0.5) * 30;
            
            const clusterCenter = new THREE.Vector3(
                Math.cos(clusterAngle) * clusterRadius,
                clusterHeight,
                Math.sin(clusterAngle) * clusterRadius
            );
            
            for (let n = 0; n < neuronsPerCluster; n++) {
                const i3 = index * 3;
                
                const localRadius = 4 + Math.random() * 12;
                const localTheta = Math.random() * Math.PI * 2;
                const localPhi = Math.random() * Math.PI;
                
                const localPos = new THREE.Vector3(
                    localRadius * Math.sin(localPhi) * Math.cos(localTheta),
                    localRadius * Math.sin(localPhi) * Math.sin(localTheta),
                    localRadius * Math.cos(localPhi)
                );
                
                localPos.add(clusterCenter);
                
                positions[i3] = localPos.x;
                positions[i3 + 1] = localPos.y;
                positions[i3 + 2] = localPos.z;
                
                // Vibrant region colors
                const regionHue = (cluster / clusterCount) * 1.0;
                const color = new THREE.Color().setHSL(regionHue, 0.9, 0.65);
                colors[i3] = color.r;
                colors[i3 + 1] = color.g;
                colors[i3 + 2] = color.b;
                
                sizes[index] = 2 + Math.random() * 4;
                index++;
            }
        }
        
        geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
        geometry.attributes.position.setUsage(THREE.DynamicDrawUsage);
        geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));
        geometry.setAttribute('size', new THREE.BufferAttribute(sizes, 1));
        
        const material = new THREE.PointsMaterial({
            size: 1.2,
            vertexColors: true,
            transparent: true,
            opacity: 0.9,
            blending: THREE.AdditiveBlending,
            sizeAttenuation: true
        });
        
        phase.particleSystem = new THREE.Points(geometry, material);
        
        this.createBrainConnections(phase, positions, totalNeurons, clusterCount, neuronsPerCluster);
        
        console.log('✅ Enhanced brain phase created');
    }
    
    createBrainConnections(phase, positions, totalCount, clusterCount, neuronsPerCluster) {
        const connections = [];
        
        const materialIntra = new THREE.LineBasicMaterial({
            color: 0x00ff88,
            transparent: true,
            opacity: 0.5,
            depthWrite: false,
            toneMapped: false
        });
        
        const materialInter = new THREE.LineBasicMaterial({
            color: 0xff00ff,
            transparent: true,
            opacity: 0.6,
            depthWrite: false,
            toneMapped: false
        });

        // Dense intra-cluster connections
        for (let cluster = 0; cluster < clusterCount; cluster++) {
            const clusterStart = cluster * neuronsPerCluster;
            const connectionCount = neuronsPerCluster * 3;
            
            for (let i = 0; i < connectionCount; i++) {
                const neuron1 = clusterStart + Math.floor(Math.random() * neuronsPerCluster);
                const neuron2 = clusterStart + Math.floor(Math.random() * neuronsPerCluster);
                
                if (neuron1 === neuron2) continue;
                
                const start = new THREE.Vector3(
                    positions[neuron1 * 3],
                    positions[neuron1 * 3 + 1],
                    positions[neuron1 * 3 + 2]
                );
                
                const end = new THREE.Vector3(
                    positions[neuron2 * 3],
                    positions[neuron2 * 3 + 1],
                    positions[neuron2 * 3 + 2]
                );
                
                const geometry = new THREE.BufferGeometry().setFromPoints([start, end]);
                connections.push(new THREE.Line(geometry, materialIntra));
            }
        }
        
        // Inter-cluster connections
        for (let i = 0; i < Math.floor(clusterCount * 8); i++) {
            const cluster1 = Math.floor(Math.random() * clusterCount);
            const cluster2 = Math.floor(Math.random() * clusterCount);
            
            if (cluster1 === cluster2) continue;
            
            const neuron1 = cluster1 * neuronsPerCluster + Math.floor(Math.random() * neuronsPerCluster);
            const neuron2 = cluster2 * neuronsPerCluster + Math.floor(Math.random() * neuronsPerCluster);
            
            const start = new THREE.Vector3(
                positions[neuron1 * 3],
                positions[neuron1 * 3 + 1],
                positions[neuron1 * 3 + 2]
            );
            
            const end = new THREE.Vector3(
                positions[neuron2 * 3],
                positions[neuron2 * 3 + 1],
                positions[neuron2 * 3 + 2]
            );
            
            const midPoint = new THREE.Vector3().addVectors(start, end).multiplyScalar(0.5);
            midPoint.add(new THREE.Vector3(
                (Math.random() - 0.5) * 40,
                (Math.random() - 0.5) * 40,
                (Math.random() - 0.5) * 40
            ));
            
            const curve = new THREE.QuadraticBezierCurve3(start, midPoint, end);
            const points = curve.getPoints(30);
            const geometry = new THREE.BufferGeometry().setFromPoints(points);
            
            connections.push(new THREE.Line(geometry, materialInter));
        }
        
        phase.connections = connections;
    }
    
    async createNetworkPhase() {
        const phase = this.phases.network;
        
        // Global network with dramatic visualization
        const nodeCount = this._scaledCountInt(400, 100);
        const geometry = new THREE.BufferGeometry();
        const positions = new Float32Array(nodeCount * 3);
        const colors = new Float32Array(nodeCount * 3);
        const sizes = new Float32Array(nodeCount);
        
        for (let i = 0; i < nodeCount; i++) {
            const i3 = i * 3;
            
            if (Math.random() > 0.25) {
                // Distributed network
                const radius = 50 + Math.random() * 100;
                const theta = Math.random() * Math.PI * 2;
                const phi = Math.random() * Math.PI;
                
                positions[i3] = radius * Math.sin(phi) * Math.cos(theta);
                positions[i3 + 1] = radius * Math.sin(phi) * Math.sin(theta);
                positions[i3 + 2] = radius * Math.cos(phi);
                
                const color = new THREE.Color().setHSL(0.1 + Math.random() * 0.2, 0.9, 0.65);
                colors[i3] = color.r;
                colors[i3 + 1] = color.g;
                colors[i3 + 2] = color.b;
                
                sizes[i] = 1.5 + Math.random() * 3;
            } else {
                // Data center clusters
                const centerIndex = Math.floor(Math.random() * 6);
                const centers = [
                    new THREE.Vector3(70, 0, 0),     // Americas
                    new THREE.Vector3(-70, 0, 0),    // Europe
                    new THREE.Vector3(0, 70, 0),     // Asia
                    new THREE.Vector3(0, -70, 0),    // Africa
                    new THREE.Vector3(0, 0, 70),     // Oceania
                    new THREE.Vector3(0, 0, -50)     // South Pole
                ];
                
                const center = centers[centerIndex];
                const localRadius = 8 + Math.random() * 20;
                const localTheta = Math.random() * Math.PI * 2;
                const localPhi = Math.random() * Math.PI;
                
                positions[i3] = center.x + localRadius * Math.sin(localPhi) * Math.cos(localTheta);
                positions[i3 + 1] = center.y + localRadius * Math.sin(localPhi) * Math.sin(localTheta);
                positions[i3 + 2] = center.z + localRadius * Math.cos(localPhi);
                
                const color = new THREE.Color().setHSL(0.0, 1.0, 0.7);
                colors[i3] = color.r;
                colors[i3 + 1] = color.g;
                colors[i3 + 2] = color.b;
                
                sizes[i] = 3 + Math.random() * 6;
            }
        }
        
        geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
        geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));
        geometry.setAttribute('size', new THREE.BufferAttribute(sizes, 1));
        
        const material = new THREE.PointsMaterial({
            size: 0.8,
            vertexColors: true,
            transparent: true,
            opacity: 0.95,
            blending: THREE.AdditiveBlending,
            sizeAttenuation: true
        });
        
        phase.particleSystem = new THREE.Points(geometry, material);
        
        // Create 3D Earth sphere
        this.createEarthGlobe(phase);
        
        // Network connections
        this.createNetworkConnections(phase, positions, nodeCount);
        
        console.log('✅ Enhanced network phase with globe created');
    }
    
    createEarthGlobe(phase) {
        // Create simple Earth sphere
        const geometry = new THREE.IcosahedronGeometry(25, 64);
        
        // Create canvas texture for Earth
        const canvas = document.createElement('canvas');
        canvas.width = 2048;
        canvas.height = 1024;
        const ctx = canvas.getContext('2d');
        
        // Ocean blue
        ctx.fillStyle = '#001a4d';
        ctx.fillRect(0, 0, canvas.width, canvas.height);
        
        // Continents
        ctx.fillStyle = '#003d00';
        ctx.fillRect(0, 300, 400, 200);     // North America
        ctx.fillRect(500, 250, 400, 250);   // Europe/Africa
        ctx.fillRect(1000, 200, 500, 400);  // Asia
        ctx.fillRect(200, 650, 300, 150);   // South America
        ctx.fillRect(1300, 600, 400, 200);  // Australia
        
        // City lights
        ctx.fillStyle = '#ffff99';
        const cities = [
            {x: 100, y: 350}, {x: 600, y: 300}, {x: 800, y: 350},
            {x: 1100, y: 280}, {x: 1300, y: 320}, {x: 250, y: 650}
        ];
        cities.forEach(city => {
            ctx.fillRect(city.x - 5, city.y - 5, 10, 10);
        });
        
        const texture = new THREE.CanvasTexture(canvas);
        texture.encoding = THREE.sRGBEncoding;
        
        const material = new THREE.MeshStandardMaterial({
            map: texture,
            emissive: 0x333333,
            emissiveIntensity: 0.5,
            metalness: 0.3,
            roughness: 0.7
        });
        
        const earth = new THREE.Mesh(geometry, material);
        earth.userData = { isEarth: true, rotationSpeed: 0.0001 };
        
        phase.earth = earth;
        console.log('✅ Earth globe created');
    }
    
    createNetworkConnections(phase, positions, nodeCount) {
        const connections = [];
        const connectionCount = Math.floor(nodeCount * 2);
        
        const sharedMat = new THREE.LineBasicMaterial({
            color: 0x00ff88,
            transparent: true,
            opacity: 0.4,
            depthWrite: false,
            toneMapped: false
        });
        
        for (let i = 0; i < connectionCount; i++) {
            const node1 = Math.floor(Math.random() * nodeCount);
            const node2 = Math.floor(Math.random() * nodeCount);
            
            if (node1 === node2) continue;
            
            const start = new THREE.Vector3(
                positions[node1 * 3],
                positions[node1 * 3 + 1],
                positions[node1 * 3 + 2]
            );
            
            const end = new THREE.Vector3(
                positions[node2 * 3],
                positions[node2 * 3 + 1],
                positions[node2 * 3 + 2]
            );
            
            const distance = start.distanceTo(end);
            if (distance > 80) continue;
            
            const geometry = new THREE.BufferGeometry().setFromPoints([start, end]);
            const line = new THREE.Line(geometry, sharedMat);
            line.userData = { dataFlow: Math.random(), flowSpeed: 1 + Math.random() * 3 };
            
            connections.push(line);
        }
        
        phase.connections = connections;
    }
    
    async createCosmosPhase() {
        const phase = this.phases.cosmos;
        
        // MASSIVE cosmic structure
        const cosmicNodeCount = this._scaledCountInt(1500, 400);
        const geometry = new THREE.BufferGeometry();
        const positions = new Float32Array(cosmicNodeCount * 3);
        const colors = new Float32Array(cosmicNodeCount * 3);
        const sizes = new Float32Array(cosmicNodeCount);
        
        for (let i = 0; i < cosmicNodeCount; i++) {
            const i3 = i * 3;
            
            let radius, theta, phi;
            
            if (Math.random() > 0.5) {
                // Cosmic web filaments
                const filamentAngle = Math.floor(Math.random() * 8) * (Math.PI / 4);
                radius = 120 + Math.random() * 280;
                theta = filamentAngle + (Math.random() - 0.5) * 0.8;
                phi = Math.PI / 2 + (Math.random() - 0.5) * 2;
                
                radius += (Math.random() - 0.5) * 40;
            } else {
                // Galaxy clusters
                radius = 150 + Math.random() * 200;
                theta = Math.random() * Math.PI * 2;
                phi = Math.random() * Math.PI;
            }
            
            positions[i3] = radius * Math.sin(phi) * Math.cos(theta);
            positions[i3 + 1] = radius * Math.sin(phi) * Math.sin(theta);
            positions[i3 + 2] = radius * Math.cos(phi);
            
            // Cosmic colors - deep and vibrant
            const colorType = Math.random();
            let color;
            
            if (colorType < 0.3) {
                // Star clusters - bright
                color = new THREE.Color().setHSL(0.15, 0.4, 0.95);
            } else if (colorType < 0.6) {
                // Nebulae - purple/magenta
                color = new THREE.Color().setHSL(0.8 + Math.random() * 0.15, 0.9, 0.7);
            } else if (colorType < 0.8) {
                // Cyan structures
                color = new THREE.Color().setHSL(0.5 + Math.random() * 0.1, 0.9, 0.65);
            } else {
                // Dark matter structures
                color = new THREE.Color().setHSL(0.6 + Math.random() * 0.15, 0.7, 0.5);
            }
            
            colors[i3] = color.r;
            colors[i3 + 1] = color.g;
            colors[i3 + 2] = color.b;
            
            sizes[i] = 0.8 + Math.random() * 4;
        }
        
        geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
        geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));
        geometry.setAttribute('size', new THREE.BufferAttribute(sizes, 1));
        
        const material = new THREE.PointsMaterial({
            size: 0.5,
            vertexColors: true,
            transparent: true,
            opacity: 0.9,
            blending: THREE.AdditiveBlending,
            sizeAttenuation: true
        });
        
        phase.particleSystem = new THREE.Points(geometry, material);
        
        // Cosmic web connections
        this.createCosmicConnections(phase, positions, cosmicNodeCount);
        
        console.log('✅ Enhanced cosmos phase created with massive cosmic web');
    }
    
    createCosmicConnections(phase, positions, nodeCount) {
        const connections = [];
        const connectionCount = Math.floor(nodeCount * 1.2);
        
        const sharedMat = new THREE.LineBasicMaterial({
            color: 0x6600ff,
            transparent: true,
            opacity: 0.25,
            depthWrite: false,
            toneMapped: false
        });
        
        for (let i = 0; i < connectionCount; i++) {
            const node1 = Math.floor(Math.random() * nodeCount);
            const node2 = Math.floor(Math.random() * nodeCount);
            
            if (node1 === node2) continue;
            
            const start = new THREE.Vector3(
                positions[node1 * 3],
                positions[node1 * 3 + 1],
                positions[node1 * 3 + 2]
            );
            
            const end = new THREE.Vector3(
                positions[node2 * 3],
                positions[node2 * 3 + 1],
                positions[node2 * 3 + 2]
            );
            
            const distance = start.distanceTo(end);
            if (distance > 180) continue;
            
            const geometry = new THREE.BufferGeometry().setFromPoints([start, end]);
            const line = new THREE.Line(geometry, sharedMat);
            line.userData = { cosmicEnergy: Math.random() };
            
            connections.push(line);
        }
        
        phase.connections = connections;
    }
    
    activatePhase(phaseName) {
        console.log(`🔄 Activating phase: ${phaseName}`);
        
        this.clearCurrentPhase();
        
        const phase = this.phases[phaseName];
        if (!phase) return;
        
        if (phase.particleSystem) {
            this.scene.add(phase.particleSystem);
        }
        
        if (phase.earth) {
            this.scene.add(phase.earth);
        }
        
        if (phase.connections) {
            phase.connections.forEach(connection => {
                this.scene.add(connection);
            });
        }
        
        this.currentPhase = phaseName;
        
        this.adjustCameraForPhase(phaseName);
        this.updateLightingForPhase(phaseName);
    }
    
    clearCurrentPhase() {
        Object.values(this.phases).forEach(phase => {
            if (phase.particleSystem && phase.particleSystem.parent) {
                this.scene.remove(phase.particleSystem);
            }
            
            if (phase.earth && phase.earth.parent) {
                this.scene.remove(phase.earth);
            }
            
            if (phase.connections) {
                phase.connections.forEach(connection => {
                    if (connection.parent) {
                        this.scene.remove(connection);
                    }
                });
            }
        });
    }
    
    adjustCameraForPhase(phaseName) {
        const cameraPositions = {
            neuron: { x: 0, y: 0, z: 40 },
            brain: { x: 0, y: 0, z: 110 },
            network: { x: 0, y: 0, z: 180 },
            cosmos: { x: 0, y: 0, z: 400 }
        };
        
        const targetPos = cameraPositions[phaseName];
        if (!targetPos) return;
        
        if (window.gsap) {
            gsap.to(this.camera.position, {
                duration: 4,
                x: targetPos.x,
                y: targetPos.y,
                z: targetPos.z,
                ease: "power2.inOut"
            });
        } else {
            this.camera.position.set(targetPos.x, targetPos.y, targetPos.z);
        }
    }
    
    updateLightingForPhase(phaseName) {
        const lightingConfigs = {
            neuron: { intensity1: 4, intensity2: 4, intensity3: 3 },
            brain: { intensity1: 3.5, intensity2: 3.5, intensity3: 2.5 },
            network: { intensity1: 3, intensity2: 3, intensity3: 2 },
            cosmos: { intensity1: 2.5, intensity2: 2.5, intensity3: 1.5 }
        };
        
        const config = lightingConfigs[phaseName];
        if (!config) return;
        
        if (window.gsap) {
            gsap.to([this.cyanLight, this.magentaLight], {
                duration: 2,
                intensity: config.intensity1,
                ease: "power2.out"
            });
            gsap.to(this.violetLight, {
                duration: 2,
                intensity: config.intensity3,
                ease: "power2.out"
            });
        }
    }
    
    setupInteractions() {
        if (!this.options.enableInteraction) return;
        
        window.addEventListener('keydown', (event) => {
            switch(event.key) {
                case '1':
                    this.transitionToPhase('neuron');
                    break;
                case '2':
                    this.transitionToPhase('brain');
                    break;
                case '3':
                    this.transitionToPhase('network');
                    break;
                case '4':
                    this.transitionToPhase('cosmos');
                    break;
                case ' ':
                    this.toggleAutoTransition();
                    break;
            }
        });
    }
    
    transitionToPhase(phaseName) {
        if (this.currentPhase === phaseName) return;
        
        this.isTransitioning = true;
        this.transitionProgress = 0;
        
        if (window.gsap) {
            gsap.to(this, {
                duration: 2,
                transitionProgress: 1,
                ease: "power2.inOut",
                onComplete: () => {
                    this.activatePhase(phaseName);
                    this.isTransitioning = false;
                }
            });
        } else {
            this.activatePhase(phaseName);
            this.isTransitioning = false;
        }
    }
    
    startAutoTransition() {
        if (this.autoTransitionTimer) return;
        
        const phases = ['neuron', 'brain', 'network', 'cosmos'];
        let currentIndex = 0;
        
        this.autoTransitionTimer = setInterval(() => {
            currentIndex = (currentIndex + 1) % phases.length;
            this.transitionToPhase(phases[currentIndex]);
        }, this.options.transitionDuration);
        
        console.log('🔄 Auto-transition started');
    }
    
    toggleAutoTransition() {
        if (this.autoTransitionTimer) {
            clearInterval(this.autoTransitionTimer);
            this.autoTransitionTimer = null;
            console.log('⏸️ Auto-transition paused');
        } else {
            this.startAutoTransition();
        }
    }

    _scaledCount(desktopCount, mobileCount) {
        if (this.reduceMotion) return Math.floor(mobileCount * 0.75);
        return this.isMobile ? mobileCount : desktopCount;
    }
    
    _scaledCountInt(desktopCount, mobileCount) {
        return Math.floor(this._scaledCount(desktopCount, mobileCount));
    }
    
    startAnimation() {
        this._targetFPS = 50;
        this._frameInterval = 1000 / this._targetFPS;
        this._lastFrameTime = performance.now();

        const loop = (now) => {
            if (document.hidden) {
                setTimeout(() => {
                    const schedule = window.optimizedRAF || requestAnimationFrame;
                    this.animationId = schedule(loop);
                }, 1000);
                return;
            }
            
            const elapsed = now - this._lastFrameTime;
            if (elapsed < this._frameInterval) {
                const schedule = window.optimizedRAF || requestAnimationFrame;
                this.animationId = schedule(loop);
                return;
            }

            this._lastFrameTime = now - (elapsed % this._frameInterval);
            this.animationId = null;

            const delta = this.clock.getDelta();
            const time = this.clock.elapsedTime;
            this.frameCount = (this.frameCount || 0) + 1;

            if (this.controls) {
                this.controls.update();
            }

            this.animatePhase(time);
            this.animateLights(time);
            this.animateConnections(time);

            // Render
            try {
                if (this.composer) {
                    this.composer.render();
                } else {
                    this.renderer.render(this.scene, this.camera);
                }
            } catch (e) {
                console.error('Render error:', e);
            }

            const schedule = window.optimizedRAF || requestAnimationFrame;
            this.animationId = schedule(loop);
        };

        const starter = window.optimizedRAF || requestAnimationFrame;
        this.animationId = starter(loop);
        console.log('✅ Animation started');
    }
    
    animatePhase(time) {
        const phase = this.phases[this.currentPhase];
        if (!phase) return;
        
        if (phase.particleSystem) {
            phase.particleSystem.rotation.x += 0.0001;
            phase.particleSystem.rotation.y += 0.0003;
            phase.particleSystem.rotation.z += 0.00015;
            
            // Pulsing effect
            const pulse = 1 + Math.sin(time * 1.5) * 0.15;
            phase.particleSystem.scale.setScalar(pulse);
        }
        
        // Rotate Earth globe
        if (phase.earth) {
            this.scene.add(phase.earth);
            phase.earth.rotation.y += phase.earth.userData.rotationSpeed;
            
            // Orbital motion
            const orbitAngle = time * 0.1;
            phase.earth.position.x = Math.cos(orbitAngle) * 50;
            phase.earth.position.z = Math.sin(orbitAngle) * 40;
        }
    }
    
    animateLights(time) {
        // Orbiting lights
        this.cyanLight.position.x = Math.sin(time * 0.3) * 100;
        this.cyanLight.position.z = Math.cos(time * 0.3) * 80;
        
        this.magentaLight.position.x = Math.cos(time * 0.4) * -100;
        this.magentaLight.position.z = Math.sin(time * 0.4) * 80;
        
        // Pulsing intensity
        const pulse = 1 + Math.sin(time * 2) * 0.3;
        this.cyanLight.intensity *= pulse * 0.3;
        this.magentaLight.intensity *= pulse * 0.3;
    }
    
    animateConnections(time) {
        const phase = this.phases[this.currentPhase];
        if (!phase || !phase.connections) return;
        
        const max = Math.min(100, phase.connections.length);
        for (let i = 0; i < max; i++) {
            const conn = phase.connections[i];
            const pulse = Math.sin(time * 2 + i * 0.1) * 0.2 + 0.6;
            if (conn.material && typeof conn.material.opacity === 'number') {
                conn.material.opacity = pulse;
            }
        }
    }
    
    handleResize() {
        const container = document.getElementById(this.containerId);
        if (!container) return;
        
        const width = container.clientWidth;
        const height = container.clientHeight;
        
        this.camera.aspect = width / height;
        this.camera.updateProjectionMatrix();
        this.renderer.setSize(width, height);
        
        if (this.composer) {
            this.composer.setSize(width, height);
        }
    }
    
    showFallback() {
        const container = document.getElementById(this.containerId);
        if (!container) return;
        
        container.innerHTML = `
            <div style="display: flex; align-items: center; justify-content: center; height: 100%; background: linear-gradient(135deg, #000005, #0a0520); color: #00ffff; text-align: center; padding: 2rem;">
                <div style="max-width: 500px;">
                    <div style="font-size: 4rem; margin-bottom: 1rem; animation: glow 2s infinite;">🌌</div>
                    <div style="font-size: 2rem; font-weight: 700; margin-bottom: 1rem;">Neural → Cosmos</div>
                    <div style="font-size: 1.2rem; opacity: 0.9;">Epic Visualization Loading...</div>
                </div>
            </div>
        `;
    }
    
    destroy() {
        if (this.animationId) {
            cancelAnimationFrame(this.animationId);
        }
        
        if (this.autoTransitionTimer) {
            clearInterval(this.autoTransitionTimer);
        }
        
        if (this.renderer) {
            this.renderer.dispose();
        }
        
        console.log('✅ Enhanced visualization destroyed');
    }
    
    getStats() {
        return {
            currentPhase: this.currentPhase,
            frameCount: this.frameCount || 0,
            isAutoTransitioning: !!this.autoTransitionTimer
        };
    }
    
    goToPhase(phaseName) {
        this.transitionToPhase(phaseName);
    }
    
    nextPhase() {
        const phases = ['neuron', 'brain', 'network', 'cosmos'];
        const currentIndex = phases.indexOf(this.currentPhase);
        const nextIndex = (currentIndex + 1) % phases.length;
        this.transitionToPhase(phases[nextIndex]);
    }
}

// Export
if (typeof module !== 'undefined' && module.exports) {
    module.exports = EpicNeuralToCosmosVizEnhanced;
} else {
    window.EpicNeuralToCosmosVizEnhanced = EpicNeuralToCosmosVizEnhanced;
}
