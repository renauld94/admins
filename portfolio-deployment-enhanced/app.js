// SIMON RENAULD PORTFOLIO - PROFESSIONAL JAVASCRIPT 2025
// Mobile-first, performance-optimized portfolio functionality

// INITIALIZATION
document.addEventListener('DOMContentLoaded', function () {
    console.log('Simon Renauld Portfolio - Initialized');

    // Initialize core functionality
    applyNavigationColorFix();
    initializeNavigation();
    initializeScrollProgress();
    initializeAnimations();
    initializePortfolioVisualizations();
    initializeContactForm();
    initializeGeospatialLaunch();
});

// NAVIGATION SYSTEM
function initializeNavigation() {
    // Smooth scrolling for navigation links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                const navHeight = 70;
                const targetPosition = target.offsetTop - navHeight;

                window.scrollTo({
                    top: targetPosition,
                    behavior: 'smooth'
                });

                // Close mobile menu if open
                closeMobileMenu();
            }
        });
    });

    // Mobile menu toggle
    const mobileMenuBtn = document.querySelector('.mobile-menu-btn');
    const mobileNav = document.querySelector('.mobile-nav');
    const backdrop = document.querySelector('.mobile-nav-backdrop');

    if (mobileMenuBtn && mobileNav) {
        // Prevent double-fire across touch/click
        let lastToggleTs = 0;
        const guard = (fn) => (e) => {
            const now = performance.now();
            if (now - lastToggleTs < 250) {
                e.preventDefault();
                e.stopPropagation();
                return;
            }
            lastToggleTs = now;
            fn(e);
        };
        mobileMenuBtn.addEventListener('click', (e) => {
            guard((ev)=>{ ev.preventDefault(); ev.stopPropagation(); toggleMobileMenu(); })(e);
        });
        
        // Add touch event for better mobile support
        mobileMenuBtn.addEventListener('touchend', (e) => {
            if (e.cancelable) e.preventDefault();
            e.stopPropagation();
            guard(()=> toggleMobileMenu())(e);
        }, { passive: false });

        // Close mobile menu when clicking on a link
        document.querySelectorAll('.mobile-nav-menu .nav-link').forEach(link => {
            link.addEventListener('click', () => {
                closeMobileMenu();
            });
        });
        
        // Close mobile menu when clicking backdrop
        if (backdrop) {
            backdrop.addEventListener('click', () => {
                closeMobileMenu();
            });
        }
    }

    // Close mobile menu when clicking outside
    document.addEventListener('click', (e) => {
        const backdrop = document.querySelector('.mobile-nav-backdrop');
        if (!mobileMenuBtn?.contains(e.target) && 
            !mobileNav?.contains(e.target) && 
            !backdrop?.contains(e.target)) {
            // Only close if the menu is open
            if (mobileNav?.classList.contains('active')) {
                closeMobileMenu();
            }
        }
    });

    // Close mobile menu on escape key
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') {
            closeMobileMenu();
        }
    });

    // Desktop Admin Tools dropdown
    const dropdown = document.querySelector('.nav-dropdown');
    if (dropdown) {
        const toggle = dropdown.querySelector('.dropdown-toggle');
        const menu = dropdown.querySelector('.dropdown-menu');
        const firstMenuItem = () => menu?.querySelector('a, button, [tabindex]:not([tabindex="-1"])');
        const setOpenState = (isOpen) => {
            dropdown.classList.toggle('open', isOpen);
            toggle?.setAttribute('aria-expanded', String(isOpen));
            menu?.setAttribute('aria-hidden', String(!isOpen));
        };
        const closeAll = (focusToggle = false) => {
            setOpenState(false);
            if (focusToggle) {
                toggle?.focus();
            }
        };
        const open = () => {
            if (!dropdown.classList.contains('open')) {
                setOpenState(true);
                requestAnimationFrame(() => {
                    firstMenuItem()?.focus();
                });
            }
        };
        const handleToggle = (ev) => {
            ev.preventDefault();
            ev.stopPropagation();
            if (dropdown.classList.contains('open')) {
                closeAll();
            } else {
                open();
            }
        };

        toggle?.addEventListener('click', handleToggle);
        toggle?.addEventListener('keydown', (ev) => {
            if (ev.key === 'Enter' || ev.key === ' ') {
                handleToggle(ev);
            } else if (ev.key === 'ArrowDown') {
                ev.preventDefault();
                open();
            } else if (ev.key === 'Escape') {
                closeAll(true);
            }
        });

        menu?.addEventListener('keydown', (ev) => {
            if (ev.key === 'Escape') {
                closeAll(true);
            }
        });

        menu?.addEventListener('click', () => closeAll());

        document.addEventListener('click', (ev) => {
            if (!dropdown.contains(ev.target)) closeAll();
        });

        dropdown.addEventListener('focusout', (ev) => {
            if (!dropdown.contains(ev.relatedTarget)) {
                closeAll();
            }
        });

        document.addEventListener('keydown', (ev) => {
            if (ev.key === 'Escape') closeAll(true);
        });
    }

    // Mobile Admin Tools dropdown with enhanced touch support
    const mobileDropdown = document.querySelector('.mobile-dropdown');
    if (mobileDropdown) {
        const toggle = mobileDropdown.querySelector('.mobile-dropdown-toggle');
        const menu = mobileDropdown.querySelector('.mobile-dropdown-menu');
        let lastToggleTs = 0;
        const guard = (fn) => (e) => {
            const now = performance.now();
            if (now - lastToggleTs < 250) {
                e.preventDefault?.();
                e.stopPropagation?.();
                return;
            }
            lastToggleTs = now;
            fn(e);
        };
        
        const close = () => {
            mobileDropdown.classList.remove('open');
            toggle?.setAttribute('aria-expanded', 'false');
            menu?.setAttribute('aria-hidden', 'true');
        };
        
        const open = () => {
            mobileDropdown.classList.add('open');
            toggle?.setAttribute('aria-expanded', 'true');
            menu?.setAttribute('aria-hidden', 'false');
        };
        
        const toggleDropdown = (ev) => {
            ev.preventDefault();
            ev.stopPropagation();
            if (mobileDropdown.classList.contains('open')) {
                close();
            } else {
                open();
            }
        };
        
        // Add both click and touchend for better mobile support
        if (toggle) {
            toggle.addEventListener('click', guard(toggleDropdown));
            toggle.addEventListener('touchend', (ev) => {
                // Prevent double-firing on mobile
                if (ev.cancelable) {
                    ev.preventDefault();
                }
                guard(toggleDropdown)(ev);
            }, { passive: false });
        }
        
        // Close dropdown when clicking outside
        document.addEventListener('click', (ev) => {
            if (!mobileDropdown.contains(ev.target)) close();
        });
        
        document.addEventListener('touchend', (ev) => {
            if (!mobileDropdown.contains(ev.target)) close();
        });
        
        // Close on Escape key
        document.addEventListener('keydown', (ev) => {
            if (ev.key === 'Escape') close();
        });

        // Mark initialization complete to avoid duplicate bindings from inline scripts
        try { window.__PORTFOLIO_APP_JS_MOBILE_DROPDOWN__ = true; } catch (e) {}
    }
}

