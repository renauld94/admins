import * as THREE from 'three';
import { EffectComposer } from 'three/addons/postprocessing/EffectComposer.js';
import { RenderPass } from 'three/addons/postprocessing/RenderPass.js';
import { UnrealBloomPass } from 'three/addons/postprocessing/UnrealBloomPass.js';
import { FilmPass } from 'three/addons/postprocessing/FilmPass.js';

// Simon Data Lab Infrastructure Data
const INFRASTRUCTURE = {
  "origin": {
    "lat": 10.8231,
    "lon": 106.6297,
    "name": "Ho Chi Minh City",
    "color": "0x00d4ff"
  },
  "regional_hubs": [
    {
      "lat": 1.3521,
      "lon": 103.8198,
      "name": "Singapore",
      "color": "0x00d4ff"
    },
    {
      "lat": 13.7563,
      "lon": 100.5018,
      "name": "Bangkok",
      "color": "0x8b5cf6"
    },
    {
      "lat": -6.2088,
      "lon": 106.8456,
      "name": "Jakarta",
      "color": "0xff6b35"
    },
    {
      "lat": 3.139,
      "lon": 101.6869,
      "name": "Kuala Lumpur",
      "color": "0xffd700"
    }
  ],
  "global_hubs": [
    {
      "lat": 52.52,
      "lon": 13.405,
      "name": "Berlin",
      "color": "0x8b5cf6"
    },
    {
      "lat": 37.7749,
      "lon": -122.4194,
      "name": "San Francisco",
      "color": "0xff6b35"
    },
    {
      "lat": 32.0853,
      "lon": 34.7818,
      "name": "Tel Aviv",
      "color": "0xffd700"
    },
    {
      "lat": 37.5665,
      "lon": 126.978,
      "name": "Seoul",
      "color": "0xffff00"
    },
    {
      "lat": -33.8688,
      "lon": 151.2093,
      "name": "Sydney",
      "color": "0x00d4ff"
    }
  ],
  "satellites": [
    {
      "name": "VM 159 AI Engine",
      "shape": "octahedron",
      "color": "0x00d4ff",
      "orbit": "low"
    },
    {
      "name": "VM 9001 LMS",
      "shape": "icosahedron",
      "color": "0x8b5cf6",
      "orbit": "medium"
    },
    {
      "name": "ML Training",
      "shape": "dodecahedron",
      "color": "0xff6b35",
      "orbit": "high"
    },
    {
      "name": "Network Science",
      "shape": "cube",
      "color": "0xffff00",
      "orbit": "elliptical"
    },
    {
      "name": "GeoServer",
      "shape": "crystal",
      "color": "0x00ff88",
      "orbit": "geostationary"
    }
  ],
  "departments": [
    {
      "name": "Development",
      "color": "0x00d4ff"
    },
    {
      "name": "Data Science",
      "color": "0x8b5cf6"
    },
    {
      "name": "Design",
      "color": "0xff6b35"
    },
    {
      "name": "Operations",
      "color": "0xffd700"
    },
    {
      "name": "Network Science",
      "color": "0xffff00"
    },
    {
      "name": "ML Research",
      "color": "0xff0066"
    },
    {
      "name": "GeoSpatial",
      "color": "0x00ff88"
    },
    {
      "name": "Learning Platform",
      "color": "0x9d4edd"
    }
  ]
};

// Camera path for 105-second journey
const CAMERA_PATH = [
    { t: 0, pos: [0, 0, 0.5], look: [0, 0, 0], fov: 85 },
    { t: 15, pos: [0, 0, 5], look: [0, 0, 0], fov: 75 },
    { t: 25, pos: [10, 8, 20], look: [0, 2, 0], fov: 70 },
    { t: 35, pos: [20, 15, 35], look: [0, 5, 0], fov: 65 },
    { t: 50, pos: [40, 25, 60], look: [0, 8, 0], fov: 60 },
    { t: 65, pos: [80, 50, 100], look: [0, 10, 0], fov: 55 },
    { t: 85, pos: [120, 70, 150], look: [0, 15, 0], fov: 52 },
    { t: 95, pos: [250, 150, 300], look: [0, 30, 0], fov: 45 },
    { t: 105, pos: [0, 0, 0.5], look: [0, 0, 0], fov: 85 }
];

