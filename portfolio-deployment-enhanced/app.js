// NEURO DATALAB PORTFOLIO - PROFESSIONAL JAVASCRIPT 2025

// ANIMATIONS
// Device detection helper (used to gate heavy visualizations on small viewports)
(function(){
    try {
        const isMobile = !!(window.matchMedia && window.matchMedia('(max-width:720px)').matches);
        window.__IS_MOBILE_PORTFOLIO__ = isMobile;
        // Expose a small convenience performance object
        window.heroPerformance = window.heroPerformance || {};
        if (typeof window.heroPerformance.shouldLoadR3F === 'undefined') {
            // default to true on non-mobile, false on mobile to avoid heavy loads
            window.heroPerformance.shouldLoadR3F = !isMobile;
            window.heroPerformance.deviceTier = isMobile ? 'mobile' : 'desktop';
        }
    } catch (e) { /* noop */ }
})();

function initializeAnimations() {
    // Check if GSAP is available
    if (typeof gsap === 'undefined') {
        console.warn('GSAP not loaded - animations disabled');
        return;
    }
    // Defer loading of ScrollTrigger to reduce initial main-thread work.
    // We will attempt to dynamically import the plugin during idle time or on first interaction.
    const ensureScrollTrigger = (() => {
        let loaded = false;
        let pending = [];
        const runPending = () => {
            if (!loaded) return;
            pending.forEach(fn => { try { fn(); } catch (e) { console.warn('ScrollTrigger pending callback failed', e); } });
            pending = [];
        };

        const onLoad = () => {
            loaded = true;
            if (typeof ScrollTrigger !== 'undefined') {
                try { gsap.registerPlugin(ScrollTrigger); } catch (e) { console.warn('Failed to register ScrollTrigger', e); }
            }
            runPending();
        };

        const loadScript = () => {
            if (loaded) return;
            // If ScrollTrigger is already present (unlikely after removing static include), just call onLoad
            if (typeof ScrollTrigger !== 'undefined') {
                onLoad();
                return;
            }

            // Dynamically import the ScrollTrigger UMD from CDN by creating a script element.
            const s = document.createElement('script');
            s.src = 'https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.2/ScrollTrigger.min.js';
            s.async = true;
            s.onload = () => onLoad();
            s.onerror = () => {
                console.warn('Failed to load ScrollTrigger from CDN');
                onLoad();
            };
            document.head.appendChild(s);
        };

        const scheduleLoad = () => {
            if (loaded) return;
            if ('requestIdleCallback' in window) {
                requestIdleCallback(() => loadScript(), { timeout: 2000 });
            } else {
                // Fallback: wait a short timeout then load
                setTimeout(() => loadScript(), 1200);
            }
        };

        // Start scheduling load on first meaningful interaction or idle.
        const onFirstInteraction = () => {
            scheduleLoad();
            window.removeEventListener('pointerdown', onFirstInteraction);
            window.removeEventListener('touchstart', onFirstInteraction);
            window.removeEventListener('keydown', onFirstInteraction);
        };

        window.addEventListener('pointerdown', onFirstInteraction, { passive: true, capture: true });
        window.addEventListener('touchstart', onFirstInteraction, { passive: true, capture: true });
        window.addEventListener('keydown', onFirstInteraction, { passive: true, capture: true });

        // Also schedule a conservative idle load so that the plugin becomes available eventually
        scheduleLoad();

        return {
            whenReady: (cb) => {
                if (loaded) return cb();
                pending.push(cb);
            }
        };
    })();

    // Animate elements on scroll if ScrollTrigger is available
    ensureScrollTrigger.whenReady(() => {
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
    });

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

        // Ensure focus is not inside the mobile nav before hiding it (accessibility requirement)
        try {
            const active = document.activeElement;
            if (mobileNav.contains(active)) {
                if (mobileMenuBtn && typeof mobileMenuBtn.focus === 'function') {
                    mobileMenuBtn.focus({ preventScroll: true });
                } else if (active && typeof active.blur === 'function') {
                    active.blur();
                }
            }
        } catch (e) { /* noop */ }

        mobileMenuBtn.setAttribute('aria-expanded', 'false');
        try {
            mobileNav.setAttribute('aria-hidden', 'true');
            if ('inert' in HTMLElement.prototype) {
                mobileNav.inert = true;
            }
            if (backdrop) {
                backdrop.setAttribute('aria-hidden', 'true');
                if ('inert' in HTMLElement.prototype) backdrop.inert = true;
            }
        } catch (e) {
            mobileNav.setAttribute('aria-hidden', 'true');
            if (backdrop) backdrop.setAttribute('aria-hidden', 'true');
        }

        try {
            document.body.classList.remove('no-scroll');
        } catch (e) {
            document.body.style.overflow = '';
            document.body.style.position = '';
            document.body.style.width = '';
        }
        // remove focus trap listener if present (legacy) and deactivate library trap if created
        try {
            if (window.__mobileNavFocusTrapHandler) {
                document.removeEventListener('keydown', window.__mobileNavFocusTrapHandler, true);
                window.__mobileNavFocusTrapHandler = null;
            }
            if (window.__mobileFocusTrap) {
                try { window.__mobileFocusTrap.deactivate({ returnFocus: true }); } catch (e) { /* noop */ }
                window.__mobileFocusTrap = null;
            }

            if (mobileNav) {
                mobileNav.removeAttribute('role');
                mobileNav.removeAttribute('aria-modal');
            }
            // restore main content accessibility
            try {
                const main = document.querySelector('main');
                if (main) {
                    main.removeAttribute('aria-hidden');
                    if ('inert' in HTMLElement.prototype) main.inert = false;
                }
            } catch (e) { /* noop */ }
        } catch (e) { /* noop */ }
    }
}

