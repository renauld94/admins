/**
 * Learning Universe - Three.js 3D Learning Environment
 * Part of the "From Data to Mastery: An Intelligent Learning Odyssey"
 */

import * as THREE from 'three';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';
import { EffectComposer } from 'three/examples/jsm/postprocessing/EffectComposer.js';
import { RenderPass } from 'three/examples/jsm/postprocessing/RenderPass.js';
import { UnrealBloomPass } from 'three/examples/jsm/postprocessing/UnrealBloomPass.js';

class LearningUniverse {
    constructor(containerId) {
        this.container = document.getElementById(containerId);
        this.scene = new THREE.Scene();
        this.camera = null;
        this.renderer = null;
        this.controls = null;
        this.composer = null;
        
        // Learning modules as 3D objects
        this.modules = new Map();
        this.achievements = [];
        this.neuralPathways = [];
        this.particles = null;
        
        // Animation and interaction
        this.clock = new THREE.Clock();
        this.mouse = new THREE.Vector2();
        this.raycaster = new THREE.Raycaster();
        this.selectedModule = null;
        
        // Learning data
        this.learnerProgress = {};
        this.communityData = {};
        
        this.init();
    }
    
    init() {
        this.setupScene();
        this.setupCamera();
        this.setupRenderer();
        this.setupControls();
        this.setupLighting();
        this.setupPostProcessing();
        this.createLearningModules();
        this.createNeuralPathways();
        this.createParticleSystem();
        this.setupEventListeners();
        this.animate();
    }
    
    setupScene() {
        // Create a cosmic background
        const geometry = new THREE.SphereGeometry(500, 60, 40);
        const material = new THREE.MeshBasicMaterial({
            map: this.createStarFieldTexture(),
            side: THREE.BackSide
        });
        const skybox = new THREE.Mesh(geometry, material);
        this.scene.add(skybox);
        
        // Add ambient lighting for mystical effect
        const ambientLight = new THREE.AmbientLight(0x404040, 0.3);
        this.scene.add(ambientLight);
    }
    
    setupCamera() {
        this.camera = new THREE.PerspectiveCamera(
            75,
            this.container.clientWidth / this.container.clientHeight,
            0.1,
            1000
        );
        this.camera.position.set(0, 20, 50);
    }
    
    setupRenderer() {
        this.renderer = new THREE.WebGLRenderer({ 
            antialias: true,
            alpha: true 
        });
        this.renderer.setSize(this.container.clientWidth, this.container.clientHeight);
        this.renderer.setPixelRatio(window.devicePixelRatio);
        this.renderer.shadowMap.enabled = true;
        this.renderer.shadowMap.type = THREE.PCFSoftShadowMap;
        this.container.appendChild(this.renderer.domElement);
    }
    
    setupControls() {
        this.controls = new OrbitControls(this.camera, this.renderer.domElement);
        this.controls.enableDamping = true;
        this.controls.dampingFactor = 0.05;
        this.controls.enableZoom = true;
        this.controls.enablePan = true;
        this.controls.maxPolarAngle = Math.PI / 2;
    }
    
    setupLighting() {
        // Main directional light
        const directionalLight = new THREE.DirectionalLight(0xffffff, 1);
        directionalLight.position.set(50, 50, 50);
        directionalLight.castShadow = true;
        directionalLight.shadow.mapSize.width = 2048;
        directionalLight.shadow.mapSize.height = 2048;
        this.scene.add(directionalLight);
        
        // Point lights for each module
        const pointLight1 = new THREE.PointLight(0x00ff00, 0.5, 100);
        pointLight1.position.set(0, 0, 0);
        this.scene.add(pointLight1);
        
        const pointLight2 = new THREE.PointLight(0x0066ff, 0.5, 100);
        pointLight2.position.set(20, 0, 0);
        this.scene.add(pointLight2);
    }
    
    setupPostProcessing() {
        this.composer = new EffectComposer(this.renderer);
        
        const renderPass = new RenderPass(this.scene, this.camera);
        this.composer.addPass(renderPass);
        
        const bloomPass = new UnrealBloomPass(
            new THREE.Vector2(this.container.clientWidth, this.container.clientHeight),
            1.5, 0.4, 0.85
        );
        this.composer.addPass(bloomPass);
    }
    
