#!/bin/bash

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  🎓 EPIC VIETNAMESE COURSE - COMPREHENSIVE AGENT TEST SUITE  ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

test_count=0
pass_count=0
fail_count=0

function test_endpoint() {
    local name=$1
    local method=$2
    local endpoint=$3
    local params=$4
    local expected_status=$5
    
    test_count=$((test_count + 1))
    
    echo -e "${BLUE}Test ${test_count}: ${name}${NC}"
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" "$endpoint$params")
    else
        response=$(curl -s -w "\n%{http_code}" -X POST "$endpoint$params")
    fi
    
    status=$(echo "$response" | tail -1)
    body=$(echo "$response" | head -n -1)
    
    if [ "$status" = "$expected_status" ]; then
        echo -e "${GREEN}✅ PASS${NC} (HTTP $status)"
        pass_count=$((pass_count + 1))
    else
        echo -e "${RED}❌ FAIL${NC} (Expected $expected_status, got $status)"
        fail_count=$((fail_count + 1))
    fi
    echo ""
}

# Test Orchestrator
echo -e "${YELLOW}═══ 1. ORCHESTRATOR TESTS (Port 5100) ═══${NC}"
test_endpoint "Orchestrator Health" "GET" "http://localhost:5100" "/health" "200"
test_endpoint "Orchestrator Dashboard" "GET" "http://localhost:5100" "/dashboard" "200"
test_endpoint "Agent Status" "GET" "http://localhost:5100" "/agents/status" "200"

# Test Code Agent
echo -e "${YELLOW}═══ 2. CODE AGENT TESTS (Port 5101) ═══${NC}"
test_endpoint "Code Agent Health" "GET" "http://localhost:5101" "/health" "200"
test_endpoint "Code Help Endpoint" "POST" "http://localhost:5101" "/help?topic=Python%20Functions" "200"

# Test Data Agent
echo -e "${YELLOW}═══ 3. DATA AGENT TESTS (Port 5102) ═══${NC}"
test_endpoint "Data Agent Health" "GET" "http://localhost:5102" "/health" "200"
test_endpoint "Data Insights" "POST" "http://localhost:5102" "/insights?metric=learning_progress" "200"

# Test Course Agent
echo -e "${YELLOW}═══ 4. COURSE AGENT TESTS (Port 5103) ═══${NC}"
test_endpoint "Course Agent Health" "GET" "http://localhost:5103" "/health" "200"
test_endpoint "Generate Lesson" "POST" "http://localhost:5103" "/generate-lesson?topic=Vietnamese%20Alphabet&level=beginner" "200"

# Test Tutor Agent
echo -e "${YELLOW}═══ 5. TUTOR AGENT TESTS (Port 5104) ═══${NC}"
test_endpoint "Tutor Agent Health" "GET" "http://localhost:5104" "/health" "200"
test_endpoint "Personalized Guidance" "POST" "http://localhost:5104" "/personalized-guidance?student_id=s001&student_name=Nguy%E1%BB%85n" "200"

# Test Multimedia Service
echo -e "${YELLOW}═══ 6. MULTIMEDIA SERVICE TESTS (Port 5105) ═══${NC}"
test_endpoint "Multimedia Health" "GET" "http://localhost:5105" "/health" "200"
test_endpoint "TTS Synthesis" "POST" "http://localhost:5105" "/audio/tts-synthesize?text=Xin%20ch%C3%A0o" "200"

# Test Orchestrator Main Endpoint
echo -e "${YELLOW}═══ 7. ORCHESTRATOR INTEGRATION TESTS ═══${NC}"
test_endpoint "Personalized Lesson" "POST" "http://localhost:5100" "/personalized-lesson?student_name=Test&topic=Greetings&level=beginner" "200"

# Summary
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    TEST SUMMARY                               ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo "Total Tests: $test_count"
echo -e "${GREEN}Passed: $pass_count${NC}"
echo -e "${RED}Failed: $fail_count${NC}"
echo ""

if [ $fail_count -eq 0 ]; then
    echo -e "${GREEN}✅ ALL TESTS PASSED - SYSTEM READY FOR PRODUCTION${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed - Please review errors above${NC}"
    exit 1
fi
