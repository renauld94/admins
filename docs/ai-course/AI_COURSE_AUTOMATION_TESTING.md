# 🚀 AI Course Automation & Testing Suite
## Complete CLI Automation and Testing Framework

**Target Platforms:** Moodle + OpenWebUI + Ollama  
**Course ID:** 22  
**Testing Scope:** Full integration testing, performance monitoring, automated deployment  

---

## 🎯 **AUTOMATION OVERVIEW**

### **Automation Goals**
- **Seamless Deployment:** One-command course setup
- **Continuous Testing:** Automated integration validation
- **Performance Monitoring:** Real-time platform health checks
- **Quality Assurance:** Automated content validation
- **Student Experience:** Optimized learning environment

### **Technology Stack**
- **Bash Scripts:** Core automation logic
- **cURL:** API testing and integration
- **jq:** JSON processing and validation
- **moosh:** Moodle command-line interface
- **Docker:** Containerized testing environments
- **GitHub Actions:** CI/CD pipeline (optional)

---

## 🔧 **CORE AUTOMATION SCRIPTS**

### **1. Course Setup Automation**
```bash
#!/bin/bash
# AI Course Complete Setup Automation
# Usage: ./setup_ai_course.sh [--course-id=22] [--modules=6] [--sessions=24]

set -euo pipefail

# Configuration
COURSE_ID=${1:-22}
MODULES=${2:-6}
SESSIONS=${3:-24}
MOODLE_URL="https://moodle.simondatalab.de"
OPENWEBUI_URL="https://openwebui.simondatalab.de"
OLLAMA_URL="https://ollama.simondatalab.de"
LOG_FILE="ai_course_setup.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
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

# Test platform connectivity
test_platform_connectivity() {
    log "Testing platform connectivity..."
    
    # Test Moodle
    if curl -s -o /dev/null -w "%{http_code}" "$MOODLE_URL/course/view.php?id=$COURSE_ID" | grep -q "200"; then
        success "Moodle connectivity: OK"
    else
        error "Moodle connectivity: FAILED"
        return 1
    fi
    
    # Test OpenWebUI
    if curl -s -o /dev/null -w "%{http_code}" "$OPENWEBUI_URL/api/v1/health" | grep -q "200"; then
        success "OpenWebUI connectivity: OK"
    else
        error "OpenWebUI connectivity: FAILED"
        return 1
    fi
    
    # Test Ollama
    if curl -s -o /dev/null -w "%{http_code}" "$OLLAMA_URL/api/tags" | grep -q "200"; then
        success "Ollama connectivity: OK"
    else
        error "Ollama connectivity: FAILED"
        return 1
    fi
}

# Create course structure
create_course_structure() {
    log "Creating course structure..."
    
    # Module 1: The AI Revolution Begins
    moosh -n section-config-set $COURSE_ID 1 name "Module 1: The AI Revolution Begins"
    moosh -n section-config-set $COURSE_ID 2 name "Session 1.1: Welcome to the AI Universe"
    moosh -n section-config-set $COURSE_ID 3 name "Session 1.2: The Building Blocks of Intelligence"
    moosh -n section-config-set $COURSE_ID 4 name "Session 1.3: Data - The Fuel of AI"
    moosh -n section-config-set $COURSE_ID 5 name "Session 1.4: Your First AI Model"
    
    # Module 2: Neural Networks - The Brain of AI
    moosh -n section-config-set $COURSE_ID 6 name "Module 2: Neural Networks - The Brain of AI"
    moosh -n section-config-set $COURSE_ID 7 name "Session 2.1: Neural Networks Demystified"
    moosh -n section-config-set $COURSE_ID 8 name "Session 2.2: Deep Learning Revolution"
    moosh -n section-config-set $COURSE_ID 9 name "Session 2.3: Computer Vision - AI's Eyes"
    moosh -n section-config-set $COURSE_ID 10 name "Session 2.4: Natural Language Processing - AI's Voice"
    
    # Module 3: Advanced AI Techniques
    moosh -n section-config-set $COURSE_ID 11 name "Module 3: Advanced AI Techniques"
    moosh -n section-config-set $COURSE_ID 12 name "Session 3.1: Reinforcement Learning - AI's Learning"
    moosh -n section-config-set $COURSE_ID 13 name "Session 3.2: Generative AI - AI's Creativity"
    moosh -n section-config-set $COURSE_ID 14 name "Session 3.3: Transfer Learning - AI's Knowledge Transfer"
    moosh -n section-config-set $COURSE_ID 15 name "Session 3.4: Ensemble Methods - AI's Teamwork"
    
    # Module 4: AI Agents & Orchestration
    moosh -n section-config-set $COURSE_ID 16 name "Module 4: AI Agents & Orchestration"
    moosh -n section-config-set $COURSE_ID 17 name "Session 4.1: Building AI Agents"
    moosh -n section-config-set $COURSE_ID 18 name "Session 4.2: Multi-Agent Systems"
    moosh -n section-config-set $COURSE_ID 19 name "Session 4.3: AI Orchestration & Workflows"
    moosh -n section-config-set $COURSE_ID 20 name "Session 4.4: AI in Production"
    
    # Module 5: Creative AI Applications
    moosh -n section-config-set $COURSE_ID 21 name "Module 5: Creative AI Applications"
    moosh -n section-config-set $COURSE_ID 22 name "Session 5.1: AI in Art & Music"
    moosh -n section-config-set $COURSE_ID 23 name "Session 5.2: AI in Storytelling & Games"
    
    # Module 6: AI Ethics, Impact & Future
    moosh -n section-config-set $COURSE_ID 24 name "Module 6: AI Ethics, Impact & Future"
    moosh -n section-config-set $COURSE_ID 25 name "Session 6.1: AI Ethics & Responsibility"
    moosh -n section-config-set $COURSE_ID 26 name "Session 6.2: The Future of AI"
    
    success "Course structure created successfully"
}

# Upload course materials
upload_course_materials() {
    log "Uploading course materials..."
    
    # Create directories if they don't exist
    mkdir -p course-materials/{visualizations,labs,assessments,assets}
    
    # Upload visualizations
    for file in course-materials/visualizations/*.html; do
        if [ -f "$file" ]; then
            moosh -n file-upload "$file" $COURSE_ID
            log "Uploaded: $(basename "$file")"
        fi
    done
    
    # Upload lab materials
    for file in course-materials/labs/*.html; do
        if [ -f "$file" ]; then
            moosh -n file-upload "$file" $COURSE_ID
            log "Uploaded: $(basename "$file")"
        fi
    done
    
    # Upload assessments
    for file in course-materials/assessments/*.xml; do
        if [ -f "$file" ]; then
            moosh -n quiz-import "$file" $COURSE_ID
            log "Uploaded: $(basename "$file")"
        fi
    done
    
    success "Course materials uploaded successfully"
}

# Configure integrations
configure_integrations() {
    log "Configuring platform integrations..."
    
    # Create integration configuration file
    cat > course-materials/integrations/config.json << EOF
{
  "moodle": {
    "url": "$MOODLE_URL",
    "course_id": $COURSE_ID,
    "api_endpoint": "$MOODLE_URL/webservice/rest/server.php"
  },
  "openwebui": {
    "url": "$OPENWEBUI_URL",
    "chat_endpoint": "$OPENWEBUI_URL/api/v1/chat",
    "models_endpoint": "$OPENWEBUI_URL/api/v1/models",
    "health_endpoint": "$OPENWEBUI_URL/api/v1/health"
  },
  "ollama": {
    "url": "$OLLAMA_URL",
    "generate_endpoint": "$OLLAMA_URL/api/generate",
    "chat_endpoint": "$OLLAMA_URL/api/chat",
    "models_endpoint": "$OLLAMA_URL/api/tags",
    "available_models": ["deepseek-coder:6.7b", "tinyllama:latest", "llama3.2:latest"]
  }
}
EOF
    
    success "Integration configuration created"
}

# Main execution
main() {
    log "Starting AI Course Setup..."
    log "Course ID: $COURSE_ID"
    log "Modules: $MODULES"
    log "Sessions: $SESSIONS"
    
    # Run setup steps
    test_platform_connectivity || exit 1
    create_course_structure
    upload_course_materials
    configure_integrations
    
    success "AI Course setup completed successfully! 🚀"
    log "Course URL: $MOODLE_URL/course/view.php?id=$COURSE_ID"
    log "Setup log: $LOG_FILE"
}

# Run main function
main "$@"
```

