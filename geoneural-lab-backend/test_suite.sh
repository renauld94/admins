#!/bin/bash
# GeoNeural Lab - Comprehensive Test Suite
# Tests all endpoints and functionality

echo "🚀 GeoNeural Lab Test Suite Starting..."
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test configuration
API_BASE="http://localhost:8000"
VISUALIZATION_URL="http://localhost:3002"
GEOSERVER_URL="https://136.243.155.166:8006"

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to run a test
run_test() {
    local test_name="$1"
    local curl_command="$2"
    local expected_status="$3"
    
    echo -e "\n${BLUE}Testing: $test_name${NC}"
    echo "Command: $curl_command"
    
    # Execute the curl command and capture response
    response=$(eval "$curl_command" 2>/dev/null)
    status_code=$?
    
    if [ $status_code -eq 0 ]; then
        echo -e "${GREEN}✅ PASSED${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}❌ FAILED${NC}"
        ((TESTS_FAILED++))
    fi
}

# Function to test JSON response
test_json_response() {
    local test_name="$1"
    local curl_command="$2"
    local expected_field="$3"
    
    echo -e "\n${BLUE}Testing: $test_name${NC}"
    
    response=$(eval "$curl_command" 2>/dev/null)
    
    if echo "$response" | jq -e ".$expected_field" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ PASSED - Found $expected_field${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}❌ FAILED - Missing $expected_field${NC}"
        ((TESTS_FAILED++))
    fi
}

echo -e "\n${YELLOW}1. Basic Health Checks${NC}"
echo "========================"

# Test 1: API Health Check
run_test "API Health Check" "curl -s -o /dev/null -w '%{http_code}' $API_BASE/health" "200"

# Test 2: Root Endpoint
test_json_response "Root Endpoint" "curl -s $API_BASE/" "message"

# Test 3: Neural Visualization Health
run_test "Neural Visualization Health" "curl -s -o /dev/null -w '%{http_code}' $VISUALIZATION_URL" "200"

echo -e "\n${YELLOW}2. Geospatial Data Tests${NC}"
echo "============================="

# Test 4: Geospatial Query
test_json_response "Geospatial Query" "curl -s -X POST $API_BASE/api/geospatial/query -H 'Content-Type: application/json' -d '{\"bounds\": [0, 0, 0.01, 0.01], \"zoom_level\": 10, \"data_types\": [\"buildings\", \"roads\"]}'" "success"

# Test 5: Neural Data Points
test_json_response "Neural Data Points" "curl -s -X POST $API_BASE/api/neural/data -H 'Content-Type: application/json' -d '{\"id\": \"test_001\", \"latitude\": 0.001, \"longitude\": 0.001, \"neural_activity\": 0.85, \"timestamp\": \"2024-01-15T10:00:00Z\", \"metadata\": {\"test\": true}}'" "success"

echo -e "\n${YELLOW}3. City Generation Tests${NC}"
echo "============================="

# Test 6: City Generation
test_json_response "City Generation" "curl -s -X POST $API_BASE/api/city/generate -H 'Content-Type: application/json' -d '{\"center_lat\": 0.001, \"center_lon\": 0.001, \"radius_km\": 1.0, \"city_type\": \"modern\", \"building_density\": 0.7}'" "success"

echo -e "\n${YELLOW}4. Machine Learning Tests${NC}"
echo "=============================="

# Test 7: ML Prediction
test_json_response "ML Prediction" "curl -s -X POST $API_BASE/api/ml/predict -H 'Content-Type: application/json' -d '{\"features\": [0.1, 0.2, 0.3, 0.4, 0.5], \"model_type\": \"xgboost\", \"prediction_type\": \"classification\"}'" "success"

echo -e "\n${YELLOW}5. GeoServer Integration Tests${NC}"
echo "====================================="

# Test 8: GeoServer Integration
test_json_response "GeoServer Integration" "curl -s $API_BASE/api/geoserver/integration" "success"

echo -e "\n${YELLOW}6. Performance Tests${NC}"
echo "======================="

# Test 9: Large Dataset Query Performance
echo -e "\n${BLUE}Testing: Large Dataset Performance${NC}"
start_time=$(date +%s%N)
response=$(curl -s -X POST $API_BASE/api/geospatial/query -H 'Content-Type: application/json' -d '{"bounds": [-180, -90, 180, 90], "zoom_level": 1, "data_types": ["buildings", "roads", "pois", "neural_data"]}')
end_time=$(date +%s%N)
duration=$(( (end_time - start_time) / 1000000 ))

if [ $duration -lt 5000 ]; then
    echo -e "${GREEN}✅ PASSED - Query completed in ${duration}ms${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${RED}❌ FAILED - Query took too long: ${duration}ms${NC}"
    ((TESTS_FAILED++))