// Toggle the mobile navigation panel (open/close) with accessibility attributes
function toggleMobileMenu() {
    try {
        const mobileMenuBtn = document.querySelector('.mobile-menu-btn');
        const mobileNav = document.querySelector('.mobile-nav') || document.querySelector('#mobile-navigation');
        const backdrop = document.querySelector('.mobile-nav-backdrop') || document.getElementById('mobile-nav-backdrop');

        if (!mobileMenuBtn || !mobileNav) return;

        const isOpen = mobileNav.classList.contains('active') || mobileMenuBtn.classList.contains('active');
        const nextState = !isOpen;

        if (nextState) {
            mobileMenuBtn.classList.add('active');
            mobileNav.classList.add('active');
            if (backdrop) backdrop.classList.add('active');
            mobileMenuBtn.setAttribute('aria-expanded', 'true');
            mobileNav.setAttribute('aria-hidden', 'false');
            // mark the mobile nav as a dialog for assistive tech and trap focus
            try {
                mobileNav.setAttribute('role', 'dialog');
                mobileNav.setAttribute('aria-modal', 'true');
            } catch (e) { /* noop */ }
            try { document.body.classList.add('no-scroll'); } catch(e) { document.body.style.overflow = 'hidden'; }

            // hide main content from assistive tech while mobile nav is open
            try {
                const main = document.querySelector('main');
                if (main) {
                    main.setAttribute('aria-hidden', 'true');
                    if ('inert' in HTMLElement.prototype) main.inert = true;
                }
            } catch (e) { /* noop */ }

            // Move focus into the mobile nav for keyboard users
            const firstLink = mobileNav.querySelector('.nav-link, button, [tabindex]');
            if (firstLink && typeof firstLink.focus === 'function') firstLink.focus({ preventScroll: true });
            // Attempt to use the small focus-trap library if available; otherwise the
            // lightweight keyboard guard remains in place (added earlier).
            try {
                const ensureFocusTrapLib = () => {
                    return new Promise((resolve) => {
                        if (typeof window.createFocusTrap === 'function') return resolve(window.createFocusTrap);
                        if (document.querySelector('script[data-focus-trap-loaded]')) {
                            // Script present but API not yet available — poll briefly
                            const start = Date.now();
                            const poll = setInterval(() => {
                                if (typeof window.createFocusTrap === 'function' || Date.now() - start > 3000) {
                                    clearInterval(poll);
                                    return resolve(window.createFocusTrap);
                                }
                            }, 80);
                            return;
                        }

                        const s = document.createElement('script');
                        s.src = 'https://unpkg.com/focus-trap@6.11.4/dist/focus-trap.umd.js';
                        s.async = true;
                        s.setAttribute('data-focus-trap-loaded', '1');
                        s.onload = () => { resolve(window.createFocusTrap); };
                        s.onerror = () => { resolve(null); };
                        document.head.appendChild(s);
                    });
                };

                ensureFocusTrapLib().then((createFocusTrap) => {
                    try {
                        if (createFocusTrap && !window.__mobileFocusTrap) {
                            const trap = createFocusTrap(mobileNav, {
                                initialFocus: mobileNav.querySelector('.nav-link, button, [tabindex]') || mobileMenuBtn,
                                escapeDeactivates: true,
                                clickOutsideDeactivates: true,
                                returnFocusOnDeactivate: true
                            });
                            window.__mobileFocusTrap = trap;
                            try { trap.activate(); } catch (e) { /* noop */ }
                        } else if (window.__mobileFocusTrap) {
                            try { window.__mobileFocusTrap.activate(); } catch (e) { /* noop */ }
                        }
                    } catch (e) { /* noop */ }
                }).catch(() => { /* noop */ });
            } catch (e) { /* noop */ }
        } else {
            // Use existing closeMobileMenu helper to ensure consistent cleanup
            closeMobileMenu();
        }
    } catch (e) {
        console.warn('toggleMobileMenu failed', e);
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
            // When the page is opened from the filesystem (file:), avoid returning a local
            // HTTP developer URL which could trigger mixed-content or insecure popups.
            // Prefer the production HTTPS URL so the user is taken to the secure hosted demo.
            // This is a safe, low-risk change: the host is the public portfolio domain.
            return 'https://www.simondatalab.de/geospatial-viz/index.html';
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
    // Defer loading of ScrollTrigger to reduce initial main-thread work.
    // We will attempt to dynamically import the plugin during idle time or on first interaction.
    const ensureScrollTrigger = (() => {
        let loaded = false;
        let pending = [];
        const runPending = () => {
            if (!loaded) return;
            pending.forEach(fn => { try { fn(); } catch (e) { console.warn('ScrollTrigger pending callback failed', e); } });
            pending = [];
        };

        const onLoad = () => {
            loaded = true;
            if (typeof ScrollTrigger !== 'undefined') {
                try { gsap.registerPlugin(ScrollTrigger); } catch (e) { console.warn('Failed to register ScrollTrigger', e); }
            }
            runPending();
        };

        const loadScript = () => {
            if (loaded) return;
            // If ScrollTrigger is already present (unlikely after removing static include), just call onLoad
            if (typeof ScrollTrigger !== 'undefined') {
                onLoad();
                return;
            }

            // Dynamically import the ScrollTrigger UMD from CDN by creating a script element.
            const s = document.createElement('script');
            s.src = 'https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.2/ScrollTrigger.min.js';
            s.async = true;
            s.onload = () => onLoad();
            s.onerror = () => {
                console.warn('Failed to load ScrollTrigger from CDN');
                onLoad();
            };
            document.head.appendChild(s);
        };

        const scheduleLoad = () => {
            if (loaded) return;
            if ('requestIdleCallback' in window) {
                requestIdleCallback(() => loadScript(), { timeout: 2000 });
            } else {
                // Fallback: wait a short timeout then load
                setTimeout(() => loadScript(), 1200);
            }
        };

        // Start scheduling load on first meaningful interaction or idle.
        const onFirstInteraction = () => {
            scheduleLoad();
            window.removeEventListener('pointerdown', onFirstInteraction);
            window.removeEventListener('touchstart', onFirstInteraction);
            window.removeEventListener('keydown', onFirstInteraction);
        };

        window.addEventListener('pointerdown', onFirstInteraction, { passive: true, capture: true });
        window.addEventListener('touchstart', onFirstInteraction, { passive: true, capture: true });
        window.addEventListener('keydown', onFirstInteraction, { passive: true, capture: true });

        // Also schedule a conservative idle load so that the plugin becomes available eventually
        scheduleLoad();

        return {
            whenReady: (cb) => {
                if (loaded) return cb();
                pending.push(cb);
            }
        };
    })();

    // Animate elements on scroll if ScrollTrigger is available
    ensureScrollTrigger.whenReady(() => {
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
    });

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
                        gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
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

            // Adaptive perf guard: measure recent frame durations and skip heavy updates
            if (typeof animate._frameCount === 'undefined') {
                animate._frameCount = 0;
                animate._perfSamples = [];
                animate._frameSkip = 1;
                animate._lastTime = performance.now();
            }
            animate._frameCount++;
            const now = performance.now();
            const frameDur = now - (animate._lastTime || now);
            animate._lastTime = now;
            animate._perfSamples.push(frameDur);
            if (animate._perfSamples.length > 30) animate._perfSamples.shift();
            const avg = animate._perfSamples.reduce((a,b) => a+b, 0) / animate._perfSamples.length;
            if (avg > 80) {
                animate._frameSkip = Math.min(6, animate._frameSkip + 1);
            } else if (avg > 45) {
                animate._frameSkip = Math.min(4, animate._frameSkip + 1);
            } else if (avg > 28) {
                animate._frameSkip = Math.min(2, animate._frameSkip + 1);
            } else {
                animate._frameSkip = Math.max(1, animate._frameSkip - 1);
            }

            // Lighter per-frame updates that keep the scene responsive
            brainGroup.rotation.y += (targetRot.y - brainGroup.rotation.y) * 0.05;
            brainGroup.rotation.x += (targetRot.x - brainGroup.rotation.x) * 0.05;
            surge += (surgeTarget - surge) * 0.08;
            const baseExposure = 1.0 + 0.05 * Math.sin(t * 0.2);
            renderer.toneMappingExposure += ((baseExposure + 0.15 * surge) - renderer.toneMappingExposure) * 0.02;

            // Do heavy visual updates only on allowed frames when skipping
            if (animate._frameCount % animate._frameSkip === 0) {
                // Intro sequence updates
                if (!intro.done) {
                    const k = Math.min((performance.now() - intro.start) / intro.duration, 1);
                    const ease = 1 - Math.pow(1 - k, 3);
                    camera.position.z = 2.3 + (3.4 - 2.3) * ease;
                    camera.fov = 60 - 2 * ease;
                    camera.updateProjectionMatrix();
                    const fadeK = Math.max(0, (k - 0.25) / 0.75);
                    setGroupOpacity(worldGroup, fadeK);
                    setGroupOpacity(peopleGroup, fadeK);
                    if (k >= 1) intro.done = true;
                }

                if (!reduceMotion) {
                    // pulsate opacities
                    const pulse = 0.5 + 0.5 * Math.sin(t * 1.5);
                    const surgeBoost = 0.4 * surge;
                    leftPoints.material.opacity = 0.65 + pulse * 0.25 + surgeBoost * 0.2;
                    rightPoints.material.opacity = 0.65 + (1 - pulse) * 0.25 + surgeBoost * 0.2;
                    if (leftPoints.material.size !== undefined) leftPoints.material.size = 0.025 * (1 + 0.6 * surge);
                    if (rightPoints.material.size !== undefined) rightPoints.material.size = 0.025 * (1 + 0.6 * surge);

                    // shimmer the callosum
                    for (let i = 0; i < corpus.children.length; i++) {
                        const ln = corpus.children[i];
                        const o = 0.15 + 0.15 * Math.sin(t * 2 + i * 0.3);
                        ln.material.opacity = o;
                    }

                    // rotate globe and advance city pulses (less frequently)
                    worldGroup.rotation.y = t * 0.07;
                    for (let i = 0; i < cityPulseObjects.length; i++) {
                        const obj = cityPulseObjects[i];
                        obj.t = (obj.t + obj.speed * 0.016 * animate._frameSkip) % 1;
                        const base = obj.curve.getPointAt(obj.t);
                        // micro jitter without allocations
                        obj.pulse.position.x = base.x + (Math.random() - 0.5) * 0.005;
                        obj.pulse.position.y = base.y + (Math.random() - 0.5) * 0.005;
                        obj.pulse.position.z = base.z + (Math.random() - 0.5) * 0.005;
                        obj.pulse.material.opacity = (0.6 + 0.4 * Math.sin((obj.t) * Math.PI)) * (1 + 0.5 * surge);
                        if (obj.t > 0.98) bursts.push({ ttl: 0.6, t: 0, pos: new THREE.Vector3(0, 0.15, 0) });
                    }

                    peopleGroup.rotation.y = Math.sin(t * 0.2) * 0.05;

                    const wave = Math.sin(t * 1.8) * 0.5 + 0.5;
                    for (let i = 0; i < corpus.children.length; i++) {
                        const ln = corpus.children[i];
                        ln.material.opacity = 0.1 + 0.2 * Math.sin(t * 2.0 + i * 0.25) * wave;
                    }

                    for (let i = bursts.length - 1; i >= 0; i--) {
                        const b = bursts[i];
                        b.t += 0.016 * animate._frameSkip;
                        const k = Math.min(b.t / b.ttl, 1);
                        const e = 1 - Math.pow(1 - k, 2);
                        const boost = 0.65 + 0.35 * (1 - e);
                        leftPoints.material.opacity = boost;
                        rightPoints.material.opacity = boost;
                        if (k >= 1) bursts.splice(i, 1);
                    }
                }
            }

            // Final render (always render to keep UI responsive)
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

// Export functions for global access (safe assignment)
// Avoid referencing bare identifiers directly (they may not be hoisted in some bundle orderings).
// Use typeof checks and safe wrappers so this module can be concatenated in any order.
window.portfolioFunctions = window.portfolioFunctions || {};

// Provide a safe delegating function for toggleMobileMenu
if (typeof window.portfolioFunctions.toggleMobileMenu === 'undefined') {
    window.portfolioFunctions.toggleMobileMenu = function (...args) {
        try {
            if (typeof toggleMobileMenu === 'function') return toggleMobileMenu.apply(null, args);
        } catch (e) { /* ignore */ }
        try {
            if (window.portfolioFunctions && typeof window.portfolioFunctions.toggleMobileMenu === 'function') {
                return window.portfolioFunctions.toggleMobileMenu.apply(null, args);
            }
        } catch (e) { /* ignore */ }
        // no-op
    };
}

// Provide a safe delegating function for closeMobileMenu
if (typeof window.portfolioFunctions.closeMobileMenu === 'undefined') {
    window.portfolioFunctions.closeMobileMenu = function (...args) {
        try {
            if (typeof closeMobileMenu === 'function') return closeMobileMenu.apply(null, args);
        } catch (e) { /* ignore */ }
        try {
            if (window.portfolioFunctions && typeof window.portfolioFunctions.closeMobileMenu === 'function') {
                return window.portfolioFunctions.closeMobileMenu.apply(null, args);
            }
        } catch (e) { /* ignore */ }
        // no-op
    };
}

// Backwards-compatible globals: some pages or inline handlers may call toggleMobileMenu
// directly. Provide safe global wrappers that delegate to the namespaced functions
// if available, preventing ReferenceError in environments where code order differs.
try {
    if (typeof window !== 'undefined') {
        if (typeof window.toggleMobileMenu === 'undefined') {
            window.toggleMobileMenu = function (...args) {
                try {
                    if (window.portfolioFunctions && typeof window.portfolioFunctions.toggleMobileMenu === 'function') {
                        return window.portfolioFunctions.toggleMobileMenu.apply(null, args);
                    }
                } catch (e) { /* swallow */ }
                // no-op fallback
            };
        }
        if (typeof window.closeMobileMenu === 'undefined') {
            window.closeMobileMenu = function (...args) {
                try {
                    if (window.portfolioFunctions && typeof window.portfolioFunctions.closeMobileMenu === 'function') {
                        return window.portfolioFunctions.closeMobileMenu.apply(null, args);
                    }
                } catch (e) { /* swallow */ }
                // no-op fallback
            };
        }
    }
} catch (e) { /* ignore in constrained environments */ }

// Non-blocking loader for heavy epic neural loading animation
function deferEpicNeuralLoader() {
    try {
        const loadingContainer = document.querySelector('.epic-neural-loading');
        if (!loadingContainer) return; // nothing to do

        // Do not auto-load the heavy epic neural loader on mobile devices to preserve
        // first-contentful-paint and avoid battery/network impact. Developers can
        // still trigger loading manually or via an explicit CTA on mobile.
        if (window.__IS_MOBILE_PORTFOLIO__) {
            console.log('[deferEpicNeuralLoader] Mobile detected - skipping automatic epic loader.');
            return;
        }

        const loadScript = () => {
            if (document.querySelector('script[data-epic-neural-loaded]')) return;
            const s = document.createElement('script');
            s.src = 'epic-neural-loading-enhanced.js';
            s.async = true;
            s.setAttribute('data-epic-neural-loaded', '1');
            s.onload = () => { /* no-op; script manages its own lifecycle */ };
            s.onerror = () => { console.warn('Failed to load epic-neural-loading-enhanced.js'); };
            document.head.appendChild(s);
        };

        const schedule = () => {
            if ('requestIdleCallback' in window) requestIdleCallback(loadScript, { timeout: 3000 });
            else setTimeout(loadScript, 2000);
        };

        // Prime on first user interaction to ensure the animation is available when needed
        const onFirstInteraction = () => {
            schedule();
            window.removeEventListener('pointerdown', onFirstInteraction);
            window.removeEventListener('touchstart', onFirstInteraction);
            window.removeEventListener('keydown', onFirstInteraction);
        };

        window.addEventListener('pointerdown', onFirstInteraction, { passive: true, capture: true });
        window.addEventListener('touchstart', onFirstInteraction, { passive: true, capture: true });
        window.addEventListener('keydown', onFirstInteraction, { passive: true, capture: true });

        // Also schedule a conservative idle load so it doesn't remain blocked forever
        schedule();
    } catch (e) {
        console.warn('deferEpicNeuralLoader failed', e);
    }
}

// Kick off deferred loader
deferEpicNeuralLoader();

// On-demand loader for advanced visualization (exposed globally)
window.loadAdvancedVisualization = function loadAdvancedVisualization() {
    try {
        // If the heavy epic loader is already present, call the visualizer entry
        if (document.querySelector('script[data-epic-neural-loaded]')) {
            console.log('[loadAdvancedVisualization] Epic loader already present — attempting to initialize visualization');
            if (typeof window.loadNeuralVisualization === 'function') {
                window.loadNeuralVisualization();
            }
            return Promise.resolve();
        }

        // Analytics hook: emit event when user explicitly requests the advanced viz
        try {
            window.dispatchEvent(new CustomEvent('advancedViz:requested', { detail: { ts: Date.now() } }));
            console.log('[Analytics] advancedViz requested');
        } catch (e) { /* noop */ }

        return new Promise((resolve, reject) => {
            const s = document.createElement('script');
            s.src = 'epic-neural-loading-enhanced.js';
            s.async = true;
            s.setAttribute('data-epic-neural-loaded', '1');
            s.onload = () => {
                console.log('[loadAdvancedVisualization] Epic loader script loaded');
                try {
                    if (typeof window.loadNeuralVisualization === 'function') {
                        window.loadNeuralVisualization();
                        try {
                            window.dispatchEvent(new CustomEvent('advancedViz:loaded', { detail: { ts: Date.now() } }));
                            console.log('[Analytics] advancedViz loaded');
                        } catch (e) { /* noop */ }
                    }
                } catch (e) { console.warn('Error while initializing loaded visualization', e); }
                resolve();
            };
            s.onerror = (err) => {
                console.warn('[loadAdvancedVisualization] Failed to load epic loader', err);
                reject(err);
            };
            document.head.appendChild(s);
        });
    } catch (e) {
        console.warn('loadAdvancedVisualization failed', e);
        return Promise.reject(e);
    }
};

// Wire the hero CTA (if present) to the on-demand loader
document.addEventListener('DOMContentLoaded', () => {
    try {
        const cta = document.getElementById('load-advanced-viz-cta');
        if (!cta) return;
        cta.addEventListener('click', (e) => {
            e.preventDefault();
            cta.setAttribute('aria-pressed', 'true');
            cta.textContent = 'Loading visualization...';
            // Provide visual feedback and attempt to load
            window.loadAdvancedVisualization().then(() => {
                cta.textContent = 'Visualization loaded';
            }).catch(() => {
                cta.textContent = 'Load failed — try again';
                setTimeout(() => { cta.textContent = 'Load advanced visualization'; cta.setAttribute('aria-pressed','false'); }, 2500);
            });
        }, { passive: false });
    } catch (e) { /* noop */ }
});


// Attach mobile nav listeners (safe, idempotent)
try {
    document.addEventListener('DOMContentLoaded', () => {
        try {
            const mobileMenuBtn = document.querySelector('.mobile-menu-btn');
            const backdrop = document.querySelector('.mobile-nav-backdrop') || document.getElementById('mobile-nav-backdrop');
            const mobileNav = document.querySelector('.mobile-nav') || document.querySelector('#mobile-navigation');
            const mobileNavClose = document.querySelector('.mobile-nav-close');

            if (mobileMenuBtn) {
                mobileMenuBtn.addEventListener('click', (e) => {
                    e.preventDefault();
                    toggleMobileMenu();
                }, { passive: false });
                // touchend helps on some mobile browsers where click is delayed
                mobileMenuBtn.addEventListener('touchend', (e) => {
                    e.preventDefault();
                    toggleMobileMenu();
                }, { passive: false });
            }

            if (backdrop) {
                backdrop.addEventListener('click', (e) => {
                    e.preventDefault();
                    closeMobileMenu();
                });
            }

            if (mobileNavClose) {
                mobileNavClose.addEventListener('click', (e) => {
                    e.preventDefault();
                    closeMobileMenu();
                });
            }

            // Close on ESC
            document.addEventListener('keydown', (ev) => {
                if (ev.key === 'Escape') closeMobileMenu();
            });
        } catch (err) { /* noop */ }
    });
} catch (e) { /* noop */ }

// Mobile-specific visual tuning: remove duplicate hero canvases and reduce render quality
function normalizeMobileHeroCanvas() {
    try {
        // Only run on devices we flagged as mobile
        if (!window.__IS_MOBILE_PORTFOLIO__) return;
        const container = document.getElementById('hero-visualization');
        if (!container) return;

        const canvases = container.querySelectorAll('canvas');
        if (canvases.length > 1) {
            // Keep the first canvas and remove any additional canvases created by fallbacks/duplicate renders
            for (let i = 1; i < canvases.length; i++) {
                try { canvases[i].remove(); } catch (err) { try { canvases[i].parentNode && canvases[i].parentNode.removeChild(canvases[i]); } catch(e) { /* noop */ } }
            }
            console.log('[mobile] normalizeMobileHeroCanvas: removed', canvases.length - 1, 'extra canvas(es)');
        }

        // Lower rendering fidelity on mobile to improve fluidity
        window.heroPerformance = window.heroPerformance || {};
        // Cap pixel ratio and particles conservatively on mobile
        window.heroPerformance.pixelRatio = Math.min(window.heroPerformance.pixelRatio || 1, 1);
        window.heroPerformance.maxParticles = Math.min(window.heroPerformance.maxParticles || 2500, 2500);

        // If a renderer exists, try to nudge its pixel ratio down (best-effort)
        try {
            const primaryCanvas = container.querySelector('canvas');
            if (primaryCanvas && primaryCanvas._threeRenderer) {
                const renderer = primaryCanvas._threeRenderer;
                if (renderer.setPixelRatio) renderer.setPixelRatio(1);
            }
        } catch (e) { /* noop */ }
    } catch (e) {
        console.warn('normalizeMobileHeroCanvas failed', e);
    }
}

// Apply normalization at DOMContentLoaded and shortly after to catch async mounts
try {
    document.addEventListener('DOMContentLoaded', () => {
        try {
            normalizeMobileHeroCanvas();
            setTimeout(normalizeMobileHeroCanvas, 1200);
        } catch (e) { /* noop */ }
    }, { passive: true });
} catch (e) { /* noop */ }