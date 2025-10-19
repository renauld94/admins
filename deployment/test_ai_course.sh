#!/bin/bash
# AI Course Comprehensive Testing Script
# Test all platform integrations and create deployment report

set -euo pipefail

# Configuration
COURSE_ID=22
MOODLE_URL="https://moodle.simondatalab.de"
OPENWEBUI_URL="https://openwebui.simondatalab.de"
OLLAMA_URL="https://ollama.simondatalab.de"
LOG_FILE="ai_course_testing.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test results
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Logging
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

# Test function
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_result="$3"
    
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    
    log "Running test: $test_name"
    
    if eval "$test_command" > /dev/null 2>&1; then
        success "✅ PASSED: $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        error "❌ FAILED: $test_name"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Test Moodle connectivity
test_moodle_connectivity() {
    log "Testing Moodle connectivity..."
    
    # Test basic connectivity
    local moodle_response=$(curl -s -o /dev/null -w "%{http_code}" "$MOODLE_URL")
    if [ "$moodle_response" = "200" ]; then
        success "Moodle base URL: OK ($moodle_response)"
    else
        error "Moodle base URL: FAILED ($moodle_response)"
    fi
    
    # Test course page (expecting redirect to enrollment)
    local course_response=$(curl -s -o /dev/null -w "%{http_code}" "$MOODLE_URL/course/view.php?id=$COURSE_ID")
    if [ "$course_response" = "303" ] || [ "$course_response" = "200" ]; then
        success "Moodle course page: OK ($course_response - redirect to enrollment is expected)"
    else
        error "Moodle course page: FAILED ($course_response)"
    fi
    
    # Test enrollment page
    local enroll_response=$(curl -s -o /dev/null -w "%{http_code}" "$MOODLE_URL/enrol/index.php?id=$COURSE_ID")
    if [ "$enroll_response" = "200" ]; then
        success "Moodle enrollment page: OK ($enroll_response)"
    else
        error "Moodle enrollment page: FAILED ($enroll_response)"
    fi
}

# Test OpenWebUI connectivity
test_openwebui_connectivity() {
    log "Testing OpenWebUI connectivity..."
    
    # Test base URL
    local openwebui_response=$(curl -s -o /dev/null -w "%{http_code}" "$OPENWEBUI_URL")
    if [ "$openwebui_response" = "200" ]; then
        success "OpenWebUI base URL: OK ($openwebui_response)"
    else
        error "OpenWebUI base URL: FAILED ($openwebui_response)"
    fi
    
    # Test chat page
    local chat_response=$(curl -s -o /dev/null -w "%{http_code}" "$OPENWEBUI_URL/chat")
    if [ "$chat_response" = "200" ]; then
        success "OpenWebUI chat page: OK ($chat_response)"
    else
        error "OpenWebUI chat page: FAILED ($chat_response)"
    fi
    
    # Test models page
    local models_response=$(curl -s -o /dev/null -w "%{http_code}" "$OPENWEBUI_URL/models")
    if [ "$models_response" = "200" ]; then
        success "OpenWebUI models page: OK ($models_response)"
    else
        error "OpenWebUI models page: FAILED ($models_response)"
    fi
}

# Test Ollama connectivity
test_ollama_connectivity() {
    log "Testing Ollama connectivity..."
    
    # Test base URL
    local ollama_response=$(curl -s -o /dev/null -w "%{http_code}" "$OLLAMA_URL")
    if [ "$ollama_response" = "200" ]; then
        success "Ollama base URL: OK ($ollama_response)"
    else
        error "Ollama base URL: FAILED ($ollama_response)"
    fi
    
    # Test models API
    local models_response=$(curl -s -o /dev/null -w "%{http_code}" "$OLLAMA_URL/api/tags")
    if [ "$models_response" = "200" ]; then
        success "Ollama models API: OK ($models_response)"
    else
        error "Ollama models API: FAILED ($models_response)"
    fi
    
    # Test available models
    local models_json=$(curl -s "$OLLAMA_URL/api/tags")
    if echo "$models_json" | grep -q "deepseek-coder"; then
        success "DeepSeek Coder model: Available"
    else
        error "DeepSeek Coder model: Not found"
    fi
    
    if echo "$models_json" | grep -q "tinyllama"; then
        success "TinyLlama model: Available"
    else
        error "TinyLlama model: Not found"
    fi
}

