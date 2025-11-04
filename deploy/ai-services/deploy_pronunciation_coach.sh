#!/bin/bash
# Deploy Pronunciation Coach Service to VM 10.0.0.110

set -e

VM="simonadmin@10.0.0.110"
JUMP="root@136.243.155.166:2222"
SERVICE_DIR="vietnamese-ai/pronunciation"

echo "📦 Deploying Pronunciation Coach Service..."

# 1. Create directory
echo "Creating service directory..."
ssh -J $JUMP $VM "mkdir -p ~/$SERVICE_DIR"

# 2. Upload service file
echo "Uploading service code..."
cat pronunciation_coach_service.py | ssh -J $JUMP $VM "cat > ~/$SERVICE_DIR/pronunciation_coach_service.py"

# 3. Install dependencies
echo "Installing Python dependencies..."
ssh -J $JUMP $VM "cd ~/vietnamese-ai && source venv/bin/activate && pip install librosa soundfile numba scikit-learn"

# 4. Stop existing service
echo "Stopping existing service..."
ssh -J $JUMP $VM "pkill -f pronunciation_coach_service || true"

# 5. Start service
echo "Starting Pronunciation Coach service..."
ssh -J $JUMP $VM "cd ~/$SERVICE_DIR && source ~/vietnamese-ai/venv/bin/activate && nohup python pronunciation_coach_service.py > pronunciation.log 2>&1 &"

sleep 3

# 6. Test service
echo "Testing service health..."
ssh -J $JUMP $VM "curl -s http://localhost:8103/health"

echo ""
echo "✅ Pronunciation Coach deployed successfully!"
echo "   Local: http://10.0.0.110:8103"
echo "   Public: https://moodle.simondatalab.de/pronunciation/"
echo ""
echo "Check logs: ssh -J $JUMP $VM 'tail -f ~/$SERVICE_DIR/pronunciation.log'"
