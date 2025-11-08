/**
 * SIMPLE NEURAL VISUALIZATION
 * Minimal THREE.js visualization for the hero section
 */

class SimpleNeuralViz {
    constructor(containerId, options = {}) {
        this.containerId = containerId;
        this.options = {
            particleCount: options.particleCount || 1000,
            ...options
        };
        
        this.scene = null;
        this.camera = null;
        this.renderer = null;
        this.controls = null;
        this.particles = null;
        this.animationId = null;
        
        console.log('🌟 Initializing Simple Neural Visualization...');
        this.init();
    }
    
    init() {
        try {
            this.setupThreeJS();
            this.createParticles();
            this.setupControls();
            this.startAnimation();
            console.log('✅ Simple Neural Visualization initialized');
        } catch (error) {
            console.error('❌ Failed to initialize Simple Neural Visualization:', error);
            this.showFallback();
        }
    }
    
    setupThreeJS() {
        const container = document.getElementById(this.containerId);
        if (!container) {
            throw new Error(`Container with id "${this.containerId}" not found`);
        }
        
        // Scene
        this.scene = new THREE.Scene();
        this.scene.background = new THREE.Color(0x000011);
        
        // Camera
        this.camera = new THREE.PerspectiveCamera(
            75,
            container.clientWidth / container.clientHeight,
            0.1,
            1000
        );
        this.camera.position.z = 50;
        
        // Renderer
        this.renderer = new THREE.WebGLRenderer({ alpha: true, antialias: true });
        this.renderer.setSize(container.clientWidth, container.clientHeight);
        // Use global capped DPR if available, fallback to mobile-aware calculation
        const cappedDPR = (typeof window !== 'undefined' && typeof window.getCappedDevicePixelRatio === 'function')
            ? window.getCappedDevicePixelRatio()
            : (() => {
                const isMobile = window.__IS_MOBILE_PORTFOLIO__ || /Mobi|Android/i.test(navigator.userAgent || '');
                return Math.min(window.devicePixelRatio, isMobile ? 1 : 2);
            })();
        this.renderer.setPixelRatio(cappedDPR);
        
        container.appendChild(this.renderer.domElement);
        
        // Lighting
        const ambientLight = new THREE.AmbientLight(0x404040, 0.5);
        this.scene.add(ambientLight);
        
        const pointLight = new THREE.PointLight(0x0ea5e9, 1, 100);
        pointLight.position.set(20, 20, 20);
        this.scene.add(pointLight);
        
        // Handle resize
        window.addEventListener('resize', () => this.handleResize());
    }
    
