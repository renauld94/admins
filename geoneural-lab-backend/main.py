# GeoNeural Lab Backend
# FastAPI + Polars + GeoPandas + PostGIS + Redis Stack

from fastapi import FastAPI, HTTPException, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import polars as pl
import geopandas as gpd
import pandas as pd
import redis
import asyncio
import json
from typing import List, Dict, Any, Optional
from pydantic import BaseModel
import psycopg2
from psycopg2.extras import RealDictCursor
import numpy as np
from datetime import datetime, timedelta
import logging
from pathlib import Path
import os

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize FastAPI app
app = FastAPI(
    title="GeoNeural Lab API",
    description="High-performance geospatial data processing with neural network integration",
    version="1.0.0"
)

# CORS middleware for frontend integration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3002", "http://localhost:3000", "http://localhost:3001"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Database and Redis configuration
POSTGRES_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "database": "geoneural_lab",
    "user": "postgres",
    "password": os.getenv("POSTGRES_PASSWORD", "your_password")
}

REDIS_CONFIG = {
    "host": "localhost",
    "port": 6379,
    "db": 0,
    "decode_responses": True
}

# Initialize Redis connection
redis_client = redis.Redis(**REDIS_CONFIG)

# Pydantic models
class GeospatialQuery(BaseModel):
    bounds: List[float]  # [min_lon, min_lat, max_lon, max_lat]
    zoom_level: int
    data_types: List[str] = ["buildings", "roads", "pois", "neural_data"]
    time_range: Optional[Dict[str, str]] = None

class NeuralDataPoint(BaseModel):
    id: str
    latitude: float
    longitude: float
    neural_activity: float
    timestamp: datetime
    metadata: Dict[str, Any] = {}

class CityGenerationRequest(BaseModel):
    center_lat: float
    center_lon: float
    radius_km: float
    city_type: str = "modern"  # modern, historical, futuristic
    building_density: float = 0.7
    road_complexity: float = 0.5

class MLPredictionRequest(BaseModel):
    features: List[float]
    model_type: str = "xgboost"  # xgboost, sklearn
    prediction_type: str = "classification"  # classification, regression

# Database connection helper
def get_db_connection():
    try:
        conn = psycopg2.connect(**POSTGRES_CONFIG)
        return conn
    except Exception as e:
        logger.error(f"Database connection failed: {e}")
        raise HTTPException(status_code=500, detail="Database connection failed")

# Redis cache helper
def get_cached_data(key: str):
    try:
        cached = redis_client.get(key)
        return json.loads(cached) if cached else None
    except Exception as e:
        logger.warning(f"Redis cache read failed: {e}")
        return None

def set_cached_data(key: str, data: Any, expire_seconds: int = 3600):
    try:
        redis_client.setex(key, expire_seconds, json.dumps(data, default=str))
    except Exception as e:
        logger.warning(f"Redis cache write failed: {e}")

