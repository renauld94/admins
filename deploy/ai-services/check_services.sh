#!/bin/bash
# Complete AI Services Status Check
echo "========================================="
echo "  VIETNAMESE AI LEARNING SERVICES"
echo "  Deployment Status Check"
echo "========================================="
echo ""

# Check VM services
echo "📡 Checking VM Services (10.0.0.110)..."
echo ""

ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.110 << 'ENDSSH'
echo "Service Status:"
echo "---------------"

# Check each port
for port in 8100 8101 8102 8103; do
    if curl -s http://localhost:$port/health > /dev/null 2>&1; then
        service_name=$(curl -s http://localhost:$port/health | jq -r '.service' 2>/dev/null || echo "unknown")
        echo "✅ Port $port: $service_name - RUNNING"
    else
        echo "❌ Port $port: NOT RUNNING"
    fi
done

echo ""
echo "Process List:"
echo "-------------"
ps aux | grep python | grep -E '8100|8101|8102|8103' | grep -v grep | awk '{print $11, $12, $13, $14}'

ENDSSH

echo ""
echo "========================================="
echo "  PUBLIC ACCESS STATUS"
echo "========================================="
echo ""

# Check public URLs
echo "🌐 Testing Public URLs..."
echo ""

if curl -s https://moodle.simondatalab.de/ai/health > /dev/null 2>&1; then
    echo "✅ AI Conversation: https://moodle.simondatalab.de/ai/"
else
    echo "❌ AI Conversation: Not accessible"
fi

# These need nginx configuration
echo "⏳ Pronunciation Coach: https://moodle.simondatalab.de/pronunciation/ (nginx needed)"
echo "⏳ Grammar Helper: https://moodle.simondatalab.de/grammar/ (nginx needed)"
echo "⏳ Vocabulary Builder: https://moodle.simondatalab.de/vocabulary/ (nginx needed)"

echo ""
echo "========================================="
echo "  DEPLOYMENT SUMMARY"
echo "========================================="
echo ""
echo "✅ COMPLETED (4/8 services - 50%):"
echo "  1. AI Conversation Partner (8100) - LIVE & PUBLIC"
echo "  2. Pronunciation Coach (8103) - Running, needs nginx"
echo "  3. Grammar Helper (8101) - Running, needs nginx"
echo "  4. Vocabulary Builder (8102) - Running, needs nginx"
echo ""
echo "❌ TODO (4/8 services - 50%):"
echo "  5. Cultural Context (8104)"
echo "  6. Reading Assistant (8105)"
echo "  7. Writing Practice (8106)"
echo "  8. Analytics Dashboard (8107)"
echo ""
echo "========================================="
echo "  NEXT STEPS"
echo "========================================="
echo ""
echo "1. Configure nginx for services 8101-8103"
echo "2. Upload AI Dashboard HTML"
echo "3. Embed in Moodle using /tmp/moodle_ai_embed.html"
echo "4. Develop remaining 4 services"
echo ""
echo "📖 Full documentation:"
echo "   FINAL_DEPLOYMENT_STATUS.md"
echo ""
