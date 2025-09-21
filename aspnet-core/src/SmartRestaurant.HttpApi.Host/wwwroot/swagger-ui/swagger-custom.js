// Custom JavaScript để khắc phục lỗi ABP Swagger scripts
(function() {
    'use strict';
    
    // Override ABP's SwaggerUIBundle nếu nó undefined
    if (typeof window.abp === 'undefined') {
        window.abp = {};
    }
    
    if (typeof window.abp.SwaggerUIBundle === 'undefined') {
        window.abp.SwaggerUIBundle = function(config) {
            // Fallback to standard SwaggerUIBundle
            if (typeof SwaggerUIBundle !== 'undefined') {
                return SwaggerUIBundle(config);
            }
            console.error('SwaggerUIBundle is not available');
            return null;
        };
    }
    
    // Patch the initialization if needed
    document.addEventListener('DOMContentLoaded', function() {
        console.log('Custom Swagger script loaded');
    });
})();