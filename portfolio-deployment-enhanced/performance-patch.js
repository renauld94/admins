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
// Optimized RAF: debounce on desktop, and cap FPS on mobile to reduce GPU/CPU pressure
window.optimizedRAF = function(callback) {
    const isMobile = !!(window.__IS_MOBILE_PORTFOLIO__ || /Mobi|Android/i.test(navigator.userAgent || ''));
    if (isMobile) {
        // Cap at ~30 FPS on mobile
        window.__optimized_last_time_mobile = window.__optimized_last_time_mobile || 0;
        const minInterval = 1000 / 30; // ms
        const schedule = (time) => {
            const elapsed = time - window.__optimized_last_time_mobile;
            if (elapsed >= minInterval) {
                window.__optimized_last_time_mobile = time;
                try { callback(time); } catch (e) { console.error(e); }
            } else {
                // schedule next attempt after remaining time
                setTimeout(() => requestAnimationFrame((t) => {
                    window.__optimized_last_time_mobile = t;
                    try { callback(t); } catch (e) { console.error(e); }
                }), Math.max(0, Math.ceil(minInterval - elapsed)));
            }
        };
        requestAnimationFrame(schedule);
        return;
    }

    // Desktop: simple debounce to avoid stacking too many RAFs
    if (!rafScheduled) {
        rafScheduled = true;
        requestAnimationFrame((time) => {
            rafScheduled = false;
            try { callback(time); } catch (e) { console.error(e); }
        });
    }
};

// 4.b Performance patch utilities: low-power mode, pixel-ratio cap, and FPS telemetry
(function(){
    const isMobile = !!(window.__IS_MOBILE_PORTFOLIO__ || /Mobi|Android/i.test(navigator.userAgent || ''));

    // Default global caps (can be changed via API)
    window.__SIMON_MAX_DEVICE_PIXEL_RATIO__ = window.__SIMON_MAX_DEVICE_PIXEL_RATIO__ || (isMobile ? 1 : 2);
    window.__SIMON_LOW_POWER_MODE__ = window.__SIMON_LOW_POWER_MODE__ || false;

    // Helper: return a capped device pixel ratio for renderers to use
    window.getCappedDevicePixelRatio = function() {
        try { return Math.min(window.devicePixelRatio || 1, window.__SIMON_MAX_DEVICE_PIXEL_RATIO__); } catch (e) { return 1; }
    };

    // Expose a simple performancePatch API
    window.performancePatch = window.performancePatch || {};

    // Enable low-power mode: caps pixel ratio and replaces requestAnimationFrame with a throttled loop
    window.performancePatch.enableLowPowerMode = function(opts = {}) {
        opts = Object.assign({ maxFPS: 30, maxDevicePixelRatio: isMobile ? 1 : 1.5 }, opts);
        window.__SIMON_LOW_POWER_MODE__ = true;
        window.__SIMON_MAX_DEVICE_PIXEL_RATIO__ = opts.maxDevicePixelRatio;

        // Replace requestAnimationFrame with a throttled version (only if not already replaced)
        if (!window.__orig_requestAnimationFrame__) {
            window.__orig_requestAnimationFrame__ = window.requestAnimationFrame;
            window.__orig_cancelAnimationFrame__ = window.cancelAnimationFrame;

            const interval = Math.round(1000 / opts.maxFPS);
            const timers = new Map();
            let nextId = 1;

            window.requestAnimationFrame = function(cb) {
                const id = nextId++;
                const handle = setTimeout(() => {
                    try { cb(performance && performance.now ? performance.now() : Date.now()); } catch (e) { console.error(e); }
                    timers.delete(id);
                }, interval);
                timers.set(id, handle);
                return id;
            };

            window.cancelAnimationFrame = function(id) {
                const handle = timers.get(id);
                if (handle) {
                    clearTimeout(handle);
                    timers.delete(id);
                }
            };
        }

        console.log(`[Performance] Low-power mode enabled: ${opts.maxFPS} FPS, DPR cap ${window.__SIMON_MAX_DEVICE_PIXEL_RATIO__}`);
    };

    window.performancePatch.disableLowPowerMode = function() {
        if (window.__orig_requestAnimationFrame__) {
            window.requestAnimationFrame = window.__orig_requestAnimationFrame__;
            window.cancelAnimationFrame = window.__orig_cancelAnimationFrame__;
            delete window.__orig_requestAnimationFrame__;
            delete window.__orig_cancelAnimationFrame__;
        }
        window.__SIMON_LOW_POWER_MODE__ = false;
        console.log('[Performance] Low-power mode disabled');
    };

    // Simple FPS sampler - can be started/stopped; default behavior logs to console and stores last sample in localStorage
    (function(){
        let sampling = false;
        let frames = 0;
        let last = performance && performance.now ? performance.now() : Date.now();
        let rafId = null;

        function tick() {
            frames++;
            const now = performance && performance.now ? performance.now() : Date.now();
            const elapsed = now - last;
            if (elapsed >= 1000) {
                const fps = Math.round((frames / elapsed) * 1000);
                frames = 0;
                last = now;
                const payload = { fps, ts: Date.now(), lowPower: !!window.__SIMON_LOW_POWER_MODE__ };
                try {
                    // Hook for custom telemetry receiver
                    if (typeof window.onPerformanceTelemetry === 'function') {
                        window.onPerformanceTelemetry(payload);
                    } else {
                        console.log('[Performance][Telemetry]', payload);
                    }
                    // Store last sample locally for debugging
                    try { localStorage.setItem('simon_perf_last_sample', JSON.stringify(payload)); } catch (e) {}
                } catch (e) { console.error(e); }
            }
            if (sampling) rafId = window.requestAnimationFrame(tick);
        }

        window.performancePatch.startFPSSampling = function() {
            if (sampling) return;
            sampling = true;
            frames = 0;
            last = performance && performance.now ? performance.now() : Date.now();
            rafId = window.requestAnimationFrame(tick);
            console.log('[Performance] FPS sampling started');
        };

        window.performancePatch.stopFPSSampling = function() {
            sampling = false;
            if (rafId != null) {
                try { window.cancelAnimationFrame(rafId); } catch (e) {}
                rafId = null;
            }
            console.log('[Performance] FPS sampling stopped');
        };
    })();

    // Auto-enable low-power mode for mobile devices by default (can be disabled by setting window.__SIMON_LOW_POWER_MODE__ = false before this script runs)
    try {
        if (isMobile && !window.__SIMON_LOW_POWER_MODE__) {
            // If the site explicitly requested a high-power mode by setting the flag, do not override
            window.performancePatch.enableLowPowerMode();
        }
    } catch (e) { console.error(e); }

})();

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
