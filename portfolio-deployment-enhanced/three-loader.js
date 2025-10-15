/**
 * THREE.js Loader with OrbitControls
 * Ensures proper loading of THREE.js and OrbitControls for the neural visualization
 */

(function() {
    'use strict';
    
    console.log('🔄 Loading THREE.js with OrbitControls...');
    
    // Check if already loaded
    if (window.THREE && window.THREE.OrbitControls) {
        console.log('✅ THREE.js and OrbitControls already available');
        window.dispatchEvent(new CustomEvent('threeJsReady'));
        return;
    }
    
    // Load THREE.js first
    function loadThreeJS() {
        return new Promise((resolve, reject) => {
            const script = document.createElement('script');
            script.src = 'https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js';
            script.onload = () => {
                console.log('✅ THREE.js loaded successfully');
                resolve();
            };
            script.onerror = () => {
                reject(new Error('Failed to load THREE.js'));
            };
            document.head.appendChild(script);
        });
    }
    
    // Load OrbitControls
    function loadOrbitControls() {
        return new Promise((resolve, reject) => {
            const script = document.createElement('script');
            script.src = 'https://threejs.org/examples/js/controls/OrbitControls.js';
            script.onload = () => {
                console.log('✅ OrbitControls loaded successfully');
                resolve();
            };
            script.onerror = () => {
                console.warn('Failed to load OrbitControls from threejs.org, trying alternative...');
                
                // Alternative OrbitControls source
                const altScript = document.createElement('script');
                altScript.src = 'https://cdn.jsdelivr.net/npm/three@0.128.0/examples/js/controls/OrbitControls.js';
                altScript.onload = () => {
                    console.log('✅ OrbitControls loaded from alternative source');
                    resolve();
                };
                altScript.onerror = () => {
                    console.warn('OrbitControls unavailable, will use basic controls');
                    resolve(); // Don't reject, just continue without OrbitControls
                };
                document.head.appendChild(altScript);
            };
            document.head.appendChild(script);
        });
    }
    
    // Load both sequentially
    async function loadAll() {
        try {
            await loadThreeJS();
            await loadOrbitControls();
            
            console.log('🎉 THREE.js and OrbitControls ready!');
            window.dispatchEvent(new CustomEvent('threeJsReady'));
            
        } catch (error) {
            console.error('❌ Failed to load THREE.js:', error);
            
            // Still dispatch event so the app can start with basic functionality
            window.dispatchEvent(new CustomEvent('threeJsReady'));
        }
    }
    
    // Start loading
    loadAll();
    
})();