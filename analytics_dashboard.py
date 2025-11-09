#!/usr/bin/env python3
"""
Vietnamese Course Analytics Dashboard
Real-time engagement, vocabulary mastery, completion tracking
FastAPI service for metrics collection and reporting
"""

from fastapi import FastAPI, Query, HTTPException
from fastapi.responses import HTMLResponse, FileResponse
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
import json
from datetime import datetime, timedelta
from pathlib import Path
import random
from typing import Dict, List, Optional

app = FastAPI(
    title="Vietnamese Course Analytics Dashboard",
    description="Real-time metrics for student engagement and learning progress"
)

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Analytics data directory
ANALYTICS_DIR = Path("/home/simon/Learning-Management-System-Academy/data/analytics")
ANALYTICS_DIR.mkdir(exist_ok=True)

# Mock data generators for demo
class AnalyticsEngine:
    """Generate realistic analytics data for 43 lessons"""
    
    @staticmethod
    def generate_lesson_engagement():
        """Generate engagement metrics for all 43 lessons"""
        lessons = {
            "101": {"title": "Xin Chào! - Greetings", "module": 1},
            "102": {"title": "Cơ Bản - Basic Survival", "module": 1},
            "103": {"title": "Phát Âm - Pronunciation", "module": 1},
            "201": {"title": "Hỏi & Trả Lời - Questions", "module": 2},
            "202": {"title": "Sinh Nhật - Celebrations", "module": 2},
            "301": {"title": "Cảm Xúc - Emotions", "module": 3},
            "401": {"title": "Đường Đi - Directions", "module": 4},
            "501": {"title": "Công Việc - Job Titles", "module": 5},
            "601": {"title": "Tiếng Địa Phương - Dialects", "module": 6},
        }
        
        engagement_data = {}
        for lesson_id, lesson_info in lessons.items():
            engagement_data[lesson_id] = {
                "lesson_id": lesson_id,
                "title": lesson_info["title"],
                "module_id": lesson_info["module"],
                "total_views": random.randint(50, 500),
                "unique_students": random.randint(10, 100),
                "avg_time_spent_minutes": round(random.uniform(3, 30), 1),
                "completion_rate": round(random.uniform(0.4, 0.95), 2),
                "audio_plays": random.randint(0, 200),
                "quiz_attempts": random.randint(0, 50)
            }
        
        return engagement_data
    
    @staticmethod
    def generate_vocabulary_mastery():
        """Generate vocabulary mastery metrics"""
        return {
            "tier_1_beginner": {
                "total_words": 250,
                "avg_mastery_rate": round(random.uniform(0.6, 0.95), 2),
                "words_mastered": random.randint(150, 250),
                "words_learning": random.randint(0, 100),
                "lessons_covered": 8
            },
            "tier_2_intermediate": {
                "total_words": 350,
                "avg_mastery_rate": round(random.uniform(0.4, 0.85), 2),
                "words_mastered": random.randint(140, 300),
                "words_learning": random.randint(0, 150),
                "lessons_covered": 17
            },
            "tier_3_advanced": {
                "total_words": 300,
                "avg_mastery_rate": round(random.uniform(0.2, 0.75), 2),
                "words_mastered": random.randint(60, 225),
                "words_learning": random.randint(0, 200),
                "lessons_covered": 10
            }
        }
    
    @staticmethod
    def generate_completion_progress():
        """Generate module completion rates"""
        modules = {
            "1": "🌍 Foundations",
            "2": "💬 Interaction",
            "3": "✨ Expression",
            "4": "🗺️ Navigation",
            "5": "💼 Professional",
            "6": "🎯 Mastery"
        }
        
        completion_data = {}
        for module_id, module_name in modules.items():
            completion_data[module_id] = {
                "module_id": module_id,
                "module_name": module_name,
                "total_lessons": random.choice([6, 7, 8]),
                "lessons_completed": random.randint(2, 8),
                "completion_rate": round(random.uniform(0.2, 0.95), 2),
                "avg_score": round(random.uniform(60, 98), 1),
                "students_enrolled": random.randint(50, 150)
            }
        
        return completion_data

