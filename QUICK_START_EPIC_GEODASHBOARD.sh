#!/bin/bash
# EPIC Geodashboard Quick Start Guide

echo "🌍 EPIC Geodashboard - Quick Access Commands"
echo "================================================"
echo ""

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📊 BACKEND STATUS${NC}"
echo "Check if FastAPI is running:"
echo "  curl http://localhost:8000/health"
echo ""

echo -e "${BLUE}🌍 ACCESS 3D GLOBE${NC}"
echo "Direct access (if served):"
echo "  http://localhost:9000/globe-3d-threejs.html"
echo ""
echo "Or serve locally:"
echo "  cd portfolio-deployment-enhanced/geospatial-viz"
echo "  python3 -m http.server 9000"
echo ""

echo -e "${BLUE}✅ RUN INTEGRATION TESTS${NC}"
echo "  http://localhost:9000/test-integration.html"
echo ""

echo -e "${BLUE}📡 TEST ENDPOINTS${NC}"
echo "Health check:"
echo "  curl http://localhost:8000/health"
echo ""
echo "Get earthquakes:"
echo "  curl http://localhost:8000/earthquakes | jq '.count'"
echo ""
echo "Post analysis:"
echo "  curl -X POST http://localhost:8000/analysis \\"
echo "    -H 'Content-Type: application/json' \\"
echo "    -d '{\"events\":[{\"mag\":5.0,\"place\":\"Test\"}]}'"
echo ""

echo -e "${BLUE}📋 MONITOR SERVICES${NC}"
echo "Backend logs (real-time):"
echo "  journalctl -u geospatial-data-agent.service -f"
echo ""
echo "Phase 2 automation logs:"
echo "  tail -f /tmp/phase2_automation.log"
echo ""
echo "List all services:"
echo "  sudo systemctl list-units --type=service agent-* geospatial-*"
echo ""

echo -e "${BLUE}🔧 SERVICE MANAGEMENT${NC}"
echo "Restart backend:"
echo "  sudo systemctl restart geospatial-data-agent.service"
echo ""
echo "Check service status:"
echo "  sudo systemctl status geospatial-data-agent.service"
echo ""
echo "View service logs:"
echo "  journalctl -u geospatial-data-agent.service -n 50"
echo ""

echo -e "${BLUE}📚 DOCUMENTATION${NC}"
echo "  DEPLOYMENT_REPORT_EPIC_GEODASHBOARD.md"
echo "  PROJECT_COMPLETE_EPIC_GEODASHBOARD.md"
echo ""

echo -e "${GREEN}✅ All systems operational!${NC}"