# Polars-based geospatial processing
def process_geospatial_data_polars(query: GeospatialQuery) -> Dict[str, Any]:
    """High-performance geospatial data processing using Polars"""
    
    # Create Polars DataFrame for efficient processing
    cache_key = f"geospatial_{hash(str(query))}"
    cached_result = get_cached_data(cache_key)
    if cached_result:
        return cached_result
    
    try:
        conn = get_db_connection()
        
        # Build SQL query with spatial bounds
        bounds_sql = f"""
        ST_Intersects(
            geom, 
            ST_MakeEnvelope({query.bounds[0]}, {query.bounds[1]}, 
                           {query.bounds[2]}, {query.bounds[3]}, 4326)
        )
        """
        
        results = {}
        
        for data_type in query.data_types:
            if data_type == "buildings":
                sql = f"""
                SELECT id, ST_AsGeoJSON(geom) as geometry, 
                       building_type, height, area,
                       ST_X(ST_Centroid(geom)) as lon,
                       ST_Y(ST_Centroid(geom)) as lat
                FROM buildings 
                WHERE {bounds_sql}
                LIMIT 10000
                """
                
            elif data_type == "roads":
                sql = f"""
                SELECT id, ST_AsGeoJSON(geom) as geometry,
                       road_type, width, surface,
                       ST_X(ST_Centroid(geom)) as lon,
                       ST_Y(ST_Centroid(geom)) as lat
                FROM roads 
                WHERE {bounds_sql}
                LIMIT 5000
                """
                
            elif data_type == "pois":
                sql = f"""
                SELECT id, ST_AsGeoJSON(geom) as geometry,
                       poi_type, name, category,
                       ST_X(ST_Centroid(geom)) as lon,
                       ST_Y(ST_Centroid(geom)) as lat
                FROM points_of_interest 
                WHERE {bounds_sql}
                LIMIT 2000
                """
                
            elif data_type == "neural_data":
                sql = f"""
                SELECT id, ST_AsGeoJSON(geom) as geometry,
                       neural_activity, timestamp, metadata,
                       ST_X(ST_Centroid(geom)) as lon,
                       ST_Y(ST_Centroid(geom)) as lat
                FROM neural_data_points 
                WHERE {bounds_sql}
                ORDER BY timestamp DESC
                LIMIT 1000
                """
            
            # Execute query and convert to Polars DataFrame
            df = pd.read_sql(sql, conn)
            if not df.empty:
                pl_df = pl.from_pandas(df)
                results[data_type] = pl_df.to_dicts()
        
        conn.close()
        
        # Cache results
        set_cached_data(cache_key, results, expire_seconds=1800)
        
        return results
        
    except Exception as e:
        logger.error(f"Geospatial processing failed: {e}")
        raise HTTPException(status_code=500, detail=f"Geospatial processing failed: {str(e)}")

# API Endpoints

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
    """Health check endpoint"""
    try:
        # Check database connection
        conn = get_db_connection()
        conn.close()
        
        # Check Redis connection
        redis_client.ping()
        
        return {
            "status": "healthy",
            "database": "connected",
            "redis": "connected",
            "timestamp": datetime.now().isoformat()
        }
    except Exception as e:
        return JSONResponse(
            status_code=503,
            content={
                "status": "unhealthy",
                "error": str(e),
                "timestamp": datetime.now().isoformat()
            }
        )

