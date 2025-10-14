// PROFESSIONAL LEARNING PLATFORM JAVASCRIPT
// Streamlined, performant, and focused on user experience

// INITIALIZATION
document.addEventListener('DOMContentLoaded', function() {
    console.log('Learning Management System Academy - Professional Platform Initialized');

    // Initialize GSAP ScrollTrigger
    if (typeof gsap !== 'undefined' && typeof ScrollTrigger !== 'undefined') {
        gsap.registerPlugin(ScrollTrigger);
        console.log('✅ GSAP ScrollTrigger registered');
    }

    // Initialize core functionality
    initializeNavigation();
    initializeModalSystem();
    initializeAnimations();
    initializeScrollProgress();

    // Add click handlers to all "Dive Deeper" buttons
    document.querySelectorAll('.dive-deeper-btn, [data-topic]').forEach(button => {
        button.addEventListener('click', (e) => {
            e.preventDefault();
            const topic = button.dataset.topic || button.closest('[data-topic]').dataset.topic;
            if (topic) {
                diveIntoTopic(topic);
            }
        });
    });
});

// NAVIGATION SYSTEM
function initializeNavigation() {
    // Smooth scrolling for navigation links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });

    // Mobile menu toggle
    const mobileMenuBtn = document.querySelector('.mobile-menu-btn');
    const navMenu = document.querySelector('.nav-menu');
    // Create a mobile overlay from the existing nav markup when needed.
    // This avoids duplicating link markup in HTML and keeps desktop menu intact.
    let mobileNavOverlay = null;

    function openMobileNav() {
        if (!mobileNavOverlay) {
            mobileNavOverlay = document.createElement('div');
            mobileNavOverlay.className = 'mobile-nav';
            mobileNavOverlay.innerHTML = `<ul class="nav-menu">${navMenu.innerHTML}</ul>`;
            document.body.appendChild(mobileNavOverlay);

            // Delegate clicks on links to close the menu and smooth scroll (if anchors)
            mobileNavOverlay.addEventListener('click', (e) => {
                const link = e.target.closest('a');
                if (!link) return;
                // Close overlay for any link click
                closeMobileNav();
            });
        }

        mobileNavOverlay.classList.add('open');
        mobileMenuBtn.classList.add('active');
        // Prevent body scroll while overlay is open
        document.body.style.overflow = 'hidden';
    }

    function closeMobileNav() {
        if (mobileNavOverlay) {
            mobileNavOverlay.classList.remove('open');
        }
        mobileMenuBtn.classList.remove('active');
        document.body.style.overflow = '';
    }

    if (mobileMenuBtn && navMenu) {
        mobileMenuBtn.addEventListener('click', (e) => {
            e.stopPropagation();
            if (mobileNavOverlay?.classList.contains('open')) {
                closeMobileNav();
            } else {
                openMobileNav();
            }
        });
    }

    // Close mobile menu when clicking outside overlay or on Escape
    document.addEventListener('click', (e) => {
        if (mobileNavOverlay && mobileNavOverlay.classList.contains('open')) {
            if (!mobileNavOverlay.contains(e.target) && !mobileMenuBtn.contains(e.target)) {
                closeMobileNav();
            }
        }
    });

    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') closeMobileNav();
    });
}

// MODAL SYSTEM
function initializeModalSystem() {
    // Close modal when clicking outside
    document.addEventListener('click', (e) => {
        const modal = document.querySelector('.topic-modal');
        if (modal && e.target === modal) {
            closeTopicModal();
        }
    });

    // Close modal on escape key
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') {
            closeTopicModal();
        }
    });
}