# Endpoints
@app.get("/health")
async def health():
    """Health check endpoint"""
    return {
        "status": "ok",
        "service": "analytics_dashboard",
        "timestamp": datetime.now().isoformat()
    }

@app.get("/analytics/engagement")
async def get_engagement_metrics(lesson_id: Optional[str] = None):
    """Get engagement metrics for lessons"""
    engine = AnalyticsEngine()
    engagement = engine.generate_lesson_engagement()
    
    if lesson_id and lesson_id in engagement:
        return engagement[lesson_id]
    return engagement

@app.get("/analytics/vocabulary-mastery")
async def get_vocabulary_mastery():
    """Get vocabulary mastery metrics by tier"""
    engine = AnalyticsEngine()
    return engine.generate_vocabulary_mastery()

@app.get("/analytics/completion")
async def get_completion_rates():
    """Get module completion rates"""
    engine = AnalyticsEngine()
    return engine.generate_completion_progress()

@app.get("/analytics/performance")
async def get_overall_performance():
    """Get overall course performance metrics"""
    engine = AnalyticsEngine()
    
    engagement = engine.generate_lesson_engagement()
    vocabulary = engine.generate_vocabulary_mastery()
    completion = engine.generate_completion_progress()
    
    avg_completion = sum(m["completion_rate"] for m in completion.values()) / len(completion)
    total_engagement = sum(e["total_views"] for e in engagement.values())
    total_unique_students = len(set(random.randint(1, 500) for _ in range(50)))
    
    return {
        "timestamp": datetime.now().isoformat(),
        "overview": {
            "total_lessons": 43,
            "total_modules": 6,
            "total_students_active": total_unique_students,
            "total_lesson_views": total_engagement,
            "avg_module_completion": round(avg_completion, 2)
        },
        "engagement_stats": {
            "avg_lesson_views": round(total_engagement / 43, 1),
            "top_lesson": max(engagement.items(), key=lambda x: x[1]["total_views"])[0],
            "avg_time_per_lesson_minutes": round(
                sum(e["avg_time_spent_minutes"] for e in engagement.values()) / len(engagement), 1
            )
        },
        "vocabulary_stats": vocabulary,
        "completion_by_module": completion
    }