### **2. Integration Testing Suite**
```bash
#!/bin/bash
# AI Course Integration Testing Suite
# Usage: ./test_integrations.sh [--full] [--quick] [--performance]

set -euo pipefail

# Configuration
MOODLE_URL="https://moodle.simondatalab.de"
OPENWEBUI_URL="https://openwebui.simondatalab.de"
OLLAMA_URL="https://ollama.simondatalab.de"
COURSE_ID=22
TEST_MODE=${1:-"quick"}
LOG_FILE="integration_test.log"

# Test results
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test result tracking
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_result="$3"
    
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    
    echo -e "${BLUE}Running test: $test_name${NC}"
    
    if eval "$test_command" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ PASSED: $test_name${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}❌ FAILED: $test_name${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Moodle integration tests
test_moodle_integration() {
    echo -e "${BLUE}Testing Moodle Integration...${NC}"
    
    run_test "Moodle Course Access" \
        "curl -s -o /dev/null -w '%{http_code}' '$MOODLE_URL/course/view.php?id=$COURSE_ID' | grep -q '200'" \
        "200"
    
    run_test "Moodle API Access" \
        "curl -s -o /dev/null -w '%{http_code}' '$MOODLE_URL/webservice/rest/server.php' | grep -q '200'" \
        "200"
    
    run_test "Moodle Course Sections" \
        "moosh -n course-sections $COURSE_ID | grep -q 'Module 1'" \
        "Module 1 found"
}

# OpenWebUI integration tests
test_openwebui_integration() {
    echo -e "${BLUE}Testing OpenWebUI Integration...${NC}"
    
    run_test "OpenWebUI Health Check" \
        "curl -s -o /dev/null -w '%{http_code}' '$OPENWEBUI_URL/api/v1/health' | grep -q '200'" \
        "200"
    
    run_test "OpenWebUI Chat API" \
        "curl -s -o /dev/null -w '%{http_code}' '$OPENWEBUI_URL/api/v1/chat' | grep -q '200'" \
        "200"
    
    run_test "OpenWebUI Models API" \
        "curl -s -o /dev/null -w '%{http_code}' '$OPENWEBUI_URL/api/v1/models' | grep -q '200'" \
        "200"
    
    # Test actual chat functionality
    run_test "OpenWebUI Chat Functionality" \
        "curl -s -X POST '$OPENWEBUI_URL/api/v1/chat' -H 'Content-Type: application/json' -d '{\"model\":\"llama3.2\",\"messages\":[{\"role\":\"user\",\"content\":\"Hello\"}]}' | jq -r '.choices[0].message.content' | grep -q '.'" \
        "Response received"
}

# Ollama integration tests
test_ollama_integration() {
    echo -e "${BLUE}Testing Ollama Integration...${NC}"
    
    run_test "Ollama Models API" \
        "curl -s -o /dev/null -w '%{http_code}' '$OLLAMA_URL/api/tags' | grep -q '200'" \
        "200"
    
    run_test "Ollama Generate API" \
        "curl -s -o /dev/null -w '%{http_code}' '$OLLAMA_URL/api/generate' | grep -q '200'" \
        "200"
    
    run_test "Ollama Chat API" \
        "curl -s -o /dev/null -w '%{http_code}' '$OLLAMA_URL/api/chat' | grep -q '200'" \
        "200"
    
    # Test model availability
    run_test "DeepSeek Coder Model Available" \
        "curl -s '$OLLAMA_URL/api/tags' | jq -r '.models[].name' | grep -q 'deepseek-coder'" \
        "deepseek-coder model found"
    
    run_test "TinyLlama Model Available" \
        "curl -s '$OLLAMA_URL/api/tags' | jq -r '.models[].name' | grep -q 'tinyllama'" \
        "tinyllama model found"
}

# Performance tests
test_performance() {
    echo -e "${BLUE}Testing Performance...${NC}"
    
    # Test response times
    local moodle_time=$(curl -o /dev/null -s -w "%{time_total}" "$MOODLE_URL/course/view.php?id=$COURSE_ID")
    local openwebui_time=$(curl -o /dev/null -s -w "%{time_total}" "$OPENWEBUI_URL/api/v1/health")
    local ollama_time=$(curl -o /dev/null -s -w "%{time_total}" "$OLLAMA_URL/api/tags")
    
    run_test "Moodle Response Time < 3s" \
        "echo '$moodle_time < 3.0' | bc -l | grep -q '1'" \
        "Moodle response time: ${moodle_time}s"
    
    run_test "OpenWebUI Response Time < 2s" \
        "echo '$openwebui_time < 2.0' | bc -l | grep -q '1'" \
        "OpenWebUI response time: ${openwebui_time}s"
    
    run_test "Ollama Response Time < 5s" \
        "echo '$ollama_time < 5.0' | bc -l | grep -q '1'" \
        "Ollama response time: ${ollama_time}s"
}

# Full integration test
test_full_integration() {
    echo -e "${BLUE}Testing Full Integration...${NC}"
    
    # Test complete workflow
    run_test "Complete AI Workflow" \
        "curl -s -X POST '$OLLAMA_URL/api/generate' -H 'Content-Type: application/json' -d '{\"model\":\"deepseek-coder:6.7b\",\"prompt\":\"Write a simple Python function\"}' | jq -r '.response' | grep -q 'def'" \
        "Code generation successful"
    
    run_test "OpenWebUI to Ollama Integration" \
        "curl -s -X POST '$OPENWEBUI_URL/api/v1/chat' -H 'Content-Type: application/json' -d '{\"model\":\"llama3.2\",\"messages\":[{\"role\":\"user\",\"content\":\"Explain neural networks\"}]}' | jq -r '.choices[0].message.content' | grep -q 'neural'" \
        "AI explanation successful"
}

# Generate test report
generate_test_report() {
    local report_file="test_report_$(date +%Y%m%d_%H%M%S).md"
    
    cat > "$report_file" << EOF
# AI Course Integration Test Report

**Test Date:** $(date)
**Test Mode:** $TEST_MODE
**Course ID:** $COURSE_ID

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

### OpenWebUI
- **URL:** $OPENWEBUI_URL
- **Status:** $([ $TESTS_FAILED -eq 0 ] && echo "✅ Healthy" || echo "⚠️ Issues detected")

### Ollama
- **URL:** $OLLAMA_URL
- **Status:** $([ $TESTS_FAILED -eq 0 ] && echo "✅ Healthy" || echo "⚠️ Issues detected")

## Recommendations

$([ $TESTS_FAILED -eq 0 ] && echo "- All systems operational" || echo "- Review failed tests and address issues")

## Next Steps

1. Monitor platform performance
2. Run regular integration tests
3. Update course content as needed
4. Collect student feedback

EOF
    
    echo -e "${GREEN}Test report generated: $report_file${NC}"
}

# Main execution
main() {
    echo -e "${BLUE}Starting AI Course Integration Tests...${NC}"
    echo -e "${BLUE}Test Mode: $TEST_MODE${NC}"
    
    # Run tests based on mode
    case $TEST_MODE in
        "full")
            test_moodle_integration
            test_openwebui_integration
            test_ollama_integration
            test_performance
            test_full_integration
            ;;
        "quick")
            test_moodle_integration
            test_openwebui_integration
            test_ollama_integration
            ;;
        "performance")
            test_performance
            ;;
        *)
            echo "Usage: $0 [--full|--quick|--performance]"
            exit 1
            ;;
    esac
    
    # Generate report
    generate_test_report
    
    # Final status
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}🎉 All tests passed! Integration is healthy.${NC}"
        exit 0
    else
        echo -e "${RED}⚠️ $TESTS_FAILED tests failed. Please review and fix issues.${NC}"
        exit 1
    fi
}

# Run main function
main "$@"
```