function diveIntoTopic(topic) {
    const topicData = {
        'consciousness': {
            title: 'Human Consciousness Network',
            content: 'Explore the intricate connections between analytical and creative thinking, neural pathways, and collective intelligence patterns. This comprehensive course covers the fundamental principles of consciousness studies and their applications in modern neuroscience.',
            redirect: 'http://136.243.155.166:8086/moodle/course/view.php?id=consciousness',
            category: 'Neuroscience'
        },
        'data-science': {
            title: 'Data Science Fundamentals',
            content: 'Master the core concepts of data science including statistical analysis, machine learning algorithms, and data visualization techniques essential for clinical research and academic studies.',
            redirect: 'http://136.243.155.166:8086/moodle/course/view.php?id=data-science',
            category: 'Data Science'
        },
        'machine-learning': {
            title: 'Machine Learning for Research',
            content: 'Learn to apply machine learning algorithms to research data, understand model validation techniques, and interpret results in the context of scientific discovery and clinical applications.',
            redirect: 'http://136.243.155.166:8086/moodle/course/view.php?id=machine-learning',
            category: 'AI/ML'
        },
        'neural-networks': {
            title: 'Neural Network Architectures',
            content: 'Deep dive into neural network design, training methodologies, and optimization techniques with practical applications in neuroscience and clinical data analysis.',
            redirect: 'http://136.243.155.166:8086/moodle/course/view.php?id=neural-networks',
            category: 'AI/ML'
        },
        'clinical-programming': {
            title: 'Clinical Programming Excellence',
            content: 'Comprehensive training in clinical trial programming, data management, and regulatory compliance standards for pharmaceutical and clinical research environments.',
            redirect: 'http://136.243.155.166:8086/moodle/course/view.php?id=clinical-programming',
            category: 'Clinical Research'
        },
        'geomatics': {
            title: 'Advanced Geomatics',
            content: 'Master geospatial data analysis, geographic information systems (GIS), and spatial statistics for environmental and epidemiological research applications.',
            redirect: 'http://136.243.155.166:8086/moodle/course/view.php?id=geomatics',
            category: 'Geography'
        },
        'data-visualization': {
            title: 'Data Visualization Mastery',
            content: 'Learn to create compelling, interactive visualizations that effectively communicate complex research findings and support data-driven decision making.',
            redirect: 'http://136.243.155.166:8086/moodle/course/view.php?id=data-visualization',
            category: 'Visualization'
        },
        'research-methods': {
            title: 'Advanced Research Methods',
            content: 'Comprehensive coverage of research methodology, experimental design, statistical analysis, and scientific writing for academic and clinical research.',
            redirect: 'http://136.243.155.166:8086/moodle/course/view.php?id=research-methods',
            category: 'Research'
        },
        'data-ethics': {
            title: 'Data Ethics & Privacy',
            content: 'Navigate the complex ethical landscape of data collection, analysis, and sharing with focus on privacy regulations, informed consent, and responsible AI development.',
            redirect: 'http://136.243.155.166:8086/moodle/course/view.php?id=data-ethics',
            category: 'Ethics'
        },
        'mathematical-modeling': {
            title: 'Mathematical Modeling',
            content: 'Apply advanced mathematical techniques to model complex biological systems, disease progression, and treatment outcomes in clinical research.',
            redirect: 'http://136.243.155.166:8086/moodle/course/view.php?id=mathematical-modeling',
            category: 'Mathematics'
        },
        'storytelling': {
            title: 'Data Science Storytelling Hub',
            content: 'Explore compelling narratives that bridge neuroscience, data engineering, AI ethics, and geospatial intelligence through interactive visualizations and professional case studies.',
            redirect: 'http://136.243.155.166:8086/moodle/course/view.php?id=storytelling',
            category: 'Professional Development'
        },
        'professional-journey': {
            title: 'From Neuroscience to Data Leadership',
            content: 'My professional journey from cognitive research to enterprise data architecture, featuring key projects in AI-powered CRM analytics, multi-cloud geospatial platforms, and cognitive learning analytics.',
            redirect: 'http://136.243.155.166:8086/moodle/course/view.php?id=professional-journey',
            category: 'Career Development'
        },
        'data-pipeline-story': {
            title: 'Data Pipeline Chronicles',
            content: 'Master the art and science of building scalable data infrastructure using Apache Spark, ETL processes, and cloud-native architectures for clinical research and business intelligence.',
            redirect: 'http://136.243.155.166:8086/moodle/course/view.php?id=data-pipeline-story',
            category: 'Data Engineering'
        },
        'ai-ethics-story': {
            title: 'AI Ethics in Healthcare',
            content: 'Navigate the complex ethical landscape of AI in healthcare, balancing innovation with responsibility in clinical research, patient privacy, and algorithmic fairness.',
            redirect: 'http://136.243.155.166:8086/moodle/course/view.php?id=ai-ethics-story',
            category: 'Ethics & AI'
        },
        'geospatial-story': {
            title: 'Geospatial Intelligence & Analytics',
            content: 'Transform spatial data into actionable insights using GIS, remote sensing, and geospatial analytics for epidemiology, urban planning, and environmental monitoring.',
            redirect: 'http://136.243.155.166:8086/moodle/course/view.php?id=geospatial-story',
            category: 'Geospatial Analytics'
        },
        'python-fundamentals': {
            title: 'Python Fundamentals',
            content: 'Master the core concepts of Python programming including syntax, data structures, control flow, and object-oriented programming principles essential for data science.',
            redirect: 'http://136.243.155.166:8086/moodle/course/view.php?id=python-fundamentals',
            category: 'Python Programming'
        },
        'data-science-python': {
            title: 'Data Science with Python',
            content: 'Learn data manipulation, analysis, and visualization using pandas, NumPy, and matplotlib for clinical research and enterprise analytics.',
            redirect: 'http://136.243.155.166:8086/moodle/course/view.php?id=data-science-python',
            category: 'Data Science'
        },
        'machine-learning': {
            title: 'Machine Learning with Python',
            content: 'Implement supervised and unsupervised learning algorithms using scikit-learn for predictive modeling and pattern recognition in healthcare.',
            redirect: 'http://136.243.155.166:8086/moodle/course/view.php?id=machine-learning',
            category: 'Machine Learning'
        },
        'deep-learning': {
            title: 'Deep Learning & Neural Networks',
            content: 'Build and train neural networks using TensorFlow and PyTorch for advanced AI applications in clinical research and medical imaging.',
            redirect: 'http://136.243.155.166:8086/moodle/course/view.php?id=deep-learning',
            category: 'Deep Learning'
        },
        'clinical-data': {
            title: 'Clinical Data Analysis',
            content: 'Specialized Python programming for healthcare data processing, statistical analysis, and clinical trial data management with regulatory compliance.',
            redirect: 'http://136.243.155.166:8086/moodle/course/view.php?id=clinical-data',
            category: 'Clinical Research'
        },
        'python-automation': {
            title: 'Python for Automation',
            content: 'Automate data workflows, ETL processes, and reporting using Python scripts for efficient research operations and business intelligence.',
            redirect: 'http://136.243.155.166:8086/moodle/course/view.php?id=python-automation',
            category: 'Automation'
        },
        'python-academy': {
            title: 'Python Academy Hub',
            content: 'Comprehensive Python programming curriculum designed for data science, machine learning, and clinical research applications with hands-on projects.',
            redirect: 'http://136.243.155.166:8086/moodle/course/view.php?id=python-academy',
            category: 'Python Academy'
        },
        'project-context': {
            title: 'Project Context & Architecture',
            content: 'Understanding the Learning Management System Academy architecture, Moodle-based platform, Docker deployment, and development workflow for effective AI collaboration.',
            redirect: 'http://136.243.155.166:8086/moodle/course/view.php?id=project-context',
            category: 'AI Development'
        },
        'coding-guidelines': {
            title: 'AI Coding Guidelines',
            content: 'Best practices for generating code, answering questions, and reviewing changes in the LMS Academy project environment with focus on Moodle theme development.',
            redirect: 'http://136.243.155.166:8086/moodle/course/view.php?id=coding-guidelines',
            category: 'AI Development'
        },
        'ai-collaboration': {
            title: 'AI-Human Collaboration',
            content: 'Effective collaboration patterns between AI agents and human developers in the Moodle LMS development ecosystem, including code review and workflow integration.',
            redirect: 'http://136.243.155.166:8086/moodle/course/view.php?id=ai-collaboration',
            category: 'AI Development'
        },
        'file-structure': {
            title: 'Project File Structure',
            content: 'Understanding the organization of Moodle themes, Docker configurations, Proxmox deployment, and development environment structure for the LMS Academy.',
            redirect: 'http://136.243.155.166:8086/moodle/course/view.php?id=file-structure',
            category: 'AI Development'
        },
        'ai-guidelines': {
            title: 'AI Development Guidelines Hub',
            content: 'Comprehensive guidelines for AI agents working on the Learning Management System Academy, covering project context, coding standards, and collaboration patterns.',
            redirect: 'http://136.243.155.166:8086/moodle/course/view.php?id=ai-guidelines',
            category: 'AI Development'
        }
    };

    const data = topicData[topic];
    if (data) {
        showTopicModal(data);
    }
}

