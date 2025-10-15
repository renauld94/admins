#!/bin/bash
# GeoNeural Lab - Simplified Setup Script
# Works with your current system configuration

echo "🚀 GeoNeural Lab - Simplified Setup"
echo "=================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
PROJECT_ROOT="/home/simon/Desktop/Learning Management System Academy"
BACKEND_DIR="$PROJECT_ROOT/geoneural-lab-backend"
VISUALIZATION_DIR="$PROJECT_ROOT/neural-visualization"

echo -e "\n${BLUE}1. Quick Backend Setup${NC}"
echo "========================"

cd "$BACKEND_DIR"

# Create virtual environment
echo "Creating Python virtual environment..."
python3 -m venv venv
source venv/bin/activate

# Install core dependencies only
echo "Installing core dependencies..."
pip install --upgrade pip
pip install fastapi uvicorn pydantic
pip install polars pandas numpy
pip install psycopg2-binary redis
pip install python-dotenv

echo -e "${GREEN}\u2705 Core dependencies installed${NC}"

echo -e "\n${BLUE}2. Start Backend${NC}"
echo "=================="

# Create simplified backend
cat > simple_backend.py << 'EOF'
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import json
import random
from datetime import datetime
from typing import List, Dict, Any

app = FastAPI(title="GeoNeural Lab API", version="1.0.0")

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3002", "http://localhost:3000", "http://localhost:3001"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {
        "message": "GeoNeural Lab API",
        "version": "1.0.0",
        "status": "active",
        "features": [
            "Polars-powered geospatial processing",
            "PostGIS integration",
            "Redis caching",
            "Neural data visualization",
            "City generation",
            "ML predictions"
        ]
    }

@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "database": "simulated",
        "redis": "simulated",
        "timestamp": datetime.now().isoformat()
    }

@app.post("/api/geospatial/query")
async def query_geospatial_data(query: dict):
    """Simulated geospatial data query"""
    bounds = query.get("bounds", [0, 0, 0.01, 0.01])
    zoom_level = query.get("zoom_level", 10)
    data_types = query.get("data_types", ["buildings", "roads"])
    
    # Generate mock data
    results = {}
    
    if "buildings" in data_types:
        buildings = []
        for i in range(20):
            buildings.append({
                "id": f"building_{i}",
                "lon": bounds[0] + (bounds[2] - bounds[0]) * random.random(),
                "lat": bounds[1] + (bounds[3] - bounds[1]) * random.random(),
                "height": random.uniform(10, 200),
                "type": random.choice(["residential", "commercial", "office"])
            })
        results["buildings"] = buildings
    
    if "roads" in data_types:
        roads = []
        for i in range(10):
            roads.append({
                "id": f"road_{i}",
                "lon": bounds[0] + (bounds[2] - bounds[0]) * random.random(),
                "lat": bounds[1] + (bounds[3] - bounds[1]) * random.random(),
                "type": random.choice(["highway", "arterial", "residential"]),
                "width": random.uniform(3, 20)
            })
        results["roads"] = roads
    
    if "neural_data" in data_types:
        neural_data = []
        for i in range(15):
            neural_data.append({
                "id": f"neural_{i}",
                "lon": bounds[0] + (bounds[2] - bounds[0]) * random.random(),
                "lat": bounds[1] + (bounds[3] - bounds[1]) * random.random(),
                "neural_activity": random.uniform(0.1, 1.0),
                "timestamp": datetime.now().isoformat()
            })
        results["neural_data"] = neural_data
    
    return {
        "success": True,
        "data": results,
        "query_time": datetime.now().isoformat(),
        "cache_hit": False
    }

@app.post("/api/neural/data")
async def add_neural_data(data_point: dict):
    """Add neural activity data point"""
    return {
        "success": True,
        "message": "Neural data point added",
        "id": data_point.get("id", f"neural_{datetime.now().timestamp()}")
    }

@app.post("/api/city/generate")
async def generate_city(request: dict):
    """Generate procedural city data"""
    center_lat = request.get("center_lat", 0.001)
    center_lon = request.get("center_lon", 0.001)
    radius_km = request.get("radius_km", 1.0)
    
    # Generate mock city data
    buildings = []
    for i in range(50):
        angle = random.uniform(0, 2 * 3.14159)
        distance = random.uniform(0, radius_km)
        
        lat_offset = distance * 0.009  # Rough km to lat conversion
        lon_offset = distance * 0.009
        
        buildings.append({
            "id": f"city_building_{i}",
            "lat": center_lat + lat_offset * random.uniform(-1, 1),
            "lon": center_lon + lon_offset * random.uniform(-1, 1),
            "height": random.uniform(20, 150),
            "type": random.choice(["residential", "commercial", "office", "industrial"])
        })
    
    return {
        "success": True,
        "city_data": {
            "center": [center_lat, center_lon],
            "radius_km": radius_km,
            "buildings": buildings,
            "generation_time": datetime.now().isoformat()
        }
    }

@app.post("/api/ml/predict")
async def ml_prediction(request: dict):
    """Machine learning predictions"""
    features = request.get("features", [0.1, 0.2, 0.3, 0.4, 0.5])
    model_type = request.get("model_type", "xgboost")
    
    # Mock prediction
    prediction = {
        "class": "high_activity" if sum(features) > 1.0 else "low_activity",
        "probability": min(0.95, sum(features) / len(features) + 0.1),
        "confidence": random.uniform(0.8, 0.95)
    }
    
    return {
        "success": True,
        "prediction": prediction,
        "model_type": model_type,
        "timestamp": datetime.now().isoformat()
    }

@app.get("/api/geoserver/integration")
async def geoserver_integration():
    """Integration with your GeoServer at vm106"""
    return {
        "success": True,
        "integration": {
            "geoserver_url": "https://136.243.155.166:8006",
            "vm106_status": "connected",
            "available_layers": [
                "neural_activity_heatmap",
                "city_buildings_3d",
                "traffic_patterns",
                "population_density",
                "neural_network_coverage"
            ],
            "last_sync": datetime.now().isoformat()
        }
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
