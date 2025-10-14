import puppeteer from 'puppeteer'
import fs from 'fs'
import path from 'path'

const OUTPUT_DIR = './exports'
const VIDEO_DURATION = 90 // seconds
const FPS = 60
const TOTAL_FRAMES = VIDEO_DURATION * FPS

async function exportVideo() {
  console.log('Starting video export...')
  
  // Ensure output directory exists
  if (!fs.existsSync(OUTPUT_DIR)) {
    fs.mkdirSync(OUTPUT_DIR, { recursive: true })
  }

  // Launch headless browser
  const browser = await puppeteer.launch({
    headless: true,
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--disable-dev-shm-usage',
      '--disable-gpu',
      '--no-first-run',
      '--no-zygote',
      '--single-process'
    ]
  })

  const page = await browser.newPage()
  
  // Set viewport for consistent rendering
  await page.setViewport({
    width: 1920,
    height: 1080,
    deviceScaleFactor: 1
  })

  // Navigate to the visualization
  const serverUrl = process.env.SERVER_URL || 'http://localhost:3000'
  await page.goto(serverUrl, { waitUntil: 'networkidle0' })

  // Wait for Three.js to initialize
  await page.waitForFunction(() => {
    return window.performance.now() > 2000 // Wait 2 seconds for initialization
  })

  console.log('Capturing frames...')

  // Capture frames
  const frames = []
  for (let frame = 0; frame < TOTAL_FRAMES; frame++) {
    const time = (frame / FPS) % VIDEO_DURATION
    
    // Set the current time in the visualization
    await page.evaluate((currentTime) => {
      if (window.setVisualizationTime) {
        window.setVisualizationTime(currentTime)
      }
    }, time)

    // Wait for frame to render
    await page.waitForTimeout(1000 / FPS)

    // Capture screenshot
    const screenshot = await page.screenshot({
      type: 'png',
      fullPage: false
    })

    frames.push(screenshot)
    
    if (frame % (FPS * 5) === 0) {
      console.log(`Captured ${frame}/${TOTAL_FRAMES} frames (${Math.round(frame/TOTAL_FRAMES*100)}%)`)
    }
  }

  console.log('Saving frames...')

  // Save frames as PNG files
  for (let i = 0; i < frames.length; i++) {
    const framePath = path.join(OUTPUT_DIR, `frame_${i.toString().padStart(6, '0')}.png`)
    fs.writeFileSync(framePath, frames[i])
  }

  console.log('Frames saved. Use FFmpeg to create video:')
  console.log(`ffmpeg -r ${FPS} -i ${OUTPUT_DIR}/frame_%06d.png -c:v libx264 -pix_fmt yuv420p -crf 18 ${OUTPUT_DIR}/neural_cosmic_visualization.mp4`)

  await browser.close()
  console.log('Export complete!')
}

// Run export if called directly
if (require.main === module) {
  exportVideo().catch(console.error)
}

export { exportVideo }
