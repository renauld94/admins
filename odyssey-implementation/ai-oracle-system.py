#!/usr/bin/env python3
"""
AI Oracle System for the Learning Odyssey
Integrates with Ollama to provide intelligent learning assistance
"""

import asyncio
import json
import logging
from datetime import datetime
from typing import Dict, List, Optional, Any
from dataclasses import dataclass
from enum import Enum

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class LearningPhase(Enum):
    AWAKENING = "awakening"  # Modules 1-2
    MAPPING = "mapping"      # Module 3: PySpark
    COLLABORATION = "collaboration"  # Module 4: Git/Bitbucket
    CLOUD_CITADEL = "cloud_citadel"  # Module 5: Databricks
    GUARDIAN_RISE = "guardian_rise"  # Module 6: Advanced

@dataclass
class LearnerProfile:
    """Represents a learner's profile and progress"""
    learner_id: str
    current_phase: LearningPhase
    skill_scores: Dict[str, float]
    learning_velocity: float
    preferred_learning_style: str
    engagement_level: float
    last_active: datetime
    achievements: List[str]
    current_challenges: List[str]

@dataclass
class LearningContext:
    """Context for AI Oracle interactions"""
    current_module: str
    current_session: str
    recent_errors: List[str]
    time_spent: float
    questions_asked: int
    concepts_mastered: List[str]
    struggling_areas: List[str]

