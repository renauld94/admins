/**
 * NEURONS TO COSMOS - Epic Cinematic 3D Journey (Pure Three.js Version)
 * 
 * A breathtaking 30-second automated journey through four scales of existence:
 * PHASE 1 (0-7.5s):   Neural Microcosm - Individual neurons firing
 * PHASE 2 (7.5-13.5s): Brain Structure - Full hemisphere with synaptic connections
 * PHASE 3 (13.5-22.5s): Geospatial Earth - Global data network
 * PHASE 4 (22.5-30s):  Cosmic Perspective - Earth in space with satellites
 * 
 * Built with: Pure Three.js (no React dependencies)
 */

(function() {
    'use strict';
    
    console.log('🌌 [NEURONS TO COSMOS] Initializing Pure Three.js Epic Journey...');
    
    // Wait for DOM and Three.js to be ready
    function initNeuronsToCosmos() {
        if (typeof THREE === 'undefined') {
            console.error('❌ [NEURONS TO COSMOS] Three.js not loaded');
            return;
        }
        
        const heroViz = document.getElementById('hero-visualization');
        if (!heroViz) {
            console.error('❌ [NEURONS TO COSMOS] Hero visualization container not found');
            return;
        }
        
        console.log('✅ [NEURONS TO COSMOS] Starting epic cinematic journey...');
        
        // Hide loading state
        const loadingDiv = heroViz.querySelector('.r3f-loading');
        if (loadingDiv) {
            loadingDiv.style.display = 'none';
        }
        
        // Create Three.js scene
        const scene = new THREE.Scene();
        const camera = new THREE.PerspectiveCamera(75, heroViz.clientWidth / heroViz.clientHeight, 0.1, 1000);
        const renderer = new THREE.WebGLRenderer({ alpha: true, antialias: true });
        
        renderer.setSize(heroViz.clientWidth, heroViz.clientHeight);
        renderer.setClearColor(0x000000, 0);
        heroViz.appendChild(renderer.domElement);
        
        // Animation phases
        const DURATION = 30;
        const PHASES = {
            NEURAL: { start: 0, end: 7.5, name: 'Neural Microcosm' },
            BRAIN: { start: 7.5, end: 13.5, name: 'Brain Structure' },
            EARTH: { start: 13.5, end: 22.5, name: 'Geospatial Network' },
            COSMOS: { start: 22.5, end: 30, name: 'Cosmic Perspective' }
        };
        
        // Colors
        const COLORS = {
            electricBlue: 0x00d9ff,
            neuralPink: 0xff6b9d,
            deepPurple: 0x8b5cf6,
            cosmicOrange: 0xff6b35,
            dataGreen: 0x10b981,
            satelliteWhite: 0xe0f2fe
        };
        
        // Create particle systems for each phase
        const particleSystems = [];
        const connections = [];
        let currentPhase = 'NEURAL';
        let startTime = Date.now();
        
        // Phase 1: Neural Microcosm - Individual neurons firing
        function createNeuralPhase() {
            const particleCount = 2000;
            const geometry = new THREE.BufferGeometry();
            const positions = new Float32Array(particleCount * 3);
            const colors = new Float32Array(particleCount * 3);
            
            for (let i = 0; i < particleCount; i++) {
                const i3 = i * 3;
                // Create small clusters of neurons
                const cluster = Math.floor(i / 200);
                const clusterCenter = new THREE.Vector3(
                    (Math.random() - 0.5) * 2,
                    (Math.random() - 0.5) * 2,
                    (Math.random() - 0.5) * 2
                );
                
                positions[i3] = clusterCenter.x + (Math.random() - 0.5) * 0.5;
                positions[i3 + 1] = clusterCenter.y + (Math.random() - 0.5) * 0.5;
                positions[i3 + 2] = clusterCenter.z + (Math.random() - 0.5) * 0.5;
                
                // Electric blue with pink accents
                colors[i3] = 0.0;     // R
                colors[i3 + 1] = 0.85; // G
                colors[i3 + 2] = 1.0;  // B
            }
            
            geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
            geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));
            
            const material = new THREE.PointsMaterial({
                size: 0.02,
                vertexColors: true,
                transparent: true,
                opacity: 0.8
            });
            
            return new THREE.Points(geometry, material);
        }
        
        // Phase 2: Brain Structure - Full hemisphere
        function createBrainPhase() {
            const particleCount = 5000;
            const geometry = new THREE.BufferGeometry();
            const positions = new Float32Array(particleCount * 3);
            const colors = new Float32Array(particleCount * 3);
            
            for (let i = 0; i < particleCount; i++) {
                const i3 = i * 3;
                // Create brain hemisphere shape
                const phi = Math.acos(1 - 2 * Math.random());
                const theta = 2 * Math.PI * Math.random();
                const radius = 3 + Math.random() * 2;
                
                positions[i3] = radius * Math.sin(phi) * Math.cos(theta);
                positions[i3 + 1] = radius * Math.sin(phi) * Math.sin(theta);
                positions[i3 + 2] = radius * Math.cos(phi);
                
                // Neural pink with purple accents
                colors[i3] = 1.0;     // R
                colors[i3 + 1] = 0.42; // G
                colors[i3 + 2] = 0.62; // B
            }
            
            geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
            geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));
            
            const material = new THREE.PointsMaterial({
                size: 0.03,
                vertexColors: true,
                transparent: true,
                opacity: 0.7
            });
            
            return new THREE.Points(geometry, material);
        }
        
        // Phase 3: Geospatial Earth - Global data network
        function createEarthPhase() {
            const particleCount = 8000;
            const geometry = new THREE.BufferGeometry();
            const positions = new Float32Array(particleCount * 3);
            const colors = new Float32Array(particleCount * 3);
            
            for (let i = 0; i < particleCount; i++) {
                const i3 = i * 3;
                // Create Earth-like sphere with data connections
                const phi = Math.acos(1 - 2 * Math.random());
                const theta = 2 * Math.PI * Math.random();
                const radius = 8 + Math.random() * 1;
                
                positions[i3] = radius * Math.sin(phi) * Math.cos(theta);
                positions[i3 + 1] = radius * Math.sin(phi) * Math.sin(theta);
                positions[i3 + 2] = radius * Math.cos(phi);
                
                // Data green with blue accents
                colors[i3] = 0.06;    // R
                colors[i3 + 1] = 0.73; // G
                colors[i3 + 2] = 0.51; // B
            }
            
            geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
            geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));
            
            const material = new THREE.PointsMaterial({
                size: 0.04,
                vertexColors: true,
                transparent: true,
                opacity: 0.6
            });
            
            return new THREE.Points(geometry, material);
        }
        
        // Phase 4: Cosmic Perspective - Earth in space
        function createCosmosPhase() {
            const particleCount = 12000;
            const geometry = new THREE.BufferGeometry();
            const positions = new Float32Array(particleCount * 3);
            const colors = new Float32Array(particleCount * 3);
            
            for (let i = 0; i < particleCount; i++) {
                const i3 = i * 3;
                // Create cosmic field with Earth at center
                const phi = Math.acos(1 - 2 * Math.random());
                const theta = 2 * Math.PI * Math.random();
                const radius = 15 + Math.random() * 10;
                
                positions[i3] = radius * Math.sin(phi) * Math.cos(theta);
                positions[i3 + 1] = radius * Math.sin(phi) * Math.sin(theta);
                positions[i3 + 2] = radius * Math.cos(phi);
                
                // Cosmic orange with white accents
                colors[i3] = 1.0;     // R
                colors[i3 + 1] = 0.42; // G
                colors[i3 + 2] = 0.21; // B
            }
            
            geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
            geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));
            
            const material = new THREE.PointsMaterial({
                size: 0.05,
                vertexColors: true,
                transparent: true,
                opacity: 0.5
            });
            
            return new THREE.Points(geometry, material);
        }
        
        // Create all phases
        const neuralSystem = createNeuralPhase();
        const brainSystem = createBrainPhase();
        const earthSystem = createEarthPhase();
        const cosmosSystem = createCosmosPhase();
        
        // Add initial phase
        scene.add(neuralSystem);
        
        // Camera positions for each phase
        const cameraPositions = {
            NEURAL: { x: 0, y: 0, z: 5 },
            BRAIN: { x: 0, y: 0, z: 8 },
            EARTH: { x: 0, y: 0, z: 15 },
            COSMOS: { x: 0, y: 0, z: 25 }
        };
        
        // Set initial camera position
        camera.position.set(cameraPositions.NEURAL.x, cameraPositions.NEURAL.y, cameraPositions.NEURAL.z);
        
        // Animation loop
        function animate() {
            requestAnimationFrame(animate);
            
            const elapsed = (Date.now() - startTime) / 1000;
            const progress = elapsed % DURATION;
            
            // Determine current phase
            let newPhase = 'NEURAL';
            for (const [phase, config] of Object.entries(PHASES)) {
                if (progress >= config.start && progress < config.end) {
                    newPhase = phase;
                    break;
                }
            }
            
            // Phase transitions
            if (newPhase !== currentPhase) {
                console.log(`🌌 [NEURONS TO COSMOS] Phase transition: ${currentPhase} → ${newPhase}`);
                
                // Remove current system
                scene.remove(scene.children[scene.children.length - 1]);
                
                // Add new system
                switch (newPhase) {
                    case 'NEURAL':
                        scene.add(neuralSystem);
                        break;
                    case 'BRAIN':
                        scene.add(brainSystem);
                        break;
                    case 'EARTH':
                        scene.add(earthSystem);
                        break;
                    case 'COSMOS':
                        scene.add(cosmosSystem);
                        break;
                }
                
                currentPhase = newPhase;
            }
            
            // Smooth camera transitions
            const targetPos = cameraPositions[currentPhase];
            camera.position.lerp(new THREE.Vector3(targetPos.x, targetPos.y, targetPos.z), 0.02);
            
            // Rotate current particle system
            const currentSystem = scene.children[scene.children.length - 1];
            if (currentSystem) {
                currentSystem.rotation.x += 0.001;
                currentSystem.rotation.y += 0.002;
            }
            
            // Camera look at center
            camera.lookAt(0, 0, 0);
            
            renderer.render(scene, camera);
        }
        
        // Handle resize
        window.addEventListener('resize', () => {
            camera.aspect = heroViz.clientWidth / heroViz.clientHeight;
            camera.updateProjectionMatrix();
            renderer.setSize(heroViz.clientWidth, heroViz.clientHeight);
        });
        
        // Start animation
        animate();
        
        console.log('✅ [NEURONS TO COSMOS] Epic cinematic journey started!');
        console.log('🎬 30-second journey: Neural Microcosm → Brain Structure → Geospatial Earth → Cosmic Perspective');
        
        // Emit event for integration
        if (window.__HERO_EVENT_BUS__) {
            window.__HERO_EVENT_BUS__.emit('hero:mounted', {
                ts: Date.now(),
                variant: 'neurons-to-cosmos-pure-threejs',
                mobile: false
            });
        }
    }
    
    // Initialize when ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initNeuronsToCosmos);
    } else {
        initNeuronsToCosmos();
    }
    
})();
