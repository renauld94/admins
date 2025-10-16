/**
 * EPIC NEURAL LOADING ANIMATION
 * Pure visual neural network animation with no text or emojis
 * Shows neural networks evolving into global data networks
 */

class EpicNeuralLoading {
    constructor(container) {
        this.container = container;
        this.canvas = null;
        this.ctx = null;
        this.animationId = null;
        this.particles = [];
        this.connections = [];
        this.globalNodes = [];
        this.time = 0;
        this.phase = 0; // 0: neural formation, 1: network expansion, 2: global connection
        this.phaseProgress = 0;
        
        this.init();
    }
    
    init() {
        this.createCanvas();
        this.createParticles();
        this.createGlobalNodes();
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
    
    createParticles() {
        const particleCount = 150;
        for (let i = 0; i < particleCount; i++) {
            this.particles.push({
                x: Math.random() * this.canvas.width,
                y: Math.random() * this.canvas.height,
                vx: (Math.random() - 0.5) * 0.5,
                vy: (Math.random() - 0.5) * 0.5,
                size: Math.random() * 3 + 1,
                energy: Math.random(),
                phase: Math.random() * Math.PI * 2,
                connections: [],
                type: Math.random() < 0.3 ? 'neural' : 'data'
            });
        }
    }
    
    createGlobalNodes() {
        const nodeCount = 8;
        const centerX = this.canvas.width / 2;
        const centerY = this.canvas.height / 2;
        const radius = Math.min(centerX, centerY) * 0.6;
        
        for (let i = 0; i < nodeCount; i++) {
            const angle = (i / nodeCount) * Math.PI * 2;
            this.globalNodes.push({
                x: centerX + Math.cos(angle) * radius,
                y: centerY + Math.sin(angle) * radius,
                size: 8,
                energy: 0,
                pulsePhase: Math.random() * Math.PI * 2,
                connections: [],
                active: false
            });
        }
    }
    
    startPhaseTransition() {
        const phaseDuration = 3000; // 3 seconds per phase
        
        setInterval(() => {
            this.phaseProgress = 0;
            this.phase = (this.phase + 1) % 3;
            
            // Animate phase transition
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
    
    updateParticles() {
        this.particles.forEach(particle => {
            // Update position
            particle.x += particle.vx;
            particle.y += particle.vy;
            
            // Boundary wrapping
            if (particle.x < 0) particle.x = this.canvas.width;
            if (particle.x > this.canvas.width) particle.x = 0;
            if (particle.y < 0) particle.y = this.canvas.height;
            if (particle.y > this.canvas.height) particle.y = 0;
            
            // Update energy based on phase
            particle.energy += 0.01;
            if (particle.energy > 1) particle.energy = 0;
            
            // Phase-specific behavior
            if (this.phase === 0) {
                // Neural formation - particles move toward center
                const centerX = this.canvas.width / 2;
                const centerY = this.canvas.height / 2;
                const dx = centerX - particle.x;
                const dy = centerY - particle.y;
                const distance = Math.sqrt(dx * dx + dy * dy);
                if (distance > 50) {
                    particle.vx += dx * 0.0001;
                    particle.vy += dy * 0.0001;
                }
            } else if (this.phase === 1) {
                // Network expansion - particles spread out
                const centerX = this.canvas.width / 2;
                const centerY = this.canvas.height / 2;
                const dx = particle.x - centerX;
                const dy = particle.y - centerY;
                particle.vx += dx * 0.00005;
                particle.vy += dy * 0.00005;
            } else if (this.phase === 2) {
                // Global connection - particles move toward global nodes
                const nearestNode = this.findNearestGlobalNode(particle);
                if (nearestNode) {
                    const dx = nearestNode.x - particle.x;
                    const dy = nearestNode.y - particle.y;
                    particle.vx += dx * 0.0002;
                    particle.vy += dy * 0.0002;
                }
            }
            
            // Apply damping
            particle.vx *= 0.99;
            particle.vy *= 0.99;
        });
    }
    
    updateGlobalNodes() {
        this.globalNodes.forEach(node => {
            node.pulsePhase += 0.05;
            node.energy = Math.sin(node.pulsePhase) * 0.5 + 0.5;
            
            // Activate nodes based on phase
            if (this.phase >= 1) {
                node.active = true;
            }
        });
    }
    
    findNearestGlobalNode(particle) {
        let nearest = null;
        let minDistance = Infinity;
        
        this.globalNodes.forEach(node => {
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
        
        // Create connections between nearby particles
        for (let i = 0; i < this.particles.length; i++) {
            for (let j = i + 1; j < this.particles.length; j++) {
                const p1 = this.particles[i];
                const p2 = this.particles[j];
                const dx = p1.x - p2.x;
                const dy = p1.y - p2.y;
                const distance = Math.sqrt(dx * dx + dy * dy);
                
                let maxDistance = 80;
                if (this.phase === 0) maxDistance = 60;
                else if (this.phase === 1) maxDistance = 100;
                else if (this.phase === 2) maxDistance = 120;
                
                if (distance < maxDistance) {
                    this.connections.push({
                        x1: p1.x, y1: p1.y,
                        x2: p2.x, y2: p2.y,
                        strength: 1 - (distance / maxDistance),
                        energy: (p1.energy + p2.energy) / 2,
                        type: p1.type === p2.type ? p1.type : 'hybrid'
                    });
                }
            }
        }
        
        // Create connections to global nodes in phase 2
        if (this.phase >= 2) {
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
                            type: 'global'
                        });
                    }
                }
            });
        }
    }
    