### **3. Performance Monitoring Script**
```bash
#!/bin/bash
# AI Course Performance Monitoring
# Usage: ./monitor_performance.sh [--continuous] [--interval=60]

set -euo pipefail

# Configuration
MOODLE_URL="https://moodle.simondatalab.de"
OPENWEBUI_URL="https://openwebui.simondatalab.de"
OLLAMA_URL="https://ollama.simondatalab.de"
COURSE_ID=22
INTERVAL=${1:-60}
CONTINUOUS=${2:-false}
LOG_FILE="performance_monitor.log"

# Performance thresholds
MOODLE_THRESHOLD=3.0
OPENWEBUI_THRESHOLD=2.0
OLLAMA_THRESHOLD=5.0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Performance metrics
declare -A metrics
declare -A alerts

# Logging
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

# Check platform performance
check_platform_performance() {
    local platform="$1"
    local url="$2"
    local threshold="$3"
    
    local response_time=$(curl -o /dev/null -s -w "%{time_total}" "$url")
    local http_code=$(curl -o /dev/null -s -w "%{http_code}" "$url")
    
    metrics["${platform}_response_time"]=$response_time
    metrics["${platform}_http_code"]=$http_code
    
    if (( $(echo "$response_time > $threshold" | bc -l) )); then
        alerts["${platform}_slow"]="true"
        echo -e "${RED}⚠️ $platform: ${response_time}s (slow)${NC}"
    else
        alerts["${platform}_slow"]="false"
        echo -e "${GREEN}✅ $platform: ${response_time}s (good)${NC}"
    fi
    
    if [ "$http_code" != "200" ]; then
        alerts["${platform}_error"]="true"
        echo -e "${RED}❌ $platform: HTTP $http_code${NC}"
    else
        alerts["${platform}_error"]="false"
    fi
}

# Check Ollama model performance
check_ollama_models() {
    log "Checking Ollama model performance..."
    
    local models=("deepseek-coder:6.7b" "tinyllama:latest" "llama3.2:latest")
    
    for model in "${models[@]}"; do
        local start_time=$(date +%s.%N)
        local response=$(curl -s -X POST "$OLLAMA_URL/api/generate" \
            -H "Content-Type: application/json" \
            -d "{\"model\":\"$model\",\"prompt\":\"Hello\",\"stream\":false}")
        local end_time=$(date +%s.%N)
        local duration=$(echo "$end_time - $start_time" | bc)
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ $model: ${duration}s${NC}"
            metrics["ollama_${model}_response_time"]=$duration
        else
            echo -e "${RED}❌ $model: Failed${NC}"
            alerts["ollama_${model}_error"]="true"
        fi
    done
}

# Check OpenWebUI chat performance
check_openwebui_chat() {
    log "Checking OpenWebUI chat performance..."
    
    local start_time=$(date +%s.%N)
    local response=$(curl -s -X POST "$OPENWEBUI_URL/api/v1/chat" \
        -H "Content-Type: application/json" \
        -d '{"model":"llama3.2","messages":[{"role":"user","content":"Hello"}]}')
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc)
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ OpenWebUI Chat: ${duration}s${NC}"
        metrics["openwebui_chat_response_time"]=$duration
    else
        echo -e "${RED}❌ OpenWebUI Chat: Failed${NC}"
        alerts["openwebui_chat_error"]="true"
    fi
}

# Generate performance report
generate_performance_report() {
    local report_file="performance_report_$(date +%Y%m%d_%H%M%S).json"
    
    cat > "$report_file" << EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "course_id": $COURSE_ID,
  "metrics": {
    "moodle_response_time": ${metrics["moodle_response_time"]:-0},
    "moodle_http_code": ${metrics["moodle_http_code"]:-0},
    "openwebui_response_time": ${metrics["openwebui_response_time"]:-0},
    "openwebui_http_code": ${metrics["openwebui_http_code"]:-0},
    "ollama_response_time": ${metrics["ollama_response_time"]:-0},
    "ollama_http_code": ${metrics["ollama_http_code"]:-0}
  },
  "alerts": {
    "moodle_slow": ${alerts["moodle_slow"]:-false},
    "moodle_error": ${alerts["moodle_error"]:-false},
    "openwebui_slow": ${alerts["openwebui_slow"]:-false},
    "openwebui_error": ${alerts["openwebui_error"]:-false},
    "ollama_slow": ${alerts["ollama_slow"]:-false},
    "ollama_error": ${alerts["ollama_error"]:-false}
  },
  "thresholds": {
    "moodle_threshold": $MOODLE_THRESHOLD,
    "openwebui_threshold": $OPENWEBUI_THRESHOLD,
    "ollama_threshold": $OLLAMA_THRESHOLD
  }
}
EOF
    
    log "Performance report generated: $report_file"
}

# Send alerts
send_alerts() {
    local alert_count=0
    
    for alert in "${!alerts[@]}"; do
        if [ "${alerts[$alert]}" = "true" ]; then
            alert_count=$((alert_count + 1))
        fi
    done
    
    if [ $alert_count -gt 0 ]; then
        log "⚠️ $alert_count alerts detected"
        # Here you could integrate with notification systems
        # e.g., Slack, email, Discord, etc.
    fi
}

# Main monitoring loop
monitor_performance() {
    log "Starting performance monitoring..."
    log "Interval: ${INTERVAL}s"
    log "Continuous: $CONTINUOUS"
    
    while true; do
        echo -e "${BLUE}=== Performance Check $(date) ===${NC}"
        
        # Check platform performance
        check_platform_performance "moodle" "$MOODLE_URL/course/view.php?id=$COURSE_ID" $MOODLE_THRESHOLD
        check_platform_performance "openwebui" "$OPENWEBUI_URL/api/v1/health" $OPENWEBUI_THRESHOLD
        check_platform_performance "ollama" "$OLLAMA_URL/api/tags" $OLLAMA_THRESHOLD
        
        # Check specific functionality
        check_ollama_models
        check_openwebui_chat
        
        # Generate report
        generate_performance_report
        
        # Send alerts
        send_alerts
        
        if [ "$CONTINUOUS" = "false" ]; then
            break
        fi
        
        echo -e "${BLUE}Waiting ${INTERVAL}s for next check...${NC}"
        sleep $INTERVAL
    done
}

# Main execution
main() {
    echo -e "${BLUE}AI Course Performance Monitor${NC}"
    echo -e "${BLUE}Course ID: $COURSE_ID${NC}"
    echo -e "${BLUE}Monitoring URL: $MOODLE_URL/course/view.php?id=$COURSE_ID${NC}"
    
    monitor_performance
}

# Run main function
main "$@"
```

