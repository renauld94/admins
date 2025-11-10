/**
 * ADVANCED ANIMATIONS - Scroll-triggered animations & parallax effects
 * Uses Intersection Observer for performance
 * Features: Fade-in, Slide-up, Scale, Stagger, Parallax
 * Version: 20251109.1
 */

(function() {
    'use strict';
    
    class ScrollAnimations {
        constructor() {
            this.animationElements = [];
            this.observer = null;
            
            console.log('✨ [ScrollAnimations] Initializing...');
            
            // Initialize Intersection Observer
            this.setupObserver();
            
            // Observe elements
            this.observeElements();
            
            // Setup scroll events for parallax
            this.setupParallax();
            
            console.log('✅ [ScrollAnimations] Initialized');
        }
        
        /**
         * Setup Intersection Observer for performance-friendly scroll detection
         */
        setupObserver() {
            const options = {
                root: null, // viewport
                rootMargin: '0px 0px -100px 0px', // trigger when 100px before visible
                threshold: 0.1
            };
            
            this.observer = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        this.triggerAnimation(entry.target);
                        // Only animate once
                        this.observer.unobserve(entry.target);
                    }
                });
            }, options);
        }
        
        /**
         * Find and observe animation-enabled elements
         */
        observeElements() {
            // Find all elements with animation attributes
            const fadeElements = document.querySelectorAll('[data-animate="fade"]');
            const slideElements = document.querySelectorAll('[data-animate="slide"]');
            const scaleElements = document.querySelectorAll('[data-animate="scale"]');
            const staggerElements = document.querySelectorAll('[data-animate="stagger"]');
            
            console.log(`✨ [ScrollAnimations] Found ${fadeElements.length} fade elements`);
            console.log(`✨ [ScrollAnimations] Found ${slideElements.length} slide elements`);
            console.log(`✨ [ScrollAnimations] Found ${scaleElements.length} scale elements`);
            console.log(`✨ [ScrollAnimations] Found ${staggerElements.length} stagger elements`);
            
            // Observe all animation elements
            [...fadeElements, ...slideElements, ...scaleElements, ...staggerElements].forEach(el => {
                this.observer.observe(el);
            });
            
            // Also observe parallax elements
            this.observeParallaxElements();
        }
        
        /**
         * Trigger animation on element
         */
        triggerAnimation(element) {
            const animationType = element.dataset.animate;
            const delay = parseFloat(element.dataset.delay || 0);
            const duration = parseFloat(element.dataset.duration || 500);
            const stagger = parseFloat(element.dataset.stagger || 100);
            
            console.log(`✨ [ScrollAnimations] Triggering ${animationType} on ${element.className}`);
            
            setTimeout(() => {
                switch (animationType) {
                    case 'fade':
                        this.animateFade(element, duration);
                        break;
                    case 'slide':
                        this.animateSlide(element, duration);
                        break;
                    case 'scale':
                        this.animateScale(element, duration);
                        break;
                    case 'stagger':
                        this.animateStagger(element, stagger);
                        break;
                    default:
                        console.warn(`Unknown animation type: ${animationType}`);
                }
            }, delay);
        }
        
        /**
         * Fade-in animation
         */
        animateFade(element, duration = 500) {
            element.style.transition = `opacity ${duration}ms ease-in-out`;
            element.style.opacity = '0';
            
            // Trigger reflow to apply initial state
            void element.offsetWidth;
            
            // Animate to final state
            element.style.opacity = '1';
            
            // Remove transition after animation
            setTimeout(() => {
                element.style.transition = '';
            }, duration);
        }
        
        /**
         * Slide-up animation
         */
        animateSlide(element, duration = 500) {
            const direction = element.dataset.direction || 'up';
            
            element.style.transition = `transform ${duration}ms ease-out, opacity ${duration}ms ease-out`;
            
            // Set initial position
            const offset = 40;
            const transforms = {
                up: `translateY(${offset}px)`,
                down: `translateY(-${offset}px)`,
                left: `translateX(${offset}px)`,
                right: `translateX(-${offset}px)`
            };
            
            element.style.transform = transforms[direction];
            element.style.opacity = '0';
            
            // Trigger reflow
            void element.offsetWidth;
            
            // Animate to final state
            element.style.transform = 'translate(0, 0)';
            element.style.opacity = '1';
            
            // Cleanup
            setTimeout(() => {
                element.style.transition = '';
            }, duration);
        }
        
        /**
         * Scale animation
         */
        animateScale(element, duration = 500) {
            element.style.transition = `transform ${duration}ms ease-out, opacity ${duration}ms ease-out`;
            element.style.transform = 'scale(0.95)';
            element.style.opacity = '0';
            
            // Trigger reflow
            void element.offsetWidth;
            
            // Animate
            element.style.transform = 'scale(1)';
            element.style.opacity = '1';
            
            // Cleanup
            setTimeout(() => {
                element.style.transition = '';
            }, duration);
        }
        
        /**
         * Stagger animation (animate children with delay)
         */
        animateStagger(element, staggerDelay = 100) {
            const children = element.querySelectorAll('[data-stagger-item]');
            
            children.forEach((child, index) => {
                const delay = index * staggerDelay;
                child.style.transition = `opacity 500ms ease-in-out, transform 500ms ease-out`;
                child.style.opacity = '0';
                child.style.transform = 'translateY(20px)';
                
                setTimeout(() => {
                    child.style.opacity = '1';
                    child.style.transform = 'translate(0, 0)';
                }, delay);
            });
        }
        
        /**
         * Setup parallax effect on scroll
         */
        setupParallax() {
            const parallaxElements = document.querySelectorAll('[data-parallax]');
            
            if (parallaxElements.length === 0) return;
            
            console.log(`✨ [ScrollAnimations] Setting up parallax for ${parallaxElements.length} elements`);
            
            // Use passive scroll listener for better performance
            let ticking = false;
            
            window.addEventListener('scroll', () => {
                if (!ticking) {
                    window.requestAnimationFrame(() => {
                        this.updateParallax(parallaxElements);
                        ticking = false;
                    });
                    ticking = true;
                }
            }, { passive: true });
        }
        
        /**
         * Update parallax positions
         */
        updateParallax(elements) {
            const scrollY = window.pageYOffset;
            
            elements.forEach(element => {
                const strength = parseFloat(element.dataset.parallax || 0.5);
                const elementOffsetTop = element.getBoundingClientRect().top + scrollY;
                const distance = scrollY - elementOffsetTop;
                const yPos = distance * strength;
                
                element.style.transform = `translateY(${yPos}px)`;
            });
        }
        
        /**
         * Observe parallax elements for animation
         */
        observeParallaxElements() {
            const parallaxElements = document.querySelectorAll('[data-parallax]');
            
            parallaxElements.forEach(el => {
                el.style.willChange = 'transform';
            });
        }
    }
    
    /**
     * Initialize animations when DOM is ready
     */
    function initScrollAnimations() {
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', () => {
                window.scrollAnimations = new ScrollAnimations();
            });
        } else {
            window.scrollAnimations = new ScrollAnimations();
        }
    }
    
    // Initialize
    initScrollAnimations();
    
    // Export public API
    window.ScrollAnimations = ScrollAnimations;
    
    console.log('✅ [ScrollAnimations] Script loaded');
    
})();

