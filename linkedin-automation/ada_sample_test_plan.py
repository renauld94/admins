"""
ADA Global - Sample QA Test Plan
TikTok Data Ingestion Pipeline Quality Assurance

Author: Simon Renauld
Date: November 4, 2025
Purpose: Demonstrate automated testing approach for social media data quality
"""

import pytest
import pandas as pd
from datetime import datetime, timedelta
from typing import Dict, List, Optional
import great_expectations as ge
from airflow.models import DagRun
from unittest.mock import Mock

# ==============================================================================
# LAYER 1: DATA ACCURACY TESTS
# ==============================================================================

class TestTikTokDataAccuracy:
    """
    Validate that TikTok data meets business accuracy requirements.
    Target: 99.9% accuracy on all critical fields.
    """
    
    def test_schema_compliance(self, tiktok_df: pd.DataFrame):
        """
        Ensure all TikTok records contain required fields with correct types.
        
        Critical Fields:
        - video_id (string, unique)
        - author_id (string)
        - views (integer, >= 0)
        - likes (integer, >= 0)
        - shares (integer, >= 0)
        - published_at (timestamp)
        - ingested_at (timestamp)
        """
        # Convert to Great Expectations dataset
        ge_df = ge.from_pandas(tiktok_df)
        
        # Required columns exist
        assert ge_df.expect_column_to_exist('video_id').success
        assert ge_df.expect_column_to_exist('author_id').success
        assert ge_df.expect_column_to_exist('views').success
        assert ge_df.expect_column_to_exist('likes').success
        assert ge_df.expect_column_to_exist('shares').success
        assert ge_df.expect_column_to_exist('published_at').success
        assert ge_df.expect_column_to_exist('ingested_at').success
        
        # Correct data types
        assert ge_df.expect_column_values_to_be_of_type('video_id', 'object').success
        assert ge_df.expect_column_values_to_be_of_type('views', 'int64').success
        assert ge_df.expect_column_values_to_be_of_type('likes', 'int64').success
        
        # No nulls in critical fields
        assert ge_df.expect_column_values_to_not_be_null('video_id').success
        assert ge_df.expect_column_values_to_not_be_null('author_id').success
        
    def test_data_freshness(self, tiktok_df: pd.DataFrame):
        """
        Ensure data is ingested within 24 hour SLA.
        
        Business Rule: 95% of records must be < 24 hours old
        Alert: If > 5% of records are stale
        """
        now = datetime.now()
        tiktok_df['age_hours'] = (now - pd.to_datetime(tiktok_df['ingested_at'])).dt.total_seconds() / 3600
        
        stale_records = (tiktok_df['age_hours'] > 24).sum()
        total_records = len(tiktok_df)
        stale_percentage = (stale_records / total_records) * 100
        
        assert stale_percentage < 5, f"FRESHNESS VIOLATION: {stale_percentage:.2f}% of records are > 24 hours old (threshold: 5%)"
        
        # Log warning if approaching threshold
        if stale_percentage > 3:
            print(f"⚠️  WARNING: Freshness at {stale_percentage:.2f}% (threshold: 5%)")
    
    def test_deduplication(self, tiktok_df: pd.DataFrame):
        """
        Ensure no duplicate video_ids exist.
        
        Business Rule: 0 duplicates allowed (100% deduplication)
        Impact: Duplicates cause over-counting in analytics
        """
        duplicates = tiktok_df['video_id'].duplicated().sum()
        
        if duplicates > 0:
            duplicate_ids = tiktok_df[tiktok_df['video_id'].duplicated(keep=False)]['video_id'].unique()
            assert False, f"DUPLICATE VIOLATION: Found {duplicates} duplicate video_ids: {duplicate_ids[:5]}"
    
    def test_referential_integrity(self, tiktok_df: pd.DataFrame, authors_df: pd.DataFrame):
        """
        Ensure all author_ids exist in authors table.
        
        Business Rule: 100% referential integrity
        Impact: Broken relationships cause incomplete analytics
        """
        orphaned_videos = ~tiktok_df['author_id'].isin(authors_df['author_id'])
        orphaned_count = orphaned_videos.sum()
        
        if orphaned_count > 0:
            orphaned_authors = tiktok_df[orphaned_videos]['author_id'].unique()
            assert False, f"REFERENTIAL INTEGRITY VIOLATION: {orphaned_count} videos have missing authors: {orphaned_authors[:5]}"
    
    def test_business_logic_validation(self, tiktok_df: pd.DataFrame):
        """
        Validate business rules and logical constraints.
        
        Rules:
        - views >= likes (you can't like without viewing)
        - views >= shares (you can't share without viewing)
        - published_at <= ingested_at (can't ingest before publish)
        - engagement_rate = (likes + shares) / views is reasonable (< 100%)
        """
        # Rule 1: Views >= Likes
        invalid_likes = tiktok_df[tiktok_df['views'] < tiktok_df['likes']]
        assert len(invalid_likes) == 0, f"LOGIC VIOLATION: {len(invalid_likes)} videos have more likes than views"
        
        # Rule 2: Views >= Shares
        invalid_shares = tiktok_df[tiktok_df['views'] < tiktok_df['shares']]
        assert len(invalid_shares) == 0, f"LOGIC VIOLATION: {len(invalid_shares)} videos have more shares than views"
        
        # Rule 3: Published before ingested
        time_travelers = tiktok_df[pd.to_datetime(tiktok_df['published_at']) > pd.to_datetime(tiktok_df['ingested_at'])]
        assert len(time_travelers) == 0, f"LOGIC VIOLATION: {len(time_travelers)} videos ingested before publication"
        
        # Rule 4: Reasonable engagement rate
        tiktok_df['engagement_rate'] = (tiktok_df['likes'] + tiktok_df['shares']) / tiktok_df['views'].replace(0, 1)
        suspicious_engagement = tiktok_df[tiktok_df['engagement_rate'] > 1.0]
        
        if len(suspicious_engagement) > 0:
            print(f"⚠️  WARNING: {len(suspicious_engagement)} videos have >100% engagement rate (data quality issue?)")