---

## 🧪 **TESTING RECOMMENDATIONS**

### **1. API Testing with cURL**

#### **OpenWebUI API Tests**
```bash
#!/bin/bash
# OpenWebUI API Testing Suite

OPENWEBUI_URL="https://openwebui.simondatalab.de"

echo "Testing OpenWebUI API..."

# Test health endpoint
echo "1. Testing health endpoint..."
curl -s "$OPENWEBUI_URL/api/v1/health" | jq '.'

# Test models endpoint
echo "2. Testing models endpoint..."
curl -s "$OPENWEBUI_URL/api/v1/models" | jq '.'

# Test chat endpoint
echo "3. Testing chat endpoint..."
curl -s -X POST "$OPENWEBUI_URL/api/v1/chat" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama3.2",
    "messages": [
      {"role": "user", "content": "Explain artificial intelligence in simple terms"}
    ],
    "stream": false
  }' | jq '.'

# Test chat with streaming
echo "4. Testing chat with streaming..."
curl -s -X POST "$OPENWEBUI_URL/api/v1/chat" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama3.2",
    "messages": [
      {"role": "user", "content": "Write a simple Python function"}
    ],
    "stream": true
  }'

echo "OpenWebUI API tests completed!"
```

#### **Ollama API Tests**
```bash
#!/bin/bash
# Ollama API Testing Suite

OLLAMA_URL="https://ollama.simondatalab.de"

echo "Testing Ollama API..."

# Test models endpoint
echo "1. Testing models endpoint..."
curl -s "$OLLAMA_URL/api/tags" | jq '.'

# Test generate endpoint
echo "2. Testing generate endpoint..."
curl -s -X POST "$OLLAMA_URL/api/generate" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "deepseek-coder:6.7b",
    "prompt": "Write a Python function to calculate fibonacci numbers",
    "stream": false
  }' | jq '.'

# Test chat endpoint
echo "3. Testing chat endpoint..."
curl -s -X POST "$OLLAMA_URL/api/chat" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama3.2",
    "messages": [
      {"role": "user", "content": "What is machine learning?"}
    ],
    "stream": false
  }' | jq '.'

# Test model pulling
echo "4. Testing model pulling..."
curl -s -X POST "$OLLAMA_URL/api/pull" \
  -H "Content-Type: application/json" \
  -d '{"name": "codellama:7b"}' | jq '.'

echo "Ollama API tests completed!"
```

