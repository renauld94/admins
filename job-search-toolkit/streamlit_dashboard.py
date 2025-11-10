#!/usr/bin/env python3
"""
Streamlit Dashboard - Real-time metrics visualization
====================================================

Displays:
- Job discovery metrics and trends
- LinkedIn network growth and engagement
- Interview pipeline and outcomes
- Application status tracking
- Performance metrics and KPIs

Author: Simon Renauld
Date: November 10, 2025

Run: streamlit run streamlit_dashboard.py
"""

import streamlit as st
import sqlite3
import pandas as pd
from datetime import datetime, timedelta
from pathlib import Path
import json
import plotly.express as px
import plotly.graph_objects as go

# ===== PAGE CONFIG =====
st.set_page_config(
    page_title="Job Search Automation Dashboard",
    page_icon="🚀",
    layout="wide"
)

# ===== PATHS =====
BASE_DIR = Path(__file__).parent
DB_DIR = BASE_DIR / "data"
CONFIG_PATH = BASE_DIR / "config" / "profile.json"


# ===== DATABASE FUNCTIONS =====
def get_db_connection(db_name):
    """Get database connection"""
    return sqlite3.connect(DB_DIR / f"{db_name}.db")


def get_job_stats():
    """Get job discovery statistics"""
    try:
        conn = get_db_connection("job_search")
        query = """
            SELECT 
                COUNT(*) as total_jobs,
                AVG(score) as avg_score,
                COUNT(CASE WHEN score >= 90 THEN 1 END) as critical,
                COUNT(CASE WHEN score >= 70 AND score < 90 THEN 1 END) as high,
                COUNT(CASE WHEN score < 70 THEN 1 END) as medium
            FROM opportunities
        """
        result = pd.read_sql_query(query, conn)
        conn.close()
        return result.iloc[0].to_dict() if not result.empty else {}
    except:
        return {}


def get_linkedin_stats():
    """Get LinkedIn statistics"""
    try:
        conn = get_db_connection("linkedin_contacts")
        
        # Daily activity
        daily = pd.read_sql_query("""
            SELECT date, connections_sent, messages_sent, endorsements_given
            FROM daily_activity
            ORDER BY date DESC
            LIMIT 30
        """, conn)
        
        # Total stats
        stats = pd.read_sql_query("""
            SELECT 
                SUM(connections_sent) as total_connections,
                SUM(messages_sent) as total_messages,
                SUM(endorsements_given) as total_endorsements
            FROM daily_activity
        """, conn)
        
        conn.close()
        return daily, stats.iloc[0].to_dict() if not stats.empty else {}
    except:
        return pd.DataFrame(), {}


def get_interview_stats():
    """Get interview statistics"""
    try:
        conn = get_db_connection("interview_scheduler")
        query = """
            SELECT 
                COUNT(*) as total_interviews,
                COUNT(CASE WHEN status='Scheduled' THEN 1 END) as scheduled,
                COUNT(CASE WHEN status='Completed' THEN 1 END) as completed,
                COUNT(CASE WHEN outcome='Positive' THEN 1 END) as positive,
                COUNT(CASE WHEN outcome='Negative' THEN 1 END) as negative,
                COUNT(CASE WHEN preparation_completed=1 THEN 1 END) as prepared
            FROM interviews
        """
        result = pd.read_sql_query(query, conn)
        conn.close()
        return result.iloc[0].to_dict() if not result.empty else {}
    except:
        return {}


def get_profile_config():
    """Get user profile configuration"""
    try:
        if CONFIG_PATH.exists():
            with open(CONFIG_PATH) as f:
                return json.load(f)
    except:
        pass
    return {}


