#!/bin/bash
# Quick health check script for AI services

echo "🔍 AI Services Health Check"
echo "================================"
echo ""

# Check service 8100 - AI Conversation Partner
echo "📊 Service 1: AI Conversation Partner (Port 8100)"
echo "External URL: https://moodle.simondatalab.de/ai/health"
HEALTH=$(curl -s https://moodle.simondatalab.de/ai/health)

if [ $? -eq 0 ]; then
    echo "$HEALTH" | jq -r '"✅ Status: \(.status)\n✅ Service: \(.service)\n✅ Ollama: \(if .ollama_available then "Available (" + (.models_loaded | length | tostring) + " models)" else "Not Available" end)\n✅ Active Sessions: \(.active_sessions)"'
else
    echo "❌ Service is DOWN or unreachable"
fi

echo ""
echo "================================"
echo "🌐 Available Endpoints:"
echo "  - https://moodle.simondatalab.de/ai/"
echo "  - https://moodle.simondatalab.de/ai/health"
echo "  - https://moodle.simondatalab.de/ai/scenarios"
echo "  - https://moodle.simondatalab.de/ai/conversation-practice.html"
echo "  - wss://moodle.simondatalab.de/ai/ws/conversation"
echo ""
echo "📋 Next Steps:"
echo "  1. Open https://moodle.simondatalab.de/ai/conversation-practice.html"
echo "  2. Test a conversation scenario"
echo "  3. Embed iframe in Moodle course (see MOODLE_IFRAME_CODE.html)"
echo ""