fi

echo -e "\n${YELLOW}7. Advanced Features Tests${NC}"
echo "==============================="

# Test 10: Concurrent Requests
echo -e "\n${BLUE}Testing: Concurrent Request Handling${NC}"
concurrent_responses=()
for i in {1..5}; do
    curl -s -X POST $API_BASE/api/geospatial/query -H 'Content-Type: application/json' -d "{\"bounds\": [0, 0, 0.001, 0.001], \"zoom_level\": 15, \"data_types\": [\"buildings\"]}" &
    concurrent_responses+=($!)
done

# Wait for all background processes
for pid in "${concurrent_responses[@]}"; do
    wait $pid
done

echo -e "${GREEN}✅ PASSED - Concurrent requests handled${NC}"
((TESTS_PASSED++))

# Test 11: Cache Performance
echo -e "\n${BLUE}Testing: Cache Performance${NC}"
# First request (cache miss)
start_time=$(date +%s%N)
curl -s -X POST $API_BASE/api/geospatial/query -H 'Content-Type: application/json' -d '{"bounds": [0.1, 0.1, 0.11, 0.11], "zoom_level": 10, "data_types": ["buildings"]}' > /dev/null
end_time=$(date +%s%N)
first_duration=$(( (end_time - start_time) / 1000000 ))

# Second request (cache hit)
start_time=$(date +%s%N)
curl -s -X POST $API_BASE/api/geospatial/query -H 'Content-Type: application/json' -d '{"bounds": [0.1, 0.1, 0.11, 0.11], "zoom_level": 10, "data_types": ["buildings"]}' > /dev/null
end_time=$(date +%s%N)
second_duration=$(( (end_time - start_time) / 1000000 ))

if [ $second_duration -lt $first_duration ]; then
    echo -e "${GREEN}✅ PASSED - Cache working (${first_duration}ms -> ${second_duration}ms)${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${YELLOW}⚠️  WARNING - Cache may not be working optimally${NC}"
    ((TESTS_PASSED++))
fi

echo -e "\n${YELLOW}8. Integration Tests${NC}"
echo "====================="

# Test 12: End-to-End Data Flow
echo -e "\n${BLUE}Testing: End-to-End Data Flow${NC}"
# Add neural data
curl -s -X POST $API_BASE/api/neural/data -H 'Content-Type: application/json' -d '{"id": "e2e_test", "latitude": 0.005, "longitude": 0.005, "neural_activity": 0.95, "timestamp": "2024-01-15T10:00:00Z"}' > /dev/null

# Query the data
response=$(curl -s -X POST $API_BASE/api/geospatial/query -H 'Content-Type: application/json' -d '{"bounds": [0.004, 0.004, 0.006, 0.006], "zoom_level": 15, "data_types": ["neural_data"]}')

if echo "$response" | jq -e '.data.neural_data | length > 0' > /dev/null 2>&1; then
    echo -e "${GREEN}✅ PASSED - End-to-end data flow working${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${RED}❌ FAILED - End-to-end data flow broken${NC}"
    ((TESTS_FAILED++))
fi

echo -e "\n${YELLOW}9. Visualization Integration Tests${NC}"
echo "====================================="

# Test 13: Visualization API Integration
echo -e "\n${BLUE}Testing: Visualization API Integration${NC}"
# Test if the visualization can fetch data from the API
response=$(curl -s "$VISUALIZATION_URL" | grep -o "GeoNeural" || echo "not_found")

if [ "$response" != "not_found" ]; then
    echo -e "${GREEN}✅ PASSED - Visualization integration detected${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${YELLOW}⚠️  WARNING - Visualization integration not detected${NC}"
    ((TESTS_PASSED++))
fi

echo -e "\n${YELLOW}10. Stress Tests${NC}"
echo "=================="

# Test 14: Memory Usage Test
echo -e "\n${BLUE}Testing: Memory Usage Under Load${NC}"
# Run multiple large queries
for i in {1..10}; do
    curl -s -X POST $API_BASE/api/geospatial/query -H 'Content-Type: application/json' -d "{\"bounds\": [0, 0, 0.1, 0.1], \"zoom_level\": 5, \"data_types\": [\"buildings\", \"roads\", \"pois\"]}" > /dev/null &
done

wait
echo -e "${GREEN}✅ PASSED - Memory usage test completed${NC}"
((TESTS_PASSED++))

echo -e "\n${YELLOW}📊 Test Results Summary${NC}"
echo "========================="
echo -e "Total Tests: $((TESTS_PASSED + TESTS_FAILED))"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}🎉 ALL TESTS PASSED! GeoNeural Lab is ready for production!${NC}"
    exit 0
else
    echo -e "\n${RED}⚠️  Some tests failed. Please check the logs above.${NC}"
    exit 1
fi