// Adaptive navigation contrast: ensures readable link color against current nav background.
function applyNavigationColorFix() {
    const styleId = 'nav-color-fix';
    if (document.getElementById(styleId)) return;

    const nav = document.querySelector('.main-navigation');
    // Helper to compute relative luminance
    function luminance(rgb) {
        const toLin = c => {
            c /= 255; return c <= 0.03928 ? c/12.92 : Math.pow((c+0.055)/1.055, 2.4);
        };
        const [r,g,b] = rgb; return 0.2126*toLin(r)+0.7152*toLin(g)+0.0722*toLin(b);
    }
    function parseColor(c) {
        if (!c) return [11,18,32];
        const m = c.match(/rgba?\((\d+),\s*(\d+),\s*(\d+)/i); if (m) return [parseInt(m[1],10),parseInt(m[2],10),parseInt(m[3],10)];
        return [11,18,32];
    }
    let desiredBase = '#ffffff';
    if (nav) {
        const bg = window.getComputedStyle(nav).backgroundColor;
        const lum = luminance(parseColor(bg));
        // If background is light (> ~0.6), switch to dark text; else keep white
        desiredBase = lum > 0.6 ? '#0f172a' : '#ffffff';
    }

    const style = document.createElement('style');
    style.id = styleId;
    style.textContent = `
      .main-navigation .nav-link { color: ${desiredBase} !important; text-decoration:none; position:relative; outline:none; }
      .main-navigation .nav-link:focus-visible { outline: 2px solid #0ea5e9; outline-offset:2px; border-radius:4px; }
      .main-navigation .nav-link:hover, .main-navigation .nav-link:focus { color: #0ea5e9 !important; }
      .main-navigation .dropdown-menu a, .main-navigation .dropdown-item { color: #0f172a !important; }
      .main-navigation .dropdown-menu a:hover, .main-navigation .dropdown-item:hover { background: #0ea5e9; color:#fff !important; }
      @media (prefers-color-scheme: light) { .main-navigation .nav-link { color: #0f172a !important; } }
    `;
    document.head.appendChild(style);
}

function toggleMobileMenu() {
    const mobileMenuBtn = document.querySelector('.mobile-menu-btn');
    const mobileNav = document.querySelector('.mobile-nav');
    const backdrop = document.querySelector('.mobile-nav-backdrop');

    if (mobileMenuBtn && mobileNav) {
        const isOpen = mobileNav.classList.contains('active');
        
        mobileMenuBtn.classList.toggle('active');
        mobileNav.classList.toggle('active');
        if (backdrop) {
            backdrop.classList.toggle('active');
        }
        
        const nowOpen = !isOpen;
        mobileMenuBtn.setAttribute('aria-expanded', String(nowOpen));
        mobileNav.setAttribute('aria-hidden', String(!nowOpen));
        if (backdrop) {
            backdrop.setAttribute('aria-hidden', String(!nowOpen));
        }

        // Prevent body scroll when menu is open
        if (nowOpen) {
            document.body.style.overflow = 'hidden';
            document.body.style.position = 'fixed';
            document.body.style.width = '100%';
        } else {
            document.body.style.overflow = '';
            document.body.style.position = '';
            document.body.style.width = '';
        }
    }
}

function closeMobileMenu() {
    const mobileMenuBtn = document.querySelector('.mobile-menu-btn');
    const mobileNav = document.querySelector('.mobile-nav');
    const backdrop = document.querySelector('.mobile-nav-backdrop');

    if (mobileMenuBtn && mobileNav) {
        mobileMenuBtn.classList.remove('active');
        mobileNav.classList.remove('active');
        if (backdrop) {
            backdrop.classList.remove('active');
        }
        
        mobileMenuBtn.setAttribute('aria-expanded', 'false');
        mobileNav.setAttribute('aria-hidden', 'true');
        if (backdrop) {
            backdrop.setAttribute('aria-hidden', 'true');
        }
        
        document.body.style.overflow = '';
        document.body.style.position = '';
        document.body.style.width = '';
    }
}

function initializeGeospatialLaunch() {
    const fab = document.querySelector('.globe-fab');
    if (!fab) return;

    const targetPath = fab.getAttribute('data-geo-target') || '/geospatial-viz/index.html';
    const features = 'noopener=yes,width=1400,height=900';

    const getBaseForRelativeUrls = () => {
        const origin = window.location.origin;
        if (origin && origin !== 'null') {
            return origin;
        }
        try {
            return new URL(document.baseURI).origin;
        } catch (err) {
            return window.location.href;
        }
    };

    const resolveTargetUrl = () => {
        const trimmed = targetPath.trim();
        if (/^https?:\/\//i.test(trimmed)) {
            return trimmed;
        }

        if (window.location.protocol === 'file:') {
            return 'http://127.0.0.1:5500/geospatial-viz/index.html'; // dev-only
        }

        try {
            const targetUrl = new URL(trimmed, getBaseForRelativeUrls());
            return targetUrl.toString();
        } catch (err) {
            console.warn('Falling back to raw geospatial target', err);
            return trimmed;
        }
    };

    const openGeospatialViz = (event) => {
        event?.preventDefault?.();
        const resolvedUrl = resolveTargetUrl();
        const popup = window.open(resolvedUrl, '_blank', features);

        if (popup) {
            try {
                popup.opener = null;
            } catch (err) {
                // ignore cross-origin assignment failures
            }
        } else {
            window.location.href = resolvedUrl;
        }
    };

    fab.addEventListener('click', openGeospatialViz);
    fab.addEventListener('keydown', (event) => {
        if (event.key === 'Enter' || event.key === ' ') {
            openGeospatialViz(event);
        }
    });
}

// SCROLL PROGRESS
function initializeScrollProgress() {
    const progressBar = document.querySelector('.scroll-progress');

    if (progressBar) {
        function updateScrollProgress() {
            const scrolled = (window.pageYOffset / (document.documentElement.scrollHeight - window.innerHeight)) * 100;
            progressBar.style.width = Math.min(scrolled, 100) + '%';
        }

        window.addEventListener('scroll', updateScrollProgress, { passive: true });
        updateScrollProgress(); // Initial call
    }
}

// ANIMATIONS
function initializeAnimations() {
    // Check if GSAP is available
    if (typeof gsap === 'undefined') {
        console.warn('GSAP not loaded - animations disabled');
        return;
    }

    // Register ScrollTrigger if available
    if (typeof ScrollTrigger !== 'undefined') {
        gsap.registerPlugin(ScrollTrigger);
    }

    // Animate elements on scroll if ScrollTrigger is available
    if (typeof ScrollTrigger !== 'undefined') {
        // Fade in sections
        gsap.utils.toArray('.section-header').forEach(header => {
            gsap.fromTo(header,
                {
                    y: 50,
                    opacity: 0
                },
                {
                    y: 0,
                    opacity: 1,
                    duration: 0.8,
                    ease: 'power2.out',
                    scrollTrigger: {
                        trigger: header,
                        start: 'top 80%',
                        end: 'bottom 20%',
                        toggleActions: 'play none none reverse'
                    }
                }
            );
        });

        // Animate cards
        gsap.utils.toArray('.project-card, .expertise-card, .value-item').forEach((card, index) => {
            gsap.fromTo(card,
                {
                    y: 30,
                    opacity: 0
                },
                {
                    y: 0,
                    opacity: 1,
                    duration: 0.6,
                    delay: index * 0.1,
                    ease: 'power2.out',
                    scrollTrigger: {
                        trigger: card,
                        start: 'top 85%',
                        toggleActions: 'play none none reverse'
                    }
                }
            );
        });

        // Timeline items
        gsap.utils.toArray('.timeline-item').forEach((item, index) => {
            gsap.fromTo(item,
                {
                    x: -30,
                    opacity: 0
                },
                {
                    x: 0,
                    opacity: 1,
                    duration: 0.8,
                    delay: index * 0.2,
                    ease: 'power2.out',
                    scrollTrigger: {
                        trigger: item,
                        start: 'top 80%',
                        toggleActions: 'play none none reverse'
                    }
                }
            );
        });
    }

    // Button hover animations
    document.querySelectorAll('.btn-primary, .btn-secondary').forEach(btn => {
        btn.addEventListener('mouseenter', () => {
            if (typeof gsap !== 'undefined') {
                gsap.to(btn, {
                    duration: 0.2,
                    scale: 1.05,
                    ease: 'power2.out'
                });
            }
        });

        btn.addEventListener('mouseleave', () => {
            if (typeof gsap !== 'undefined') {
                gsap.to(btn, {
                    duration: 0.2,
                    scale: 1,
                    ease: 'power2.out'
                });
            }
        });
    });

    // Number counters for hero stats
    initializeStatCounters();
}

// Animate hero stat numbers (e.g., 10+, 25+, 500M+)
function initializeStatCounters() {
    const stats = document.querySelectorAll('.hero-stats .stat-item .stat-number');
    if (!stats.length) return;

    const parseTarget = (text) => {
        // Extract number and suffix (e.g., 'M', '+')
        const match = text.trim().match(/^(\d+)([a-zA-Z]?)(\+)?$/);
        if (!match) return { value: 0, suffix: '' };
        const value = parseInt(match[1], 10);
        const unit = match[2] || '';
        const plus = match[3] ? '+' : '';
        return { value, suffix: unit + plus };
    };

    const animateValue = (el, to, suffix, duration = 1500) => {
        const start = 0;
        const startTime = performance.now();
        const step = (now) => {
            const progress = Math.min((now - startTime) / duration, 1);
            const eased = 1 - Math.pow(1 - progress, 3); // easeOutCubic
            const current = Math.floor(start + (to - start) * eased);
            el.textContent = current + suffix;
            if (progress < 1) requestAnimationFrame(step);
        };
        requestAnimationFrame(step);
    };

    const observer = new IntersectionObserver((entries, obs) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                stats.forEach(el => {
                    const { value, suffix } = parseTarget(el.dataset.target || el.textContent);
                    // Normalize 500M+ to 500 with 'M+'
                    el.dataset.target = value + suffix;
                    animateValue(el, value, suffix);
                });
                obs.disconnect();
            }
        });
    }, { threshold: 0.4 });

    const container = document.querySelector('.hero-stats');
    if (container) observer.observe(container);
}