@app.post("/api/geospatial/query")
async def query_geospatial_data(query: GeospatialQuery):
    """High-performance geospatial data query using Polars"""
    try:
        results = process_geospatial_data_polars(query)
        return {
            "success": True,
            "data": results,
            "query_time": datetime.now().isoformat(),
            "cache_hit": get_cached_data(f"geospatial_{hash(str(query))}") is not None
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/neural/data")
async def add_neural_data(data_point: NeuralDataPoint):
    """Add neural activity data point"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        sql = """
        INSERT INTO neural_data_points (id, geom, neural_activity, timestamp, metadata)
        VALUES (%s, ST_GeomFromText('POINT(%s %s)', 4326), %s, %s, %s)
        """
        
        cursor.execute(sql, (
            data_point.id,
            data_point.longitude,
            data_point.latitude,
            data_point.neural_activity,
            data_point.timestamp,
            json.dumps(data_point.metadata)
        ))
        
        conn.commit()
        cursor.close()
        conn.close()
        
        # Invalidate relevant cache
        redis_client.delete("neural_data_*")
        
        return {"success": True, "message": "Neural data point added"}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/city/generate")
async def generate_city(request: CityGenerationRequest):
    """Generate procedural city data"""
    try:
        # This would integrate with procedural-gl-js or CityEngine
        # For now, return mock data structure
        
        city_data = {
            "center": [request.center_lat, request.center_lon],
            "radius_km": request.radius_km,
            "city_type": request.city_type,
            "buildings": generate_procedural_buildings(request),
            "roads": generate_procedural_roads(request),
            "parks": generate_procedural_parks(request)
        }
        
        return {
            "success": True,
            "city_data": city_data,
            "generation_time": datetime.now().isoformat()
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/ml/predict")
async def ml_prediction(request: MLPredictionRequest):
    """Machine learning predictions using XGBoost or Scikit-learn"""
    try:
        # This would integrate with your trained models
        # For now, return mock prediction
        
        if request.model_type == "xgboost":
            # XGBoost prediction logic
            prediction = predict_with_xgboost(request.features)
        else:
            # Scikit-learn prediction logic
            prediction = predict_with_sklearn(request.features)
        
        return {
            "success": True,
            "prediction": prediction,
            "model_type": request.model_type,
            "confidence": 0.85,  # Mock confidence score
            "timestamp": datetime.now().isoformat()
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/geoserver/integration")
async def geoserver_integration():
    """Integration with your GeoServer at vm106"""
    try:
        # This would connect to your GeoServer instance
        geoserver_url = "https://136.243.155.166:8006"
        
        # Mock integration data
        integration_data = {
            "geoserver_url": geoserver_url,
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
        
        return {
            "success": True,
            "integration": integration_data
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Helper functions for procedural generation
def generate_procedural_buildings(request: CityGenerationRequest) -> List[Dict]:
    """Generate procedural building data"""
    buildings = []
    num_buildings = int(request.building_density * 100)
    
    for i in range(num_buildings):
        # Generate random building within radius
        angle = np.random.uniform(0, 2 * np.pi)
        distance = np.random.uniform(0, request.radius_km)
        
        lat_offset = distance * np.cos(angle) / 111.0  # Rough km to lat conversion
        lon_offset = distance * np.sin(angle) / (111.0 * np.cos(np.radians(request.center_lat)))
        
        building = {
            "id": f"building_{i}",
            "lat": request.center_lat + lat_offset,
            "lon": request.center_lon + lon_offset,
            "height": np.random.uniform(10, 200),
            "type": np.random.choice(["residential", "commercial", "office", "industrial"]),
            "floors": np.random.randint(3, 50)
        }
        buildings.append(building)
    
    return buildings

def generate_procedural_roads(request: CityGenerationRequest) -> List[Dict]:
    """Generate procedural road network"""
    roads = []
    num_roads = int(request.road_complexity * 50)
    
    for i in range(num_roads):
        road = {
            "id": f"road_{i}",
            "type": np.random.choice(["highway", "arterial", "residential", "pedestrian"]),
            "width": np.random.uniform(3, 20),
            "coordinates": generate_road_coordinates(request)
        }
        roads.append(road)
    
    return roads

def generate_procedural_parks(request: CityGenerationRequest) -> List[Dict]:
    """Generate procedural park areas"""
    parks = []
    num_parks = int(request.building_density * 10)
    
    for i in range(num_parks):
        park = {
            "id": f"park_{i}",
            "type": np.random.choice(["urban_park", "green_space", "playground", "nature_reserve"]),
            "area": np.random.uniform(0.1, 5.0),
            "coordinates": generate_park_coordinates(request)
        }
        parks.append(park)
    
    return parks

def generate_road_coordinates(request: CityGenerationRequest) -> List[List[float]]:
    """Generate road coordinate arrays"""
    # Simplified road generation
    return [
        [request.center_lon - 0.01, request.center_lat - 0.01],
        [request.center_lon + 0.01, request.center_lat + 0.01]
    ]

def generate_park_coordinates(request: CityGenerationRequest) -> List[List[float]]:
    """Generate park coordinate arrays"""
    # Simplified park generation
    return [
        [request.center_lon - 0.005, request.center_lat - 0.005],
        [request.center_lon + 0.005, request.center_lat - 0.005],
        [request.center_lon + 0.005, request.center_lat + 0.005],
        [request.center_lon - 0.005, request.center_lat + 0.005],
        [request.center_lon - 0.005, request.center_lat - 0.005]
    ]

def predict_with_xgboost(features: List[float]) -> Any:
    """XGBoost prediction (mock implementation)"""
    # This would load your trained XGBoost model
    return {"class": "high_activity", "probability": 0.87}

def predict_with_sklearn(features: List[float]) -> Any:
    """Scikit-learn prediction (mock implementation)"""
    # This would load your trained Scikit-learn model
    return {"prediction": 0.75, "confidence": 0.82}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
