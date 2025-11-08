/* Local Phase 2 Automation Simulator
 * Creates /tmp/phase2_automation.log so `tail -f` can follow progress.
 * This version removes the VS Code dependency and shortens delays for quick testing.
 */

const fs = require('fs');

const PHASE2_PROMPTS = [
  { id: 1, name: "WebSocket Real-Time Stats", expectedLines: 80, durationSec: 4 },
  { id: 2, name: "Layer Toggle Animations", expectedLines: 150, durationSec: 3 },
  { id: 3, name: "Stat Cards Pulse Animation", expectedLines: 30, durationSec: 2 },
  { id: 4, name: "Pan/Zoom Map Controls", expectedLines: 120, durationSec: 3 },
  { id: 5, name: "Live Data Layers", expectedLines: 200, durationSec: 4 }
];

class Phase2LocalSimulator {
  constructor() {
    this.currentPromptIndex = 0;
    this.results = [];
    this.startTime = new Date();
    this.logFile = '/tmp/phase2_automation.log';

    // Ensure log file exists and is empty
    try {
      fs.writeFileSync(this.logFile, '');
    } catch (err) {
      console.error('Cannot write to log file:', err.message);
      process.exit(1);
    }
  }

  log(message) {
    const timestamp = new Date().toISOString();
    const logMessage = `[${timestamp}] ${message}`;
    console.log(logMessage);
    fs.appendFileSync(this.logFile, logMessage + '\n');
  }

  async runAllPrompts() {
    this.log('='.repeat(80));
    this.log('🚀 PHASE 2 LOCAL SIMULATOR STARTED');
    this.log('='.repeat(80));
    this.log(`Total prompts: ${PHASE2_PROMPTS.length}`);
    this.log(`Estimated quick-run time: ~${PHASE2_PROMPTS.reduce((s,p)=>s+p.durationSec,0)} seconds`);
    this.log('');

    for (let i = 0; i < PHASE2_PROMPTS.length; i++) {
      this.currentPromptIndex = i;
      const prompt = PHASE2_PROMPTS[i];

      this.log('');
      this.log(`[PROGRESS] Prompt ${i+1}/${PHASE2_PROMPTS.length}: ${prompt.name}`);
      this.log(`Expected output: ~${prompt.expectedLines} lines`);
      this.log(`Simulating generation for ${prompt.durationSec}s...`);

      try {
        const result = await this.simulatePromptExecution(prompt);
        this.results.push(result);

        this.log(`✅ COMPLETED: ${prompt.name}`);
        this.log(`Generated: ${result.actualLines} lines`);
        this.log(`Time taken: ${result.duration}s`);
      } catch (error) {
        this.log(`❌ ERROR in prompt ${i+1}: ${error.message}`);
        this.results.push({promptId: prompt.id, success: false, error: error.message});
      }

      this.logProgressBar(i+1, PHASE2_PROMPTS.length);
    }

    this.logSummary();
  }

  async simulatePromptExecution(prompt) {
    return new Promise((resolve) => {
      setTimeout(() => {
        resolve({
          promptId: prompt.id,
          success: true,
          actualLines: Math.round(prompt.expectedLines + (Math.random() * 20 - 10)),
          duration: prompt.durationSec
        });
      }, prompt.durationSec * 1000);
    });
  }

  logProgressBar(current, total) {
    const percentage = Math.round((current / total) * 100);
    const filled = Math.round((current / total) * 20);
    const empty = 20 - filled;
    this.log(`Progress: [${'█'.repeat(filled)}${'░'.repeat(empty)}] ${percentage}%`);
  }

  logSummary() {
    this.log('');
    this.log('='.repeat(80));
    this.log('📊 PHASE 2 LOCAL SUMMARY');
    this.log('='.repeat(80));

    const successful = this.results.filter(r => r.success !== false).length;
    const failed = this.results.filter(r => r.success === false).length;
    const totalTime = ((new Date() - this.startTime) / 1000).toFixed(1);

    this.log(`Successful: ${successful}/${PHASE2_PROMPTS.length}`);
    this.log(`Failed: ${failed}/${PHASE2_PROMPTS.length}`);
    this.log(`Total time: ${totalTime}s`);

    this.results.forEach((result, idx) => {
      const prompt = PHASE2_PROMPTS[idx];
      const status = result.success === false ? '❌' : '✅';
      this.log(`${status} Prompt ${idx+1}: ${prompt.name}`);
      if (result.success !== false) {
        this.log(`   Lines: ${result.actualLines}`);
        this.log(`   Time: ${result.duration}s`);
      } else {
        this.log(`   Error: ${result.error}`);
      }
    });

    this.log('');
    this.log('='.repeat(80));
    this.log('Phase 2 Local Simulation Complete!');
    this.log('='.repeat(80));
  }
}

// Run
const sim = new Phase2LocalSimulator();
sim.runAllPrompts().catch(err => {
  sim.log(`Fatal error: ${err.message}`);
  process.exit(1);
});
