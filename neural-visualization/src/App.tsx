import React, { Suspense, useState, useRef, useEffect } from 'react'
import { Canvas } from '@react-three/fiber'
import { OrbitControls, Environment, Stats } from '@react-three/drei'
import { EffectComposer, Bloom, Vignette, ChromaticAberration } from '@react-three/postprocessing'
import { BlendFunction } from 'postprocessing'
import { SceneManager } from './components/SceneManager'
import { CameraController } from './components/CameraController'
import { PerformanceMonitor } from './components/PerformanceMonitor'
import { ControlsPanel } from './components/ControlsPanel'
import { SceneOverlay } from './components/SceneOverlay'
import { LoadingScreen } from './components/LoadingScreen'
import { useDataIntegration } from './hooks/useDataIntegration'
import { useGeoNeuralData } from './services/GeoNeuralDataService'

// Environment variables with fallbacks
const CONFIG = {
  WEBSOCKET_URL: import.meta.env.VITE_WEBSOCKET_URL || 'ws://localhost:8080',
  PROXMOX_API_URL: import.meta.env.VITE_PROXMOX_API_URL || 'https://vm106-geoneural10.0.0.1.11:8006',
  GEOSERVER_WMS_URL: import.meta.env.VITE_GEOSERVER_WMS_URL || 'http://vm106-geoneural10.0.0.1.11:8080/geoserver',
  MOODLE_STATS_WS: import.meta.env.VITE_MOODLE_STATS_WS || 'ws://localhost:3001',
  MOCK_DATA: import.meta.env.VITE_MOCK_DATA === 'true' || true
}

export default function App() {
  const [isLoading, setIsLoading] = useState(true)
  const [currentScene, setCurrentScene] = useState(0)
  const [isPlaying, setIsPlaying] = useState(true)
  const [playbackSpeed, setPlaybackSpeed] = useState(1)
  const [showOverlay, setShowOverlay] = useState(true)
  const [showPerformance, setShowPerformance] = useState(false)
  const [zoomLevel, setZoomLevel] = useState(1)
  const canvasRef = useRef<HTMLCanvasElement>(null)

  // Initialize data integration
  const dataIntegration = useDataIntegration(CONFIG)
  const geoNeuralData = useGeoNeuralData()

  useEffect(() => {
    // Simulate loading time
    const timer = setTimeout(() => {
      setIsLoading(false)
    }, 2000)

    return () => clearTimeout(timer)
  }, [])

  const sceneNames = [
    'Individual Expertise',
    'Integrated Knowledge', 
    'Collaborative Intelligence',
    'Global Infrastructure',
    'GeoNeural Integration',
    'Distributed Systems'
  ]

  if (isLoading) {
    return <LoadingScreen />
  }

  return (
    <>
      <Canvas
        ref={canvasRef}
        camera={{ 
          position: [0, 0, 5], 
          fov: 75,
          near: 0.1,
          far: 10000
        }}
        gl={{ 
          antialias: true,
          alpha: false,
          powerPreference: 'high-performance'
        }}
        dpr={[1, 2]}
        performance={{ min: 0.5 }}
      >
        <Suspense fallback={null}>
          {/* Lighting */}
          <ambientLight intensity={0.1} />
          <directionalLight position={[10, 10, 5]} intensity={0.5} />
          <pointLight position={[-10, -10, -5]} intensity={0.3} color="#00ff88" />

          {/* Environment */}
          <Environment preset="night" />

          {/* Main Scene Manager */}
          <SceneManager 
            currentScene={currentScene}
            dataIntegration={dataIntegration}
            playbackSpeed={playbackSpeed}
            zoomLevel={zoomLevel}
            geoNeuralData={geoNeuralData}
          />

          {/* Camera Controller */}
          <CameraController 
            currentScene={currentScene}
            isPlaying={isPlaying}
            playbackSpeed={playbackSpeed}
            zoomLevel={zoomLevel}
          />

          {/* Post-processing Effects */}
          <EffectComposer>
            <Bloom
              intensity={1.8}
              luminanceThreshold={0.85}
              luminanceSmoothing={0.9}
              blendFunction={BlendFunction.ADD}
            />
            <Vignette
              eskil={false}
              offset={0.1}
              darkness={0.5}
              blendFunction={BlendFunction.NORMAL}
            />
            <ChromaticAberration
              offset={[0.001, 0.001]}
              blendFunction={BlendFunction.NORMAL}
            />
          </EffectComposer>

          {/* Performance Stats */}
          {showPerformance && <Stats />}
        </Suspense>
      </Canvas>

      {/* UI Overlays */}
      <ControlsPanel
        currentScene={currentScene}
        setCurrentScene={setCurrentScene}
        isPlaying={isPlaying}
        setIsPlaying={setIsPlaying}
        playbackSpeed={playbackSpeed}
        setPlaybackSpeed={setPlaybackSpeed}
        showOverlay={showOverlay}
        setShowOverlay={setShowOverlay}
        showPerformance={showPerformance}
        setShowPerformance={setShowPerformance}
        zoomLevel={zoomLevel}
        setZoomLevel={setZoomLevel}
        dataIntegration={dataIntegration}
      />

      <SceneOverlay 
        text={sceneNames[currentScene]}
        visible={showOverlay}
      />

      <PerformanceMonitor />
    </>
  )
}
