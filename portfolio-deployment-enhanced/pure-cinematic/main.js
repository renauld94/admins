// ============================================================================
// PURE CINEMATIC: NEURAL-TO-COSMIC ANIMATION (105 seconds)
// ============================================================================
// Zero UI. Zero text. Pure visual storytelling.
// From neuron firing to cosmic intelligence. Seamless eternal loop.

class CinematicAnimation {
    constructor() {
        // Scene setup
        this.scene = new THREE.Scene();
        this.scene.background = new THREE.Color(0x000000);
        this.scene.fog = new THREE.Fog(0x000000, 500, 20000);
        
        // Responsive detection
        this.width = window.innerWidth;
        this.height = window.innerHeight;
        this.pixelRatio = Math.min(window.devicePixelRatio, 2);
        this.performance = this.detectDevice();
        
        // Camera
        this.camera = new THREE.PerspectiveCamera(
            85,
            this.width / this.height,
            0.1,
            100000
        );
        this.setupCamera();
        
        // Renderer
        this.renderer = new THREE.WebGLRenderer({
            canvas: document.getElementById('canvas'),
            antialias: true,
            alpha: false,
            precision: 'highp'
        });
        this.renderer.setSize(this.width, this.height);
        this.renderer.setPixelRatio(this.pixelRatio);
        this.renderer.outputColorSpace = THREE.SRGBColorSpace;
        this.renderer.shadowMap.enabled = true;
        this.renderer.shadowMap.type = THREE.PCFShadowShadowMap;
        
        // Timing
        this.startTime = Date.now();
        this.duration = 105000; // 105 seconds
        this.time = 0;
        
        // Containers
        this.scene.containers = {
            neural: new THREE.Group(),
            brains: new THREE.Group(),
            network: new THREE.Group(),
            earth: new THREE.Group(),
            satellites: new THREE.Group(),
            effects: new THREE.Group(),
            stars: new THREE.Group()
        };
        
        for (const key in this.scene.containers) {
            this.scene.add(this.scene.containers[key]);
        }
        
        // Post-processing
        this.setupPostProcessing();
        
        // Initialize everything
        this.init();
    }
    
    detectDevice() {
        const totalPixels = this.width * this.height * (this.pixelRatio ** 2);
        if (totalPixels > 3000000) {
            return { tier: 'desktop', particleScale: 1.0, maxDuration: 105, textureQuality: 1.0 };
        } else if (totalPixels > 1200000) {
            return { tier: 'tablet', particleScale: 0.6, maxDuration: 90, textureQuality: 0.75 };
        } else {
            return { tier: 'mobile', particleScale: 0.3, maxDuration: 75, textureQuality: 0.5 };
        }
    }
    
    setupCamera() {
        // Define complete 105-second camera journey
        this.cameraPath = [
            // Phase 1: Birth (0-15s) - Inside neuron
            { time: 0, pos: [0, 0, 0.3], target: [0, 0, 0], fov: 90 },
            // Transition (15s)
            { time: 15, pos: [0, 0, 5], target: [0, 0, 0], fov: 80 },
            // Phase 2: Minds connecting (15-25s)
            { time: 25, pos: [12, 8, 18], target: [0, 2, 0], fov: 70 },
            // Phase 3: Crystallization (25-35s)
            { time: 35, pos: [25, 18, 35], target: [0, 5, 0], fov: 65 },
            // Phase 4: Regional (35-50s)
            { time: 50, pos: [45, 30, 65], target: [0, 8, 0], fov: 58 },
            // Phase 5: Planetary (50-65s)
            { time: 65, pos: [90, 60, 120], target: [0, 12, 0], fov: 50 },
            // Phase 6: Brain overlay (65-75s)
            { time: 75, pos: [110, 70, 135], target: [0, 15, 0], fov: 48 },
            // Phase 7: Orbital (75-85s)
            { time: 85, pos: [150, 90, 180], target: [0, 20, 0], fov: 45 },
            // Phase 8: Cosmic (85-95s)
            { time: 95, pos: [300, 200, 350], target: [0, 50, 0], fov: 38 },
            // Phase 9: Return (95-105s) and loop
            { time: 105, pos: [0, 0, 0.3], target: [0, 0, 0], fov: 90 }
        ];
        
        this.camera.position.set(0, 0, 0.3);
        this.camera.lookAt(0, 0, 0);
        this.camera.fov = 90;
        this.camera.updateProjectionMatrix();
    }
    
