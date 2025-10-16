/**
 * ENHANCED EPIC NEURAL LOADING ANIMATION
 * Advanced neural network visualization with morphing effects
 * Pure visual animation - no text or emojis
 */

class EnhancedEpicNeuralLoading {
    constructor(container) {
        this.container = container;
        this.canvas = null;
        this.ctx = null;
        this.animationId = null;
        this.particles = [];
        this.neuralLayers = [];
        this.globalNodes = [];
        this.dataStreams = [];
        this.time = 0;
        this.phase = 0;
        this.phaseProgress = 0;
        this.mouseX = 0;
        this.mouseY = 0;
        
        this.init();
    }
    
    init() {
        this.createCanvas();
        this.createNeuralLayers();
        this.createParticles();
        this.createGlobalNodes();
        this.createDataStreams();
        this.setupEventListeners();
        this.animate();
        this.startPhaseTransition();
    }
    
    createCanvas() {
        this.canvas = document.createElement('canvas');
        this.canvas.style.position = 'absolute';
        this.canvas.style.top = '0';
        this.canvas.style.left = '0';
        this.canvas.style.width = '100%';
        this.canvas.style.height = '100%';
        this.canvas.style.pointerEvents = 'none';
        this.canvas.style.zIndex = '1';
        
        this.ctx = this.canvas.getContext('2d');
        this.container.appendChild(this.canvas);
        
        this.resize();
        window.addEventListener('resize', () => this.resize());
    }
    
    resize() {
        const rect = this.container.getBoundingClientRect();
        this.canvas.width = rect.width * window.devicePixelRatio;
        this.canvas.height = rect.height * window.devicePixelRatio;
        this.ctx.scale(window.devicePixelRatio, window.devicePixelRatio);
    }
    
    createNeuralLayers() {
        const layerCount = 5;
        const centerX = this.canvas.width / 2;
        const centerY = this.canvas.height / 2;
        
        for (let i = 0; i < layerCount; i++) {
            this.neuralLayers.push({
                x: centerX,
                y: centerY,
                radius: 20 + i * 40,
                nodes: [],
                connections: [],
                energy: 0,
                phase: Math.random() * Math.PI * 2,
                active: false
            });
            
            // Create nodes for each layer
            const nodeCount = 8 + i * 4;
            for (let j = 0; j < nodeCount; j++) {
                const angle = (j / nodeCount) * Math.PI * 2;
                this.neuralLayers[i].nodes.push({
                    x: centerX + Math.cos(angle) * (20 + i * 40),
                    y: centerY + Math.sin(angle) * (20 + i * 40),
                    energy: 0,
                    phase: Math.random() * Math.PI * 2,
                    connections: []
                });
            }
        }
    }
    
    createParticles() {
        const particleCount = 200;
        for (let i = 0; i < particleCount; i++) {
            this.particles.push({
                x: Math.random() * this.canvas.width,
                y: Math.random() * this.canvas.height,
                vx: (Math.random() - 0.5) * 0.3,
                vy: (Math.random() - 0.5) * 0.3,
                size: Math.random() * 2 + 0.5,
                energy: Math.random(),
                phase: Math.random() * Math.PI * 2,
                type: Math.random() < 0.4 ? 'neural' : Math.random() < 0.7 ? 'data' : 'quantum',
                life: 1,
                maxLife: 1
            });
        }
    }
    
    createGlobalNodes() {
        const nodeCount = 12;
        const centerX = this.canvas.width / 2;
        const centerY = this.canvas.height / 2;
        const radius = Math.min(centerX, centerY) * 0.7;
        
        for (let i = 0; i < nodeCount; i++) {
            const angle = (i / nodeCount) * Math.PI * 2;
            this.globalNodes.push({
                x: centerX + Math.cos(angle) * radius,
                y: centerY + Math.sin(angle) * radius,
                size: 6 + Math.random() * 4,
                energy: 0,
                pulsePhase: Math.random() * Math.PI * 2,
                connections: [],
                active: false,
                type: Math.random() < 0.5 ? 'server' : 'data'
            });
        }
    }
    
    createDataStreams() {
        const streamCount = 8;
        for (let i = 0; i < streamCount; i++) {
            this.dataStreams.push({
                x: Math.random() * this.canvas.width,
                y: Math.random() * this.canvas.height,
                vx: (Math.random() - 0.5) * 2,
                vy: (Math.random() - 0.5) * 2,
                size: Math.random() * 3 + 1,
                energy: Math.random(),
                phase: Math.random() * Math.PI * 2,
                particles: [],
                active: false
            });
        }
    }
    
