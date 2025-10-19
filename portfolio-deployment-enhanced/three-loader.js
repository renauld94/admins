/**
 * THREE.js Loader with OrbitControls
 * Ensures proper loading of THREE.js and OrbitControls for the neural visualization
 */

(function() {
    'use strict';
    
    console.log('Loading THREE.js with OrbitControls...');
    
    // Check if already loaded
    if (window.THREE && window.THREE.OrbitControls) {
        console.log('THREE.js and OrbitControls already available');
        window.dispatchEvent(new CustomEvent('threeJsReady'));
        return;
    }
    
    // Load THREE.js first
    function loadThreeJS() {
        return new Promise((resolve, reject) => {
            const script = document.createElement('script');
            script.src = 'https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js';
            script.onload = () => {
                console.log('THREE.js loaded successfully');
                resolve();
            };
            script.onerror = () => {
                reject(new Error('Failed to load THREE.js'));
            };
            document.head.appendChild(script);
        });
    }
    
    // Load OrbitControls (prefer stable CDN first to avoid initial errors)
    function loadOrbitControls() {
        return new Promise((resolve) => {
            const sources = [
                // Stable first
                'https://cdn.jsdelivr.net/npm/three@0.128.0/examples/js/controls/OrbitControls.js',
                // Fallbacks
                'https://unpkg.com/three@0.128.0/examples/js/controls/OrbitControls.js',
                'https://threejs.org/examples/js/controls/OrbitControls.js'
            ];
            
            let index = 0;
            const tryNext = () => {
                if (index >= sources.length) {
                    console.warn('OrbitControls unavailable, continuing without it');
                    return resolve();
                }
                const src = sources[index++];
                const s = document.createElement('script');
                s.src = src;
                s.onload = () => {
                    console.log('OrbitControls loaded from', src);
                    resolve();
                };
                s.onerror = () => {
                    console.warn('Failed to load OrbitControls from', src);
                    tryNext();
                };
                document.head.appendChild(s);
            };
            tryNext();
        });
    }
    
    // Load both sequentially
    async function loadAll() {
        try {
            await loadThreeJS();
            await loadOrbitControls();
            
            console.log('THREE.js and OrbitControls ready');
            window.dispatchEvent(new CustomEvent('threeJsReady'));
            
        } catch (error) {
            console.error('Failed to load THREE.js:', error);
            
            // Still dispatch event so the app can start with basic functionality
            window.dispatchEvent(new CustomEvent('threeJsReady'));
        }
    }
    
    // Start loading
    loadAll();
    
})();