function showTopicModal(data) {
    // Remove existing modal if present
    const existingModal = document.querySelector('.topic-modal');
    if (existingModal) {
        existingModal.remove();
    }

    // Create modal overlay
    const modal = document.createElement('div');
    modal.className = 'topic-modal';
    modal.innerHTML = `
        <div class="modal-content">
            <div class="modal-header">
                <h3>${data.title}</h3>
                <span class="topic-category">${data.category}</span>
                <button class="modal-close" onclick="closeTopicModal()">&times;</button>
            </div>
            <div class="modal-body">
                <p>${data.content}</p>
                <div class="modal-actions">
                    <button class="btn primary" onclick="redirectToTopic('${data.redirect}')">
                        Start Learning
                    </button>
                    <button class="btn secondary" onclick="closeTopicModal()">
                        Explore More Topics
                    </button>
                </div>
            </div>
        </div>
    `;

    document.body.appendChild(modal);

    // Animate modal entrance
    gsap.from('.modal-content', {
        duration: 0.5,
        y: 50,
        opacity: 0,
        scale: 0.9,
        ease: 'power3.out'
    });

    // Prevent body scroll when modal is open
    document.body.style.overflow = 'hidden';
}

function closeTopicModal() {
    const modal = document.querySelector('.topic-modal');
    if (modal) {
        gsap.to('.modal-content', {
            duration: 0.3,
            y: -50,
            opacity: 0,
            scale: 0.9,
            ease: 'power3.in',
            onComplete: () => {
                modal.remove();
                document.body.style.overflow = '';
            }
        });
    }
}

function redirectToTopic(url) {
    closeTopicModal();
    window.open(url, '_blank');
}

// GENERAL ANIMATIONS
function initializeAnimations() {
    // Add subtle animations to various elements
    gsap.utils.toArray('.btn').forEach(btn => {
        btn.addEventListener('mouseenter', () => {
            gsap.to(btn, {
                duration: 0.2,
                scale: 1.05,
                ease: 'power2.out'
            });
        });

        btn.addEventListener('mouseleave', () => {
            gsap.to(btn, {
                duration: 0.2,
                scale: 1,
                ease: 'power2.out'
            });
        });
    });

    // Animate section headers on scroll
    gsap.utils.toArray('.section-header').forEach(header => {
        if (typeof ScrollTrigger !== 'undefined') {
            gsap.from(header, {
                scrollTrigger: {
                    trigger: header,
                    start: 'top 80%',
                    end: 'bottom 20%',
                    toggleActions: 'play none none reverse'
                },
                y: 50,
                opacity: 0,
                duration: 0.8,
                ease: 'power3.out'
            });
        } else {
            // Fallback animation without ScrollTrigger
            gsap.from(header, {
                y: 50,
                opacity: 0,
                duration: 0.8,
                ease: 'power3.out'
            });
        }
    });
}

// SCROLL PROGRESS
function initializeScrollProgress() {
    const progressBar = document.querySelector('.scroll-progress');

    if (progressBar) {
        window.addEventListener('scroll', () => {
            const scrolled = (window.pageYOffset / (document.documentElement.scrollHeight - window.innerHeight)) * 100;
            progressBar.style.width = scrolled + '%';
        });
    }
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

    // Debounce resize events
    window.addEventListener('resize', debounce(handleResize, 250));
}

function handleScroll() {
    // Throttled scroll handling
    requestAnimationFrame(() => {
        // Update scroll-based animations
        updateScrollProgress();
    });
}

function handleResize() {
    // Handle window resize
    console.log('Window resized');
}

function updateScrollProgress() {
    const scrolled = (window.pageYOffset / (document.documentElement.scrollHeight - window.innerHeight)) * 100;

    // Update any scroll progress indicators
    const progressBar = document.querySelector('.scroll-progress');
    if (progressBar) {
        progressBar.style.width = scrolled + '%';
    }
}

// Initialize performance optimizations
optimizePerformance();

// Initialize selective educational visualizations
initializeEducationalVisualizations();

// STORYTELLING VISUALIZATIONS
function initializeStorytellingVisualizations() {
    // Only initialize storytelling visualizations that enhance learning
    if (document.getElementById('data-pipeline-3d')) {
        initializeDataPipelineVisualization();
    }

    if (document.getElementById('ai-evolution-timeline')) {
        initializeAIEvolutionTimeline();
    }

    if (document.getElementById('neuroscience-integration')) {
        initializeNeuroscienceIntegration();
    }
}