// PORTFOLIO VISUALIZATIONS
function initializePortfolioVisualizations() {
    // AI-Enhanced R3F Hero is now the primary visualization
    // Vanilla Three.js fallback disabled to prevent duplicate instances
    // The R3F hero loads via r3f-hero.ai-epic.v20251004.js
    const heroPerf = window.heroPerformance;
    if (heroPerf && heroPerf.shouldLoadR3F === false) {
        console.log('[Portfolio] R3F hero skipped for current device tier', {
            tier: heroPerf.deviceTier,
            reason: heroPerf.fallbackReason || 'performance-tier'
        });
        return;
    }

    console.log('[Portfolio] R3F AI-Enhanced Hero active - vanilla fallback disabled');
    // initializeHeroVisualization(); // DISABLED - R3F handles this now
}

// HERO VISUALIZATION
async function initializeHeroVisualization() {
    const container = document.getElementById('hero-visualization');
    // If an R3F hero is enabled, wait briefly for it to mount; if it doesn't, fall back to vanilla.
    if (!container) return;
    if (container.hasAttribute('data-r3f')) {
        // If already mounted by R3F, skip vanilla
        const hasR3FCanvas = !!container.querySelector('.r3f-host canvas');
        if (hasR3FCanvas || container.getAttribute('data-r3f-mounted') === '1') return;

        // Observe for R3F mount
        let mounted = false;
        const observer = new MutationObserver(() => {
            if (container.querySelector('.r3f-host canvas')) {
                mounted = true;
                container.setAttribute('data-r3f-mounted', '1');
                observer.disconnect();
            }
        });
        observer.observe(container, { childList: true, subtree: true });

        // Fallback timer: if no R3F after 3s, proceed with vanilla init
        setTimeout(() => {
            if (!mounted && !container.querySelector('.r3f-host canvas')) {
                console.warn('R3F hero did not mount in time. Falling back to vanilla Three.js hero.');
                // Remove the data-r3f to allow vanilla init to proceed
                container.removeAttribute('data-r3f');
                initializeHeroVisualization();
            }
        }, 3000);
        return;
    }
    let THREEInstance = globalThis.THREE;
    if (!THREEInstance) {
        try {
            const threeModule = await import('three');
            THREEInstance = threeModule?.default ?? threeModule;
            globalThis.THREE = THREEInstance;
        } catch (error) {
            console.error('Three.js failed to load for vanilla hero fallback', error);
            return;
        }
    }

    const THREE = THREEInstance;

    const reduceMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    try {
        const scene = new THREE.Scene();
        // Depth fog for parallax depth (subtle)
        scene.fog = new THREE.FogExp2(0x0b1220, 0.08);
        const camera = new THREE.PerspectiveCamera(60, container.clientWidth / container.clientHeight, 0.1, 100);
        const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
        renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
        renderer.setSize(container.clientWidth, container.clientHeight);
        renderer.setClearColor(0x000000, 0);
        container.appendChild(renderer.domElement);

        // Optional postprocessing (Bloom + FXAA + Vignette)
        let composer = null;
        let fxaaPass = null;
        try {
            const [
                { EffectComposer },
                { RenderPass },
                { UnrealBloomPass },
                { ShaderPass },
                { FXAAShader }
            ] = await Promise.all([
                import('three/addons/postprocessing/EffectComposer.js'),
                import('three/addons/postprocessing/RenderPass.js'),
                import('three/addons/postprocessing/UnrealBloomPass.js'),
                import('three/addons/postprocessing/ShaderPass.js'),
                import('three/addons/shaders/FXAAShader.js')
            ]);

            composer = new EffectComposer(renderer);
            const renderPass = new RenderPass(scene, camera);
            composer.addPass(renderPass);

            const bloomPass = new UnrealBloomPass(
                new THREE.Vector2(container.clientWidth, container.clientHeight),
                0.7,   // strength
                0.6,   // radius
                0.18   // threshold
            );
            composer.addPass(bloomPass);

            fxaaPass = new ShaderPass(FXAAShader);
            fxaaPass.material.uniforms['resolution'].value.set(
                1 / (container.clientWidth * renderer.getPixelRatio()),
                1 / (container.clientHeight * renderer.getPixelRatio())
            );
            composer.addPass(fxaaPass);

            // Lightweight vignette shader
            const VignetteShader = {
                uniforms: {
                    tDiffuse: { value: null },
                    darkness: { value: 0.35 }, // 0..1 amount
                    offset: { value: 0.95 }     // inner radius where vignette starts (0..1)
                },
                vertexShader: `
                    varying vec2 vUv;
                    void main() {
                        vUv = uv;
                        gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
                    }
                `,
                fragmentShader: `
                    uniform sampler2D tDiffuse;
                    uniform float darkness;
                    uniform float offset;
                    varying vec2 vUv;
                    void main() {
                        vec4 color = texture2D(tDiffuse, vUv);
                        float dist = distance(vUv, vec2(0.5));
                        float vignette = smoothstep(0.5, offset, dist);
                        color.rgb *= (1.0 - darkness * vignette);
                        gl_FragColor = color;
                    }
                `
            };
            const vignettePass = new ShaderPass(VignetteShader);
            composer.addPass(vignettePass);
        } catch (e) {
            // Postprocessing is optional; continue without if modules fail to load
            console.warn('Postprocessing not available, proceeding without bloom/FXAA', e);
        }

        // Tone mapping + exposure for nicer contrast
        renderer.toneMapping = THREE.ACESFilmicToneMapping;
        renderer.toneMappingExposure = 1.0;

        // Lighting for subtle depth
        const ambient = new THREE.AmbientLight(0xffffff, 0.6);
        scene.add(ambient);
        const dir = new THREE.DirectionalLight(0x88ccff, 0.6);
        dir.position.set(2, 2, 2);
        scene.add(dir);

        // Group to hold the brain structure
        const brainGroup = new THREE.Group();
        scene.add(brainGroup);

        // Parameters for two hemispheres (ellipsoids)
        const hemiParams = {
            a: 1.2, // x radius
            b: 0.95, // y radius
            c: 1.0, // z radius
            offset: 0.7 // x offset between hemispheres
        };

        // Generate nodes on ellipsoid surface with subtle "sulci" modulation
        function sampleHemisphere(side = 'left', count = 300) {
            const positions = [];
            for (let i = 0; i < count; i++) {
                const u = Math.random();
                const v = Math.random();
                const theta = 2 * Math.PI * u; // around y
                const phi = Math.acos(2 * v - 1); // polar

                // Ellipsoid base
                const sx = hemiParams.a * Math.sin(phi) * Math.cos(theta);
                const sy = hemiParams.b * Math.cos(phi);
                const sz = hemiParams.c * Math.sin(phi) * Math.sin(theta);

                // Sulci/gyri modulation (subtle ridges)
                const ridges = 1 + 0.06 * Math.sin(8 * theta + 3 * phi);
                let x = sx * ridges + (side === 'left' ? -hemiParams.offset : hemiParams.offset);
                let y = sy * ridges;
                let z = sz * ridges;

                // Slight inward bias to create volume
                const inward = 0.85 + Math.random() * 0.15;
                positions.push(x * inward, y * inward, z * inward);
            }
            return new Float32Array(positions);
        }

        // Create points materials (glow-like)
        const pointsMaterial = new THREE.PointsMaterial({
            color: 0x8b5cf6,
            size: 0.025,
            transparent: true,
            opacity: 0.85,
            blending: THREE.AdditiveBlending,
            depthWrite: false,
            sizeAttenuation: true
        });

        const leftGeo = new THREE.BufferGeometry();
        leftGeo.setAttribute('position', new THREE.BufferAttribute(sampleHemisphere('left', 320), 3));
        const leftPoints = new THREE.Points(leftGeo, pointsMaterial.clone());
        leftPoints.material.color = new THREE.Color('#38bdf8');
        brainGroup.add(leftPoints);

        const rightGeo = new THREE.BufferGeometry();
        rightGeo.setAttribute('position', new THREE.BufferAttribute(sampleHemisphere('right', 320), 3));
        const rightPoints = new THREE.Points(rightGeo, pointsMaterial.clone());
        rightPoints.material.color = new THREE.Color('#8b5cf6');
        brainGroup.add(rightPoints);

        // Build intra-hemisphere connections (short lines between nearby points)
        function buildConnections(pointsObj, maxDist = 0.22, probability = 0.1, color = 0x0ea5e9) {
            const pos = pointsObj.geometry.attributes.position.array;
            const lines = new THREE.Group();
            const mat = new THREE.LineBasicMaterial({ color, transparent: true, opacity: 0.35, blending: THREE.AdditiveBlending });
            for (let i = 0; i < pos.length; i += 3) {
                if (Math.random() > probability) continue;
                const ax = pos[i], ay = pos[i + 1], az = pos[i + 2];
                // pick a random neighbor j
                const j = (Math.floor(Math.random() * (pos.length / 3)) | 0) * 3;
                const bx = pos[j], by = pos[j + 1], bz = pos[j + 2];
                const dx = ax - bx, dy = ay - by, dz = az - bz;
                const dist = Math.hypot(dx, dy, dz);
                if (dist < maxDist && dist > 0.02) {
                    const g = new THREE.BufferGeometry();
                    g.setFromPoints([new THREE.Vector3(ax, ay, az), new THREE.Vector3(bx, by, bz)]);
                    const ln = new THREE.Line(g, mat);
                    lines.add(ln);
                }
            }
            return lines;
        }

        const leftConn = buildConnections(leftPoints, 0.2, 0.12, 0x38bdf8);
        const rightConn = buildConnections(rightPoints, 0.2, 0.12, 0xa78bfa);
        brainGroup.add(leftConn);
        brainGroup.add(rightConn);

        // Corpus callosum: graceful curves bridging hemispheres
        function addCorpusCallosum(bridges = 24) {
            const group = new THREE.Group();
            const mat = new THREE.LineBasicMaterial({ color: 0x67e8f9, transparent: true, opacity: 0.25, blending: THREE.AdditiveBlending });
            for (let k = 0; k < bridges; k++) {
                const y = (Math.random() - 0.5) * 0.6;
                const z = (Math.random() - 0.5) * 0.4;
                const p0 = new THREE.Vector3(-hemiParams.offset * 0.9, y, z);
                const p2 = new THREE.Vector3(hemiParams.offset * 0.9, y, z);
                const arch = new THREE.Vector3(0, y + 0.2 + Math.random() * 0.2, z + (Math.random() - 0.5) * 0.2);
                const curve = new THREE.CatmullRomCurve3([p0, arch, p2]);
                const pts = curve.getPoints(16);
                const geo = new THREE.BufferGeometry().setFromPoints(pts);
                const line = new THREE.Line(geo, mat);
                group.add(line);
            }
            return group;
        }
        const corpus = addCorpusCallosum(28);
        brainGroup.add(corpus);

        // ──────────────────────────────────────────────────────────────
        // WORLD → BRAIN → NETWORK LAYERS
        // ──────────────────────────────────────────────────────────────
        const worldGroup = new THREE.Group();
        worldGroup.position.set(-0.15, -0.05, -0.25);
        scene.add(worldGroup);

        // Globe with texture and atmospheric glow
        const GLOBE_R = 1.55;
        const texLoader = new THREE.TextureLoader();
        
        // Day texture
        const earthDayUrl = 'https://unpkg.com/three-globe@2.31.0/example/img/earth-blue-marble.jpg';
        const earthDayTex = texLoader.load(earthDayUrl);
        earthDayTex.colorSpace = THREE.SRGBColorSpace;
        const earthDayMat = new THREE.MeshBasicMaterial({ map: earthDayTex, transparent: true, opacity: 0.9 });
        const earthDayMesh = new THREE.Mesh(new THREE.SphereGeometry(GLOBE_R, 64, 32), earthDayMat);
        worldGroup.add(earthDayMesh);

        // Night texture for city lights
        const earthNightUrl = 'https://unpkg.com/three-globe@2.31.0/example/img/earth-night.jpg';
        const earthNightTex = texLoader.load(earthNightUrl);
        earthNightTex.colorSpace = THREE.SRGBColorSpace;
        const earthNightMat = new THREE.MeshBasicMaterial({ 
            map: earthNightTex, 
            transparent: true, 
            opacity: 0.6, 
            blending: THREE.AdditiveBlending 
        });
        const earthNightMesh = new THREE.Mesh(new THREE.SphereGeometry(GLOBE_R * 1.001, 64, 32), earthNightMat);
        worldGroup.add(earthNightMesh);

        // Atmospheric glow
        const atmosphereMat = new THREE.ShaderMaterial({
            uniforms: {
                'c': { value: 0.5 },
                'p': { value: 4.0 },
                glowColor: { value: new THREE.Color(0x0ea5e9) },
                viewVector: { value: new THREE.Vector3() }
            },
            vertexShader: `
                uniform float c;
                uniform float p;
                uniform vec3 viewVector;
                varying float intensity;
                void main() {
                    vec3 vNormal = normalize( normalMatrix * normal );
                    vec3 vNormel = normalize( vec3( modelViewMatrix * vec4( position, 1.0 ) ) );
                    intensity = pow( c - dot(vNormal, vNormel), p );
                    gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
                }
            `,
            fragmentShader: `
                uniform vec3 glowColor;
                varying float intensity;
                void main() {
                    gl_FragColor = vec4( glowColor * intensity, 1.0 * intensity );
                }
            `,
            side: THREE.BackSide,
            blending: THREE.AdditiveBlending,
            transparent: true
        });

        const atmosphere = new THREE.Mesh(new THREE.SphereGeometry(GLOBE_R * 1.08, 64, 32), atmosphereMat);
        worldGroup.add(atmosphere);

        function latLonToVec3(lat, lon, r) {
            const latR = THREE.MathUtils.degToRad(lat);
            const lonR = THREE.MathUtils.degToRad(lon);
            const x = r * Math.cos(latR) * Math.cos(lonR);
            const y = r * Math.sin(latR);
            const z = -r * Math.cos(latR) * Math.sin(lonR);
            return new THREE.Vector3(x, y, z);
        }


        // City signals → arcs to brain
        const cities = [
            { name: 'Brussels', lat: 50.8503, lon: 4.3517 },
            { name: 'London', lat: 51.5074, lon: -0.1278 },
            { name: 'New York', lat: 40.7128, lon: -74.0060 },
            { name: 'San Francisco', lat: 37.7749, lon: -122.4194 },
            { name: 'Berlin', lat: 52.52, lon: 13.405 },
            { name: 'Singapore', lat: 1.3521, lon: 103.8198 },
            { name: 'Tokyo', lat: 35.6762, lon: 139.6503 },
            { name: 'Sydney', lat: -33.8688, lon: 151.2093 },
            { name: 'Toronto', lat: 43.6532, lon: -79.3832 },
            { name: 'Johannesburg', lat: -26.2041, lon: 28.0473 },
            { name: 'Sao Paulo', lat: -23.5505, lon: -46.6333 },
            { name: 'Dubai', lat: 25.2048, lon: 55.2708 }
        ];

        const cityPulseObjects = [];
        function addCityArcs() {
            const group = new THREE.Group();
            const pulseMat = new THREE.MeshBasicMaterial({ color: 0x67e8f9, transparent: true, opacity: 0.9, blending: THREE.AdditiveBlending });
            const target = new THREE.Vector3(0.0, 0.15, 0.0); // brain hub

            cities.forEach((c, i) => {
                const p0 = latLonToVec3(c.lat, c.lon, GLOBE_R);
                // Curve arches towards the brain group center with slight elevation
                const mid = p0.clone().add(target).multiplyScalar(0.5).add(new THREE.Vector3(0, 0.6 + Math.random() * 0.2, 0));
                const curve = new THREE.CatmullRomCurve3([p0, mid, target]);
                const pts = curve.getPoints(64);

                // Premium arc: Tube with additive translucent material (fresnel-ish)
                const tubeGeo = new THREE.TubeGeometry(curve, 64, 0.009, 8, false);
                const tubeMat = new THREE.MeshPhysicalMaterial({
                    color: 0x67e8f9,
                    transparent: true,
                    opacity: 0.5,
                    roughness: 0.2,
                    metalness: 0.0,
                    clearcoat: 1,
                    clearcoatRoughness: 0.6,
                    blending: THREE.AdditiveBlending,
                    depthWrite: false
                });
                const tube = new THREE.Mesh(tubeGeo, tubeMat);
                group.add(tube);

                // Moving pulse along the curve
                const pulse = new THREE.Mesh(new THREE.SphereGeometry(0.025, 12, 12), pulseMat.clone());
                pulse.position.copy(pts[0]);
                group.add(pulse);
                cityPulseObjects.push({ curve, pulse, speed: 0.18 + Math.random() * 0.35, t: Math.random() });
            });
            return group;
        }
        const cityArcs = addCityArcs();
        worldGroup.add(cityArcs);

        // People network: ring of nodes + soft connections
        const peopleGroup = new THREE.Group();
        scene.add(peopleGroup);
        function addPeopleNetwork(count = 32) {
            const matNode = new THREE.MeshBasicMaterial({ color: 0xa78bfa, transparent: true, opacity: 0.85, blending: THREE.AdditiveBlending });
            const matLink = new THREE.LineBasicMaterial({ color: 0x8b5cf6, transparent: true, opacity: 0.25, blending: THREE.AdditiveBlending });
            const nodes = [];
            const radius = 2.2;
            for (let i = 0; i < count; i++) {
                const ang = (i / count) * Math.PI * 2 + (Math.random() - 0.5) * 0.2;
                const y = -0.1 + Math.sin(ang * 3.0) * 0.15;
                const x = Math.cos(ang) * radius;
                const z = Math.sin(ang) * radius;
                const n = new THREE.Mesh(new THREE.SphereGeometry(0.03, 10, 10), matNode.clone());
                n.position.set(x, y, z);
                peopleGroup.add(n);
                nodes.push(n);
            }
            // Sparse links between neighbors
            for (let i = 0; i < nodes.length; i++) {
                const a = nodes[i];
                const b = nodes[(i + 3) % nodes.length];
                if (Math.random() < 0.6) {
                    const g = new THREE.BufferGeometry().setFromPoints([a.position, b.position]);
                    const ln = new THREE.Line(g, matLink);
                    peopleGroup.add(ln);
                }
            }
            // Connect a few to brain hub
            for (let i = 0; i < 6; i++) {
                const a = nodes[(i * 5) % nodes.length];
                const g = new THREE.BufferGeometry().setFromPoints([a.position, new THREE.Vector3(0, 0.15, 0)]);
                peopleGroup.add(new THREE.Line(g, matLink));
            }
        }
        addPeopleNetwork();

        // Subtle motion and neural firing
        // Intro "dimensions" micro-zoom/perspective dive-out
        const INTRO_SECONDS = reduceMotion ? 0 : 4.0;
        const intro = {
            start: performance.now(),
            duration: INTRO_SECONDS * 1000,
            done: INTRO_SECONDS === 0
        };
        // Start closer to neurons, zoom out to reveal brain → world
        camera.position.z = INTRO_SECONDS ? 2.3 : 3.4;
        brainGroup.rotation.x = -0.15;

        const clock = new THREE.Clock();
        const bursts = [];

        // Helper: fade group opacity
        function setGroupOpacity(group, alpha) {
            group.traverse(obj => {
                if (obj.material) {
                    const mats = Array.isArray(obj.material) ? obj.material : [obj.material];
                    mats.forEach(m => {
                        if ('opacity' in m) {
                            m.transparent = true;
                            m.opacity = alpha;
                        }
                    });
                }
            });
        }
        // Initially hide world/people, reveal during intro
        if (INTRO_SECONDS) {
            setGroupOpacity(worldGroup, 0);
            setGroupOpacity(peopleGroup, 0);
        }

        // Pointer parallax
        const targetRot = { x: brainGroup.rotation.x, y: brainGroup.rotation.y };
        let surge = 0;           // hover energy surge (0..1)
        let surgeTarget = 0;
        container.addEventListener('mousemove', (e) => {
            const rect = container.getBoundingClientRect();
            const mx = (e.clientX - rect.left) / rect.width * 2 - 1;
            const my = (e.clientY - rect.top) / rect.height * 2 - 1;
            targetRot.y = mx * 0.25;
            targetRot.x = -0.15 + my * 0.15;
            const d = Math.hypot(mx, my);
            // Near center → higher surge; clamp to [0,1]
            surgeTarget = Math.max(0, 1 - d * 1.5);
        }, { passive: true });

        function animate() {
            requestAnimationFrame(animate);
            const t = clock.getElapsedTime();

            // Ease towards pointer rotation
            brainGroup.rotation.y += (targetRot.y - brainGroup.rotation.y) * 0.05;
            brainGroup.rotation.x += (targetRot.x - brainGroup.rotation.x) * 0.05;

            // Ease surge
            surge += (surgeTarget - surge) * 0.08;
            // Slight auto-exposure curve with surge accent
            const baseExposure = 1.0 + 0.05 * Math.sin(t * 0.2);
            renderer.toneMappingExposure += ((baseExposure + 0.15 * surge) - renderer.toneMappingExposure) * 0.02;

            // Intro sequence: camera dolly + group fades + subtle FOV change
            if (!intro.done) {
                const now = performance.now();
                const k = Math.min((now - intro.start) / intro.duration, 1);
                const ease = 1 - Math.pow(1 - k, 3); // easeOutCubic
                // camera z from 2.3 → 3.4
                camera.position.z = 2.3 + (3.4 - 2.3) * ease;
                // slight perspective change 60 → 58
                camera.fov = 60 - 2 * ease;
                camera.updateProjectionMatrix();
                // fade world and people in after first quarter
                const fadeK = Math.max(0, (k - 0.25) / 0.75);
                setGroupOpacity(worldGroup, fadeK);
                setGroupOpacity(peopleGroup, fadeK);
                if (k >= 1) intro.done = true;
            }

            if (!reduceMotion) {
                // pulsate opacities to simulate firing
                const pulse = 0.5 + 0.5 * Math.sin(t * 1.5);
                const surgeBoost = 0.4 * surge;
                leftPoints.material.opacity = 0.65 + pulse * 0.25 + surgeBoost * 0.2;
                rightPoints.material.opacity = 0.65 + (1 - pulse) * 0.25 + surgeBoost * 0.2;
                // Slightly grow point size under surge
                if (leftPoints.material.size !== undefined) {
                    leftPoints.material.size = 0.025 * (1 + 0.6 * surge);
                }
                if (rightPoints.material.size !== undefined) {
                    rightPoints.material.size = 0.025 * (1 + 0.6 * surge);
                }

                // shimmer the callosum
                corpus.children.forEach((ln, i) => {
                    const o = 0.15 + 0.15 * Math.sin(t * 2 + i * 0.3);
                    ln.material.opacity = o;
                });

                // rotate globe slowly
                worldGroup.rotation.y = t * 0.07;

                // advance city pulses along arcs
                cityPulseObjects.forEach((obj, i) => {
                    obj.t = (obj.t + obj.speed * 0.016) % 1; // ~60fps dt
                    const base = obj.curve.getPointAt(obj.t);
                    // micro jitter for signal noise
                    const n = 0.005;
                    const pos = base.clone().add(new THREE.Vector3(
                        (Math.random() - 0.5) * n,
                        (Math.random() - 0.5) * n,
                        (Math.random() - 0.5) * n
                    ));
                    obj.pulse.position.copy(pos);
                    obj.pulse.material.opacity = (0.6 + 0.4 * Math.sin((obj.t) * Math.PI)) * (1 + 0.5 * surge);

                    // Trigger burst on arrival
                    if (obj.t > 0.98) {
                        bursts.push({
                            ttl: 0.6,
                            t: 0,
                            pos: new THREE.Vector3(0, 0.15, 0)
                        });
                    }
                });

                // gentle breathing of people ring
                peopleGroup.rotation.y = Math.sin(t * 0.2) * 0.05;

                // traveling wave across corpus (phase offset)
                const wave = Math.sin(t * 1.8) * 0.5 + 0.5;
                corpus.children.forEach((ln, i) => {
                    ln.material.opacity = 0.1 + 0.2 * Math.sin(t * 2.0 + i * 0.25) * wave;
                });

                // Render bursts: temporarily brighten brain points
                for (let i = bursts.length - 1; i >= 0; i--) {
                    const b = bursts[i];
                    b.t += 0.016;
                    const k = Math.min(b.t / b.ttl, 1);
                    const e = 1 - Math.pow(1 - k, 2);
                    const boost = 0.65 + 0.35 * (1 - e);
                    leftPoints.material.opacity = boost;
                    rightPoints.material.opacity = boost;
                    if (k >= 1) bursts.splice(i, 1);
                }
            }

            if (composer) {
                composer.render();
            } else {
                renderer.render(scene, camera);
            }
        }
        animate();

        function handleResize() {
            const width = container.clientWidth;
            const height = container.clientHeight;
            camera.aspect = width / height;
            camera.updateProjectionMatrix();
            renderer.setSize(width, height);
            if (composer) {
                composer.setSize(width, height);
                if (fxaaPass) {
                    fxaaPass.material.uniforms['resolution'].value.set(
                        1 / (width * renderer.getPixelRatio()),
                        1 / (height * renderer.getPixelRatio())
                    );
                }
            }
        }
        window.addEventListener('resize', handleResize);

    } catch (error) {
        console.error('Failed to initialize hero visualization:', error);
        container.innerHTML = '<div style="display: flex; align-items: center; justify-content: center; height: 100%; color: rgba(255,255,255,0.6);">Neural Visualization</div>';
    }
}


