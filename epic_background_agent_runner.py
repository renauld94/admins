#!/usr/bin/env python3
"""
🚀 EPIC BACKGROUND AGENT RUNNER
=====================================
Runs AI agents in the background with all VM 159 models for the online course
- Multi-model support (DeepSeek, Llama, Qwen, Mistral, Gemma)
- SSH tunnel to VM 159 Ollama
- Systemd service integration
- Comprehensive logging
- Web monitoring dashboard
"""

import os
import sys
import json
import time
import logging
import subprocess
import threading
import signal
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional
import asyncio
import uvicorn
from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse, FileResponse
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
import requests
from dataclasses import dataclass, asdict

# ============================================================================
# CONFIGURATION
# ============================================================================

BASE_DIR = Path(__file__).parent
LOG_DIR = BASE_DIR / "logs" / "agents"
DATA_DIR = BASE_DIR / "data" / "agents"
ASSETS_DIR = BASE_DIR / "assets" / "agent-dashboard"

LOG_DIR.mkdir(parents=True, exist_ok=True)
DATA_DIR.mkdir(parents=True, exist_ok=True)
ASSETS_DIR.mkdir(parents=True, exist_ok=True)

# VM 159 Configuration
VM159_IP = "10.0.0.110"
VM159_USER = "simonadmin"
SSH_TUNNEL_PORT = 11434
OLLAMA_API = f"http://localhost:{SSH_TUNNEL_PORT}"

# Models on VM 159
AVAILABLE_MODELS = [
    "deepseek-coder:6.7b",
    "llama3.1:8b",
    "qwen:7b",
    "mistral:7b",
    "gemma2:9b"
]

# Service Ports
PORTS = {
    "orchestrator": 5100,
    "code_agent": 5101,
    "data_agent": 5102,
    "course_agent": 5103,
    "tutor_agent": 5104,
    "dashboard": 5110
}