// DATA PIPELINE 3D VISUALIZATION - Professional ETL Process
function initializeDataPipelineVisualization() {
    const container = document.getElementById('data-pipeline-3d');
    if (!container) return;

    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(75, container.clientWidth / container.clientHeight, 0.1, 1000);
    const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });

    renderer.setSize(container.clientWidth, container.clientHeight);
    renderer.setClearColor(0x000000, 0);
    container.appendChild(renderer.domElement);

    // Create pipeline stages
    const stages = [
        { name: 'Extract', position: [-3, 0, 0], color: 0x6366f1, size: 0.8 },
        { name: 'Transform', position: [0, 0, 0], color: 0x8b5cf6, size: 1.0 },
        { name: 'Load', position: [3, 0, 0], color: 0x059669, size: 0.8 }
    ];

    const stageObjects = [];

    stages.forEach(stage => {
        const geometry = new THREE.CylinderGeometry(stage.size, stage.size, 0.3, 16);
        const material = new THREE.MeshPhongMaterial({
            color: stage.color,
            transparent: true,
            opacity: 0.9
        });
        const cylinder = new THREE.Mesh(geometry, material);
        cylinder.position.set(...stage.position);
        cylinder.userData = { name: stage.name };
        scene.add(cylinder);
        stageObjects.push(cylinder);

        // Add pulsing effect
        gsap.to(cylinder.scale, {
            x: 1.2, y: 1.2, z: 1.2,
            duration: 2 + Math.random(),
            yoyo: true,
            repeat: -1,
            ease: 'power2.inOut'
        });
    });

    // Create data flow particles
    const particles = [];
    for (let i = 0; i < 20; i++) {
        const geometry = new THREE.SphereGeometry(0.05, 8, 8);
        const material = new THREE.MeshBasicMaterial({
            color: new THREE.Color().setHSL(Math.random(), 0.7, 0.6)
        });
        const particle = new THREE.Mesh(geometry, material);

        // Start particles at extract stage
        particle.position.set(-3 + Math.random() * 0.5, Math.random() * 0.5 - 0.25, Math.random() * 0.5 - 0.25);
        particle.targetStage = Math.floor(Math.random() * 3); // 0, 1, or 2
        particle.progress = 0;

        scene.add(particle);
        particles.push(particle);
    }

    // Create connection tubes
    for (let i = 0; i < stages.length - 1; i++) {
        const startPos = new THREE.Vector3(...stages[i].position);
        const endPos = new THREE.Vector3(...stages[i + 1].position);

        const direction = endPos.clone().sub(startPos);
        const length = direction.length();
        const geometry = new THREE.CylinderGeometry(0.05, 0.05, length, 8);
        const material = new THREE.MeshPhongMaterial({
            color: 0xffffff,
            transparent: true,
            opacity: 0.3
        });

        const tube = new THREE.Mesh(geometry, material);
        tube.position.copy(startPos).add(direction.multiplyScalar(0.5));
        tube.lookAt(endPos);
        tube.rotateX(Math.PI / 2);

        scene.add(tube);
    }

    // Lighting
    const ambientLight = new THREE.AmbientLight(0x404040, 0.6);
    scene.add(ambientLight);

    const pointLight = new THREE.PointLight(0xffffff, 0.8);
    pointLight.position.set(0, 2, 2);
    scene.add(pointLight);

    camera.position.z = 6;

    // Animation loop
    function animate() {
        requestAnimationFrame(animate);

        // Animate particles through pipeline
        particles.forEach(particle => {
            const startStage = Math.floor(particle.progress * 2);
            const nextStage = Math.min(startStage + 1, 2);

            const startPos = new THREE.Vector3(...stages[startStage].position);
            const endPos = new THREE.Vector3(...stages[nextStage].position);

            const localProgress = (particle.progress * 2) - startStage;
            particle.position.lerpVectors(startPos, endPos, localProgress);

            particle.progress += 0.005;
            if (particle.progress >= 1) {
                particle.progress = 0;
                // Reset to start
                particle.position.set(-3 + Math.random() * 0.5, Math.random() * 0.5 - 0.25, Math.random() * 0.5 - 0.25);
            }

            // Gentle particle rotation
            particle.rotation.x += 0.02;
            particle.rotation.y += 0.02;
        });

        // Rotate the entire pipeline slowly
        scene.rotation.y += 0.002;

        renderer.render(scene, camera);
    }
    animate();

    // Educational tooltips
    container.addEventListener('click', (event) => {
        const mouse = new THREE.Vector2();
        mouse.x = (event.offsetX / container.clientWidth) * 2 - 1;
        mouse.y = -(event.offsetY / container.clientHeight) * 2 + 1;

        const raycaster = new THREE.Raycaster();
        raycaster.setFromCamera(mouse, camera);
        const intersects = raycaster.intersectObjects(stageObjects);

        if (intersects.length > 0) {
            const stage = intersects[0].object.userData.name;
            showPipelineTooltip(stage, event);
        }
    });
}