// CONTACT FORM
function initializeContactForm() {
    const form = document.querySelector('.contact-form-container');
    if (!form) return;

    form.addEventListener('submit', function (e) {
        e.preventDefault();

        const formData = new FormData(form);
        const data = Object.fromEntries(formData);

        // Simulate form submission
        const submitButton = form.querySelector('.btn-primary');
        const originalText = submitButton.textContent;
        const status = document.getElementById('contact-status');

        submitButton.textContent = 'Sending...';
        submitButton.disabled = true;
        if (status) status.textContent = 'Sending message...';

        setTimeout(() => {
            if (status) status.textContent = 'Thank you for your message! I\'ll get back to you soon.';
            form.reset();
            submitButton.textContent = originalText;
            submitButton.disabled = false;
        }, 2000);
    });
}

// UTILITY FUNCTIONS
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// PERFORMANCE OPTIMIZATION
function optimizePerformance() {
    // Use passive listeners for scroll events
    window.addEventListener('scroll', handleScroll, { passive: true });
    window.addEventListener('resize', debounce(handleResize, 250));
}

function handleScroll() {
    requestAnimationFrame(() => {
        updateScrollProgress();
    });
}

function handleResize() {
    // Handle responsive adjustments
    const heroViz = document.getElementById('hero-visualization');
    if (heroViz && heroViz.firstChild && heroViz.firstChild.tagName === 'CANVAS') {
        // Trigger resize for Three.js visualization
        window.dispatchEvent(new Event('resize'));
    }
}

function updateScrollProgress() {
    const scrolled = (window.pageYOffset / (document.documentElement.scrollHeight - window.innerHeight)) * 100;
    const progressBar = document.querySelector('.scroll-progress');
    if (progressBar) {
        progressBar.style.width = Math.min(scrolled, 100) + '%';
    }
}

// Initialize performance optimizations
optimizePerformance();

// Export functions for global access
window.portfolioFunctions = {
    toggleMobileMenu,
    closeMobileMenu
};