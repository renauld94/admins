import React, { useRef, useEffect } from 'react'
import { useFrame } from '@react-three/fiber'
import { SceneNeuron } from '../scenes/SceneNeuron'
import { SceneBrain } from '../scenes/SceneBrain'
import { SceneCluster } from '../scenes/SceneCluster'
import { SceneEarth } from '../scenes/SceneEarth'
import { SceneGeoNeural } from '../scenes/SceneGeoNeural'
import { SceneOrbit } from '../scenes/SceneOrbit'

interface SceneManagerProps {
  currentScene: number
  dataIntegration: any
  playbackSpeed: number
  zoomLevel?: number
  geoNeuralData?: any
}

export function SceneManager({ currentScene, dataIntegration, playbackSpeed, zoomLevel = 1, geoNeuralData }: SceneManagerProps) {
  const groupRef = useRef<THREE.Group>(null)
  const timeRef = useRef(0)

  useFrame((state, delta) => {
    timeRef.current += delta * playbackSpeed
    
    // Reset time for seamless loop (90 seconds)
    if (timeRef.current >= 90) {
      timeRef.current = 0
    }

    // Update data integration
    dataIntegration.update(timeRef.current)
  })

  const renderScene = () => {
    const time = timeRef.current

    // Scene transitions based on time
    if (time >= 0 && time < 15) {
      return <SceneNeuron time={time} dataIntegration={dataIntegration} zoomLevel={zoomLevel} />
    } else if (time >= 15 && time < 30) {
      return <SceneBrain time={time - 15} dataIntegration={dataIntegration} zoomLevel={zoomLevel} />
    } else if (time >= 30 && time < 50) {
      return <SceneCluster time={time - 30} dataIntegration={dataIntegration} zoomLevel={zoomLevel} />
    } else if (time >= 50 && time < 65) {
      return <SceneEarth time={time - 50} playbackSpeed={playbackSpeed} zoomLevel={zoomLevel} />
    } else if (time >= 65 && time < 80) {
      return <SceneGeoNeural 
        time={time - 65} 
        playbackSpeed={playbackSpeed} 
        zoomLevel={zoomLevel}
        geoserverData={geoNeuralData?.geoserverData}
        neuralData={geoNeuralData?.neuralData}
      />
    } else if (time >= 80 && time < 90) {
      return <SceneOrbit time={time - 80} dataIntegration={dataIntegration} zoomLevel={zoomLevel} />
    }

    return null
  }

  return (
    <group ref={groupRef}>
      {renderScene()}
    </group>
  )
}
