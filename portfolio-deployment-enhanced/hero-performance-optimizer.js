// ENHANCED HERO VISUALIZATION - Mobile & Performance Optimized
// Addresses: RAF violations, canvas resolution, particle count, framerate targeting

(function() {
    'use strict';
    
    // Device detection and performance tier
    const isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
    const isTablet = /iPad|Android(?!.*Mobile)/i.test(navigator.userAgent);
    const isLowEnd = navigator.hardwareConcurrency && navigator.hardwareConcurrency < 4;
    const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    const viewportWidth = Math.min(window.innerWidth || 0, window.screen?.width || window.innerWidth || 0);
    const viewportHeight = Math.min(window.innerHeight || 0, window.screen?.height || window.innerHeight || 0);
    const pointerCoarse = window.matchMedia('(pointer:coarse)').matches;
    const isCompactViewport = viewportWidth > 0 && viewportWidth <= 1024;
    const isHandheldViewport = viewportWidth > 0 && viewportWidth <= 768;
    const isLowPowerMobile = pointerCoarse && isHandheldViewport && (navigator.hardwareConcurrency ? navigator.hardwareConcurrency <= 2 : false);

    function checkWebGLSupport() {
        try {
            const canvas = document.createElement('canvas');
            const contextAttributes = {
                powerPreference: 'low-power',
                failIfMajorPerformanceCaveat: true,
                alpha: false,
                antialias: false
            };
            const gl = canvas.getContext('webgl2', contextAttributes)
                || canvas.getContext('webgl', contextAttributes)
                || canvas.getContext('experimental-webgl', contextAttributes);
            if (!gl) {
                return { supported: false, reason: 'webgl-context-unavailable' };
            }
            if (typeof gl.getParameter === 'function') {
                const maxTexture = gl.getParameter(gl.MAX_TEXTURE_SIZE) || 0;
                if (maxTexture && maxTexture < 2048) {
                    return { supported: false, reason: 'webgl-low-capability' };
                }
            }
            return { supported: true, reason: null };
        } catch (error) {
            return { supported: false, reason: (error && error.message) ? error.message : 'webgl-check-failed' };
        }
    }

    const webglCapability = checkWebGLSupport();
    const hasWebGLSupport = webglCapability.supported;
    
    // Performance configuration based on device
    const performanceConfig = {
        // Particle counts
        particles: {
            desktop: 12000,
            tablet: 8000,
            mobile: 6000,
            lowEnd: 3000
        },
        
        // Stars count
        stars: {
            desktop: 16000,
            tablet: 12000,
            mobile: 8000,
            lowEnd: 5000
        },
        
        // Target FPS
        targetFPS: {
            desktop: 60,
            tablet: 45,
            mobile: 30,
            lowEnd: 24
        },
        
        // Canvas DPR (device pixel ratio)
        dpr: {
            desktop: Math.min(window.devicePixelRatio, 2),
            tablet: Math.min(window.devicePixelRatio, 1.5),
            mobile: 1,
            lowEnd: 1
        },
        
        // Quality settings
        quality: {
            desktop: { antialias: true, shadows: true },
            tablet: { antialias: false, shadows: false },
            mobile: { antialias: false, shadows: false },
            lowEnd: { antialias: false, shadows: false }
        }
    };
    
    // Determine device tier
    function getDeviceTier() {
        if (prefersReducedMotion || isLowEnd || isLowPowerMobile) {
            return 'lowEnd';
        }
        if (isMobile || isHandheldViewport || (!isTablet && pointerCoarse)) {
            return 'mobile';
        }
        if (isTablet || isCompactViewport) {
            return 'tablet';
        }
        return 'desktop';
    }
    
    const deviceTier = getDeviceTier();
    const config = {
        particles: performanceConfig.particles[deviceTier],
        stars: performanceConfig.stars[deviceTier],
        targetFPS: performanceConfig.targetFPS[deviceTier],
        dpr: performanceConfig.dpr[deviceTier],
        quality: performanceConfig.quality[deviceTier]
    };
    const computedFallbackReason = !hasWebGLSupport
        ? (webglCapability.reason || 'webgl-unavailable')
        : (prefersReducedMotion ? 'reduced-motion' : (deviceTier === 'lowEnd' ? 'low-tier-device' : null));
    const shouldLoadR3F = hasWebGLSupport && !(prefersReducedMotion || deviceTier === 'lowEnd');
    
    console.log(`📱 Device Tier: ${deviceTier}`, {
        tier: deviceTier,
        shouldLoadR3F,
        viewportWidth,
        viewportHeight,
        pointerCoarse,
        prefersReducedMotion,
        isMobileUA: isMobile,
        isTabletUA: isTablet,
        isLowEndHardware: Boolean(isLowEnd),
        isLowPowerMobile,
        hasWebGLSupport,
        webglFailureReason: hasWebGLSupport ? null : computedFallbackReason,
        config
    });
    
    // Framerate throttling to prevent RAF violations
    class FramerateThrottle {
        constructor(targetFPS = 60) {
            this.targetFPS = targetFPS;
            this.frameInterval = 1000 / targetFPS;
            this.lastFrameTime = performance.now();
            this.rafID = null;
        }
        
        shouldRender() {
            const now = performance.now();
            const elapsed = now - this.lastFrameTime;
            
            if (elapsed >= this.frameInterval) {
                this.lastFrameTime = now - (elapsed % this.frameInterval);
                return true;
            }
            return false;
        }
        
        request(callback) {
            if (this.rafID) {
                cancelAnimationFrame(this.rafID);
            }
            this.rafID = requestAnimationFrame(callback);
            return this.rafID;
        }
        
        cancel() {
            if (this.rafID) {
                cancelAnimationFrame(this.rafID);
                this.rafID = null;
            }
        }
    }
    
    // Canvas resolution optimizer
    class CanvasOptimizer {
        static optimizeCanvas(canvas, container) {
            if (!canvas || !container) return;
            
            const containerRect = container.getBoundingClientRect();
            const width = containerRect.width;
            const height = containerRect.height;
            const dpr = config.dpr;
            
            // Set actual size
            canvas.width = width * dpr;
            canvas.height = height * dpr;
            
            // Set CSS size
            canvas.style.width = `${width}px`;
            canvas.style.height = `${height}px`;
            
            console.log(`🎨 Canvas optimized: ${canvas.width}x${canvas.height} (DPR: ${dpr})`);
        }
        
        static handleResize(canvas, container, callback) {
            let resizeTimeout;
            const resizeHandler = () => {
                clearTimeout(resizeTimeout);
                resizeTimeout = setTimeout(() => {
                    CanvasOptimizer.optimizeCanvas(canvas, container);
                    if (callback) callback();
                }, 150);
            };
            
            window.addEventListener('resize', resizeHandler);
            return () => window.removeEventListener('resize', resizeHandler);
        }
    }
    
    // Performance monitor
    class PerformanceMonitor {
        constructor() {
            this.frameTimes = [];
            this.maxSamples = 60;
            this.warningThreshold = 33; // 30fps = 33ms per frame
            this.lastWarning = 0;
        }
        
        recordFrame(deltaTime) {
            this.frameTimes.push(deltaTime);
            if (this.frameTimes.length > this.maxSamples) {
                this.frameTimes.shift();
            }
        }
        
        getAverageFPS() {
            if (this.frameTimes.length === 0) return 0;
            const avgFrameTime = this.frameTimes.reduce((a, b) => a + b) / this.frameTimes.length;
            return 1000 / avgFrameTime;
        }
        
        getFrameTimeStats() {
            if (this.frameTimes.length === 0) return { min: 0, max: 0, avg: 0 };
            const sorted = [...this.frameTimes].sort((a, b) => a - b);
            return {
                min: sorted[0],
                max: sorted[sorted.length - 1],
                avg: sorted.reduce((a, b) => a + b) / sorted.length,
                p95: sorted[Math.floor(sorted.length * 0.95)]
            };
        }
        
        checkPerformance() {
            const stats = this.getFrameTimeStats();
            const now = Date.now();
            
            // Warn only every 10 seconds to avoid spam
            if (stats.avg > this.warningThreshold && now - this.lastWarning > 10000) {
                console.warn(`⚠️ Performance: ${this.getAverageFPS().toFixed(1)} FPS (avg frame time: ${stats.avg.toFixed(1)}ms)`);
                this.lastWarning = now;
                return false;
            }
            return true;
        }
    }
    
    // Intersection Observer for lazy loading
    class LazyHeroLoader {
        static observe(element, loadCallback) {
            if (!('IntersectionObserver' in window)) {
                // Fallback: load immediately
                loadCallback();
                return () => {};
            }
            
            const observer = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        console.log('🎬 Hero visualization entering viewport - loading...');
                        loadCallback();
                        observer.disconnect();
                    }
                });
            }, {
                rootMargin: '50px', // Start loading 50px before visible
                threshold: 0.1
            });
            
            observer.observe(element);
            return () => observer.disconnect();
        }
    }
    
    // Static fallback (used for reduced motion or low-tier devices)
    function createStaticHeroFallback(reason = 'reduced-motion') {
        const hero = document.getElementById('hero-visualization');
        if (!hero) return;

        const message = (reason && reason.startsWith('webgl'))
            ? 'Interactive 3D hero disabled on this device; static visualization shown.'
            : 'Data Engineering & Analytics Platform';

        hero.innerHTML = `
            <div class="reduced-motion-hero">
                <svg width="400" height="400" viewBox="0 0 200 200" style="max-width: 100%; height: auto;">
                    <defs>
                        <linearGradient id="heroGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                            <stop offset="0%" style="stop-color:#a78bfa;stop-opacity:1" />
                            <stop offset="50%" style="stop-color:#0ea5e9;stop-opacity:1" />
                            <stop offset="100%" style="stop-color:#06b6d4;stop-opacity:1" />
                        </linearGradient>
                    </defs>
                    <circle cx="100" cy="100" r="80" fill="none" stroke="url(#heroGradient)" stroke-width="2" />
                    <circle cx="100" cy="100" r="60" fill="none" stroke="url(#heroGradient)" stroke-width="1.5" opacity="0.6" />
                    <circle cx="100" cy="100" r="40" fill="none" stroke="url(#heroGradient)" stroke-width="1" opacity="0.4" />
                    <circle cx="100" cy="100" r="20" fill="url(#heroGradient)" opacity="0.2" />
                </svg>
                <p style="text-align: center; color: #64748b; margin-top: 20px;">${message}</p>
            </div>
        `;
        hero.classList.add('hero-static-fallback');
        hero.setAttribute('data-hero-fallback', reason);
    hero.dataset.loaded = 'fallback';
    hero.setAttribute('data-r3f-skipped', '1');
        console.log(`🛡️ Hero static fallback displayed (${reason})`);
    }
    
    // GPU tier detection (simplified)
    async function detectGPUTier() {
        try {
            const canvas = document.createElement('canvas');
            const gl = canvas.getContext('webgl') || canvas.getContext('experimental-webgl');
            if (!gl) return { tier: 1, gpu: 'unknown' };
            
            const debugInfo = gl.getExtension('WEBGL_debug_renderer_info');
            const renderer = debugInfo ? gl.getParameter(debugInfo.UNMASKED_RENDERER_WEBGL) : 'unknown';
            
            // Simple tier detection based on renderer string
            const tier = renderer.toLowerCase().includes('intel') ? 2 :
                        renderer.toLowerCase().includes('nvidia') || 
                        renderer.toLowerCase().includes('amd') ? 3 : 1;
            
            console.log(`🎮 GPU Detected: ${renderer} (Tier ${tier})`);
            return { tier, gpu: renderer };
        } catch (e) {
            console.warn('GPU detection failed:', e);
            return { tier: 1, gpu: 'unknown' };
        }
    }
    
    const heroState = {
        config,
        deviceTier,
        shouldLoadR3F,
        viewport: {
            width: viewportWidth,
            height: viewportHeight,
            pointerCoarse
        },
        conditions: {
            isMobileUA: isMobile,
            isTabletUA: isTablet,
            isLowEndHardware: Boolean(isLowEnd),
            prefersReducedMotion,
            isLowPowerMobile,
            hasWebGLSupport,
            webglFailureReason: hasWebGLSupport ? null : computedFallbackReason
        },
        CanvasOptimizer,
        LazyHeroLoader,
        detectGPUTier,
        perfMonitor: null,
        throttle: null,
        staticFallbackApplied: !shouldLoadR3F,
        fallbackReason: shouldLoadR3F ? null : computedFallbackReason,
        webglSupported: hasWebGLSupport,
        webglFailureReason: hasWebGLSupport ? null : computedFallbackReason,
        updatedAt: Date.now()
    };

    window.heroPerformance = heroState;

    // Main initialization
    function initHeroOptimizations() {
        const root = document.documentElement;
        if (root) {
            root.setAttribute('data-hero-tier', deviceTier);
            root.classList.toggle('hero-tier-mobile', deviceTier === 'mobile');
            root.classList.toggle('hero-tier-tablet', deviceTier === 'tablet');
            root.classList.toggle('hero-tier-lowend', deviceTier === 'lowEnd');
        }

        if (!shouldLoadR3F) {
            const reason = computedFallbackReason || (prefersReducedMotion ? 'reduced-motion' : 'low-tier-device');
            createStaticHeroFallback(reason);
            heroState.staticFallbackApplied = true;
            heroState.fallbackReason = reason;
            heroState.shouldLoadR3F = false;
            heroState.webglSupported = hasWebGLSupport;
            heroState.webglFailureReason = !hasWebGLSupport ? reason : null;
            heroState.updatedAt = Date.now();
            window.heroPerformance = heroState;
            window.dispatchEvent(new CustomEvent('heroPerformance:ready', { detail: heroState }));
            return;
        }

        if (!hasWebGLSupport) {
            return;
        }

        if (!window.__HERO_WEBGL_GUARD__) {
            window.__HERO_WEBGL_GUARD__ = true;
            document.addEventListener('webglcontextlost', (event) => {
                const target = event.target;
                if (!(target instanceof HTMLCanvasElement)) return;
                if (!target.closest || !target.closest('#hero-visualization')) return;
                event.preventDefault();
                console.warn('🛑 Hero WebGL context lost, switching to static fallback');
                createStaticHeroFallback('webgl-context-lost');
                heroState.staticFallbackApplied = true;
                heroState.fallbackReason = 'webgl-context-lost';
                heroState.shouldLoadR3F = false;
                heroState.webglSupported = false;
                heroState.webglFailureReason = 'webgl-context-lost';
                heroState.updatedAt = Date.now();
                window.heroPerformance = heroState;
                window.dispatchEvent(new CustomEvent('heroPerformance:contextLost', { detail: heroState }));
            }, { passive: false });
        }

        const perfMonitor = new PerformanceMonitor();
        const throttle = new FramerateThrottle(config.targetFPS);
        heroState.perfMonitor = perfMonitor;
        heroState.throttle = throttle;
        heroState.staticFallbackApplied = false;
        heroState.fallbackReason = null;
        heroState.webglSupported = true;
        heroState.webglFailureReason = null;
        heroState.updatedAt = Date.now();
        window.heroPerformance = heroState;
        window.dispatchEvent(new CustomEvent('heroPerformance:ready', { detail: heroState }));

        console.log('✨ Hero performance optimizations ready', {
            tier: deviceTier,
            particles: config.particles,
            targetFPS: config.targetFPS,
            dpr: config.dpr
        });
    }
    
    // Initialize when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initHeroOptimizations);
    } else {
        initHeroOptimizations();
    }
    
})();