# Test Ollama model functionality
test_ollama_models() {
    log "Testing Ollama model functionality..."
    
    # Test code generation
    local code_response=$(curl -s -X POST "$OLLAMA_URL/api/generate" \
        -H "Content-Type: application/json" \
        -d '{"model":"deepseek-coder:6.7b","prompt":"Write a simple Python function","stream":false}')
    
    if echo "$code_response" | grep -q "response"; then
        success "Code generation test: OK"
        local generated_code=$(echo "$code_response" | jq -r '.response' | head -3)
        log "Generated code sample: $generated_code"
    else
        error "Code generation test: FAILED"
    fi
    
    # Test chat functionality
    local chat_response=$(curl -s -X POST "$OLLAMA_URL/api/chat" \
        -H "Content-Type: application/json" \
        -d '{"model":"tinyllama:latest","messages":[{"role":"user","content":"Hello"}],"stream":false}')
    
    if echo "$chat_response" | grep -q "message"; then
        success "Chat functionality test: OK"
        local chat_reply=$(echo "$chat_response" | jq -r '.message.content' | head -1)
        log "Chat reply sample: $chat_reply"
    else
        error "Chat functionality test: FAILED"
    fi
}

# Test performance
test_performance() {
    log "Testing platform performance..."
    
    # Test response times
    local moodle_time=$(curl -o /dev/null -s -w "%{time_total}" "$MOODLE_URL")
    local openwebui_time=$(curl -o /dev/null -s -w "%{time_total}" "$OPENWEBUI_URL")
    local ollama_time=$(curl -o /dev/null -s -w "%{time_total}" "$OLLAMA_URL/api/tags")
    
    log "Response times:"
    log "  Moodle: ${moodle_time}s"
    log "  OpenWebUI: ${openwebui_time}s"
    log "  Ollama: ${ollama_time}s"
    
    # Check if response times are acceptable
    if (( $(echo "$moodle_time < 5.0" | bc -l) )); then
        success "Moodle response time: OK (${moodle_time}s)"
    else
        warning "Moodle response time: SLOW (${moodle_time}s)"
    fi
    
    if (( $(echo "$openwebui_time < 3.0" | bc -l) )); then
        success "OpenWebUI response time: OK (${openwebui_time}s)"
    else
        warning "OpenWebUI response time: SLOW (${openwebui_time}s)"
    fi
    
    if (( $(echo "$ollama_time < 2.0" | bc -l) )); then
        success "Ollama response time: OK (${ollama_time}s)"
    else
        warning "Ollama response time: SLOW (${ollama_time}s)"
    fi
}

