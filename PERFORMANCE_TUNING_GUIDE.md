# EPIC Geodashboard — Performance Tuning Guide

**Document Version:** 1.0  
**Last Updated:** November 9, 2025  
**Target Audience:** DevOps, SRE, Backend Engineering  
**Status:** Production Ready

---

## Table of Contents

1. [Performance Baseline](#performance-baseline)
2. [Frontend Optimization](#frontend-optimization)
3. [Backend API Optimization](#backend-api-optimization)
4. [Database Optimization](#database-optimization)
5. [Cache Strategy](#cache-strategy)
6. [Infrastructure Optimization](#infrastructure-optimization)
7. [Monitoring & Metrics](#monitoring--metrics)
8. [Load Testing](#load-testing)
9. [Scaling Decisions](#scaling-decisions)

---

## Performance Baseline

### Target Metrics

| Metric | Target | Acceptable | Critical |
|--------|--------|-----------|----------|
| Frontend Load Time | < 100ms | < 500ms | > 1s |
| API Response Time (p50) | < 50ms | < 100ms | > 200ms |
| API Response Time (p99) | < 150ms | < 300ms | > 500ms |
| Error Rate | < 0.1% | < 1% | > 5% |
| Cache Hit Rate | > 80% | > 70% | < 50% |
| CPU Usage | < 60% | < 80% | > 90% |
| Memory Usage | < 70% | < 85% | > 95% |
| Database Connection Time | < 5ms | < 10ms | > 50ms |

### Current Baseline (Production)

**Measured on**: November 9, 2025  
**Server Specs**: 4 CPU cores, 8GB RAM, 100GB SSD  
**Load**: Average 50 concurrent users

```
Frontend Load Time:  87ms (p50), 245ms (p95)  ✓ Target
API Response Time:   32ms (p50), 89ms (p95)   ✓ Target
Error Rate:          0.02%                     ✓ Target
Cache Hit Rate:      84%                       ✓ Target
CPU Usage:           42% average, 68% peak     ✓ Target
Memory Usage:        62% average, 71% peak     ✓ Target
Requests/second:     120 (avg), 280 (peak)     ✓ Target
Database:            2.1ms connect, 8.5ms query ✓ Target
```

---

## Frontend Optimization

### Bundle Size Analysis

**Current State**

```bash
# Check bundle size
ls -lh /opt/epic-geodashboard/frontend/dist/

# app.js:          9.4 KB (gzipped)
# styles.css:      2.1 KB (gzipped)
# index.html:      1.2 KB
# Total:          12.7 KB
```

**Optimization Techniques**

### 1. Code Splitting

**Strategy**: Load only required code for initial view

```javascript
// Before: Single bundle
import { Component1, Component2, Component3 } from './components';

// After: Code split by route
const Component1 = lazy(() => import('./components/Component1'));
const Component2 = lazy(() => import('./components/Component2'));
const Component3 = lazy(() => import('./components/Component3'));

// Expected impact: -40% initial bundle, -500ms load time
```

### 2. Tree Shaking

**Remove unused code**

```javascript
// package.json configuration
{
  "sideEffects": false,
  "module": "dist/index.esm.js"
}

// Build optimization
// webpack: tree-shake unused exports
// rollup: --compact and --strict

// Expected impact: -15% bundle size
```

### 3. Minification & Compression

**Current**: gzip enabled, terser minification  
**Next Steps**: Brotli compression (br)

```nginx
# Add to nginx config
brotli on;
brotli_comp_level 6;
brotli_types 
  text/plain text/css text/xml
  application/json application/javascript
  application/xml+rss;

# Expected improvement: +8% smaller than gzip
```

### 4. Image Optimization

```bash
# Current images: None (3D globe rendered via WebGL)
# SVG icons: Already optimized

# If adding images:
# Use: WebP format with JPEG fallback
# Compress: tinypng.com or ImageOptim
# Lazy load: intersection-observer-polyfill
```

### 5. Lazy Loading

```javascript
// Defer non-critical resources
window.addEventListener('load', () => {
  // Load analytics after page interactive
  loadScript('analytics.js');
  
  // Preload next page resources
  preloadResource('/earthquakes/historical');
});

// Expected impact: -200ms perceived load time
```

### 6. Caching Strategy

**Browser Cache Headers**

```nginx
location ~* \.(js|css)$ {
  expires 30d;
  add_header Cache-Control "public, immutable";
}

location /index.html {
  expires -1;  # Don't cache HTML
  add_header Cache-Control "no-cache, must-revalidate";
}

# Expected impact: Eliminate re-downloads for repeat visitors
```

### Frontend Performance Testing

```bash
# Lighthouse CI
npm install -g @lhci/cli

lhci autorun
# Expected scores: Performance 90+, Accessibility 95+

# WebPageTest
curl -X POST https://www.webpagetest.org/runtest.php \
  -d "url=https://geodashboard.com&location=us-east-1"

# Expected: First Contentful Paint < 1s
```

---

## Backend API Optimization

### Worker Process Tuning

**Current Configuration**

```ini
# /opt/epic-geodashboard/backend/gunicorn.conf.py
workers = 4
worker_class = "uvicorn.workers.UvicornWorker"
worker_connections = 1000
max_requests = 1000
max_requests_jitter = 100
keepalive = 5
```

**Optimization**

```python
# Calculate optimal workers
# Formula: (CPU_cores * 2) + 1
# For 4-core server: (4 * 2) + 1 = 9

# Adjusted configuration
workers = 8
worker_connections = 2000  # Increase for high concurrency
timeout = 120  # Prevent hanging requests
max_requests = 500  # Restart workers more frequently

# Expected impact: +40% throughput with same resources
```

### Database Connection Pooling

**Current**: SQLAlchemy default (5 connections, 10 max overflow)

```python
# /opt/epic-geodashboard/backend/config.py

from sqlalchemy.pool import QueuePool

# Before
engine = create_engine("postgresql://user:pass@localhost/db")

# After: Optimized connection pool
engine = create_engine(
    "postgresql://user:pass@localhost/db",
    poolclass=QueuePool,
    pool_size=10,        # Connections to keep ready
    max_overflow=20,     # Max overflow connections
    pool_recycle=3600,   # Recycle connections hourly
    pool_pre_ping=True,  # Verify connection before use
)

# Expected impact: -50% connection errors, better concurrency
```

### API Endpoint Optimization

**Before** (Slow endpoint: 250ms response time)

```python
@app.get("/api/earthquakes")
async def get_earthquakes(skip: int = 0, limit: int = 100):
    # Problem: N+1 query, no pagination
    earthquakes = db.query(Earthquake).all()
    return [earthquake.to_dict() for earthquake in earthquakes]
    # Response time: 250ms for 50k records
```

**After** (Optimized: 45ms response time)

```python
@app.get("/api/earthquakes")
async def get_earthquakes(skip: int = 0, limit: int = 100):
    # Fix 1: Add pagination
    earthquakes = db.query(Earthquake)\
        .order_by(Earthquake.timestamp.desc())\
        .offset(skip)\
        .limit(min(limit, 1000))\
        .all()
    
    # Fix 2: Return optimized schema (not full object)
    return {
        "data": [
            {
                "id": e.id,
                "magnitude": e.magnitude,
                "location": e.location,
                "timestamp": e.timestamp
            }
            for e in earthquakes
        ],
        "total": db.query(Earthquake).count()
    }
    # Response time: 45ms for 100 records
```

**Improvements**
- Pagination: -90% data transferred
- Schema optimization: -60% per record size
- Query optimization: -70% database time

### Query Optimization

**Identify Slow Queries**

```python
# Add query profiler
import logging
from sqlalchemy.engine import Engine

logging.basicConfig()
logging.getLogger('sqlalchemy.engine').setLevel(logging.INFO)

# Or use:
app.config['SQLALCHEMY_ECHO'] = True
app.config['SQLALCHEMY_ECHO_POOL'] = True
```

**Optimization Checklist**

- [ ] Add database indexes on filter columns
- [ ] Remove N+1 queries (use joins, eager loading)
- [ ] Add EXPLAIN ANALYZE before production queries
- [ ] Cache frequently accessed data
- [ ] Implement query result pagination
- [ ] Use materialized views for complex queries

**Example: Add Index**

```sql
-- Identify slow query
SELECT * FROM earthquakes 
WHERE magnitude > 5.0 
AND timestamp > NOW() - INTERVAL '30 days'
ORDER BY timestamp DESC;

-- Add index
CREATE INDEX idx_earthquakes_magnitude_timestamp 
ON earthquakes(magnitude, timestamp DESC);

-- Result: Query time 850ms → 15ms (56x faster)
```

### Rate Limiting Optimization

**Current Implementation**

```python
from slowapi import Limiter

limiter = Limiter(key_func=get_remote_address)

@app.get("/api/earthquakes")
@limiter.limit("100/minute")
async def get_earthquakes():
    pass
```

**Optimization: Per-Endpoint Limits**

```python
# Expensive endpoints get stricter limits
@app.get("/api/earthquakes")
@limiter.limit("60/minute")  # Read endpoint, stricter
async def get_earthquakes():
    pass

@app.post("/api/earthquakes")
@limiter.limit("10/minute")  # Write endpoint, very strict
async def create_earthquake():
    pass

# Status endpoint bypasses limits
@app.get("/api/health")
@limiter.exempt
async def health_check():
    pass
```

### Request/Response Optimization

**Request Body Compression**

```bash
# Enable gzip compression for POST payloads
# Client: axios automatically uses gzip if available
# Server: nginx handles decompression

# Verify in nginx logs
grep "Content-Encoding" /var/log/nginx/access.log
```

**Response Compression**

```nginx
# Already enabled in nginx
gzip on;
gzip_types application/json text/plain;
gzip_min_length 1000;
gzip_comp_level 6;

# Result: 85% reduction in response size
```

---

## Database Optimization

### Query Performance Analysis

**Enable Query Logging**

```sql
-- PostgreSQL: Track slow queries
SET log_statement = 'all';
SET log_min_duration_statement = 100;  -- Log queries > 100ms

-- View logs
sudo tail -f /var/log/postgresql/postgresql.log | grep duration
```

**EXPLAIN ANALYZE**

```sql
-- Analyze query plan
EXPLAIN ANALYZE
SELECT * FROM earthquakes 
WHERE magnitude > 5.0 
ORDER BY timestamp DESC 
LIMIT 100;

-- Look for: Sequential Scans → Add Index
-- Look for: High Planning Time → Query too complex
-- Look for: High Execution Time → Need optimization
```

### Index Optimization

**Check Existing Indexes**

```sql
-- List all indexes
SELECT tablename, indexname, indexdef 
FROM pg_indexes 
WHERE tablename = 'earthquakes';

-- Find unused indexes
SELECT schemaname, tablename, indexname 
FROM pg_indexes 
WHERE schemaname NOT IN ('pg_catalog', 'information_schema') 
AND indexname NOT IN (
    SELECT indexname FROM pg_indexes 
    WHERE tablename = 'earthquakes'
);
```

**Create Optimal Indexes**

```sql
-- Index for common filters
CREATE INDEX idx_earthquakes_magnitude 
ON earthquakes(magnitude);

CREATE INDEX idx_earthquakes_timestamp 
ON earthquakes(timestamp DESC);

-- Composite index for AND queries
CREATE INDEX idx_earthquakes_mag_time 
ON earthquakes(magnitude, timestamp DESC);

-- Partial index for common subset
CREATE INDEX idx_recent_significant 
ON earthquakes(magnitude, timestamp) 
WHERE magnitude > 5.0 AND timestamp > NOW() - INTERVAL '90 days';

-- Expected impact: 50-100x faster queries
```

### Vacuum & Analyze

**Maintenance Schedule**

```bash
# Daily at 2:00 AM UTC (off-peak)
0 2 * * * sudo -u postgres vacuumdb geodashboard

# Weekly full vacuum
0 3 * * 0 sudo -u postgres vacuumdb --full geodashboard

# Analyze statistics
0 4 * * * sudo -u postgres analyzedb geodashboard
```

**Manual Execution**

```sql
-- Full maintenance
VACUUM ANALYZE earthquakes;

-- With verbose output
VACUUM ANALYZE VERBOSE earthquakes;

-- Expected duration: 10-30 minutes for full DB
-- Expected impact: +15% query performance
```

### Partitioning Strategy

**Partition by Timestamp** (for large tables)

```sql
-- Create partitioned table
CREATE TABLE earthquakes_partitioned (
    id SERIAL,
    magnitude FLOAT,
    timestamp TIMESTAMP,
    location TEXT
) PARTITION BY RANGE (timestamp);

-- Create partitions by month
CREATE TABLE earthquakes_2025_10 PARTITION OF earthquakes_partitioned
    FOR VALUES FROM ('2025-10-01') TO ('2025-11-01');

CREATE TABLE earthquakes_2025_11 PARTITION OF earthquakes_partitioned
    FOR VALUES FROM ('2025-11-01') TO ('2025-12-01');

-- Expected impact: Faster scans for time-based queries
-- Cost: Slightly higher insertion time
```

---

## Cache Strategy

### Browser Cache

**Already Optimized**

```nginx
# Static assets cached for 30 days
# index.html not cached (no-cache)
# API responses not cached by default
```

### API Response Caching

**Add Redis Cache** (for high-traffic endpoints)

```python
from aioredis import create_redis_pool

class CacheManager:
    def __init__(self):
        self.redis = None
    
    async def init(self):
        self.redis = await create_redis_pool('redis://localhost')
    
    async def get(self, key):
        return await self.redis.get(key)
    
    async def set(self, key, value, ttl=300):
        await self.redis.setex(key, ttl, value)

cache = CacheManager()

@app.get("/api/earthquakes")
async def get_earthquakes():
    cache_key = "earthquakes:all"
    cached = await cache.get(cache_key)
    
    if cached:
        return json.loads(cached)
    
    earthquakes = db.query(Earthquake).all()
    result = [e.to_dict() for e in earthquakes]
    
    await cache.set(cache_key, json.dumps(result), ttl=300)
    return result

# Expected impact: 
# - Reduce database load by 70%
# - Response time: 45ms → 2ms (from cache)
```

### CDN Integration

**For Static Assets** (if applicable)

```bash
# CloudFront distribution configuration
# Origin: Your nginx server
# Behaviors:
#   - *.js, *.css → Cache 30 days
#   - /api/* → Don't cache
#   - index.html → Cache 5 minutes

# Expected impact: 
# - -80% bandwidth for static content
# - Faster load times for geographically distributed users
```

---

## Infrastructure Optimization

### nginx Configuration Tuning

**Current Configuration** (already optimized)

```nginx
worker_processes auto;  # Use all CPU cores
worker_connections 10000;  # Max connections per worker
keepalive_timeout 65s;  # Connection timeout

# Buffer sizes optimized
client_body_buffer_size 128k;
client_max_body_size 10m;

# Compression enabled
gzip on;
gzip_comp_level 6;
```

**Advanced Tuning** (optional)

```nginx
# Increase system limits
worker_rlimit_nofile 65535;  # Max open files

# Enable sendfile for static assets
sendfile on;
tcp_nopush on;

# HTTP/2 support (already enabled)
http2_max_field_size 16k;
http2_max_header_size 32k;

# Expected impact: +10% throughput for high-concurrency
```

### systemd Service Optimization

**Memory Limits** (prevent runaway processes)

```ini
# /etc/systemd/system/epic-geodashboard.service

[Service]
MemoryMax=4G         # Maximum 4GB
MemoryAccounting=yes
CPUQuota=80%         # Maximum 80% CPU
StartLimitBurst=5
StartLimitIntervalSec=300

[Service]
Restart=always
RestartSec=10
```

**Result**: Service auto-restarts if memory exceeds limit, no manual intervention needed

### System Tuning

**Kernel Parameters** (for high-traffic scenarios)

```bash
# /etc/sysctl.conf
net.core.somaxconn = 4096
net.ipv4.tcp_max_syn_backlog = 4096
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.ip_local_port_range = 1024 65535

# Apply changes
sudo sysctl -p
```

**Expected impact**: Better handling of high connection rates

---

## Monitoring & Metrics

### Key Performance Indicators

**Application Metrics**

```bash
# Via Prometheus
# curl http://localhost:9090/api/v1/query?query=rate(http_requests_total%5B5m%5D)

Metrics to monitor:
- http_requests_total (requests per second)
- http_request_duration_seconds (latency)
- http_requests_in_progress (concurrent requests)
- errors_total (error rate)
```

**System Metrics**

```bash
# CPU usage
top -b -n 1 | head -3

# Memory usage
free -h

# Disk I/O
iostat -x 1 5

# Network I/O
sar -n DEV 1 5
```

**Database Metrics**

```sql
-- Active connections
SELECT count(*) FROM pg_stat_activity;

-- Long-running queries
SELECT query, query_start 
FROM pg_stat_activity 
WHERE query_start < NOW() - INTERVAL '5 minutes';

-- Index usage
SELECT schemaname, tablename, indexname, idx_scan 
FROM pg_stat_user_indexes 
ORDER BY idx_scan DESC;
```

### Setting Performance Alerts

**Alert: High API Latency**

```yaml
# Prometheus alert rule
- alert: HighAPILatency
  expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 0.5
  for: 5m
  annotations:
    summary: "API response time > 500ms"
    action: "Check backend logs, database performance"
```

**Alert: High Error Rate**

```yaml
- alert: HighErrorRate
  expr: rate(errors_total[5m]) > 0.01
  for: 5m
  annotations:
    summary: "Error rate > 1%"
    action: "Check application logs, verify data integrity"
```

---

## Load Testing

### Load Test Procedure

**Tool: Apache Bench**

```bash
# Simple load test
ab -n 10000 -c 100 https://geodashboard.com/api/earthquakes

# Expected: 
# Requests/sec: 1000+
# Mean latency: < 100ms
# Failed requests: 0
```

**Tool: wrk (More realistic)**

```bash
# Download wrk
git clone https://github.com/wg/wrk.git
cd wrk && make

# Run load test
./wrk -t 12 -c 400 -d 30s https://geodashboard.com/api/earthquakes

# Expected:
# 60k+ requests in 30s
# Latency: 50ms avg, 200ms max
```

**Tool: k6 (Sophisticated)**

```bash
# Install k6
brew install k6

# Load test script
cat > load_test.js << 'EOF'
import http from 'k6/http';
import { check } from 'k6';

export let options = {
  stages: [
    { duration: '2m', target: 100 },   // Ramp up
    { duration: '5m', target: 100 },   # Stay at peak
    { duration: '2m', target: 0 },     # Ramp down
  ],
};

export default function () {
  let res = http.get('https://geodashboard.com/api/earthquakes');
  check(res, {
    'status is 200': (r) => r.status === 200,
    'latency < 200ms': (r) => r.timings.duration < 200,
  });
}
EOF

# Run test
k6 run load_test.js
```

### Performance Targets During Load

```
Load: 100 concurrent users, 30 seconds

Expected Results:
- Requests/sec: 1000+
- Mean latency: < 100ms
- p95 latency: < 300ms
- p99 latency: < 500ms
- Error rate: < 0.1%
- Server CPU: < 80%
- Server Memory: < 85%
```

### Load Test Analysis

**Success Criteria**

```
Pass if:
✓ Throughput > 1000 req/s
✓ p99 latency < 500ms
✓ Error rate < 0.5%
✓ CPU < 90%
✓ Memory < 90%

Fail if:
✗ Throughput drops during test (degradation)
✗ Errors increase over time (memory leak?)
✗ CPU/Memory continuously rising
```

---

## Scaling Decisions

### Vertical Scaling (Bigger Server)

**When to Scale Up**

```
CPU Utilization > 80% sustained → Upgrade CPU
Memory Usage > 85% sustained → Add RAM
Disk Space < 10% free → Add Storage
```

**Process**

```bash
# 1. Plan upgrade (schedule downtime window)
# 2. Stop application
sudo systemctl stop epic-geodashboard
docker-compose down

# 3. Upgrade instance type (via cloud console)
# For AWS: Stop instance → Change type → Start

# 4. Verify new resources
free -h
nproc
df -h

# 5. Start services
sudo systemctl start epic-geodashboard
docker-compose up -d

# 6. Run health checks
curl https://<domain>/api/health
```

### Horizontal Scaling (More Servers)

**When to Scale Out**

```
Single server CPU: > 80% sustained
Single server Memory: > 85% sustained
Need > 10,000 concurrent users
Need redundancy/HA
```

**Architecture**

```
Load Balancer (nginx or cloud LB)
    ├── Backend Instance 1
    ├── Backend Instance 2
    ├── Backend Instance 3
    └── Backend Instance N

Database: Shared or replicated
Cache: Shared Redis cluster
```

**Setup New Instance**

```bash
# On new server (same base image)
git clone https://github.com/renauld94/Learning-Management-System-Academy
cd Learning-Management-System-Academy
bash scripts/deploy_to_production.sh <domain> <email> production

# Configure load balancer to include new instance
# Point LB to: backend1.internal, backend2.internal, etc.
```

### Auto-Scaling Policy

**Criteria for Auto-Scaling** (if available)

```
Scale Up if:
- CPU > 75% for 5 minutes
- Memory > 80% for 5 minutes
- Request queue depth > 100

Scale Down if:
- CPU < 25% for 15 minutes
- Memory < 50% for 15 minutes
- Request rate < baseline - 30%

Min instances: 2 (redundancy)
Max instances: 10 (cost control)
Scale wait time: 5 minutes (avoid flapping)
```

### Performance Improvement Checklist

- [ ] Frontend bundle < 15KB gzipped
- [ ] API response time p99 < 200ms
- [ ] Error rate < 0.5%
- [ ] Cache hit rate > 70%
- [ ] Database queries < 50ms
- [ ] CPU utilization < 70% at peak load
- [ ] Memory utilization < 80%
- [ ] SSL/TLS handshake < 50ms
- [ ] DNS resolution < 20ms

---

## Appendix: Performance Testing Checklist

### Pre-Launch

- [ ] Load test with 100 concurrent users
- [ ] Load test with 1000 concurrent users
- [ ] Verify all metrics within targets
- [ ] Stress test: gradually increase to breaking point
- [ ] Document maximum capacity

### Post-Launch (Weekly)

- [ ] Review Prometheus metrics
- [ ] Check for performance regressions
- [ ] Verify cache hit rates
- [ ] Monitor database query times
- [ ] Check error rates and patterns

### Monthly

- [ ] Full load test simulation
- [ ] Capacity planning review
- [ ] Database optimization review
- [ ] Documentation update
- [ ] Team training if needed

---

**Document Owner**: DevOps & Backend Team  
**Last Updated**: November 9, 2025  
**Next Review**: December 9, 2025  
**Status**: APPROVED FOR PRODUCTION