    setupLighting() {
        // Ambient - very low
        const ambient = new THREE.AmbientLight(0xffffff, 0.15);
        this.scene.add(ambient);
        
        // Point light - cyan
        const point = new THREE.PointLight(0x00ffff, 2, 1000);
        point.position.set(50, 50, 50);
        this.scene.add(point);
        
        // Directional - sun-like
        const dirLight = new THREE.DirectionalLight(0xffffff, 1.2);
        dirLight.position.set(200, 150, 200);
        dirLight.castShadow = true;
        dirLight.shadow.mapSize.set(4096, 4096);
        dirLight.shadow.camera.far = 5000;
        this.scene.add(dirLight);
        
        // Hemisphere
        const hemi = new THREE.HemisphereLight(0x0088ff, 0x000000, 0.4);
        this.scene.add(hemi);
    }
    
    setupPostProcessing() {
        this.composer = new THREE.EffectComposer(this.renderer);
        const renderPass = new THREE.RenderPass(this.scene, this.camera);
        this.composer.addPass(renderPass);
        
        // Bloom - heavy for glow effect
        const bloomPass = new THREE.UnrealBloomPass(
            new THREE.Vector2(this.width, this.height),
            2.2, // strength
            0.6, // radius
            0.82 // threshold
        );
        this.composer.addPass(bloomPass);
        
        // Film - subtle grain
        const filmPass = new THREE.FilmPass(0.12, 0, 0, false);
        this.composer.addPass(filmPass);
    }
    