    createLearningModules() {
        const moduleData = [
            {
                id: 'system-setup',
                name: 'The Awakening',
                position: [0, 0, 0],
                color: 0x00ff00,
                status: 'completed',
                description: 'Foundation setup for development environment'
            },
            {
                id: 'core-python',
                name: 'Data Literacy Awakening',
                position: [15, 5, 0],
                color: 0x0066ff,
                status: 'completed',
                description: 'Python fundamentals and advanced concepts'
            },
            {
                id: 'pyspark',
                name: 'Map of Lost Pipelines',
                position: [30, -5, 10],
                color: 0xff6600,
                status: 'in-progress',
                description: 'Big data processing with Apache Spark'
            },
            {
                id: 'git-bitbucket',
                name: 'Code of Collaboration',
                position: [45, 0, 0],
                color: 0x9900ff,
                status: 'locked',
                description: 'Version control and collaboration'
            },
            {
                id: 'databricks',
                name: 'Cloud Citadel',
                position: [60, 10, 0],
                color: 0xff0066,
                status: 'locked',
                description: 'Cloud-based data engineering platform'
            },
            {
                id: 'advanced-topics',
                name: 'Rise of the Data Guardian',
                position: [75, 0, 0],
                color: 0xffff00,
                status: 'locked',
                description: 'Advanced applications and capstone'
            }
        ];
        
        moduleData.forEach(module => {
            const moduleObject = this.createModuleObject(module);
            this.modules.set(module.id, moduleObject);
            this.scene.add(moduleObject);
        });
    }
    
    createModuleObject(moduleData) {
        const group = new THREE.Group();
        
        // Main module sphere
        const geometry = new THREE.SphereGeometry(3, 32, 32);
        const material = new THREE.MeshPhongMaterial({
            color: moduleData.color,
            transparent: true,
            opacity: 0.8,
            emissive: moduleData.color,
            emissiveIntensity: 0.2
        });
        const sphere = new THREE.Mesh(geometry, material);
        sphere.castShadow = true;
        sphere.receiveShadow = true;
        sphere.userData = { moduleId: moduleData.id, type: 'module' };
        group.add(sphere);
        
        // Status indicator ring
        const ringGeometry = new THREE.RingGeometry(3.5, 4, 32);
        const ringMaterial = new THREE.MeshBasicMaterial({
            color: this.getStatusColor(moduleData.status),
            transparent: true,
            opacity: 0.6,
            side: THREE.DoubleSide
        });
        const ring = new THREE.Mesh(ringGeometry, ringMaterial);
        ring.rotation.x = Math.PI / 2;
        group.add(ring);
        
        // Module label
        const label = this.createTextLabel(moduleData.name);
        label.position.set(0, 5, 0);
        group.add(label);
        
        // Position the module
        group.position.set(...moduleData.position);
        
        // Add pulsing animation
        this.addPulsingAnimation(group, moduleData.status);
        
        return group;
    }
    
    createTextLabel(text) {
        const canvas = document.createElement('canvas');
        const context = canvas.getContext('2d');
        canvas.width = 256;
        canvas.height = 64;
        
        context.fillStyle = 'rgba(0, 0, 0, 0.8)';
        context.fillRect(0, 0, canvas.width, canvas.height);
        
        context.fillStyle = 'white';
        context.font = '16px Arial';
        context.textAlign = 'center';
        context.fillText(text, canvas.width / 2, canvas.height / 2 + 5);
        
        const texture = new THREE.CanvasTexture(canvas);
        const material = new THREE.SpriteMaterial({ map: texture });
        const sprite = new THREE.Sprite(material);
        sprite.scale.set(8, 2, 1);
        
        return sprite;
    }
    
    getStatusColor(status) {
        const colors = {
            'completed': 0x00ff00,
            'in-progress': 0xffaa00,
            'locked': 0x666666
        };
        return colors[status] || 0x666666;
    }
    
