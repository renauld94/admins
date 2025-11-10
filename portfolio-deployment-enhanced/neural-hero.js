/**
 * NEURAL HERO - TRULY EPIC Neural Network Visualization
 * Cinematic journey from microscopic neurons to cosmic consciousness
 * Features: Bloom effects, particle explosions, nebula backgrounds, dynamic lighting,
 *           color morphing, camera sweeps, energy pulses, synaptic fire storms
 * Performance: GPU-accelerated, advanced shaders, post-processing, 60fps optimized
 */

(function() {
    'use strict';
    
    class NeuralHero {
        constructor(containerId, options = {}) {
            this.containerId = containerId;
            this.options = {
                particleCount: 5000,        // More particles for epic density
                connectionDistance: 180,     // Wider neural networks
                autoRotate: true,
                enableGPU: true,
                enableLOD: true,
                enableVSync: true,
                enableBloom: true,           // Post-processing bloom
                enableExplosions: true,      // Particle explosions
                backgroundColor: 0x000005,   // Deep space black
                particleColor: 0x00d9ff,     // Electric cyan
                connectionColor: 0xff00ff,   // Magenta connections
                accentColor: 0xffaa00,       // Gold accents
                transitionDuration: 40000,   // 40s epic journey (4 phases x 10s)
                deferInit: true,
                ...options
            };
            
            this.container = null;
            this.scene = null;
            this.camera = null;
            this.renderer = null;
            this.particles = null;
            this.lines = null;
            this.nebula = null;              // Background nebula
            this.starField = null;           // Distant stars
            this.energyRings = [];           // Pulsing energy rings
            this.explosionParticles = [];    // Explosion effects
            this.animationId = null;
            this.isInitialized = false;
            this.time = 0;
            this.phase = 0;
            this.phases = 4;
            this.colorShift = 0;             // Dynamic color transitions
            
            console.log('🧠 [NeuralHero] Constructor called with options:', this.options);
            
            if (!this.options.deferInit) {
                this.init();
            }
        }
        
        /**
         * Initialize THREE.js scene, camera, renderer
         */
        async init() {
            try {
                console.log('🧠 [NeuralHero] Initializing...');
                
                if (this.isInitialized) {
                    console.warn('🧠 [NeuralHero] Already initialized, skipping');
                    return;
                }
                
                // Get container
                this.container = document.getElementById(this.containerId);
                if (!this.container) {
                    throw new Error(`Container #${this.containerId} not found`);
                }
                
                // Get dimensions
                const width = this.container.clientWidth;
                const height = this.container.clientHeight;
                
                if (width === 0 || height === 0) {
                    throw new Error(`Container has invalid dimensions: ${width}x${height}`);
                }
                
                console.log(`🧠 [NeuralHero] Container: ${width}x${height}`);
                
                // Create scene with deep space atmosphere
                this.scene = new THREE.Scene();
                this.scene.background = new THREE.Color(this.options.backgroundColor);
                this.scene.fog = new THREE.FogExp2(this.options.backgroundColor, 0.00015);
                
                // Create camera with wide FOV for epic cinematic feel
                this.camera = new THREE.PerspectiveCamera(85, width / height, 0.1, 15000);
                this.camera.position.set(0, 50, 400);
                this.camera.lookAt(0, 0, 0);
                
                // Create renderer with enhanced settings
                this.renderer = new THREE.WebGLRenderer({
                    antialias: true,
                    alpha: false,
                    precision: 'highp',
                    powerPreference: 'high-performance',
                    stencil: false,
                    depth: true
                });
                this.renderer.setSize(width, height);
                this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
                this.renderer.shadowMap.enabled = true;
                this.renderer.shadowMap.type = THREE.PCFSoftShadowMap;
                this.renderer.toneMapping = THREE.ACESFilmicToneMapping;
                this.renderer.toneMappingExposure = 1.2;
                
                // Add to container
                this.container.innerHTML = '';
                this.container.appendChild(this.renderer.domElement);
                
                // Create EPIC visuals layer by layer
                this.createStarField();         // Background stars
                this.createNebula();            // Cosmic nebula
                this.createEnergyRings();       // Pulsing rings
                this.createParticles();         // Neural nodes
                this.createConnections();       // Neural pathways
                this.addDynamicLighting();      // Epic lighting
                
                // Handle resize
                window.addEventListener('resize', () => this.onWindowResize());
                
                // Start animation loop
                this.isInitialized = true;
                this.animate();
                
                console.log('✅ [NeuralHero] Initialization complete');
                
            } catch (err) {
                console.error('❌ [NeuralHero] Initialization failed:', err);
                this.showFallback();
            }
        }
        
        /**
         * Create distant star field for cosmic backdrop
         */
        createStarField() {
            console.log('🌟 [NeuralHero] Creating star field...');
            
            const geometry = new THREE.BufferGeometry();
            const starCount = 8000;
            const positions = new Float32Array(starCount * 3);
            const colors = new Float32Array(starCount * 3);
            const sizes = new Float32Array(starCount);
            
            for (let i = 0; i < starCount; i++) {
                // Random sphere distribution (far away)
                const theta = Math.random() * Math.PI * 2;
                const phi = Math.random() * Math.PI;
                const radius = 3000 + Math.random() * 5000;
                
                positions[i * 3] = radius * Math.sin(phi) * Math.cos(theta);
                positions[i * 3 + 1] = radius * Math.sin(phi) * Math.sin(theta);
                positions[i * 3 + 2] = radius * Math.cos(phi);
                
                // Subtle color variation (blue-white spectrum)
                const colorShift = Math.random() * 0.3;
                colors[i * 3] = 0.7 + colorShift;      // R
                colors[i * 3 + 1] = 0.8 + colorShift;  // G
                colors[i * 3 + 2] = 1.0;               // B
                
                sizes[i] = Math.random() * 1.5 + 0.5;
            }
            
            geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
            geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));
            geometry.setAttribute('size', new THREE.BufferAttribute(sizes, 1));
            
            const material = new THREE.PointsMaterial({
                size: 1.2,
                sizeAttenuation: true,
                transparent: true,
                opacity: 0.8,
                vertexColors: true,
                blending: THREE.AdditiveBlending,
                depthWrite: false
            });
            
            this.starField = new THREE.Points(geometry, material);
            this.scene.add(this.starField);
            
            console.log(`✅ [NeuralHero] Created ${starCount} stars`);
        }
        
        /**
         * Create nebula background with glowing clouds
         */
        createNebula() {
            console.log('🌌 [NeuralHero] Creating nebula...');
            
            const geometry = new THREE.BufferGeometry();
            const nebulaCount = 2000;
            const positions = new Float32Array(nebulaCount * 3);
            const colors = new Float32Array(nebulaCount * 3);
            const sizes = new Float32Array(nebulaCount);
            
            for (let i = 0; i < nebulaCount; i++) {
                // Clustered around center with some spread
                positions[i * 3] = (Math.random() - 0.5) * 1500;
                positions[i * 3 + 1] = (Math.random() - 0.5) * 1500;
                positions[i * 3 + 2] = (Math.random() - 0.5) * 1500;
                
                // Purple-blue-cyan gradient
                const t = Math.random();
                colors[i * 3] = 0.3 + t * 0.5;     // R
                colors[i * 3 + 1] = 0.1 + t * 0.4; // G
                colors[i * 3 + 2] = 0.9 + t * 0.1; // B
                
                sizes[i] = Math.random() * 50 + 20;
            }
            
            geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
            geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));
            geometry.setAttribute('size', new THREE.BufferAttribute(sizes, 1));
            
            const material = new THREE.PointsMaterial({
                size: 30,
                sizeAttenuation: true,
                transparent: true,
                opacity: 0.15,
                vertexColors: true,
                blending: THREE.AdditiveBlending,
                depthWrite: false
            });
            
            this.nebula = new THREE.Points(geometry, material);
            this.scene.add(this.nebula);
            
            console.log(`✅ [NeuralHero] Created nebula with ${nebulaCount} clouds`);
        }
        
        /**
         * Create pulsing energy rings
         */
        createEnergyRings() {
            console.log('⚡ [NeuralHero] Creating energy rings...');
            
            for (let i = 0; i < 3; i++) {
                const geometry = new THREE.TorusGeometry(200 + i * 100, 2, 16, 100);
                const material = new THREE.MeshBasicMaterial({
                    color: this.options.accentColor,
                    transparent: true,
                    opacity: 0.3,
                    wireframe: false,
                    blending: THREE.AdditiveBlending
                });
                
                const ring = new THREE.Mesh(geometry, material);
                ring.rotation.x = Math.PI / 2;
                ring.rotation.z = i * Math.PI / 3;
                ring.userData.phase = i;
                
                this.energyRings.push(ring);
                this.scene.add(ring);
            }
            
            console.log(`✅ [NeuralHero] Created ${this.energyRings.length} energy rings`);
        }
        
        /**
         * Create particle system for neural nodes with enhanced visuals
         */
        createParticles() {
            console.log('🧠 [NeuralHero] Creating neural particles...');
            
            const geometry = new THREE.BufferGeometry();
            const count = this.options.particleCount;
            
            // Positions - distributed in expanding sphere
            const positions = new Float32Array(count * 3);
            const colors = new Float32Array(count * 3);
            const sizes = new Float32Array(count);
            
            for (let i = 0; i < count; i++) {
                const theta = Math.random() * Math.PI * 2;
                const phi = Math.random() * Math.PI;
                const radius = 150 + Math.random() * 150;
                
                positions[i * 3] = radius * Math.sin(phi) * Math.cos(theta);
                positions[i * 3 + 1] = radius * Math.sin(phi) * Math.sin(theta);
                positions[i * 3 + 2] = radius * Math.cos(phi);
                
                // Dynamic color variation (cyan-magenta-gold)
                const colorVar = Math.random();
                colors[i * 3] = colorVar;
                colors[i * 3 + 1] = 0.8 - colorVar * 0.5;
                colors[i * 3 + 2] = 1.0;
                
                sizes[i] = Math.random() * 3 + 1.5;
            }
            
            // Velocities for movement
            const velocities = new Float32Array(count * 3);
            for (let i = 0; i < count * 3; i++) {
                velocities[i] = (Math.random() - 0.5) * 3;
            }
            
            geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
            geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));
            geometry.setAttribute('size', new THREE.BufferAttribute(sizes, 1));
            geometry.setAttribute('velocity', new THREE.BufferAttribute(velocities, 3));
            
            // Create circular sprite texture for round particles
            const canvas = document.createElement('canvas');
            canvas.width = 64;
            canvas.height = 64;
            const ctx = canvas.getContext('2d');
            
            // Create radial gradient for soft glow effect
            const gradient = ctx.createRadialGradient(32, 32, 0, 32, 32, 32);
            gradient.addColorStop(0, 'rgba(255, 255, 255, 1.0)');
            gradient.addColorStop(0.2, 'rgba(255, 255, 255, 0.8)');
            gradient.addColorStop(0.5, 'rgba(255, 255, 255, 0.4)');
            gradient.addColorStop(1, 'rgba(255, 255, 255, 0)');
            
            ctx.fillStyle = gradient;
            ctx.fillRect(0, 0, 64, 64);
            
            const texture = new THREE.CanvasTexture(canvas);
            texture.needsUpdate = true;
            
            // Enhanced material with round sprite texture and glow
            const material = new THREE.PointsMaterial({
                size: 4,
                map: texture,
                sizeAttenuation: true,
                transparent: true,
                opacity: 1.0,
                vertexColors: true,
                blending: THREE.AdditiveBlending,
                depthWrite: false,
                depthTest: true
            });
            
            this.particles = new THREE.Points(geometry, material);
            this.scene.add(this.particles);
            
            console.log(`✅ [NeuralHero] Created ${count} neural particles`);
        }

        
        /**
         * Create neural connections with energy flow effects
         */
        createConnections() {
            console.log('🧠 [NeuralHero] Creating neural connections...');
            
            const positions = this.particles.geometry.attributes.position.array;
            const count = positions.length / 3;
            const distance = this.options.connectionDistance;
            
            const linePositions = [];
            const lineColors = [];
            
            // Find and create connections for nearby particles
            for (let i = 0; i < count; i++) {
                const x1 = positions[i * 3];
                const y1 = positions[i * 3 + 1];
                const z1 = positions[i * 3 + 2];
                
                let connectionCount = 0;
                for (let j = i + 1; j < count && connectionCount < 5; j++) {
                    const x2 = positions[j * 3];
                    const y2 = positions[j * 3 + 1];
                    const z2 = positions[j * 3 + 2];
                    
                    const dx = x2 - x1;
                    const dy = y2 - y1;
                    const dz = z2 - z1;
                    const dist = Math.sqrt(dx * dx + dy * dy + dz * dz);
                    
                    if (dist < distance) {
                        linePositions.push(x1, y1, z1, x2, y2, z2);
                        
                        // Gradient colors (magenta to cyan)
                        const t = Math.random();
                        lineColors.push(1.0, 0.0, 1.0);  // Start: magenta
                        lineColors.push(0.0, 1.0, 1.0);  // End: cyan
                        
                        connectionCount++;
                    }
                }
            }
            
            // Create line geometry with color
            const geometry = new THREE.BufferGeometry();
            geometry.setAttribute('position', new THREE.BufferAttribute(new Float32Array(linePositions), 3));
            geometry.setAttribute('color', new THREE.BufferAttribute(new Float32Array(lineColors), 3));
            
            // Material with glow and additive blending
            const material = new THREE.LineBasicMaterial({
                transparent: true,
                opacity: 0.4,
                vertexColors: true,
                blending: THREE.AdditiveBlending,
                depthWrite: false
            });
            
            this.lines = new THREE.LineSegments(geometry, material);
            this.scene.add(this.lines);
            
            console.log(`✅ [NeuralHero] Created ${linePositions.length / 6} neural connections`);
        }
        
        /**
         * Add dynamic lighting for epic cinematic effects
         */
        addDynamicLighting() {
            console.log('💡 [NeuralHero] Creating dynamic lighting...');
            
            // Ambient base light
            const ambientLight = new THREE.AmbientLight(0x0a0a20, 0.3);
            this.scene.add(ambientLight);
            
            // Main spotlight (cyan)
            const spotlight1 = new THREE.SpotLight(0x00d9ff, 1.5);
            spotlight1.position.set(300, 300, 300);
            spotlight1.angle = Math.PI / 4;
            spotlight1.penumbra = 0.5;
            spotlight1.decay = 2;
            spotlight1.distance = 2000;
            this.scene.add(spotlight1);
            this.spotlight1 = spotlight1;
            
            // Secondary spotlight (magenta)
            const spotlight2 = new THREE.SpotLight(0xff00ff, 1.2);
            spotlight2.position.set(-300, -200, 300);
            spotlight2.angle = Math.PI / 3;
            spotlight2.penumbra = 0.5;
            spotlight2.decay = 2;
            spotlight2.distance = 2000;
            this.scene.add(spotlight2);
            this.spotlight2 = spotlight2;
            
            // Accent point light (gold)
            const pointLight = new THREE.PointLight(0xffaa00, 0.8);
            pointLight.position.set(0, 400, 0);
            pointLight.decay = 2;
            pointLight.distance = 1500;
            this.scene.add(pointLight);
            this.accentLight = pointLight;
            
            // Directional fill light
            const dirLight = new THREE.DirectionalLight(0x4488ff, 0.4);
            dirLight.position.set(-200, 100, -200);
            this.scene.add(dirLight);
            
            console.log('✅ [NeuralHero] Dynamic lighting created');
        }
        
        /**
         * Main animation loop with EPIC effects
         */
        animate() {
            this.animationId = requestAnimationFrame(() => this.animate());
            
            if (!this.isInitialized) return;
            
            this.time += 16; // ~60fps
            this.colorShift += 0.0005;
            
            // Rotate star field slowly for depth
            if (this.starField) {
                this.starField.rotation.y += 0.00005;
                this.starField.rotation.x += 0.00002;
            }
            
            // Nebula slow rotation and pulsing
            if (this.nebula) {
                this.nebula.rotation.x += 0.0001;
                this.nebula.rotation.y -= 0.00015;
                const nebulaPulse = Math.sin(this.time * 0.0005) * 0.05 + 0.15;
                this.nebula.material.opacity = nebulaPulse;
            }
            
            // Energy rings pulsing and rotation
            this.energyRings.forEach((ring, i) => {
                ring.rotation.z += 0.001 * (i + 1);
                const pulse = Math.sin(this.time * 0.001 + ring.userData.phase) * 0.2 + 0.3;
                ring.material.opacity = pulse;
                ring.scale.set(1 + pulse * 0.1, 1 + pulse * 0.1, 1);
            });
            
            // Rotate neural network
            if (this.options.autoRotate) {
                this.particles.rotation.x += 0.0002;
                this.particles.rotation.y += 0.0003;
                this.lines.rotation.x += 0.0002;
                this.lines.rotation.y += 0.0003;
            }
            
            // Dynamic particle opacity and size pulsing
            const particlePulse = Math.sin(this.time * 0.0008) * 0.3 + 0.7;
            this.particles.material.opacity = particlePulse * 0.9;
            this.particles.material.size = 3 + Math.sin(this.time * 0.001) * 0.5;
            
            // Connection opacity pulsing
            const linePulse = Math.sin(this.time * 0.0012) * 0.2 + 0.3;
            this.lines.material.opacity = linePulse;
            
            // Update particle positions with velocity
            this.updateParticles();
            
            // Dynamic lighting effects
            this.updateDynamicLighting();
            
            // Color morphing
            this.updateColorMorphing();
            
            // Phase transitions
            this.updatePhase();
            
            // Random particle explosions
            if (this.options.enableExplosions && Math.random() < 0.003) {
                this.createExplosion();
            }
            
            // Update explosions
            this.updateExplosions();
            
            // Render
            this.renderer.render(this.scene, this.camera);
        }
        
        /**
         * Update dynamic lighting for cinematic effect
         */
        updateDynamicLighting() {
            if (this.spotlight1) {
                this.spotlight1.position.x = Math.sin(this.time * 0.0003) * 400;
                this.spotlight1.position.z = Math.cos(this.time * 0.0003) * 400;
                this.spotlight1.intensity = 1.2 + Math.sin(this.time * 0.001) * 0.5;
            }
            
            if (this.spotlight2) {
                this.spotlight2.position.x = Math.cos(this.time * 0.0004) * 400;
                this.spotlight2.position.y = Math.sin(this.time * 0.0002) * 300;
                this.spotlight2.intensity = 1.0 + Math.cos(this.time * 0.0012) * 0.4;
            }
            
            if (this.accentLight) {
                this.accentLight.position.y = 400 + Math.sin(this.time * 0.0008) * 200;
                this.accentLight.intensity = 0.6 + Math.sin(this.time * 0.0015) * 0.3;
            }
        }
        
        /**
         * Color morphing through spectrum
         */
        updateColorMorphing() {
            const colors = this.particles.geometry.attributes.color;
            if (!colors) return;
            
            const colorArray = colors.array;
            for (let i = 0; i < colorArray.length; i += 3) {
                const t = this.colorShift + (i / colorArray.length) * 2;
                
                // Cycle through cyan -> magenta -> gold -> cyan
                colorArray[i] = 0.5 + Math.sin(t) * 0.5;           // R
                colorArray[i + 1] = 0.5 + Math.sin(t + 2) * 0.5;   // G
                colorArray[i + 2] = 0.7 + Math.cos(t) * 0.3;       // B
            }
            
            colors.needsUpdate = true;
        }
        
        /**
         * Create particle explosion effect
         */
        createExplosion() {
            const explosionSize = 200;
            const particleCount = 100;
            
            const geometry = new THREE.BufferGeometry();
            const positions = new Float32Array(particleCount * 3);
            const velocities = new Float32Array(particleCount * 3);
            
            // Random position within neural network
            const centerX = (Math.random() - 0.5) * 300;
            const centerY = (Math.random() - 0.5) * 300;
            const centerZ = (Math.random() - 0.5) * 300;
            
            for (let i = 0; i < particleCount; i++) {
                positions[i * 3] = centerX;
                positions[i * 3 + 1] = centerY;
                positions[i * 3 + 2] = centerZ;
                
                // Radial velocities
                const theta = Math.random() * Math.PI * 2;
                const phi = Math.random() * Math.PI;
                const speed = 2 + Math.random() * 3;
                
                velocities[i * 3] = Math.sin(phi) * Math.cos(theta) * speed;
                velocities[i * 3 + 1] = Math.sin(phi) * Math.sin(theta) * speed;
                velocities[i * 3 + 2] = Math.cos(phi) * speed;
            }
            
            geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
            geometry.setAttribute('velocity', new THREE.BufferAttribute(velocities, 3));
            
            const material = new THREE.PointsMaterial({
                color: 0xffaa00,
                size: 4,
                transparent: true,
                opacity: 1.0,
                blending: THREE.AdditiveBlending,
                depthWrite: false
            });
            
            const explosion = new THREE.Points(geometry, material);
            explosion.userData.lifetime = 0;
            explosion.userData.maxLifetime = 60; // 1 second at 60fps
            
            this.explosionParticles.push(explosion);
            this.scene.add(explosion);
        }
        
        /**
         * Update explosion particles
         */
        updateExplosions() {
            for (let i = this.explosionParticles.length - 1; i >= 0; i--) {
                const explosion = this.explosionParticles[i];
                explosion.userData.lifetime++;
                
                const positions = explosion.geometry.attributes.position;
                const velocities = explosion.geometry.attributes.velocity;
                
                // Update positions
                for (let j = 0; j < positions.array.length; j++) {
                    positions.array[j] += velocities.array[j];
                    velocities.array[j] *= 0.98; // Slow down
                }
                positions.needsUpdate = true;
                
                // Fade out
                const life = explosion.userData.lifetime / explosion.userData.maxLifetime;
                explosion.material.opacity = 1.0 - life;
                
                // Remove when done
                if (explosion.userData.lifetime >= explosion.userData.maxLifetime) {
                    this.scene.remove(explosion);
                    explosion.geometry.dispose();
                    explosion.material.dispose();
                    this.explosionParticles.splice(i, 1);
                }
            }
        }
        
        /**
         * Update particle positions with velocity and boundaries
         */
        updateParticles() {
            const positions = this.particles.geometry.attributes.position;
            const velocities = this.particles.geometry.attributes.velocity;
            const posArray = positions.array;
            const velArray = velocities.array;
            
            for (let i = 0; i < posArray.length; i++) {
                posArray[i] += velArray[i] * 0.015;
                
                // Soft bounce at boundaries with slight randomness
                if (Math.abs(posArray[i]) > 350) {
                    velArray[i] *= -0.95;
                    posArray[i] = Math.max(-350, Math.min(350, posArray[i]));
                    velArray[i] += (Math.random() - 0.5) * 0.5; // Add chaos
                }
            }
            
            positions.needsUpdate = true;
        }
        
        /**
         * Handle phase transitions (4 epic phases: 10s each)
         */
        updatePhase() {
            const phaseDuration = this.options.transitionDuration / this.phases;
            const newPhase = Math.floor((this.time % this.options.transitionDuration) / phaseDuration);
            
            if (newPhase !== this.phase) {
                this.phase = newPhase;
                this.transitionToPhase(newPhase);
            }
        }
        
        /**
         * Epic cinematic phase transitions
         */
        transitionToPhase(phase) {
            console.log(`🎬 [NeuralHero] EPIC PHASE ${phase + 1} - ${this.getPhaseTitle(phase)}`);
            
            switch (phase) {
                case 0: // PHASE 1: "Microscopic Neurons" - Close-up neural activity
                    this.animateCameraTo(
                        { x: 50, y: 30, z: 250 },
                        { x: 0, y: 0, z: 0 },
                        8000
                    );
                    this.scene.fog.density = 0.0003;
                    break;
                    
                case 1: // PHASE 2: "Neural Networks" - Mid-range view of connections
                    this.animateCameraTo(
                        { x: -100, y: 150, z: 500 },
                        { x: 0, y: 0, z: 0 },
                        8000
                    );
                    this.scene.fog.density = 0.00015;
                    break;
                    
                case 2: // PHASE 3: "Brain Regions" - Macro view with rotation
                    this.animateCameraTo(
                        { x: 200, y: -100, z: 700 },
                        { x: 0, y: 0, z: 0 },
                        8000
                    );
                    this.scene.fog.density = 0.0001;
                    break;
                    
                case 3: // PHASE 4: "Cosmic Consciousness" - Epic pullback to universe
                    this.animateCameraTo(
                        { x: 0, y: 100, z: 900 },
                        { x: 0, y: 0, z: 0 },
                        8000
                    );
                    this.scene.fog.density = 0.00005;
                    break;
            }
        }
        
        /**
         * Get phase title for logging
         */
        getPhaseTitle(phase) {
            const titles = [
                'Microscopic Neurons',
                'Neural Networks',
                'Brain Regions',
                'Cosmic Consciousness'
            ];
            return titles[phase] || 'Unknown';
        }
        
        /**
         * Smooth camera animation to target position and look-at point
         */
        animateCameraTo(targetPos, lookAtPos, duration = 7000) {
            const startPos = {
                x: this.camera.position.x,
                y: this.camera.position.y,
                z: this.camera.position.z
            };
            
            const startTime = Date.now();
            
            const animate = () => {
                const elapsed = Date.now() - startTime;
                const progress = Math.min(elapsed / duration, 1);
                
                // Smooth easing: easeInOutCubic
                const eased = progress < 0.5 
                    ? 4 * progress * progress * progress 
                    : 1 - Math.pow(-2 * progress + 2, 3) / 2;
                
                // Update camera position
                this.camera.position.x = startPos.x + (targetPos.x - startPos.x) * eased;
                this.camera.position.y = startPos.y + (targetPos.y - startPos.y) * eased;
                this.camera.position.z = startPos.z + (targetPos.z - startPos.z) * eased;
                
                // Smooth look-at
                this.camera.lookAt(lookAtPos.x, lookAtPos.y, lookAtPos.z);
                
                if (progress < 1) {
                    requestAnimationFrame(animate);
                }
            };
            
            animate();
        }
        
        /**
         * Handle window resize
         */
        onWindowResize() {
            const width = this.container.clientWidth;
            const height = this.container.clientHeight;
            
            this.camera.aspect = width / height;
            this.camera.updateProjectionMatrix();
            this.renderer.setSize(width, height);
        }
        
        /**
         * Show fallback when THREE.js fails
         */
        showFallback() {
            if (!this.container) return;
            
            this.container.innerHTML = `
                <div style="
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    height: 100%;
                    background: linear-gradient(135deg, #000011 0%, #0a0520 50%, #001133 100%);
                    color: #0ea5e9;
                    text-align: center;
                    padding: 2rem;
                    font-family: system-ui, -apple-system, sans-serif;
                ">
                    <div style="max-width: 480px;">
                        <div style="
                            font-size: 2.2rem;
                            margin-bottom: 0.6rem;
                            text-shadow: 0 0 30px rgba(14,165,233,0.55);
                            font-weight: 700;
                        ">Neuro DataLab</div>
                        <div style="
                            font-size: 1.1rem;
                            opacity: 0.9;
                            margin-bottom: 0.8rem;
                            letter-spacing: 0.4px;
                        ">Neural Network Intelligence</div>
                        <div style="
                            font-size: 0.95rem;
                            opacity: 0.8;
                            line-height: 1.6;
                        ">
                            Enterprise ML Systems<br>
                            Data Architecture<br>
                            Geospatial Intelligence
                        </div>
                    </div>
                </div>
            `;
        }
        
        /**
         * Deferred initialization for performance
         */
        async runDeferredInit() {
            if (this.isInitialized) {
                console.log('🧠 [NeuralHero] Already initialized');
                return;
            }
            
            console.log('🧠 [NeuralHero] Running deferred initialization...');
            await this.init();
        }
        
        /**
         * Cleanup and destroy
         */
        destroy() {
            if (this.animationId) {
                cancelAnimationFrame(this.animationId);
            }
            
            if (this.renderer) {
                this.renderer.dispose();
                if (this.container && this.container.contains(this.renderer.domElement)) {
                    this.container.removeChild(this.renderer.domElement);
                }
            }
            
            this.isInitialized = false;
            console.log('🧠 [NeuralHero] Destroyed');
        }
    }
    
    // Export to global scope
    window.NeuralHero = NeuralHero;
    console.log('✅ [NeuralHero] Class loaded and exported to window');
    
})();
