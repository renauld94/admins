#!/bin/bash

# Neural Visualization Status Check
echo "🧠 Neural Consciousness → Cosmic Intelligence Status Check"
echo "========================================================"

# Check if server is running
if curl -s http://localhost:3001 > /dev/null; then
    echo "✅ Development server: RUNNING on http://localhost:3001"
else
    echo "❌ Development server: NOT RUNNING"
    echo "   Start with: cd neural-visualization && npm run dev"
fi

# Check if build exists
if [ -d "neural-visualization/dist" ]; then
    echo "✅ Production build: READY"
    echo "   Size: $(du -sh neural-visualization/dist | cut -f1)"
else
    echo "⚠️  Production build: NOT FOUND"
    echo "   Build with: cd neural-visualization && npm run build"
fi

# Check dependencies
if [ -d "neural-visualization/node_modules" ]; then
    echo "✅ Dependencies: INSTALLED"
else
    echo "❌ Dependencies: NOT INSTALLED"
    echo "   Install with: cd neural-visualization && npm install"
fi

# Check environment
if [ -f "neural-visualization/.env" ]; then
    echo "✅ Environment: CONFIGURED"
else
    echo "⚠️  Environment: USING DEFAULTS"
    echo "   Copy env.example to .env for custom configuration"
fi

echo ""
echo "🎯 Quick Access:"
echo "   Development: http://localhost:3001"
echo "   Network: http://192.168.0.112:3001"
echo "   Network: http://192.168.0.108:3001"
echo ""
echo "🎮 Controls:"
echo "   - Click numbered buttons (1-5) to jump between scenes"
echo "   - Use timeline scrubber to navigate the 90-second loop"
echo "   - Toggle performance stats and overlays"
echo "   - Click neurons, brains, and satellites for interactions"
echo ""
echo "🎬 Video Export:"
echo "   cd neural-visualization && npm run export"
echo ""
echo "From neural networks to global data networks! 🧠🌍🛰️"