    setupEventListeners() {
        this.container.addEventListener('mousemove', (e) => {
            const rect = this.container.getBoundingClientRect();
            this.mouseX = e.clientX - rect.left;
            this.mouseY = e.clientY - rect.top;
        });
    }
    
    startPhaseTransition() {
        const phaseDuration = 4000;
        
        setInterval(() => {
            this.phaseProgress = 0;
            this.phase = (this.phase + 1) % 4;
            
            const startTime = Date.now();
            const animatePhase = () => {
                const elapsed = Date.now() - startTime;
                this.phaseProgress = Math.min(elapsed / 1000, 1);
                
                if (this.phaseProgress < 1) {
                    requestAnimationFrame(animatePhase);
                }
            };
            animatePhase();
        }, phaseDuration);
    }
    
    updateNeuralLayers() {
        this.neuralLayers.forEach((layer, layerIndex) => {
            layer.phase += 0.02;
            layer.energy = Math.sin(layer.phase) * 0.5 + 0.5;
            
            // Activate layers based on phase
            if (this.phase >= layerIndex) {
                layer.active = true;
            }
            
            // Update layer nodes
            layer.nodes.forEach((node, nodeIndex) => {
                node.phase += 0.03 + layerIndex * 0.01;
                node.energy = Math.sin(node.phase) * 0.5 + 0.5;
                
                // Update node position for morphing effect
                const baseAngle = (nodeIndex / layer.nodes.length) * Math.PI * 2;
                const morphFactor = this.phaseProgress;
                const currentAngle = baseAngle + Math.sin(this.time * 0.01 + layerIndex) * 0.3;
                
                node.x = layer.x + Math.cos(currentAngle) * layer.radius * (0.8 + layer.energy * 0.4);
                node.y = layer.y + Math.sin(currentAngle) * layer.radius * (0.8 + layer.energy * 0.4);
            });
        });
    }
    
    updateParticles() {
        this.particles.forEach(particle => {
            // Update position
            particle.x += particle.vx;
            particle.y += particle.vy;
            
            // Boundary wrapping with fade
            if (particle.x < 0 || particle.x > this.canvas.width || 
                particle.y < 0 || particle.y > this.canvas.height) {
                particle.life -= 0.01;
                if (particle.life <= 0) {
                    particle.x = Math.random() * this.canvas.width;
                    particle.y = Math.random() * this.canvas.height;
                    particle.life = particle.maxLife;
                }
            }
            
            // Update energy
            particle.energy += 0.008;
            if (particle.energy > 1) particle.energy = 0;
            
            // Phase-specific behavior
            this.applyPhaseBehavior(particle);
            
            // Mouse interaction
            const dx = this.mouseX - particle.x;
            const dy = this.mouseY - particle.y;
            const distance = Math.sqrt(dx * dx + dy * dy);
            if (distance < 100) {
                const force = (100 - distance) / 100;
                particle.vx += dx * force * 0.0001;
                particle.vy += dy * force * 0.0001;
            }
            
            // Apply damping
            particle.vx *= 0.98;
            particle.vy *= 0.98;
        });
    }
    
    applyPhaseBehavior(particle) {
        const centerX = this.canvas.width / 2;
        const centerY = this.canvas.height / 2;
        
        if (this.phase === 0) {
            // Neural formation - particles converge to center
            const dx = centerX - particle.x;
            const dy = centerY - particle.y;
            const distance = Math.sqrt(dx * dx + dy * dy);
            if (distance > 30) {
                particle.vx += dx * 0.0002;
                particle.vy += dy * 0.0002;
            }
        } else if (this.phase === 1) {
            // Layer formation - particles move to neural layers
            const nearestLayer = this.findNearestNeuralLayer(particle);
            if (nearestLayer && nearestLayer.active) {
                const dx = nearestLayer.x - particle.x;
                const dy = nearestLayer.y - particle.y;
                particle.vx += dx * 0.0001;
                particle.vy += dy * 0.0001;
            }
        } else if (this.phase === 2) {
            // Network expansion - particles spread out
            const dx = particle.x - centerX;
            const dy = particle.y - centerY;
            particle.vx += dx * 0.00005;
            particle.vy += dy * 0.00005;
        } else if (this.phase === 3) {
            // Global connection - particles move to global nodes
            const nearestNode = this.findNearestGlobalNode(particle);
            if (nearestNode && nearestNode.active) {
                const dx = nearestNode.x - particle.x;
                const dy = nearestNode.y - particle.y;
                particle.vx += dx * 0.0003;
                particle.vy += dy * 0.0003;
            }
        }
    }
    