/**
 * USAGE EXAMPLES:
 * 
 * // Fade in animation
 * <div data-animate="fade">Content will fade in on scroll</div>
 * 
 * // Slide up animation with custom delay/duration
 * <div data-animate="slide" data-delay="200" data-duration="600">Slides up on scroll</div>
 * 
 * // Scale animation
 * <div data-animate="scale">Scales in on scroll</div>
 * 
 * // Stagger animation (animate children)
 * <div data-animate="stagger" data-stagger="150">
 *   <div data-stagger-item>Item 1</div>
 *   <div data-stagger-item>Item 2</div>
 *   <div data-stagger-item>Item 3</div>
 * </div>
 * 
 * // Parallax effect (strength 0-1, higher = more movement)
 * <div data-parallax="0.3">This moves 30% of scroll distance</div>
 * <div data-parallax="0.8">This moves 80% of scroll distance</div>
 * 
 * Attributes:
 * - data-animate: Type of animation (fade, slide, scale, stagger)
 * - data-direction: Direction for slide (up, down, left, right)
 * - data-delay: Delay in ms before animation starts
 * - data-duration: Animation duration in ms
 * - data-stagger: Delay between staggered children in ms
 * - data-parallax: Parallax strength (0.1-1.0)
 * - data-stagger-item: Marks children for stagger animation
 */
