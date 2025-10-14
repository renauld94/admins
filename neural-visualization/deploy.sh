#!/bin/bash

# Neural Consciousness → Cosmic Intelligence Deployment Script
# This script sets up and deploys the Three.js visualization

set -e

echo "🧠 Neural Consciousness → Cosmic Intelligence Deployment"
echo "=================================================="

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 18+ first."
    exit 1
fi

# Check Node.js version
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo "❌ Node.js version 18+ is required. Current version: $(node -v)"
    exit 1
fi

echo "✅ Node.js $(node -v) detected"

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Create environment file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating environment configuration..."
    cp env.example .env
    echo "✅ Environment file created. Please update .env with your actual values."
fi

# Build the project
echo "🔨 Building project..."
npm run build

# Check if build was successful
if [ -d "dist" ]; then
    echo "✅ Build successful!"
    echo "📁 Output directory: dist/"
else
    echo "❌ Build failed!"
    exit 1
fi

# Create deployment package
echo "📦 Creating deployment package..."
DEPLOY_DIR="neural-visualization-deploy"
mkdir -p "$DEPLOY_DIR"

# Copy built files
cp -r dist/* "$DEPLOY_DIR/"
cp package.json "$DEPLOY_DIR/"
cp README.md "$DEPLOY_DIR/"

# Create deployment README
cat > "$DEPLOY_DIR/DEPLOYMENT.md" << EOF
# Neural Visualization Deployment

## Quick Start

1. Serve the files using any static web server:
   \`\`\`bash
   # Using Python
   python -m http.server 8000
   
   # Using Node.js
   npx serve .
   
   # Using PHP
   php -S localhost:8000
   \`\`\`

2. Open http://localhost:8000 in your browser

## Production Deployment

- Upload the contents of this directory to your web server
- Ensure your server supports serving static files
- Configure HTTPS for production use
- Set up proper caching headers for optimal performance

## Environment Configuration

Copy \`env.example\` to \`.env\` and update with your actual values:
- VITE_WEBSOCKET_URL: WebSocket for real-time data
- VITE_PROXMOX_API_URL: Proxmox API endpoint
- VITE_GEOSERVER_WMS_URL: GeoServer WMS endpoint
- VITE_MOODLE_STATS_WS: Moodle WebSocket endpoint

## Performance Notes

- Requires WebGL 2.0 support
- Optimized for 60 FPS on modern hardware
- Uses GPU instancing for 100k+ particles
- Includes LOD system for distant objects
EOF

echo "✅ Deployment package created in: $DEPLOY_DIR/"

# Create video export script
echo "🎬 Setting up video export..."
mkdir -p scripts
cat > scripts/export-video.sh << 'EOF'
#!/bin/bash

# Video Export Script for Neural Visualization
# Requires FFmpeg to be installed

echo "🎬 Exporting 90-second visualization video..."

# Check if FFmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "❌ FFmpeg is not installed. Please install FFmpeg first."
    echo "   Ubuntu/Debian: sudo apt install ffmpeg"
    echo "   macOS: brew install ffmpeg"
    echo "   Windows: Download from https://ffmpeg.org/"
    exit 1
fi

# Check if frames exist
if [ ! -d "exports" ] || [ -z "$(ls -A exports)" ]; then
    echo "❌ No frames found in exports/ directory."
    echo "   Run 'npm run export' first to generate frames."
    exit 1
fi

# Create video
echo "🎥 Creating video from frames..."
ffmpeg -r 60 -i exports/frame_%06d.png \
  -c:v libx264 \
  -pix_fmt yuv420p \
  -crf 18 \
  -preset slow \
  -movflags +faststart \
  neural_cosmic_visualization.mp4

if [ $? -eq 0 ]; then
    echo "✅ Video exported successfully: neural_cosmic_visualization.mp4"
    echo "📊 Video specs: 1920x1080, 60fps, 90 seconds"
else
    echo "❌ Video export failed!"
    exit 1
fi
EOF

chmod +x scripts/export-video.sh

# Create system check script
cat > scripts/check-system.sh << 'EOF'
#!/bin/bash

# System Requirements Check for Neural Visualization

echo "🔍 Checking system requirements..."

# Check WebGL support
echo "Checking WebGL support..."
if command -v node &> /dev/null; then
    node -e "
    const { execSync } = require('child_process');
    try {
        execSync('npx puppeteer --version', { stdio: 'pipe' });
        console.log('✅ Puppeteer available for WebGL testing');
    } catch (e) {
        console.log('⚠️  Puppeteer not available - install with: npm install puppeteer');
    }
    " 2>/dev/null || echo "⚠️  Node.js check failed"
fi

# Check GPU info (Linux)
if command -v lspci &> /dev/null; then
    echo "GPU Information:"
    lspci | grep -i vga || lspci | grep -i 3d || echo "⚠️  No GPU information found"
fi

# Check available memory
echo "Memory Information:"
if command -v free &> /dev/null; then
    free -h
elif command -v vm_stat &> /dev/null; then
    vm_stat
else
    echo "⚠️  Memory information not available"
fi

echo ""
echo "📋 System Requirements:"
echo "  - WebGL 2.0 compatible GPU"
echo "  - 4GB+ RAM recommended"
echo "  - Modern browser (Chrome 80+, Firefox 75+, Safari 13+)"
echo "  - Hardware acceleration enabled"
EOF

chmod +x scripts/check-system.sh

echo ""
echo "🎉 Deployment Complete!"
echo "======================"
echo ""
echo "📁 Files created:"
echo "  - $DEPLOY_DIR/ (deployment package)"
echo "  - scripts/export-video.sh (video export)"
echo "  - scripts/check-system.sh (system check)"
echo ""
echo "🚀 Next steps:"
echo "  1. Update .env with your actual configuration"
echo "  2. Test locally: npm run dev"
echo "  3. Deploy: Upload $DEPLOY_DIR/ to your web server"
echo "  4. Export video: ./scripts/export-video.sh"
echo ""
echo "📖 Documentation: README.md"
echo "🔧 Configuration: .env"
echo ""
echo "From neural networks to global data networks! 🧠🌍🛰️"
