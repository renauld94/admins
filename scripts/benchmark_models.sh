#!/bin/bash

# AI Model Performance Benchmark Script
# Tests coding assistant models for speed and quality

echo "🧪 AI Model Performance Benchmark"
echo "=================================="
echo "Timestamp: $(date)"
echo ""

# Configuration
JUMP_HOST="root@136.243.155.166:2222"
VM_USER="simonadmin"
VM_IP="10.0.0.111"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Test prompts for coding tasks
SIMPLE_PROMPT="Write a Python function to sort a list of numbers"
COMPLEX_PROMPT="Create a Python class for a binary search tree with insert, delete, and search methods"
DEBUG_PROMPT="Debug this Python code: def factorial(n): return n * factorial(n-1) if n > 1 else 1"

echo "🔍 Testing Model Availability..."
MODELS=$(curl -s --max-time 10 https://ollama.simondatalab.de/api/tags 2>/dev/null)

if [ $? -eq 0 ] && [ -n "$MODELS" ]; then
    AVAILABLE_MODELS=$(echo "$MODELS" | jq -r '.models[].name' 2>/dev/null)
    print_status "Models available: $AVAILABLE_MODELS"
else
    print_error "Cannot retrieve available models"
    exit 1
fi

echo ""
echo "⚡ Running Performance Tests..."

# Function to test a model
test_model() {
    local model_name=$1
    local prompt=$2
    local test_name=$3
    
    echo "   Testing $model_name - $test_name..."
    
    # Test via API
    START_TIME=$(date +%s.%N)
    RESPONSE=$(curl -s --max-time 30 -X POST https://ollama.simondatalab.de/api/generate \
        -H "Content-Type: application/json" \
        -d "{\"model\": \"$model_name\", \"prompt\": \"$prompt\", \"stream\": false}" 2>/dev/null)
    END_TIME=$(date +%s.%N)
    
    if [ $? -eq 0 ] && [ -n "$RESPONSE" ]; then
        DURATION=$(echo "$END_TIME - $START_TIME" | bc)
        RESPONSE_LENGTH=$(echo "$RESPONSE" | jq -r '.response' | wc -c)
        
        print_status "✅ $model_name - $test_name"
        echo "      Time: ${DURATION}s"
        echo "      Response Length: ${RESPONSE_LENGTH} characters"
        
        # Store results
        echo "$model_name,$test_name,$DURATION,$RESPONSE_LENGTH" >> benchmark_results.csv
    else
        print_error "❌ $model_name - $test_name failed"
    fi
}

# Initialize results file
echo "Model,Test,Time,ResponseLength" > benchmark_results.csv

# Test available models
if echo "$AVAILABLE_MODELS" | grep -q "deepseek-coder"; then
    echo ""
    echo "🧠 Testing DeepSeek Coder 6.7B..."
    test_model "deepseek-coder:6.7b" "$SIMPLE_PROMPT" "Simple Task"
    test_model "deepseek-coder:6.7b" "$COMPLEX_PROMPT" "Complex Task"
    test_model "deepseek-coder:6.7b" "$DEBUG_PROMPT" "Debug Task"
fi

if echo "$AVAILABLE_MODELS" | grep -q "tinyllama"; then
    echo ""
    echo "🚀 Testing TinyLlama..."
    test_model "tinyllama:latest" "$SIMPLE_PROMPT" "Simple Task"
    test_model "tinyllama:latest" "$COMPLEX_PROMPT" "Complex Task"
fi

echo ""
echo "📊 Benchmark Results Summary:"
if [ -f benchmark_results.csv ]; then
    echo "Model Performance Comparison:"
    echo "=============================="
    
    # Calculate averages
    while IFS=',' read -r model test time length; do
        if [ "$test" != "Test" ]; then
            echo "   $model - $test: ${time}s (${length} chars)"
        fi
    done < benchmark_results.csv
    
    print_status "Detailed results saved to benchmark_results.csv"
else
    print_warning "No benchmark results generated"
fi

echo ""
echo "🎯 Performance Recommendations:"

# Analyze results and provide recommendations
if echo "$AVAILABLE_MODELS" | grep -q "deepseek-coder"; then
    print_info "DeepSeek Coder 6.7B: Best for complex coding tasks"
    echo "   - Use for: Architecture design, debugging, complex algorithms"
    echo "   - Optimal settings: temperature=0.1, max_tokens=4096"
fi

if echo "$AVAILABLE_MODELS" | grep -q "tinyllama"; then
    print_info "TinyLlama: Best for quick responses and simple tasks"
    echo "   - Use for: Quick prototypes, simple scripts, fast responses"
    echo "   - Optimal settings: temperature=0.2, max_tokens=2048"
fi

echo ""
echo "🔧 Optimization Suggestions:"
echo "   1. For faster responses: Use TinyLlama for simple tasks"
echo "   2. For better quality: Use DeepSeek Coder for complex tasks"
echo "   3. For mixed workloads: Configure both models in OpenWebUI"
echo "   4. For performance: Monitor resource usage during inference"

echo ""
echo "📈 Next Steps:"
echo "   - Review benchmark results"
echo "   - Configure OpenWebUI with optimal settings"
echo "   - Test with your specific coding tasks"
echo "   - Consider adding more models (CodeLlama, StarCoder)"

# Cleanup
rm -f benchmark_results.csv 2>/dev/null

echo ""
print_status "Benchmark completed! Check the results above for optimization insights."
