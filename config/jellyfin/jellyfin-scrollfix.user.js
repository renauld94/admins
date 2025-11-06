// ==UserScript==
// @name         Jellyfin ScrollBehavior Fix
// @namespace    http://simondatalab.de/
// @version      1.0.0
// @description  Fix scrollBehavior null error in Jellyfin 10.10.x
// @author       Simon Renauld
// @match        http://136.243.155.166:8096/*
// @match        https://jellyfin.simondatalab.de/*
// @icon         data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>🎬</text></svg>
// @grant        none
// @run-at       document-start
// ==/UserScript==

(function() {
    'use strict';
    
    console.log('🔧 Jellyfin ScrollBehavior Fix - Initializing...');
    
    // Wait for DOM to be ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', applyFix);
    } else {
        applyFix();
    }
    
    function applyFix() {
        try {
            // Override Element.prototype.scrollTo
            const originalScrollTo = Element.prototype.scrollTo;
            Element.prototype.scrollTo = function(options) {
                // Handle both object and positional arguments
                if (typeof options === 'object' && options !== null) {
                    // Fix null behavior value
                    if (options.behavior === null || options.behavior === undefined) {
                        options.behavior = 'smooth';
                    }
                    // Ensure behavior is valid enum
                    if (!['smooth', 'auto', 'instant'].includes(options.behavior)) {
                        console.warn('Invalid scroll behavior:', options.behavior, '- defaulting to smooth');
                        options.behavior = 'smooth';
                    }
                }
                return originalScrollTo.call(this, options);
            };
            
            // Override window.scrollTo
            const originalWindowScrollTo = window.scrollTo;
            window.scrollTo = function(optionsOrX, y) {
                // Handle object notation
                if (typeof optionsOrX === 'object' && optionsOrX !== null) {
                    if (optionsOrX.behavior === null || optionsOrX.behavior === undefined) {
                        optionsOrX.behavior = 'smooth';
                    }
                    if (!['smooth', 'auto', 'instant'].includes(optionsOrX.behavior)) {
                        optionsOrX.behavior = 'smooth';
                    }
                }
                return originalWindowScrollTo.call(this, optionsOrX, y);
            };
            
            // Override window.scroll (alias for scrollTo)
            const originalWindowScroll = window.scroll;
            window.scroll = function(optionsOrX, y) {
                if (typeof optionsOrX === 'object' && optionsOrX !== null) {
                    if (optionsOrX.behavior === null || optionsOrX.behavior === undefined) {
                        optionsOrX.behavior = 'smooth';
                    }
                    if (!['smooth', 'auto', 'instant'].includes(optionsOrX.behavior)) {
                        optionsOrX.behavior = 'smooth';
                    }
                }
                return originalWindowScroll.call(this, optionsOrX, y);
            };
            
            // Override scrollIntoView on all elements
            const originalScrollIntoView = Element.prototype.scrollIntoView;
            Element.prototype.scrollIntoView = function(options) {
                if (typeof options === 'object' && options !== null) {
                    if (options.behavior === null || options.behavior === undefined) {
                        options.behavior = 'smooth';
                    }
                    if (!['smooth', 'auto', 'instant'].includes(options.behavior)) {
                        options.behavior = 'smooth';
                    }
                }
                return originalScrollIntoView.call(this, options);
            };
            
            console.log('✅ Jellyfin ScrollBehavior Fix - Applied successfully!');
            console.log('📺 Live TV guide should now work without errors');
            
        } catch (error) {
            console.error('❌ Failed to apply ScrollBehavior fix:', error);
        }
    }
})();