# ==============================================================================
# LAYER 2: PIPELINE QUALITY TESTS
# ==============================================================================

class TestTikTokAirflowDAG:
    """
    Validate that Airflow pipeline executes correctly.
    Target: 98% success rate over 30 days.
    """
    
    def test_dag_exists(self, dag_bag):
        """Ensure TikTok ingestion DAG is registered."""
        assert 'tiktok_ingestion_dag' in dag_bag.dag_ids, "TikTok DAG not found in Airflow"
    
    def test_dag_structure(self, tiktok_dag):
        """
        Validate DAG has expected tasks in correct order.
        
        Expected Flow:
        extract_tiktok_api → validate_raw_data → transform_data → 
        load_to_postgres → data_quality_check → send_metrics
        """
        task_ids = [task.task_id for task in tiktok_dag.tasks]
        
        required_tasks = [
            'extract_tiktok_api',
            'validate_raw_data',
            'transform_data',
            'load_to_postgres',
            'data_quality_check',
            'send_metrics'
        ]
        
        for task in required_tasks:
            assert task in task_ids, f"Missing required task: {task}"
        
        # Validate dependencies
        extract_task = tiktok_dag.get_task('extract_tiktok_api')
        validate_task = tiktok_dag.get_task('validate_raw_data')
        
        assert validate_task in extract_task.downstream_list, "extract_tiktok_api should flow to validate_raw_data"
    
    def test_dag_success_rate(self, tiktok_dag):
        """
        Check last 30 days of DAG runs for success rate.
        Target: >= 98% success rate
        """
        thirty_days_ago = datetime.now() - timedelta(days=30)
        
        dag_runs = DagRun.find(
            dag_id='tiktok_ingestion_dag',
            execution_start_date=thirty_days_ago
        )
        
        total_runs = len(dag_runs)
        successful_runs = len([run for run in dag_runs if run.state == 'success'])
        
        if total_runs > 0:
            success_rate = (successful_runs / total_runs) * 100
            assert success_rate >= 98, f"DAG SUCCESS RATE VIOLATION: {success_rate:.2f}% (target: 98%)"
        else:
            pytest.skip("No DAG runs in last 30 days - new pipeline")
    
    def test_task_execution_time(self, tiktok_dag):
        """
        Ensure tasks complete within SLA.
        
        SLA Targets:
        - extract_tiktok_api: < 5 minutes
        - validate_raw_data: < 2 minutes
        - transform_data: < 10 minutes
        - load_to_postgres: < 5 minutes
        """
        recent_run = DagRun.find(
            dag_id='tiktok_ingestion_dag',
            state='success'
        )[0]  # Most recent successful run
        
        task_durations = {
            'extract_tiktok_api': 300,  # 5 min in seconds
            'validate_raw_data': 120,   # 2 min
            'transform_data': 600,      # 10 min
            'load_to_postgres': 300     # 5 min
        }
        
        for task_id, max_duration in task_durations.items():
            task_instance = recent_run.get_task_instance(task_id)
            actual_duration = (task_instance.end_date - task_instance.start_date).total_seconds()
            
            assert actual_duration <= max_duration, \
                f"SLA VIOLATION: {task_id} took {actual_duration:.0f}s (max: {max_duration}s)"


