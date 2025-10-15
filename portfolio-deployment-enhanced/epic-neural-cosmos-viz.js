/**
 * EPIC NEURAL TO COSMOS VISUALIZATION
 * A journey from microscopic neurons to cosmic data networks
 * Inspired by the scale of intelligence across the universe
 */

class EpicNeuralToCosmosViz {
    constructor(containerId, options = {}) {
        this.containerId = containerId;
        this.options = {
            autoTransition: options.autoTransition !== false,
            transitionDuration: options.transitionDuration || 15000, // 15 seconds per phase
            particleCount: options.particleCount || 5000,
            enableInteraction: options.enableInteraction !== false,
            ...options
        };
        
        // Scene components
        this.scene = null;
        this.camera = null;
        this.renderer = null;
        this.controls = null;
        this.clock = new THREE.Clock();
        
        // Animation state
        this.currentPhase = 'neuron'; // neuron -> brain -> network -> cosmos
        this.transitionProgress = 0;
        this.isTransitioning = false;
        this.animationId = null;
        
        // Phase systems
        this.phases = {
            neuron: { particles: [], connections: [], scale: 1 },
            brain: { particles: [], connections: [], scale: 10 },
            network: { particles: [], connections: [], scale: 100 },
            cosmos: { particles: [], connections: [], scale: 1000 }
        };
        
        // Visual elements
        this.particleSystem = null;
        this.connectionSystem = null;
        this.backgroundSphere = null;
        this.dataFlows = [];
        
        // Performance
        this.frameCount = 0;
        
        this.init();
    }
    
    async init() {
        console.log('🌌 Initializing Epic Neural to Cosmos Visualization...');
        
        try {
            await this.setupThreeJS();
            await this.createPhases();
            this.setupPostProcessing();
            this.setupInteractions();
            this.startAnimation();
            
            if (this.options.autoTransition) {
                this.startAutoTransition();
            }
            
            console.log('✅ Epic visualization initialized successfully');
            
        } catch (error) {
            console.error('❌ Failed to initialize Epic visualization:', error);
            this.showFallback();
        }
    }
    
    async setupThreeJS() {
        const container = document.getElementById(this.containerId);
        if (!container) {
            throw new Error(`Container with id "${this.containerId}" not found`);
        }
        
        // Scene
        this.scene = new THREE.Scene();
        this.scene.background = new THREE.Color(0x000008);
        this.scene.fog = new THREE.Fog(0x000008, 50, 300);
        
        // Camera
        this.camera = new THREE.PerspectiveCamera(
            60,
            container.clientWidth / container.clientHeight,
            0.1,
            2000
        );
        this.camera.position.set(0, 0, 50);
        
        // Renderer with advanced features
        this.renderer = new THREE.WebGLRenderer({ 
            alpha: true, 
            antialias: true,
            powerPreference: "high-performance"
        });
        
        this.renderer.setSize(container.clientWidth, container.clientHeight);
        this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
        this.renderer.outputEncoding = THREE.sRGBEncoding;
        this.renderer.toneMapping = THREE.ACESFilmicToneMapping;
        this.renderer.toneMappingExposure = 1.2;
        
        container.appendChild(this.renderer.domElement);
        
        // Controls
        if (this.options.enableInteraction) {
            this.setupControls();
        }
        
        // Lighting for dramatic effect
        this.setupLighting();
        
        // Handle resize
        window.addEventListener('resize', () => this.handleResize());
        
        console.log('✅ THREE.js setup completed');
    }
    
    setupControls() {
        if (THREE && THREE.OrbitControls) {
            this.controls = new THREE.OrbitControls(this.camera, this.renderer.domElement);
            this.controls.enableDamping = true;
            this.controls.dampingFactor = 0.05;
            this.controls.minDistance = 10;
            this.controls.maxDistance = 500;
            this.controls.autoRotate = true;
            this.controls.autoRotateSpeed = 0.5;
        }
    }
    