// AI EVOLUTION TIMELINE - Machine Learning Progress Visualization
function initializeAIEvolutionTimeline() {
    const svg = d3.select('#ai-evolution-timeline')
        .append('svg')
        .attr('width', '100%')
        .attr('height', '400')
        .attr('viewBox', '0 0 800 400');

    // AI/ML evolution data
    const evolutionData = [
        { year: 2010, name: 'Traditional ML', description: 'Linear Regression, Decision Trees', accuracy: 0.3, complexity: 0.2 },
        { year: 2012, name: 'Deep Learning', description: 'Neural Networks, CNNs', accuracy: 0.5, complexity: 0.4 },
        { year: 2015, name: 'Transfer Learning', description: 'Pre-trained models, Fine-tuning', accuracy: 0.7, complexity: 0.6 },
        { year: 2018, name: 'Transformers', description: 'Attention mechanisms, BERT', accuracy: 0.85, complexity: 0.8 },
        { year: 2021, name: 'Large Language Models', description: 'GPT, Multimodal AI', accuracy: 0.95, complexity: 0.9 },
        { year: 2024, name: 'Foundation Models', description: 'Unified architectures, AGI progress', accuracy: 0.98, complexity: 1.0 }
    ];

    const margin = { top: 40, right: 40, bottom: 60, left: 60 };
    const width = 800 - margin.left - margin.right;
    const height = 400 - margin.top - margin.bottom;

    const g = svg.append('g')
        .attr('transform', `translate(${margin.left},${margin.top})`);

    // Scales
    const xScale = d3.scaleLinear()
        .domain([2010, 2024])
        .range([0, width]);

    const yAccuracyScale = d3.scaleLinear()
        .domain([0, 1])
        .range([height, 0]);

    const yComplexityScale = d3.scaleLinear()
        .domain([0, 1])
        .range([height, 0]);

    // Axes
    g.append('g')
        .attr('transform', `translate(0,${height})`)
        .call(d3.axisBottom(xScale).tickFormat(d3.format('d')));

    g.append('g')
        .call(d3.axisLeft(yAccuracyScale).tickFormat(d => `${d * 100}%`));

    // Labels
    g.append('text')
        .attr('x', width / 2)
        .attr('y', height + 40)
        .attr('text-anchor', 'middle')
        .attr('fill', 'white')
        .text('Year');

    g.append('text')
        .attr('transform', 'rotate(-90)')
        .attr('x', -height / 2)
        .attr('y', -40)
        .attr('text-anchor', 'middle')
        .attr('fill', 'white')
        .text('Model Accuracy');

    // Create line for accuracy
    const accuracyLine = d3.line()
        .x(d => xScale(d.year))
        .y(d => yAccuracyScale(d.accuracy))
        .curve(d3.curveMonotoneX);

    g.append('path')
        .datum(evolutionData)
        .attr('fill', 'none')
        .attr('stroke', '#6366f1')
        .attr('stroke-width', 3)
        .attr('d', accuracyLine);

    // Create line for complexity
    const complexityLine = d3.line()
        .x(d => xScale(d.year))
        .y(d => yComplexityScale(d.complexity))
        .curve(d3.curveMonotoneX);

    g.append('path')
        .datum(evolutionData)
        .attr('fill', 'none')
        .attr('stroke', '#8b5cf6')
        .attr('stroke-width', 2)
        .attr('stroke-dasharray', '5,5')
        .attr('d', complexityLine);

    // Add data points
    g.selectAll('.accuracy-point')
        .data(evolutionData)
        .enter()
        .append('circle')
        .attr('class', 'accuracy-point')
        .attr('cx', d => xScale(d.year))
        .attr('cy', d => yAccuracyScale(d.accuracy))
        .attr('r', 6)
        .attr('fill', '#6366f1')
        .attr('stroke', 'white')
        .attr('stroke-width', 2);

    // Add complexity points
    g.selectAll('.complexity-point')
        .data(evolutionData)
        .enter()
        .append('circle')
        .attr('class', 'complexity-point')
        .attr('cx', d => xScale(d.year))
        .attr('cy', d => yComplexityScale(d.complexity))
        .attr('r', 4)
        .attr('fill', '#8b5cf6')
        .attr('stroke', 'white')
        .attr('stroke-width', 1);

    // Add labels for key milestones
    g.selectAll('.milestone-label')
        .data(evolutionData.filter(d => d.year >= 2015))
        .enter()
        .append('text')
        .attr('class', 'milestone-label')
        .attr('x', d => xScale(d.year))
        .attr('y', d => yAccuracyScale(d.accuracy) - 15)
        .attr('text-anchor', 'middle')
        .attr('fill', 'white')
        .attr('font-size', '11px')
        .attr('font-weight', 'bold')
        .text(d => d.name);

    // Legend
    const legend = g.append('g')
        .attr('transform', `translate(${width - 150}, 20)`);

    legend.append('line')
        .attr('x1', 0)
        .attr('y1', 0)
        .attr('x2', 20)
        .attr('y2', 0)
        .attr('stroke', '#6366f1')
        .attr('stroke-width', 3);

    legend.append('text')
        .attr('x', 25)
        .attr('y', 5)
        .attr('fill', 'white')
        .attr('font-size', '12px')
        .text('Accuracy');

    legend.append('line')
        .attr('x1', 0)
        .attr('y1', 20)
        .attr('x2', 20)
        .attr('y2', 20)
        .attr('stroke', '#8b5cf6')
        .attr('stroke-width', 2)
        .attr('stroke-dasharray', '5,5');

    legend.append('text')
        .attr('x', 25)
        .attr('y', 25)
        .attr('fill', 'white')
        .attr('font-size', '12px')
        .text('Complexity');

    // Interactive tooltips
    g.selectAll('.accuracy-point')
        .on('mouseover', function(event, d) {
            showEvolutionTooltip(d, event);
        })
        .on('mouseout', function() {
            d3.select('.evolution-tooltip').remove();
        });
}

// NEUROSCIENCE INTEGRATION - Connecting Research with Data Science
function initializeNeuroscienceIntegration() {
    const container = document.getElementById('neuroscience-integration');
    if (!container) return;

    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(75, container.clientWidth / container.clientHeight, 0.1, 1000);
    const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });

    renderer.setSize(container.clientWidth, container.clientHeight);
    renderer.setClearColor(0x000000, 0);
    container.appendChild(renderer.domElement);

    // Create brain regions (neuroscience)
    const brainRegions = [
        { name: 'Prefrontal Cortex', position: [-2, 1, 0], color: 0x6366f1, size: 0.6 },
        { name: 'Hippocampus', position: [-1, -0.5, 0.5], color: 0x8b5cf6, size: 0.5 },
        { name: 'Amygdala', position: [1, -0.5, 0.5], color: 0x06b6d4, size: 0.4 }
    ];

    // Create data science concepts
    const dataConcepts = [
        { name: 'Machine Learning', position: [2, 1, 0], color: 0x059669, size: 0.6 },
        { name: 'Neural Networks', position: [1, -0.5, -0.5], color: 0x0d9488, size: 0.5 },
        { name: 'Big Data', position: [3, 0, 0], color: 0x0891b2, size: 0.7 }
    ];

    const allNodes = [...brainRegions, ...dataConcepts];
    const nodeObjects = [];

    // Create all nodes
    allNodes.forEach(node => {
        const geometry = new THREE.SphereGeometry(node.size, 16, 16);
        const material = new THREE.MeshPhongMaterial({
            color: node.color,
            transparent: true,
            opacity: 0.8
        });
        const sphere = new THREE.Mesh(geometry, material);
        sphere.position.set(...node.position);
        sphere.userData = { name: node.name, type: brainRegions.includes(node) ? 'neuroscience' : 'datascience' };
        scene.add(sphere);
        nodeObjects.push(sphere);

        // Gentle pulsing
        gsap.to(sphere.scale, {
            x: 1.1, y: 1.1, z: 1.1,
            duration: 2 + Math.random(),
            yoyo: true,
            repeat: -1,
            ease: 'power2.inOut'
        });
    });

    // Create integration connections
    for (let i = 0; i < brainRegions.length; i++) {
        for (let j = 0; j < dataConcepts.length; j++) {
            const points = [brainRegions[i].position, dataConcepts[j].position];
            const geometry = new THREE.BufferGeometry().setFromPoints(points);
            const material = new THREE.LineBasicMaterial({
                color: 0xffffff,
                transparent: true,
                opacity: 0.4,
                linewidth: 2
            });
            const line = new THREE.Line(geometry, material);
            scene.add(line);
        }
    }

    // Lighting
    const ambientLight = new THREE.AmbientLight(0x404040, 0.6);
    scene.add(ambientLight);

    const pointLight = new THREE.PointLight(0xffffff, 0.8);
    pointLight.position.set(0, 2, 2);
    scene.add(pointLight);

    camera.position.z = 6;

    // Animation loop
    function animate() {
        requestAnimationFrame(animate);
        scene.rotation.y += 0.003;
        renderer.render(scene, camera);
    }
    animate();

    // Educational tooltips
    container.addEventListener('click', (event) => {
        const mouse = new THREE.Vector2();
        mouse.x = (event.offsetX / container.clientWidth) * 2 - 1;
        mouse.y = -(event.offsetY / container.clientHeight) * 2 + 1;

        const raycaster = new THREE.Raycaster();
        raycaster.setFromCamera(mouse, camera);
        const intersects = raycaster.intersectObjects(nodeObjects);

        if (intersects.length > 0) {
            const node = intersects[0].object.userData;
            showIntegrationTooltip(node, event);
        }
    });
}

