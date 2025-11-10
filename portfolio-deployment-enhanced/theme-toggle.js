/**
 * DARK MODE TOGGLE - Theme switching with localStorage persistence
 * Supports: Auto (system preference), Dark, Light modes
 * Version: 20251109.1
 */

(function() {
    'use strict';
    
    class ThemeToggle {
        constructor() {
            this.STORAGE_KEY = 'theme-preference';
            this.LIGHT_MODE = 'light';
            this.DARK_MODE = 'dark';
            this.AUTO_MODE = 'auto';
            
            // Get saved preference or default to auto
            this.currentTheme = this.getSavedTheme() || this.AUTO_MODE;
            
            console.log('🌙 [ThemeToggle] Initializing with theme:', this.currentTheme);
            
            // Apply theme on load
            this.applyTheme(this.currentTheme);
            
            // Listen for system theme changes
            this.watchSystemPreference();
            
            // Setup toggle button
            this.setupToggleButton();
            
            console.log('✅ [ThemeToggle] Initialized');
        }
        
        /**
         * Get saved theme preference from localStorage
         */
        getSavedTheme() {
            try {
                return localStorage.getItem(this.STORAGE_KEY);
            } catch (err) {
                console.warn('[ThemeToggle] localStorage not available:', err);
                return null;
            }
        }
        
        /**
         * Save theme preference to localStorage
         */
        saveTheme(theme) {
            try {
                localStorage.setItem(this.STORAGE_KEY, theme);
            } catch (err) {
                console.warn('[ThemeToggle] Failed to save theme:', err);
            }
        }
        
        /**
         * Get system theme preference
         */
        getSystemTheme() {
            if (window.matchMedia && window.matchMedia('(prefers-color-scheme: light)').matches) {
                return this.LIGHT_MODE;
            }
            return this.DARK_MODE;
        }
        
        /**
         * Determine effective theme (considering auto mode)
         */
        getEffectiveTheme(theme) {
            if (theme === this.AUTO_MODE) {
                return this.getSystemTheme();
            }
            return theme;
        }
        
        /**
         * Apply theme to document
         */
        applyTheme(theme) {
            const effectiveTheme = this.getEffectiveTheme(theme);
            const isLight = effectiveTheme === this.LIGHT_MODE;
            
            console.log(`🌙 [ThemeToggle] Applying theme: ${theme} (effective: ${effectiveTheme})`);
            
            // Update document class
            document.documentElement.classList.toggle('light-mode', isLight);
            document.documentElement.classList.toggle('dark-mode', !isLight);
            document.body.classList.toggle('light-mode', isLight);
            document.body.classList.toggle('dark-mode', !isLight);
            
            // Update meta theme-color for mobile browsers
            this.updateMetaThemeColor(isLight);
            
            // Dispatch custom event for other components
            window.dispatchEvent(new CustomEvent('themechange', {
                detail: { theme, effectiveTheme, isLight }
            }));
        }
        
        /**
         * Update meta theme-color tag
         */
        updateMetaThemeColor(isLight) {
            let metaTag = document.querySelector('meta[name="theme-color"]');
            
            if (!metaTag) {
                metaTag = document.createElement('meta');
                metaTag.name = 'theme-color';
                document.head.appendChild(metaTag);
            }
            
            metaTag.content = isLight ? '#f8fafc' : '#0a0f1e';
        }
        
        /**
         * Watch for system theme preference changes
         */
        watchSystemPreference() {
            if (!window.matchMedia) return;
            
            try {
                window.matchMedia('(prefers-color-scheme: light)').addEventListener('change', (e) => {
                    console.log('[ThemeToggle] System theme preference changed');
                    if (this.currentTheme === this.AUTO_MODE) {
                        this.applyTheme(this.AUTO_MODE);
                        this.updateToggleButton();
                    }
                });
            } catch (err) {
                console.warn('[ThemeToggle] Failed to watch system preference:', err);
            }
        }
        
        /**
         * Setup toggle button in header
         */
        setupToggleButton() {
            // Check if button already exists
            let button = document.getElementById('theme-toggle-btn');
            
            if (!button) {
                console.log('[ThemeToggle] Creating toggle button...');
                
                // Find header or nav to insert button
                const header = document.querySelector('header');
                const nav = document.querySelector('nav');
                const targetElement = header || nav || document.body;
                
                button = document.createElement('button');
                button.id = 'theme-toggle-btn';
                button.className = 'theme-toggle-btn';
                button.setAttribute('aria-label', 'Toggle theme');
                button.innerHTML = this.getToggleButtonHTML();
                
                // Insert at the end of nav or beginning of header
                if (nav) {
                    nav.appendChild(button);
                } else if (header) {
                    header.appendChild(button);
                }
            }
            
            // Add click handler
            button.addEventListener('click', () => this.toggleTheme());
            this.updateToggleButton();
        }
        
        /**
         * Get toggle button HTML (Sun/Moon icon)
         */
        getToggleButtonHTML() {
            return `
                <svg class="theme-icon sun-icon" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <circle cx="12" cy="12" r="5"></circle>
                    <line x1="12" y1="1" x2="12" y2="3"></line>
                    <line x1="12" y1="21" x2="12" y2="23"></line>
                    <line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line>
                    <line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line>
                    <line x1="1" y1="12" x2="3" y2="12"></line>
                    <line x1="21" y1="12" x2="23" y2="12"></line>
                    <line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line>
                    <line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line>
                </svg>
                <svg class="theme-icon moon-icon" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path>
                </svg>
            `;
        }
        
        /**
         * Update toggle button appearance based on current theme
         */
        updateToggleButton() {
            const button = document.getElementById('theme-toggle-btn');
            if (!button) return;
            
            const effectiveTheme = this.getEffectiveTheme(this.currentTheme);
            const isLight = effectiveTheme === this.LIGHT_MODE;
            
            // Show/hide icons based on theme
            const sunIcon = button.querySelector('.sun-icon');
            const moonIcon = button.querySelector('.moon-icon');
            
            if (sunIcon) sunIcon.style.display = isLight ? 'block' : 'none';
            if (moonIcon) moonIcon.style.display = isLight ? 'none' : 'block';
        }
        
        /**
         * Cycle through themes: Auto -> Light -> Dark -> Auto
         */
        toggleTheme() {
            const themes = [this.AUTO_MODE, this.LIGHT_MODE, this.DARK_MODE];
            const currentIndex = themes.indexOf(this.currentTheme);
            const nextIndex = (currentIndex + 1) % themes.length;
            const nextTheme = themes[nextIndex];
            
            console.log(`🌙 [ThemeToggle] Toggling theme: ${this.currentTheme} -> ${nextTheme}`);
            
            this.currentTheme = nextTheme;
            this.saveTheme(nextTheme);
            this.applyTheme(nextTheme);
            this.updateToggleButton();
            
            // Show toast notification
            this.showThemeNotification(nextTheme);
        }
        
        /**
         * Show theme change notification
         */
        showThemeNotification(theme) {
            const messages = {
                [this.AUTO_MODE]: 'Theme: Auto (System preference)',
                [this.LIGHT_MODE]: 'Theme: Light Mode',
                [this.DARK_MODE]: 'Theme: Dark Mode'
            };
            
            const message = messages[theme] || 'Theme changed';
            
            // Optional: Show toast notification
            if (window.showToast) {
                window.showToast(message, 'info');
            } else {
                console.log(`[ThemeToggle] ${message}`);
            }
        }
        
        /**
         * Set theme programmatically
         */
        setTheme(theme) {
            if (![this.AUTO_MODE, this.LIGHT_MODE, this.DARK_MODE].includes(theme)) {
                console.error(`[ThemeToggle] Invalid theme: ${theme}`);
                return;
            }
            
            this.currentTheme = theme;
            this.saveTheme(theme);
            this.applyTheme(theme);
            this.updateToggleButton();
        }
        
        /**
         * Get current theme
         */
        getTheme() {
            return this.currentTheme;
        }
        
        /**
         * Get effective theme (considering auto mode)
         */
        getEffectiveThemeNow() {
            return this.getEffectiveTheme(this.currentTheme);
        }
    }
    
    // Initialize theme toggle when DOM is ready
    function initThemeToggle() {
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', () => {
                window.themeToggle = new ThemeToggle();
            });
        } else {
            window.themeToggle = new ThemeToggle();
        }
    }
    
    // Initialize
    initThemeToggle();
    
    console.log('✅ [ThemeToggle] Script loaded');
    
})();