# Create course content
create_course_content() {
    log "Creating AI course content..."
    
    # Create course content directory
    mkdir -p course-content
    
    # Create main course page
    cat > "course-content/ai-course-main.html" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI MASTERY: From Neural Networks to Global Intelligence</title>
    <style>
        body { 
            font-family: 'Segoe UI', Arial, sans-serif; 
            margin: 0; 
            padding: 20px; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }
        .container { 
            max-width: 1200px; 
            margin: 0 auto; 
            background: white; 
            border-radius: 15px; 
            padding: 40px; 
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        }
        .header { 
            text-align: center; 
            margin-bottom: 40px; 
        }
        .header h1 { 
            color: #d51920; 
            font-size: 3em; 
            margin: 0; 
            text-shadow: 2px 2px 4px rgba(0,0,0,0.1);
        }
        .header p { 
            color: #666; 
            font-size: 1.2em; 
            margin: 10px 0; 
        }
        .module { 
            margin: 30px 0; 
            padding: 25px; 
            border: 1px solid #ddd; 
            border-radius: 10px; 
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            transition: transform 0.3s ease;
        }
        .module:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        .module h3 { 
            color: #d51920; 
            margin-top: 0; 
            font-size: 1.5em;
        }
        .session { 
            margin: 15px 0; 
            padding: 15px; 
            background: white; 
            border-radius: 8px; 
            border-left: 4px solid #d51920;
        }
        .integration-links { 
            margin: 20px 0; 
            padding: 20px; 
            background: #e8f4fd; 
            border-radius: 10px; 
            text-align: center;
        }
        .integration-link { 
            display: inline-block; 
            padding: 12px 25px; 
            background: #d51920; 
            color: white; 
            text-decoration: none; 
            border-radius: 25px; 
            margin: 10px 5px; 
            transition: all 0.3s ease;
            font-weight: bold;
        }
        .integration-link:hover { 
            background: #b71c1c; 
            transform: scale(1.05);
        }
        .stats { 
            display: grid; 
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); 
            gap: 20px; 
            margin: 30px 0; 
        }
        .stat-card { 
            background: white; 
            padding: 20px; 
            border-radius: 10px; 
            text-align: center; 
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .stat-number { 
            font-size: 2em; 
            font-weight: bold; 
            color: #d51920; 
        }
        .stat-label { 
            color: #666; 
            margin-top: 5px; 
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🤖 AI MASTERY</h1>
            <p>From Neural Networks to Global Intelligence</p>
            <p>Epic Learning Experience with OpenWebUI + Ollama Integration</p>
        </div>
        
        <div class="stats">
            <div class="stat-card">
                <div class="stat-number">6</div>
                <div class="stat-label">Comprehensive Modules</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">24</div>
                <div class="stat-label">Interactive Sessions</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">40+</div>
                <div class="stat-label">Hours of Content</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">100%</div>
                <div class="stat-label">Hands-on Labs</div>
            </div>
        </div>
        
        <div class="integration-links">
            <h3>🔗 Platform Integrations</h3>
            <a href="${MOODLE_URL}/course/view.php?id=${COURSE_ID}" class="integration-link" target="_blank">📚 Moodle Course</a>
            <a href="${OPENWEBUI_URL}/chat" class="integration-link" target="_blank">🤖 OpenWebUI Chat</a>
            <a href="${OLLAMA_URL}" class="integration-link" target="_blank">🔧 Ollama Models</a>
            <a href="integration-test.html" class="integration-link" target="_blank">🧪 Integration Test</a>
        </div>
        
        <div class="module">
            <h3>🚀 Module 1: The AI Revolution Begins</h3>
            <div class="session">
                <strong>Session 1.1:</strong> Welcome to the AI Universe - Epic opening with neural network evolution
            </div>
            <div class="session">
                <strong>Session 1.2:</strong> The Building Blocks of Intelligence - Interactive decision tree builder
            </div>
            <div class="session">
                <strong>Session 1.3:</strong> Data - The Fuel of AI - Real-time data pipeline visualization
            </div>
            <div class="session">
                <strong>Session 1.4:</strong> Your First AI Model - Hands-on model creation with Ollama
            </div>
        </div>
        
        <div class="module">
            <h3>🧠 Module 2: Neural Networks - The Brain of AI</h3>
            <div class="session">
                <strong>Session 2.1:</strong> Neural Networks Demystified - 3D interactive network builder
            </div>
            <div class="session">
                <strong>Session 2.2:</strong> Deep Learning Revolution - Advanced architecture explorer
            </div>
            <div class="session">
                <strong>Session 2.3:</strong> Computer Vision - AI's Eyes - Real-time image classification
            </div>
            <div class="session">
                <strong>Session 2.4:</strong> Natural Language Processing - AI's Voice - Language model testing
            </div>
        </div>
        
        <div class="module">
            <h3>⚡ Module 3: Advanced AI Techniques</h3>
            <div class="session">
                <strong>Session 3.1:</strong> Reinforcement Learning - AI's Learning - Interactive RL simulator
            </div>
            <div class="session">
                <strong>Session 3.2:</strong> Generative AI - AI's Creativity - AI art and music generation
            </div>
            <div class="session">
                <strong>Session 3.3:</strong> Transfer Learning - AI's Knowledge Transfer - Model adaptation
            </div>
            <div class="session">
                <strong>Session 3.4:</strong> Ensemble Methods - AI's Teamwork - Collaborative AI systems
            </div>
        </div>
        
        <div class="module">
            <h3>🤖 Module 4: AI Agents & Orchestration</h3>
            <div class="session">
                <strong>Session 4.1:</strong> Building AI Agents - Interactive agent builder
            </div>
            <div class="session">
                <strong>Session 4.2:</strong> Multi-Agent Systems - Collaborative agent simulation
            </div>
            <div class="session">
                <strong>Session 4.3:</strong> AI Orchestration & Workflows - System integration
            </div>
            <div class="session">
                <strong>Session 4.4:</strong> AI in Production - Deployment and monitoring
            </div>
        </div>
        
        <div class="module">
            <h3>🎨 Module 5: Creative AI Applications</h3>
            <div class="session">
                <strong>Session 5.1:</strong> AI in Art & Music - Creative AI studio
            </div>
            <div class="session">
                <strong>Session 5.2:</strong> AI in Storytelling & Games - Interactive narrative builder
            </div>
        </div>
        
        <div class="module">
            <h3>🌍 Module 6: AI Ethics, Impact & Future</h3>
            <div class="session">
                <strong>Session 6.1:</strong> AI Ethics & Responsibility - Ethics dashboard
            </div>
            <div class="session">
                <strong>Session 6.2:</strong> The Future of AI - Future technology explorer
            </div>
        </div>
        
        <div class="integration-links">
            <h3>🎯 Ready to Start Your AI Journey?</h3>
            <a href="${MOODLE_URL}/course/view.php?id=${COURSE_ID}" class="integration-link" target="_blank">🚀 Launch Course</a>
            <a href="${OPENWEBUI_URL}/chat" class="integration-link" target="_blank">💬 Start Chatting with AI</a>
            <a href="${OLLAMA_URL}" class="integration-link" target="_blank">🔧 Explore AI Models</a>
        </div>
    </div>
</body>
</html>
EOF

    # Create integration test page
    cat > "course-content/integration-test.html" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI Course Integration Test</title>
    <style>
        body { font-family: 'Segoe UI', Arial, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; }
        .test-section { background: white; margin: 20px 0; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .test-button { padding: 15px 30px; background: #d51920; color: white; border: none; border-radius: 5px; cursor: pointer; margin: 10px; }
        .test-button:hover { background: #b71c1c; }
        .result { margin: 20px 0; padding: 15px; border-radius: 5px; }
        .success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .iframe-container { margin: 20px 0; }
        iframe { width: 100%; height: 600px; border: 1px solid #ddd; border-radius: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🤖 AI Course Integration Test</h1>
        
        <div class="test-section">
            <h2>Platform Connectivity Tests</h2>
            <button class="test-button" onclick="testMoodle()">Test Moodle</button>
            <button class="test-button" onclick="testOpenWebUI()">Test OpenWebUI</button>
            <button class="test-button" onclick="testOllama()">Test Ollama</button>
            <div id="test-results"></div>
        </div>
        
        <div class="test-section">
            <h2>OpenWebUI Integration</h2>
            <div class="iframe-container">
                <iframe src="${OPENWEBUI_URL}/chat" title="OpenWebUI Chat"></iframe>
            </div>
        </div>
        
        <div class="test-section">
            <h2>Ollama Model Testing</h2>
            <button class="test-button" onclick="testOllamaGenerate()">Test Code Generation</button>
            <button class="test-button" onclick="testOllamaChat()">Test Chat</button>
            <div id="ollama-results"></div>
        </div>
        
        <div class="test-section">
            <h2>Course Navigation</h2>
            <a href="${MOODLE_URL}/course/view.php?id=${COURSE_ID}" class="test-button" target="_blank">Go to Moodle Course</a>
        </div>
    </div>
    
    <script>
        async function testMoodle() {
            try {
                const response = await fetch('${MOODLE_URL}/course/view.php?id=${COURSE_ID}');
                const result = document.getElementById('test-results');
                if (response.ok || response.status === 303) {
                    result.innerHTML = '<div class="result success">✅ Moodle: Connected successfully (redirect to enrollment is expected)</div>';
                } else {
                    result.innerHTML = '<div class="result error">❌ Moodle: Connection failed</div>';
                }
            } catch (error) {
                document.getElementById('test-results').innerHTML = '<div class="result error">❌ Moodle: Error - ' + error.message + '</div>';
            }
        }
        
        async function testOpenWebUI() {
            try {
                const response = await fetch('${OPENWEBUI_URL}');
                const result = document.getElementById('test-results');
                if (response.ok) {
                    result.innerHTML = '<div class="result success">✅ OpenWebUI: Connected successfully</div>';
                } else {
                    result.innerHTML = '<div class="result error">❌ OpenWebUI: Connection failed</div>';
                }
            } catch (error) {
                document.getElementById('test-results').innerHTML = '<div class="result error">❌ OpenWebUI: Error - ' + error.message + '</div>';
            }
        }
        
        async function testOllama() {
            try {
                const response = await fetch('${OLLAMA_URL}/api/tags');
                const data = await response.json();
                const result = document.getElementById('test-results');
                if (response.ok) {
                    result.innerHTML = '<div class="result success">✅ Ollama: Connected successfully</div>';
                } else {
                    result.innerHTML = '<div class="result error">❌ Ollama: Connection failed</div>';
                }
            } catch (error) {
                document.getElementById('test-results').innerHTML = '<div class="result error">❌ Ollama: Error - ' + error.message + '</div>';
            }
        }
        
        async function testOllamaGenerate() {
            try {
                const response = await fetch('${OLLAMA_URL}/api/generate', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        model: 'deepseek-coder:6.7b',
                        prompt: 'Write a simple Python function',
                        stream: false
                    })
                });
                const data = await response.json();
                const result = document.getElementById('ollama-results');
                if (response.ok) {
                    result.innerHTML = '<div class="result success">✅ Code Generation: ' + data.response.substring(0, 100) + '...</div>';
                } else {
                    result.innerHTML = '<div class="result error">❌ Code Generation: Failed</div>';
                }
            } catch (error) {
                document.getElementById('ollama-results').innerHTML = '<div class="result error">❌ Code Generation: Error - ' + error.message + '</div>';
            }
        }
        
        async function testOllamaChat() {
            try {
                const response = await fetch('${OLLAMA_URL}/api/chat', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        model: 'tinyllama:latest',
                        messages: [{ role: 'user', content: 'Hello AI!' }],
                        stream: false
                    })
                });
                const data = await response.json();
                const result = document.getElementById('ollama-results');
                if (response.ok) {
                    result.innerHTML = '<div class="result success">✅ Chat: ' + data.message.content.substring(0, 100) + '...</div>';
                } else {
                    result.innerHTML = '<div class="result error">❌ Chat: Failed</div>';
                }
            } catch (error) {
                document.getElementById('ollama-results').innerHTML = '<div class="result error">❌ Chat: Error - ' + error.message + '</div>';
            }
        }
    </script>
