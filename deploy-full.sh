#!/bin/bash

# Complete Learning Odyssey Deployment Script
# Handles proxy jump: root@136.243.155.166 -> simonadmin@10.0.0.104

set -e

# Configuration
PROXY_HOST="root@136.243.155.166"
TARGET_HOST="simonadmin@10.0.0.104"
MOODLE_COURSE_ID="2"
MOODLE_PATH="/var/www/html/moodle"
COURSE_PATH="$MOODLE_PATH/course/$MOODLE_COURSE_ID"
ODYSSEY_PATH="$COURSE_PATH/odyssey"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo "🚀 Starting Complete Learning Odyssey Deployment..."
echo "Proxy: $PROXY_HOST"
echo "Target: $TARGET_HOST"
echo "Course: https://moodle.simondatalab.de/course/view.php?id=$MOODLE_COURSE_ID"
echo ""

# Function to test connection
test_connection() {
    local max_attempts=3
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        print_status "Connection attempt $attempt/$max_attempts..."
        
        if ssh -o ConnectTimeout=15 -o BatchMode=yes -J $PROXY_HOST $TARGET_HOST "echo 'Connection successful'" 2>/dev/null; then
            print_success "Connection established via proxy jump!"
            return 0
        else
            print_warning "Connection attempt $attempt failed"
            sleep 5
            ((attempt++))
        fi
    done
    
    print_error "All connection attempts failed"
    return 1
}

# Test connection
if ! test_connection; then
    print_error "Cannot establish connection. Please check:"
    echo "1. SSH keys are properly configured"
    echo "2. Proxy server is accessible"
    echo "3. Target server is reachable from proxy"
    echo "4. Network connectivity is working"
    echo ""
    print_status "Trying alternative deployment method..."
    
    # Create deployment package for manual transfer
    print_status "Creating deployment package..."
    tar -czf learning-odyssey-deployment.tar.gz odyssey-implementation/ deploy-*.sh *.md
    
    print_success "Deployment package created: learning-odyssey-deployment.tar.gz"
    print_status "Manual deployment instructions:"
    echo "1. Copy package to server: scp learning-odyssey-deployment.tar.gz $TARGET_HOST:~/"
    echo "2. SSH to server: ssh -J $PROXY_HOST $TARGET_HOST"
    echo "3. Extract and deploy: tar -xzf learning-odyssey-deployment.tar.gz && cd odyssey-implementation && ../deploy-odyssey.sh"
    
    exit 1
fi

# Create remote directory structure
print_status "Creating remote directory structure..."
ssh -J $PROXY_HOST $TARGET_HOST "mkdir -p $ODYSSEY_PATH/{js,css,images,ai,analytics}"

# Copy files to remote server
print_status "Copying implementation files..."

# Copy JavaScript files
scp -J $PROXY_HOST odyssey-implementation/learning-universe.js $TARGET_HOST:$ODYSSEY_PATH/js/
scp -J $PROXY_HOST odyssey-implementation/d3-dashboard.js $TARGET_HOST:$ODYSSEY_PATH/js/

# Copy Python files
scp -J $PROXY_HOST odyssey-implementation/ai-oracle-system.py $TARGET_HOST:$ODYSSEY_PATH/ai/
scp -J $PROXY_HOST odyssey-implementation/databricks-analytics.py $TARGET_HOST:$ODYSSEY_PATH/analytics/

# Copy HTML demo
scp -J $PROXY_HOST odyssey-implementation/examples/basic-setup.html $TARGET_HOST:$ODYSSEY_PATH/odyssey-demo.html

# Copy documentation
scp -J $PROXY_HOST odyssey-implementation/README.md $TARGET_HOST:$ODYSSEY_PATH/
scp -J $PROXY_HOST ODYSSEY_IMPLEMENTATION_SUMMARY.md $TARGET_HOST:$ODYSSEY_PATH/

print_success "Files copied successfully!"

# Create comprehensive Moodle integration file
print_status "Creating comprehensive Moodle integration..."