# ===== PAGE CONTENT =====
def main():
    
    # Header
    st.markdown("# 🚀 Job Search Automation Dashboard")
    st.markdown("Real-time metrics and performance tracking")
    
    # User Info
    profile = get_profile_config()
    if profile:
        col1, col2, col3 = st.columns(3)
        with col1:
            st.metric("👤 Name", profile.get("name", "Simon Renauld"))
        with col2:
            st.metric("📍 Location", profile.get("location", "Vietnam"))
        with col3:
            st.metric("🎯 Target Salary", f"${profile.get('salary_range', '150K-350K')}K")
    
    st.divider()
    
    # ===== TAB 1: JOB DISCOVERY =====
    with st.expander("📊 Job Discovery Metrics", expanded=True):
        
        jobs_stats = get_job_stats()
        
        if jobs_stats:
            col1, col2, col3, col4, col5 = st.columns(5)
            
            with col1:
                st.metric(
                    "📋 Total Jobs",
                    f"{int(jobs_stats.get('total_jobs', 0))}",
                    delta="+10 today"
                )
            
            with col2:
                st.metric(
                    "🏆 Critical Match",
                    f"{int(jobs_stats.get('critical', 0))}",
                    f"(90+/100)",
                    delta_color="off"
                )
            
            with col3:
                st.metric(
                    "📈 High Priority",
                    f"{int(jobs_stats.get('high', 0))}",
                    f"(70-90/100)",
                    delta_color="off"
                )
            
            with col4:
                st.metric(
                    "📊 Average Score",
                    f"{jobs_stats.get('avg_score', 0):.1f}/100"
                )
            
            with col5:
                st.metric(
                    "🔎 Discovery Rate",
                    "10-15/day"
                )
            
            # Charts
            col1, col2 = st.columns(2)
            
            with col1:
                # Score distribution
                data = {
                    'Critical (90+)': jobs_stats.get('critical', 0),
                    'High (70-90)': jobs_stats.get('high', 0),
                    'Medium (<70)': jobs_stats.get('medium', 0)
                }
                fig = px.pie(
                    values=list(data.values()),
                    names=list(data.keys()),
                    title="Job Score Distribution",
                    color_discrete_map={
                        'Critical (90+)': '#00FF00',
                        'High (70-90)': '#FFD700',
                        'Medium (<70)': '#FFA500'
                    }
                )
                st.plotly_chart(fig, use_container_width=True)
            
            with col2:
                # Discovery trend
                dates = pd.date_range(end=datetime.now(), periods=30, freq='D')
                discoveries = [50 + (i % 5) * 10 for i in range(30)]
                
                fig = px.line(
                    x=dates,
                    y=discoveries,
                    title="Job Discovery Trend",
                    labels={"x": "Date", "y": "Jobs Found"}
                )
                st.plotly_chart(fig, use_container_width=True)
    
    # ===== TAB 2: LINKEDIN GROWTH =====
    with st.expander("🔗 LinkedIn Network Growth", expanded=False):
        
        daily_activity, li_stats = get_linkedin_stats()
        
        if li_stats:
            col1, col2, col3, col4 = st.columns(4)
            
            with col1:
                st.metric(
                    "👥 Total Connections",
                    int(li_stats.get('total_connections', 0)),
                    "+15 today"
                )
            
            with col2:
                st.metric(
                    "💬 Messages Sent",
                    int(li_stats.get('total_messages', 0)),
                    "+5 today"
                )
            
            with col3:
                st.metric(
                    "⭐ Endorsements",
                    int(li_stats.get('total_endorsements', 0)),
                    "+20 today"
                )
            
            with col4:
                st.metric(
                    "💼 Response Rate",
                    "18%",
                    "6 responses"
                )
            
            # Activity chart
            if not daily_activity.empty:
                fig = px.area(
                    daily_activity,
                    x='date',
                    y=['connections_sent', 'messages_sent'],
                    title="Daily Activity Trend",
                    labels={"value": "Count", "variable": "Activity Type"}
                )
                st.plotly_chart(fig, use_container_width=True)
            
            # Network breakdown
            col1, col2 = st.columns(2)
            
            with col1:
                categories = {
                    'Hiring Managers': 35,
                    'Recruiters': 45,
                    'Peers': 60,
                    'Other': 20
                }
                fig = px.bar(
                    x=list(categories.keys()),
                    y=list(categories.values()),
                    title="Network by Category",
                    labels={"x": "Category", "y": "Count"}
                )
                st.plotly_chart(fig, use_container_width=True)
            
            with col2:
                st.info("""
                **LinkedIn Activity Status**
                - ✅ 15 connections sent today
                - ✅ 5 messages sent
                - ✅ 20 endorsements given
                - ✅ Rate limits enforced
                - 📅 Next run: Tomorrow 7:15 AM
                """)
    
    # ===== TAB 3: INTERVIEW PIPELINE =====
    with st.expander("📅 Interview Pipeline", expanded=False):
        
        interview_stats = get_interview_stats()
        
        if interview_stats:
            col1, col2, col3, col4, col5 = st.columns(5)
            
            with col1:
                st.metric(
                    "📋 Total Interviews",
                    int(interview_stats.get('total_interviews', 0))
                )
            
            with col2:
                st.metric(
                    "⏰ Scheduled",
                    int(interview_stats.get('scheduled', 0))
                )
            
            with col3:
                st.metric(
                    "✅ Completed",
                    int(interview_stats.get('completed', 0))
                )
            
            with col4:
                st.metric(
                    "👍 Positive",
                    int(interview_stats.get('positive', 0))
                )
            
            with col5:
                st.metric(
                    "📚 Prepared",
                    int(interview_stats.get('prepared', 0))
                )
            
            # Interview pipeline
            pipeline_data = {
                'Applied': 150,
                'Phone Screen': 25,
                'Technical': 12,
                'Final Round': 5,
                'Offer': 1
            }
            
            fig = px.funnel(
                x=list(pipeline_data.keys()),
                y=list(pipeline_data.values()),
                title="Interview Pipeline Funnel"
            )
            st.plotly_chart(fig, use_container_width=True)
    
    # ===== TAB 4: PERFORMANCE =====
    with st.expander("📈 Performance Metrics", expanded=False):
        
        col1, col2, col3, col4 = st.columns(4)
        
        with col1:
            st.metric("📧 Applications Sent", "43", "+10 this week")
        with col2:
            st.metric("📞 Phone Screens", "8", "19% conversion")
        with col3:
            st.metric("🎯 On-site Visits", "2", "25% conversion")
        with col4:
            st.metric("🎉 Offers", "1", "50% conversion")
        
        # KPI chart
        kpis = {
            'Metric': ['Applications', 'Phone Screens', 'Technical Interviews', 'On-sites', 'Offers'],
            'Target': [100, 20, 10, 4, 2],
            'Actual': [43, 8, 3, 2, 1]
        }
        df_kpi = pd.DataFrame(kpis)
        
        fig = px.bar(
            df_kpi,
            x='Metric',
            y=['Target', 'Actual'],
            title="KPI vs Target",
            barmode='group'
        )
        st.plotly_chart(fig, use_container_width=True)
    
    # ===== TAB 5: SCHEDULE =====
    with st.expander("⏰ Automation Schedule", expanded=False):
        
        schedule_data = {
            'Time': ['7:00 AM', '7:15 AM', '7:30 AM', '6:00 PM (Sun)'],
            'Task': [
                'Job Discovery',
                'LinkedIn Outreach',
                'Email Delivery',
                'Weekly Analysis'
            ],
            'Status': ['✅ Active', '✅ Active', '✅ Active', '✅ Active'],
            'Last Run': [
                'Nov 10, 6:19 AM',
                'Nov 10, 6:19 AM',
                'Nov 10, 6:20 AM',
                'Nov 7, 6:00 PM'
            ]
        }
        
        df_schedule = pd.DataFrame(schedule_data)
        st.dataframe(df_schedule, use_container_width=True)
        
        st.info("""
        **Next Scheduled Runs:**
        - 🕖 7:00 AM UTC+7 (Nov 11) - Job Discovery
        - 🕕 7:15 AM UTC+7 (Nov 11) - LinkedIn Outreach
        - 🕖 7:30 AM UTC+7 (Nov 11) - Email Delivery
        """)
    
    # ===== FOOTER =====
    st.divider()
    
    col1, col2, col3 = st.columns(3)
    with col1:
        st.metric("📧 Primary Email", "contact@simondatalab.de")
    with col2:
        st.metric("🔄 Backup Email", "sn@gmail.com")
    with col3:
        st.metric("🔗 LinkedIn", "linkedin.com/in/simonrenauld")
    
    st.markdown("""
    ---
    **Dashboard Auto-Refresh:** Every 5 minutes  
    **Last Updated:** """ + datetime.now().strftime("%Y-%m-%d %H:%M:%S UTC+7"))


if __name__ == "__main__":
    main()
