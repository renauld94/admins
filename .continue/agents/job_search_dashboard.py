#!/usr/bin/env python3
"""
🚀 Job Search Dashboard - Real-Time Monitoring & Analytics
==========================================================

Interactive dashboard to track:
- Job search progress (funnel analytics)
- Application pipeline
- Interview schedule
- Salary trends
- Company research
- Weekly KPIs and goal tracking
"""

import json
from datetime import datetime, timedelta
from pathlib import Path
import os
from collections import defaultdict


class JobSearchDashboard:
    """Real-time job search dashboard"""

    def __init__(self, agent_dir: str = None):
        if agent_dir is None:
            agent_dir = os.path.expanduser("~/.job_search_agent")
        self.agent_dir = Path(agent_dir)

    def generate_html_dashboard(self) -> str:
        """Generate HTML dashboard"""
        
        html = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🎯 Job Search Dashboard</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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
            border-radius: 15px;
            margin-bottom: 30px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .header h1 {
            color: #333;
            font-size: 2.5em;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .header .date {
            color: #666;
            font-size: 1.1em;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: white;
            padding: 25px;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            text-align: center;
        }

        .stat-card .number {
            font-size: 3em;
            font-weight: bold;
            color: #667eea;
            margin-bottom: 10px;
        }

        .stat-card .label {
            color: #666;
            font-size: 1.1em;
        }

        .stat-card .emoji {
            font-size: 2em;
            margin-bottom: 10px;
        }

        .chart-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .chart-container {
            background: white;
            padding: 25px;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
        }

        .chart-container h3 {
            color: #333;
            margin-bottom: 20px;
            font-size: 1.3em;
        }

        .opportunities-table {
            background: white;
            padding: 25px;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            overflow-x: auto;
        }

        .opportunities-table h3 {
            color: #333;
            margin-bottom: 20px;
            font-size: 1.3em;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        th {
            background: #f8f9fa;
            color: #333;
            padding: 15px;
            text-align: left;
            font-weight: 600;
            border-bottom: 2px solid #e0e0e0;
        }

        td {
            padding: 15px;
            border-bottom: 1px solid #e0e0e0;
        }

        tr:hover {
            background: #f8f9fa;
        }

        .status-badge {
            display: inline-block;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 0.9em;
            font-weight: 600;
        }

        .status-applied {
            background: #e3f2fd;
            color: #1976d2;
        }

        .status-interview {
            background: #fff3e0;
            color: #f57c00;
        }

        .status-offer {
            background: #e8f5e9;
            color: #388e3c;
        }

        .status-rejected {
            background: #ffebee;
            color: #c62828;
        }

        .progress-bar {
            width: 100%;
            height: 25px;
            background: #e0e0e0;
            border-radius: 12px;
            overflow: hidden;
            margin: 10px 0;
        }

        .progress-fill {
            height: 100%;
            background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 600;
            font-size: 0.9em;
        }

        .footer {
            text-align: center;
            color: white;
            margin-top: 40px;
            padding: 20px;
        }

        @media (max-width: 768px) {
            .header {
                flex-direction: column;
                gap: 20px;
                text-align: center;
            }

            .chart-grid {
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
            <div>
                <h1>🎯 Job Search Dashboard</h1>
                <div class="date" id="currentDate"></div>
            </div>
            <div style="text-align: right;">
                <div style="font-size: 1.3em; color: #667eea; font-weight: 600;">Last Updated</div>
                <div style="color: #666;" id="lastUpdated"></div>
            </div>
        </div>

        <!-- Key Metrics -->
        <div class="stats-grid" id="statsGrid">
            <div class="stat-card">
                <div class="emoji">🔍</div>
                <div class="number" id="totalOpportunities">0</div>
                <div class="label">Opportunities Found</div>
            </div>
            <div class="stat-card">
                <div class="emoji">✉️</div>
                <div class="number" id="totalApplications">0</div>
                <div class="label">Applications Sent</div>
            </div>
            <div class="stat-card">
                <div class="emoji">📞</div>
                <div class="number" id="totalInterviews">0</div>
                <div class="label">Interviews Scheduled</div>
            </div>
            <div class="stat-card">
                <div class="emoji">🎉</div>
                <div class="number" id="totalOffers">0</div>
                <div class="label">Offers Received</div>
            </div>
        </div>

        <!-- Key Performance Indicators -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="emoji">📊</div>
                <div class="number" id="applicationRate">0%</div>
                <div class="label">Application Rate</div>
            </div>
            <div class="stat-card">
                <div class="emoji">🎯</div>
                <div class="number" id="interviewRate">0%</div>
                <div class="label">Interview Conversion</div>
            </div>
            <div class="stat-card">
                <div class="emoji">💰</div>
                <div class="number" id="offerRate">0%</div>
                <div class="label">Offer Close Rate</div>
            </div>
            <div class="stat-card">
                <div class="emoji">⭐</div>
                <div class="number" id="avgMatchScore">0%</div>
                <div class="label">Average Match Score</div>
            </div>
        </div>

        <!-- Charts -->
        <div class="chart-grid">
            <div class="chart-container">
                <h3>📈 Application Funnel</h3>
                <canvas id="funnelChart"></canvas>
            </div>
            <div class="chart-container">
                <h3>📅 Applications Over Time</h3>
                <canvas id="timelineChart"></canvas>
            </div>
        </div>

        <!-- Progress Tracking -->
        <div style="background: white; padding: 25px; border-radius: 15px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); margin-bottom: 30px;">
            <h3 style="color: #333; margin-bottom: 20px; font-size: 1.3em;">🎯 Weekly Goals</h3>
            <div style="margin-bottom: 20px;">
                <div style="color: #666; margin-bottom: 8px;">Applications Target: 5/week</div>
                <div class="progress-bar">
                    <div class="progress-fill" style="width: 60%;"><span>3 / 5</span></div>
                </div>
            </div>
            <div style="margin-bottom: 20px;">
                <div style="color: #666; margin-bottom: 8px;">Interview Rate Target: 20%</div>
                <div class="progress-bar">
                    <div class="progress-fill" style="width: 45%;"><span>9%</span></div>
                </div>
            </div>
            <div>
                <div style="color: #666; margin-bottom: 8px;">Offer Close Rate Target: 30%</div>
                <div class="progress-bar">
                    <div class="progress-fill" style="width: 33%;"><span>10%</span></div>
                </div>
            </div>
        </div>

        <!-- Top Opportunities -->
        <div class="opportunities-table">
            <h3>⭐ Top Matching Opportunities</h3>
            <table>
                <thead>
                    <tr>
                        <th>Title</th>
                        <th>Company</th>
                        <th>Location</th>
                        <th>Match</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody id="opportunitiesBody">
                    <tr>
                        <td colspan="5" style="text-align: center; color: #999;">No opportunities yet</td>
                    </tr>
                </tbody>
            </table>
        </div>

        <!-- Upcoming Follow-ups -->
        <div class="opportunities-table" style="margin-top: 30px;">
            <h3>📞 Upcoming Follow-ups</h3>
            <table>
                <thead>
                    <tr>
                        <th>Company</th>
                        <th>Position</th>
                        <th>Follow-up Date</th>
                        <th>Days Until</th>
                    </tr>
                </thead>
                <tbody id="followupsBody">
                    <tr>
                        <td colspan="4" style="text-align: center; color: #999;">No follow-ups scheduled</td>
                    </tr>
                </tbody>
            </table>
        </div>

        <div class="footer">
            <p>🎯 Keep pushing forward. Every application gets you closer to your dream role!</p>
            <p style="margin-top: 10px; font-size: 0.9em; opacity: 0.8;">
                Last generated: <span id="generatedTime"></span>
            </p>
        </div>
    </div>

    <script>
        // Initialize dashboard
        function initDashboard() {
            const now = new Date();
            document.getElementById('currentDate').textContent = now.toLocaleDateString('en-US', 
                { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });
            document.getElementById('lastUpdated').textContent = now.toLocaleTimeString();
            document.getElementById('generatedTime').textContent = now.toLocaleString();

            // Initialize charts
            initFunnelChart();
            initTimelineChart();

            // Load data
            loadDashboardData();
        }

        function initFunnelChart() {
            const ctx = document.getElementById('funnelChart').getContext('2d');
            new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: ['Discovered', 'Applied', 'Interview', 'Offers'],
                    datasets: [{
                        label: 'Count',
                        data: [15, 8, 2, 1],
                        backgroundColor: ['#667eea', '#764ba2', '#f093fb', '#f5576c'],
                        borderRadius: 8
                    }]
                },
                options: {
                    indexAxis: 'y',
                    responsive: true,
                    plugins: {
                        legend: { display: false }
                    },
                    scales: {
                        x: { beginAtZero: true }
                    }
                }
            });
        }

        function initTimelineChart() {
            const ctx = document.getElementById('timelineChart').getContext('2d');
            new Chart(ctx, {
                type: 'line',
                data: {
                    labels: ['Week 1', 'Week 2', 'Week 3', 'Week 4', 'Week 5'],
                    datasets: [{
                        label: 'Applications',
                        data: [1, 3, 5, 6, 8],
                        borderColor: '#667eea',
                        backgroundColor: 'rgba(102, 126, 234, 0.1)',
                        tension: 0.4,
                        fill: true,
                        pointRadius: 6,
                        pointBackgroundColor: '#667eea'
                    }]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: { display: false }
                    },
                    scales: {
                        y: { beginAtZero: true }
                    }
                }
            });
        }

        function loadDashboardData() {
            // Mock data - replace with actual API calls
            document.getElementById('totalOpportunities').textContent = '15';
            document.getElementById('totalApplications').textContent = '8';
            document.getElementById('totalInterviews').textContent = '2';
            document.getElementById('totalOffers').textContent = '1';
            document.getElementById('applicationRate').textContent = '53%';
            document.getElementById('interviewRate').textContent = '25%';
            document.getElementById('offerRate').textContent = '50%';
            document.getElementById('avgMatchScore').textContent = '72%';
        }

        // Initialize on page load
        window.addEventListener('load', initDashboard);
    </script>
</body>
</html>
        """
        
        return html

    def save_dashboard(self, filepath: str = None):
        """Save dashboard to HTML file"""
        if filepath is None:
            filepath = str(self.agent_dir / "job_search_dashboard.html")
        
        with open(filepath, 'w') as f:
            f.write(self.generate_html_dashboard())
        
        print(f"✅ Dashboard saved to {filepath}")
        return filepath


def main():
    """Generate and save dashboard"""
    dashboard = JobSearchDashboard()
    filepath = dashboard.save_dashboard()
    print(f"\n📊 Job Search Dashboard ready!")
    print(f"📍 Location: {filepath}")
    print(f"🌐 Open in browser to view live dashboard")


if __name__ == "__main__":
    main()
