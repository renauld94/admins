/**
 * AI INTEGRATION MODULE FOR EPIC PORTFOLIO
 * Connects to: Ollama, OpenWebUI, Grafana/Prometheus
 * Created: 2025-10-04
 * 
 * This module enables LIVE AI interaction with the 3D cinematic experience:
 * - Real-time AI narration via Ollama
 * - Live metrics from Grafana/Prometheus
 * - Interactive chat with OpenWebUI
 * - Generative content creation
 */

export class AIIntegrationManager {
  constructor() {
    this.ollamaEndpoint = 'https://openwebui.simondatalab.de/api';
    this.grafanaEndpoint = 'http://grafana.simondatalab.de/api';
    this.metricsCache = new Map();
    this.narrativeCache = [];
    this.isStreaming = false;
    
    // AI Configuration
    this.model = 'llama3.2'; // Default model
    this.temperature = 0.9; // High creativity
    this.maxTokens = 200;
    
    // Metrics polling
    this.metricsInterval = null;
    this.pollRate = 8000; // Increased to 8 seconds to reduce CPU usage
    
    // Performance monitoring
    this.performanceMode = 'balanced'; // 'performance' | 'balanced' | 'quality'
    this.enableDebugLogs = false; // Set true for debugging
    
    // Request debouncing
    this.pendingRequests = new Map();
    
    // Lazy initialization flag
    this.initialized = false;
    this.initPromise = null;
  }
  
  /**
   * Lazy initialization - only run when needed
   */
  async initialize() {
    if (this.initialized) return;
    if (this.initPromise) return this.initPromise;
    
    this.initPromise = new Promise((resolve) => {
      // Delay initialization by 3 seconds to let scene load first
      setTimeout(() => {
        this.initialized = true;
        if (this.enableDebugLogs) {
          console.log('🤖 AI Integration Manager initialized (lazy)');
        }
        resolve();
      }, 3000);
    });
    
    return this.initPromise;
  }

