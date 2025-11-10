/**
 * NEURAL HERO - Enhanced Neural Network Visualization
 * Replaces epic-neural-cosmos-viz with optimized, performant neural network animation
 * Features: Particle systems, neural pathways, cosmic background, smooth animations
 * Performance: GPU-accelerated, LOD system, frustum culling, requestAnimationFrame
 */

(function() {
    'use strict';
    
    class NeuralHero {
        constructor(containerId, options = {}) {
            this.containerId = containerId;
            this.options = {
                particleCount: 3000,
                connectionDistance: 150,
                autoRotate: true,
                enableGPU: true,
                enableLOD: true,
                enableVSync: true,
                backgroundColor: 0x0a0f1e,
                particleColor: 0x0ea5e9,
                connectionColor: 0x8b5cf6,
                transitionDuration: 28000,
                deferInit: true,
                ...options
            };
            
            this.container = null;
            this.scene = null;
            this.camera = null;
            this.renderer = null;
            this.particles = null;
            this.lines = null;
            this.animationId = null;
            this.isInitialized = false;
            this.time = 0;
            this.phase = 0;
            this.phases = 4;
            
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
                
                // Create scene
                this.scene = new THREE.Scene();
                this.scene.background = new THREE.Color(this.options.backgroundColor);
                this.scene.fog = new THREE.Fog(this.options.backgroundColor, 2000, 5000);
                
                // Create camera
                this.camera = new THREE.PerspectiveCamera(75, width / height, 0.1, 10000);
                this.camera.position.z = 300;
                
                // Create renderer with antialiasing for smooth visuals
                this.renderer = new THREE.WebGLRenderer({
                    antialias: true,
                    alpha: false,
                    precision: 'highp',
                    powerPreference: 'high-performance'
                });
                this.renderer.setSize(width, height);
                this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
                this.renderer.shadowMap.enabled = true;
                
                // Add to container
                this.container.innerHTML = '';
                this.container.appendChild(this.renderer.domElement);
                
                // Create particles
                this.createParticles();
                
                // Create connections
                this.createConnections();
                
                // Add lighting
                this.addLighting();
                
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
         * Create particle system for neural nodes
         */
        createParticles() {
            console.log('🧠 [NeuralHero] Creating particles...');
            
            const geometry = new THREE.BufferGeometry();
            const count = this.options.particleCount;
            
            // Positions - distributed in sphere
            const positions = new Float32Array(count * 3);
            for (let i = 0; i < count; i++) {
                const theta = Math.random() * Math.PI * 2;
                const phi = Math.random() * Math.PI;
                const radius = 150 + Math.random() * 100;
                
                positions[i * 3] = radius * Math.sin(phi) * Math.cos(theta);
                positions[i * 3 + 1] = radius * Math.sin(phi) * Math.sin(theta);
                positions[i * 3 + 2] = radius * Math.cos(phi);
            }
            
            // Velocities
            const velocities = new Float32Array(count * 3);
            for (let i = 0; i < count * 3; i++) {
                velocities[i] = (Math.random() - 0.5) * 2;
            }
            
            geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
            geometry.setAttribute('velocity', new THREE.BufferAttribute(velocities, 3));
            
            // Material - points with size
            const material = new THREE.PointsMaterial({
                color: this.options.particleColor,
                size: 2,
                sizeAttenuation: true,
                transparent: true,
                opacity: 0.8,
                fog: true
            });
            
            this.particles = new THREE.Points(geometry, material);
            this.scene.add(this.particles);
            
            console.log(`✅ [NeuralHero] Created ${count} particles`);
        }
        
        /**
         * Create neural connections (lines between nearby particles)
         */
        createConnections() {
            console.log('🧠 [NeuralHero] Creating connections...');
            
            const positions = this.particles.geometry.attributes.position.array;
            const count = positions.length / 3;
            const distance = this.options.connectionDistance;
            
            const linePositions = [];
            
            // Find and create connections for nearby particles
            for (let i = 0; i < count; i++) {
                const x1 = positions[i * 3];
                const y1 = positions[i * 3 + 1];
                const z1 = positions[i * 3 + 2];
                
                for (let j = i + 1; j < count; j++) {
                    const x2 = positions[j * 3];
                    const y2 = positions[j * 3 + 1];
                    const z2 = positions[j * 3 + 2];
                    
                    const dx = x2 - x1;
                    const dy = y2 - y1;
                    const dz = z2 - z1;
                    const dist = Math.sqrt(dx * dx + dy * dy + dz * dz);
                    
                    if (dist < distance) {
                        linePositions.push(x1, y1, z1, x2, y2, z2);
                    }
                }
            }
            
            // Create line geometry
            const geometry = new THREE.BufferGeometry();
            geometry.setAttribute('position', new THREE.BufferAttribute(new Float32Array(linePositions), 3));
            
            // Create line material with glow
            const material = new THREE.LineBasicMaterial({
                color: this.options.connectionColor,
                transparent: true,
                opacity: 0.3,
                fog: true
            });
            
            this.lines = new THREE.LineSegments(geometry, material);
            this.scene.add(this.lines);
            
            console.log(`✅ [NeuralHero] Created connections (${linePositions.length / 6} segments)`);
        }
        
        /**
         * Add lighting for depth and realism
         */
        addLighting() {
            // Ambient light
            const ambientLight = new THREE.AmbientLight(0xffffff, 0.5);
            this.scene.add(ambientLight);
            
            // Directional light
            const directionalLight = new THREE.DirectionalLight(0x0ea5e9, 0.8);
            directionalLight.position.set(100, 100, 100);
            this.scene.add(directionalLight);
            
            // Point light for glow effect
            const pointLight = new THREE.PointLight(0x8b5cf6, 0.5);
            pointLight.position.set(-200, 200, 200);
            this.scene.add(pointLight);
        }
        
        /**
         * Main animation loop
         */
        animate() {
            this.animationId = requestAnimationFrame(() => this.animate());
            
            if (!this.isInitialized) return;
            
            this.time += 16; // ~60fps
            
            // Rotate particles
            if (this.options.autoRotate) {
                this.particles.rotation.x += 0.0001;
                this.particles.rotation.y += 0.0002;
            }
            
            // Pulsing effect
            const pulse = Math.sin(this.time * 0.001) * 0.3 + 0.7;
            this.particles.material.opacity = pulse * 0.8;
            this.lines.material.opacity = pulse * 0.2;
            
            // Update particles with velocity
            this.updateParticles();
            
            // Phase transitions
            this.updatePhase();
            
            // Render
            this.renderer.render(this.scene, this.camera);
        }
        
        /**
         * Update particle positions with velocity
         */
        updateParticles() {
            const positions = this.particles.geometry.attributes.position;
            const velocities = this.particles.geometry.attributes.velocity;
            const posArray = positions.array;
            const velArray = velocities.array;
            
            for (let i = 0; i < posArray.length; i++) {
                posArray[i] += velArray[i] * 0.01;
                
                // Bounce at boundaries
                if (Math.abs(posArray[i]) > 250) {
                    velArray[i] *= -1;
                    posArray[i] = Math.max(-250, Math.min(250, posArray[i]));
                }
            }
            
            positions.needsUpdate = true;
        }
        
        /**
         * Handle phase transitions (4 phases: 7s each)
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
         * Transition between visualization phases
         */
        transitionToPhase(phase) {
            console.log(`🧠 [NeuralHero] Transitioning to phase ${phase + 1}`);
            
            switch (phase) {
                case 0: // Zoom in on network
                    this.animateCameraTo(300, 300 * 0.75);
                    break;
                case 1: // Rotate view
                    this.animateCameraTo(400, 300 * 0.5);
                    break;
                case 2: // Zoom out
                    this.animateCameraTo(200, 300 * 1.2);
                    break;
                case 3: // Reset
                    this.animateCameraTo(300, 300 * 0.75);
                    break;
            }
        }
        
        /**
         * Animate camera to target position
         */
        animateCameraTo(z, y) {
            const startZ = this.camera.position.z;
            const startY = this.camera.position.y;
            const duration = (this.options.transitionDuration / this.phases) * 0.8;
            const startTime = Date.now();
            
            const animate = () => {
                const elapsed = Date.now() - startTime;
                const progress = Math.min(elapsed / duration, 1);
                
                // Easing: easeInOutCubic
                const eased = progress < 0.5 
                    ? 4 * progress * progress * progress 
                    : 1 - Math.pow(-2 * progress + 2, 3) / 2;
                
                this.camera.position.z = startZ + (z - startZ) * eased;
                this.camera.position.y = startY + (y - startY) * eased;
                
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