    createParticles() {
        const particleCount = this.options.particleCount;
        const geometry = new THREE.BufferGeometry();
        
        const positions = new Float32Array(particleCount * 3);
        const colors = new Float32Array(particleCount * 3);
        
        for (let i = 0; i < particleCount; i++) {
            const i3 = i * 3;
            
            // Random positions in sphere
            const radius = 30 + Math.random() * 20;
            const theta = Math.random() * Math.PI * 2;
            const phi = Math.random() * Math.PI;
            
            positions[i3] = radius * Math.sin(phi) * Math.cos(theta);
            positions[i3 + 1] = radius * Math.sin(phi) * Math.sin(theta);
            positions[i3 + 2] = radius * Math.cos(phi);
            
            // Blue to purple gradient
            const hue = 0.6 + Math.random() * 0.2;
            const color = new THREE.Color();
            color.setHSL(hue, 0.8, 0.6);
            colors[i3] = color.r;
            colors[i3 + 1] = color.g;
            colors[i3 + 2] = color.b;
        }
        
        geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
        geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));
        
        const material = new THREE.PointsMaterial({
            size: 0.8,
            vertexColors: true,
            transparent: true,
            opacity: 0.8,
            blending: THREE.AdditiveBlending
        });
        
        this.particles = new THREE.Points(geometry, material);
        this.scene.add(this.particles);
        
        console.log(`✅ Created ${particleCount} particles`);
    }
    
    setupControls() {
        if (THREE && THREE.OrbitControls) {
            try {
                this.controls = new THREE.OrbitControls(this.camera, this.renderer.domElement);
                this.controls.enableDamping = true;
                this.controls.dampingFactor = 0.05;
                this.controls.minDistance = 20;
                this.controls.maxDistance = 100;
                console.log('✅ OrbitControls enabled');
            } catch (error) {
                console.warn('OrbitControls failed, using basic controls:', error);
                this.setupBasicControls();
            }
        } else {
            this.setupBasicControls();
        }
    }
    
    setupBasicControls() {
        let isDragging = false;
        let previousMousePosition = { x: 0, y: 0 };
        
        this.renderer.domElement.addEventListener('mousedown', (event) => {
            isDragging = true;
            previousMousePosition = { x: event.clientX, y: event.clientY };
        });
        
        this.renderer.domElement.addEventListener('mousemove', (event) => {
            if (!isDragging) return;
            
            const deltaX = event.clientX - previousMousePosition.x;
            const deltaY = event.clientY - previousMousePosition.y;
            
            // Rotate camera around origin
            const spherical = new THREE.Spherical();
            spherical.setFromVector3(this.camera.position);
            spherical.theta -= deltaX * 0.01;
            spherical.phi += deltaY * 0.01;
            spherical.phi = Math.max(0.1, Math.min(Math.PI - 0.1, spherical.phi));
            
            this.camera.position.setFromSpherical(spherical);
            this.camera.lookAt(0, 0, 0);
            
            previousMousePosition = { x: event.clientX, y: event.clientY };
        });
        
        document.addEventListener('mouseup', () => {
            isDragging = false;
        });
        
        this.renderer.domElement.addEventListener('wheel', (event) => {
            const scale = event.deltaY > 0 ? 1.1 : 0.9;
            this.camera.position.multiplyScalar(scale);
            
            // Clamp distance
            const distance = this.camera.position.length();
            if (distance < 20) this.camera.position.normalize().multiplyScalar(20);
            if (distance > 100) this.camera.position.normalize().multiplyScalar(100);
        });
        
        console.log('✅ Basic controls enabled');
    }
    
    startAnimation() {
        const animate = () => {
            this.animationId = requestAnimationFrame(animate);
            
            const time = Date.now() * 0.001;
            
            // Update controls
            if (this.controls && this.controls.update) {
                this.controls.update();
            }
            
            // Animate particles
            if (this.particles) {
                this.particles.rotation.x += 0.001;
                this.particles.rotation.y += 0.002;
                
                // Pulse effect
                const scale = 1 + Math.sin(time) * 0.1;
                this.particles.scale.setScalar(scale);
            }
            
            // Render
            this.renderer.render(this.scene, this.camera);
        };
        
        animate();
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
            <div style="display: flex; align-items: center; justify-content: center; height: 100%; color: #0ea5e9; text-align: center; padding: 2rem;">
                <div>
                    <div style="font-size: 1.5rem; font-weight: 700; margin-bottom: 1rem;">🌌 Neural Data Platform</div>
                    <div style="font-size: 1rem; opacity: 0.8;">Transforming Healthcare Data</div>
                    <div style="font-size: 0.8rem; opacity: 0.6; margin-top: 1rem;">Advanced Analytics & Machine Learning</div>
                </div>
            </div>
        `;
    }
    
    destroy() {
        if (this.animationId) {
            cancelAnimationFrame(this.animationId);
        }
        
        if (this.renderer) {
            this.renderer.dispose();
        }
        
        console.log('✅ Simple Neural Visualization destroyed');
    }
    
    getStats() {
        return {
            particles: this.options.particleCount,
            hasControls: !!this.controls,
            isAnimating: !!this.animationId
        };
    }
}

// Export
if (typeof module !== 'undefined' && module.exports) {
    module.exports = SimpleNeuralViz;
} else {
    window.SimpleNeuralViz = SimpleNeuralViz;
}