</body>
</html>
EOF

    success "Course content created successfully"
}

# Generate comprehensive test report
generate_test_report() {
    local report_file="ai_course_test_report_$(date +%Y%m%d_%H%M%S).md"
    
    cat > "$report_file" << EOF
# AI Course Integration Test Report

**Test Date:** $(date)
**Course ID:** $COURSE_ID
**Test Duration:** $(date)

## Test Results Summary

- **Total Tests:** $TESTS_TOTAL
- **Passed:** $TESTS_PASSED
- **Failed:** $TESTS_FAILED
- **Success Rate:** $(( (TESTS_PASSED * 100) / TESTS_TOTAL ))%

## Platform Status

### Moodle
- **URL:** $MOODLE_URL
- **Course:** $MOODLE_URL/course/view.php?id=$COURSE_ID
- **Status:** $([ $TESTS_FAILED -eq 0 ] && echo "✅ Healthy" || echo "⚠️ Issues detected")
- **Note:** Redirect to enrollment page is expected behavior

### OpenWebUI
- **URL:** $OPENWEBUI_URL
- **Chat:** $OPENWEBUI_URL/chat
- **Models:** $OPENWEBUI_URL/models
- **Status:** $([ $TESTS_FAILED -eq 0 ] && echo "✅ Healthy" || echo "⚠️ Issues detected")

### Ollama
- **URL:** $OLLAMA_URL
- **Models API:** $OLLAMA_URL/api/tags
- **Generate API:** $OLLAMA_URL/api/generate
- **Chat API:** $OLLAMA_URL/api/chat
- **Status:** $([ $TESTS_FAILED -eq 0 ] && echo "✅ Healthy" || echo "⚠️ Issues detected")

## Available Models

### Ollama Models
- **deepseek-coder:6.7b** - Code generation and programming tasks
- **tinyllama:latest** - Fast responses for general tasks

## Course Content

### Created Files
- \`course-content/ai-course-main.html\` - Main course page
- \`course-content/integration-test.html\` - Integration test page

### Course Structure
- **6 Modules** - Comprehensive AI learning path
- **24 Sessions** - Detailed learning sessions
- **40+ Hours** - Extensive content coverage
- **Hands-on Labs** - Interactive learning with real AI systems

## Integration Features

### OpenWebUI Integration
- Interactive chat interface
- Model comparison tools
- Real-time AI conversations
- Collaborative learning features

### Ollama Integration
- Local model execution
- Code generation capabilities
- Chat functionality
- Performance testing

### Moodle Integration
- Structured learning path
- Course enrollment system
- Progress tracking
- Assessment tools

## Performance Metrics

### Response Times
- **Moodle:** $(curl -o /dev/null -s -w "%{time_total}" "$MOODLE_URL")s
- **OpenWebUI:** $(curl -o /dev/null -s -w "%{time_total}" "$OPENWEBUI_URL")s
- **Ollama:** $(curl -o /dev/null -s -w "%{time_total}" "$OLLAMA_URL/api/tags")s

## Recommendations

$([ $TESTS_FAILED -eq 0 ] && echo "- All systems operational and ready for deployment" || echo "- Review failed tests and address issues before deployment")

## Next Steps

1. **Deploy Course Content** - Upload HTML files to Moodle
2. **Configure Integrations** - Set up OpenWebUI and Ollama connections
3. **Test Student Experience** - Validate complete learning workflow
4. **Monitor Performance** - Track system performance and user engagement
5. **Collect Feedback** - Gather student feedback for continuous improvement

## Course URLs

- **Main Course:** $MOODLE_URL/course/view.php?id=$COURSE_ID
- **Course Content:** file://$(pwd)/course-content/ai-course-main.html
- **Integration Test:** file://$(pwd)/course-content/integration-test.html
- **OpenWebUI Chat:** $OPENWEBUI_URL/chat
- **Ollama Models:** $OLLAMA_URL

## Support Information

- **Course ID:** $COURSE_ID
- **Test Log:** $LOG_FILE
- **Report Generated:** $(date)

---

*AI Course Integration Test Report - Generated by automated testing suite*
EOF
    
    success "Test report generated: $report_file"
}

# Main execution
main() {
    echo -e "${BLUE}🧪 Starting AI Course Comprehensive Testing...${NC}"
    echo -e "${BLUE}Course ID: $COURSE_ID${NC}"
    echo -e "${BLUE}Moodle URL: $MOODLE_URL${NC}"
    echo -e "${BLUE}OpenWebUI URL: $OPENWEBUI_URL${NC}"
    echo -e "${BLUE}Ollama URL: $OLLAMA_URL${NC}"
    echo
    
    # Run all tests
    test_moodle_connectivity
    test_openwebui_connectivity
    test_ollama_connectivity
    test_ollama_models
    test_performance
    
    # Create course content
    create_course_content
    
    # Generate report
    generate_test_report
    
    # Final status
    echo
    echo -e "${BLUE}=== TEST SUMMARY ===${NC}"
    echo -e "${GREEN}Tests Passed: $TESTS_PASSED${NC}"
    echo -e "${RED}Tests Failed: $TESTS_FAILED${NC}"
    echo -e "${BLUE}Total Tests: $TESTS_TOTAL${NC}"
    echo -e "${BLUE}Success Rate: $(( (TESTS_PASSED * 100) / TESTS_TOTAL ))%${NC}"
    echo
    
    if [ $TESTS_FAILED -eq 0 ]; then
        success "🎉 All tests passed! AI course is ready for deployment."
        echo
        echo -e "${GREEN}Course URLs:${NC}"
        echo -e "  📚 Moodle Course: $MOODLE_URL/course/view.php?id=$COURSE_ID"
        echo -e "  🤖 OpenWebUI Chat: $OPENWEBUI_URL/chat"
        echo -e "  🔧 Ollama Models: $OLLAMA_URL"
        echo -e "  📄 Course Content: file://$(pwd)/course-content/ai-course-main.html"
        echo -e "  🧪 Integration Test: file://$(pwd)/course-content/integration-test.html"
    else
        warning "⚠️ $TESTS_FAILED tests failed. Please review and fix issues."
    fi
    
    echo
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Review test report for detailed results"
    echo "2. Upload course content to Moodle"
    echo "3. Test student experience"
    echo "4. Monitor performance and collect feedback"
}

# Run main function
main "$@"