    render() {
        this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
        
        // Create gradient background
        const gradient = this.ctx.createRadialGradient(
            this.canvas.width / 2, this.canvas.height / 2, 0,
            this.canvas.width / 2, this.canvas.height / 2, Math.max(this.canvas.width, this.canvas.height) / 2
        );
        gradient.addColorStop(0, 'rgba(14, 165, 233, 0.1)');
        gradient.addColorStop(0.5, 'rgba(139, 92, 246, 0.05)');
        gradient.addColorStop(1, 'rgba(0, 0, 0, 0.8)');
        this.ctx.fillStyle = gradient;
        this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
        
        // Render connections
        this.connections.forEach(conn => {
            this.ctx.beginPath();
            this.ctx.moveTo(conn.x1, conn.y1);
            this.ctx.lineTo(conn.x2, conn.y2);
            
            const alpha = conn.strength * conn.energy * 0.6;
            let color;
            
            if (conn.type === 'neural') {
                color = `rgba(14, 165, 233, ${alpha})`;
            } else if (conn.type === 'data') {
                color = `rgba(139, 92, 246, ${alpha})`;
            } else if (conn.type === 'hybrid') {
                color = `rgba(6, 182, 212, ${alpha})`;
            } else if (conn.type === 'global') {
                color = `rgba(255, 255, 255, ${alpha * 0.8})`;
            }
            
            this.ctx.strokeStyle = color;
            this.ctx.lineWidth = conn.strength * 2;
            this.ctx.stroke();
        });
        
        // Render particles
        this.particles.forEach(particle => {
            this.ctx.beginPath();
            this.ctx.arc(particle.x, particle.y, particle.size * (0.5 + particle.energy * 0.5), 0, Math.PI * 2);
            
            let color;
            if (particle.type === 'neural') {
                color = `rgba(14, 165, 233, ${0.3 + particle.energy * 0.7})`;
            } else {
                color = `rgba(139, 92, 246, ${0.3 + particle.energy * 0.7})`;
            }
            
            this.ctx.fillStyle = color;
            this.ctx.fill();
            
            // Add glow effect
            this.ctx.shadowColor = color;
            this.ctx.shadowBlur = particle.size * 3;
            this.ctx.fill();
            this.ctx.shadowBlur = 0;
        });
        
        // Render global nodes
        this.globalNodes.forEach(node => {
            if (!node.active) return;
            
            this.ctx.beginPath();
            this.ctx.arc(node.x, node.y, node.size * (0.5 + node.energy * 0.5), 0, Math.PI * 2);
            
            const color = `rgba(255, 255, 255, ${0.4 + node.energy * 0.6})`;
            this.ctx.fillStyle = color;
            this.ctx.fill();
            
            // Add pulsing ring
            this.ctx.beginPath();
            this.ctx.arc(node.x, node.y, node.size * (1 + node.energy), 0, Math.PI * 2);
            this.ctx.strokeStyle = `rgba(255, 255, 255, ${node.energy * 0.3})`;
            this.ctx.lineWidth = 2;
            this.ctx.stroke();
        });
        
        // Add phase-specific effects
        if (this.phase === 0) {
            this.renderNeuralFormation();
        } else if (this.phase === 1) {
            this.renderNetworkExpansion();
        } else if (this.phase === 2) {
            this.renderGlobalConnection();
        }
    }
    
    renderNeuralFormation() {
        // Central convergence effect
        const centerX = this.canvas.width / 2;
        const centerY = this.canvas.height / 2;
        
        this.ctx.beginPath();
        this.ctx.arc(centerX, centerY, 20 + Math.sin(this.time * 0.01) * 10, 0, Math.PI * 2);
        this.ctx.strokeStyle = `rgba(14, 165, 233, ${0.5 + Math.sin(this.time * 0.01) * 0.3})`;
        this.ctx.lineWidth = 3;
        this.ctx.stroke();
    }
    
    renderNetworkExpansion() {
        // Expanding wave effect
        const centerX = this.canvas.width / 2;
        const centerY = this.canvas.height / 2;
        const waveRadius = (this.time * 0.1) % (Math.max(this.canvas.width, this.canvas.height) / 2);
        
        this.ctx.beginPath();
        this.ctx.arc(centerX, centerY, waveRadius, 0, Math.PI * 2);
        this.ctx.strokeStyle = `rgba(139, 92, 246, ${0.3 - (waveRadius / (Math.max(this.canvas.width, this.canvas.height) / 2)) * 0.3})`;
        this.ctx.lineWidth = 2;
        this.ctx.stroke();
    }
    
    renderGlobalConnection() {
        // Global network pulse
        this.globalNodes.forEach((node, i) => {
            const pulseRadius = 30 + Math.sin(this.time * 0.02 + i) * 15;
            
            this.ctx.beginPath();
            this.ctx.arc(node.x, node.y, pulseRadius, 0, Math.PI * 2);
            this.ctx.strokeStyle = `rgba(255, 255, 255, ${0.2 - (pulseRadius / 45) * 0.2})`;
            this.ctx.lineWidth = 1;
            this.ctx.stroke();
        });
    }
    
    animate() {
        this.time += 16;
        this.updateParticles();
        this.updateGlobalNodes();
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

// Initialize the epic neural loading animation
document.addEventListener('DOMContentLoaded', () => {
    const loadingContainer = document.querySelector('.r3f-loading');
    if (loadingContainer) {
        // Hide the text content
        const textContent = loadingContainer.querySelector('.r3f-loading-inner');
        if (textContent) {
            textContent.style.display = 'none';
        }
        
        // Create the epic animation
        const epicAnimation = new EpicNeuralLoading(loadingContainer);
        
        // Clean up when the loading is complete
        setTimeout(() => {
            epicAnimation.destroy();
        }, 15000); // Run for 15 seconds
    }
});
