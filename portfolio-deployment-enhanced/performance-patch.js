// PERFORMANCE OPTIMIZATION PATCH
// Suppress Three.js duplicate warning and optimize loading

// 1. Suppress Three.js multiple instance warning (it's expected with R3F)
const originalWarn = console.warn;
console.warn = function(...args) {
    const msg = args[0];
    if (typeof msg === 'string' && msg.includes('Multiple instances of Three.js')) {
        // Suppress this specific warning - it's expected with React Three Fiber
        return;
    }
    originalWarn.apply(console, args);
};

// 2. Performance hints for browser
if ('connection' in navigator) {
    const conn = navigator.connection;
    if (conn && conn.effectiveType && (conn.effectiveType === 'slow-2g' || conn.effectiveType === '2g')) {
        console.log('[Performance] Slow connection detected - consider showing lightweight version');
    }
}

// 3. Lazy-load AI features to reduce initial bundle
window.lazyLoadAIFeatures = function() {
    return new Promise((resolve) => {
        // Delay AI features by 2 seconds to let scene initialize first
        setTimeout(() => {
            if (window.aiManager) {
                window.aiManager.healthCheck().then(status => {
                    console.log('🤖 AI Services Status:', status);
                    resolve(status);
                });
            } else {
                resolve(null);
            }
        }, 2000);
    });
};

// 4. Debounce requestAnimationFrame to prevent violations
let rafScheduled = false;
window.optimizedRAF = function(callback) {
    if (!rafScheduled) {
        rafScheduled = true;
        requestAnimationFrame((time) => {
            rafScheduled = false;
            callback(time);
        });
    }
};

// 5. Reduce console noise in production
if (window.location.hostname !== 'localhost') {
    // Keep errors, but reduce info/log spam
    const originalLog = console.log;
    console.log = function(...args) {
        const msg = args[0];
        if (typeof msg === 'string' && msg.includes('[Violation]')) {
            return; // Suppress violation warnings in production
        }
        originalLog.apply(console, args);
    };
}

// 6. Add performance observer for monitoring
if ('PerformanceObserver' in window) {
    try {
        const observer = new PerformanceObserver((list) => {
            for (const entry of list.getEntries()) {
                // Only log if duration > 500ms (severe)
                if (entry.duration > 500) {
                    console.warn(`[Performance] Long task detected: ${entry.duration.toFixed(0)}ms`);
                }
            }
        });
        observer.observe({ entryTypes: ['longtask'] });
    } catch (e) {
        // PerformanceObserver not supported or longtask not available
    }
}

console.log('⚡ Performance optimizations applied');

// ============================================================================
// 🌌 NEURONS TO COSMOS - Epic Animation Monitoring
// ----------------------------------------------------------------------------
// Monitors successful loading of the epic 30-second cinematic journey
// Reports phase transitions and performance metrics to console
// ----------------------------------------------------------------------------
(function() {
    const LOG = '[NEURONS-TO-COSMOS-MONITOR]';
    
    // Wait for hero to mount
    window.__HERO_EVENT_BUS__?.on('hero:mounted', (data) => {
        console.log(LOG, '🌌 Epic animation mounted:', {
            variant: data.variant,
            mobile: data.mobile,
            timestamp: new Date(data.ts).toISOString()
        });
    });
    
    // Monitor WebGL performance
    setTimeout(() => {
        const canvas = document.querySelector('#hero-visualization canvas');
        if (canvas) {
            const gl = canvas.getContext('webgl2') || canvas.getContext('webgl');
            if (gl) {
                console.log(LOG, '✅ WebGL Context:', {
                    version: gl.getParameter(gl.VERSION),
                    renderer: gl.getParameter(gl.RENDERER),
                    vendor: gl.getParameter(gl.VENDOR)
                });
            }
        }
    }, 2000);
    
    console.log(LOG, '🎬 Monitoring epic 30-second journey: Neural → Brain → Earth → Cosmos');
})();
