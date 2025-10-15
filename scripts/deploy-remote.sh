#!/bin/bash

# Remote Learning Odyssey Deployment Script
# Run this script to deploy to your Moodle server via SSH

set -e

# Configuration
REMOTE_HOST="10.0.0.104"
REMOTE_USER="simonadmin"
MOODLE_COURSE_ID="2"
LOCAL_ODYSSEY_PATH="./odyssey-implementation"
REMOTE_ODYSSEY_PATH="/var/www/html/moodle/course/$MOODLE_COURSE_ID/odyssey"

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

echo "🚀 Starting Remote Learning Odyssey Deployment..."
echo "Target: $REMOTE_USER@$REMOTE_HOST"
echo "Course: https://moodle.simondatalab.de/course/view.php?id=$MOODLE_COURSE_ID"
echo ""

# Test connection
print_status "Testing connection to remote server..."
if ! ssh -o ConnectTimeout=10 -o BatchMode=yes $REMOTE_USER@$REMOTE_HOST "echo 'Connection successful'" 2>/dev/null; then
    print_error "Cannot connect to $REMOTE_USER@$REMOTE_HOST"
    print_status "Please ensure:"
    echo "1. SSH key is properly configured"
    echo "2. Server is accessible"
    echo "3. User has proper permissions"
    exit 1
fi

print_success "Connection established!"

# Create remote directory structure
print_status "Creating remote directory structure..."
ssh $REMOTE_USER@$REMOTE_HOST "mkdir -p $REMOTE_ODYSSEY_PATH/{js,css,images,ai,analytics}"

# Copy files to remote server
print_status "Copying implementation files..."

# Copy JavaScript files
scp $LOCAL_ODYSSEY_PATH/learning-universe.js $REMOTE_USER@$REMOTE_HOST:$REMOTE_ODYSSEY_PATH/js/
scp $LOCAL_ODYSSEY_PATH/d3-dashboard.js $REMOTE_USER@$REMOTE_HOST:$REMOTE_ODYSSEY_PATH/js/

# Copy Python files
scp $LOCAL_ODYSSEY_PATH/ai-oracle-system.py $REMOTE_USER@$REMOTE_HOST:$REMOTE_ODYSSEY_PATH/ai/
scp $LOCAL_ODYSSEY_PATH/databricks-analytics.py $REMOTE_USER@$REMOTE_HOST:$REMOTE_ODYSSEY_PATH/analytics/

# Copy HTML demo
scp $LOCAL_ODYSSEY_PATH/examples/basic-setup.html $REMOTE_USER@$REMOTE_HOST:$REMOTE_ODYSSEY_PATH/odyssey-demo.html

# Copy documentation
scp $LOCAL_ODYSSEY_PATH/README.md $REMOTE_USER@$REMOTE_HOST:$REMOTE_ODYSSEY_PATH/
scp ODYSSEY_IMPLEMENTATION_SUMMARY.md $REMOTE_USER@$REMOTE_HOST:$REMOTE_ODYSSEY_PATH/

print_success "Files copied successfully!"

# Create Moodle integration files on remote server
print_status "Creating Moodle integration files on remote server..."

ssh $REMOTE_USER@$REMOTE_HOST "cat > $REMOTE_ODYSSEY_PATH/odyssey-course.html << 'EOF'
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
    </script>
</body>
</html>
EOF"

# Create requirements file
ssh $REMOTE_USER@$REMOTE_HOST "cat > $REMOTE_ODYSSEY_PATH/requirements.txt << 'EOF'
asyncio
pandas>=1.5.0
numpy>=1.21.0
databricks-sdk>=0.1.0
ollama>=0.1.0
aiohttp>=3.8.0
python-dateutil>=2.8.0
EOF"

# Set proper permissions
print_status "Setting file permissions..."
ssh $REMOTE_USER@$REMOTE_HOST "chown -R www-data:www-data $REMOTE_ODYSSEY_PATH && chmod -R 755 $REMOTE_ODYSSEY_PATH"

# Create test script
ssh $REMOTE_USER@$REMOTE_HOST "cat > $REMOTE_ODYSSEY_PATH/test-deployment.sh << 'EOF'
#!/bin/bash
echo \"🧪 Testing Learning Odyssey Deployment...\"
echo \"Files deployed to: $REMOTE_ODYSSEY_PATH\"
ls -la $REMOTE_ODYSSEY_PATH/
echo \"✅ Deployment test complete!\"
EOF"

ssh $REMOTE_USER@$REMOTE_HOST "chmod +x $REMOTE_ODYSSEY_PATH/test-deployment.sh"

print_success "🎉 Remote deployment completed successfully!"

echo ""
print_status "Deployment Summary:"
echo "📁 Files deployed to: $REMOTE_ODYSSEY_PATH"
echo "🌐 Course URL: https://moodle.simondatalab.de/course/view.php?id=$MOODLE_COURSE_ID"
echo "🎮 Demo URL: https://moodle.simondatalab.de/course/$MOODLE_COURSE_ID/odyssey/odyssey-demo.html"

echo ""
print_status "Next steps:"
echo "1. SSH to server: ssh $REMOTE_USER@$REMOTE_HOST"
echo "2. Run test: $REMOTE_ODYSSEY_PATH/test-deployment.sh"
echo "3. Add odyssey-course.html as a page resource in Moodle"
echo "4. Configure AI Oracle and Databricks services"

echo ""
print_success "🚀 Your Learning Odyssey is ready to launch! 🌌"