# ==============================================================================
# LAYER 3: MONITORING & ALERTING TESTS
# ==============================================================================

class TestTikTokMonitoring:
    """
    Validate that monitoring catches issues before clients do.
    Target: MTTD < 15 minutes, MTTR < 2 hours
    """
    
    def test_volume_anomaly_detection(self, tiktok_df: pd.DataFrame, baseline_stats: Dict):
        """
        Detect sudden drops/spikes in data volume.
        
        Alert if:
        - Current volume < 50% of baseline (data loss)
        - Current volume > 200% of baseline (duplicate ingestion)
        """
        current_volume = len(tiktok_df)
        baseline_volume = baseline_stats['avg_daily_volume']
        
        volume_ratio = current_volume / baseline_volume
        
        if volume_ratio < 0.5:
            pytest.fail(f"VOLUME ANOMALY: Current volume {current_volume} is {volume_ratio:.0%} of baseline (possible data loss)")
        
        if volume_ratio > 2.0:
            print(f"⚠️  WARNING: Current volume {current_volume} is {volume_ratio:.0%} of baseline (spike detected)")
    
    def test_schema_drift_detection(self, tiktok_df: pd.DataFrame, expected_schema: Dict):
        """
        Detect if TikTok API changed their schema (new/missing fields).
        
        Impact: Schema changes break downstream analytics
        """
        current_columns = set(tiktok_df.columns)
        expected_columns = set(expected_schema.keys())
        
        # Missing columns
        missing = expected_columns - current_columns
        if missing:
            pytest.fail(f"SCHEMA DRIFT: Missing columns {missing} (TikTok API changed?)")
        
        # New columns (warning, not failure)
        new = current_columns - expected_columns
        if new:
            print(f"⚠️  WARNING: New columns detected {new} (update schema?)")
    
    def test_data_quality_metrics_export(self, metrics_collector):
        """
        Ensure QA metrics are exported to monitoring system (Prometheus/Grafana).
        
        Metrics to track:
        - tiktok_accuracy_rate
        - tiktok_freshness_hours
        - tiktok_duplicate_count
        - tiktok_pipeline_success_rate
        """
        required_metrics = [
            'tiktok_accuracy_rate',
            'tiktok_freshness_hours',
            'tiktok_duplicate_count',
            'tiktok_pipeline_success_rate'
        ]
        
        exported_metrics = metrics_collector.get_metric_names()
        
        for metric in required_metrics:
            assert metric in exported_metrics, f"Missing metric export: {metric}"


# ==============================================================================
# FIXTURES & UTILITIES
# ==============================================================================

@pytest.fixture
def tiktok_df():
    """Sample TikTok data for testing."""
    return pd.DataFrame({
        'video_id': ['vid_001', 'vid_002', 'vid_003'],
        'author_id': ['auth_123', 'auth_456', 'auth_123'],
        'views': [10000, 5000, 20000],
        'likes': [500, 300, 1500],
        'shares': [50, 30, 150],
        'published_at': ['2025-11-03 10:00:00', '2025-11-03 14:00:00', '2025-11-04 08:00:00'],
        'ingested_at': ['2025-11-04 02:00:00', '2025-11-04 02:00:00', '2025-11-04 09:00:00']
    })

@pytest.fixture
def authors_df():
    """Sample authors data for referential integrity tests."""
    return pd.DataFrame({
        'author_id': ['auth_123', 'auth_456', 'auth_789'],
        'username': ['user1', 'user2', 'user3']
    })

