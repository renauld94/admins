#!/bin/bash
# GeoNeural Lab - Complete Setup Script
# Sets up the entire GeoNeural Lab stack with stunning demo

echo "🚀 GeoNeural Lab Setup Starting..."
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ROOT="/home/simon/Desktop/Learning Management System Academy"
BACKEND_DIR="$PROJECT_ROOT/geoneural-lab-backend"
VISUALIZATION_DIR="$PROJECT_ROOT/neural-visualization"
GEOSERVER_URL="https://136.243.155.166:8006"

echo -e "\n${BLUE}1. Environment Setup${NC}"
echo "====================="

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}\u274c Please don't run as root${NC}"
    exit 1
fi

# Check required tools
echo "Checking required tools..."
for tool in docker docker-compose curl jq node npm python3 pip; do
    if ! command -v $tool &> /dev/null; then
        echo -e "${RED}\u274c $tool is not installed${NC}"
        echo "Please install $tool and try again"
        exit 1
    else
        echo -e "${GREEN}\u2705 $tool found${NC}"
    fi
done

echo -e "\n${BLUE}2. Backend Setup${NC}"
echo "=================="

# Create backend directory if it doesn't exist
if [ ! -d "$BACKEND_DIR" ]; then
    mkdir -p "$BACKEND_DIR"
    echo -e "${GREEN}\u2705 Created backend directory${NC}"
fi

cd "$BACKEND_DIR"

# Create virtual environment
echo "Creating Python virtual environment..."
python3 -m venv venv
source venv/bin/activate

# Install Python dependencies
echo "Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

echo -e "${GREEN}\u2705 Backend dependencies installed${NC}"

echo -e "\n${BLUE}3. Database Setup${NC}"
echo "=================="

# Start PostgreSQL and Redis with Docker
echo "Starting PostgreSQL and Redis..."
docker-compose up -d postgres redis

# Wait for services to be ready
echo "Waiting for services to start..."
sleep 10

# Test database connection
echo "Testing database connection..."
if docker exec geoneural-lab-backend_postgres_1 pg_isready -U postgres; then
    echo -e "${GREEN}\u2705 PostgreSQL is ready${NC}"
else
    echo -e "${RED}\u274c PostgreSQL connection failed${NC}"
    exit 1
fi

# Test Redis connection
if docker exec geoneural-lab-backend_redis_1 redis-cli ping | grep -q "PONG"; then
    echo -e "${GREEN}\u2705 Redis is ready${NC}"
else
    echo -e "${RED}\u274c Redis connection failed${NC}"
    exit 1
fi

echo -e "\n${BLUE}4. Frontend Setup${NC}"
echo "=================="

cd "$VISUALIZATION_DIR"

# Install frontend dependencies
echo "Installing frontend dependencies..."
npm install

# Install additional packages for GeoNeural integration
echo "Installing GeoNeural integration packages..."
npm install @duckdb/duckdb-wasm apache-arrow

echo -e "${GREEN}\u2705 Frontend dependencies installed${NC}"

echo -e "\n${BLUE}5. Integration Setup${NC}"
echo "====================="

# Create environment files
echo "Creating environment configuration..."

# Backend .env
cat > "$BACKEND_DIR/.env" << EOF
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DB=geoneural_lab
POSTGRES_USER=postgres
POSTGRES_PASSWORD=geoneural2024
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_DB=0
GEOSERVER_URL=$GEOSERVER_URL
API_HOST=0.0.0.0
API_PORT=8000
DEBUG=True
EOF

# Frontend .env
cat > "$VISUALIZATION_DIR/.env" << EOF
REACT_APP_API_URL=http://localhost:8000
REACT_APP_GEOSERVER_URL=$GEOSERVER_URL
REACT_APP_DUCKDB_WASM_URL=/duckdb-wasm.wasm
PORT=3002
EOF

echo -e "${GREEN}\u2705 Environment files created${NC}"

echo -e "\n${BLUE}6. Start Services${NC}"
echo "=================="

# Start backend
echo "Starting GeoNeural Lab backend..."
cd "$BACKEND_DIR"
source venv/bin/activate
python main.py &
BACKEND_PID=$!

# Wait for backend to start
echo "Waiting for backend to start..."
sleep 5

# Test backend health
if curl -s http://localhost:8000/health | grep -q "healthy"; then
    echo -e "${GREEN}\u2705 Backend is running${NC}"
else
    echo -e "${RED}\u274c Backend failed to start${NC}"
    kill $BACKEND_PID 2>/dev/null
    exit 1
fi

# Start frontend
echo "Starting neural visualization..."
cd "$VISUALIZATION_DIR"
PORT=3002 npm start &
FRONTEND_PID=$!

# Wait for frontend to start
echo "Waiting for frontend to start..."
sleep 10