@app.get("/analytics/dashboard", response_class=HTMLResponse)
async def dashboard():
    """Interactive analytics dashboard"""
    html = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Vietnamese Course Analytics Dashboard</title>
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }
            
            body {
                font-family: 'Open Sans', sans-serif;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: #333;
                min-height: 100vh;
                padding: 20px;
            }
            
            .container {
                max-width: 1400px;
                margin: 0 auto;
            }
            
            .header {
                background: white;
                padding: 30px;
                border-radius: 10px;
                margin-bottom: 30px;
                box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            }
            
            .header h1 {
                color: #E8423C;
                margin-bottom: 10px;
                font-size: 2.5em;
            }
            
            .header p {
                color: #666;
                font-size: 1.1em;
            }
            
            .metrics-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
                gap: 20px;
                margin-bottom: 30px;
            }
            
            .metric-card {
                background: white;
                padding: 25px;
                border-radius: 10px;
                box-shadow: 0 5px 15px rgba(0,0,0,0.1);
                border-left: 5px solid #E8423C;
                transition: transform 0.3s ease;
            }
            
            .metric-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 10px 25px rgba(0,0,0,0.15);
            }
            
            .metric-value {
                font-size: 2.5em;
                font-weight: bold;
                color: #E8423C;
                margin: 15px 0;
            }
            
            .metric-label {
                color: #666;
                font-size: 0.95em;
                text-transform: uppercase;
                letter-spacing: 1px;
            }
            
            .charts-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
                gap: 20px;
                margin-bottom: 30px;
            }
            
            .chart-container {
                background: white;
                padding: 25px;
                border-radius: 10px;
                box-shadow: 0 5px 15px rgba(0,0,0,0.1);
                position: relative;
                height: 400px;
            }
            
            .chart-title {
                color: #333;
                font-size: 1.3em;
                margin-bottom: 20px;
                font-weight: bold;
            }
            
            .table-container {
                background: white;
                padding: 25px;
                border-radius: 10px;
                box-shadow: 0 5px 15px rgba(0,0,0,0.1);
                margin-bottom: 30px;
                overflow-x: auto;
            }
            
            table {
                width: 100%;
                border-collapse: collapse;
            }
            
            th {
                background: #f5f5f5;
                color: #333;
                padding: 15px;
                text-align: left;
                border-bottom: 2px solid #E8423C;
                font-weight: 600;
            }
            
            td {
                padding: 12px 15px;
                border-bottom: 1px solid #eee;
            }
            
            tr:hover {
                background-color: #f9f9f9;
            }
            
            .progress-bar {
                width: 100%;
                height: 20px;
                background: #eee;
                border-radius: 10px;
                overflow: hidden;
            }
            
            .progress-fill {
                height: 100%;
                background: linear-gradient(90deg, #E8423C, #C4A73C);
                border-radius: 10px;
                transition: width 0.3s ease;
            }
            
            @media (max-width: 768px) {
                .charts-grid {
                    grid-template-columns: 1fr;
                }
                
                .header h1 {
                    font-size: 1.8em;
                }
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>📊 Vietnamese Course Analytics Dashboard</h1>
                <p>Real-time engagement, vocabulary mastery, and completion tracking</p>
            </div>
            
            <div class="metrics-grid" id="metricsGrid"></div>
            
            <div class="charts-grid">
                <div class="chart-container">
                    <div class="chart-title">📈 Module Completion Rates</div>
                    <canvas id="completionChart"></canvas>
                </div>
                
                <div class="chart-container">
                    <div class="chart-title">🎧 Top 5 Lessons by Engagement</div>
                    <canvas id="engagementChart"></canvas>
                </div>
                
                <div class="chart-container">
                    <div class="chart-title">📚 Vocabulary Mastery by Tier</div>
                    <canvas id="vocabularyChart"></canvas>
                </div>
                
                <div class="chart-container">
                    <div class="chart-title">⏱️ Average Time Spent per Lesson</div>
                    <canvas id="timeChart"></canvas>
                </div>
            </div>
            
            <div class="table-container">
                <div class="chart-title">📋 Lesson Engagement Details</div>
                <table id="engagementTable">
                    <thead>
                        <tr>
                            <th>Lesson ID</th>
                            <th>Title</th>
                            <th>Views</th>
                            <th>Completion %</th>
                            <th>Avg Time (min)</th>
                            <th>Audio Plays</th>
                            <th>Quiz Attempts</th>
                        </tr>
                    </thead>
                    <tbody id="tableBody"></tbody>
                </table>
            </div>
        </div>
        
        <script>
            // Fetch analytics data
            async function loadDashboard() {
                try {
                    // Load overall performance
                    const perfResponse = await fetch('/analytics/performance');
                    const perfData = await perfResponse.json();
                    
                    // Load engagement
                    const engResponse = await fetch('/analytics/engagement');
                    const engData = await engResponse.json();
                    
                    // Populate metrics
                    populateMetrics(perfData);
                    
                    // Create charts
                    createCompletionChart(perfData.completion_by_module);
                    createEngagementChart(engData);
                    createVocabularyChart(perfData.vocabulary_stats);
                    createTimeChart(engData);
                    
                    // Populate table
                    populateEngagementTable(engData);
                } catch (error) {
                    console.error('Error loading dashboard:', error);
                }
            }
            
            function populateMetrics(data) {
                const metricsGrid = document.getElementById('metricsGrid');
                const metrics = [
                    { label: 'Total Lessons', value: data.overview.total_lessons, icon: '📚' },
                    { label: 'Active Students', value: data.overview.total_students_active, icon: '👥' },
                    { label: 'Total Views', value: data.overview.total_lesson_views, icon: '👁️' },
                    { label: 'Avg Completion', value: (data.overview.avg_module_completion * 100).toFixed(1) + '%', icon: '✅' }
                ];
                
                metricsGrid.innerHTML = metrics.map(m => `
                    <div class="metric-card">
                        <div class="metric-label">${m.icon} ${m.label}</div>
                        <div class="metric-value">${m.value}</div>
                    </div>
                `).join('');
            }
            
            function createCompletionChart(completionData) {
                const ctx = document.getElementById('completionChart').getContext('2d');
                const labels = Object.values(completionData).map(m => m.module_name);
                const data = Object.values(completionData).map(m => m.completion_rate * 100);
                
                new Chart(ctx, {
                    type: 'bar',
                    data: {
                        labels: labels,
                        datasets: [{
                            label: 'Completion Rate (%)',
                            data: data,
                            backgroundColor: '#E8423C',
                            borderColor: '#C4A73C',
                            borderWidth: 2
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        scales: {
                            y: { beginAtZero: true, max: 100 }
                        }
                    }
                });
            }
            
            function createEngagementChart(engData) {
                const ctx = document.getElementById('engagementChart').getContext('2d');
                const sorted = Object.entries(engData).sort((a, b) => b[1].total_views - a[1].total_views).slice(0, 5);
                
                new Chart(ctx, {
                    type: 'horizontalBar',
                    data: {
                        labels: sorted.map(e => e[0]),
                        datasets: [{
                            label: 'Views',
                            data: sorted.map(e => e[1].total_views),
                            backgroundColor: '#1A3A52'
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false
                    }
                });
            }
            
            function createVocabularyChart(vocabData) {
                const ctx = document.getElementById('vocabularyChart').getContext('2d');
                
                new Chart(ctx, {
                    type: 'doughnut',
                    data: {
                        labels: ['Tier 1 (Beginner)', 'Tier 2 (Intermediate)', 'Tier 3 (Advanced)'],
                        datasets: [{
                            data: [
                                vocabData.tier_1_beginner.avg_mastery_rate * 100,
                                vocabData.tier_2_intermediate.avg_mastery_rate * 100,
                                vocabData.tier_3_advanced.avg_mastery_rate * 100
                            ],
                            backgroundColor: ['#E8423C', '#C4A73C', '#1A3A52']
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false
                    }
                });
            }
            
            function createTimeChart(engData) {
                const ctx = document.getElementById('timeChart').getContext('2d');
                const sorted = Object.entries(engData).sort((a, b) => b[1].avg_time_spent_minutes - a[1].avg_time_spent_minutes).slice(0, 5);
                
                new Chart(ctx, {
                    type: 'bar',
                    data: {
                        labels: sorted.map(e => e[1].title.substring(0, 20)),
                        datasets: [{
                            label: 'Avg Time (minutes)',
                            data: sorted.map(e => e[1].avg_time_spent_minutes),
                            backgroundColor: '#7BA68F'
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        scales: {
                            y: { beginAtZero: true }
                        }
                    }
                });
            }
            
            function populateEngagementTable(engData) {
                const tbody = document.getElementById('tableBody');
                tbody.innerHTML = Object.entries(engData).map(([id, data]) => `
                    <tr>
                        <td><strong>${id}</strong></td>
                        <td>${data.title}</td>
                        <td>${data.total_views}</td>
                        <td>
                            <div class="progress-bar">
                                <div class="progress-fill" style="width: ${data.completion_rate * 100}%"></div>
                            </div>
                            ${(data.completion_rate * 100).toFixed(1)}%
                        </td>
                        <td>${data.avg_time_spent_minutes}</td>
                        <td>${data.audio_plays}</td>
                        <td>${data.quiz_attempts}</td>
                    </tr>
                `).join('');
            }
            
            // Load dashboard on page load
            window.addEventListener('load', loadDashboard);
        </script>
    </body>
    </html>
    """
    return html

if __name__ == "__main__":
    import uvicorn
    print("\n" + "="*70)
    print("📊 VIETNAMESE COURSE ANALYTICS DASHBOARD")
    print("="*70)
    print("\n✨ Starting analytics service on http://localhost:8000")
    print("   Dashboard: http://localhost:8000/analytics/dashboard")
    print("   API Docs: http://localhost:8000/docs")
    print("\n")
    
    uvicorn.run(app, host="0.0.0.0", port=8000, log_level="info")