    createNeuralGenesis() {
        // 50,000 organic dendritic particles
        const count = Math.floor(50000 * this.performance.particleScale);
        const geometry = new THREE.BufferGeometry();
        
        const positions = new Float32Array(count * 3);
        const colors = new Float32Array(count * 3);
        const scales = new Float32Array(count);
        const phases = new Float32Array(count);
        
        for (let i = 0; i < count; i++) {
            // Organic branching
            const angle = Math.random() * Math.PI * 2;
            const depth = Math.pow(Math.random(), 0.5) * 2;
            const radius = Math.random() * 1.8 + depth * 0.4;
            
            positions[i * 3] = Math.cos(angle) * radius;
            positions[i * 3 + 1] = Math.sin(angle) * radius;
            positions[i * 3 + 2] = (Math.random() - 0.5) * depth;
            
            // Color palette
            const colorIdx = Math.random();
            if (colorIdx < 0.5) {
                colors[i * 3] = 0.0;
                colors[i * 3 + 1] = 1.0;
                colors[i * 3 + 2] = 1.0; // Cyan
            } else if (colorIdx < 0.8) {
                colors[i * 3] = 0.55;
                colors[i * 3 + 1] = 0.36;
                colors[i * 3 + 2] = 0.96; // Purple
            } else {
                colors[i * 3] = 1.0;
                colors[i * 3 + 1] = 0.42;
                colors[i * 3 + 2] = 0.21; // Orange
            }
            
            scales[i] = Math.random() * 0.3 + 0.1;
            phases[i] = Math.random() * Math.PI * 2;
        }
        
        geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
        geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));
        geometry.setAttribute('scale', new THREE.BufferAttribute(scales, 1));
        geometry.setAttribute('phase', new THREE.BufferAttribute(phases, 1));
        
        const material = new THREE.PointsMaterial({
            size: 0.15,
            vertexColors: true,
            transparent: true,
            opacity: 0.9,
            emissive: 0x00ffff,
            sizeAttenuation: true
        });
        
        const particles = new THREE.Points(geometry, material);
        return particles;
    }
    
    createBrainCluster() {
        // 8 colored brains in space
        const group = new THREE.Group();
        
        const positions = [
            new THREE.Vector3(-10, 0, 0),
            new THREE.Vector3(10, 0, 0),
            new THREE.Vector3(0, 10, 0),
            new THREE.Vector3(0, -10, 0),
            new THREE.Vector3(7, 7, 0),
            new THREE.Vector3(-7, 7, 0),
            new THREE.Vector3(7, -7, 0),
            new THREE.Vector3(-7, -7, 0)
        ];
        
        const colors = [
            0x00ffff, 0x8b5cf6, 0xff6b35, 0xffd700,
            0xffff00, 0xff0066, 0x00ff88, 0xb19cd9
        ];
        
        const labels = ['Cyan', 'Purple', 'Orange', 'Gold', 'Yellow', 'Red', 'Green', 'Violet'];
        
        for (let i = 0; i < 8; i++) {
            const geom = new THREE.IcosahedronGeometry(1.8, 4);
            const mat = new THREE.MeshPhongMaterial({
                color: colors[i],
                emissive: colors[i],
                emissiveIntensity: 0.6,
                wireframe: false,
                shininess: 100
            });
            
            const brain = new THREE.Mesh(geom, mat);
            brain.position.copy(positions[i]);
            brain.castShadow = true;
            brain.receiveShadow = true;
            brain.userData.label = labels[i];
            
            group.add(brain);
        }
        
        return group;
    }
    
    createGlobalNetwork() {
        // 10 nodes: origin + 4 SE Asia + 5 global
        const group = new THREE.Group();
        
        const nodes = [
            { lat: 10.8231, lon: 106.6297, size: 2.2, color: 0x00ffff, name: 'Origin' },
            { lat: 1.3521, lon: 103.8198, size: 1.6, color: 0x00ffff, name: 'Singapore' },
            { lat: 13.7563, lon: 100.5018, size: 1.6, color: 0x8b5cf6, name: 'Bangkok' },
            { lat: -6.2088, lon: 106.8456, size: 1.6, color: 0xff6b35, name: 'Jakarta' },
            { lat: 3.1390, lon: 101.6869, size: 1.6, color: 0xffd700, name: 'KL' },
            { lat: 52.5200, lon: 13.4050, size: 1.8, color: 0x8b5cf6, name: 'Berlin' },
            { lat: 37.7749, lon: -122.4194, size: 1.8, color: 0xff6b35, name: 'SF' },
            { lat: 32.0853, lon: 34.7818, size: 1.6, color: 0xffd700, name: 'TelAviv' },
            { lat: 37.5665, lon: 126.9780, size: 1.6, color: 0xffff00, name: 'Seoul' },
            { lat: -33.8688, lon: 151.2093, size: 1.6, color: 0x00ffff, name: 'Sydney' }
        ];
        
        for (const node of nodes) {
            const lat = node.lat * Math.PI / 180;
            const lon = node.lon * Math.PI / 180;
            const radius = 110;
            
            const x = radius * Math.cos(lat) * Math.cos(lon);
            const y = radius * Math.sin(lat);
            const z = radius * Math.cos(lat) * Math.sin(lon);
            
            const geom = new THREE.SphereGeometry(node.size, 32, 32);
            const mat = new THREE.MeshPhongMaterial({
                color: node.color,
                emissive: node.color,
                emissiveIntensity: 0.8,
                shininess: 150,
                wireframe: false
            });
            
            const mesh = new THREE.Mesh(geom, mat);
            mesh.position.set(x, y, z);
            mesh.castShadow = true;
            mesh.receiveShadow = true;
            mesh.userData.node = node.name;
            
            group.add(mesh);
        }
        
        return group;
    }
    
    createEarth() {
        // Realistic Earth sphere
        const geom = new THREE.SphereGeometry(100, 160, 160);
        
        // Canvas texture for Earth
        const canvas = document.createElement('canvas');
        canvas.width = 4096;
        canvas.height = 2048;
        const ctx = canvas.getContext('2d');
        
        // Ocean
        ctx.fillStyle = '#1a4d6d';
        ctx.fillRect(0, 0, canvas.width, canvas.height);
        
        // Continents
        ctx.fillStyle = '#2d5016';
        // North America
        ctx.fillRect(200, 600, 400, 300);
        // South America
        ctx.fillRect(300, 1000, 250, 300);
        // Europe
        ctx.fillRect(1200, 400, 300, 200);
        // Africa
        ctx.fillRect(1400, 800, 300, 400);
        // Asia
        ctx.fillRect(2000, 500, 600, 400);
        // Australia
        ctx.fillRect(2800, 1200, 200, 160);
        
        // Night lights (simplified)
        ctx.fillStyle = 'rgba(255, 200, 100, 0.3)';
        ctx.fillRect(200, 580, 150, 50);
        ctx.fillRect(1200, 380, 100, 40);
        
        const texture = new THREE.CanvasTexture(canvas);
        
        const mat = new THREE.MeshPhongMaterial({
            map: texture,
            emissive: 0x1a1a2e,
            emissiveIntensity: 0.2,
            shininess: 80
        });
        
        const earth = new THREE.Mesh(geom, mat);
        earth.castShadow = true;
        earth.receiveShadow = true;
        
        // Slowly rotating
        earth.userData.rotating = true;
        
        return earth;
    }
    
    createSatellites() {
        // 12 satellites in various orbits
        const group = new THREE.Group();
        
        const types = [
            { geom: 'octahedron', size: 2, color: 0x00ffff },
            { geom: 'icosahedron', size: 2.5, color: 0x8b5cf6 },
            { geom: 'dodecahedron', size: 2.2, color: 0xff6b35 },
            { geom: 'tetrahedron', size: 2, color: 0xffd700 }
        ];
        
        for (let i = 0; i < 12; i++) {
            const type = types[i % types.length];
            let geom;
            
            switch (type.geom) {
                case 'octahedron':
                    geom = new THREE.OctahedronGeometry(type.size);
                    break;
                case 'icosahedron':
                    geom = new THREE.IcosahedronGeometry(type.size, 2);
                    break;
                case 'dodecahedron':
                    geom = new THREE.DodecahedronGeometry(type.size);
                    break;
                case 'tetrahedron':
                    geom = new THREE.TetrahedronGeometry(type.size);
                    break;
                default:
                    geom = new THREE.SphereGeometry(type.size, 16, 16);
            }
            
            const mat = new THREE.MeshPhongMaterial({
                color: type.color,
                emissive: type.color,
                emissiveIntensity: 0.7,
                shininess: 120,
                metalness: 0.8,
                roughness: 0.2
            });
            
            const sat = new THREE.Mesh(geom, mat);
            
            // Orbital parameters
            const radius = 160 + (i * 12);
            const angle = (i / 12) * Math.PI * 2;
            const inclination = (Math.random() - 0.5) * 0.5;
            
            sat.position.set(
                Math.cos(angle) * radius * Math.cos(inclination),
                Math.sin(inclination) * radius * 30,
                Math.sin(angle) * radius * Math.cos(inclination)
            );
            
            sat.castShadow = true;
            sat.receiveShadow = true;
            
            sat.userData = {
                orbitRadius: radius,
                orbitSpeed: 0.001 + Math.random() * 0.003,
                angle: angle,
                basePos: sat.position.clone()
            };
            
            group.add(sat);
        }
        
        return group;
    }
    
    createStarfield() {
        // 50,000 background stars
        const count = Math.floor(50000 * this.performance.particleScale);
        const geom = new THREE.BufferGeometry();
        
        const positions = new Float32Array(count * 3);
        const colors = new Float32Array(count * 3);
        
        for (let i = 0; i < count; i++) {
            const phi = Math.random() * Math.PI * 2;
            const theta = Math.random() * Math.PI;
            const r = 8000;
            
            positions[i * 3] = r * Math.sin(theta) * Math.cos(phi);
            positions[i * 3 + 1] = r * Math.sin(theta) * Math.sin(phi);
            positions[i * 3 + 2] = r * Math.cos(theta);
            
            const brightness = Math.random() * 0.6 + 0.4;
            colors[i * 3] = brightness;
            colors[i * 3 + 1] = brightness * 0.9;
            colors[i * 3 + 2] = brightness * 0.7;
        }
        
        geom.setAttribute('position', new THREE.BufferAttribute(positions, 3));
        geom.setAttribute('color', new THREE.BufferAttribute(colors, 3));
        
        const mat = new THREE.PointsMaterial({
            size: 2.5,
            vertexColors: true,
            transparent: true,
            opacity: 0.9,
            emissive: 0xffffff
        });
        
        const stars = new THREE.Points(geom, mat);
        return stars;
    }
    
    createBrainWireframe() {
        // Transparent brain overlay
        const geom = new THREE.IcosahedronGeometry(108, 6);
        
        const wireGeom = new THREE.WireframeGeometry(geom);
        const mat = new THREE.LineBasicMaterial({
            color: 0xffffff,
            emissive: 0x8b5cf6,
            transparent: true,
            opacity: 0.25,
            linewidth: 1
        });
        
        const brain = new THREE.LineSegments(wireGeom, mat);
        return brain;
    }
    
    init() {
        console.log('[CINEMATIC] Initializing Pure Cinematic Animation...');
        
        // Setup lighting
        this.setupLighting();
        
        // Create elements
        const neural = this.createNeuralGenesis();
        this.scene.containers.neural.add(neural);
        
        const brains = this.createBrainCluster();
        this.scene.containers.brains.add(brains);
        
        const network = this.createGlobalNetwork();
        this.scene.containers.network.add(network);
        
        const earth = this.createEarth();
        this.scene.containers.earth.add(earth);
        
        const satellites = this.createSatellites();
        this.scene.containers.satellites.add(satellites);
        
        const stars = this.createStarfield();
        this.scene.containers.stars.add(stars);
        
        const brainWire = this.createBrainWireframe();
        this.scene.containers.effects.add(brainWire);
        
        console.log('[CINEMATIC] Initialization complete. Starting render loop.');
        
        // Hide loading dot
        setTimeout(() => this.hideLoading(), 2500);
        
        // Start animation loop
        this.animate();
        
        // Handle resize
        window.addEventListener('resize', () => this.onResize());
    }
    
    hideLoading() {
        const loading = document.getElementById('loading');
        if (loading) {
            loading.style.animation = 'fadeOut 0.5s ease-out forwards';
            setTimeout(() => { loading.style.display = 'none'; }, 500);
        }
    }
    
    interpolateCamera(t) {
        // Find keyframes
        let current = this.cameraPath[0];
        let next = this.cameraPath[1];
        
        for (let i = 0; i < this.cameraPath.length - 1; i++) {
            if (t >= this.cameraPath[i].time && t <= this.cameraPath[i + 1].time) {
                current = this.cameraPath[i];
                next = this.cameraPath[i + 1];
                break;
            }
        }
        
        // Lerp factor
        const segment = next.time - current.time;
        const elapsed = t - current.time;
        let lerp = segment > 0 ? elapsed / segment : 0;
        
        // Apply easing
        if (t <= 65) {
            lerp = this.easeInOutCubic(lerp);
        } else if (t <= 85) {
            lerp = this.easeOutQuad(lerp);
        } else if (t <= 95) {
            lerp = this.easeInQuart(lerp);
        } else {
            lerp = this.easeInExpo(lerp);
        }
        
        // Interpolate
        const pos = [
            THREE.MathUtils.lerp(current.pos[0], next.pos[0], lerp),
            THREE.MathUtils.lerp(current.pos[1], next.pos[1], lerp),
            THREE.MathUtils.lerp(current.pos[2], next.pos[2], lerp)
        ];
        
        const target = [
            THREE.MathUtils.lerp(current.target[0], next.target[0], lerp),
            THREE.MathUtils.lerp(current.target[1], next.target[1], lerp),
            THREE.MathUtils.lerp(current.target[2], next.target[2], lerp)
        ];
        
        const fov = THREE.MathUtils.lerp(current.fov, next.fov, lerp);
        
        return { pos, target, fov };
    }
    
    easeInOutCubic(t) { return t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2; }
    easeOutQuad(t) { return 1 - (1 - t) * (1 - t); }
    easeInQuart(t) { return t * t * t * t; }
    easeInExpo(t) { return t === 0 ? 0 : Math.pow(2, 10 * t - 10); }
    
    updatePhases(t) {
        // 0-15s: Neural birth only
        if (t < 15) {
            this.scene.containers.neural.visible = true;
            this.scene.containers.brains.visible = false;
            this.scene.containers.network.visible = false;
            this.scene.containers.earth.visible = false;
            this.scene.containers.satellites.visible = false;
            this.scene.containers.effects.visible = false;
            this.scene.containers.stars.visible = false;
        }
        // 15-25s: Brains emerge
        else if (t < 25) {
            this.scene.containers.neural.visible = true;
            this.scene.containers.brains.visible = true;
            this.scene.containers.network.visible = false;
            const fade = Math.max(0, (25 - t) / 10);
            this.scene.containers.neural.children[0].material.opacity = 0.3 + fade * 0.6;
        }
        // 25-35s: Crystallization
        else if (t < 35) {
            const phase = (t - 25) / 10;
            this.scene.containers.neural.visible = false;
            this.scene.containers.brains.visible = true;
            this.scene.containers.brains.scale.set(1 - phase * 0.3, 1 - phase * 0.3, 1 - phase * 0.3);
            this.scene.containers.network.visible = true;
            this.scene.containers.earth.visible = true;
            this.scene.containers.earth.scale.set(phase, phase, phase);
        }
        // 35-50s: Regional mesh
        else if (t < 50) {
            this.scene.containers.brains.visible = false;
            this.scene.containers.network.visible = true;
            this.scene.containers.earth.visible = true;
            this.scene.containers.satellites.visible = false;
        }
        // 50-65s: Planetary
        else if (t < 65) {
            this.scene.containers.network.visible = true;
            this.scene.containers.earth.visible = true;
            this.scene.containers.satellites.visible = false;
        }
        // 65-75s: Brain overlay
        else if (t < 75) {
            this.scene.containers.network.visible = true;
            this.scene.containers.earth.visible = true;
            this.scene.containers.effects.visible = true;
            const overlayFade = Math.min(1, (t - 65) / 5);
            this.scene.containers.effects.children[0].material.opacity = overlayFade * 0.25;
        }
        // 75-85s: Satellites
        else if (t < 85) {
            this.scene.containers.satellites.visible = true;
            this.scene.containers.effects.visible = false;
        }
        // 85-95s: Cosmic
        else if (t < 95) {
            this.scene.containers.stars.visible = true;
        }
        // 95-105s: Return
        else {
            const returnPhase = (t - 95) / 10;
            this.scene.containers.neural.visible = true;
            this.scene.containers.neural.children[0].material.opacity = returnPhase * 0.8;
            this.scene.containers.earth.visible = false;
            this.scene.containers.network.visible = false;
            this.scene.containers.satellites.visible = false;
            this.scene.containers.stars.visible = false;
            this.scene.containers.effects.visible = false;
        }
    }
    
    animate() {
        requestAnimationFrame(() => this.animate());
        
        // Seamless loop
        const elapsed = Date.now() - this.startTime;
        this.time = (elapsed % this.duration) / 1000;
        
        // Update camera
        const camera = this.interpolateCamera(this.time);
        this.camera.position.set(camera.pos[0], camera.pos[1], camera.pos[2]);
        this.camera.lookAt(camera.target[0], camera.target[1], camera.target[2]);
        this.camera.fov = camera.fov;
        this.camera.updateProjectionMatrix();
        
        // Update phases
        this.updatePhases(this.time);
        
        // Update satellites
        this.scene.containers.satellites.children.forEach(sat => {
            const data = sat.userData;
            data.angle += data.orbitSpeed;
            
            sat.position.x = Math.cos(data.angle) * data.orbitRadius;
            sat.position.z = Math.sin(data.angle) * data.orbitRadius;
            
            sat.rotation.x += 0.004;
            sat.rotation.y += 0.006;
        });
        
        // Rotate Earth
        if (this.scene.containers.earth.children[0]) {
            this.scene.containers.earth.children[0].rotation.y += 0.0001;
        }
        
        // Brain breathing
        if (this.time > 65 && this.time < 75 && this.scene.containers.effects.visible) {
            const breathe = Math.sin(this.time * 1.5) * 0.05 + 1;
            this.scene.containers.effects.scale.set(breathe, breathe, breathe);
        }
        
        // Render
        this.composer.render();
    }
    
    onResize() {
        this.width = window.innerWidth;
        this.height = window.innerHeight;
        
        this.camera.aspect = this.width / this.height;
        this.camera.updateProjectionMatrix();
        
        this.renderer.setSize(this.width, this.height);
        this.composer.setSize(this.width, this.height);
    }
}

// Initialize on load
document.addEventListener('DOMContentLoaded', () => {
    console.log('[CINEMATIC] DOM loaded. Pure Cinematic: Neural-to-Cosmic Animation starting...');
    new CinematicAnimation();
});

// Pause on visibility change
document.addEventListener('visibilitychange', () => {
    if (document.hidden) {
        console.log('[CINEMATIC] Tab hidden');
    } else {
        console.log('[CINEMATIC] Tab visible');
    }
});