#### **Moodle API Tests**
```bash
#!/bin/bash
# Moodle API Testing Suite

MOODLE_URL="https://moodle.simondatalab.de"
COURSE_ID=22
TOKEN="your_moodle_token"  # Replace with actual token

echo "Testing Moodle API..."

# Test course access
echo "1. Testing course access..."
curl -s "$MOODLE_URL/course/view.php?id=$COURSE_ID" | grep -q "AI MASTERY" && echo "✅ Course accessible" || echo "❌ Course not accessible"

# Test course info API
echo "2. Testing course info API..."
curl -s "$MOODLE_URL/webservice/rest/server.php?wstoken=$TOKEN&wsfunction=core_course_get_courses&moodlewsrestformat=json" | jq '.'

# Test course sections API
echo "3. Testing course sections API..."
curl -s "$MOODLE_URL/webservice/rest/server.php?wstoken=$TOKEN&wsfunction=core_course_get_contents&courseid=$COURSE_ID&moodlewsrestformat=json" | jq '.'

# Test user info API
echo "4. Testing user info API..."
curl -s "$MOODLE_URL/webservice/rest/server.php?wstoken=$TOKEN&wsfunction=core_webservice_get_site_info&moodlewsrestformat=json" | jq '.'

echo "Moodle API tests completed!"
```