    setupLighting() {
        // Ambient light for base illumination
        const ambientLight = new THREE.AmbientLight(0x1e1e3a, 0.3);
        this.scene.add(ambientLight);
        
        // Directional light for structure
        const directionalLight = new THREE.DirectionalLight(0x4a90e2, 0.8);
        directionalLight.position.set(50, 50, 50);
        this.scene.add(directionalLight);
        
        // Point lights for neural activity
        const pointLight1 = new THREE.PointLight(0x00ffff, 2, 100);
        pointLight1.position.set(30, 0, 0);
        this.scene.add(pointLight1);
        
        const pointLight2 = new THREE.PointLight(0xff00aa, 2, 100);
        pointLight2.position.set(-30, 0, 0);
        this.scene.add(pointLight2);
        
        // Pulsing lights for cosmic effect
        this.cosmicLights = [pointLight1, pointLight2];
    }
    
    async createPhases() {
        console.log('🧠 Creating phase systems...');
        
        // Create each phase with unique characteristics
        await this.createNeuronPhase();
        await this.createBrainPhase();
        await this.createNetworkPhase();
        await this.createCosmosPhase();
        
        // Start with neuron phase
        this.activatePhase('neuron');
    }
    
    async createNeuronPhase() {
        const phase = this.phases.neuron;
        
        // Individual neuron with dendrites and synapses
        const neuronCount = 50;
        const geometry = new THREE.BufferGeometry();
        const positions = new Float32Array(neuronCount * 3);
        const colors = new Float32Array(neuronCount * 3);
        const sizes = new Float32Array(neuronCount);
        
        for (let i = 0; i < neuronCount; i++) {
            const i3 = i * 3;
            
            // Organic, tree-like distribution
            const radius = 5 + Math.random() * 15;
            const theta = Math.random() * Math.PI * 2;
            const phi = Math.random() * Math.PI;
            
            positions[i3] = radius * Math.sin(phi) * Math.cos(theta);
            positions[i3 + 1] = radius * Math.sin(phi) * Math.sin(theta);
            positions[i3 + 2] = radius * Math.cos(phi);
            
            // Neuron colors - electric blue to cyan
            const hue = 0.5 + Math.random() * 0.2; // Blue-cyan range
            const color = new THREE.Color().setHSL(hue, 0.9, 0.7);
            colors[i3] = color.r;
            colors[i3 + 1] = color.g;
            colors[i3 + 2] = color.b;
            
            sizes[i] = 2 + Math.random() * 3;
        }
        
        geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
        geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));
        geometry.setAttribute('size', new THREE.BufferAttribute(sizes, 1));
        
        const material = new THREE.PointsMaterial({
            size: 1,
            vertexColors: true,
            transparent: true,
            opacity: 0.9,
            blending: THREE.AdditiveBlending,
            sizeAttenuation: true
        });
        
        phase.particleSystem = new THREE.Points(geometry, material);
        
        // Create neural connections (synapses)
        this.createNeuralConnections(phase, positions, neuronCount);
        
        console.log('✅ Neuron phase created');
    }
    
    createNeuralConnections(phase, positions, count) {
        const connections = [];
        const connectionCount = count * 2; // Multiple connections per neuron
        
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
            
            // Create curved connection (synapse)
            const curve = new THREE.QuadraticBezierCurve3(
                start,
                new THREE.Vector3().addVectors(start, end).multiplyScalar(0.5).add(
                    new THREE.Vector3(
                        (Math.random() - 0.5) * 10,
                        (Math.random() - 0.5) * 10,
                        (Math.random() - 0.5) * 10
                    )
                ),
                end
            );
            
            const points = curve.getPoints(20);
            const geometry = new THREE.BufferGeometry().setFromPoints(points);
            
            const material = new THREE.LineBasicMaterial({
                color: 0x00aaff,
                transparent: true,
                opacity: 0.3,
                blending: THREE.AdditiveBlending
            });
            
            const line = new THREE.Line(geometry, material);
            connections.push(line);
        }
        
        phase.connections = connections;
    }
    
    async createBrainPhase() {
        const phase = this.phases.brain;
        
        // Brain-like network with clusters
        const clusterCount = 8;
        const neuronsPerCluster = 30;
        const totalNeurons = clusterCount * neuronsPerCluster;
        
        const geometry = new THREE.BufferGeometry();
        const positions = new Float32Array(totalNeurons * 3);
        const colors = new Float32Array(totalNeurons * 3);
        const sizes = new Float32Array(totalNeurons);
        
        let index = 0;
        
        for (let cluster = 0; cluster < clusterCount; cluster++) {
            // Cluster center in brain-like formation
            const clusterRadius = 25;
            const clusterAngle = (cluster / clusterCount) * Math.PI * 2;
            const clusterHeight = (Math.random() - 0.5) * 20;
            
            const clusterCenter = new THREE.Vector3(
                Math.cos(clusterAngle) * clusterRadius,
                clusterHeight,
                Math.sin(clusterAngle) * clusterRadius
            );
            
            for (let n = 0; n < neuronsPerCluster; n++) {
                const i3 = index * 3;
                
                // Neurons clustered around center
                const localRadius = 3 + Math.random() * 8;
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
                
                // Brain region colors
                const regionHue = (cluster / clusterCount) * 0.8 + 0.1;
                const color = new THREE.Color().setHSL(regionHue, 0.8, 0.6);
                colors[i3] = color.r;
                colors[i3 + 1] = color.g;
                colors[i3 + 2] = color.b;
                
                sizes[index] = 1.5 + Math.random() * 2;
                index++;
            }
        }
        
        geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
        geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));
        geometry.setAttribute('size', new THREE.BufferAttribute(sizes, 1));
        
        const material = new THREE.PointsMaterial({
            size: 0.8,
            vertexColors: true,
            transparent: true,
            opacity: 0.8,
            blending: THREE.AdditiveBlending,
            sizeAttenuation: true
        });
        
        phase.particleSystem = new THREE.Points(geometry, material);
        
        // Create inter-cluster connections
        this.createBrainConnections(phase, positions, totalNeurons, clusterCount, neuronsPerCluster);
        
        console.log('✅ Brain phase created');
    }
    
    createBrainConnections(phase, positions, totalCount, clusterCount, neuronsPerCluster) {
        const connections = [];
        
        // Intra-cluster connections (dense)
        for (let cluster = 0; cluster < clusterCount; cluster++) {
            const clusterStart = cluster * neuronsPerCluster;
            const connectionCount = neuronsPerCluster * 2;
            
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
                const material = new THREE.LineBasicMaterial({
                    color: 0x4a90e2,
                    transparent: true,
                    opacity: 0.2
                });
                
                connections.push(new THREE.Line(geometry, material));
            }
        }
        
        // Inter-cluster connections (sparse but important)
        for (let i = 0; i < clusterCount * 5; i++) {
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
            
            // Curved inter-cluster connections
            const midPoint = new THREE.Vector3().addVectors(start, end).multiplyScalar(0.5);
            midPoint.add(new THREE.Vector3(
                (Math.random() - 0.5) * 30,
                (Math.random() - 0.5) * 30,
                (Math.random() - 0.5) * 30
            ));
            
            const curve = new THREE.QuadraticBezierCurve3(start, midPoint, end);
            const points = curve.getPoints(25);
            const geometry = new THREE.BufferGeometry().setFromPoints(points);
            
            const material = new THREE.LineBasicMaterial({
                color: 0xff6b9d,
                transparent: true,
                opacity: 0.4
            });
            
            connections.push(new THREE.Line(geometry, material));
        }
        
        phase.connections = connections;
    }
    
    async createNetworkPhase() {
        const phase = this.phases.network;
        
        // Global data network with servers, data flows
        const nodeCount = 200;
        const geometry = new THREE.BufferGeometry();
        const positions = new Float32Array(nodeCount * 3);
        const colors = new Float32Array(nodeCount * 3);
        const sizes = new Float32Array(nodeCount);
        
        for (let i = 0; i < nodeCount; i++) {
            const i3 = i * 3;
            
            // Network distribution - some clustered (data centers), some distributed
            let radius, theta, phi;
            
            if (Math.random() > 0.3) {
                // Distributed network nodes
                radius = 40 + Math.random() * 60;
                theta = Math.random() * Math.PI * 2;
                phi = Math.random() * Math.PI;
            } else {
                // Data center clusters
                const centerIndex = Math.floor(Math.random() * 5);
                const centers = [
                    new THREE.Vector3(50, 0, 0),   // Americas
                    new THREE.Vector3(-50, 0, 0),  // Europe
                    new THREE.Vector3(0, 50, 0),   // Asia
                    new THREE.Vector3(0, -50, 0),  // Africa
                    new THREE.Vector3(0, 0, 50)    // Oceania
                ];
                
                const center = centers[centerIndex];
                const localRadius = 5 + Math.random() * 15;
                const localTheta = Math.random() * Math.PI * 2;
                const localPhi = Math.random() * Math.PI;
                
                positions[i3] = center.x + localRadius * Math.sin(localPhi) * Math.cos(localTheta);
                positions[i3 + 1] = center.y + localRadius * Math.sin(localPhi) * Math.sin(localTheta);
                positions[i3 + 2] = center.z + localRadius * Math.cos(localPhi);
                
                // Data center colors - green for efficiency
                const color = new THREE.Color().setHSL(0.3 + Math.random() * 0.2, 0.8, 0.5);
                colors[i3] = color.r;
                colors[i3 + 1] = color.g;
                colors[i3 + 2] = color.b;
                
                sizes[i] = 2 + Math.random() * 4;
                continue;
            }
            
            positions[i3] = radius * Math.sin(phi) * Math.cos(theta);
            positions[i3 + 1] = radius * Math.sin(phi) * Math.sin(theta);
            positions[i3 + 2] = radius * Math.cos(phi);
            
            // Network node colors - orange to red for data flows
            const color = new THREE.Color().setHSL(0.05 + Math.random() * 0.15, 0.9, 0.6);
            colors[i3] = color.r;
            colors[i3 + 1] = color.g;
            colors[i3 + 2] = color.b;
            
            sizes[i] = 1 + Math.random() * 2;
        }
        
        geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
        geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));
        geometry.setAttribute('size', new THREE.BufferAttribute(sizes, 1));
        
        const material = new THREE.PointsMaterial({
            size: 0.6,
            vertexColors: true,
            transparent: true,
            opacity: 0.9,
            blending: THREE.AdditiveBlending,
            sizeAttenuation: true
        });
        
        phase.particleSystem = new THREE.Points(geometry, material);
        
        // Create network connections with data flow animations
        this.createNetworkConnections(phase, positions, nodeCount);
        
        console.log('✅ Network phase created');
    }
    
    createNetworkConnections(phase, positions, nodeCount) {
        const connections = [];
        const connectionCount = nodeCount * 1.5;
        
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
            
            // Only connect nearby nodes for realistic network topology
            if (distance > 50) continue;
            
            const geometry = new THREE.BufferGeometry().setFromPoints([start, end]);
            const material = new THREE.LineBasicMaterial({
                color: 0x00ff88,
                transparent: true,
                opacity: 0.3
            });
            
            const line = new THREE.Line(geometry, material);
            line.userData = { 
                dataFlow: Math.random(), 
                flowSpeed: 0.5 + Math.random() * 2,
                flowDirection: Math.random() > 0.5 ? 1 : -1
            };
            
            connections.push(line);
        }
        
        phase.connections = connections;
    }
    
    async createCosmosPhase() {
        const phase = this.phases.cosmos;
        
        // Cosmic structure - galaxies, nebulae, cosmic web
        const cosmicNodeCount = 800;
        const geometry = new THREE.BufferGeometry();
        const positions = new Float32Array(cosmicNodeCount * 3);
        const colors = new Float32Array(cosmicNodeCount * 3);
        const sizes = new Float32Array(cosmicNodeCount);
        
        for (let i = 0; i < cosmicNodeCount; i++) {
            const i3 = i * 3;
            
            let radius, theta, phi;
            
            if (Math.random() > 0.4) {
                // Cosmic web filaments
                const filamentAngle = Math.floor(Math.random() * 6) * (Math.PI / 3);
                radius = 80 + Math.random() * 150;
                theta = filamentAngle + (Math.random() - 0.5) * 0.5;
                phi = Math.PI / 2 + (Math.random() - 0.5) * 1.5;
                
                // Add noise for organic filament structure
                const noise = 20 * (Math.random() - 0.5);
                radius += noise;
            } else {
                // Galaxy clusters
                radius = 100 + Math.random() * 100;
                theta = Math.random() * Math.PI * 2;
                phi = Math.random() * Math.PI;
            }
            
            positions[i3] = radius * Math.sin(phi) * Math.cos(theta);
            positions[i3 + 1] = radius * Math.sin(phi) * Math.sin(theta);
            positions[i3 + 2] = radius * Math.cos(phi);
            
            // Cosmic colors - deep purples, blues, and starlight
            const colorType = Math.random();
            let color;
            
            if (colorType < 0.3) {
                // Star clusters - white to yellow
                color = new THREE.Color().setHSL(0.15, 0.3, 0.9);
            } else if (colorType < 0.6) {
                // Nebulae - purple to magenta
                color = new THREE.Color().setHSL(0.8 + Math.random() * 0.2, 0.8, 0.6);
            } else {
                // Dark matter/energy - deep blue
                color = new THREE.Color().setHSL(0.6 + Math.random() * 0.1, 0.7, 0.4);
            }
            
            colors[i3] = color.r;
            colors[i3 + 1] = color.g;
            colors[i3 + 2] = color.b;
            
            sizes[i] = 0.5 + Math.random() * 3;
        }
        
        geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
        geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));
        geometry.setAttribute('size', new THREE.BufferAttribute(sizes, 1));
        
        const material = new THREE.PointsMaterial({
            size: 0.4,
            vertexColors: true,
            transparent: true,
            opacity: 0.8,
            blending: THREE.AdditiveBlending,
            sizeAttenuation: true
        });
        
        phase.particleSystem = new THREE.Points(geometry, material);
        
        // Create cosmic web connections
        this.createCosmicConnections(phase, positions, cosmicNodeCount);
        
        console.log('✅ Cosmos phase created');
    }
    
    createCosmicConnections(phase, positions, nodeCount) {
        const connections = [];
        const connectionCount = nodeCount * 0.8;
        
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
            
            // Create cosmic web filaments - longer connections allowed
            if (distance > 120) continue;
            
            const geometry = new THREE.BufferGeometry().setFromPoints([start, end]);
            const material = new THREE.LineBasicMaterial({
                color: 0x6600ff,
                transparent: true,
                opacity: 0.15
            });
            
            const line = new THREE.Line(geometry, material);
            line.userData = { 
                cosmicFlow: Math.random(),
                energy: Math.random() * 2 
            };
            
            connections.push(line);
        }
        
        phase.connections = connections;
    }
    
    activatePhase(phaseName) {
        console.log(`🔄 Activating phase: ${phaseName}`);
        
        // Clear current phase
        this.clearCurrentPhase();
        
        const phase = this.phases[phaseName];
        if (!phase) return;
        
        // Add particles
        if (phase.particleSystem) {
            this.scene.add(phase.particleSystem);
        }
        
        // Add connections
        if (phase.connections) {
            phase.connections.forEach(connection => {
                this.scene.add(connection);
            });
        }
        
        this.currentPhase = phaseName;
        
        // Adjust camera for phase
        this.adjustCameraForPhase(phaseName);
        
        // Update lighting for phase
        this.updateLightingForPhase(phaseName);
    }
    
    clearCurrentPhase() {
        Object.values(this.phases).forEach(phase => {
            if (phase.particleSystem && phase.particleSystem.parent) {
                this.scene.remove(phase.particleSystem);
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
            neuron: { x: 0, y: 0, z: 30 },
            brain: { x: 0, y: 0, z: 80 },
            network: { x: 0, y: 0, z: 150 },
            cosmos: { x: 0, y: 0, z: 300 }
        };
        
        const targetPos = cameraPositions[phaseName];
        if (!targetPos) return;
        
        // Smooth camera transition
        if (window.gsap) {
            gsap.to(this.camera.position, {
                duration: 3,
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
            neuron: { ambient: 0x1e1e3a, intensity1: 3, intensity2: 3 },
            brain: { ambient: 0x2a1e3a, intensity1: 2, intensity2: 2 },
            network: { ambient: 0x1e2a1e, intensity1: 1.5, intensity2: 1.5 },
            cosmos: { ambient: 0x0a0a2a, intensity1: 1, intensity2: 1 }
        };
        
        const config = lightingConfigs[phaseName];
        if (!config) return;
        
        // Update ambient light
        const ambientLight = this.scene.children.find(child => child.type === 'AmbientLight');
        if (ambientLight) {
            ambientLight.color.setHex(config.ambient);
        }
        
        // Update cosmic lights
        if (this.cosmicLights) {
            this.cosmicLights[0].intensity = config.intensity1;
            this.cosmicLights[1].intensity = config.intensity2;
        }
    }
    
    setupPostProcessing() {
        // Add subtle bloom effect for sci-fi feel
        // This would require additional post-processing libraries
        // For now, we'll rely on the built-in additive blending
    }
    
    setupInteractions() {
        if (!this.options.enableInteraction) return;
        
        // Keyboard controls for manual phase switching
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
        
        console.log('✅ Interactions setup - Use keys 1-4 to switch phases, Space to toggle auto-transition');
    }
    
    transitionToPhase(phaseName) {
        if (this.currentPhase === phaseName) return;
        
        this.isTransitioning = true;
        this.transitionProgress = 0;
        
        // Smooth transition
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
    
    startAnimation() {
        const animate = () => {
            this.animationId = requestAnimationFrame(animate);
            
            const time = this.clock.getElapsedTime();
            this.frameCount++;
            
            // Update controls
            if (this.controls && this.controls.update) {
                this.controls.update();
            }
            
            // Animate current phase
            this.animateCurrentPhase(time);
            
            // Animate cosmic lights
            if (this.cosmicLights) {
                this.cosmicLights[0].position.x = Math.sin(time * 0.5) * 50;
                this.cosmicLights[0].position.z = Math.cos(time * 0.3) * 30;
                
                this.cosmicLights[1].position.x = Math.cos(time * 0.7) * -40;
                this.cosmicLights[1].position.y = Math.sin(time * 0.4) * 25;
            }
            
            // Render
            this.renderer.render(this.scene, this.camera);
        };
        
        animate();
        console.log('✅ Animation started');
    }
    
    animateCurrentPhase(time) {
        const phase = this.phases[this.currentPhase];
        if (!phase) return;
        
        // Animate particles based on phase type
        if (phase.particleSystem) {
            const positions = phase.particleSystem.geometry.attributes.position.array;
            const originalPositions = phase.particleSystem.userData.originalPositions;
            
            // Store original positions if not already stored
            if (!originalPositions) {
                phase.particleSystem.userData.originalPositions = new Float32Array(positions);
            }
            
            // Phase-specific animations
            switch (this.currentPhase) {
                case 'neuron':
                    this.animateNeuronPhase(phase, time);
                    break;
                case 'brain':
                    this.animateBrainPhase(phase, time);
                    break;
                case 'network':
                    this.animateNetworkPhase(phase, time);
                    break;
                case 'cosmos':
                    this.animateCosmosPhase(phase, time);
                    break;
            }
        }
        
        // Animate connections
        this.animateConnections(phase, time);
    }
    
    animateNeuronPhase(phase, time) {
        // Organic pulsing and electrical activity
        const positions = phase.particleSystem.geometry.attributes.position.array;
        
        for (let i = 0; i < positions.length; i += 3) {
            const pulse = Math.sin(time * 3 + i * 0.1) * 0.5;
            positions[i] += pulse * 0.1;
            positions[i + 1] += Math.cos(time * 2 + i * 0.05) * 0.1;
            positions[i + 2] += Math.sin(time * 4 + i * 0.15) * 0.05;
        }
        
        phase.particleSystem.geometry.attributes.position.needsUpdate = true;
        
        // Electrical impulse effects
        phase.particleSystem.material.opacity = 0.8 + Math.sin(time * 5) * 0.2;
    }
    
    animateBrainPhase(phase, time) {
        // Brain wave patterns and neural oscillations
        const positions = phase.particleSystem.geometry.attributes.position.array;
        
        for (let i = 0; i < positions.length; i += 3) {
            const wavePhase = time * 2 + i * 0.01;
            const brainWave = Math.sin(wavePhase) * Math.cos(wavePhase * 0.5) * 0.3;
            
            positions[i + 1] += brainWave;
        }
        
        phase.particleSystem.geometry.attributes.position.needsUpdate = true;
        
        // Alpha wave synchronization
        phase.particleSystem.rotation.y += 0.001;
    }
    
    animateNetworkPhase(phase, time) {
        // Data packet flows and network traffic
        phase.particleSystem.rotation.x = Math.sin(time * 0.1) * 0.1;
        phase.particleSystem.rotation.y += 0.002;
        
        // Simulate network latency variations
        const colors = phase.particleSystem.geometry.attributes.color.array;
        for (let i = 0; i < colors.length; i += 3) {
            const activity = Math.sin(time * 3 + i * 0.1) * 0.3 + 0.7;
            colors[i] *= activity;     // Red component (data activity)
            colors[i + 1] *= activity; // Green component
        }
        
        phase.particleSystem.geometry.attributes.color.needsUpdate = true;
    }
    
    animateCosmosPhase(phase, time) {
        // Cosmic expansion and dark energy flows
        const scale = 1 + Math.sin(time * 0.1) * 0.05; // Cosmic expansion
        phase.particleSystem.scale.setScalar(scale);
        
        // Galactic rotation
        phase.particleSystem.rotation.z += 0.0005;
        
        // Stellar evolution (twinkling)
        const colors = phase.particleSystem.geometry.attributes.color.array;
        for (let i = 0; i < colors.length; i += 3) {
            const twinkle = Math.sin(time * 5 + i * 0.05) * 0.2 + 0.8;
            colors[i + 2] *= twinkle; // Blue component (starlight)
        }
        
        phase.particleSystem.geometry.attributes.color.needsUpdate = true;
    }
    
    animateConnections(phase, time) {
        if (!phase.connections) return;
        
        phase.connections.forEach((connection, index) => {
            // Pulse opacity for data/energy flow
            const pulseSpeed = connection.userData?.flowSpeed || 1;
            const pulse = Math.sin(time * pulseSpeed + index * 0.1) * 0.3 + 0.7;
            
            connection.material.opacity = connection.material.opacity * 0.95 + pulse * 0.05;
            
            // Color shifting for energy flow
            if (this.currentPhase === 'cosmos') {
                const hue = (time * 0.1 + index * 0.02) % 1;
                connection.material.color.setHSL(hue * 0.3 + 0.6, 0.8, 0.5);
            }
        });
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
    
    showFallback() {
        const container = document.getElementById(this.containerId);
        if (!container) return;
        
        container.innerHTML = `
            <div style="display: flex; align-items: center; justify-content: center; height: 100%; color: #00aaff; text-align: center; padding: 2rem; background: linear-gradient(45deg, #000011, #001122);">
                <div>
                    <div style="font-size: 1.8rem; font-weight: 700; margin-bottom: 1rem; text-shadow: 0 0 20px currentColor;">🧠 → 🌌</div>
                    <div style="font-size: 1.2rem; opacity: 0.9; margin-bottom: 0.5rem;">Neural Networks to Cosmos</div>
                    <div style="font-size: 0.9rem; opacity: 0.7;">From Neurons to Universal Intelligence</div>
                </div>
            </div>
        `;
    }
    
    // Public API
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
        
        console.log('✅ Epic Neural to Cosmos visualization destroyed');
    }
    
    getStats() {
        return {
            currentPhase: this.currentPhase,
            frameCount: this.frameCount,
            isAutoTransitioning: !!this.autoTransitionTimer,
            isTransitioning: this.isTransitioning
        };
    }
    
    // Manual controls
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
    module.exports = EpicNeuralToCosmosViz;
} else {
    window.EpicNeuralToCosmosViz = EpicNeuralToCosmosViz;
}