# Test frontend
if curl -s http://localhost:3002 | grep -q "html"; then
    echo -e "${GREEN}\u2705 Frontend is running${NC}"
else
    echo -e "${RED}\u274c Frontend failed to start${NC}"
    kill $BACKEND_PID $FRONTEND_PID 2>/dev/null
    exit 1
fi

echo -e "\n${BLUE}7. Run Tests${NC}"
echo "============="

# Run comprehensive test suite
echo "Running comprehensive test suite..."
cd "$BACKEND_DIR"
chmod +x test_suite.sh
./test_suite.sh

if [ $? -eq 0 ]; then
    echo -e "${GREEN}\u2705 All tests passed${NC}"
else
    echo -e "${YELLOW}\u26a0\ufe0f  Some tests failed, but continuing...${NC}"
fi

echo -e "\n${BLUE}8. Demo Data Generation${NC}"
echo "========================="

# Generate demo data
echo "Generating demo data..."
curl -s -X POST http://localhost:8000/api/neural/data \
  -H 'Content-Type: application/json' \
  -d '{"id": "demo_001", "latitude": 40.7128, "longitude": -74.0060, "neural_activity": 0.95, "timestamp": "2024-01-15T10:00:00Z", "metadata": {"demo": true}}' > /dev/null

curl -s -X POST http://localhost:8000/api/neural/data \
  -H 'Content-Type: application/json' \
  -d '{"id": "demo_002", "latitude": 51.5074, "longitude": -0.1278, "neural_activity": 0.87, "timestamp": "2024-01-15T10:00:00Z", "metadata": {"demo": true}}' > /dev/null

curl -s -X POST http://localhost:8000/api/neural/data \
  -H 'Content-Type: application/json' \
  -d '{"id": "demo_003", "latitude": 35.6762, "longitude": 139.6503, "neural_activity": 0.92, "timestamp": "2024-01-15T10:00:00Z", "metadata": {"demo": true}}' > /dev/null

echo -e "${GREEN}\u2705 Demo data generated${NC}"

echo -e "\n${BLUE}9. Performance Optimization${NC}"
echo "============================="

# Optimize database
echo "Optimizing database performance..."
docker exec geoneural-lab-backend_postgres_1 psql -U postgres -d geoneural_lab -c "
ANALYZE;
REFRESH MATERIALIZED VIEW building_density;
REFRESH MATERIALIZED VIEW neural_activity_heatmap;
"

echo -e "${GREEN}\u2705 Database optimized${NC}"

echo -e "\n${PURPLE}\u{1F389} GeoNeural Lab Setup Complete!${NC}"
echo "=================================="
echo -e "${GREEN}\u2705 Backend API: http://localhost:8000${NC}"
echo -e "${GREEN}\u2705 Neural Visualization: http://localhost:3002${NC}"
echo -e "${GREEN}\u2705 GeoServer Integration: $GEOSERVER_URL${NC}"
echo -e "${GREEN}\u2705 Database: PostgreSQL + PostGIS${NC}"
echo -e "${GREEN}\u2705 Cache: Redis${NC}"
echo -e "${GREEN}\u2705 Analytics: DuckDB-WASM + Apache Arrow${NC}"

echo -e "\n${YELLOW}\u{1F680} Quick Start Commands:${NC}"
echo "========================"
echo "• View API docs: http://localhost:8000/docs"
echo "• Test API: curl http://localhost:8000/health"
echo "• View visualization: http://localhost:3002"
echo "• Run tests: cd $BACKEND_DIR && ./test_suite.sh"

echo -e "\n${YELLOW}\u{1F4CA} Features Available:${NC}"
echo "======================"
echo "• 🌍 Real-time geospatial data processing"
echo "• 🧠 Neural activity visualization"
echo "• 🏙️ Procedural city generation"
echo "• 📈 High-performance analytics (Polars + DuckDB)"
echo "• ⚡ Redis caching for subsecond responses"

echo -e "\n${YELLOW}\u{1F6E0}\ufe0f Management Commands:${NC}"
echo "========================"
echo "• Stop all services: pkill -f 'python main.py' && pkill -f 'npm start'"
echo "• Restart backend: cd $BACKEND_DIR && source venv/bin/activate && python main.py"
echo "• Restart frontend: cd $VISUALIZATION_DIR && PORT=3002 npm start"
echo "• View logs: docker-compose logs -f"

echo -e "\n${GREEN}\u{1F3AC} Your stunning GeoNeural Lab is ready!${NC}"
echo "Experience the epic journey from neural networks to global data networks!"

# Keep processes running
echo -e "\n${BLUE}Services are running... Press Ctrl+C to stop${NC}"
trap 'echo -e "\n${YELLOW}Stopping services...${NC}"; kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; docker-compose down; exit 0' INT

# Wait for user interrupt
wait
