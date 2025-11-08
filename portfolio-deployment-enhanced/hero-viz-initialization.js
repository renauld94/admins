/**
 * HERO VISUALIZATION INITIALIZATION - BULLETPROOF
 * Ensures Epic Neural Cosmos visualization loads and renders correctly
 * Handles all initialization paths: THREE.js, deferred init, fallbacks
 */

(function() {
    'use strict';
    
    console.log('🚀 [HERO VIZ] Initializer loaded');
    
    // Track initialization state
    const state = {
        threeJsReady: false,
        heroMounted: false,
        hasTried: false,
        lastError: null
    };
    
    // Helper: Check if container exists and is visible
    function getHeroContainer() {
        return document.getElementById('hero-visualization');
    }
    
    function isContainerValid() {
        const container = getHeroContainer();
        if (!container) {
            console.warn('[HERO VIZ] Container #hero-visualization not found');
            return false;
        }
        
        const rect = container.getBoundingClientRect();
        if (rect.width === 0 || rect.height === 0) {
            console.warn('[HERO VIZ] Container has zero dimensions', rect);
            return false;
        }
        
        console.log(`[HERO VIZ] Container valid: ${rect.width}x${rect.height}`);
        return true;
    }
    
    // Main initialization function
    function initHeroVisualization() {
        if (state.heroMounted || state.hasTried) {
            console.log('[HERO VIZ] Already attempted or mounted, skipping');
            return;
        }
        
        state.hasTried = true;
        
        console.log('[HERO VIZ] Starting initialization...');
        
        // Check container
        if (!isContainerValid()) {
            console.error('[HERO VIZ] Container validation failed');
            showFallback();
            return;
        }
        
        // Check if mobile
        const isMobile = window.__IS_MOBILE_PORTFOLIO__ || /Mobi|Android/i.test(navigator.userAgent);
        
        if (isMobile) {
            console.log('[HERO VIZ] Mobile device detected, using simple visualization');
            loadSimpleVisualization();
            return;
        }
        
        // Check if THREE.js is available
        if (typeof THREE === 'undefined') {
            console.warn('[HERO VIZ] THREE.js not available yet, waiting...');
            return;
        }
        
        console.log('✅ [HERO VIZ] THREE.js confirmed available');
        loadEpicVisualization();
    }
    
    // Load Epic Neural Cosmos Visualization (enhanced version only - no duplicate loading)
    function loadEpicVisualization() {
        console.log('[HERO VIZ] Checking for enhanced visualization...');
        
        // Check if enhanced version is already loaded (preloaded via index.html)
        if (typeof window.EpicNeuralToCosmosVizEnhanced !== 'undefined') {
            console.log('✅ [HERO VIZ] Enhanced visualization class already loaded, mounting...');
            mountEpicVisualization();
            return;
        }
        
        // If not already loaded, load it now (shouldn't normally happen since it's in index.html)
        console.log('[HERO VIZ] Enhanced visualization not yet loaded, loading now...');
        
        const script = document.createElement('script');
        script.src = './epic-neural-cosmos-viz-enhanced.js?v=' + Date.now();
        script.onload = () => {
            console.log('✅ [HERO VIZ] epic-neural-cosmos-viz-enhanced.js loaded');
            
            if (typeof window.EpicNeuralToCosmosVizEnhanced === 'undefined') {
                console.error('[HERO VIZ] EpicNeuralToCosmosVizEnhanced class not found after loading');
                showFallback();
                return;
            }
            
            mountEpicVisualization();
        };
        
        script.onerror = (err) => {
            console.error('[HERO VIZ] Failed to load epic-neural-cosmos-viz-enhanced.js:', err);
            showFallback();
        };
        
        document.head.appendChild(script);
    }
    
    // Mount the visualization (enhanced version only)
    function mountEpicVisualization() {
        console.log('[HERO VIZ] Mounting Epic Neural Cosmos visualization...');
        
        try {
            const container = getHeroContainer();
            if (!container) {
                console.error('[HERO VIZ] Container disappeared during mount');
                showFallback();
                return;
            }
            // Local mobile detection for use inside nested helpers
            const isMobile = window.__IS_MOBILE_PORTFOLIO__ || /Mobi|Android/i.test(navigator.userAgent || '');
            
            // Use enhanced version (no fallback to original to avoid duplicate class declarations)
            const VizClass = window.EpicNeuralToCosmosVizEnhanced;
            
            if (!VizClass) {
                console.error('[HERO VIZ] EpicNeuralToCosmosVizEnhanced class not available');
                showFallback();
                return;
            }
            
            console.log('[HERO VIZ] Using visualization class: EpicNeuralToCosmosVizEnhanced');
            
            // Create instance with deferred initialization
            const viz = new VizClass('hero-visualization', {
                autoTransition: true,
                transitionDuration: 28000, // 28 seconds per phase for epic feel
                particleCount: 5000,
                enableInteraction: true,
                deferInit: true // CRITICAL: defer heavy setup
            });
            
            // Store globally for debugging
            window.heroVisualization = viz;
            state.heroMounted = true;
            
            console.log('✅ [HERO VIZ] Epic visualization instance created');
            console.log('[HERO VIZ] Scheduling deferred initialization...');

            // Helper: attempt to lazy-load Three.js post-processing example scripts
            function ensurePostProcessingLibs() {
                if (window.THREE && window.THREE.EffectComposer) return Promise.resolve();
                if (isMobile) return Promise.resolve(); // skip on mobile

                const sources = [
                    'https://cdn.jsdelivr.net/npm/three@0.128.0/examples/js/postprocessing/EffectComposer.js',
                    'https://cdn.jsdelivr.net/npm/three@0.128.0/examples/js/postprocessing/RenderPass.js',
                    'https://cdn.jsdelivr.net/npm/three@0.128.0/examples/js/shaders/LuminosityHighPassShader.js',
                    'https://cdn.jsdelivr.net/npm/three@0.128.0/examples/js/postprocessing/UnrealBloomPass.js'
                ];

                return new Promise((resolve) => {
                    let i = 0;
                    const next = () => {
                        if (i >= sources.length) return resolve();
                        const s = document.createElement('script');
                        s.src = sources[i++];
                        s.async = true;
                        s.onload = () => next();
                        s.onerror = () => {
                            console.warn('[HERO VIZ] Post-processing script failed to load:', s.src);
                            next();
                        };
                        document.head.appendChild(s);
                    };
                    next();
                });
            }

            // Schedule deferred init in next frame, but ensure post-processing libs are loaded first on capable devices
            const runDeferred = () => {
                console.log('[HERO VIZ] Running deferred init...');
                if (viz.runDeferredInit) {
                    viz.runDeferredInit().catch(err => {
                        console.error('[HERO VIZ] Deferred init failed:', err);
                        showFallback();
                    });
                } else {
                    console.log('[HERO VIZ] Visualization already initialized');
                }
            };

            if (typeof requestIdleCallback === 'function') {
                requestIdleCallback(() => {
                    console.log('[HERO VIZ] requestIdleCallback fired - preparing deferred init');
                    ensurePostProcessingLibs().then(runDeferred);
                }, { timeout: 3000 });
            } else {
                setTimeout(() => {
                    console.log('[HERO VIZ] setTimeout fired - preparing deferred init');
                    ensurePostProcessingLibs().then(runDeferred);
                }, 500);
            }
            
        } catch (err) {
            console.error('[HERO VIZ] Mount error:', err);
            state.lastError = err;
            showFallback();
        }
    }
    
    // Load simple visualization as fallback
    function loadSimpleVisualization() {
        console.log('[HERO VIZ] Loading simple neural visualization...');
        
        const script = document.createElement('script');
        script.src = './simple-neural-viz.js';
        script.onload = () => {
            console.log('✅ [HERO VIZ] simple-neural-viz.js loaded');
            
            try {
                if (typeof SimpleNeuralViz === 'undefined') {
                    console.error('[HERO VIZ] SimpleNeuralViz not found');
                    showFallback();
                    return;
                }
                
                const viz = new SimpleNeuralViz('hero-visualization', {
                    particleCount: 2000
                });
                
                window.heroVisualization = viz;
                state.heroMounted = true;
                
                console.log('✅ [HERO VIZ] Simple visualization mounted');
                
                // Try to upgrade to advanced visualization
                setTimeout(() => {
                    loadAdvancedVisualization();
                }, 2000);
                
            } catch (err) {
                console.error('[HERO VIZ] Simple visualization mount failed:', err);
                showFallback();
            }
        };
        
        script.onerror = (err) => {
            console.error('[HERO VIZ] Failed to load simple visualization:', err);
            showFallback();
        };
        
        document.head.appendChild(script);
    }
    
    // Try to load advanced visualization on top of simple
    function loadAdvancedVisualization() {
        console.log('[HERO VIZ] Attempting to load advanced GeoServer visualization...');
        
        const perfScript = document.createElement('script');
        perfScript.src = './neural-geoserver-performance.js?v=PERF20250113';
        perfScript.onload = () => {
            const script = document.createElement('script');
            script.src = './neural-geoserver-viz.js?v=NEURAL20250113';
            script.onload = () => {
                console.log('✅ [HERO VIZ] Advanced GeoServer visualization loaded');
                
                try {
                    if (window.heroVisualization && typeof window.heroVisualization.destroy === 'function') {
                        window.heroVisualization.destroy();
                    }
                    
                    const viz = new NeuralGeoServerViz('hero-visualization', {
                        geoserverUrl: 'https://www.simondatalab.de/geospatial-viz',
                        proxmoxUrl: '',
                        particleCount: 15000,
                        enableGPUAcceleration: true,
                        enableLOD: true,
                        enableFrustumCulling: true,
                        updateInterval: 5000
                    });
                    
                    window.heroVisualization = viz;
                    console.log('✅ [HERO VIZ] Advanced visualization mounted');
                    
                } catch (err) {
                    console.warn('[HERO VIZ] Advanced visualization failed, keeping simple version:', err);
                }
            };
            
            script.onerror = () => {
                console.warn('[HERO VIZ] Advanced visualization script failed to load');
            };
            
            document.head.appendChild(script);
        };
        
        perfScript.onerror = () => {
            console.warn('[HERO VIZ] Performance optimizer failed to load');
        };
        
        document.head.appendChild(perfScript);
    }
    
    // Show fallback when everything fails
    function showFallback() {
        console.log('[HERO VIZ] Showing fallback...');
        
        const container = getHeroContainer();
        if (!container) return;
        
        container.innerHTML = `
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
                <div style="text-align: center;">
                    <div style="
                        font-size: 2rem;
                        opacity: 0.5;
                        font-weight: 300;
                        letter-spacing: 1px;
                    ">Loading...</div>
                </div>
            </div>
        `;
        
        state.heroMounted = true;
    }
    
    // Listen for THREE.js ready event
    window.addEventListener('threeJsReady', () => {
        console.log('📦 [HERO VIZ] Received threeJsReady event');
        state.threeJsReady = true;
        initHeroVisualization();
    });
    
    // Also try direct initialization on DOMContentLoaded in case THREE.js is already loaded
    function tryDirectInit() {
        if (typeof THREE !== 'undefined' && !state.threeJsReady) {
            console.log('[HERO VIZ] THREE.js found directly available, initializing...');
            state.threeJsReady = true;
            initHeroVisualization();
        }
    }
    
    // Multiple initialization triggers
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', () => {
            console.log('[HERO VIZ] DOMContentLoaded fired');
            tryDirectInit();
            // If still not initialized after a delay, force it
            setTimeout(() => {
                if (!state.heroMounted && state.threeJsReady) {
                    console.log('[HERO VIZ] Force initialization after DOMContentLoaded timeout');
                    initHeroVisualization();
                }
            }, 2000);
        });
    } else {
        console.log('[HERO VIZ] Document already loaded');
        tryDirectInit();
    }
    
    // Also try on load event (all resources loaded)
    window.addEventListener('load', () => {
        console.log('[HERO VIZ] Window load event fired');
        tryDirectInit();
        if (!state.heroMounted && state.threeJsReady) {
            console.log('[HERO VIZ] Force initialization after load event');
            initHeroVisualization();
        }
    });
    
    // Expose manual trigger for debugging
    window.initHeroVisualization = () => {
        console.log('[HERO VIZ] Manual initialization triggered');
        state.hasTried = false;
        initHeroVisualization();
    };
    
    console.log('✅ [HERO VIZ] Initialization script loaded and ready');
    console.log('   Use window.initHeroVisualization() to manually trigger');
    console.log('   Check window.heroVisualization for instance');
    
})();