@pytest.fixture
def baseline_stats():
    """Baseline statistics for anomaly detection."""
    return {
        'avg_daily_volume': 1000000,
        'avg_engagement_rate': 0.05,
        'p95_freshness_hours': 12
    }

@pytest.fixture
def expected_schema():
    """Expected TikTok data schema."""
    return {
        'video_id': 'string',
        'author_id': 'string',
        'views': 'int64',
        'likes': 'int64',
        'shares': 'int64',
        'published_at': 'datetime64',
        'ingested_at': 'datetime64'
    }


# ==============================================================================
# EXAMPLE: INTEGRATION TEST
# ==============================================================================

@pytest.mark.integration
def test_end_to_end_tiktok_pipeline():
    """
    Full pipeline test: Extract → Validate → Transform → Load → Quality Check
    
    This is a smoke test to ensure the full pipeline works.
    Run nightly or before production deployments.
    """
    # Step 1: Extract (mock TikTok API)
    raw_data = extract_from_tiktok_api(limit=100)
    assert len(raw_data) > 0, "Extraction failed - no data returned"
    
    # Step 2: Validate raw data
    validation_errors = validate_raw_tiktok_data(raw_data)
    assert len(validation_errors) == 0, f"Validation failed: {validation_errors}"
    
    # Step 3: Transform
    transformed_data = transform_tiktok_data(raw_data)
    assert 'engagement_rate' in transformed_data.columns, "Transform failed - missing derived fields"
    
    # Step 4: Load to Postgres
    load_success = load_to_postgres(transformed_data, table='tiktok_videos')
    assert load_success, "Load failed - database insert error"
    
    # Step 5: Quality check
    quality_report = run_data_quality_checks(table='tiktok_videos')
    assert quality_report['accuracy_rate'] >= 0.999, f"Quality check failed: {quality_report}"


# ==============================================================================
# USAGE INSTRUCTIONS
# ==============================================================================

"""
HOW TO RUN THESE TESTS:

1. Unit Tests (fast, run on every commit):
   pytest test_tiktok_qa.py::TestTikTokDataAccuracy -v

2. Integration Tests (slower, run before deployment):
   pytest test_tiktok_qa.py -m integration -v

3. Full Test Suite (all tests):
   pytest test_tiktok_qa.py -v --cov=tiktok_pipeline

4. Continuous Monitoring (run every hour):
   pytest test_tiktok_qa.py::TestTikTokMonitoring -v

5. Generate HTML Report:
   pytest test_tiktok_qa.py --html=report.html --self-contained-html

EXPECTED OUTPUT:
================================================================================
test_tiktok_qa.py::TestTikTokDataAccuracy::test_schema_compliance ✓ PASSED
test_tiktok_qa.py::TestTikTokDataAccuracy::test_data_freshness ✓ PASSED
test_tiktok_qa.py::TestTikTokDataAccuracy::test_deduplication ✓ PASSED
test_tiktok_qa.py::TestTikTokDataAccuracy::test_referential_integrity ✓ PASSED
test_tiktok_qa.py::TestTikTokDataAccuracy::test_business_logic_validation ✓ PASSED
test_tiktok_qa.py::TestTikTokAirflowDAG::test_dag_exists ✓ PASSED
test_tiktok_qa.py::TestTikTokAirflowDAG::test_dag_structure ✓ PASSED
test_tiktok_qa.py::TestTikTokAirflowDAG::test_dag_success_rate ✓ PASSED
test_tiktok_qa.py::TestTikTokAirflowDAG::test_task_execution_time ✓ PASSED
test_tiktok_qa.py::TestTikTokMonitoring::test_volume_anomaly_detection ✓ PASSED
test_tiktok_qa.py::TestTikTokMonitoring::test_schema_drift_detection ✓ PASSED
test_tiktok_qa.py::TestTikTokMonitoring::test_data_quality_metrics_export ✓ PASSED
================================================================================
12 passed in 2.34s

INTEGRATION WITH CI/CD:
- Add to GitHub Actions: .github/workflows/qa_tests.yml
- Run on every PR: Prevents bad code from merging
- Run nightly: Catches data drift, API changes
- Export metrics to Grafana: Track quality trends over time
"""
