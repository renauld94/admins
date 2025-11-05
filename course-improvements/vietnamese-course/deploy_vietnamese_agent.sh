#!/bin/bash
# Deploy Vietnamese Tutor Agent

set -e

echo "=================================================="
echo "Vietnamese Tutor Agent - Deployment Script"
echo "=================================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ROOT_DIR="/home/simon/Learning-Management-System-Academy"
AGENT_FILE="$ROOT_DIR/.continue/agents/agents_continue/vietnamese_tutor_agent.py"
SERVICE_FILE="$ROOT_DIR/.continue/systemd/vietnamese-tutor-agent.service"

# Check if running as correct user
if [ "$USER" != "simon" ]; then
    echo -e "${RED}❌ This script must be run as user 'simon'${NC}"
    exit 1
fi

# 1. Check dependencies
echo -e "\n${YELLOW}[1/7] Checking dependencies...${NC}"
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ python3 not found${NC}"
    exit 1
fi

if ! python3 -c "import fastapi" 2>/dev/null; then
    echo -e "${YELLOW}Installing FastAPI...${NC}"
    pip3 install fastapi uvicorn pydantic requests python-multipart
fi

echo -e "${GREEN}✅ Dependencies OK${NC}"

# 2. Check Ollama
echo -e "\n${YELLOW}[2/7] Checking Ollama...${NC}"
if ! curl -s http://127.0.0.1:11434/api/tags > /dev/null 2>&1; then
    echo -e "${RED}❌ Ollama not running at http://127.0.0.1:11434${NC}"
    echo "Start Ollama: ollama serve"
    exit 1
fi

# Check for required models
REQUIRED_MODELS=("qwen2.5-coder:7b" "deepseek-coder:6.7b-instruct" "phi3.5:3.8b")
MISSING_MODELS=()

for model in "${REQUIRED_MODELS[@]}"; do
    if ! ollama list | grep -q "$model"; then
        MISSING_MODELS+=("$model")
    fi
done

if [ ${#MISSING_MODELS[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Missing models: ${MISSING_MODELS[*]}${NC}"
    echo "Pull models: ollama pull <model-name>"
else
    echo -e "${GREEN}✅ All required models installed${NC}"
fi

# 3. Check ASR service
echo -e "\n${YELLOW}[3/7] Checking ASR service...${NC}"
if curl -s http://localhost:8000/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ ASR service running${NC}"
else
    echo -e "${YELLOW}⚠️  ASR service not running (optional)${NC}"
    echo "Start ASR: cd $ROOT_DIR/course-improvements/vietnamese-course/asr_service && docker-compose up -d"
fi

# 4. Create context directory
echo -e "\n${YELLOW}[4/7] Creating context directory...${NC}"
CONTEXT_DIR="$ROOT_DIR/workspace/agents/context/vietnamese-tutor"
mkdir -p "$CONTEXT_DIR"
chmod 755 "$CONTEXT_DIR"
echo -e "${GREEN}✅ Context dir: $CONTEXT_DIR${NC}"

# 5. Install systemd service
echo -e "\n${YELLOW}[5/7] Installing systemd service...${NC}"
if [ -f "$SERVICE_FILE" ]; then
    sudo cp "$SERVICE_FILE" /etc/systemd/system/
    sudo systemctl daemon-reload
    echo -e "${GREEN}✅ Service installed${NC}"
else
    echo -e "${RED}❌ Service file not found: $SERVICE_FILE${NC}"
    exit 1
fi

# 6. Enable and start service
echo -e "\n${YELLOW}[6/7] Starting service...${NC}"
sudo systemctl enable vietnamese-tutor-agent
sudo systemctl restart vietnamese-tutor-agent

# Wait for service to start
sleep 3

if sudo systemctl is-active --quiet vietnamese-tutor-agent; then
    echo -e "${GREEN}✅ Service running${NC}"
else
    echo -e "${RED}❌ Service failed to start${NC}"
    echo "Check logs: sudo journalctl -u vietnamese-tutor-agent -n 50"
    exit 1
fi

# 7. Test agent
echo -e "\n${YELLOW}[7/7] Testing agent...${NC}"
if curl -s http://localhost:5001/health > /dev/null 2>&1; then
    HEALTH=$(curl -s http://localhost:5001/health)
    echo -e "${GREEN}✅ Agent is healthy${NC}"
    echo "$HEALTH" | python3 -m json.tool
else
    echo -e "${RED}❌ Agent not responding${NC}"
    echo "Check logs: sudo journalctl -u vietnamese-tutor-agent -n 50"
    exit 1
fi

# Summary
echo ""
echo "=================================================="
echo -e "${GREEN}✅ Vietnamese Tutor Agent deployed successfully!${NC}"
echo "=================================================="
echo ""
echo "Service Status:"
echo "  sudo systemctl status vietnamese-tutor-agent"
echo ""
echo "View Logs:"
echo "  sudo journalctl -u vietnamese-tutor-agent -f"
echo ""
echo "Test Agent:"
echo "  python3 $ROOT_DIR/course-improvements/vietnamese-course/test_vietnamese_agent.py"
echo ""
echo "API Endpoints:"
echo "  http://localhost:5001/health"
echo "  http://localhost:5001/docs (Swagger UI)"
echo ""
echo "Integration Guide:"
echo "  $ROOT_DIR/course-improvements/vietnamese-course/VIETNAMESE_AGENT_INTEGRATION.md"
echo ""
echo "=================================================="
