#!/usr/bin/env python3
"""
Databricks Analytics for Learning Odyssey
Real-time metrics and impact evaluation system
"""

import json
import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any, Tuple
from dataclasses import dataclass, asdict
from enum import Enum
import pandas as pd
import numpy as np

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class LearningEventType(Enum):
    MODULE_START = "module_start"
    MODULE_COMPLETE = "module_complete"
    SESSION_START = "session_start"
    SESSION_COMPLETE = "session_complete"
    QUESTION_ASKED = "question_asked"
    AI_INTERACTION = "ai_interaction"
    ACHIEVEMENT_UNLOCKED = "achievement_unlocked"
    COLLABORATION = "collaboration"
    ERROR_ENCOUNTERED = "error_encountered"
    TIME_SPENT = "time_spent"

@dataclass
class LearningEvent:
    """Represents a learning event in the system"""
    event_id: str
    learner_id: str
    event_type: LearningEventType
    module_id: Optional[str]
    session_id: Optional[str]
    timestamp: datetime
    metadata: Dict[str, Any]
    impact_score: float = 0.0

@dataclass
class LearnerMetrics:
    """Comprehensive learner metrics"""
    learner_id: str
    total_time_spent: float
    modules_completed: int
    sessions_completed: int
    questions_asked: int
    ai_interactions: int
    achievements_unlocked: int
    collaboration_score: float
    engagement_level: float
    skill_scores: Dict[str, float]
    learning_velocity: float
    last_active: datetime
    error_rate: float
    sentiment_score: float

@dataclass
class ModuleImpact:
    """Impact metrics for a specific module"""
    module_id: str
    module_name: str
    completion_rate: float
    average_time: float
    difficulty_score: float
    engagement_score: float
    skill_improvement: Dict[str, float]
    error_frequency: float
    ai_help_requests: int
    collaboration_events: int
    impact_index: float

