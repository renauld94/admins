import React from 'react'

interface ControlsPanelProps {
  currentScene: number
  setCurrentScene: (scene: number) => void
  isPlaying: boolean
  setIsPlaying: (playing: boolean) => void
  playbackSpeed: number
  setPlaybackSpeed: (speed: number) => void
  showOverlay: boolean
  setShowOverlay: (show: boolean) => void
  showPerformance: boolean
  setShowPerformance: (show: boolean) => void
  zoomLevel: number
  setZoomLevel: (level: number) => void
  dataIntegration: any
}

export function ControlsPanel({
  currentScene,
  setCurrentScene,
  isPlaying,
  setIsPlaying,
  playbackSpeed,
  setPlaybackSpeed,
  showOverlay,
  setShowOverlay,
  showPerformance,
  setShowPerformance,
  zoomLevel,
  setZoomLevel,
  dataIntegration
}: ControlsPanelProps) {
  const sceneNames = [
    'Individual Expertise',
    'Integrated Knowledge',
    'Collaborative Intelligence',
    'Global Infrastructure',
    'Distributed Systems'
  ]

  return (
    <div className="controls-panel">
      <h3>Neural Consciousness → Cosmic Intelligence</h3>
      
      {/* Scene Navigation */}
      <div>
        <label>Current Scene: {sceneNames[currentScene]}</label>
        <div className="scene-buttons">
          {sceneNames.map((name, index) => (
            <button
              key={index}
              onClick={() => setCurrentScene(index)}
              className={currentScene === index ? 'active' : ''}
            >
              {index + 1}
            </button>
          ))}
        </div>
      </div>

      {/* Playback Controls */}
      <div>
        <button onClick={() => setIsPlaying(!isPlaying)}>
          {isPlaying ? 'Pause' : 'Play'}
        </button>
        
        <label>Speed: {playbackSpeed}x</label>
        <input
          type="range"
          min="0.5"
          max="2"
          step="0.1"
          value={playbackSpeed}
          onChange={(e) => setPlaybackSpeed(parseFloat(e.target.value))}
        />
      </div>

      {/* Zoom Controls */}
      <div>
        <label>Zoom: {zoomLevel.toFixed(1)}x</label>
        <input
          type="range"
          min="0.1"
          max="5"
          step="0.1"
          value={zoomLevel}
          onChange={(e) => setZoomLevel(parseFloat(e.target.value))}
        />
        <div className="zoom-buttons">
          <button onClick={() => setZoomLevel(0.5)}>Micro</button>
          <button onClick={() => setZoomLevel(1)}>Normal</button>
          <button onClick={() => setZoomLevel(2)}>Macro</button>
          <button onClick={() => setZoomLevel(5)}>Cosmic</button>
        </div>
      </div>

      {/* Display Options */}
      <div>
        <label>
          <input
            type="checkbox"
            checked={showOverlay}
            onChange={(e) => setShowOverlay(e.target.checked)}
          />
          Show Scene Overlay
        </label>
        
        <label>
          <input
            type="checkbox"
            checked={showPerformance}
            onChange={(e) => setShowPerformance(e.target.checked)}
          />
          Show Performance Stats
        </label>
      </div>

      {/* Data Integration Status */}
      <div>
        <h4>Data Integration</h4>
        <div>WebSocket: {dataIntegration.isConnected ? 'Connected' : 'Disconnected'}</div>
        <div>Proxmox API: {dataIntegration.proxmoxStatus}</div>
        <div>GeoServer: {dataIntegration.geoserverStatus}</div>
        <div>Moodle: {dataIntegration.moodleStatus}</div>
      </div>

      {/* Timeline Scrubber */}
      <div>
        <label>Timeline (90s loop)</label>
        <input
          type="range"
          min="0"
          max="90"
          step="0.1"
          value={currentScene * 18} // Approximate time per scene
          onChange={(e) => {
            const time = parseFloat(e.target.value)
            const newScene = Math.floor(time / 18)
            setCurrentScene(Math.min(4, Math.max(0, newScene)))
          }}
          className="timeline-scrubber"
        />
      </div>
    </div>
  )
}
