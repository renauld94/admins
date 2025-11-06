import * as THREE from 'three';
import { UnrealBloomPass } from 'three/addons/postprocessing/UnrealBloomPass.js';
import { EffectComposer } from 'three/addons/postprocessing/EffectComposer.js';
import { RenderPass } from 'three/addons/postprocessing/RenderPass.js';
import { ShaderPass } from 'three/addons/postprocessing/ShaderPass.js';

// Global configuration
const CONFIG = {
    duration: 105, // 105 second loop
    resolution: { width: window.innerWidth, height: window.innerHeight },
    colors: {
        neural: 0x00d4ff,
        cosmic: 0xffd700,
        ambient: 0x0a0e27
    }
};

// Initialize scene
const scene = new THREE.Scene();
scene.background = new THREE.Color(CONFIG.colors.ambient);
scene.fog = new THREE.Fog(CONFIG.colors.ambient, 500, 2000);

// Camera setup
const camera = new THREE.PerspectiveCamera(75, CONFIG.resolution.width / CONFIG.resolution.height, 0.1, 10000);
camera.position.z = 100;

// Renderer setup
const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
renderer.setSize(CONFIG.resolution.width, CONFIG.resolution.height);
renderer.setPixelRatio(window.devicePixelRatio);
renderer.shadowMap.enabled = true;
document.getElementById('canvas-container').appendChild(renderer.domElement);

// Post-processing
const composer = new EffectComposer(renderer);
const renderPass = new RenderPass(scene, camera);
composer.addPass(renderPass);

const bloomPass = new UnrealBloomPass(
    new THREE.Vector2(CONFIG.resolution.width, CONFIG.resolution.height),
    1.5, 0.4, 0.85
);
composer.addPass(bloomPass);

// Lighting
const ambientLight = new THREE.AmbientLight(0xffffff, 0.4);
scene.add(ambientLight);

const pointLight = new THREE.PointLight(0x00d4ff, 2);
pointLight.position.set(50, 50, 50);
pointLight.castShadow = true;
scene.add(pointLight);

// Neural network visualization
class NeuralNetwork {
    constructor(layers = 5) {
        this.group = new THREE.Group();
        this.particles = [];
        this.connections = [];
        
        // Create nodes
        for (let i = 0; i < layers; i++) {
            const nodeCount = Math.floor(Math.random() * 5) + 3;
            for (let j = 0; j < nodeCount; j++) {
                const geometry = new THREE.SphereGeometry(0.5, 8, 8);
                const material = new THREE.MeshPhongMaterial({
                    color: 0x00d4ff,
                    emissive: 0x00d4ff,
                    emissiveIntensity: 0.5
                });
                const mesh = new THREE.Mesh(geometry, material);
                mesh.position.set(
                    (i - layers/2) * 10,
                    (j - nodeCount/2) * 10,
                    Math.random() * 20
                );
                this.group.add(mesh);
                this.particles.push(mesh);
            }
        }
        
        scene.add(this.group);
    }
    
    update(time) {
        this.particles.forEach((particle, i) => {
            particle.rotation.x += 0.01;
            particle.rotation.y += 0.01;
            particle.position.z += Math.sin(time + i) * 0.5;
        });
    }
}

// Infrastructure visualization
class InfrastructureViz {
    constructor() {
        this.group = new THREE.Group();
        this.elements = [];
        
        // Origin point
        const originGeometry = new THREE.IcosahedronGeometry(2, 4);
        const originMaterial = new THREE.MeshPhongMaterial({
            color: 0x00d4ff,
            emissive: 0x00d4ff,
            emissiveIntensity: 0.8,
            wireframe: false
        });
        const origin = new THREE.Mesh(originGeometry, originMaterial);
        this.group.add(origin);
        this.elements.push({ mesh: origin, angle: 0 });
        
        // Regional hubs
        for (let i = 0; i < 4; i++) {
            const hubGeometry = new THREE.OctahedronGeometry(1.5, 2);
            const hubMaterial = new THREE.MeshPhongMaterial({
                color: 0x8b5cf6,
                emissive: 0x8b5cf6,
                emissiveIntensity: 0.5
            });
            const hub = new THREE.Mesh(hubGeometry, hubMaterial);
            hub.position.set(Math.cos(i * Math.PI / 2) * 30, Math.sin(i * Math.PI / 2) * 30, 0);
            this.group.add(hub);
            this.elements.push({ mesh: hub, angle: i * Math.PI / 2, distance: 30 });
        }
        
        // Global nodes
        for (let i = 0; i < 5; i++) {
            const nodeGeometry = new THREE.TetrahedronGeometry(1, 2);
            const nodeMaterial = new THREE.MeshPhongMaterial({
                color: 0xff6b35,
                emissive: 0xff6b35,
                emissiveIntensity: 0.4
            });
            const node = new THREE.Mesh(nodeGeometry, nodeMaterial);
            const phi = Math.acos(-1 + 2 * i / 5);
            const theta = Math.sqrt(5) * Math.PI * i;
            node.position.set(
                Math.sin(phi) * Math.cos(theta) * 50,
                Math.sin(phi) * Math.sin(theta) * 50,
                Math.cos(phi) * 50
            );
            this.group.add(node);
            this.elements.push({ mesh: node, angle: theta, distance: 50 });
        }
        
        scene.add(this.group);
    }
    
    update(time) {
        this.elements.forEach((element, i) => {
            element.mesh.rotation.x += 0.003;
            element.mesh.rotation.y += 0.005;
            element.mesh.rotation.z += 0.002;
            
            if (element.distance) {
                element.mesh.position.x = Math.cos(element.angle + time * 0.1) * element.distance;
                element.mesh.position.y = Math.sin(element.angle + time * 0.1) * element.distance;
                element.mesh.position.z = Math.sin(time * 0.05 + i) * 20;
            }
        });
    }
}

// Create visualizations
const neural = new NeuralNetwork(5);
const infra = new InfrastructureViz();

// Animation loop
let startTime = Date.now();
let frameCount = 0;

function animate() {
    requestAnimationFrame(animate);
    
    const elapsed = (Date.now() - startTime) / 1000;
    const progress = (elapsed % CONFIG.duration) / CONFIG.duration;
    
    // Update camera position along cinematic path
    const cameraDistance = 100 + Math.sin(progress * Math.PI * 2) * 30;
    camera.position.x = Math.cos(progress * Math.PI * 4) * cameraDistance;
    camera.position.y = Math.sin(progress * Math.PI * 3) * cameraDistance;
    camera.position.z = 50 + Math.cos(progress * Math.PI * 2) * 30;
    camera.lookAt(0, 0, 0);
    
    // Update visualizations
    neural.update(elapsed);
    infra.update(elapsed);
    
    // Render
    composer.render();
    
    // Update stats
    frameCount++;
    if (frameCount % 10 === 0) {
        const fps = Math.round(1000 / (Date.now() - startTime) * frameCount);
        document.getElementById('fps').textContent = fps;
        document.getElementById('time').textContent = Math.floor(elapsed) + 's';
    }
}

// Handle window resize
window.addEventListener('resize', () => {
    const width = window.innerWidth;
    const height = window.innerHeight;
    camera.aspect = width / height;
    camera.updateProjectionMatrix();
    renderer.setSize(width, height);
    composer.setSize(width, height);
});

// Hide loading, show animation
setTimeout(() => {
    document.getElementById('loading').style.display = 'none';
    animate();
}, 1000);