// EDUCATIONAL TOOLTIPS FOR STORYTELLING
function showPipelineTooltip(stage, event) {
    const tooltips = {
        'Extract': 'Data extraction from various sources including databases, APIs, and files. This stage involves data collection and initial validation.',
        'Transform': 'Data transformation including cleaning, normalization, aggregation, and feature engineering to prepare data for analysis.',
        'Load': 'Loading processed data into target systems such as data warehouses, databases, or analytics platforms for consumption.'
    };

    showTooltip(tooltips[stage], event, 'Pipeline Stage');
}

function showEvolutionTooltip(data, event) {
    const tooltip = d3.select('body')
        .append('div')
        .attr('class', 'evolution-tooltip')
        .style('position', 'absolute')
        .style('left', (event.pageX + 10) + 'px')
        .style('top', (event.pageY - 10) + 'px')
        .style('background', 'rgba(0, 0, 0, 0.9)')
        .style('color', 'white')
        .style('padding', '10px')
        .style('border-radius', '5px')
        .style('max-width', '250px')
        .style('z-index', '1000')
        .style('pointer-events', 'none')
        .html(`
            <h4>${data.name}</h4>
            <p>${data.description}</p>
            <p><strong>Year:</strong> ${data.year}</p>
            <p><strong>Accuracy:</strong> ${(data.accuracy * 100).toFixed(1)}%</p>
        `);

    setTimeout(() => tooltip.remove(), 3000);
}

function showIntegrationTooltip(node, event) {
    const neuroscienceTooltips = {
        'Prefrontal Cortex': 'Executive function and decision-making center, crucial for complex cognitive tasks and strategic planning.',
        'Hippocampus': 'Memory formation and spatial navigation, essential for learning and episodic memory.',
        'Amygdala': 'Emotional processing center, involved in fear response, emotional learning, and social behavior.'
    };

    const dataScienceTooltips = {
        'Machine Learning': 'Algorithms that learn patterns from data to make predictions and decisions without explicit programming.',
        'Neural Networks': 'Computational models inspired by biological neural networks, foundation of deep learning.',
        'Big Data': 'Large and complex datasets that require specialized tools and techniques for processing and analysis.'
    };

    const tooltips = node.type === 'neuroscience' ? neuroscienceTooltips : dataScienceTooltips;
    showTooltip(tooltips[node.name], event, node.name);
}

function showTooltip(content, event, title) {
    const existingTooltip = document.querySelector('.educational-tooltip');
    if (existingTooltip) existingTooltip.remove();

    const tooltip = document.createElement('div');
    tooltip.className = 'educational-tooltip';
    tooltip.innerHTML = `
        <h4>${title}</h4>
        <p>${content}</p>
        <button onclick="this.parentElement.remove()">×</button>
    `;

    tooltip.style.position = 'fixed';
    tooltip.style.left = event.pageX + 10 + 'px';
    tooltip.style.top = event.pageY - 10 + 'px';
    tooltip.style.background = 'rgba(0, 0, 0, 0.9)';
    tooltip.style.color = 'white';
    tooltip.style.padding = '15px';
    tooltip.style.borderRadius = '8px';
    tooltip.style.maxWidth = '300px';
    tooltip.style.zIndex = '1000';
    tooltip.style.boxShadow = '0 4px 12px rgba(0, 0, 0, 0.3)';

    document.body.appendChild(tooltip);

    setTimeout(() => {
        if (tooltip.parentElement) tooltip.remove();
    }, 5000);
}

// Initialize storytelling visualizations
initializeStorytellingVisualizations();

// EXPORT FUNCTIONS FOR GLOBAL ACCESS
window.diveIntoTopic = diveIntoTopic;
window.closeTopicModal = closeTopicModal;
window.redirectToTopic = redirectToTopic;

// SELECTIVE EDUCATIONAL VISUALIZATIONS
function initializeEducationalVisualizations() {
    // Only initialize visualizations that enhance learning
    if (document.getElementById('brain-3d')) {
        initializeSimpleBrainVisualization();
    }

    if (document.getElementById('data-flow-particles')) {
        initializeDataFlowParticles();
    }

    if (document.getElementById('neural-network-simple')) {
        initializeSimpleNeuralNetwork();
    }

    if (document.getElementById('knowledge-tree')) {
        initializeKnowledgeTree();
    }
}

