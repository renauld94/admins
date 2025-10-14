-- GeoNeural Lab Database Setup
-- PostGIS optimized for high-performance geospatial processing

-- Enable PostGIS extensions
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;

-- Create database if not exists (run as superuser)
-- CREATE DATABASE geoneural_lab;

-- Connect to geoneural_lab database and run the following:

-- Create optimized tables for geospatial data
CREATE TABLE IF NOT EXISTS buildings (
    id SERIAL PRIMARY KEY,
    geom GEOMETRY(POLYGON, 4326),
    building_type VARCHAR(50),
    height FLOAT,
    area FLOAT,
    floors INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS roads (
    id SERIAL PRIMARY KEY,
    geom GEOMETRY(LINESTRING, 4326),
    road_type VARCHAR(50),
    width FLOAT,
    surface VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS points_of_interest (
    id SERIAL PRIMARY KEY,
    geom GEOMETRY(POINT, 4326),
    poi_type VARCHAR(50),
    name VARCHAR(255),
    category VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS neural_data_points (
    id VARCHAR(255) PRIMARY KEY,
    geom GEOMETRY(POINT, 4326),
    neural_activity FLOAT,
    timestamp TIMESTAMP,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create spatial indexes for optimal performance
CREATE INDEX IF NOT EXISTS idx_buildings_geom ON buildings USING GIST (geom);
CREATE INDEX IF NOT EXISTS idx_roads_geom ON roads USING GIST (geom);
CREATE INDEX IF NOT EXISTS idx_pois_geom ON points_of_interest USING GIST (geom);
CREATE INDEX IF NOT EXISTS idx_neural_geom ON neural_data_points USING GIST (geom);

-- Create additional indexes for common queries
CREATE INDEX IF NOT EXISTS idx_buildings_type ON buildings (building_type);
CREATE INDEX IF NOT EXISTS idx_roads_type ON roads (road_type);
CREATE INDEX IF NOT EXISTS idx_pois_category ON points_of_interest (category);
CREATE INDEX IF NOT EXISTS idx_neural_timestamp ON neural_data_points (timestamp);
CREATE INDEX IF NOT EXISTS idx_neural_activity ON neural_data_points (neural_activity);

-- Create materialized views for common aggregations
CREATE MATERIALIZED VIEW IF NOT EXISTS building_density AS
SELECT 
    ST_SnapToGrid(geom, 0.001) as grid_cell,
    COUNT(*) as building_count,
    AVG(height) as avg_height,
    SUM(area) as total_area
FROM buildings
GROUP BY ST_SnapToGrid(geom, 0.001);

CREATE MATERIALIZED VIEW IF NOT EXISTS neural_activity_heatmap AS
SELECT 
    ST_SnapToGrid(geom, 0.01) as grid_cell,
    COUNT(*) as point_count,
    AVG(neural_activity) as avg_activity,
    MAX(neural_activity) as max_activity,
    MIN(neural_activity) as min_activity
FROM neural_data_points
WHERE timestamp >= CURRENT_TIMESTAMP - INTERVAL '24 hours'
GROUP BY ST_SnapToGrid(geom, 0.01);

-- Create indexes on materialized views
CREATE INDEX IF NOT EXISTS idx_building_density_geom ON building_density USING GIST (grid_cell);
CREATE INDEX IF NOT EXISTS idx_neural_heatmap_geom ON neural_activity_heatmap USING GIST (grid_cell);

-- Create functions for common operations
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers to automatically update timestamps
CREATE TRIGGER update_buildings_updated_at 
    BEFORE UPDATE ON buildings 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_roads_updated_at 
    BEFORE UPDATE ON roads 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_pois_updated_at 
    BEFORE UPDATE ON points_of_interest 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_neural_updated_at 
    BEFORE UPDATE ON neural_data_points 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create function to refresh materialized views
CREATE OR REPLACE FUNCTION refresh_geoneural_views()
RETURNS VOID AS $$
BEGIN
    REFRESH MATERIALIZED VIEW building_density;
    REFRESH MATERIALIZED VIEW neural_activity_heatmap;
END;
$$ LANGUAGE plpgsql;

-- Create function for spatial clustering
CREATE OR REPLACE FUNCTION cluster_neural_points(
    cluster_distance FLOAT DEFAULT 0.01,
    min_points INTEGER DEFAULT 3
)
RETURNS TABLE (
    cluster_id INTEGER,
    cluster_center GEOMETRY,
    point_count INTEGER,
    avg_activity FLOAT
) AS $$
BEGIN
    RETURN QUERY
    WITH clustered AS (
        SELECT 
            ST_ClusterDBSCAN(geom, cluster_distance, min_points) OVER() as cluster_id,
            geom,
            neural_activity
        FROM neural_data_points
        WHERE timestamp >= CURRENT_TIMESTAMP - INTERVAL '1 hour'
    )
    SELECT 
        cluster_id,
        ST_Centroid(ST_Collect(geom)) as cluster_center,
        COUNT(*)::INTEGER as point_count,
        AVG(neural_activity) as avg_activity
    FROM clustered
    WHERE cluster_id IS NOT NULL
    GROUP BY cluster_id;
END;
$$ LANGUAGE plpgsql;

-- Insert sample data for testing
INSERT INTO buildings (geom, building_type, height, area, floors) VALUES
(ST_GeomFromText('POLYGON((0 0, 0.001 0, 0.001 0.001, 0 0.001, 0 0))', 4326), 'residential', 30.5, 100.0, 10),
(ST_GeomFromText('POLYGON((0.002 0.002, 0.003 0.002, 0.003 0.003, 0.002 0.003, 0.002 0.002))', 4326), 'commercial', 45.2, 200.0, 15),
(ST_GeomFromText('POLYGON((0.004 0.004, 0.005 0.004, 0.005 0.005, 0.004 0.005, 0.004 0.004))', 4326), 'office', 60.8, 300.0, 20);

INSERT INTO roads (geom, road_type, width, surface) VALUES
(ST_GeomFromText('LINESTRING(0 0, 0.01 0)', 4326), 'highway', 20.0, 'asphalt'),
(ST_GeomFromText('LINESTRING(0 0, 0 0.01)', 4326), 'arterial', 15.0, 'asphalt'),
(ST_GeomFromText('LINESTRING(0.005 0.005, 0.015 0.015)', 4326), 'residential', 8.0, 'concrete');

INSERT INTO points_of_interest (geom, poi_type, name, category) VALUES
(ST_GeomFromText('POINT(0.001 0.001)', 4326), 'restaurant', 'Neural Cafe', 'food'),
(ST_GeomFromText('POINT(0.002 0.002)', 4326), 'park', 'Data Park', 'recreation'),
(ST_GeomFromText('POINT(0.003 0.003)', 4326), 'hospital', 'GeoNeural Medical', 'healthcare');

INSERT INTO neural_data_points (id, geom, neural_activity, timestamp, metadata) VALUES
('neural_001', ST_GeomFromText('POINT(0.001 0.001)', 4326), 0.85, CURRENT_TIMESTAMP, '{"source": "sensor_1", "confidence": 0.9}'),
('neural_002', ST_GeomFromText('POINT(0.002 0.002)', 4326), 0.72, CURRENT_TIMESTAMP, '{"source": "sensor_2", "confidence": 0.8}'),
('neural_003', ST_GeomFromText('POINT(0.003 0.003)', 4326), 0.91, CURRENT_TIMESTAMP, '{"source": "sensor_3", "confidence": 0.95}');

-- Create user for application (optional)
-- CREATE USER geoneural_user WITH PASSWORD 'secure_password';
-- GRANT CONNECT ON DATABASE geoneural_lab TO geoneural_user;
-- GRANT USAGE ON SCHEMA public TO geoneural_user;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO geoneural_user;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO geoneural_user;

-- Performance optimization settings (add to postgresql.conf)
-- shared_preload_libraries = 'pg_stat_statements'
-- max_connections = 200
-- shared_buffers = 256MB
-- effective_cache_size = 1GB
-- work_mem = 4MB
-- maintenance_work_mem = 64MB
-- checkpoint_completion_target = 0.9
-- wal_buffers = 16MB
-- default_statistics_target = 100

COMMENT ON DATABASE geoneural_lab IS 'GeoNeural Lab - High-performance geospatial data processing with neural network integration';
COMMENT ON TABLE buildings IS 'Building geometries with spatial indexing for fast queries';
COMMENT ON TABLE roads IS 'Road network geometries optimized for routing and analysis';
COMMENT ON TABLE points_of_interest IS 'POI data with spatial indexing for location-based queries';
COMMENT ON TABLE neural_data_points IS 'Neural activity data points with temporal and spatial indexing';
COMMENT ON MATERIALIZED VIEW building_density IS 'Pre-computed building density for fast visualization';
COMMENT ON MATERIALIZED VIEW neural_activity_heatmap IS 'Pre-computed neural activity heatmap for real-time visualization';