    updateGlobalNodes() {
        this.globalNodes.forEach(node => {
            node.pulsePhase += 0.04;
            node.energy = Math.sin(node.pulsePhase) * 0.5 + 0.5;
            
            if (this.phase >= 2) {
                node.active = true;
            }
        });
    }
    
    updateDataStreams() {
        this.dataStreams.forEach(stream => {
            stream.phase += 0.05;
            stream.energy = Math.sin(stream.phase) * 0.5 + 0.5;
            
            if (this.phase >= 1) {
                stream.active = true;
            }
            
            if (stream.active) {
                stream.x += stream.vx;
                stream.y += stream.vy;
                
                // Boundary wrapping
                if (stream.x < 0) stream.x = this.canvas.width;
                if (stream.x > this.canvas.width) stream.x = 0;
                if (stream.y < 0) stream.y = this.canvas.height;
                if (stream.y > this.canvas.height) stream.y = 0;
            }
        });
    }
    
    findNearestNeuralLayer(particle) {
        let nearest = null;
        let minDistance = Infinity;
        
        this.neuralLayers.forEach(layer => {
            if (!layer.active) return;
            
            const dx = layer.x - particle.x;
            const dy = layer.y - particle.y;
            const distance = Math.sqrt(dx * dx + dy * dy);
            
            if (distance < minDistance) {
                minDistance = distance;
                nearest = layer;
            }
        });
        
        return nearest;
    }
    
    findNearestGlobalNode(particle) {
        let nearest = null;
        let minDistance = Infinity;
        
        this.globalNodes.forEach(node => {
            if (!node.active) return;
            
            const dx = node.x - particle.x;
            const dy = node.y - particle.y;
            const distance = Math.sqrt(dx * dx + dy * dy);
            
            if (distance < minDistance) {
                minDistance = distance;
                nearest = node;
            }
        });
        
        return nearest;
    }
    
    createConnections() {
        this.connections = [];
        
        // Create connections between particles
        for (let i = 0; i < this.particles.length; i++) {
            for (let j = i + 1; j < this.particles.length; j++) {
                const p1 = this.particles[i];
                const p2 = this.particles[j];
                const dx = p1.x - p2.x;
                const dy = p1.y - p2.y;
                const distance = Math.sqrt(dx * dx + dy * dy);
                
                let maxDistance = 60;
                if (this.phase === 0) maxDistance = 40;
                else if (this.phase === 1) maxDistance = 80;
                else if (this.phase === 2) maxDistance = 100;
                else if (this.phase === 3) maxDistance = 120;
                
                if (distance < maxDistance) {
                    this.connections.push({
                        x1: p1.x, y1: p1.y,
                        x2: p2.x, y2: p2.y,
                        strength: 1 - (distance / maxDistance),
                        energy: (p1.energy + p2.energy) / 2,
                        type: p1.type === p2.type ? p1.type : 'hybrid',
                        life: p1.life * p2.life
                    });
                }
            }
        }
        
        // Create connections within neural layers
        this.neuralLayers.forEach(layer => {
            if (!layer.active) return;
            
            layer.nodes.forEach((node, i) => {
                layer.nodes.forEach((otherNode, j) => {
                    if (i >= j) return;
                    
                    const dx = node.x - otherNode.x;
                    const dy = node.y - otherNode.y;
                    const distance = Math.sqrt(dx * dx + dy * dy);
                    
                    if (distance < 80) {
                        this.connections.push({
                            x1: node.x, y1: node.y,
                            x2: otherNode.x, y2: otherNode.y,
                            strength: 1 - (distance / 80),
                            energy: (node.energy + otherNode.energy) / 2,
                            type: 'neural',
                            life: 1
                        });
                    }
                });
            });
        });
        
        // Create connections to global nodes
        if (this.phase >= 3) {
            this.particles.forEach(particle => {
                const nearestNode = this.findNearestGlobalNode(particle);
                if (nearestNode) {
                    const dx = particle.x - nearestNode.x;
                    const dy = particle.y - nearestNode.y;
                    const distance = Math.sqrt(dx * dx + dy * dy);
                    
                    if (distance < 150) {
                        this.connections.push({
                            x1: particle.x, y1: particle.y,
                            x2: nearestNode.x, y2: nearestNode.y,
                            strength: 1 - (distance / 150),
                            energy: (particle.energy + nearestNode.energy) / 2,
                            type: 'global',
                            life: 1
                        });
                    }
                }
            });
        }
    }
    
    render() {
        this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
        
        // Create dynamic gradient background
        this.renderBackground();
        
        // Render connections
        this.renderConnections();
        
        // Render neural layers
        this.renderNeuralLayers();
        
        // Render particles
        this.renderParticles();
        
        // Render global nodes
        this.renderGlobalNodes();
        
        // Render data streams
        this.renderDataStreams();
        
        // Add phase-specific effects
        this.renderPhaseEffects();
    }
    