### **2. Load Testing**

#### **Load Testing Script**
```bash
#!/bin/bash
# Load Testing for AI Course Platforms

echo "Starting load testing..."

# Test OpenWebUI under load
echo "Testing OpenWebUI under load..."
for i in {1..10}; do
    curl -s -X POST "https://openwebui.simondatalab.de/api/v1/chat" \
      -H "Content-Type: application/json" \
      -d '{"model":"llama3.2","messages":[{"role":"user","content":"Hello"}]}' &
done
wait

# Test Ollama under load
echo "Testing Ollama under load..."
for i in {1..5}; do
    curl -s -X POST "https://ollama.simondatalab.de/api/generate" \
      -H "Content-Type: application/json" \
      -d '{"model":"deepseek-coder:6.7b","prompt":"Write code"}' &
done
wait

# Test Moodle under load
echo "Testing Moodle under load..."
for i in {1..20}; do
    curl -s "https://moodle.simondatalab.de/course/view.php?id=22" &
done
wait

echo "Load testing completed!"
```

### **3. Automated Testing Pipeline**

#### **GitHub Actions Workflow** (Optional)
```yaml
# .github/workflows/ai-course-testing.yml
name: AI Course Integration Testing

on:
  schedule:
    - cron: '0 */6 * * *'  # Every 6 hours
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test-integration:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup dependencies
      run: |
        sudo apt-get update
        sudo apt-get install -y curl jq bc
    
    - name: Test Moodle Integration
      run: |
        curl -s -o /dev/null -w "%{http_code}" "https://moodle.simondatalab.de/course/view.php?id=22" | grep -q "200"
    
    - name: Test OpenWebUI Integration
      run: |
        curl -s -o /dev/null -w "%{http_code}" "https://openwebui.simondatalab.de/api/v1/health" | grep -q "200"
    
    - name: Test Ollama Integration
      run: |
        curl -s -o /dev/null -w "%{http_code}" "https://ollama.simondatalab.de/api/tags" | grep -q "200"
    
    - name: Run Performance Tests
      run: |
        ./test_integrations.sh --performance
    
    - name: Generate Test Report
      run: |
        ./test_integrations.sh --full
        cp test_report_*.md test_report.md
    
    - name: Upload Test Report
      uses: actions/upload-artifact@v3
      with:
        name: test-report
        path: test_report.md
```

