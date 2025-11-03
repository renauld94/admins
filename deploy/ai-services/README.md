# 🚀 AI Services Deployment Guide

## Quick Deployment

```bash
# 1. Make script executable
chmod +x deploy/ai-services/deploy_ai_stack.sh

# 2. Run deployment
./deploy/ai-services/deploy_ai_stack.sh

# 3. Upload service files
cd deploy/ai-services
scp -J root@136.243.155.166:2222 \
    ai_conversation_service.py \
    conversation_practice.html \
    simonadmin@10.0.0.110:~/vietnamese-ai/conversation/

# 4. Start services
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.110 \
    "cd ~/vietnamese-ai/conversation && \
     source ../venv/bin/activate && \
     nohup python3 ai_conversation_service.py > conversation.log 2>&1 &"

# 5. Test service
curl http://10.0.0.110:8100/health
```

## Services Overview

| Service | Port | Purpose |
|---------|------|---------|
| AI Conversation Partner | 8100 | Real-time Vietnamese conversation practice |
| Adaptive Learning Engine | 8101 | Personalized learning paths |
| Content Generator | 8102 | AI-generated exercises |
| Pronunciation Coach | 8103 | Advanced tone analysis |
| Grammar Assistant | 8104 | Writing improvement |
| Cultural Explainer | 8105 | Context and etiquette |
| Analytics Dashboard | 8107 | Progress tracking |

## Moodle Integration

Add to course sections:

```html
<!-- AI Conversation Partner -->
<iframe src="https://moodle.simondatalab.de/ai/conversation-practice.html" 
        width="100%" height="800px" frameborder="0">
</iframe>
```

## Next Steps

1. ✅ Deploy AI Conversation Partner (Port 8100)
2. ⏳ Configure nginx reverse proxy
3. ⏳ Deploy remaining services
4. ⏳ Integrate into Moodle course
5. ⏳ Test with students

## Monitoring

```bash
# Check service status
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.110 \
    "ps aux | grep python3"

# View logs
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.110 \
    "tail -f ~/vietnamese-ai/conversation/conversation.log"

# Test Ollama
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.110 \
    "ollama run qwen2.5:7b 'Xin chào!'"
```