    renderBackground() {
        const gradient = this.ctx.createRadialGradient(
            this.canvas.width / 2, this.canvas.height / 2, 0,
            this.canvas.width / 2, this.canvas.height / 2, Math.max(this.canvas.width, this.canvas.height) / 2
        );
        
        const phaseColors = [
            ['rgba(14, 165, 233, 0.1)', 'rgba(0, 0, 0, 0.9)'],
            ['rgba(139, 92, 246, 0.1)', 'rgba(0, 0, 0, 0.9)'],
            ['rgba(6, 182, 212, 0.1)', 'rgba(0, 0, 0, 0.9)'],
            ['rgba(255, 255, 255, 0.05)', 'rgba(0, 0, 0, 0.95)']
        ];
        
        const colors = phaseColors[this.phase];
        gradient.addColorStop(0, colors[0]);
        gradient.addColorStop(0.5, colors[1]);
        gradient.addColorStop(1, colors[1]);
        
        this.ctx.fillStyle = gradient;
        this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
    }
    
    renderConnections() {
        this.connections.forEach(conn => {
            this.ctx.beginPath();
            this.ctx.moveTo(conn.x1, conn.y1);
            this.ctx.lineTo(conn.x2, conn.y2);
            
            const alpha = conn.strength * conn.energy * conn.life * 0.8;
            let color;
            
            switch (conn.type) {
                case 'neural':
                    color = `rgba(14, 165, 233, ${alpha})`;
                    break;
                case 'data':
                    color = `rgba(139, 92, 246, ${alpha})`;
                    break;
                case 'quantum':
                    color = `rgba(6, 182, 212, ${alpha})`;
                    break;
                case 'hybrid':
                    color = `rgba(255, 255, 255, ${alpha * 0.6})`;
                    break;
                case 'global':
                    color = `rgba(255, 255, 255, ${alpha * 0.8})`;
                    break;
            }
            
            this.ctx.strokeStyle = color;
            this.ctx.lineWidth = conn.strength * 2.5;
            this.ctx.stroke();
        });
    }
    
    renderNeuralLayers() {
        this.neuralLayers.forEach((layer, index) => {
            if (!layer.active) return;
            
            // Render layer ring
            this.ctx.beginPath();
            this.ctx.arc(layer.x, layer.y, layer.radius, 0, Math.PI * 2);
            this.ctx.strokeStyle = `rgba(14, 165, 233, ${0.2 + layer.energy * 0.3})`;
            this.ctx.lineWidth = 2;
            this.ctx.stroke();
            
            // Render layer nodes
            layer.nodes.forEach(node => {
                this.ctx.beginPath();
                this.ctx.arc(node.x, node.y, 3 + node.energy * 2, 0, Math.PI * 2);
                this.ctx.fillStyle = `rgba(14, 165, 233, ${0.4 + node.energy * 0.6})`;
                this.ctx.fill();
            });
        });
    }
    
    renderParticles() {
        this.particles.forEach(particle => {
            if (particle.life <= 0) return;
            
            this.ctx.beginPath();
            this.ctx.arc(particle.x, particle.y, particle.size * (0.5 + particle.energy * 0.5), 0, Math.PI * 2);
            
            let color;
            switch (particle.type) {
                case 'neural':
                    color = `rgba(14, 165, 233, ${(0.3 + particle.energy * 0.7) * particle.life})`;
                    break;
                case 'data':
                    color = `rgba(139, 92, 246, ${(0.3 + particle.energy * 0.7) * particle.life})`;
                    break;
                case 'quantum':
                    color = `rgba(6, 182, 212, ${(0.3 + particle.energy * 0.7) * particle.life})`;
                    break;
            }
            
            this.ctx.fillStyle = color;
            this.ctx.fill();
            
            // Add glow effect
            this.ctx.shadowColor = color;
            this.ctx.shadowBlur = particle.size * 4;
            this.ctx.fill();
            this.ctx.shadowBlur = 0;
        });
    }
    
    renderGlobalNodes() {
        this.globalNodes.forEach(node => {
            if (!node.active) return;
            
            this.ctx.beginPath();
            this.ctx.arc(node.x, node.y, node.size * (0.5 + node.energy * 0.5), 0, Math.PI * 2);
            
            const color = node.type === 'server' 
                ? `rgba(255, 255, 255, ${0.4 + node.energy * 0.6})`
                : `rgba(6, 182, 212, ${0.4 + node.energy * 0.6})`;
            
            this.ctx.fillStyle = color;
            this.ctx.fill();
            
            // Add pulsing ring
            this.ctx.beginPath();
            this.ctx.arc(node.x, node.y, node.size * (1.5 + node.energy), 0, Math.PI * 2);
            this.ctx.strokeStyle = `rgba(255, 255, 255, ${node.energy * 0.3})`;
            this.ctx.lineWidth = 2;
            this.ctx.stroke();
        });
    }
    
