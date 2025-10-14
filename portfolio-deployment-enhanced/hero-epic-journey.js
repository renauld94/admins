// HERO EPIC JOURNEY VISUALIZATION
// A working Three.js animation to replace the loading state

(function() {
    'use strict';
    
    console.log('🚀 Initializing Hero Epic Journey Visualization...');
    
    // Wait for DOM to be ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initHeroEpicJourney);
    } else {
        initHeroEpicJourney();
    }
    
    function initHeroEpicJourney() {
        const heroViz = document.getElementById('hero-visualization');
        if (!heroViz) {
            console.log('❌ Hero visualization container not found');
            return;
        }
        
        console.log('✅ Hero visualization container found');
        
        // Check if Three.js is available
        if (typeof THREE === 'undefined') {
            console.log('❌ Three.js not loaded, falling back to CSS animation');
            createFallbackAnimation();
            return;
        }
        
        // Check if GSAP is available
        if (typeof gsap === 'undefined') {
            console.log('❌ GSAP not loaded, using basic Three.js animation');
            createBasicThreeJSAnimation();
            return;
        }
        
        console.log('✅ All libraries loaded, creating Epic Journey animation');
        createEpicJourneyAnimation();
    }
    
    function createFallbackAnimation() {
        const heroViz = document.getElementById('hero-visualization');
        const loadingDiv = heroViz.querySelector('.r3f-loading');
        
        if (loadingDiv) {
            loadingDiv.innerHTML = `
                <div class="epic-journey-fallback">
                    <div class="epic-particles">
                        <div class="particle"></div>
                        <div class="particle"></div>
                        <div class="particle"></div>
                        <div class="particle"></div>
                        <div class="particle"></div>
                        <div class="particle"></div>
                        <div class="particle"></div>
                        <div class="particle"></div>
                    </div>
                    <div class="epic-text">
                        <h3>Epic Journey</h3>
                        <p>Neural Data Visualization</p>
                    </div>
                </div>
            `;
        }
        
        // Add CSS for fallback animation
        const style = document.createElement('style');
        style.textContent = `
            .epic-journey-fallback {
                position: relative;
                width: 100%;
                height: 100%;
                display: flex;
                align-items: center;
                justify-content: center;
                background: radial-gradient(circle at center, rgba(14, 165, 233, 0.1) 0%, transparent 70%);
                overflow: hidden;
            }
            
            .epic-particles {
                position: absolute;
                width: 100%;
                height: 100%;
            }
            
            .particle {
                position: absolute;
                width: 4px;
                height: 4px;
                background: #0ea5e9;
                border-radius: 50%;
                animation: float 3s ease-in-out infinite;
            }
            
            .particle:nth-child(1) { top: 20%; left: 20%; animation-delay: 0s; }
            .particle:nth-child(2) { top: 30%; left: 80%; animation-delay: 0.5s; }
            .particle:nth-child(3) { top: 60%; left: 30%; animation-delay: 1s; }
            .particle:nth-child(4) { top: 70%; left: 70%; animation-delay: 1.5s; }
            .particle:nth-child(5) { top: 40%; left: 50%; animation-delay: 2s; }
            .particle:nth-child(6) { top: 80%; left: 20%; animation-delay: 2.5s; }
            .particle:nth-child(7) { top: 10%; left: 60%; animation-delay: 3s; }
            .particle:nth-child(8) { top: 50%; left: 10%; animation-delay: 3.5s; }
            
            @keyframes float {
                0%, 100% { transform: translateY(0px) scale(1); opacity: 0.7; }
                50% { transform: translateY(-20px) scale(1.2); opacity: 1; }
            }
            
            .epic-text {
                text-align: center;
                color: #0ea5e9;
                z-index: 10;
            }
            
            .epic-text h3 {
                font-size: 2rem;
                font-weight: 700;
                margin: 0 0 0.5rem 0;
                background: linear-gradient(45deg, #0ea5e9, #8b5cf6);
                -webkit-background-clip: text;
                -webkit-text-fill-color: transparent;
                background-clip: text;
            }
            
            .epic-text p {
                font-size: 1rem;
                margin: 0;
                opacity: 0.8;
            }
        `;
        document.head.appendChild(style);
    }
    
    function createBasicThreeJSAnimation() {
        const heroViz = document.getElementById('hero-visualization');
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
        
        // Create particles
        const particleCount = 1000;
        const particles = new THREE.BufferGeometry();
        const positions = new Float32Array(particleCount * 3);
        
        for (let i = 0; i < particleCount * 3; i++) {
            positions[i] = (Math.random() - 0.5) * 20;
        }
        
        particles.setAttribute('position', new THREE.BufferAttribute(positions, 3));
        
        const particleMaterial = new THREE.PointsMaterial({
            color: 0x0ea5e9,
            size: 0.02,
            transparent: true,
            opacity: 0.8
        });
        
        const particleSystem = new THREE.Points(particles, particleMaterial);
        scene.add(particleSystem);
        
        camera.position.z = 5;
        
        // Animation loop
        function animate() {
            requestAnimationFrame(animate);
            
            particleSystem.rotation.x += 0.001;
            particleSystem.rotation.y += 0.002;
            
            renderer.render(scene, camera);
        }
        
        animate();
        
        // Handle resize
        window.addEventListener('resize', () => {
            camera.aspect = heroViz.clientWidth / heroViz.clientHeight;
            camera.updateProjectionMatrix();
            renderer.setSize(heroViz.clientWidth, heroViz.clientHeight);
        });
    }
    
    function createEpicJourneyAnimation() {
        const heroViz = document.getElementById('hero-visualization');
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
        
        // Create neural network-like structure
        const group = new THREE.Group();
        
        // Create nodes
        const nodeGeometry = new THREE.SphereGeometry(0.1, 16, 16);
        const nodeMaterial = new THREE.MeshBasicMaterial({ 
            color: 0x0ea5e9,
            transparent: true,
            opacity: 0.8
        });
        
        const nodes = [];
        const nodeCount = 50;
        
        for (let i = 0; i < nodeCount; i++) {
            const node = new THREE.Mesh(nodeGeometry, nodeMaterial);
            node.position.set(
                (Math.random() - 0.5) * 20,
                (Math.random() - 0.5) * 20,
                (Math.random() - 0.5) * 20
            );
            nodes.push(node);
            group.add(node);
        }
        
        // Create connections
        const lineGeometry = new THREE.BufferGeometry();
        const linePositions = [];
        
        for (let i = 0; i < nodes.length; i++) {
            for (let j = i + 1; j < nodes.length; j++) {
                const distance = nodes[i].position.distanceTo(nodes[j].position);
                if (distance < 8) {
                    linePositions.push(
                        nodes[i].position.x, nodes[i].position.y, nodes[i].position.z,
                        nodes[j].position.x, nodes[j].position.y, nodes[j].position.z
                    );
                }
            }
        }
        
        lineGeometry.setAttribute('position', new THREE.Float32BufferAttribute(linePositions, 3));
        
        const lineMaterial = new THREE.LineBasicMaterial({
            color: 0x0ea5e9,
            transparent: true,
            opacity: 0.3
        });
        
        const lines = new THREE.LineSegments(lineGeometry, lineMaterial);
        group.add(lines);
        
        scene.add(group);
        
        camera.position.z = 15;
        
        // GSAP animations
        gsap.from(group.rotation, {
            duration: 2,
            x: Math.PI * 2,
            y: Math.PI * 2,
            ease: "power2.out"
        });
        
        gsap.from(camera.position, {
            duration: 3,
            z: 30,
            ease: "power2.out"
        });
        
        // Continuous rotation
        gsap.to(group.rotation, {
            duration: 20,
            y: Math.PI * 2,
            repeat: -1,
            ease: "none"
        });
        
        // Pulse animation for nodes
        nodes.forEach((node, index) => {
            gsap.to(node.scale, {
                duration: 2 + Math.random() * 2,
                x: 1.5,
                y: 1.5,
                z: 1.5,
                repeat: -1,
                yoyo: true,
                ease: "power2.inOut",
                delay: index * 0.1
            });
        });
        
        // Animation loop
        function animate() {
            requestAnimationFrame(animate);
            renderer.render(scene, camera);
        }
        
        animate();
        
        // Handle resize
        window.addEventListener('resize', () => {
            camera.aspect = heroViz.clientWidth / heroViz.clientHeight;
            camera.updateProjectionMatrix();
            renderer.setSize(heroViz.clientWidth, heroViz.clientHeight);
        });
        
        console.log('🎉 Epic Journey animation initialized successfully!');
    }
    
})();