    addPulsingAnimation(group, status) {
        if (status === 'in-progress') {
            const pulse = () => {
                const scale = 1 + Math.sin(Date.now() * 0.003) * 0.1;
                group.scale.setScalar(scale);
                requestAnimationFrame(pulse);
            };
            pulse();
        }
    }
    
    createNeuralPathways() {
        // Create connections between modules
        const modulePositions = Array.from(this.modules.values()).map(module => module.position);
        
        for (let i = 0; i < modulePositions.length - 1; i++) {
            const pathway = this.createNeuralPathway(
                modulePositions[i],
                modulePositions[i + 1]
            );
            this.neuralPathways.push(pathway);
            this.scene.add(pathway);
        }
    }
    
    createNeuralPathway(startPos, endPos) {
        const group = new THREE.Group();
        
        // Create curved path
        const curve = new THREE.QuadraticBezierCurve3(
            new THREE.Vector3(...startPos),
            new THREE.Vector3(
                (startPos[0] + endPos[0]) / 2,
                Math.max(startPos[1], endPos[1]) + 10,
                (startPos[2] + endPos[2]) / 2
            ),
            new THREE.Vector3(...endPos)
        );
        
        const points = curve.getPoints(50);
        const geometry = new THREE.BufferGeometry().setFromPoints(points);
        
        const material = new THREE.LineBasicMaterial({
            color: 0x00ffff,
            transparent: true,
            opacity: 0.6
        });
        
        const line = new THREE.Line(geometry, material);
        group.add(line);
        
        // Add flowing particles along the path
        this.addFlowingParticles(group, points);
        
        return group;
    }
    
    addFlowingParticles(group, points) {
        const particleCount = 20;
        const particleGeometry = new THREE.BufferGeometry();
        const positions = new Float32Array(particleCount * 3);
        
        for (let i = 0; i < particleCount; i++) {
            const pointIndex = Math.floor((i / particleCount) * points.length);
            const point = points[pointIndex];
            positions[i * 3] = point.x;
            positions[i * 3 + 1] = point.y;
            positions[i * 3 + 2] = point.z;
        }
        
        particleGeometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
        
        const particleMaterial = new THREE.PointsMaterial({
            color: 0x00ffff,
            size: 0.2,
            transparent: true,
            opacity: 0.8
        });
        
        const particles = new THREE.Points(particleGeometry, particleMaterial);
        group.add(particles);
        
        // Animate particles flowing along the path
        this.animateFlowingParticles(particles, points);
    }
    
    animateFlowingParticles(particles, points) {
        const animate = () => {
            const time = Date.now() * 0.001;
            const positions = particles.geometry.attributes.position.array;
            
            for (let i = 0; i < positions.length; i += 3) {
                const particleIndex = i / 3;
                const progress = (time * 0.5 + particleIndex * 0.1) % 1;
                const pointIndex = Math.floor(progress * points.length);
                const point = points[pointIndex];
                
                positions[i] = point.x;
                positions[i + 1] = point.y;
                positions[i + 2] = point.z;
            }
            
            particles.geometry.attributes.position.needsUpdate = true;
            requestAnimationFrame(animate);
        };
        animate();
    }
    
    createParticleSystem() {
        const particleCount = 1000;
        const geometry = new THREE.BufferGeometry();
        const positions = new Float32Array(particleCount * 3);
        
        for (let i = 0; i < particleCount * 3; i++) {
            positions[i] = (Math.random() - 0.5) * 200;
        }
        
        geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
        
        const material = new THREE.PointsMaterial({
            color: 0xffffff,
            size: 0.5,
            transparent: true,
            opacity: 0.6
        });
        
        this.particles = new THREE.Points(geometry, material);
        this.scene.add(this.particles);
    }
    
