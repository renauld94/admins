#!/usr/bin/env python3
"""
Job Search Analytics Dashboard
==============================

Streamlit-based dashboard for monitoring:
- Job discovery pipeline
- Application conversion funnel
- LinkedIn outreach metrics
- Interview pipeline tracking
- Offer status

Installation:
  pip install streamlit plotly pandas

Run:
  streamlit run job_search_dashboard.py

Open:
  http://localhost:8501

Created: November 10, 2025
"""

import streamlit as st
import pandas as pd
import plotly.graph_objects as go
import plotly.express as px
import sqlite3
from datetime import datetime, timedelta
from pathlib import Path

# ===== CONFIGURATION =====
BASE_DIR = Path(__file__).parent
DATA_DIR = BASE_DIR / "data"
DB_PATH = DATA_DIR / "job_search.db"

# ===== PAGE CONFIG =====
st.set_page_config(
    page_title="Job Search Dashboard",
    page_icon="🎯",
    layout="wide",
    initial_sidebar_state="expanded"
)

# ===== STYLING =====
st.markdown("""
<style>
    .metric-card {
        background-color: #f0f2f6;
        padding: 20px;
        border-radius: 10px;
        margin: 10px 0;
    }
    .success-metric { color: #22c55e; }
    .warning-metric { color: #f59e0b; }
    .danger-metric { color: #ef4444; }
    h1 { color: #667eea; }
    h2 { color: #667eea; margin-top: 30px; }
</style>
""", unsafe_allow_html=True)


class JobSearchDashboard:
    """Dashboard for job search analytics"""
    
    def __init__(self, db_path: Path):
        self.db_path = db_path
    
    def query_db(self, query: str) -> pd.DataFrame:
        """Execute database query"""
        try:
            conn = sqlite3.connect(self.db_path)
            df = pd.read_sql_query(query, conn)
            conn.close()
            return df
        except Exception as e:
            st.error(f"Database error: {e}")
            return pd.DataFrame()
    
    def get_pipeline_metrics(self):
        """Get pipeline funnel metrics"""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            cursor.execute("SELECT COUNT(*) FROM jobs WHERE status = 'discovered'")
            discovered = cursor.fetchone()[0]
            
            cursor.execute("SELECT COUNT(*) FROM jobs WHERE status = 'applied'")
            applied = cursor.fetchone()[0]
            
            cursor.execute("SELECT COUNT(*) FROM jobs WHERE status = 'responded'")
            responded = cursor.fetchone()[0]
            
            cursor.execute("SELECT COUNT(*) FROM jobs WHERE status = 'interview'")
            interviews = cursor.fetchone()[0]
            
            cursor.execute("SELECT COUNT(*) FROM jobs WHERE status = 'offer'")
            offers = cursor.fetchone()[0]
            
            conn.close()
            
            return {
                'discovered': discovered,
                'applied': applied,
                'responded': responded,
                'interviews': interviews,
                'offers': offers
            }
        except:
            return {}
    
    def get_daily_metrics(self):
        """Get today's metrics"""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            today = datetime.now().strftime('%Y-%m-%d')
            
            cursor.execute(f"SELECT COUNT(*) FROM jobs WHERE date(posted_date) = '{today}'")
            jobs_today = cursor.fetchone()[0]
            
            cursor.execute(f"SELECT COUNT(*) FROM jobs WHERE date(applied_date) = '{today}' AND status = 'applied'")
            applied_today = cursor.fetchone()[0]
            
            conn.close()
            
            return {
                'jobs_today': jobs_today,
                'applied_today': applied_today
            }
        except:
            return {}
    
    def create_funnel_chart(self, metrics):
        """Create conversion funnel chart"""
        stages = ['Discovered', 'Applied', 'Responded', 'Interview', 'Offer']
        values = [
            metrics.get('discovered', 0),
            metrics.get('applied', 0),
            metrics.get('responded', 0),
            metrics.get('interviews', 0),
            metrics.get('offers', 0)
        ]
        
        # Calculate conversion rates
        conversion_rates = []
        for i in range(len(values)):
            if i == 0 or values[i-1] == 0:
                conversion_rates.append(100)
            else:
                rate = (values[i] / values[i-1]) * 100
                conversion_rates.append(rate)
        
        fig = go.Figure(go.Funnel(
            y=stages,
            x=values,
            marker=dict(color=['#667eea', '#764ba2', '#f093fb', '#4facfe', '#00f2fe']),
            textinfo='value+percent initial'
        ))
        
        fig.update_layout(
            title="Job Search Pipeline Funnel",
            height=500,
            showlegend=False
        )
        
        return fig, conversion_rates
    
    def create_timeline_chart(self):
        """Create job discovery timeline"""
        query = """
        SELECT date(posted_date) as date, COUNT(*) as count
        FROM jobs
        GROUP BY date(posted_date)
        ORDER BY date DESC
        LIMIT 30
        """
        df = self.query_db(query)
        
        if df.empty:
            return None
        
        df['date'] = pd.to_datetime(df['date'])
        df = df.sort_values('date')
        
        fig = px.line(
            df,
            x='date',
            y='count',
            title='Daily Job Discoveries (Last 30 Days)',
            markers=True,
            labels={'count': 'Jobs Found', 'date': 'Date'}
        )
        
        fig.update_traces(line=dict(color='#667eea', width=2))
        fig.update_layout(height=400)
        
        return fig
    
    def create_source_chart(self):
        """Create job source distribution"""
        query = """
        SELECT source, COUNT(*) as count
        FROM jobs
        GROUP BY source
        ORDER BY count DESC
        """
        df = self.query_db(query)
        
        if df.empty:
            return None
        
        fig = px.pie(
            df,
            values='count',
            names='source',
            title='Job Sources Distribution',
            color_discrete_sequence=['#667eea', '#764ba2', '#f093fb', '#4facfe', '#00f2fe', '#43e97b']
        )
        
        fig.update_layout(height=400)
        
        return fig