// SIMPLE 3D BRAIN VISUALIZATION - Educational Tool
function initializeSimpleBrainVisualization() {
    const container = document.getElementById('brain-3d');
    if (!container) return;

    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(75, container.clientWidth / container.clientHeight, 0.1, 1000);
    const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });

    renderer.setSize(container.clientWidth, container.clientHeight);
    renderer.setClearColor(0x000000, 0);
    container.appendChild(renderer.domElement);

    // Create simplified brain regions
    const brainRegions = [
        { name: 'Prefrontal Cortex', position: [0, 1.5, 0], color: 0x6366f1, size: 0.8 },
        { name: 'Hippocampus', position: [-1, -0.5, 0.5], color: 0x8b5cf6, size: 0.6 },
        { name: 'Amygdala', position: [1, -0.5, 0.5], color: 0x06b6d4, size: 0.5 },
        { name: 'Visual Cortex', position: [0, 0, -1], color: 0x059669, size: 0.7 }
    ];

    const spheres = [];

    brainRegions.forEach(region => {
        const geometry = new THREE.SphereGeometry(region.size, 16, 16);
        const material = new THREE.MeshPhongMaterial({
            color: region.color,
            transparent: true,
            opacity: 0.8
        });
        const sphere = new THREE.Mesh(geometry, material);
        sphere.position.set(...region.position);
        sphere.userData = { name: region.name };
        scene.add(sphere);
        spheres.push(sphere);

        // Gentle pulsing animation
        gsap.to(sphere.scale, {
            x: 1.1, y: 1.1, z: 1.1,
            duration: 2 + Math.random(),
            yoyo: true,
            repeat: -1,
            ease: 'power2.inOut'
        });
    });

    // Simple connections
    for (let i = 0; i < spheres.length - 1; i++) {
        const points = [spheres[i].position, spheres[i + 1].position];
        const geometry = new THREE.BufferGeometry().setFromPoints(points);
        const material = new THREE.LineBasicMaterial({
            color: 0xffffff,
            transparent: true,
            opacity: 0.3
        });
        const line = new THREE.Line(geometry, material);
        scene.add(line);
    }

    // Lighting
    const ambientLight = new THREE.AmbientLight(0x404040, 0.6);
    scene.add(ambientLight);

    const pointLight = new THREE.PointLight(0xffffff, 0.8);
    pointLight.position.set(2, 2, 2);
    scene.add(pointLight);

    camera.position.z = 5;

    // Smooth rotation animation
    function animate() {
        requestAnimationFrame(animate);
        scene.rotation.y += 0.005;
        renderer.render(scene, camera);
    }
    animate();

    // Educational tooltips
    container.addEventListener('click', (event) => {
        const mouse = new THREE.Vector2();
        mouse.x = (event.offsetX / container.clientWidth) * 2 - 1;
        mouse.y = -(event.offsetY / container.clientHeight) * 2 + 1;

        const raycaster = new THREE.Raycaster();
        raycaster.setFromCamera(mouse, camera);
        const intersects = raycaster.intersectObjects(spheres);

        if (intersects.length > 0) {
            const region = intersects[0].object.userData.name;
            showEducationalTooltip(region, event);
        }
    });
}

// DATA FLOW PARTICLES - Learning Analytics Visualization
function initializeDataFlowParticles() {
    const container = document.getElementById('data-flow-particles');
    if (!container) return;

    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(75, container.clientWidth / container.clientHeight, 0.1, 1000);
    const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });

    renderer.setSize(container.clientWidth, container.clientHeight);
    renderer.setClearColor(0x000000, 0);
    container.appendChild(renderer.domElement);

    // Create data particles
    const particles = [];
    const particleCount = 50;

    for (let i = 0; i < particleCount; i++) {
        const geometry = new THREE.SphereGeometry(0.05, 8, 8);
        const material = new THREE.MeshBasicMaterial({
            color: new THREE.Color().setHSL(Math.random(), 0.7, 0.6)
        });
        const particle = new THREE.Mesh(geometry, material);

        particle.position.set(
            (Math.random() - 0.5) * 4,
            (Math.random() - 0.5) * 4,
            (Math.random() - 0.5) * 4
        );

        particle.velocity = new THREE.Vector3(
            (Math.random() - 0.5) * 0.02,
            (Math.random() - 0.5) * 0.02,
            (Math.random() - 0.5) * 0.02
        );

        scene.add(particle);
        particles.push(particle);
    }

    camera.position.z = 3;

    function animate() {
        requestAnimationFrame(animate);

        particles.forEach(particle => {
            particle.position.add(particle.velocity);

            // Boundary wrapping
            ['x', 'y', 'z'].forEach(axis => {
                if (particle.position[axis] > 2) particle.position[axis] = -2;
                if (particle.position[axis] < -2) particle.position[axis] = 2;
            });

            // Gentle rotation
            particle.rotation.x += 0.01;
            particle.rotation.y += 0.01;
        });

        renderer.render(scene, camera);
    }
    animate();
}

