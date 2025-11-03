/**
 * QA Test Suite for Admin Menu - Desktop & Mobile
 * Tests dropdown functionality, links, accessibility, and responsive behavior
 */

const QA_ADMIN_MENU = {
    // Test Configuration
    config: {
        baseUrl: 'https://www.simondatalab.de/',
        expectedServices: [
            { name: 'simondatalab.de', emoji: '🏠', url: 'https://simondatalab.de/' },
            { name: 'www.simondatalab.de', emoji: '🌐', url: 'https://www.simondatalab.de/' },
            { name: 'Moodle LMS', emoji: '📚', url: 'https://moodle.simondatalab.de/' },
            { name: 'Grafana', emoji: '📊', url: 'https://grafana.simondatalab.de/' },
            { name: 'Open WebUI', emoji: '🤖', url: 'https://openwebui.simondatalab.de/' },
            { name: 'Ollama', emoji: '🦙', url: 'https://ollama.simondatalab.de/' },
            { name: 'MLflow', emoji: '📈', url: 'https://mlflow.simondatalab.de/' },
            { name: 'MCP Server', emoji: '🔌', url: 'https://mcp.simondatalab.de/' },
            { name: 'GeoServer', emoji: '🌍', url: 'https://geoneuralviz.simondatalab.de/' },
            { name: 'Jellyfin', emoji: '🎬', url: 'https://jellyfin.simondatalab.de/' },
            { name: 'Booklore', emoji: '📖', url: 'https://booklore.simondatalab.de/' },
            { name: 'Prometheus', emoji: '📡', url: 'https://prometheus.simondatalab.de/' },
            { name: 'API', emoji: '🔗', url: 'https://api.simondatalab.de/' },
            { name: 'Analytics', emoji: '📉', url: 'https://analytics.simondatalab.de/' },
            { name: 'Jellyfin (Direct)', emoji: '🎬', url: 'http://136.243.155.166:8096/' },
            { name: 'Open WebUI (Direct)', emoji: '🤖', url: 'http://10.0.0.110:3001/' },
            { name: 'Grafana (Direct)', emoji: '📊', url: 'http://10.0.0.104:3000/' }
        ]
    },

    // Test Results
    results: {
        desktop: [],
        mobile: [],
        accessibility: [],
        links: []
    },

    // Desktop Dropdown Tests
    testDesktopDropdown() {
        console.log('🖥️  Testing Desktop Admin Dropdown...');
        
        const dropdownToggle = document.querySelector('.dropdown-toggle');
        const desktopMenu = document.getElementById('desktop-admin-menu');
        
        if (!dropdownToggle) {
            this.results.desktop.push({ test: 'Dropdown Toggle Exists', status: '❌ FAIL', message: 'Toggle button not found' });
            return;
        }
        this.results.desktop.push({ test: 'Dropdown Toggle Exists', status: '✅ PASS' });

        // Test click to open
        dropdownToggle.click();
        setTimeout(() => {
            const isExpanded = dropdownToggle.getAttribute('aria-expanded') === 'true';
            this.results.desktop.push({ 
                test: 'Dropdown Opens on Click', 
                status: isExpanded ? '✅ PASS' : '❌ FAIL',
                message: `aria-expanded: ${dropdownToggle.getAttribute('aria-expanded')}`
            });

            const isVisible = desktopMenu.getAttribute('aria-hidden') === 'false';
            this.results.desktop.push({ 
                test: 'Menu Visibility Toggle', 
                status: isVisible ? '✅ PASS' : '❌ FAIL',
                message: `aria-hidden: ${desktopMenu.getAttribute('aria-hidden')}`
            });

            // Test click to close
            dropdownToggle.click();
        }, 100);
    },

    // Mobile Dropdown Tests
    testMobileDropdown() {
        console.log('📱 Testing Mobile Admin Dropdown...');
        
        const mobileToggle = document.querySelector('.mobile-dropdown-toggle');
        const mobileMenu = document.querySelector('.mobile-dropdown-menu');
        
        if (!mobileToggle) {
            this.results.mobile.push({ test: 'Mobile Toggle Exists', status: '❌ FAIL', message: 'Mobile toggle not found' });
            return;
        }
        this.results.mobile.push({ test: 'Mobile Toggle Exists', status: '✅ PASS' });

        if (!mobileMenu) {
            this.results.mobile.push({ test: 'Mobile Menu Exists', status: '❌ FAIL', message: 'Mobile menu not found' });
            return;
        }
        this.results.mobile.push({ test: 'Mobile Menu Exists', status: '✅ PASS' });
    },

    // Link Tests
    testAllLinks() {
        console.log('🔗 Testing All Service Links...');
        
        const desktopLinks = document.querySelectorAll('#desktop-admin-menu a.dropdown-item');
        const mobileLinks = document.querySelectorAll('.mobile-dropdown-menu a.nav-link');

        this.results.links.push({ 
            test: 'Desktop Links Count', 
            status: desktopLinks.length === this.config.expectedServices.length ? '✅ PASS' : '⚠️  WARNING',
            message: `Found ${desktopLinks.length}/${this.config.expectedServices.length} links`
        });

        this.results.links.push({ 
            test: 'Mobile Links Count', 
            status: mobileLinks.length === this.config.expectedServices.length ? '✅ PASS' : '⚠️  WARNING',
            message: `Found ${mobileLinks.length}/${this.config.expectedServices.length} links`
        });

        // Verify each expected service exists
        this.config.expectedServices.forEach(service => {
            const desktopLink = Array.from(desktopLinks).find(link => 
                link.href === service.url || link.textContent.includes(service.name)
            );
            const mobileLink = Array.from(mobileLinks).find(link => 
                link.href === service.url || link.textContent.includes(service.name)
            );

            this.results.links.push({
                test: `${service.emoji} ${service.name}`,
                status: (desktopLink && mobileLink) ? '✅ PASS' : '❌ FAIL',
                desktop: desktopLink ? '✅' : '❌',
                mobile: mobileLink ? '✅' : '❌',
                url: service.url
            });
        });

        // Check for target="_blank" on external links
        const externalLinks = Array.from(desktopLinks).filter(link => 
            link.hostname !== window.location.hostname
        );
        const hasTargetBlank = externalLinks.every(link => link.target === '_blank');
        const hasNoopener = externalLinks.every(link => link.rel.includes('noopener'));

        this.results.links.push({
            test: 'External Links Security',
            status: (hasTargetBlank && hasNoopener) ? '✅ PASS' : '⚠️  WARNING',
            message: `target="_blank": ${hasTargetBlank}, rel="noopener": ${hasNoopener}`
        });
    },

    // Accessibility Tests
    testAccessibility() {
        console.log('♿ Testing Accessibility...');
        
        const dropdownToggle = document.querySelector('.dropdown-toggle');
        const desktopMenu = document.getElementById('desktop-admin-menu');

        // ARIA attributes
        const hasAriaExpanded = dropdownToggle.hasAttribute('aria-expanded');
        const hasAriaHaspopup = dropdownToggle.hasAttribute('aria-haspopup');
        const hasAriaLabel = desktopMenu.hasAttribute('aria-label');
        const hasAriaHidden = desktopMenu.hasAttribute('aria-hidden');

        this.results.accessibility.push({
            test: 'ARIA Expanded',
            status: hasAriaExpanded ? '✅ PASS' : '❌ FAIL'
        });
        this.results.accessibility.push({
            test: 'ARIA Haspopup',
            status: hasAriaHaspopup ? '✅ PASS' : '❌ FAIL'
        });
        this.results.accessibility.push({
            test: 'ARIA Label',
            status: hasAriaLabel ? '✅ PASS' : '❌ FAIL'
        });
        this.results.accessibility.push({
            test: 'ARIA Hidden',
            status: hasAriaHidden ? '✅ PASS' : '❌ FAIL'
        });

        // Keyboard navigation
        const isKeyboardAccessible = dropdownToggle.tagName === 'BUTTON';
        this.results.accessibility.push({
            test: 'Keyboard Accessible',
            status: isKeyboardAccessible ? '✅ PASS' : '❌ FAIL',
            message: `Element is: ${dropdownToggle.tagName}`
        });
    },

    // Run All Tests
    runAllTests() {
        console.log('\n🧪 Starting Admin Menu QA Tests...\n');
        
        this.testDesktopDropdown();
        this.testMobileDropdown();
        this.testAllLinks();
        this.testAccessibility();

        // Wait for async tests
        setTimeout(() => {
            this.displayResults();
        }, 500);
    },

    // Display Results
    displayResults() {
        console.log('\n📊 QA TEST RESULTS\n');
        console.log('═'.repeat(80));
        
        // Desktop Tests
        console.log('\n🖥️  DESKTOP DROPDOWN TESTS');
        console.log('─'.repeat(80));
        this.results.desktop.forEach(result => {
            console.log(`${result.status} ${result.test}${result.message ? ` - ${result.message}` : ''}`);
        });

        // Mobile Tests
        console.log('\n📱 MOBILE DROPDOWN TESTS');
        console.log('─'.repeat(80));
        this.results.mobile.forEach(result => {
            console.log(`${result.status} ${result.test}${result.message ? ` - ${result.message}` : ''}`);
        });

        // Link Tests
        console.log('\n🔗 LINK TESTS');
        console.log('─'.repeat(80));
        this.results.links.forEach(result => {
            if (result.desktop && result.mobile) {
                console.log(`${result.status} ${result.test} [Desktop: ${result.desktop}, Mobile: ${result.mobile}]`);
            } else {
                console.log(`${result.status} ${result.test}${result.message ? ` - ${result.message}` : ''}`);
            }
        });

        // Accessibility Tests
        console.log('\n♿ ACCESSIBILITY TESTS');
        console.log('─'.repeat(80));
        this.results.accessibility.forEach(result => {
            console.log(`${result.status} ${result.test}${result.message ? ` - ${result.message}` : ''}`);
        });

        // Summary
        const totalTests = 
            this.results.desktop.length + 
            this.results.mobile.length + 
            this.results.links.length + 
            this.results.accessibility.length;
        
        const passedTests = [
            ...this.results.desktop,
            ...this.results.mobile,
            ...this.results.links,
            ...this.results.accessibility
        ].filter(r => r.status.includes('✅')).length;

        console.log('\n' + '═'.repeat(80));
        console.log(`\n📈 SUMMARY: ${passedTests}/${totalTests} tests passed (${Math.round(passedTests/totalTests*100)}%)\n`);
    }
};

// Auto-run if loaded on the page
if (typeof window !== 'undefined') {
    // Wait for DOM to be ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', () => QA_ADMIN_MENU.runAllTests());
    } else {
        console.log('Run QA_ADMIN_MENU.runAllTests() in console to test the admin menu');
    }
}

// Export for use
if (typeof module !== 'undefined' && module.exports) {
    module.exports = QA_ADMIN_MENU;
}