class CinematicAnimation {
    constructor() {
        this.container = document.getElementById('canvas-container');
        this.clock = new THREE.Clock();
        this.animationTime = 0;
        this.totalDuration = 105; // seconds
        
        this.init();
        this.createScenes();
        this.setupPostProcessing();
        this.animate();
        
        // Hide loading screen when ready
        setTimeout(() => {
            document.getElementById('loading-screen').classList.add('hidden');
        }, 1000);
    }
    
    init() {
        // Renderer setup
        this.renderer = new THREE.WebGLRenderer({ 
            antialias: true,
            powerPreference: 'high-performance'
        });
        this.renderer.setSize(window.innerWidth, window.innerHeight);
        this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
        this.renderer.toneMapping = THREE.ACESFilmicToneMapping;
        this.renderer.toneMappingExposure = 1.0;
        this.container.appendChild(this.renderer.domElement);
        
        // Scene
        this.scene = new THREE.Scene();
        this.scene.background = new THREE.Color(0x000000);
        
        // Camera
        this.camera = new THREE.PerspectiveCamera(
            85,
            window.innerWidth / window.innerHeight,
            0.1,
            10000
        );
        this.camera.position.set(0, 0, 0.5);
        
        // Responsive
        window.addEventListener('resize', () => this.onResize());
    }
    
    createScenes() {
        // Act 1: Neural Genesis
        this.neuralParticles = this.createNeuralParticles();
        this.scene.add(this.neuralParticles);
        
        // Act 2: Brain structures
        this.brainGroup = this.createBrainStructures();
        this.brainGroup.visible = false;
        this.scene.add(this.brainGroup);
        
        // Act 3-5: Global network with Earth
        this.earthGroup = this.createEarthNetwork();
        this.earthGroup.visible = false;
        this.scene.add(this.earthGroup);
        
        // Act 6: Brain overlay
        this.brainOverlay = this.createBrainOverlay();
        this.brainOverlay.visible = false;
        this.scene.add(this.brainOverlay);
        
        // Act 7: Satellites
        this.satelliteGroup = this.createSatellites();
        this.satelliteGroup.visible = false;
        this.scene.add(this.satelliteGroup);
        
        // Act 8: Cosmic scale
        this.cosmicGroup = this.createCosmicScene();
        this.cosmicGroup.visible = false;
        this.scene.add(this.cosmicGroup);
        
        // Lights
        const ambientLight = new THREE.AmbientLight(0xffffff, 0.3);
        this.scene.add(ambientLight);
        
        const pointLight = new THREE.PointLight(0x00d4ff, 2, 100);
        pointLight.position.set(0, 0, 0);
        this.scene.add(pointLight);
    }
    
