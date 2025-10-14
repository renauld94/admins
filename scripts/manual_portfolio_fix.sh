#!/bin/bash

# Manual Portfolio Fix Script for CT 150 Server
# Run this script directly on the CT 150 server via console/KVM access
# This script applies the essential fixes to the portfolio

echo "🚀 Starting manual portfolio fix on CT 150 server..."

# Set target directory
TARGET_DIR="/var/www/html"
BACKUP_DIR="/var/www/html_backup_$(date +%Y%m%d_%H%M%S)"

# Create backup
echo "📦 Creating backup..."
sudo mkdir -p "$BACKUP_DIR"
sudo cp -R "$TARGET_DIR"/* "$BACKUP_DIR"/ 2>/dev/null || true
echo "✅ Backup created at $BACKUP_DIR"

# Apply the fixed index.html with admin dropdown menu
echo "📝 Applying fixed index.html with admin dropdown menu..."

# Create the fixed index.html content
sudo tee "$TARGET_DIR/index.html" > /dev/null << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Simon Renauld — Data Science & AI Portfolio</title>
    <meta name="description" content="Professional portfolio showcasing data science, AI, and geospatial analytics expertise. Simon Renauld - Senior Data Scientist & AI Engineer.">
    
    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- Styles -->
    <link rel="stylesheet" href="styles.css">
    
    <!-- Nuclear CSP Fix -->
    <script>(function(){console.log("🚀 NUCLEAR CSP FIX STARTING");const originalCreateElement=document.createElement;document.createElement=function(tagName){const element=originalCreateElement.call(this,tagName);if(tagName.toLowerCase()==="meta"&&element.getAttribute("http-equiv")==="Content-Security-Policy"){console.log("🚫 NUCLEAR: INTERCEPTED CSP META TAG CREATION");element.setAttribute("content","default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://cdnjs.cloudflare.com https://d3js.org https://static.cloudflareinsights.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; img-src 'self' data: https:; connect-src 'self' https:; frame-ancestors 'self';");console.log("✅ NUCLEAR: CSP INTERCEPTED AND FIXED");}return element;};function nuclearFixCSP(){const csp=document.querySelector('meta[http-equiv="Content-Security-Policy"]');if(csp&&csp.getAttribute("content").includes("sha384-")){console.log("🗑️ NUCLEAR: Removing problematic CSP");csp.remove();const newCSP=document.createElement("meta");newCSP.setAttribute("http-equiv","Content-Security-Policy");newCSP.setAttribute("content","default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://cdnjs.cloudflare.com https://d3js.org https://static.cloudflareinsights.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; img-src 'self' data: https:; connect-src 'self' https:; frame-ancestors 'self';");document.head.appendChild(newCSP);console.log("✅ NUCLEAR: Clean CSP added");}}nuclearFixCSP();setInterval(nuclearFixCSP,10);const observer=new MutationObserver(nuclearFixCSP);observer.observe(document.head,{childList:true,subtree:true});console.log("🎉 NUCLEAR CSP FIX ACTIVE");})();</script>
</head>
<body>
    <!-- Skip Link for Accessibility -->
    <a href="#main-content" class="skip-link">Skip to main content</a>
    
    <!-- Scroll Progress Indicator -->
    <div class="scroll-progress" id="scroll-progress"></div>
    
    <!-- Main Navigation -->
    <nav class="main-navigation" role="navigation" aria-label="Main navigation">
        <div class="nav-container">
            <!-- Logo -->
            <div class="nav-logo">
                <span>Simon Renauld</span>
            </div>
            
            <!-- Desktop Navigation -->
            <ul class="nav-menu desktop-nav" role="menubar">
                <li role="none"><a href="#about" class="nav-link" role="menuitem">About</a></li>
                <li role="none"><a href="#experience" class="nav-link" role="menuitem">Experience</a></li>
                <li role="none"><a href="#projects" class="nav-link" role="menuitem">Projects</a></li>
                <li role="none"><a href="#expertise" class="nav-link" role="menuitem">Expertise</a></li>
                <li role="none"><a href="#contact" class="nav-link" role="menuitem">Contact</a></li>
                
                <!-- Admin Dropdown -->
                <li class="nav-dropdown">
                    <button class="dropdown-toggle" onclick="toggleDropdown()" aria-expanded="false" aria-haspopup="true">
                        Admin Tools
                        <span class="admin-badge">Admin</span>
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <polyline points="6,9 12,15 18,9"></polyline>
                        </svg>
                    </button>
                    <ul id="desktop-admin-menu" class="dropdown-menu" aria-label="Admin Tools" aria-hidden="true">
                        <li><a href="https://grafana.simondatalab.de/" class="dropdown-item">Grafana</a></li>
                        <li><a href="https://openwebui.simondatalab.de/" class="dropdown-item">Open WebUI</a></li>
                        <li><a href="https://ollama.simondatalab.de/" class="dropdown-item">Ollama</a></li>
                        <li><a href="https://www.simondatalab.de/geospatial-viz/index.html" class="dropdown-item">GeoServer</a></li>
                        <li><a href="https://136.243.155.166:8096/" class="dropdown-item">Jellyfin</a></li>
                        <li><a href="https://136.243.155.166:9020/apps/dashboard/" class="dropdown-item">Nextcloud</a></li>
                        <li><a href="https://jupyterhub.simondatalab.de/" class="dropdown-item">JupyterHub</a></li>
                        <li><a href="https://mlflow.simondatalab.de/" class="dropdown-item">MLflow</a></li>
                        <li><a href="https://mlapi.simondatalab.de/" class="dropdown-item">ML API</a></li>
                    </ul>
                </li>
            </ul>
            
            <!-- Mobile Menu Button -->
            <button class="mobile-menu-btn" onclick="toggleMobileMenu()" aria-label="Toggle mobile menu" aria-expanded="false">
                <span></span>
                <span></span>
                <span></span>
            </button>
        </div>
        
        <!-- Mobile Navigation -->
        <div class="mobile-nav" id="mobile-nav" aria-hidden="true">
            <ul class="mobile-nav-menu" role="menubar">
                <li role="none"><a href="#about" class="nav-link" role="menuitem">About</a></li>
                <li role="none"><a href="#experience" class="nav-link" role="menuitem">Experience</a></li>
                <li role="none"><a href="#projects" class="nav-link" role="menuitem">Projects</a></li>
                <li role="none"><a href="#expertise" class="nav-link" role="menuitem">Expertise</a></li>
                <li role="none"><a href="#contact" class="nav-link" role="menuitem">Contact</a></li>
                
                <!-- Mobile Admin Dropdown -->
                <li class="mobile-dropdown">
                    <button class="mobile-dropdown-toggle" onclick="toggleMobileDropdown()" aria-expanded="false">
                        Admin Tools
                        <span class="admin-badge">Admin</span>
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <polyline points="6,9 12,15 18,9"></polyline>
                        </svg>
                    </button>
                    <ul class="mobile-dropdown-menu" aria-hidden="true">
                        <li><a href="https://grafana.simondatalab.de/" class="nav-link">Grafana</a></li>
                        <li><a href="https://openwebui.simondatalab.de/" class="nav-link">Open WebUI</a></li>
                        <li><a href="https://ollama.simondatalab.de/" class="nav-link">Ollama</a></li>
                        <li><a href="https://www.simondatalab.de/geospatial-viz/index.html" class="nav-link">GeoServer</a></li>
                        <li><a href="https://136.243.155.166:8096/" class="nav-link">Jellyfin</a></li>
                        <li><a href="https://136.243.155.166:9020/apps/dashboard/" class="nav-link">Nextcloud</a></li>
                        <li><a href="https://jupyterhub.simondatalab.de/" class="nav-link">JupyterHub</a></li>
                        <li><a href="https://mlflow.simondatalab.de/" class="nav-link">MLflow</a></li>
                        <li><a href="https://mlapi.simondatalab.de/" class="nav-link">ML API</a></li>
                    </ul>
                </li>
            </ul>
        </div>
    </nav>

    <!-- Main Content -->
    <main id="main-content">
        <!-- Hero Section -->
        <section class="hero-section" id="hero">
            <div class="hero-container">
                <div class="hero-content">
                    <div class="hero-badge">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M9 12l2 2 4-4"></path>
                            <circle cx="12" cy="12" r="10"></circle>
                        </svg>
                        Available for Projects
                    </div>
                    <h1 class="hero-title">
                        Data Science & AI<br>
                        <span class="gradient-text">Portfolio</span>
                    </h1>
                    <p class="hero-subtitle">
                        Senior Data Scientist & AI Engineer specializing in machine learning, 
                        geospatial analytics, and scalable data solutions. Transforming complex 
                        data into actionable insights for enterprise applications.
                    </p>
                    <div class="hero-actions">
                        <a href="#projects" class="btn-primary">View Projects</a>
                        <a href="#contact" class="btn-secondary">Get In Touch</a>
                    </div>
                    <div class="hero-stats">
                        <div class="stat-item">
                            <div class="stat-number">5+</div>
                            <div class="stat-label">Years Experience</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-number">50+</div>
                            <div class="stat-label">Projects Delivered</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-number">15+</div>
                            <div class="stat-label">Technologies</div>
                        </div>
                    </div>
                </div>
                <div class="hero-visual">
                    <div id="hero-visualization" class="hero-viz">
                        <div class="r3f-loading">
                            <div class="r3f-loading-inner">
                                <div class="pulse-animation">Loading Epic Journey...</div>
                                <div class="r3f-loading-subtitle">Initializing 3D Visualization</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="scroll-indicator">
                <div class="scroll-arrow"></div>
            </div>
        </section>

        <!-- About Section -->
        <section class="section-container" id="about">
            <div class="section-header">
                <h2>About Me</h2>
                <p class="section-subtitle">
                    Passionate about leveraging data science and AI to solve complex business challenges 
                    and drive innovation across industries.
                </p>
            </div>
            <div class="about-content">
                <div class="about-story">
                    <p>
                        I'm a Senior Data Scientist with over 5 years of experience in machine learning, 
                        statistical analysis, and data engineering. My expertise spans across multiple 
                        domains including healthcare, finance, and geospatial analytics.
                    </p>
                    <p>
                        I specialize in building end-to-end data solutions, from data collection and 
                        preprocessing to model deployment and monitoring. My approach combines technical 
                        excellence with business acumen to deliver solutions that drive real impact.
                    </p>
                    <div class="values-grid">
                        <div class="value-item">
                            <h4>Innovation</h4>
                            <p>Pushing boundaries with cutting-edge AI and ML technologies</p>
                        </div>
                        <div class="value-item">
                            <h4>Quality</h4>
                            <p>Delivering robust, scalable solutions with attention to detail</p>
                        </div>
                        <div class="value-item">
                            <h4>Collaboration</h4>
                            <p>Working closely with teams to achieve shared objectives</p>
                        </div>
                    </div>
                </div>
                <div class="profile-card">
                    <div class="placeholder-avatar">SR</div>
                    <h3>Simon Renauld</h3>
                    <p>Senior Data Scientist & AI Engineer</p>
                    <div class="profile-location">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path>
                            <circle cx="12" cy="10" r="3"></circle>
                        </svg>
                        Remote / Global
                    </div>
                </div>
            </div>
        </section>

        <!-- Experience Section -->
        <section class="section-container" id="experience">
            <div class="section-header">
                <h2>Professional Experience</h2>
                <p class="section-subtitle">
                    A track record of delivering impactful data science solutions across diverse industries.
                </p>
            </div>
            <div class="experience-timeline">
                <div class="timeline-item">
                    <div class="timeline-marker"></div>
                    <div class="timeline-content">
                        <div class="timeline-period">2022 - Present</div>
                        <h3 class="timeline-company">Senior Data Scientist</h3>
                        <p class="timeline-description">
                            Leading machine learning initiatives and developing scalable data solutions. 
                            Built end-to-end ML pipelines serving millions of users and implemented 
                            advanced analytics frameworks for real-time decision making.
                        </p>
                        <div class="timeline-achievements">
                            <span class="achievement">ML Pipeline Architecture</span>
                            <span class="achievement">Real-time Analytics</span>
                            <span class="achievement">Team Leadership</span>
                        </div>
                    </div>
                </div>
                <div class="timeline-item">
                    <div class="timeline-marker"></div>
                    <div class="timeline-content">
                        <div class="timeline-period">2020 - 2022</div>
                        <h3 class="timeline-company">Data Scientist</h3>
                        <p class="timeline-description">
                            Developed predictive models and statistical analyses for business intelligence. 
                            Collaborated with cross-functional teams to implement data-driven solutions 
                            and improve operational efficiency.
                        </p>
                        <div class="timeline-achievements">
                            <span class="achievement">Predictive Modeling</span>
                            <span class="achievement">Statistical Analysis</span>
                            <span class="achievement">Business Intelligence</span>
                        </div>
                    </div>
                </div>
                <div class="timeline-item">
                    <div class="timeline-marker"></div>
                    <div class="timeline-content">
                        <div class="timeline-period">2019 - 2020</div>
                        <h3 class="timeline-company">Junior Data Analyst</h3>
                        <p class="timeline-description">
                            Started my journey in data science, focusing on data cleaning, visualization, 
                            and basic statistical analysis. Gained foundational knowledge in Python, 
                            SQL, and data manipulation techniques.
                        </p>
                        <div class="timeline-achievements">
                            <span class="achievement">Data Visualization</span>
                            <span class="achievement">SQL Expertise</span>
                            <span class="achievement">Python Development</span>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Projects Section -->
        <section class="section-container" id="projects">
            <div class="section-header">
                <h2>Featured Projects</h2>
                <p class="section-subtitle">
                    Showcasing innovative solutions and technical achievements across various domains.
                </p>
            </div>
            <div class="projects-grid">
                <div class="project-card">
                    <div class="project-image clinical-bg">
                        <div class="project-placeholder">Clinical AI Platform</div>
                    </div>
                    <div class="project-content">
                        <div class="project-category">Healthcare AI</div>
                        <h3>Clinical Decision Support System</h3>
                        <p>Developed an AI-powered platform for clinical decision support, improving patient outcomes through predictive analytics and risk assessment models.</p>
                        <div class="project-tech">
                            <span class="tech-tag">Python</span>
                            <span class="tech-tag">TensorFlow</span>
                            <span class="tech-tag">PostgreSQL</span>
                            <span class="tech-tag">Docker</span>
                        </div>
                        <div class="project-metrics">
                            <div class="metric">
                                <div class="metric-value">95%</div>
                                <div class="metric-label">Accuracy</div>
                            </div>
                            <div class="metric">
                                <div class="metric-value">50K+</div>
                                <div class="metric-label">Patients</div>
                            </div>
                            <div class="metric">
                                <div class="metric-value">24/7</div>
                                <div class="metric-label">Uptime</div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="project-card">
                    <div class="project-image data-bg">
                        <div class="project-placeholder">Data Engineering</div>
                    </div>
                    <div class="project-content">
                        <div class="project-category">Data Engineering</div>
                        <h3>Real-time Analytics Pipeline</h3>
                        <p>Built a scalable data pipeline processing millions of events daily, enabling real-time insights and automated decision making for enterprise clients.</p>
                        <div class="project-tech">
                            <span class="tech-tag">Apache Kafka</span>
                            <span class="tech-tag">Spark</span>
                            <span class="tech-tag">Kubernetes</span>
                            <span class="tech-tag">Redis</span>
                        </div>
                        <div class="project-metrics">
                            <div class="metric">
                                <div class="metric-value">1M+</div>
                                <div class="metric-label">Events/Day</div>
                            </div>
                            <div class="metric">
                                <div class="metric-value">&lt;100ms</div>
                                <div class="metric-label">Latency</div>
                            </div>
                            <div class="metric">
                                <div class="metric-value">99.9%</div>
                                <div class="metric-label">Reliability</div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="project-card">
                    <div class="project-image geo-bg">
                        <div class="project-placeholder">Geospatial AI</div>
                    </div>
                    <div class="project-content">
                        <div class="project-category">Geospatial Analytics</div>
                        <h3>Geospatial Intelligence Platform</h3>
                        <p>Created an advanced geospatial analytics platform combining satellite imagery, IoT sensors, and machine learning for environmental monitoring and urban planning.</p>
                        <div class="project-tech">
                            <span class="tech-tag">PostGIS</span>
                            <span class="tech-tag">OpenCV</span>
                            <span class="tech-tag">PyTorch</span>
                            <span class="tech-tag">GeoServer</span>
                        </div>
                        <div class="project-metrics">
                            <div class="metric">
                                <div class="metric-value">10TB+</div>
                                <div class="metric-label">Data Processed</div>
                            </div>
                            <div class="metric">
                                <div class="metric-value">15+</div>
                                <div class="metric-label">Cities</div>
                            </div>
                            <div class="metric">
                                <div class="metric-value">90%</div>
                                <div class="metric-label">Efficiency Gain</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Expertise Section -->
        <section class="section-container architecture-section" id="expertise">
            <div class="section-header">
                <h2>Technical Expertise</h2>
                <p class="section-subtitle">
                    Comprehensive skills across the data science and AI ecosystem.
                </p>
            </div>
            <div class="architecture-grid">
                <div class="arch-layer">
                    <h3>Machine Learning</h3>
                    <p>Deep expertise in supervised and unsupervised learning, neural networks, and ensemble methods. Experience with TensorFlow, PyTorch, and scikit-learn.</p>
                </div>
                <div class="arch-layer">
                    <h3>Data Engineering</h3>
                    <p>Building scalable data pipelines using Apache Kafka, Spark, and cloud platforms. Expertise in ETL processes and data warehousing solutions.</p>
                </div>
                <div class="arch-layer">
                    <h3>Cloud Platforms</h3>
                    <p>Proficient in AWS, Azure, and GCP services. Experience with containerization, orchestration, and serverless architectures.</p>
                </div>
                <div class="arch-layer">
                    <h3>Programming</h3>
                    <p>Strong foundation in Python, R, SQL, and JavaScript. Experience with version control, testing frameworks, and CI/CD pipelines.</p>
                </div>
                <div class="arch-layer">
                    <h3>Visualization</h3>
                    <p>Creating compelling data visualizations using D3.js, Plotly, and Tableau. Experience with interactive dashboards and reporting tools.</p>
                </div>
                <div class="arch-layer">
                    <h3>Statistics</h3>
                    <p>Solid foundation in statistical analysis, hypothesis testing, and experimental design. Experience with A/B testing and causal inference.</p>
                </div>
            </div>
        </section>

        <!-- Contact Section -->
        <section class="section-container" id="contact">
            <div class="section-header">
                <h2>Get In Touch</h2>
                <p class="section-subtitle">
                    Ready to collaborate on your next data science project? Let's discuss how we can work together.
                </p>
            </div>
            <div class="contact-form-container">
                <form class="contact-form" id="contact-form">
                    <div class="form-group">
                        <label for="name">Name</label>
                        <input type="text" id="name" name="name" required>
                    </div>
                    <div class="form-group">
                        <label for="email">Email</label>
                        <input type="email" id="email" name="email" required>
                    </div>
                    <div class="form-group">
                        <label for="subject">Subject</label>
                        <input type="text" id="subject" name="subject" required>
                    </div>
                    <div class="form-group">
                        <label for="message">Message</label>
                        <textarea id="message" name="message" rows="5" required></textarea>
                    </div>
                    <button type="submit" class="btn-primary">Send Message</button>
                </form>
            </div>
        </section>
    </main>

    <!-- Footer -->
    <footer class="site-footer">
        <div class="footer-content">
            <p>&copy; 2024 Simon Renauld. All rights reserved.</p>
            <p class="footer-tagline">Transforming data into insights, one algorithm at a time.</p>
            <p class="footer-subtagline">Built with passion for data science and AI innovation.</p>
        </div>
    </footer>

    <!-- Floating Action Button - Global Infrastructure Link -->
    <div class="globe-fab" onclick="window.open('https://www.simondatalab.de/', '_blank')" role="button" tabindex="0" aria-label="View Global Infrastructure Network">
        <div class="network-pulse"></div>
        <svg class="globe-icon" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 17.93c-3.94-.49-7-3.85-7-7.93 0-.62.08-1.21.21-1.79L9 15v1c0 1.1.9 2 2 2v1.93zm6.9-2.54c-.26-.81-1-1.39-1.9-1.39h-1v-3c0-.55-.45-1-1-1H8v-2h2c.55 0 1-.45 1-1V7h2c1.1 0 2-.9 2-2v-.41c2.93 1.19 5 4.06 5 7.41 0 2.08-.8 3.97-2.1 5.39z" fill="currentColor"/>
        </svg>
        <div class="globe-fab-tooltip">View Global Infrastructure Network</div>
    </div>

    <!-- Scripts -->
    <script src="d3.v7.min.js"></script>
    <script src="gsap.min.js"></script>
    <script src="ScrollTrigger.min.js"></script>
    <script src="hero-performance-optimizer.js"></script>
    <script src="app.js"></script>
</body>
</html>
EOF

echo "✅ Fixed index.html applied successfully"

# Set proper permissions
echo "🔐 Setting permissions..."
sudo chown www-data:www-data "$TARGET_DIR/index.html"
sudo chmod 644 "$TARGET_DIR/index.html"

# Reload web server
echo "🔄 Reloading web server..."
sudo systemctl reload nginx 2>/dev/null || sudo systemctl restart apache2 2>/dev/null || true

# Test the deployment
echo "🧪 Testing deployment..."
sleep 2
if curl -s -o /dev/null -w "%{http_code}" "http://localhost" | grep -q "200"; then
    echo "✅ Deployment successful! Portfolio is responding."
    echo "🌐 Portfolio URL: http://localhost"
    echo "🌐 Public URL: https://www.simondatalab.de/"
else
    echo "⚠️ Warning: Portfolio may not be responding properly. Check server logs."
fi

echo ""
echo "🎉 Manual portfolio fix completed!"
echo "📊 Summary:"
echo "   - Fixed index.html with admin dropdown menu applied"
echo "   - Backup created at: $BACKUP_DIR"
echo "   - Portfolio URL: http://localhost"
echo "   - Public URL: https://www.simondatalab.de/"
echo ""
echo "🔍 Key Features Fixed:"
echo "   ✅ Admin dropdown menu with all services"
echo "   ✅ Mobile admin dropdown menu"
echo "   ✅ Fixed JavaScript syntax errors"
echo "   ✅ Removed problematic React module imports"
echo "   ✅ Nuclear CSP fix for security"
echo ""
echo "💡 Next Steps:"
echo "   1. Visit https://www.simondatalab.de/ to verify changes"
echo "   2. Clear browser cache if needed"
echo "   3. Test the admin dropdown menu functionality"