class DatabricksLearningAnalytics:
    """
    Main analytics engine for the Learning Odyssey
    Integrates with Databricks for real-time learning analytics
    """
    
    def __init__(self, databricks_client=None):
        self.databricks_client = databricks_client
        self.learning_events: List[LearningEvent] = []
        self.learner_metrics: Dict[str, LearnerMetrics] = {}
        self.module_impacts: Dict[str, ModuleImpact] = {}
        self.community_metrics = {}
        
        # Analytics configuration
        self.impact_weights = {
            'completion_rate': 0.3,
            'engagement': 0.25,
            'skill_improvement': 0.25,
            'collaboration': 0.1,
            'error_reduction': 0.1
        }
        
        self.skill_categories = {
            'python': ['python_basics', 'data_structures', 'functions', 'classes'],
            'pyspark': ['rdd_operations', 'dataframes', 'sql', 'performance'],
            'git': ['version_control', 'branching', 'merging', 'collaboration'],
            'databricks': ['notebooks', 'clusters', 'jobs', 'libraries'],
            'data_analysis': ['statistics', 'visualization', 'machine_learning', 'reporting']
        }
    
    def log_learning_event(self, event: LearningEvent) -> bool:
        """Log a learning event to the analytics system"""
        try:
            self.learning_events.append(event)
            
            # Update real-time metrics
            self._update_learner_metrics(event)
            self._update_module_impact(event)
            
            # Send to Databricks if available
            if self.databricks_client:
                self._send_to_databricks(event)
            
            logger.info(f"Logged event: {event.event_type.value} for learner {event.learner_id}")
            return True
            
        except Exception as e:
            logger.error(f"Error logging event: {e}")
            return False
    
    def _update_learner_metrics(self, event: LearningEvent):
        """Update learner metrics based on new event"""
        learner_id = event.learner_id
        
        if learner_id not in self.learner_metrics:
            self.learner_metrics[learner_id] = LearnerMetrics(
                learner_id=learner_id,
                total_time_spent=0.0,
                modules_completed=0,
                sessions_completed=0,
                questions_asked=0,
                ai_interactions=0,
                achievements_unlocked=0,
                collaboration_score=0.0,
                engagement_level=0.5,
                skill_scores={},
                learning_velocity=1.0,
                last_active=event.timestamp,
                error_rate=0.0,
                sentiment_score=0.5
            )
        
        metrics = self.learner_metrics[learner_id]
        
        # Update based on event type
        if event.event_type == LearningEventType.MODULE_COMPLETE:
            metrics.modules_completed += 1
            metrics.engagement_level = min(1.0, metrics.engagement_level + 0.1)
            
        elif event.event_type == LearningEventType.SESSION_COMPLETE:
            metrics.sessions_completed += 1
            
        elif event.event_type == LearningEventType.QUESTION_ASKED:
            metrics.questions_asked += 1
            metrics.engagement_level = min(1.0, metrics.engagement_level + 0.05)
            
        elif event.event_type == LearningEventType.AI_INTERACTION:
            metrics.ai_interactions += 1
            
        elif event.event_type == LearningEventType.ACHIEVEMENT_UNLOCKED:
            metrics.achievements_unlocked += 1
            metrics.engagement_level = min(1.0, metrics.engagement_level + 0.15)
            
        elif event.event_type == LearningEventType.COLLABORATION:
            metrics.collaboration_score = min(1.0, metrics.collaboration_score + 0.1)
            
        elif event.event_type == LearningEventType.ERROR_ENCOUNTERED:
            metrics.error_rate = min(1.0, metrics.error_rate + 0.05)
            
        elif event.event_type == LearningEventType.TIME_SPENT:
            time_spent = event.metadata.get('duration_minutes', 0)
            metrics.total_time_spent += time_spent
            
            # Update learning velocity based on time efficiency
            if time_spent > 0:
                expected_time = event.metadata.get('expected_duration_minutes', 60)
                efficiency = expected_time / time_spent
                metrics.learning_velocity = (metrics.learning_velocity + efficiency) / 2
        
        # Update skill scores if provided
        if 'skill_improvements' in event.metadata:
            for skill, improvement in event.metadata['skill_improvements'].items():
                current_score = metrics.skill_scores.get(skill, 0.0)
                metrics.skill_scores[skill] = min(1.0, current_score + improvement)
        
        # Update last active
        metrics.last_active = event.timestamp
        
        # Calculate sentiment score based on recent events
        metrics.sentiment_score = self._calculate_sentiment_score(learner_id)
    
    def _update_module_impact(self, event: LearningEvent):
        """Update module impact metrics based on new event"""
        if not event.module_id:
            return
        
        module_id = event.module_id
        
        if module_id not in self.module_impacts:
            self.module_impacts[module_id] = ModuleImpact(
                module_id=module_id,
                module_name=event.metadata.get('module_name', module_id),
                completion_rate=0.0,
                average_time=0.0,
                difficulty_score=0.5,
                engagement_score=0.5,
                skill_improvement={},
                error_frequency=0.0,
                ai_help_requests=0,
                collaboration_events=0,
                impact_index=0.0
            )
        
        impact = self.module_impacts[module_id]
        
        # Update based on event type
        if event.event_type == LearningEventType.MODULE_COMPLETE:
            # Update completion rate
            total_attempts = len([e for e in self.learning_events 
                                if e.module_id == module_id and e.event_type == LearningEventType.MODULE_START])
            if total_attempts > 0:
                completions = len([e for e in self.learning_events 
                                 if e.module_id == module_id and e.event_type == LearningEventType.MODULE_COMPLETE])
                impact.completion_rate = completions / total_attempts
        
        elif event.event_type == LearningEventType.TIME_SPENT:
            # Update average time
            module_events = [e for e in self.learning_events 
                           if e.module_id == module_id and e.event_type == LearningEventType.TIME_SPENT]
            if module_events:
                total_time = sum(e.metadata.get('duration_minutes', 0) for e in module_events)
                impact.average_time = total_time / len(module_events)
        
        elif event.event_type == LearningEventType.QUESTION_ASKED:
            impact.ai_help_requests += 1
        
        elif event.event_type == LearningEventType.COLLABORATION:
            impact.collaboration_events += 1
        
        elif event.event_type == LearningEventType.ERROR_ENCOUNTERED:
            # Update error frequency
            module_events = [e for e in self.learning_events 
                           if e.module_id == module_id]
            if module_events:
                error_events = len([e for e in module_events 
                                  if e.event_type == LearningEventType.ERROR_ENCOUNTERED])
                impact.error_frequency = error_events / len(module_events)
        
        # Recalculate impact index
        impact.impact_index = self._calculate_impact_index(impact)
    
    def _calculate_sentiment_score(self, learner_id: str) -> float:
        """Calculate sentiment score based on recent events"""
        recent_events = [e for e in self.learning_events 
                        if e.learner_id == learner_id 
                        and e.timestamp > datetime.now() - timedelta(days=7)]
        
        if not recent_events:
            return 0.5
        
        positive_events = len([e for e in recent_events 
                             if e.event_type in [LearningEventType.MODULE_COMPLETE, 
                                               LearningEventType.ACHIEVEMENT_UNLOCKED,
                                               LearningEventType.COLLABORATION]])
        
        negative_events = len([e for e in recent_events 
                             if e.event_type == LearningEventType.ERROR_ENCOUNTERED])
        
        total_events = len(recent_events)
        if total_events == 0:
            return 0.5
        
        sentiment = (positive_events - negative_events) / total_events
        return max(0.0, min(1.0, (sentiment + 1) / 2))
    
    def _calculate_impact_index(self, impact: ModuleImpact) -> float:
        """Calculate overall impact index for a module"""
        score = 0.0
        
        # Completion rate contribution
        score += impact.completion_rate * self.impact_weights['completion_rate']
        
        # Engagement score contribution
        score += impact.engagement_score * self.impact_weights['engagement']
        
        # Skill improvement contribution
        if impact.skill_improvement:
            avg_skill_improvement = np.mean(list(impact.skill_improvement.values()))
            score += avg_skill_improvement * self.impact_weights['skill_improvement']
        
        # Collaboration contribution
        score += min(1.0, impact.collaboration_events / 10) * self.impact_weights['collaboration']
        
        # Error reduction contribution (inverse of error frequency)
        score += (1.0 - impact.error_frequency) * self.impact_weights['error_reduction']
        
        return min(1.0, score)
    
    def _send_to_databricks(self, event: LearningEvent):
        """Send event data to Databricks for storage and analysis"""
        try:
            # Convert event to DataFrame
            event_data = {
                'event_id': event.event_id,
                'learner_id': event.learner_id,
                'event_type': event.event_type.value,
                'module_id': event.module_id,
                'session_id': event.session_id,
                'timestamp': event.timestamp.isoformat(),
                'metadata': json.dumps(event.metadata),
                'impact_score': event.impact_score
            }
            
            df = pd.DataFrame([event_data])
            
            # Write to Databricks table
            # This would be implemented based on your Databricks setup
            # df.write.mode("append").saveAsTable("learning_events")
            
            logger.info(f"Sent event {event.event_id} to Databricks")
            
        except Exception as e:
            logger.error(f"Error sending to Databricks: {e}")
    
    def get_learner_analytics(self, learner_id: str) -> Dict[str, Any]:
        """Get comprehensive analytics for a specific learner"""
        if learner_id not in self.learner_metrics:
            return {"error": "Learner not found"}
        
        metrics = self.learner_metrics[learner_id]
        
        # Get recent activity
        recent_events = [e for e in self.learning_events 
                        if e.learner_id == learner_id 
                        and e.timestamp > datetime.now() - timedelta(days=30)]
        
        # Calculate learning patterns
        learning_patterns = self._analyze_learning_patterns(learner_id)
        
        # Get skill progression
        skill_progression = self._get_skill_progression(learner_id)
        
        return {
            "learner_id": learner_id,
            "metrics": asdict(metrics),
            "recent_activity": [asdict(e) for e in recent_events[-10:]],
            "learning_patterns": learning_patterns,
            "skill_progression": skill_progression,
            "recommendations": self._generate_recommendations(learner_id)
        }
    
    def get_module_analytics(self, module_id: str) -> Dict[str, Any]:
        """Get comprehensive analytics for a specific module"""
        if module_id not in self.module_impacts:
            return {"error": "Module not found"}
        
        impact = self.module_impacts[module_id]
        
        # Get learner performance data
        module_events = [e for e in self.learning_events if e.module_id == module_id]
        learner_performance = self._analyze_learner_performance(module_id)
        
        return {
            "module_id": module_id,
            "impact": asdict(impact),
            "learner_performance": learner_performance,
            "trends": self._analyze_module_trends(module_id),
            "recommendations": self._generate_module_recommendations(module_id)
        }
    
    def get_community_analytics(self) -> Dict[str, Any]:
        """Get community-wide analytics"""
        total_learners = len(self.learner_metrics)
        total_events = len(self.learning_events)
        
        # Calculate community metrics
        avg_engagement = np.mean([m.engagement_level for m in self.learner_metrics.values()])
        avg_completion_rate = np.mean([m.modules_completed / 6 for m in self.learner_metrics.values()])
        avg_collaboration = np.mean([m.collaboration_score for m in self.learner_metrics.values()])
        
        # Get top performing modules
        module_rankings = sorted(self.module_impacts.items(), 
                               key=lambda x: x[1].impact_index, 
                               reverse=True)
        
        # Get learning trends
        trends = self._analyze_community_trends()
        
        return {
            "total_learners": total_learners,
            "total_events": total_events,
            "average_engagement": avg_engagement,
            "average_completion_rate": avg_completion_rate,
            "average_collaboration": avg_collaboration,
            "module_rankings": [(mid, impact.impact_index) for mid, impact in module_rankings],
            "trends": trends,
            "insights": self._generate_community_insights()
        }
    
    def _analyze_learning_patterns(self, learner_id: str) -> Dict[str, Any]:
        """Analyze learning patterns for a specific learner"""
        learner_events = [e for e in self.learning_events if e.learner_id == learner_id]
        
        if not learner_events:
            return {}
        
        # Analyze time patterns
        time_events = [e for e in learner_events if e.event_type == LearningEventType.TIME_SPENT]
        if time_events:
            hours = [e.timestamp.hour for e in time_events]
            peak_hour = max(set(hours), key=hours.count)
        else:
            peak_hour = None
        
        # Analyze session length patterns
        session_lengths = [e.metadata.get('duration_minutes', 0) for e in time_events]
        avg_session_length = np.mean(session_lengths) if session_lengths else 0
        
        # Analyze error patterns
        error_events = [e for e in learner_events if e.event_type == LearningEventType.ERROR_ENCOUNTERED]
        error_rate = len(error_events) / len(learner_events) if learner_events else 0
        
        return {
            "peak_learning_hour": peak_hour,
            "average_session_length": avg_session_length,
            "error_rate": error_rate,
            "learning_consistency": self._calculate_consistency(learner_events)
        }
    
    def _get_skill_progression(self, learner_id: str) -> Dict[str, List[float]]:
        """Get skill progression over time for a learner"""
        learner_events = [e for e in self.learning_events if e.learner_id == learner_id]
        
        # Group events by week
        weekly_skills = {}
        for event in learner_events:
            if 'skill_improvements' in event.metadata:
                week = event.timestamp.isocalendar()[1]
                if week not in weekly_skills:
                    weekly_skills[week] = {}
                
                for skill, improvement in event.metadata['skill_improvements'].items():
                    if skill not in weekly_skills[week]:
                        weekly_skills[week][skill] = 0.0
                    weekly_skills[week][skill] += improvement
        
        return weekly_skills
    
    def _analyze_learner_performance(self, module_id: str) -> Dict[str, Any]:
        """Analyze how learners perform on a specific module"""
        module_events = [e for e in self.learning_events if e.module_id == module_id]
        
        if not module_events:
            return {}
        
        # Get unique learners for this module
        learners = list(set(e.learner_id for e in module_events))
        
        # Calculate performance metrics
        completion_times = []
        error_rates = []
        
        for learner_id in learners:
            learner_events = [e for e in module_events if e.learner_id == learner_id]
            
            # Calculate completion time
            start_events = [e for e in learner_events if e.event_type == LearningEventType.MODULE_START]
            complete_events = [e for e in learner_events if e.event_type == LearningEventType.MODULE_COMPLETE]
            
            if start_events and complete_events:
                start_time = min(e.timestamp for e in start_events)
                complete_time = max(e.timestamp for e in complete_events)
                completion_times.append((complete_time - start_time).total_seconds() / 3600)  # hours
            
            # Calculate error rate
            error_events = len([e for e in learner_events if e.event_type == LearningEventType.ERROR_ENCOUNTERED])
            error_rates.append(error_events / len(learner_events) if learner_events else 0)
        
        return {
            "total_learners": len(learners),
            "average_completion_time": np.mean(completion_times) if completion_times else 0,
            "completion_time_std": np.std(completion_times) if completion_times else 0,
            "average_error_rate": np.mean(error_rates) if error_rates else 0,
            "error_rate_std": np.std(error_rates) if error_rates else 0
        }
    
    def _analyze_module_trends(self, module_id: str) -> Dict[str, Any]:
        """Analyze trends for a specific module over time"""
        module_events = [e for e in self.learning_events if e.module_id == module_id]
        
        if not module_events:
            return {}
        
        # Group events by week
        weekly_data = {}
        for event in module_events:
            week = event.timestamp.isocalendar()[1]
            if week not in weekly_data:
                weekly_data[week] = {
                    'completions': 0,
                    'errors': 0,
                    'ai_requests': 0,
                    'total_events': 0
                }
            
            weekly_data[week]['total_events'] += 1
            
            if event.event_type == LearningEventType.MODULE_COMPLETE:
                weekly_data[week]['completions'] += 1
            elif event.event_type == LearningEventType.ERROR_ENCOUNTERED:
                weekly_data[week]['errors'] += 1
            elif event.event_type == LearningEventType.QUESTION_ASKED:
                weekly_data[week]['ai_requests'] += 1
        
        return weekly_data
    
    def _analyze_community_trends(self) -> Dict[str, Any]:
        """Analyze community-wide trends"""
        # Group events by week
        weekly_data = {}
        for event in self.learning_events:
            week = event.timestamp.isocalendar()[1]
            if week not in weekly_data:
                weekly_data[week] = {
                    'total_events': 0,
                    'unique_learners': set(),
                    'completions': 0,
                    'collaborations': 0
                }
            
            weekly_data[week]['total_events'] += 1
            weekly_data[week]['unique_learners'].add(event.learner_id)
            
            if event.event_type == LearningEventType.MODULE_COMPLETE:
                weekly_data[week]['completions'] += 1
            elif event.event_type == LearningEventType.COLLABORATION:
                weekly_data[week]['collaborations'] += 1
        
        # Convert sets to counts
        for week_data in weekly_data.values():
            week_data['unique_learners'] = len(week_data['unique_learners'])
        
        return weekly_data
    
    def _calculate_consistency(self, events: List[LearningEvent]) -> float:
        """Calculate learning consistency score"""
        if len(events) < 2:
            return 0.0
        
        # Calculate intervals between events
        timestamps = sorted([e.timestamp for e in events])
        intervals = [(timestamps[i+1] - timestamps[i]).total_seconds() / 3600 
                    for i in range(len(timestamps)-1)]
        
        if not intervals:
            return 0.0
        
        # Calculate coefficient of variation (lower is more consistent)
        mean_interval = np.mean(intervals)
        std_interval = np.std(intervals)
        
        if mean_interval == 0:
            return 0.0
        
        cv = std_interval / mean_interval
        consistency = max(0.0, 1.0 - cv)  # Convert to 0-1 scale where 1 is most consistent
        
        return consistency
    
    def _generate_recommendations(self, learner_id: str) -> List[str]:
        """Generate personalized recommendations for a learner"""
        if learner_id not in self.learner_metrics:
            return []
        
        metrics = self.learner_metrics[learner_id]
        recommendations = []
        
        # Engagement recommendations
        if metrics.engagement_level < 0.5:
            recommendations.append("Try the interactive 3D learning environment to boost engagement")
        
        # Collaboration recommendations
        if metrics.collaboration_score < 0.3:
            recommendations.append("Join a collaborative challenge to improve teamwork skills")
        
        # Error rate recommendations
        if metrics.error_rate > 0.3:
            recommendations.append("Focus on reviewing error patterns and seeking help from the AI Oracle")
        
        # Skill gap recommendations
        for skill, score in metrics.skill_scores.items():
            if score < 0.5:
                recommendations.append(f"Focus on improving {skill} skills through targeted practice")
        
        # Learning velocity recommendations
        if metrics.learning_velocity < 0.8:
            recommendations.append("Consider breaking down complex topics into smaller sessions")
        
        return recommendations
    
    def _generate_module_recommendations(self, module_id: str) -> List[str]:
        """Generate recommendations for improving a module"""
        if module_id not in self.module_impacts:
            return []
        
        impact = self.module_impacts[module_id]
        recommendations = []
        
        # Completion rate recommendations
        if impact.completion_rate < 0.7:
            recommendations.append("Consider reducing module complexity or adding more support materials")
        
        # Error frequency recommendations
        if impact.error_frequency > 0.2:
            recommendations.append("Add more error handling examples and debugging guidance")
        
        # AI help requests recommendations
        if impact.ai_help_requests > 10:
            recommendations.append("Consider adding more detailed explanations and examples")
        
        # Collaboration recommendations
        if impact.collaboration_events < 5:
            recommendations.append("Add more collaborative exercises and group activities")
        
        return recommendations
    
    def _generate_community_insights(self) -> List[str]:
        """Generate insights about the learning community"""
        insights = []
        
        # Engagement insights
        avg_engagement = np.mean([m.engagement_level for m in self.learner_metrics.values()])
        if avg_engagement > 0.8:
            insights.append("Community shows high engagement levels - excellent learning culture")
        elif avg_engagement < 0.5:
            insights.append("Community engagement could be improved - consider gamification elements")
        
        # Collaboration insights
        avg_collaboration = np.mean([m.collaboration_score for m in self.learner_metrics.values()])
        if avg_collaboration > 0.7:
            insights.append("Strong collaborative learning culture observed")
        elif avg_collaboration < 0.3:
            insights.append("Opportunity to increase peer learning and collaboration")
        
        # Module performance insights
        if self.module_impacts:
            best_module = max(self.module_impacts.items(), key=lambda x: x[1].impact_index)
            worst_module = min(self.module_impacts.items(), key=lambda x: x[1].impact_index)
            
            insights.append(f"Highest performing module: {best_module[1].module_name}")
            insights.append(f"Module needing attention: {worst_module[1].module_name}")
        
        return insights