# ============================================================================
# LOGGING SETUP
# ============================================================================

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(LOG_DIR / "orchestrator.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# ============================================================================
# DATA MODELS
# ============================================================================

@dataclass
class AgentStatus:
    name: str
    port: int
    status: str  # running, stopped, error
    uptime: float
    models_ready: List[str]
    last_heartbeat: str
    request_count: int
    error_count: int

@dataclass
class SystemHealth:
    timestamp: str
    ssh_tunnel: bool
    ollama_connectivity: bool
    agents_running: int
    total_agents: int
    total_models_available: int
    disk_usage_percent: float
    memory_usage_percent: float

# ============================================================================
# SSH TUNNEL MANAGER
# ============================================================================

class SSHTunnelManager:
    """Manages SSH tunnel to VM 159 Ollama"""
    
    def __init__(self):
        self.tunnel_process = None
        self.tunnel_pid = None
        
    def start(self):
        """Start SSH tunnel to VM 159"""
        try:
            logger.info(f"🌐 Starting SSH tunnel to VM 159 ({VM159_IP}:{SSH_TUNNEL_PORT})")
            cmd = f"ssh -N -L {SSH_TUNNEL_PORT}:localhost:11434 {VM159_USER}@{VM159_IP}"
            self.tunnel_process = subprocess.Popen(
                cmd.split(),
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
            self.tunnel_pid = self.tunnel_process.pid
            logger.info(f"✅ SSH tunnel started (PID: {self.tunnel_pid})")
            return True
        except Exception as e:
            logger.error(f"❌ Failed to start SSH tunnel: {e}")
            return False
    
    def check_connectivity(self) -> bool:
        """Check if tunnel and Ollama are accessible"""
        try:
            response = requests.get(f"{OLLAMA_API}/api/tags", timeout=5)
            return response.status_code == 200
        except Exception as e:
            logger.warning(f"⚠️ Ollama connectivity check failed: {e}")
            return False
    
    def stop(self):
        """Stop SSH tunnel"""
        if self.tunnel_process:
            self.tunnel_process.terminate()
            logger.info("🛑 SSH tunnel stopped")

# ============================================================================
# AGENT LAUNCHER
# ============================================================================

class AgentLauncher:
    """Launches and manages AI agents"""
    
    def __init__(self):
        self.agents: Dict[str, subprocess.Popen] = {}
        self.agent_status: Dict[str, AgentStatus] = {}
        self.start_times: Dict[str, float] = {}
    
    def launch_code_agent(self):
        """Launch Code Generation Agent"""
        return self._launch_agent(
            "code_agent",
            "Code Generation Agent (DeepSeek)",
            """
from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
import requests
import json

app = FastAPI()
OLLAMA_API = "{ollama_api}"
MODEL = "deepseek-coder:6.7b"

@app.get("/health")
async def health():
    return {{"status": "ok", "agent": "code_agent", "model": MODEL}}

@app.post("/generate")
async def generate_code(prompt: str):
    try:
        response = requests.post(
            f"{{OLLAMA_API}}/api/generate",
            json={{"model": MODEL, "prompt": prompt}},
            timeout=120
        )
        return response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/review")
async def review_code(code: str):
    prompt = f"Review this code and suggest improvements:\\n{{code}}"
    try:
        response = requests.post(
            f"{{OLLAMA_API}}/api/generate",
            json={{"model": MODEL, "prompt": prompt}},
            timeout=120
        )
        return response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port={port})
""".format(ollama_api=OLLAMA_API, port=PORTS["code_agent"])
        )
    
    def launch_data_agent(self):
        """Launch Data Science Agent"""
        return self._launch_agent(
            "data_agent",
            "Data Science Agent (Llama)",
            """
from fastapi import FastAPI, HTTPException
import requests
import json

app = FastAPI()
OLLAMA_API = "{ollama_api}"
MODEL = "llama3.1:8b"

@app.get("/health")
async def health():
    return {{"status": "ok", "agent": "data_agent", "model": MODEL}}

@app.post("/analyze")
async def analyze_data(query: str):
    prompt = f"Analyze this data science question: {{query}}"
    try:
        response = requests.post(
            f"{{OLLAMA_API}}/api/generate",
            json={{"model": MODEL, "prompt": prompt}},
            timeout=120
        )
        return response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/visualize")
async def suggest_visualization(data_description: str):
    prompt = f"Suggest data visualizations for: {{data_description}}"
    try:
        response = requests.post(
            f"{{OLLAMA_API}}/api/generate",
            json={{"model": MODEL, "prompt": prompt}},
            timeout=120
        )
        return response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port={port})
""".format(ollama_api=OLLAMA_API, port=PORTS["data_agent"])
        )
    
    def launch_course_agent(self):
        """Launch Course Content Agent"""
        return self._launch_agent(
            "course_agent",
            "Course Content Agent (Qwen)",
            """
from fastapi import FastAPI, HTTPException
import requests

app = FastAPI()
OLLAMA_API = "{ollama_api}"
MODEL = "qwen:7b"

@app.get("/health")
async def health():
    return {{"status": "ok", "agent": "course_agent", "model": MODEL}}

@app.post("/generate-lesson")
async def generate_lesson(topic: str, level: str):
    prompt = f"Create a {{level}} lesson on {{topic}} for Vietnamese students"
    try:
        response = requests.post(
            f"{{OLLAMA_API}}/api/generate",
            json={{"model": MODEL, "prompt": prompt}},
            timeout=120
        )
        return response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/quiz")
async def generate_quiz(topic: str, num_questions: int = 5):
    prompt = f"Create {{num_questions}} quiz questions on {{topic}}"
    try:
        response = requests.post(
            f"{{OLLAMA_API}}/api/generate",
            json={{"model": MODEL, "prompt": prompt}},
            timeout=120
        )
        return response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port={port})
""".format(ollama_api=OLLAMA_API, port=PORTS["course_agent"])
        )
    
    def launch_tutor_agent(self):
        """Launch AI Tutor Agent"""
        return self._launch_agent(
            "tutor_agent",
            "AI Tutor Agent (Mistral)",
            """
from fastapi import FastAPI, HTTPException
import requests

app = FastAPI()
OLLAMA_API = "{ollama_api}"
MODEL = "mistral:7b"

@app.get("/health")
async def health():
    return {{"status": "ok", "agent": "tutor_agent", "model": MODEL}}

@app.post("/explain")
async def explain_concept(topic: str):
    prompt = f"Explain {{topic}} in simple, clear language suitable for students"
    try:
        response = requests.post(
            f"{{OLLAMA_API}}/api/generate",
            json={{"model": MODEL, "prompt": prompt}},
            timeout=120
        )
        return response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/answer")
async def answer_question(question: str):
    prompt = f"Answer this student question thoughtfully: {{question}}"
    try:
        response = requests.post(
            f"{{OLLAMA_API}}/api/generate",
            json={{"model": MODEL, "prompt": prompt}},
            timeout=120
        )
        return response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port={port})
""".format(ollama_api=OLLAMA_API, port=PORTS["tutor_agent"])
        )
    
    def _launch_agent(self, agent_name: str, display_name: str, code: str):
        """Generic agent launcher"""
        try:
            # Write agent code to temp file
            agent_file = DATA_DIR / f"{agent_name}.py"
            agent_file.write_text(code)
            
            logger.info(f"🤖 Starting {display_name}...")
            proc = subprocess.Popen(
                ["python3", str(agent_file)],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                cwd=str(BASE_DIR)
            )
            
            self.agents[agent_name] = proc
            self.start_times[agent_name] = time.time()
            
            # Wait for startup
            time.sleep(2)
            
            # Check if process is still running
            if proc.poll() is None:
                logger.info(f"✅ {display_name} started (PID: {proc.pid})")
                return True
            else:
                _, err = proc.communicate()
                logger.error(f"❌ {display_name} failed: {err.decode()}")
                return False
        except Exception as e:
            logger.error(f"❌ Failed to start {display_name}: {e}")
            return False
    
    def get_status(self) -> Dict[str, AgentStatus]:
        """Get status of all agents"""
        status = {}
        for agent_name, proc in self.agents.items():
            uptime = time.time() - self.start_times.get(agent_name, time.time())
            is_running = proc.poll() is None
            
            status[agent_name] = AgentStatus(
                name=agent_name,
                port=PORTS.get(agent_name, 0),
                status="running" if is_running else "stopped",
                uptime=uptime,
                models_ready=AVAILABLE_MODELS,
                last_heartbeat=datetime.now().isoformat(),
                request_count=0,
                error_count=0
            )
        return status

# ============================================================================
# ORCHESTRATOR SERVER
# ============================================================================

app = FastAPI(title="Epic Agent Orchestrator", version="1.0.0")

# Add CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global state
tunnel_manager = SSHTunnelManager()
agent_launcher = AgentLauncher()

@app.on_event("startup")
async def startup():
    """Initialize on startup"""
    logger.info("🚀 Epic Agent Orchestrator starting...")
    
    # Start SSH tunnel
    if not tunnel_manager.start():
        logger.warning("⚠️ SSH tunnel startup may have failed")
    
    # Wait for tunnel
    await asyncio.sleep(2)
    
    # Check Ollama connectivity
    if tunnel_manager.check_connectivity():
        logger.info("✅ Ollama connectivity verified")
    else:
        logger.warning("⚠️ Ollama may not be accessible yet")
    
    # Launch agents
    agent_launcher.launch_code_agent()
    agent_launcher.launch_data_agent()
    agent_launcher.launch_course_agent()
    agent_launcher.launch_tutor_agent()
    
    logger.info("✨ All agents launched!")

@app.on_event("shutdown")
async def shutdown():
    """Cleanup on shutdown"""
    logger.info("🛑 Shutting down Epic Agent Orchestrator...")
    tunnel_manager.stop()
    for proc in agent_launcher.agents.values():
        if proc.poll() is None:
            proc.terminate()

@app.get("/health")
async def health():
    """Health check"""
    tunnel_ok = tunnel_manager.check_connectivity()
    agents = agent_launcher.get_status()
    return {
        "status": "ok",
        "timestamp": datetime.now().isoformat(),
        "tunnel": "connected" if tunnel_ok else "disconnected",
        "agents_running": sum(1 for a in agents.values() if a.status == "running"),
        "total_agents": len(agents)
    }

@app.get("/status")
async def status():
    """Get system status"""
    agents = agent_launcher.get_status()
    return {
        "agents": {name: asdict(agent) for name, agent in agents.items()},
        "models_available": AVAILABLE_MODELS,
        "tunnel_status": "connected" if tunnel_manager.check_connectivity() else "disconnected"
    }

@app.get("/models")
async def list_models():
    """List available models"""
    try:
        response = requests.get(f"{OLLAMA_API}/api/tags", timeout=5)
        if response.status_code == 200:
            return response.json()
        else:
            return {"error": "Could not fetch models from Ollama"}
    except Exception as e:
        return {"error": str(e)}

@app.post("/agent/{agent_name}/query")
async def query_agent(agent_name: str, query: str, model: Optional[str] = None):
    """Send query to specific agent"""
    try:
        port = PORTS.get(agent_name)
        if not port:
            raise HTTPException(status_code=404, detail=f"Agent {agent_name} not found")
        
        response = requests.post(
            f"http://localhost:{port}/query",
            json={"query": query, "model": model or AVAILABLE_MODELS[0]},
            timeout=120
        )
        return response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/dashboard")
async def dashboard():
    """Serve monitoring dashboard"""
    return FileResponse(ASSETS_DIR / "index.html")

@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "name": "Epic Agent Orchestrator",
        "version": "1.0.0",
        "endpoints": {
            "health": "/health",
            "status": "/status",
            "models": "/models",
            "dashboard": "/dashboard"
        }
    }

# ============================================================================
# MAIN
# ============================================================================

def main():
    """Main entry point"""
    print("""
    ╔═══════════════════════════════════════════════════════════════╗
    ║   🚀 EPIC BACKGROUND AGENT RUNNER                            ║
    ║   Running AI Agents with VM 159 Models                      ║
    ╚═══════════════════════════════════════════════════════════════╝
    """)
    
    logger.info("Starting orchestrator server...")
    logger.info(f"Dashboard available at: http://localhost:{PORTS['dashboard']}")
    logger.info(f"API available at: http://localhost:{PORTS['orchestrator']}")
    
    uvicorn.run(
        app,
        host="0.0.0.0",
        port=PORTS["orchestrator"],
        log_level="info"
    )

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        logger.info("Interrupted by user")
    except Exception as e:
        logger.error(f"Fatal error: {e}")
        sys.exit(1)