---

## 📊 **MONITORING DASHBOARD**

### **Real-time Monitoring Script**
```bash
#!/bin/bash
# Real-time AI Course Monitoring Dashboard

# Configuration
MOODLE_URL="https://moodle.simondatalab.de"
OPENWEBUI_URL="https://openwebui.simondatalab.de"
OLLAMA_URL="https://ollama.simondatalab.de"
COURSE_ID=22

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Clear screen and show header
clear
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    AI COURSE MONITORING DASHBOARD            ║${NC}"
echo -e "${BLUE}║                    $(date)                    ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo

# Function to check status
check_status() {
    local name="$1"
    local url="$2"
    local response_time=$(curl -o /dev/null -s -w "%{time_total}" "$url")
    local http_code=$(curl -o /dev/null -s -w "%{http_code}" "$url")
    
    if [ "$http_code" = "200" ]; then
        echo -e "${GREEN}✅ $name: ${response_time}s${NC}"
    else
        echo -e "${RED}❌ $name: HTTP $http_code${NC}"
    fi
}

# Function to check Ollama models
check_ollama_models() {
    echo -e "${BLUE}Ollama Models:${NC}"
    curl -s "$OLLAMA_URL/api/tags" | jq -r '.models[].name' | while read model; do
        echo -e "  ${GREEN}📦 $model${NC}"
    done
}

# Main monitoring loop
while true; do
    echo -e "${BLUE}Platform Status:${NC}"
    check_status "Moodle Course" "$MOODLE_URL/course/view.php?id=$COURSE_ID"
    check_status "OpenWebUI" "$OPENWEBUI_URL/api/v1/health"
    check_status "Ollama" "$OLLAMA_URL/api/tags"
    
    echo
    check_ollama_models
    
    echo
    echo -e "${BLUE}Course Analytics:${NC}"
    echo -e "  ${GREEN}📚 Course ID: $COURSE_ID${NC}"
    echo -e "  ${GREEN}🌐 Course URL: $MOODLE_URL/course/view.php?id=$COURSE_ID${NC}"
    echo -e "  ${GREEN}🤖 OpenWebUI: $OPENWEBUI_URL${NC}"
    echo -e "  ${GREEN}🔧 Ollama: $OLLAMA_URL${NC}"
    
    echo
    echo -e "${YELLOW}Press Ctrl+C to exit${NC}"
    sleep 30
    clear
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                    AI COURSE MONITORING DASHBOARD            ║${NC}"
    echo -e "${BLUE}║                    $(date)                    ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
done
```

