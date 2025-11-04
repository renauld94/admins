#!/bin/bash
# Quick deployment script for AI conversation service

set -e

VM_HOST="10.0.0.110"
VM_USER="simonadmin"
JUMP_HOST="root@136.243.155.166:2222"
SSH_CMD="ssh -J $JUMP_HOST $VM_USER@$VM_HOST"

echo "🚀 Deploying AI Conversation Service"
echo ""

# Upload service code
echo "📤 Uploading service files..."
scp -J $JUMP_HOST \
    ai_conversation_service.py \
    simonadmin@$VM_HOST:~/vietnamese-ai/conversation/

# Restart service
echo ""
echo "🔄 Restarting service..."
$SSH_CMD "pkill -f ai_conversation_service || true"
$SSH_CMD "cd ~/vietnamese-ai/conversation && source ../venv/bin/activate && nohup python3 ai_conversation_service.py > conversation.log 2>&1 &"

# Wait and check
echo ""
echo "⏳ Waiting for service to start..."
sleep 5

# Test health
echo ""
echo "🏥 Checking service health..."
$SSH_CMD "curl -s http://localhost:8100/health | python3 -m json.tool"

echo ""
echo "✅ Deployment complete!"
echo ""
echo "Service endpoints:"
echo "  - Health: http://10.0.0.110:8100/health"
echo "  - Scenarios: http://10.0.0.110:8100/scenarios"
echo "  - WebSocket: ws://10.0.0.110:8100/ws/conversation"
echo ""
echo "View logs:"
echo "  ssh -J $JUMP_HOST $VM_USER@$VM_HOST 'tail -f ~/vietnamese-ai/conversation/conversation.log'"