    createStarFieldTexture() {
        const canvas = document.createElement('canvas');
        canvas.width = 1024;
        canvas.height = 1024;
        const context = canvas.getContext('2d');
        
        // Create starfield
        context.fillStyle = '#000011';
        context.fillRect(0, 0, canvas.width, canvas.height);
        
        for (let i = 0; i < 2000; i++) {
            const x = Math.random() * canvas.width;
            const y = Math.random() * canvas.height;
            const size = Math.random() * 2;
            
            context.fillStyle = `rgba(255, 255, 255, ${Math.random()})`;
            context.beginPath();
            context.arc(x, y, size, 0, Math.PI * 2);
            context.fill();
        }
        
        return new THREE.CanvasTexture(canvas);
    }
    
    setupEventListeners() {
        // Mouse interaction
        this.container.addEventListener('click', (event) => {
            this.mouse.x = (event.clientX / this.container.clientWidth) * 2 - 1;
            this.mouse.y = -(event.clientY / this.container.clientHeight) * 2 + 1;
            
            this.raycaster.setFromCamera(this.mouse, this.camera);
            const intersects = this.raycaster.intersectObjects(
                Array.from(this.modules.values()).map(module => module.children[0])
            );
            
            if (intersects.length > 0) {
                const module = intersects[0].object.parent;
                this.selectModule(module);
            }
        });
        
        // Window resize
        window.addEventListener('resize', () => {
            this.camera.aspect = this.container.clientWidth / this.container.clientHeight;
            this.camera.updateProjectionMatrix();
            this.renderer.setSize(this.container.clientWidth, this.container.clientHeight);
            this.composer.setSize(this.container.clientWidth, this.container.clientHeight);
        });
    }
    
    selectModule(module) {
        if (this.selectedModule) {
            this.selectedModule.scale.setScalar(1);
        }
        
        this.selectedModule = module;
        module.scale.setScalar(1.2);
        
        // Emit module selection event
        const event = new CustomEvent('moduleSelected', {
            detail: { moduleId: module.userData.moduleId }
        });
        this.container.dispatchEvent(event);
    }
    
    updateLearnerProgress(progressData) {
        this.learnerProgress = progressData;
        
        // Update module statuses based on progress
        Object.entries(progressData.modules).forEach(([moduleId, status]) => {
            const module = this.modules.get(moduleId);
            if (module) {
                this.updateModuleStatus(module, status);
            }
        });
    }
    
    updateModuleStatus(module, status) {
        const ring = module.children[1];
        ring.material.color.setHex(this.getStatusColor(status));
        
        // Update pulsing animation
        if (status === 'in-progress') {
            this.addPulsingAnimation(module, status);
        }
    }
    
    animate() {
        requestAnimationFrame(() => this.animate());
        
        const deltaTime = this.clock.getDelta();
        
        // Update controls
        this.controls.update();
        
        // Rotate particles
        if (this.particles) {
            this.particles.rotation.y += deltaTime * 0.001;
        }
        
        // Rotate neural pathways
        this.neuralPathways.forEach(pathway => {
            pathway.rotation.y += deltaTime * 0.002;
        });
        
        // Render
        this.composer.render();
    }
    
    // Public API methods
    getModuleInfo(moduleId) {
        const module = this.modules.get(moduleId);
        if (module) {
            return {
                id: moduleId,
                position: module.position,
                status: module.userData.status
            };
        }
        return null;
    }
    
    focusOnModule(moduleId) {
        const module = this.modules.get(moduleId);
        if (module) {
            this.controls.target.copy(module.position);
            this.camera.position.set(
                module.position.x + 20,
                module.position.y + 20,
                module.position.z + 20
            );
        }
    }
    
    destroy() {
        this.container.removeChild(this.renderer.domElement);
        this.renderer.dispose();
    }
}

// Export for use in other modules
export default LearningUniverse;

// Example usage
document.addEventListener('DOMContentLoaded', () => {
    const universe = new LearningUniverse('learning-universe-container');
    
    // Listen for module selection
    document.getElementById('learning-universe-container').addEventListener('moduleSelected', (event) => {
        console.log('Module selected:', event.detail.moduleId);
    });
    
    // Example progress update
    setTimeout(() => {
        universe.updateLearnerProgress({
            modules: {
                'system-setup': 'completed',
                'core-python': 'completed',
                'pyspark': 'in-progress'
            }
        });
    }, 2000);
});