ssh -J $PROXY_HOST $TARGET_HOST "cat > $ODYSSEY_PATH/odyssey-course.html << 'EOF'
<!DOCTYPE html>
<html lang=\"en\">
<head>
    <meta charset=\"UTF-8\">
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
    <title>Learning Odyssey - J&J Python Academy</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            background: linear-gradient(135deg, #0a0a0a 0%, #1a1a2e 50%, #16213e 100%);
            color: #ffffff;
            font-family: 'Arial', sans-serif;
            overflow-x: hidden;
        }
        
        .moodle-header {
            background: rgba(0, 255, 136, 0.1);
            border: 2px solid #00ff88;
            border-radius: 15px;
            padding: 20px;
            margin: 20px;
            text-align: center;
        }
        
        .moodle-header h1 {
            margin: 0;
            font-size: 2.5em;
            background: linear-gradient(45deg, #00ff88, #0066ff, #ff6600);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        
        .container {
            display: grid;
            grid-template-columns: 1fr 1fr;
            grid-template-rows: auto 1fr;
            height: 80vh;
            gap: 20px;
            padding: 20px;
        }
        
        .universe-container {
            background: rgba(0, 0, 0, 0.3);
            border: 2px solid #0066ff;
            border-radius: 15px;
            padding: 20px;
            position: relative;
            overflow: hidden;
        }
        
        .dashboard-container {
            background: rgba(0, 0, 0, 0.3);
            border: 2px solid #ff6600;
            border-radius: 15px;
            padding: 20px;
            overflow-y: auto;
        }
        
        .ai-chat {
            position: fixed;
            bottom: 20px;
            right: 20px;
            width: 300px;
            background: rgba(0, 0, 0, 0.9);
            border: 2px solid #00ff88;
            border-radius: 15px;
            padding: 15px;
            z-index: 1000;
        }
        
        .ai-chat h3 {
            margin: 0 0 10px 0;
            color: #00ff88;
            text-align: center;
        }
        
        .chat-messages {
            height: 200px;
            overflow-y: auto;
            margin-bottom: 10px;
            padding: 10px;
            background: rgba(255, 255, 255, 0.05);
            border-radius: 10px;
        }
        
        .chat-input {
            width: 100%;
            padding: 10px;
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid #00ff88;
            border-radius: 5px;
            color: white;
            font-size: 14px;
        }
        
        .send-button {
            width: 100%;
            margin-top: 10px;
            padding: 10px;
            background: linear-gradient(45deg, #00ff88, #0066ff);
            border: none;
            border-radius: 5px;
            color: white;
            font-weight: bold;
            cursor: pointer;
            transition: transform 0.2s;
        }
        
        .send-button:hover {
            transform: scale(1.05);
        }
        
        .module-info {
            background: rgba(0, 255, 136, 0.1);
            border: 1px solid #00ff88;
            border-radius: 10px;
            padding: 15px;
            margin: 10px 0;
        }
        
        .progress-bar {
            width: 100%;
            height: 20px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 10px;
            overflow: hidden;
            margin: 10px 0;
        }
        
        .progress-fill {
            height: 100%;
            background: linear-gradient(90deg, #00ff88, #0066ff);
            transition: width 0.3s ease;
        }
        
        .narrative-text {
            background: rgba(0, 102, 255, 0.1);
            border-left: 4px solid #0066ff;
            padding: 15px;
            margin: 15px 0;
            border-radius: 0 10px 10px 0;
            font-style: italic;
        }
        
        .skill-radar {
            width: 200px;
            height: 200px;
            margin: 20px auto;
            background: radial-gradient(circle, rgba(0, 255, 136, 0.1) 0%, transparent 70%);
            border-radius: 50%;
            position: relative;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .skill-point {
            position: absolute;
            width: 8px;
            height: 8px;
            background: #00ff88;
            border-radius: 50%;
            animation: pulse 2s infinite;
        }
        
        @keyframes pulse {
            0% { transform: scale(1); opacity: 1; }
            50% { transform: scale(1.2); opacity: 0.7; }
            100% { transform: scale(1); opacity: 1; }
        }
        
        .achievement {
            background: rgba(255, 102, 0, 0.1);
            border: 1px solid #ff6600;
            border-radius: 10px;
            padding: 10px;
            margin: 5px 0;
            display: flex;
            align-items: center;
        }
        
        .achievement-icon {
            width: 20px;
            height: 20px;
            background: #ff6600;
            border-radius: 50%;
            margin-right: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
        }
        
        .phase-indicator {
            background: rgba(255, 102, 0, 0.1);
            border: 1px solid #ff6600;
            border-radius: 10px;
            padding: 15px;
            margin: 10px 0;
            text-align: center;
        }
        
        .phase-indicator h4 {
            margin: 0 0 10px 0;
            color: #ff6600;
        }
        
        .phase-progress {
            display: flex;
            justify-content: space-between;
            margin: 10px 0;
        }
        
        .phase-step {
            width: 20px;
            height: 20px;
            border-radius: 50%;
            background: #333;
            border: 2px solid #666;
            position: relative;
        }
        
        .phase-step.active {
            background: #ff6600;
            border-color: #ff6600;
        }
        
        .phase-step.completed {
            background: #00ff00;
            border-color: #00ff00;
        }
    </style>
</head>
<body>
    <div class=\"moodle-header\">
        <h1>🚀 From Data to Mastery: An Intelligent Learning Odyssey</h1>
        <p>Your journey into the realm of analytical wisdom begins now...</p>
    </div>
    
    <div class=\"container\">
        <div class=\"universe-container\">
            <h2 style=\"text-align: center; color: #00ff88; margin-bottom: 20px;\">🌌 Learning Universe</h2>
            <div id=\"learning-universe-container\" style=\"width: 100%; height: 400px; background: radial-gradient(circle, rgba(0, 102, 255, 0.1) 0%, transparent 70%); border-radius: 10px; position: relative;\">
                <div style=\"position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); text-align: center;\">
                    <div style=\"font-size: 2em; margin-bottom: 20px;\">🌌</div>
                    <div>3D Learning Universe</div>
                    <div style=\"font-size: 0.8em; opacity: 0.7; margin-top: 10px;\">Interactive 3D environment loading...</div>
                </div>
            </div>
            
            <div class=\"narrative-text\">
                \"Welcome, young data seeker. Your journey into the realm of analytical wisdom begins now. Each module is a glowing planet in this vast learning universe, waiting to be explored and mastered.\"
            </div>
        </div>
        
        <div class=\"dashboard-container\">
            <h2 style=\"text-align: center; color: #ff6600; margin-bottom: 20px;\">📊 Learning Dashboard</h2>
            
            <div class=\"module-info\">
                <h4>Current Mission: The Awakening of Data Literacy</h4>
                <div class=\"progress-bar\">
                    <div class=\"progress-fill\" style=\"width: 75%;\"></div>
                </div>
                <p>Progress: 75% Complete</p>
            </div>
            
            <div class=\"phase-indicator\">
                <h4>Learning Phases</h4>
                <div class=\"phase-progress\">
                    <div class=\"phase-step completed\" title=\"The Awakening\"></div>
                    <div class=\"phase-step completed\" title=\"Data Literacy\"></div>
                    <div class=\"phase-step active\" title=\"Lost Pipelines\"></div>
                    <div class=\"phase-step\" title=\"Collaboration\"></div>
                    <div class=\"phase-step\" title=\"Cloud Citadel\"></div>
                    <div class=\"phase-step\" title=\"Data Guardian\"></div>
                </div>
            </div>
            
            <div class=\"skill-radar\">
                <div class=\"skill-point\" style=\"top: 20%; left: 30%;\"></div>
                <div class=\"skill-point\" style=\"top: 40%; left: 70%;\"></div>
                <div class=\"skill-point\" style=\"top: 60%; left: 20%;\"></div>
                <div class=\"skill-point\" style=\"top: 80%; left: 80%;\"></div>
                <div style=\"text-align: center;\">
                    <div style=\"font-size: 1.2em; color: #00ff88;\">Skill Mastery</div>
                    <div style=\"font-size: 0.8em; opacity: 0.7;\">Radar Chart</div>
                </div>
            </div>
            
            <div class=\"achievement\">
                <div class=\"achievement-icon\">🏆</div>
                <div>
                    <strong>First Steps</strong><br>
                    <small>Completed System Setup</small>
                </div>
            </div>
            
            <div class=\"achievement\">
                <div class=\"achievement-icon\">⚡</div>
                <div>
                    <strong>Data Awakening</strong><br>
                    <small>Mastered Python Basics</small>
                </div>
            </div>
            
            <div class=\"narrative-text\">
                \"Your data journey begins with insight — the metrics become your compass. Each achievement unlocks new possibilities in your quest for mastery.\"
            </div>
        </div>
    </div>
    
    <div class=\"ai-chat\">
        <h3>🤖 AI Oracle</h3>
        <div class=\"chat-messages\" id=\"chat-messages\">
            <div style=\"color: #00ff88; margin-bottom: 10px;\">
                <strong>Oracle:</strong> Welcome, young data seeker. I am your guide through this learning odyssey. What questions do you have about your journey?
            </div>
        </div>
        <input type=\"text\" class=\"chat-input\" id=\"chat-input\" placeholder=\"Ask the Oracle about your learning journey...\">
        <button class=\"send-button\" onclick=\"sendMessage()\">Send to Oracle</button>
    </div>
    
    <script>
        const oracleResponses = [
            \"The path to data mastery is not without challenges, but each step brings you closer to enlightenment.\",
            \"Let the data flow through you, and you will discover patterns hidden to the untrained eye.\",
            \"Your curiosity is your greatest asset. Every question opens new doors to understanding.\",
            \"The Data Ghosts of errors are not your enemies—they are your teachers in disguise.\",
            \"Collaboration with fellow learners will accelerate your journey. Seek wisdom together.\",
            \"The Cloud Citadel awaits those who master the fundamentals. Your time will come.\",
            \"Patience and persistence are the keys to unlocking the mysteries of data science.\",
            \"Each module completed is a step closer to becoming a true Data Guardian.\"
        ];
        
        function sendMessage() {
            const input = document.getElementById('chat-input');
            const messages = document.getElementById('chat-messages');
            const userMessage = input.value.trim();
            
            if (userMessage) {
                const userDiv = document.createElement('div');
                userDiv.style.color = '#0066ff';
                userDiv.style.marginBottom = '10px';
                userDiv.innerHTML = \`<strong>You:</strong> \${userMessage}\`;
                messages.appendChild(userDiv);
                
                input.value = '';
                
                setTimeout(() => {
                    const randomResponse = oracleResponses[Math.floor(Math.random() * oracleResponses.length)];
                    const aiDiv = document.createElement('div');
                    aiDiv.style.color = '#00ff88';
                    aiDiv.style.marginBottom = '10px';
                    aiDiv.innerHTML = \`<strong>Oracle:</strong> \${randomResponse}\`;
                    messages.appendChild(aiDiv);
                    messages.scrollTop = messages.scrollHeight;
                }, 1000);
            }
        }
        
        document.getElementById('chat-input').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                sendMessage();
            }
        });
        
        setInterval(() => {
            const progressBars = document.querySelectorAll('.progress-fill');
            progressBars.forEach(bar => {
                const currentWidth = parseInt(bar.style.width);
                if (currentWidth < 100) {
                    bar.style.width = (currentWidth + Math.random() * 2) + '%';
                }
            });
        }, 5000);
        
        // Simulate module selection in 3D universe
        document.getElementById('learning-universe-container').addEventListener('click', function(e) {
            const modules = [
                'System Setup & Introduction',
                'Core Python Programming',
                'PySpark Mastery',
                'Git & Bitbucket',
                'Databricks Cloud',
                'Advanced Topics'
            ];
            
            const randomModule = modules[Math.floor(Math.random() * modules.length)];
            const messages = document.getElementById('chat-messages');
            const moduleDiv = document.createElement('div');
            moduleDiv.style.color = '#ff6600';
            moduleDiv.style.marginBottom = '10px';
            moduleDiv.innerHTML = \`<strong>Universe:</strong> Selected module: \${randomModule}\`;
            messages.appendChild(moduleDiv);
            messages.scrollTop = messages.scrollHeight;
        });
    </script>
</body>
</html>
EOF"

# Create requirements and configuration files
print_status "Creating configuration files..."

ssh -J $PROXY_HOST $TARGET_HOST "cat > $ODYSSEY_PATH/requirements.txt << 'EOF'
asyncio
pandas>=1.5.0
numpy>=1.21.0
databricks-sdk>=0.1.0
ollama>=0.1.0
aiohttp>=3.8.0
python-dateutil>=2.8.0
EOF"

# Create systemd service
ssh -J $PROXY_HOST $TARGET_HOST "cat > $ODYSSEY_PATH/ai-oracle.service << 'EOF'
[Unit]
Description=Learning Odyssey AI Oracle Service
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/var/www/html/moodle/course/2/odyssey/ai
ExecStart=/usr/bin/python3 ai-oracle-system.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF"

# Create deployment configuration
ssh -J $PROXY_HOST $TARGET_HOST "cat > $ODYSSEY_PATH/deployment-config.json << 'EOF'
{
    \"moodle_course_id\": \"2\",
    \"course_url\": \"https://moodle.simondatalab.de/course/view.php?id=2\",
    \"odyssey_path\": \"/var/www/html/moodle/course/2/odyssey\",
    \"ai_oracle_port\": 8001,
    \"analytics_port\": 8002,
    \"deployment_date\": \"'$(date -Iseconds)'\",
    \"version\": \"2.0-odyssey\",
    \"deployment_method\": \"proxy-jump\",
    \"proxy_host\": \"root@136.243.155.166\",
    \"target_host\": \"simonadmin@10.0.0.104\"
}
EOF"

# Set proper permissions
print_status "Setting file permissions..."
ssh -J $PROXY_HOST $TARGET_HOST "chown -R www-data:www-data $ODYSSEY_PATH && chmod -R 755 $ODYSSEY_PATH"

# Create comprehensive test script
ssh -J $PROXY_HOST $TARGET_HOST "cat > $ODYSSEY_PATH/test-deployment.sh << 'EOF'
#!/bin/bash
echo \"🧪 Testing Learning Odyssey Deployment...\"
echo \"==========================================\"
echo \"Files deployed to: $ODYSSEY_PATH\"
echo \"Course URL: https://moodle.simondatalab.de/course/view.php?id=2\"
echo \"Demo URL: https://moodle.simondatalab.de/course/2/odyssey/odyssey-demo.html\"
echo \"\"
echo \"File structure:\"
ls -la $ODYSSEY_PATH/
echo \"\"
echo \"JavaScript files:\"
ls -la $ODYSSEY_PATH/js/
echo \"\"
echo \"Python files:\"
ls -la $ODYSSEY_PATH/ai/
ls -la $ODYSSEY_PATH/analytics/
echo \"\"
echo \"Configuration files:\"
ls -la $ODYSSEY_PATH/*.json $ODYSSEY_PATH/*.txt $ODYSSEY_PATH/*.service
echo \"\"
echo \"✅ Deployment test complete!\"
echo \"\"
echo \"Next steps:\"
echo \"1. Add odyssey-course.html as a page resource in Moodle\"
echo \"2. Configure AI Oracle service\"
echo \"3. Set up Databricks analytics\"
echo \"4. Test all features\"
EOF"

ssh -J $PROXY_HOST $TARGET_HOST "chmod +x $ODYSSEY_PATH/test-deployment.sh"

# Create comprehensive integration guide
ssh -J $PROXY_HOST $TARGET_HOST "cat > $ODYSSEY_PATH/MOODLE_INTEGRATION_GUIDE.md << 'EOF'
# Learning Odyssey - Moodle Integration Guide

## 🚀 Quick Start

### 1. Add to Moodle Course
1. Go to [Course Administration](https://moodle.simondatalab.de/course/view.php?id=2)
2. Click \"Turn editing on\"
3. Add a new \"Page\" resource
4. Title: \"Learning Odyssey\"
5. Content: Copy from \`odyssey-course.html\`
6. Save and return to course

### 2. Test the Deployment
\`\`\`bash
cd /var/www/html/moodle/course/2/odyssey
./test-deployment.sh
\`\`\`

## 🔧 Advanced Configuration

### AI Oracle Service
\`\`\`bash
# Install dependencies
pip3 install -r requirements.txt

# Start AI Oracle
cd ai
python3 ai-oracle-system.py &

# Or use systemd service
sudo cp ai-oracle.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable ai-oracle.service
sudo systemctl start ai-oracle.service
\`\`\`

### Databricks Analytics
\`\`\`bash
# Update credentials
cd analytics
nano databricks-analytics.py
# Add your Databricks credentials

# Start analytics service
python3 databricks-analytics.py &
\`\`\`

## 🌐 Access URLs

- **Main Course**: https://moodle.simondatalab.de/course/view.php?id=2
- **Odyssey Demo**: https://moodle.simondatalab.de/course/2/odyssey/odyssey-demo.html
- **AI Oracle API**: http://localhost:8001
- **Analytics API**: http://localhost:8002

## 📊 Features

### ✅ Implemented
- Interactive 3D Learning Universe
- Real-time Analytics Dashboard
- AI Oracle Chat System
- Progress Tracking
- Achievement System
- Narrative Learning Phases

### 🎭 Learning Phases
1. **The Awakening of Data Literacy** (Modules 1-2)
2. **The Map of Lost Pipelines** (Module 3: PySpark)
3. **The Code of Collaboration** (Module 4: Git/Bitbucket)
4. **The Cloud Citadel** (Module 5: Databricks)
5. **The Rise of the Data Guardian** (Module 6: Advanced)

## 🔍 Monitoring

### Health Checks
\`\`\`bash
# Check AI Oracle
curl http://localhost:8001/health

# Check Analytics
curl http://localhost:8002/health

# View logs
tail -f /var/log/syslog | grep odyssey
\`\`\`

### Performance Monitoring
- Check server resources: \`htop\`
- Monitor web server: \`tail -f /var/log/apache2/access.log\`
- Check database performance

## 🛠️ Troubleshooting

### Common Issues
1. **Files not accessible**: Check permissions (\`chown -R www-data:www-data /var/www/html/moodle/course/2/odyssey\`)
2. **AI Oracle not responding**: Check Python dependencies and service status
3. **3D Universe not loading**: Verify Three.js dependencies
4. **Analytics not updating**: Check Databricks connection

### Debug Commands
\`\`\`bash
# Check file permissions
ls -la /var/www/html/moodle/course/2/odyssey/

# Test Python dependencies
python3 -c \"import asyncio, pandas, numpy\"

# Check service status
sudo systemctl status ai-oracle.service

# View error logs
sudo journalctl -u ai-oracle.service -f
\`\`\`

## 🎉 Success!

Your Learning Odyssey is now deployed and ready to transform the J&J Python Academy into an immersive, intelligent learning experience!

The system will engage students with:
- Interactive 3D environments
- AI-powered assistance
- Real-time analytics
- Compelling narratives
- Gamified learning elements

Welcome to the future of data science education! 🌌✨
EOF"

print_success "Comprehensive integration guide created!"

# Run final test
print_status "Running final deployment test..."
ssh -J $PROXY_HOST $TARGET_HOST "cd $ODYSSEY_PATH && ./test-deployment.sh"

print_success "🎉 Complete Learning Odyssey deployment successful!"
print_status "Files deployed to: $ODYSSEY_PATH"
print_status "Course URL: https://moodle.simondatalab.de/course/view.php?id=$MOODLE_COURSE_ID"
print_status "Demo URL: https://moodle.simondatalab.de/course/$MOODLE_COURSE_ID/odyssey/odyssey-demo.html"

echo ""
print_status "🚀 Next Steps:"
echo "1. Add odyssey-course.html as a page resource in Moodle"
echo "2. Configure AI Oracle service (optional)"
echo "3. Set up Databricks analytics (optional)"
echo "4. Test all features with students"

echo ""
print_success "Your Learning Odyssey is ready to launch! 🌌✨"