class AIOracle:
    """
    The AI Oracle - your personal data guide in the learning odyssey
    """
    
    def __init__(self, ollama_client=None):
        self.ollama_client = ollama_client
        self.learner_profiles: Dict[str, LearnerProfile] = {}
        self.narrative_templates = self._load_narrative_templates()
        self.character_voices = self._load_character_voices()
    
    def _load_narrative_templates(self) -> Dict[str, str]:
        """Load narrative templates for different learning phases"""
        return {
            "awakening": {
                "greeting": "Welcome, young data seeker. Your journey into the realm of analytical wisdom begins now.",
                "encouragement": "The path to data mastery is not without challenges, but each step brings you closer to enlightenment.",
                "guidance": "Let the data flow through you, and you will discover patterns hidden to the untrained eye."
            },
            "mapping": {
                "greeting": "Ah, you seek to map the lost pipelines! The data streams await your command.",
                "encouragement": "PySpark is your compass in the vast ocean of big data. Master it, and no dataset shall remain unconquered.",
                "guidance": "Transform raw data into insights, and you will become the architect of information."
            },
            "collaboration": {
                "greeting": "The Code of Collaboration calls to you. Learn to work as one with your fellow data guardians.",
                "encouragement": "Version control is the foundation of great data science. Master Git, and your code will live forever.",
                "guidance": "Share knowledge freely, for in collaboration lies the true power of data science."
            },
            "cloud_citadel": {
                "greeting": "Welcome to the Cloud Citadel, where data ascends to the heavens of scalability.",
                "encouragement": "Databricks is your gateway to infinite computational power. Embrace the cloud, and transcend limitations.",
                "guidance": "In the cloud, your data finds its true potential. Scale beyond imagination."
            },
            "guardian_rise": {
                "greeting": "The time has come for you to rise as a true Data Guardian. Your transformation is nearly complete.",
                "encouragement": "You have journeyed far, young architect. Now, wield your knowledge to protect and serve the realm of data.",
                "guidance": "With great data power comes great responsibility. Use your skills wisely, Guardian."
            }
        }
    
    def _load_character_voices(self) -> Dict[str, str]:
        """Load different character voices for the AI Oracle"""
        return {
            "mentor": "wise and patient",
            "guide": "encouraging and supportive", 
            "challenger": "direct and motivating",
            "celebrator": "enthusiastic and proud"
        }
    
    async def process_question(self, learner_id: str, question: str, context: LearningContext) -> Dict[str, Any]:
        """
        Process a learner's question and provide intelligent response
        """
        try:
            # Get learner profile
            profile = self.learner_profiles.get(learner_id)
            if not profile:
                profile = await self._create_learner_profile(learner_id)
            
            # Determine appropriate voice based on context
            voice = self._select_voice(profile, context)
            
            # Generate AI response
            response = await self._generate_response(profile, question, context, voice)
            
            # Update learner profile based on interaction
            await self._update_learner_profile(profile, question, context)
            
            return {
                "response": response,
                "voice": voice,
                "phase": profile.current_phase.value,
                "suggestions": self._generate_suggestions(profile, context),
                "narrative_element": self._get_narrative_element(profile.current_phase, "guidance")
            }
            
        except Exception as e:
            logger.error(f"Error processing question for learner {learner_id}: {e}")
            return {
                "response": "I apologize, but I encountered an issue processing your question. Please try again.",
                "voice": "mentor",
                "phase": "unknown",
                "suggestions": [],
                "narrative_element": "The Oracle's wisdom flows through the digital realm..."
            }
    
    async def _create_learner_profile(self, learner_id: str) -> LearnerProfile:
        """Create a new learner profile"""
        profile = LearnerProfile(
            learner_id=learner_id,
            current_phase=LearningPhase.AWAKENING,
            skill_scores={},
            learning_velocity=1.0,
            preferred_learning_style="visual",
            engagement_level=0.5,
            last_active=datetime.now(),
            achievements=[],
            current_challenges=[]
        )
        self.learner_profiles[learner_id] = profile
        return profile
    
    def _select_voice(self, profile: LearnerProfile, context: LearningContext) -> str:
        """Select appropriate voice based on learner state"""
        if profile.engagement_level < 0.3:
            return "challenger"
        elif len(profile.achievements) > 5:
            return "celebrator"
        elif context.questions_asked > 10:
            return "guide"
        else:
            return "mentor"
    
    async def _generate_response(self, profile: LearnerProfile, question: str, 
                               context: LearningContext, voice: str) -> str:
        """Generate AI response using Ollama or fallback logic"""
        
        if self.ollama_client:
            # Use Ollama for AI response
            prompt = self._build_ollama_prompt(profile, question, context, voice)
            try:
                response = await self.ollama_client.generate(prompt)
                return response
            except Exception as e:
                logger.warning(f"Ollama generation failed: {e}, using fallback")
        
        # Fallback response generation
        return self._generate_fallback_response(profile, question, context, voice)
    
    def _build_ollama_prompt(self, profile: LearnerProfile, question: str, 
                           context: LearningContext, voice: str) -> str:
        """Build prompt for Ollama AI generation"""
        phase_info = self.narrative_templates[profile.current_phase.value]
        voice_style = self.character_voices[voice]
        
        return f"""
        You are the AI Oracle, a wise and mystical guide in the Learning Odyssey.
        
        Current Learning Phase: {profile.current_phase.value.title()}
        Phase Description: {phase_info['guidance']}
        Voice Style: {voice_style}
        
        Learner Profile:
        - Skill Scores: {profile.skill_scores}
        - Learning Velocity: {profile.learning_velocity}
        - Engagement Level: {profile.engagement_level}
        - Current Module: {context.current_module}
        
        Learner Question: {question}
        
        Context:
        - Time Spent: {context.time_spent} minutes
        - Recent Errors: {context.recent_errors}
        - Concepts Mastered: {context.concepts_mastered}
        
        Respond as the AI Oracle with:
        1. A mystical, encouraging tone appropriate to the learning phase
        2. Direct, helpful technical guidance
        3. A narrative element that fits the odyssey theme
        4. Specific next steps or suggestions
        
        Keep the response concise but inspiring, blending technical accuracy with storytelling.
        """
    
    def _generate_fallback_response(self, profile: LearnerProfile, question: str, 
                                  context: LearningContext, voice: str) -> str:
        """Generate fallback response when Ollama is unavailable"""
        phase_info = self.narrative_templates[profile.current_phase.value]
        
        # Simple keyword-based responses
        if "error" in question.lower() or "problem" in question.lower():
            return f"{phase_info['encouragement']} Every error is a stepping stone to mastery. Let me help you debug this challenge."
        elif "help" in question.lower() or "stuck" in question.lower():
            return f"{phase_info['guidance']} The path forward may seem unclear, but persistence will reveal the way."
        elif "next" in question.lower() or "what" in question.lower():
            return f"{phase_info['guidance']} Your journey continues. Focus on mastering the current concepts before advancing."
        else:
            return f"{phase_info['encouragement']} Your question shows great curiosity. Let me guide you through this learning moment."
    
    def _generate_suggestions(self, profile: LearnerProfile, context: LearningContext) -> List[str]:
        """Generate learning suggestions based on profile and context"""
        suggestions = []
        
        if profile.engagement_level < 0.5:
            suggestions.append("Try the interactive 3D visualization to explore concepts")
            suggestions.append("Join a collaborative challenge with other learners")
        
        if context.struggling_areas:
            suggestions.append(f"Focus on reviewing: {', '.join(context.struggling_areas)}")
        
        if len(profile.achievements) < 3:
            suggestions.append("Complete a hands-on exercise to unlock your first achievement")
        
        return suggestions
    
    def _get_narrative_element(self, phase: LearningPhase, element_type: str) -> str:
        """Get narrative element for current phase"""
        return self.narrative_templates[phase.value].get(element_type, "The journey continues...")
    
    async def _update_learner_profile(self, profile: LearnerProfile, question: str, 
                                    context: LearningContext):
        """Update learner profile based on interaction"""
        profile.last_active = datetime.now()
        profile.engagement_level = min(1.0, profile.engagement_level + 0.1)
        
        # Update based on question complexity
        if len(question) > 100:
            profile.learning_velocity += 0.05
        
        # Add achievements based on context
        if context.concepts_mastered and len(context.concepts_mastered) > len(profile.achievements):
            new_achievements = set(context.concepts_mastered) - set(profile.achievements)
            profile.achievements.extend(list(new_achievements))
    
    async def get_learner_progress(self, learner_id: str) -> Dict[str, Any]:
        """Get comprehensive learner progress report"""
        profile = self.learner_profiles.get(learner_id)
        if not profile:
            return {"error": "Learner not found"}
        
        return {
            "learner_id": learner_id,
            "current_phase": profile.current_phase.value,
            "skill_scores": profile.skill_scores,
            "learning_velocity": profile.learning_velocity,
            "engagement_level": profile.engagement_level,
            "achievements": profile.achievements,
            "narrative_status": self._get_narrative_element(profile.current_phase, "greeting"),
            "next_milestone": self._get_next_milestone(profile)
        }
    
    def _get_next_milestone(self, profile: LearnerProfile) -> str:
        """Get next learning milestone for the learner"""
        milestones = {
            LearningPhase.AWAKENING: "Master Python fundamentals to unlock the Map of Lost Pipelines",
            LearningPhase.MAPPING: "Conquer PySpark to access the Code of Collaboration",
            LearningPhase.COLLABORATION: "Master Git to enter the Cloud Citadel",
            LearningPhase.CLOUD_CITADEL: "Ascend to the final phase: The Rise of the Data Guardian",
            LearningPhase.GUARDIAN_RISE: "Complete your transformation into a true Data Guardian"
        }
        return milestones.get(profile.current_phase, "Continue your journey of discovery")

# Example usage and testing
async def main():
    """Example usage of the AI Oracle system"""
    oracle = AIOracle()
    
    # Simulate a learner interaction
    learner_id = "learner_001"
    question = "I'm having trouble understanding DataFrame operations in PySpark"
    
    context = LearningContext(
        current_module="Module 3: PySpark",
        current_session="Session 3.06: DataFrame Operations",
        recent_errors=["TypeError: 'NoneType' object has no attribute 'select'"],
        time_spent=45.0,
        questions_asked=3,
        concepts_mastered=["RDD basics", "DataFrame creation"],
        struggling_areas=["DataFrame operations", "SQL queries"]
    )
    
    response = await oracle.process_question(learner_id, question, context)
    print("AI Oracle Response:")
    print(json.dumps(response, indent=2))
    
    # Get learner progress
    progress = await oracle.get_learner_progress(learner_id)
    print("\nLearner Progress:")
    print(json.dumps(progress, indent=2))

if __name__ == "__main__":
    asyncio.run(main())

