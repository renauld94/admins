// Jellyfin ScrollBehavior Fix
// Inject this into Jellyfin web client to fix scroll errors

(function() {
    'use strict';
    
    console.log('🔧 Applying Jellyfin ScrollBehavior Fix...');
    
    // Override Element.prototype.scrollTo to handle null behavior
    const originalScrollTo = Element.prototype.scrollTo;
    Element.prototype.scrollTo = function(options) {
        if (typeof options === 'object' && options !== null) {
            // Fix null behavior value
            if (options.behavior === null) {
                options.behavior = 'smooth';
            }
            // Ensure behavior is valid
            if (!['smooth', 'auto', 'instant'].includes(options.behavior)) {
                options.behavior = 'smooth';
            }
        }
        return originalScrollTo.call(this, options);
    };
    
    // Also fix window.scrollTo
    const originalWindowScrollTo = window.scrollTo;
    window.scrollTo = function(options) {
        if (typeof options === 'object' && options !== null) {
            if (options.behavior === null) {
                options.behavior = 'smooth';
            }
            if (!['smooth', 'auto', 'instant'].includes(options.behavior)) {
                options.behavior = 'smooth';
            }
        }
        return originalWindowScrollTo.call(this, options);
    };
    
    console.log('✅ ScrollBehavior fix applied successfully');
})();