# Example usage and testing
def main():
    """Example usage of the Databricks Learning Analytics system"""
    analytics = DatabricksLearningAnalytics()
    
    # Simulate some learning events
    events = [
        LearningEvent(
            event_id="evt_001",
            learner_id="learner_001",
            event_type=LearningEventType.MODULE_START,
            module_id="module_1",
            session_id="session_1_01",
            timestamp=datetime.now() - timedelta(hours=2),
            metadata={"module_name": "System Setup & Introduction"}
        ),
        LearningEvent(
            event_id="evt_002",
            learner_id="learner_001",
            event_type=LearningEventType.TIME_SPENT,
            module_id="module_1",
            session_id="session_1_01",
            timestamp=datetime.now() - timedelta(hours=1),
            metadata={"duration_minutes": 45, "expected_duration_minutes": 60}
        ),
        LearningEvent(
            event_id="evt_003",
            learner_id="learner_001",
            event_type=LearningEventType.QUESTION_ASKED,
            module_id="module_1",
            session_id="session_1_01",
            timestamp=datetime.now() - timedelta(minutes=30),
            metadata={"question": "How do I install Python on Windows?"}
        ),
        LearningEvent(
            event_id="evt_004",
            learner_id="learner_001",
            event_type=LearningEventType.MODULE_COMPLETE,
            module_id="module_1",
            session_id="session_1_01",
            timestamp=datetime.now(),
            metadata={"module_name": "System Setup & Introduction", "final_score": 0.85}
        )
    ]
    
    # Log events
    for event in events:
        analytics.log_learning_event(event)
    
    # Get analytics
    learner_analytics = analytics.get_learner_analytics("learner_001")
    print("Learner Analytics:")
    print(json.dumps(learner_analytics, indent=2, default=str))
    
    module_analytics = analytics.get_module_analytics("module_1")
    print("\nModule Analytics:")
    print(json.dumps(module_analytics, indent=2, default=str))
    
    community_analytics = analytics.get_community_analytics()
    print("\nCommunity Analytics:")
    print(json.dumps(community_analytics, indent=2, default=str))

if __name__ == "__main__":
    main()


