#!/bin/bash

# Learning Odyssey Deployment Script
# Deploy to Moodle course at https://moodle.simondatalab.de/course/view.php?id=2

set -e

echo "🚀 Starting Learning Odyssey Deployment..."

# Configuration
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

# Function to print colored output
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

# Check if we're on the correct server
print_status "Checking server environment..."

# Create odyssey directory structure
print_status "Creating odyssey directory structure..."
mkdir -p "$ODYSSEY_PATH"
mkdir -p "$ODYSSEY_PATH/js"
mkdir -p "$ODYSSEY_PATH/css"
mkdir -p "$ODYSSEY_PATH/images"
mkdir -p "$ODYSSEY_PATH/ai"
mkdir -p "$ODYSSEY_PATH/analytics"

# Copy implementation files
print_status "Copying implementation files..."

# Copy JavaScript files
cp odyssey-implementation/learning-universe.js "$ODYSSEY_PATH/js/"
cp odyssey-implementation/d3-dashboard.js "$ODYSSEY_PATH/js/"

# Copy Python files
cp odyssey-implementation/ai-oracle-system.py "$ODYSSEY_PATH/ai/"
cp odyssey-implementation/databricks-analytics.py "$ODYSSEY_PATH/analytics/"

# Copy HTML demo
cp odyssey-implementation/examples/basic-setup.html "$ODYSSEY_PATH/odyssey-demo.html"

# Copy documentation
cp odyssey-implementation/README.md "$ODYSSEY_PATH/"
cp ODYSSEY_IMPLEMENTATION_SUMMARY.md "$ODYSSEY_PATH/"

print_success "Files copied successfully!"

# Create Moodle integration files
print_status "Creating Moodle integration files..."

# Create course page HTML
cat > "$ODYSSEY_PATH/odyssey-course.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
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
    </style>