  /**
   * FEATURE 1: REAL-TIME AI NARRATION
   * Generates poetic descriptions of the current animation phase
   */
  async generateNarrative(phase, sceneContext) {
    // Lazy initialization - wait until first use
    await this.initialize();
    
    const prompts = {
      neural: `You are witnessing the birth of consciousness. Describe in 2-3 poetic sentences what you see as electrical signals dance between neurons, forming the foundation of thought. Be inspirational and profound. Focus on emergence, connection, and the spark of intelligence.`,
      
      brain: `The neurons have formed a brain - a universe of thought. In 2-3 poetic sentences, describe the beauty of synaptic connections creating consciousness. Speak to the observer's sense of wonder about the human mind. Focus on complexity, emergence, and cognitive beauty.`,
      
      earth: `From mind to world - data flows across a digital Earth. In 2-3 poetic sentences, describe how information connects humanity across continents. Be visionary about technology's role in global connection. Focus on networks, communication, and planetary intelligence.`,
      
      cosmos: `The journey expands to infinity - stars, galaxies, the cosmic web. In 2-3 poetic sentences, describe the observer's place in this vast universe of data and wonder. Be philosophical about scale, perspective, and our quest for understanding. End with hope and invitation.`
    };

    try {
      const response = await fetch(`${this.ollamaEndpoint}/chat`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model: this.model,
          messages: [
            {
              role: 'system',
              content: 'You are a poetic AI narrator for an epic 3D visualization journey. Speak in vivid, inspiring language. Keep responses to 2-3 sentences maximum. Be profound but concise.'
            },
            {
              role: 'user',
              content: prompts[phase] || prompts.neural
            }
          ],
          temperature: this.temperature,
          max_tokens: this.maxTokens,
          stream: false
        })
      });

      const data = await response.json();
      const narrative = data.message?.content || this.getFallbackNarrative(phase);
      
      this.narrativeCache.push({ phase, text: narrative, timestamp: Date.now() });
      return narrative;
      
    } catch (error) {
      console.warn('AI Narration failed, using fallback:', error);
      return this.getFallbackNarrative(phase);
    }
  }

  getFallbackNarrative(phase) {
    const fallbacks = {
      neural: "Watch as electrical impulses dance through neural pathways, each spark a thought waiting to be born. This is the genesis of intelligence, the first whisper of consciousness.",
      brain: "Billions of connections weave together into a tapestry of thought. Each synapse fires with purpose, creating the miracle of awareness, the symphony of mind.",
      earth: "Data streams encircle our world like rivers of light, connecting minds across oceans. We have woven a planetary nervous system, a global consciousness awakening.",
      cosmos: "You stand at the edge of infinity, where data becomes stardust and algorithms trace the patterns of creation. Your journey through technology mirrors humanity's eternal quest to understand our place among the stars."
    };
    return fallbacks[phase] || fallbacks.neural;
  }

  /**
   * FEATURE 2: LIVE METRICS FROM GRAFANA/PROMETHEUS
   * Pulls real-time server metrics to drive animation parameters
   */
  async fetchMetrics() {
    try {
      // Fetch multiple metrics in parallel
      const [cpuMetric, memoryMetric, networkMetric] = await Promise.all([
        this.queryPrometheus('rate(process_cpu_seconds_total[1m])'),
        this.queryPrometheus('process_resident_memory_bytes'),
        this.queryPrometheus('rate(http_requests_total[1m])')
      ]);

      const metrics = {
        cpu: this.normalizeMetric(cpuMetric, 0, 100), // 0-1 range
        memory: this.normalizeMetric(memoryMetric, 0, 8e9), // 0-8GB
        network: this.normalizeMetric(networkMetric, 0, 1000), // 0-1000 req/s
        timestamp: Date.now()
      };

      this.metricsCache.set('latest', metrics);
      return metrics;
      
    } catch (error) {
      console.warn('Metrics fetch failed, using simulated data:', error);
      return this.getSimulatedMetrics();
    }
  }

  async queryPrometheus(query) {
    const url = `${this.grafanaEndpoint}/datasources/proxy/1/api/v1/query?query=${encodeURIComponent(query)}`;
    const response = await fetch(url);
    const data = await response.json();
    
    if (data.status === 'success' && data.data.result.length > 0) {
      return parseFloat(data.data.result[0].value[1]);
    }
    throw new Error('No data returned');
  }

  normalizeMetric(value, min, max) {
    return Math.max(0, Math.min(1, (value - min) / (max - min)));
  }

  getSimulatedMetrics() {
    // Fallback simulated metrics with realistic patterns
    const time = Date.now() / 1000;
    return {
      cpu: 0.3 + 0.2 * Math.sin(time / 10),
      memory: 0.5 + 0.1 * Math.cos(time / 15),
      network: 0.4 + 0.3 * Math.sin(time / 5),
      timestamp: Date.now(),
      simulated: true
    };
  }

  startMetricsPolling(callback) {
    this.stopMetricsPolling(); // Clear existing
    this.metricsInterval = setInterval(async () => {
      const metrics = await this.fetchMetrics();
      callback(metrics);
    }, this.pollRate);
    
    // Fetch immediately
    this.fetchMetrics().then(callback);
  }

  stopMetricsPolling() {
    if (this.metricsInterval) {
      clearInterval(this.metricsInterval);
      this.metricsInterval = null;
    }
  }

  /**
   * FEATURE 3: AI CHAT PORTAL
   * Enables visitors to chat with your portfolio via OpenWebUI
   */
  async sendChatMessage(message, conversationHistory = []) {
    try {
      const response = await fetch(`${this.ollamaEndpoint}/chat`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model: this.model,
          messages: [
            {
              role: 'system',
              content: `You are Simon's AI portfolio assistant. You help visitors learn about Simon's skills in:
- Data Science & Machine Learning
- Full-Stack Development (React, Node.js, Python)
- DevOps & Infrastructure (Docker, Kubernetes, Prometheus/Grafana)
- AI/LLM Integration (Ollama, OpenWebUI)
- 3D Visualization (Three.js, WebGL)

Be enthusiastic, professional, and highlight Simon's unique combination of technical depth and creative vision. 
Keep responses under 100 words. Be conversational and engaging.`
            },
            ...conversationHistory,
            {
              role: 'user',
              content: message
            }
          ],
          temperature: 0.8,
          max_tokens: 150,
          stream: false
        })
      });

      const data = await response.json();
      return data.message?.content || "I'm here to help! Ask me about Simon's work.";
      
    } catch (error) {
      console.error('Chat failed:', error);
      return "I'm having trouble connecting right now, but I'd love to chat about Simon's impressive work in AI, data science, and 3D visualization!";
    }
  }

  /**
   * FEATURE 4: GENERATIVE CONTENT
   * Creates dynamic, AI-generated content for the portfolio
   */
  async generateDynamicTagline() {
    try {
      const response = await fetch(`${this.ollamaEndpoint}/chat`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model: this.model,
          messages: [
            {
              role: 'system',
              content: 'Generate a single powerful tagline (8-12 words) for a data scientist who builds AI systems, creates 3D visualizations, and runs his own infrastructure. Make it inspiring and unique. Return ONLY the tagline, nothing else.'
            },
            {
              role: 'user',
              content: 'Create an epic tagline.'
            }
          ],
          temperature: 1.0,
          max_tokens: 30,
          stream: false
        })
      });

      const data = await response.json();
      return data.message?.content.replace(/['"]/g, '').trim();
      
    } catch (error) {
      const fallbacks = [
        "Building Intelligence, One Neural Connection at a Time",
        "Where Data Meets Creativity in Three Dimensions",
        "Engineering the Future of AI-Powered Experiences",
        "Transforming Complexity into Visual Poetry",
        "Full-Stack Architect of Intelligent Systems"
      ];
      return fallbacks[Math.floor(Math.random() * fallbacks.length)];
    }
  }

  async generateConstellationFromText(text) {
    // Generate 3D coordinates for text as constellation points
    const words = text.split(' ');
    const points = [];
    
    for (let i = 0; i < words.length; i++) {
      const angle = (i / words.length) * Math.PI * 2;
      const radius = 5 + Math.random() * 3;
      const height = (Math.random() - 0.5) * 4;
      
      points.push({
        position: [
          Math.cos(angle) * radius,
          height,
          Math.sin(angle) * radius
        ],
        word: words[i],
        brightness: 0.5 + Math.random() * 0.5
      });
    }
    
    return points;
  }

  /**
   * UTILITY: Health check for all services
   */
  async healthCheck() {
    const results = {
      ollama: false,
      grafana: false,
      timestamp: Date.now()
    };

    try {
      const ollamaCheck = await fetch(`${this.ollamaEndpoint}/tags`, {
        method: 'GET',
        signal: AbortSignal.timeout(5000)
      });
      results.ollama = ollamaCheck.ok;
    } catch (e) {
      console.warn('Ollama health check failed:', e.message);
    }

    try {
      const grafanaCheck = await fetch(`${this.grafanaEndpoint}/health`, {
        method: 'GET',
        signal: AbortSignal.timeout(5000)
      });
      results.grafana = grafanaCheck.ok;
    } catch (e) {
      console.warn('Grafana health check failed:', e.message);
    }

    return results;
  }
}

// Singleton instance
export const aiManager = new AIIntegrationManager();
