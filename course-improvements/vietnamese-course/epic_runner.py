#!/usr/bin/env python3
import asyncio
from epic_enhancement_agent import EpicEnhancementOrchestrator

async def run_hours(hours=2):
    orchestrator = EpicEnhancementOrchestrator()
    await orchestrator.run_24h_enhancement(max_hours=hours)

if __name__ == '__main__':
    asyncio.run(run_hours(hours=2))