    createNeuralParticles() {
        const particleCount = window.innerWidth < 768 ? 12500 : 50000;
        const geometry = new THREE.BufferGeometry();
        const positions = new Float32Array(particleCount * 3);
        const colors = new Float32Array(particleCount * 3);
        const phases = new Float32Array(particleCount);
        
        const colorPalette = [
            new THREE.Color(0x00d4ff), // cyan
            new THREE.Color(0x8b5cf6), // purple
            new THREE.Color(0xff69b4)  // pink
        ];
        
        for (let i = 0; i < particleCount; i++) {
            // Spherical distribution
            const radius = Math.random() * 3;
            const theta = Math.random() * Math.PI * 2;
            const phi = Math.acos(2 * Math.random() - 1);
            
            positions[i * 3] = radius * Math.sin(phi) * Math.cos(theta);
            positions[i * 3 + 1] = radius * Math.sin(phi) * Math.sin(theta);
            positions[i * 3 + 2] = radius * Math.cos(phi);
            
            const color = colorPalette[Math.floor(Math.random() * colorPalette.length)];
            colors[i * 3] = color.r;
            colors[i * 3 + 1] = color.g;
            colors[i * 3 + 2] = color.b;
            
            phases[i] = Math.random() * Math.PI * 2;
        }
        
        geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
        geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));
        geometry.setAttribute('phase', new THREE.BufferAttribute(phases, 1));
        
        const material = new THREE.PointsMaterial({
            size: 0.05,
            vertexColors: true,
            blending: THREE.AdditiveBlending,
            transparent: true,
            opacity: 0.8
        });
        
        return new THREE.Points(geometry, material);
    }
    
    createBrainStructures() {
        const group = new THREE.Group();
        const departments = INFRASTRUCTURE.departments;
        
        departments.forEach((dept, index) => {
            const brainGeometry = new THREE.IcosahedronGeometry(1, 2);
            const brainMaterial = new THREE.MeshStandardMaterial({
                color: parseInt(dept.color),
                emissive: parseInt(dept.color),
                emissiveIntensity: 0.5,
                transparent: true,
                opacity: 0.7
            });
            
            const brain = new THREE.Mesh(brainGeometry, brainMaterial);
            
            // Arrange in circle
            const angle = (index / departments.length) * Math.PI * 2;
            const radius = 5;
            brain.position.set(
                Math.cos(angle) * radius,
                Math.sin(angle) * radius * 0.3,
                Math.sin(angle) * radius
            );
            
            group.add(brain);
        });
        
        return group;
    }
    
    createEarthNetwork() {
        const group = new THREE.Group();
        
        // Earth sphere
        const earthGeometry = new THREE.SphereGeometry(100, 128, 128);
        const earthMaterial = new THREE.MeshStandardMaterial({
            color: 0x1a4d7a,
            emissive: 0x0a2d4a,
            roughness: 0.9,
            metalness: 0.1
        });
        
        const earth = new THREE.Mesh(earthGeometry, earthMaterial);
        group.add(earth);
        
        // Atmosphere
        const atmosphereGeometry = new THREE.SphereGeometry(102, 128, 128);
        const atmosphereMaterial = new THREE.ShaderMaterial({
            vertexShader: `
                varying vec3 vNormal;
                varying vec3 vPosition;
                void main() {
                    vNormal = normalize(normalMatrix * normal);
                    vPosition = (modelMatrix * vec4(position, 1.0)).xyz;
                    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
                }
            `,
            fragmentShader: `
                varying vec3 vNormal;
                varying vec3 vPosition;
                uniform vec3 cameraPosition;
                void main() {
                    vec3 viewDir = normalize(cameraPosition - vPosition);
                    float fresnel = pow(1.0 - dot(viewDir, vNormal), 3.0);
                    vec3 glow = vec3(0.3, 0.6, 1.0) * fresnel * 2.0;
                    gl_FragColor = vec4(glow, fresnel * 0.5);
                }
            `,
            transparent: true,
            side: THREE.BackSide,
            blending: THREE.AdditiveBlending
        });
        
        const atmosphere = new THREE.Mesh(atmosphereGeometry, atmosphereMaterial);
        group.add(atmosphere);
        
        // City nodes
        const allNodes = [INFRASTRUCTURE.origin, ...INFRASTRUCTURE.regional_hubs, ...INFRASTRUCTURE.global_hubs];
        
        allNodes.forEach(node => {
            const nodeGeometry = new THREE.SphereGeometry(node.name === 'Ho Chi Minh City' ? 2 : 1.5, 16, 16);
            const nodeMaterial = new THREE.MeshBasicMaterial({
                color: parseInt(node.color),
                transparent: true,
                opacity: 0.9
            });
            
            const nodeMesh = new THREE.Mesh(nodeGeometry, nodeMaterial);
            
            // Convert lat/lon to 3D position
            const phi = (90 - node.lat) * (Math.PI / 180);
            const theta = (node.lon + 180) * (Math.PI / 180);
            const radius = 101;
            
            nodeMesh.position.set(
                -(radius * Math.sin(phi) * Math.cos(theta)),
                radius * Math.cos(phi),
                radius * Math.sin(phi) * Math.sin(theta)
            );
            
            group.add(nodeMesh);
            
            // Add glow
            const glowGeometry = new THREE.SphereGeometry(node.name === 'Ho Chi Minh City' ? 3 : 2.5, 16, 16);
            const glowMaterial = new THREE.MeshBasicMaterial({
                color: parseInt(node.color),
                transparent: true,
                opacity: 0.3,
                blending: THREE.AdditiveBlending
            });
            const glow = new THREE.Mesh(glowGeometry, glowMaterial);
            glow.position.copy(nodeMesh.position);
            group.add(glow);
        });
        
        return group;
    }
    
    createBrainOverlay() {
        const group = new THREE.Group();
        
        // Wireframe brain structure
        const brainGeometry = new THREE.IcosahedronGeometry(105, 3);
        const brainMaterial = new THREE.MeshBasicMaterial({
            color: 0xffffff,
            wireframe: true,
            transparent: true,
            opacity: 0.3
        });
        
        const brain = new THREE.Mesh(brainGeometry, brainMaterial);
        brain.position.set(0, 50, 0);
        brain.scale.set(1, 0.5, 1);
        group.add(brain);
        
        return group;
    }
    
    createSatellites() {
        const group = new THREE.Group();
        
        INFRASTRUCTURE.satellites.forEach((sat, index) => {
            let geometry;
            switch(sat.shape) {
                case 'octahedron':
                    geometry = new THREE.OctahedronGeometry(3);
                    break;
                case 'icosahedron':
                    geometry = new THREE.IcosahedronGeometry(3);
                    break;
                case 'dodecahedron':
                    geometry = new THREE.DodecahedronGeometry(3);
                    break;
                case 'cube':
                    geometry = new THREE.BoxGeometry(5, 5, 5);
                    break;
                default:
                    geometry = new THREE.TetrahedronGeometry(3);
            }
            
            const material = new THREE.MeshStandardMaterial({
                color: parseInt(sat.color),
                emissive: parseInt(sat.color),
                emissiveIntensity: 0.7,
                metalness: 0.8,
                roughness: 0.2
            });
            
            const satellite = new THREE.Mesh(geometry, material);
            
            // Orbital positioning
            const orbitRadius = sat.orbit === 'low' ? 115 : sat.orbit === 'medium' ? 130 : sat.orbit === 'high' ? 145 : 125;
            const angle = (index / INFRASTRUCTURE.satellites.length) * Math.PI * 2;
            
            satellite.position.set(
                Math.cos(angle) * orbitRadius,
                Math.sin(angle) * orbitRadius * 0.3,
                Math.sin(angle) * orbitRadius
            );
            
            satellite.userData = { orbitRadius, angle, speed: sat.orbit === 'low' ? 0.02 : 0.01 };
            
            group.add(satellite);
        });
        
        return group;
    }
    
    createCosmicScene() {
        const group = new THREE.Group();
        
        // Star field
        const starCount = window.innerWidth < 768 ? 12500 : 50000;
        const starGeometry = new THREE.BufferGeometry();
        const starPositions = new Float32Array(starCount * 3);
        
        for (let i = 0; i < starCount; i++) {
            starPositions[i * 3] = (Math.random() - 0.5) * 2000;
            starPositions[i * 3 + 1] = (Math.random() - 0.5) * 2000;
            starPositions[i * 3 + 2] = (Math.random() - 0.5) * 2000;
        }
        
        starGeometry.setAttribute('position', new THREE.BufferAttribute(starPositions, 3));
        
        const starMaterial = new THREE.PointsMaterial({
            color: 0xffffff,
            size: 2,
            blending: THREE.AdditiveBlending,
            transparent: true
        });
        
        const stars = new THREE.Points(starGeometry, starMaterial);
        group.add(stars);
        
        return group;
    }
    
    setupPostProcessing() {
        this.composer = new EffectComposer(this.renderer);
        
        const renderPass = new RenderPass(this.scene, this.camera);
        this.composer.addPass(renderPass);
        
        this.bloomPass = new UnrealBloomPass(
            new THREE.Vector2(window.innerWidth, window.innerHeight),
            2.0,
            0.5,
            0.85
        );
        this.composer.addPass(this.bloomPass);
        
        const filmPass = new FilmPass(0.15, 0.5, 2048, false);
        this.composer.addPass(filmPass);
    }
    
    updateCamera(t) {
        // Find two keyframes to interpolate between
        let startFrame, endFrame;
        for (let i = 0; i < CAMERA_PATH.length - 1; i++) {
            if (t >= CAMERA_PATH[i].t && t <= CAMERA_PATH[i + 1].t) {
                startFrame = CAMERA_PATH[i];
                endFrame = CAMERA_PATH[i + 1];
                break;
            }
        }
        
        if (!startFrame || !endFrame) return;
        
        // Interpolation factor
        const duration = endFrame.t - startFrame.t;
        const elapsed = t - startFrame.t;
        const alpha = this.easeInOutCubic(elapsed / duration);
        
        // Interpolate position
        this.camera.position.x = THREE.MathUtils.lerp(startFrame.pos[0], endFrame.pos[0], alpha);
        this.camera.position.y = THREE.MathUtils.lerp(startFrame.pos[1], endFrame.pos[1], alpha);
        this.camera.position.z = THREE.MathUtils.lerp(startFrame.pos[2], endFrame.pos[2], alpha);
        
        // Interpolate FOV
        this.camera.fov = THREE.MathUtils.lerp(startFrame.fov, endFrame.fov, alpha);
        this.camera.updateProjectionMatrix();
        
        // Look at target
        const lookTarget = new THREE.Vector3(
            THREE.MathUtils.lerp(startFrame.look[0], endFrame.look[0], alpha),
            THREE.MathUtils.lerp(startFrame.look[1], endFrame.look[1], alpha),
            THREE.MathUtils.lerp(startFrame.look[2], endFrame.look[2], alpha)
        );
        this.camera.lookAt(lookTarget);
    }
    
    easeInOutCubic(t) {
        return t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2;
    }
    
    updateSceneVisibility(t) {
        // Act transitions
        this.neuralParticles.visible = t < 30;
        this.brainGroup.visible = t >= 15 && t < 35;
        this.earthGroup.visible = t >= 25;
        this.brainOverlay.visible = t >= 65 && t < 85;
        this.satelliteGroup.visible = t >= 75;
        this.cosmicGroup.visible = t >= 85;
    }
    
    updateAnimations(t, delta) {
        // Neural particles animation
        if (this.neuralParticles.visible) {
            const positions = this.neuralParticles.geometry.attributes.position;
            const phases = this.neuralParticles.geometry.attributes.phase;
            
            for (let i = 0; i < positions.count; i++) {
                const phase = phases.array[i];
                const pulse = Math.sin(t * 2 + phase) * 0.5 + 0.5;
                const scale = 1 + pulse * 0.15;
                
                positions.array[i * 3] *= scale;
                positions.array[i * 3 + 1] *= scale;
                positions.array[i * 3 + 2] *= scale;
            }
            positions.needsUpdate = true;
            
            this.neuralParticles.rotation.y += delta * 0.1;
        }
        
        // Brain structures animation
        if (this.brainGroup.visible) {
            this.brainGroup.children.forEach((brain, index) => {
                const pulse = Math.sin(t * 2 + index) * 0.02 + 1;
                brain.scale.set(pulse, pulse, pulse);
            });
            this.brainGroup.rotation.y += delta * 0.2;
        }
        
        // Earth rotation
        if (this.earthGroup.visible) {
            this.earthGroup.rotation.y += delta * 0.05;
        }
        
        // Brain overlay breathing
        if (this.brainOverlay.visible) {
            const breathe = Math.sin(t * 0.5) * 0.02 + 1;
            this.brainOverlay.scale.set(breathe, breathe, breathe);
        }
        
        // Satellite orbits
        if (this.satelliteGroup.visible) {
            this.satelliteGroup.children.forEach(satellite => {
                satellite.userData.angle += delta * satellite.userData.speed;
                const r = satellite.userData.orbitRadius;
                satellite.position.set(
                    Math.cos(satellite.userData.angle) * r,
                    Math.sin(satellite.userData.angle) * r * 0.3,
                    Math.sin(satellite.userData.angle) * r
                );
                satellite.rotation.y += delta;
            });
        }
    }
    
    animate() {
        requestAnimationFrame(() => this.animate());
        
        const delta = this.clock.getDelta();
        this.animationTime += delta;
        
        // Loop seamlessly
        if (this.animationTime >= this.totalDuration) {
            this.animationTime = 0;
        }
        
        // Update camera position
        this.updateCamera(this.animationTime);
        
        // Update scene visibility
        this.updateSceneVisibility(this.animationTime);
        
        // Update animations
        this.updateAnimations(this.animationTime, delta);
        
        // Render with post-processing
        this.composer.render();
    }
    
    onResize() {
        this.camera.aspect = window.innerWidth / window.innerHeight;
        this.camera.updateProjectionMatrix();
        this.renderer.setSize(window.innerWidth, window.innerHeight);
        this.composer.setSize(window.innerWidth, window.innerHeight);
    }
}

// Initialize when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => new CinematicAnimation());
} else {
    new CinematicAnimation();
}