---

## 🚀 **DEPLOYMENT AUTOMATION**

### **Complete Deployment Script**
```bash
#!/bin/bash
# Complete AI Course Deployment Automation

set -euo pipefail

echo "🚀 Starting AI Course Deployment..."

# Run all automation scripts
echo "1. Setting up course structure..."
./setup_ai_course.sh --course-id=22 --modules=6 --sessions=24

echo "2. Running integration tests..."
./test_integrations.sh --full

echo "3. Starting performance monitoring..."
./monitor_performance.sh --continuous=false

echo "4. Generating deployment report..."
cat > deployment_report.md << EOF
# AI Course Deployment Report

**Deployment Date:** $(date)
**Course ID:** 22
**Status:** ✅ Successfully Deployed

## Platform Status
- **Moodle:** ✅ Operational
- **OpenWebUI:** ✅ Operational  
- **Ollama:** ✅ Operational

## Course Structure
- **Modules:** 6
- **Sessions:** 24
- **Duration:** 40+ hours

## Next Steps
1. Monitor student engagement
2. Collect feedback
3. Optimize based on usage data
4. Plan future enhancements

## Course URL
https://moodle.simondatalab.de/course/view.php?id=22
EOF

echo "🎉 AI Course deployment completed successfully!"
echo "📊 Course URL: https://moodle.simondatalab.de/course/view.php?id=22"
echo "📋 Deployment report: deployment_report.md"
```

---

## 📋 **IMPLEMENTATION CHECKLIST**

### **Pre-Deployment**
- [ ] Verify all platform URLs are accessible
- [ ] Test API endpoints with cURL
- [ ] Validate course content and materials
- [ ] Check visual asset compatibility
- [ ] Test integration workflows

### **Deployment**
- [ ] Run course setup automation
- [ ] Execute integration tests
- [ ] Validate performance metrics
- [ ] Test student experience
- [ ] Verify all features work correctly

### **Post-Deployment**
- [ ] Monitor platform performance
- [ ] Track student engagement
- [ ] Collect feedback and analytics
- [ ] Optimize based on data
- [ ] Plan future enhancements

---

This comprehensive automation and testing suite provides everything needed to deploy, monitor, and maintain the AI course with confidence. The scripts ensure reliable operation, optimal performance, and continuous quality assurance across all integrated platforms.

**Ready to deploy the epic AI course with full automation! 🚀🤖**

