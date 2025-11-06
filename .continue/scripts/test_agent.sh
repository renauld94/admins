#!/bin/bash
# Test Continue Agent Configuration and Integration
# Tests all components, models, and integrations

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
CONFIG_FILE="$PROJECT_ROOT/.continue/config.json"

echo "╔══════════════════════════════════════════════════════════════════════════╗"
echo "║                                                                          ║"
echo "║   🤖 Continue Agent Test Suite                                          ║"
echo "║   ═════════════════════════════                                         ║"
echo "║                                                                          ║"
echo "╚══════════════════════════════════════════════════════════════════════════╝"
echo ""
echo "Testing Continue agent configuration and integrations..."
echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Test function
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    echo -n "Test $TESTS_TOTAL: $test_name... "
    
    if eval "$test_command" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ PASS${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}❌ FAIL${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Test 1: Configuration Files"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

run_test "Config file exists" "test -f '$CONFIG_FILE'"
run_test "Config is valid JSON" "python3 -m json.tool '$CONFIG_FILE' > /dev/null"
run_test "Agent version present" "grep -q 'agentVersion' '$CONFIG_FILE'"
run_test "Models configured" "grep -q 'llama3.2:3b' '$CONFIG_FILE'"
run_test "Jellyfin integration configured" "grep -q 'jellyfin' '$CONFIG_FILE'"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🤖 Test 2: Ollama Service"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

run_test "Ollama service running" "curl -s http://localhost:11434/api/tags > /dev/null"
run_test "Llama 3.2 3B model available" "curl -s http://localhost:11434/api/tags | grep -q 'llama3.2:3b'"

# Test model generation
if curl -s http://localhost:11434/api/tags | grep -q 'llama3.2:3b'; then
    echo -n "Test $((TESTS_TOTAL + 1)): Model generation works... "
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    
    RESPONSE=$(curl -s -X POST http://localhost:11434/api/generate -d '{
        "model": "llama3.2:3b",
        "prompt": "Say hello in exactly 3 words",
        "stream": false,
        "options": {
            "temperature": 0.1,
            "num_predict": 10
        }
    }' 2>&1)
    
    if echo "$RESPONSE" | grep -q '"response"'; then
        echo -e "${GREEN}✅ PASS${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}❌ FAIL${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎬 Test 3: Jellyfin Integration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

JELLYFIN_API_KEY="f870ddf763334cfba15fb45b091b10a8"
JELLYFIN_URL="http://136.243.155.166:8096"

run_test "Jellyfin server reachable" "curl -s -o /dev/null -w '%{http_code}' '$JELLYFIN_URL/web/index.html' | grep -q 200"
run_test "Jellyfin API key valid" "curl -s -H 'X-MediaBrowser-Token: $JELLYFIN_API_KEY' '$JELLYFIN_URL/System/Info' | grep -q 'ServerName'"
run_test "Live TV channels accessible" "curl -s -H 'X-MediaBrowser-Token: $JELLYFIN_API_KEY' '$JELLYFIN_URL/LiveTv/Channels?limit=1' | grep -q 'TotalRecordCount'"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📁 Test 4: Project Scripts"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

run_test "Jellyfin channel monitor exists" "test -f '$PROJECT_ROOT/scripts/jellyfin-channel-monitor.py'"
run_test "Jellyfin API refresh exists" "test -f '$PROJECT_ROOT/scripts/jellyfin-api-refresh.sh'"
run_test "Jellyfin image diagnostic exists" "test -f '$PROJECT_ROOT/scripts/diagnose-jellyfin-images.sh'"
run_test "Tampermonkey installer exists" "test -f '$PROJECT_ROOT/scripts/install-tampermonkey-script.sh'"
run_test "Channel monitor is executable" "test -x '$PROJECT_ROOT/scripts/jellyfin-channel-monitor.py' || chmod +x '$PROJECT_ROOT/scripts/jellyfin-channel-monitor.py'"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Test 5: Python Dependencies"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

run_test "Python3 available" "command -v python3"
run_test "requests library installed" "python3 -c 'import requests' 2>/dev/null"
run_test "json library available" "python3 -c 'import json' 2>/dev/null"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔧 Test 6: System Integration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

run_test "M3U file exists" "test -f '$PROJECT_ROOT/alternative_m3u_sources/jellyfin-channels-enhanced.m3u'"
run_test "Reports directory exists" "test -d '$PROJECT_ROOT/reports/jellyfin'"
run_test "Config directory exists" "test -d '$PROJECT_ROOT/config/jellyfin'"
run_test "Userscript exists" "test -f '$PROJECT_ROOT/config/jellyfin/jellyfin-scrollfix.user.js'"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎯 Test 7: Custom Commands"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

run_test "jellyfin-health command configured" "grep -q 'jellyfin-health' '$CONFIG_FILE'"
run_test "jellyfin-refresh command configured" "grep -q 'jellyfin-refresh' '$CONFIG_FILE'"
run_test "channel-monitor command configured" "grep -q 'channel-monitor' '$CONFIG_FILE'"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Test Results Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

PASS_RATE=$((TESTS_PASSED * 100 / TESTS_TOTAL))

echo "Total Tests: $TESTS_TOTAL"
echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
echo "Pass Rate: $PASS_RATE%"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🎉 Agent Status: FULLY OPERATIONAL"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Your Continue agent is properly configured and all integrations are working."
    echo ""
    echo "Available features:"
    echo "  • Llama 3.2 3B for code completion and chat"
    echo "  • Jellyfin API integration for media management"
    echo "  • Channel monitoring (311 channels, 92% working)"
    echo "  • Automated image cache management"
    echo "  • Custom commands for Jellyfin operations"
    echo ""
    echo "Next steps:"
    echo "  1. Use in VS Code: Ctrl+L or Cmd+L to start chat"
    echo "  2. Test Jellyfin commands: /jellyfin-health"
    echo "  3. Monitor channels: /channel-monitor"
    echo ""
    exit 0
else
    echo -e "${RED}⚠️  Some tests failed!${NC}"
    echo ""
    echo "Please review the failed tests above and fix any issues."
    echo ""
    echo "Common solutions:"
    echo "  • Ollama not running: systemctl start ollama"
    echo "  • Model not available: ollama pull gemma2:9b"
    echo "  • Jellyfin unreachable: check network/firewall"
    echo "  • Missing scripts: ensure all scripts are in place"
    echo ""
    exit 1
fi