def main():
    """Main dashboard function"""
    st.title("🎯 Job Search Analytics Dashboard")
    st.markdown("---")
    
    # Initialize dashboard
    dashboard = JobSearchDashboard(DB_PATH)
    
    # Sidebar filters
    with st.sidebar:
        st.header("📊 Dashboard Options")
        
        view_type = st.radio(
            "Select View",
            ["Overview", "Pipeline", "Timeline", "Sources", "Reports"]
        )
        
        refresh_interval = st.slider(
            "Auto-refresh (minutes)",
            1, 60, 5
        )
    
    # Main metrics row
    col1, col2, col3, col4, col5 = st.columns(5)
    
    metrics = dashboard.get_pipeline_metrics()
    daily = dashboard.get_daily_metrics()
    
    with col1:
        st.metric(
            "🔍 Discovered",
            metrics.get('discovered', 0),
            delta=f"+{daily.get('jobs_today', 0)} today"
        )
    
    with col2:
        st.metric(
            "📋 Applied",
            metrics.get('applied', 0),
            delta=f"+{daily.get('applied_today', 0)} today"
        )
    
    with col3:
        st.metric(
            "💬 Responded",
            metrics.get('responded', 0)
        )
    
    with col4:
        st.metric(
            "🎤 Interviews",
            metrics.get('interviews', 0)
        )
    
    with col5:
        st.metric(
            "🎉 Offers",
            metrics.get('offers', 0)
        )
    
    st.markdown("---")
    
    # Views
    if view_type == "Overview":
        st.header("📊 Overview")
        
        col1, col2 = st.columns(2)
        
        with col1:
            # Funnel chart
            funnel_fig, conv_rates = dashboard.create_funnel_chart(metrics)
            if funnel_fig:
                st.plotly_chart(funnel_fig, use_container_width=True)
                
                # Conversion rates
                st.subheader("📈 Conversion Rates")
                stages = ['Discovered→Applied', 'Applied→Responded', 'Responded→Interview', 'Interview→Offer']
                for i, (stage, rate) in enumerate(zip(stages, conv_rates[1:])):
                    st.write(f"{stage}: {rate:.1f}%")
        
        with col2:
            st.subheader("🎯 Quick Stats")
            
            if metrics.get('applied', 0) > 0:
                response_rate = (metrics.get('responded', 0) / metrics.get('applied', 0)) * 100
                st.write(f"**Response Rate**: {response_rate:.1f}%")
            
            if metrics.get('responded', 0) > 0:
                interview_rate = (metrics.get('interviews', 0) / metrics.get('responded', 0)) * 100
                st.write(f"**Interview Rate**: {interview_rate:.1f}%")
            
            if metrics.get('interviews', 0) > 0:
                offer_rate = (metrics.get('offers', 0) / metrics.get('interviews', 0)) * 100
                st.write(f"**Offer Rate**: {offer_rate:.1f}%")
    
    elif view_type == "Pipeline":
        st.header("📋 Full Pipeline View")
        funnel_fig, _ = dashboard.create_funnel_chart(metrics)
        if funnel_fig:
            st.plotly_chart(funnel_fig, use_container_width=True)
    
    elif view_type == "Timeline":
        st.header("📅 Job Discovery Timeline")
        timeline_fig = dashboard.create_timeline_chart()
        if timeline_fig:
            st.plotly_chart(timeline_fig, use_container_width=True)
    
    elif view_type == "Sources":
        st.header("📊 Job Sources")
        source_fig = dashboard.create_source_chart()
        if source_fig:
            st.plotly_chart(source_fig, use_container_width=True)
    
    elif view_type == "Reports":
        st.header("📈 Reports")
        
        st.subheader("Daily Summary")
        col1, col2, col3 = st.columns(3)
        with col1:
            st.write(f"**Jobs Today**: {daily.get('jobs_today', 0)}")
        with col2:
            st.write(f"**Applied Today**: {daily.get('applied_today', 0)}")
        with col3:
            st.write(f"**Total in Pipeline**: {metrics.get('discovered', 0)}")
        
        st.markdown("---")
        
        st.subheader("Next Actions")
        st.write("✓ Review high-scoring jobs (>80)")
        st.write("✓ Follow up on pending interviews")
        st.write("✓ Check recruiter responses")
        st.write("✓ Update CRM with new contacts")
    
    # Footer
    st.markdown("---")
    st.markdown("""
    <center style='color: #999; font-size: 12px;'>
    EPIC Job Search Automation System | Last updated: 
    """ + datetime.now().strftime("%Y-%m-%d %H:%M:%S") + """
    </center>
    """, unsafe_allow_html=True)


if __name__ == "__main__":
    main()