    renderDataStreams() {
        this.dataStreams.forEach(stream => {
            if (!stream.active) return;
            
            this.ctx.beginPath();
            this.ctx.arc(stream.x, stream.y, stream.size * (0.5 + stream.energy * 0.5), 0, Math.PI * 2);
            this.ctx.fillStyle = `rgba(6, 182, 212, ${0.2 + stream.energy * 0.4})`;
            this.ctx.fill();
        });
    }
    
    renderPhaseEffects() {
        const centerX = this.canvas.width / 2;
        const centerY = this.canvas.height / 2;
        
        switch (this.phase) {
            case 0:
                this.renderNeuralFormation(centerX, centerY);
                break;
            case 1:
                this.renderLayerFormation(centerX, centerY);
                break;
            case 2:
                this.renderNetworkExpansion(centerX, centerY);
                break;
            case 3:
                this.renderGlobalConnection(centerX, centerY);
                break;
        }
    }
    
    renderNeuralFormation(centerX, centerY) {
        // Central convergence effect
        this.ctx.beginPath();
        this.ctx.arc(centerX, centerY, 15 + Math.sin(this.time * 0.01) * 8, 0, Math.PI * 2);
        this.ctx.strokeStyle = `rgba(14, 165, 233, ${0.6 + Math.sin(this.time * 0.01) * 0.3})`;
        this.ctx.lineWidth = 3;
        this.ctx.stroke();
    }
    
    renderLayerFormation(centerX, centerY) {
        // Expanding rings
        const ringRadius = (this.time * 0.05) % 200;
        this.ctx.beginPath();
        this.ctx.arc(centerX, centerY, ringRadius, 0, Math.PI * 2);
        this.ctx.strokeStyle = `rgba(139, 92, 246, ${0.4 - (ringRadius / 200) * 0.4})`;
        this.ctx.lineWidth = 2;
        this.ctx.stroke();
    }
    
    renderNetworkExpansion(centerX, centerY) {
        // Network pulse
        const pulseRadius = 50 + Math.sin(this.time * 0.02) * 30;
        this.ctx.beginPath();
        this.ctx.arc(centerX, centerY, pulseRadius, 0, Math.PI * 2);
        this.ctx.strokeStyle = `rgba(6, 182, 212, ${0.3 + Math.sin(this.time * 0.02) * 0.2})`;
        this.ctx.lineWidth = 3;
        this.ctx.stroke();
    }
    
    renderGlobalConnection(centerX, centerY) {
        // Global network pulse
        this.globalNodes.forEach((node, i) => {
            const pulseRadius = 25 + Math.sin(this.time * 0.03 + i) * 15;
            
            this.ctx.beginPath();
            this.ctx.arc(node.x, node.y, pulseRadius, 0, Math.PI * 2);
            this.ctx.strokeStyle = `rgba(255, 255, 255, ${0.2 - (pulseRadius / 40) * 0.2})`;
            this.ctx.lineWidth = 1.5;
            this.ctx.stroke();
        });
    }
    
    animate() {
        this.time += 16;
        this.updateNeuralLayers();
        this.updateParticles();
        this.updateGlobalNodes();
        this.updateDataStreams();
        this.createConnections();
        this.render();
        
        this.animationId = requestAnimationFrame(() => this.animate());
    }
    
    destroy() {
        if (this.animationId) {
            cancelAnimationFrame(this.animationId);
        }
        if (this.canvas && this.canvas.parentNode) {
            this.canvas.parentNode.removeChild(this.canvas);
        }
    }
}

// Initialize the enhanced epic neural loading animation
document.addEventListener('DOMContentLoaded', () => {
    const loadingContainer = document.querySelector('.epic-neural-loading');
    if (loadingContainer) {
        // Hide the text content
        const textContent = loadingContainer.querySelector('.r3f-loading-inner');
        if (textContent) {
            textContent.style.display = 'none';
        }
        
        // Create the enhanced epic animation
        const epicAnimation = new EnhancedEpicNeuralLoading(loadingContainer);
        
        // Clean up when the loading is complete
        setTimeout(() => {
            epicAnimation.destroy();
        }, 20000); // Run for 20 seconds
    }
});