</head>
<body>
    <div class="moodle-header">
        <h1>🚀 From Data to Mastery: An Intelligent Learning Odyssey</h1>
        <p>Your journey into the realm of analytical wisdom begins now...</p>
    </div>
    
    <div class="container">
        <div class="universe-container">
            <h2 style="text-align: center; color: #00ff88; margin-bottom: 20px;">🌌 Learning Universe</h2>
            <div id="learning-universe-container" style="width: 100%; height: 400px; background: radial-gradient(circle, rgba(0, 102, 255, 0.1) 0%, transparent 70%); border-radius: 10px; position: relative;">
                <div style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); text-align: center;">
                    <div style="font-size: 2em; margin-bottom: 20px;">🌌</div>
                    <div>3D Learning Universe</div>
                    <div style="font-size: 0.8em; opacity: 0.7; margin-top: 10px;">Interactive 3D environment loading...</div>
                </div>
            </div>
            
            <div class="narrative-text">
                "Welcome, young data seeker. Your journey into the realm of analytical wisdom begins now. Each module is a glowing planet in this vast learning universe, waiting to be explored and mastered."
            </div>
        </div>
        
        <div class="dashboard-container">
            <h2 style="text-align: center; color: #ff6600; margin-bottom: 20px;">📊 Learning Dashboard</h2>
            
            <div class="module-info">
                <h4>Current Mission: The Awakening of Data Literacy</h4>
                <div class="progress-bar">
                    <div class="progress-fill" style="width: 75%;"></div>
                </div>
                <p>Progress: 75% Complete</p>
            </div>
            
            <div class="narrative-text">
                "Your data journey begins with insight — the metrics become your compass. Each achievement unlocks new possibilities in your quest for mastery."
            </div>
        </div>
    </div>
    
    <div class="ai-chat">
        <h3>🤖 AI Oracle</h3>
        <div class="chat-messages" id="chat-messages">
            <div style="color: #00ff88; margin-bottom: 10px;">
                <strong>Oracle:</strong> Welcome, young data seeker. I am your guide through this learning odyssey. What questions do you have about your journey?
            </div>
        </div>
        <input type="text" class="chat-input" id="chat-input" placeholder="Ask the Oracle about your learning journey...">
        <button class="send-button" onclick="sendMessage()">Send to Oracle</button>
    </div>
    
    <script>
        // AI Oracle responses
        const oracleResponses = [
            "The path to data mastery is not without challenges, but each step brings you closer to enlightenment.",
            "Let the data flow through you, and you will discover patterns hidden to the untrained eye.",
            "Your curiosity is your greatest asset. Every question opens new doors to understanding.",
            "The Data Ghosts of errors are not your enemies—they are your teachers in disguise.",
            "Collaboration with fellow learners will accelerate your journey. Seek wisdom together.",
            "The Cloud Citadel awaits those who master the fundamentals. Your time will come.",
            "Patience and persistence are the keys to unlocking the mysteries of data science.",
            "Each module completed is a step closer to becoming a true Data Guardian."
        ];
        
        function sendMessage() {
            const input = document.getElementById('chat-input');
            const messages = document.getElementById('chat-messages');
            const userMessage = input.value.trim();
            
            if (userMessage) {
                const userDiv = document.createElement('div');
                userDiv.style.color = '#0066ff';
                userDiv.style.marginBottom = '10px';
                userDiv.innerHTML = `<strong>You:</strong> ${userMessage}`;
                messages.appendChild(userDiv);
                
                input.value = '';
                
                setTimeout(() => {
                    const randomResponse = oracleResponses[Math.floor(Math.random() * oracleResponses.length)];
                    const aiDiv = document.createElement('div');
                    aiDiv.style.color = '#00ff88';
                    aiDiv.style.marginBottom = '10px';
                    aiDiv.innerHTML = `<strong>Oracle:</strong> ${randomResponse}`;
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
        
        // Simulate real-time updates
        setInterval(() => {
            const progressBars = document.querySelectorAll('.progress-fill');
            progressBars.forEach(bar => {
                const currentWidth = parseInt(bar.style.width);
                if (currentWidth < 100) {
                    bar.style.width = (currentWidth + Math.random() * 2) + '%';
                }
            });
        }, 5000);
    </script>
</body>
</html>
EOF

print_success "Moodle integration files created!"

# Create Python requirements file
cat > "$ODYSSEY_PATH/requirements.txt" << 'EOF'
asyncio
pandas>=1.5.0
numpy>=1.21.0
databricks-sdk>=0.1.0
ollama>=0.1.0
aiohttp>=3.8.0
python-dateutil>=2.8.0
EOF

# Create systemd service for AI Oracle
cat > "$ODYSSEY_PATH/ai-oracle.service" << 'EOF'
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
EOF

# Create deployment configuration
cat > "$ODYSSEY_PATH/deployment-config.json" << 'EOF'
{
    "moodle_course_id": "2",
    "course_url": "https://moodle.simondatalab.de/course/view.php?id=2",
    "odyssey_path": "/var/www/html/moodle/course/2/odyssey",
    "ai_oracle_port": 8001,
    "analytics_port": 8002,
    "deployment_date": "'$(date -Iseconds)'",
    "version": "2.0-odyssey"
}
EOF

# Set proper permissions
print_status "Setting file permissions..."
chown -R www-data:www-data "$ODYSSEY_PATH"
chmod -R 755 "$ODYSSEY_PATH"
chmod +x "$ODYSSEY_PATH/ai/ai-oracle-system.py"
chmod +x "$ODYSSEY_PATH/analytics/databricks-analytics.py"

print_success "Permissions set successfully!"

# Create Moodle course integration instructions
cat > "$ODYSSEY_PATH/MOODLE_INTEGRATION.md" << 'EOF'
# Moodle Integration Instructions

## Course Integration Steps

1. **Add Odyssey Page to Course**
   - Go to Course Administration > Turn editing on
   - Add a new Page resource
   - Title: "Learning Odyssey"
   - Content: Use the odyssey-course.html file
   - Save and return to course

2. **Enable AI Oracle Service**
   ```bash
   sudo cp ai-oracle.service /etc/systemd/system/
   sudo systemctl daemon-reload
   sudo systemctl enable ai-oracle.service
   sudo systemctl start ai-oracle.service
   ```

3. **Configure Databricks Analytics**
   - Update databricks-analytics.py with your Databricks credentials
   - Set up database tables for learning events
   - Configure real-time data pipeline

4. **Set up Ollama Integration**
   - Install Ollama on the server
   - Download appropriate model (e.g., llama2, codellama)
   - Update AI Oracle configuration

## Access URLs

- **Main Odyssey Interface**: https://moodle.simondatalab.de/course/view.php?id=2
- **AI Oracle API**: http://localhost:8001
- **Analytics API**: http://localhost:8002
- **Demo Page**: https://moodle.simondatalab.de/course/2/odyssey/odyssey-demo.html

## Monitoring

- Check AI Oracle status: `sudo systemctl status ai-oracle.service`
- View logs: `sudo journalctl -u ai-oracle.service -f`
- Monitor analytics: Check Databricks dashboard

## Troubleshooting

1. **AI Oracle not responding**: Check service status and logs
2. **3D Universe not loading**: Verify Three.js dependencies
3. **Analytics not updating**: Check Databricks connection
4. **Permission issues**: Verify www-data ownership
EOF

print_success "Moodle integration instructions created!"

# Create a simple test script
cat > "$ODYSSEY_PATH/test-deployment.sh" << 'EOF'
#!/bin/bash

echo "🧪 Testing Learning Odyssey Deployment..."

# Test file existence
echo "Checking files..."
ls -la /var/www/html/moodle/course/2/odyssey/

# Test AI Oracle
echo "Testing AI Oracle..."
curl -s http://localhost:8001/health || echo "AI Oracle not running"

# Test analytics
echo "Testing Analytics..."
curl -s http://localhost:8002/health || echo "Analytics not running"

# Test Moodle course
echo "Testing Moodle course..."
curl -s -I https://moodle.simondatalab.de/course/view.php?id=2 | head -1

echo "✅ Deployment test complete!"
EOF

chmod +x "$ODYSSEY_PATH/test-deployment.sh"

print_success "Test script created!"

# Final status
print_success "🎉 Learning Odyssey deployment completed successfully!"
print_status "Files deployed to: $ODYSSEY_PATH"
print_status "Course URL: https://moodle.simondatalab.de/course/view.php?id=2"
print_status "Demo URL: https://moodle.simondatalab.de/course/2/odyssey/odyssey-demo.html"

echo ""
print_status "Next steps:"
echo "1. Run: sudo systemctl start ai-oracle.service"
echo "2. Add odyssey-course.html as a page resource in Moodle"
echo "3. Configure Databricks credentials"
echo "4. Test the deployment with: ./test-deployment.sh"

echo ""
print_success "🚀 Your Learning Odyssey is ready to launch! 🌌"