// SIMPLE NEURAL NETWORK - Educational Visualization
function initializeSimpleNeuralNetwork() {
    const svg = d3.select('#neural-network-simple')
        .append('svg')
        .attr('width', '100%')
        .attr('height', '300')
        .attr('viewBox', '0 0 600 300');

    // Simple 3-layer network
    const layers = [
        { nodes: 4, x: 100, label: 'Input' },
        { nodes: 6, x: 300, label: 'Hidden' },
        { nodes: 3, x: 500, label: 'Output' }
    ];

    const nodes = [];
    const links = [];

    // Create nodes
    layers.forEach(layer => {
        for (let i = 0; i < layer.nodes; i++) {
            const y = (i + 1) * (250 / (layer.nodes + 1)) + 25;
            nodes.push({
                id: `${layer.label}-${i}`,
                x: layer.x,
                y: y,
                layer: layer.label
            });
        }
    });

    // Create connections (sparse for clarity)
    for (let i = 0; i < layers.length - 1; i++) {
        const currentLayer = layers[i];
        const nextLayer = layers[i + 1];

        for (let j = 0; j < currentLayer.nodes; j++) {
            for (let k = 0; k < nextLayer.nodes; k++) {
                if (Math.random() > 0.6) {
                    links.push({
                        source: nodes.find(n => n.id === `${currentLayer.label}-${j}`),
                        target: nodes.find(n => n.id === `${nextLayer.label}-${k}`)
                    });
                }
            }
        }
    }

    // Draw connections
    svg.selectAll('line')
        .data(links)
        .enter()
        .append('line')
        .attr('x1', d => d.source.x)
        .attr('y1', d => d.source.y)
        .attr('x2', d => d.target.x)
        .attr('y2', d => d.target.y)
        .attr('stroke', 'rgba(255, 255, 255, 0.4)')
        .attr('stroke-width', 1);

    // Draw nodes
    svg.selectAll('circle')
        .data(nodes)
        .enter()
        .append('circle')
        .attr('cx', d => d.x)
        .attr('cy', d => d.y)
        .attr('r', 12)
        .attr('fill', d => {
            const colors = {
                'Input': '#6366f1',
                'Hidden': '#8b5cf6',
                'Output': '#059669'
            };
            return colors[d.layer];
        })
        .attr('stroke', 'rgba(255, 255, 255, 0.5)')
        .attr('stroke-width', 2);

    // Add labels
    svg.selectAll('text')
        .data(layers)
        .enter()
        .append('text')
        .attr('x', d => d.x)
        .attr('y', 20)
        .attr('text-anchor', 'middle')
        .attr('fill', 'white')
        .attr('font-size', '12px')
        .attr('font-weight', 'bold')
        .text(d => d.label);

    // Animate neural activity
    function animateNeuralActivity() {
        svg.selectAll('circle')
            .transition()
            .duration(1500)
            .attr('r', d => 12 + Math.random() * 4)
            .transition()
            .duration(1500)
            .attr('r', 12);
    }

    setInterval(animateNeuralActivity, 3000);
}

// KNOWLEDGE TREE - Interactive Learning Structure
function initializeKnowledgeTree() {
    const svg = d3.select('#knowledge-tree')
        .append('svg')
        .attr('width', '100%')
        .attr('height', '400')
        .attr('viewBox', '0 0 600 400');

    // Knowledge tree structure
    const treeData = {
        name: 'Data Science',
        children: [
            {
                name: 'Statistics',
                children: [
                    { name: 'Descriptive' },
                    { name: 'Inferential' },
                    { name: 'Bayesian' }
                ]
            },
            {
                name: 'Machine Learning',
                children: [
                    { name: 'Supervised' },
                    { name: 'Unsupervised' },
                    { name: 'Deep Learning' }
                ]
            },
            {
                name: 'Visualization',
                children: [
                    { name: 'Charts' },
                    { name: 'Dashboards' },
                    { name: 'Interactive' }
                ]
            }
        ]
    };

    const root = d3.hierarchy(treeData);
    const treeLayout = d3.tree().size([500, 300]);
    treeLayout(root);

    // Draw links
    svg.selectAll('line')
        .data(root.links())
        .enter()
        .append('line')
        .attr('x1', d => d.source.x + 50)
        .attr('y1', d => d.source.y + 50)
        .attr('x2', d => d.target.x + 50)
        .attr('y2', d => d.target.y + 50)
        .attr('stroke', 'rgba(255, 255, 255, 0.6)')
        .attr('stroke-width', 2);

    // Draw nodes
    const nodes = svg.selectAll('circle')
        .data(root.descendants())
        .enter()
        .append('circle')
        .attr('cx', d => d.x + 50)
        .attr('cy', d => d.y + 50)
        .attr('r', d => d.children ? 20 : 15)
        .attr('fill', d => d.children ? '#6366f1' : '#8b5cf6')
        .attr('stroke', 'white')
        .attr('stroke-width', 2);

    // Add labels
    svg.selectAll('text')
        .data(root.descendants())
        .enter()
        .append('text')
        .attr('x', d => d.x + 50)
        .attr('y', d => d.y + 35)
        .attr('text-anchor', 'middle')
        .attr('fill', 'white')
        .attr('font-size', '11px')
        .attr('font-weight', 'bold')
        .text(d => d.data.name);

    // Interactive hover effects
    nodes.on('mouseover', function(event, d) {
        d3.select(this)
            .transition()
            .duration(200)
            .attr('r', d.children ? 25 : 20)
            .attr('fill', '#f39c12');
    });

    nodes.on('mouseout', function(event, d) {
        d3.select(this)
            .transition()
            .duration(200)
            .attr('r', d.children ? 20 : 15)
            .attr('fill', d.children ? '#6366f1' : '#8b5cf6');
    });
}

// EDUCATIONAL TOOLTIPS
function showEducationalTooltip(region, event) {
    // Remove existing tooltip
    const existingTooltip = document.querySelector('.educational-tooltip');
    if (existingTooltip) existingTooltip.remove();

    const tooltips = {
        'Prefrontal Cortex': 'Responsible for executive functions, decision-making, and complex cognitive behaviors.',
        'Hippocampus': 'Critical for learning, memory formation, and spatial navigation.',
        'Amygdala': 'Processes emotions, particularly fear and emotional responses.',
        'Visual Cortex': 'Primary area for processing visual information from the eyes.'
    };

    const tooltip = document.createElement('div');
    tooltip.className = 'educational-tooltip';
    tooltip.innerHTML = `
        <h4>${region}</h4>
        <p>${tooltips[region]}</p>
        <button onclick="this.parentElement.remove()">×</button>
    `;

    tooltip.style.position = 'fixed';
    tooltip.style.left = event.pageX + 10 + 'px';
    tooltip.style.top = event.pageY - 10 + 'px';
    tooltip.style.background = 'rgba(0, 0, 0, 0.9)';
    tooltip.style.color = 'white';
    tooltip.style.padding = '10px';
    tooltip.style.borderRadius = '5px';
    tooltip.style.maxWidth = '200px';
    tooltip.style.zIndex = '1000';

    document.body.appendChild(tooltip);

    // Auto-remove after 5 seconds
    setTimeout(() => {
        if (tooltip.parentElement) tooltip.remove();
    }, 5000);
}
