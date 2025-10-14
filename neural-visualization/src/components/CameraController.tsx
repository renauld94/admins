import React, { useRef, useEffect } from 'react'
import { useFrame, useThree } from '@react-three/fiber'
import * as THREE from 'three'
import { gsap } from 'gsap'

interface CameraControllerProps {
  currentScene: number
  isPlaying: boolean
  playbackSpeed: number
  zoomLevel?: number
}

// Camera positions and targets for each scene
const cameraConfigs = [
  // Scene 1: Individual Neuron (microscopic zoom)
  {
    position: [0, 0, 1.5],
    target: [0, 0, 0],
    fov: 85,
    duration: 12,
    movement: 'microscopic'
  },
  // Scene 2: Brain Network (neural zoom)
  {
    position: [0, 0, 6],
    target: [0, 0, 0],
    fov: 70,
    duration: 15,
    movement: 'neural'
  },
  // Scene 3: Collaborative Intelligence (orbital)
  {
    position: [12, 8, 12],
    target: [0, 0, 0],
    fov: 55,
    duration: 20,
    movement: 'orbital'
  },
  // Scene 4: Global Infrastructure (Earth view)
  {
    position: [18, 12, 18],
    target: [0, 0, 0],
    fov: 45,
    duration: 25,
    movement: 'earth'
  },
  // Scene 5: Distributed Systems (cosmic)
  {
    position: [25, 20, 25],
    target: [0, 0, 0],
    fov: 35,
    duration: 18,
    movement: 'cosmic'
  }
]

export function CameraController({ currentScene, isPlaying, playbackSpeed, zoomLevel = 1 }: CameraControllerProps) {
  const { camera } = useThree()
  const cameraRef = useRef(camera)
  const timelineRef = useRef<gsap.core.Timeline | null>(null)

  useEffect(() => {
    if (timelineRef.current) {
      timelineRef.current.kill()
    }

    const config = cameraConfigs[currentScene]
    if (!config) return

    // Apply zoom scaling to position
    const zoomedPosition = [
      config.position[0] * zoomLevel,
      config.position[1] * zoomLevel,
      config.position[2] * zoomLevel
    ]

    // Create smooth camera transition
    timelineRef.current = gsap.timeline({
      duration: config.duration / playbackSpeed,
      ease: "power2.inOut"
    })

    // Position transition with zoom
    timelineRef.current.to(cameraRef.current.position, {
      x: zoomedPosition[0],
      y: zoomedPosition[1],
      z: zoomedPosition[2],
      duration: config.duration / playbackSpeed,
      ease: "power2.inOut"
    }, 0)

    // FOV transition with zoom effect
    if (cameraRef.current instanceof THREE.PerspectiveCamera) {
      const zoomedFov = config.fov / Math.max(0.1, zoomLevel)
      timelineRef.current.to(cameraRef.current, {
        fov: zoomedFov,
        duration: config.duration / playbackSpeed,
        ease: "power2.inOut",
        onUpdate: () => {
          cameraRef.current.updateProjectionMatrix()
        }
      }, 0)
    }

    // Target transition (lookAt)
    const target = new THREE.Vector3(config.target[0], config.target[1], config.target[2])
    timelineRef.current.to(cameraRef.current, {
      duration: config.duration / playbackSpeed,
      ease: "power2.inOut",
      onUpdate: () => {
        cameraRef.current.lookAt(target)
      }
    }, 0)

    return () => {
      if (timelineRef.current) {
        timelineRef.current.kill()
      }
    }
  }, [currentScene, playbackSpeed])

  useFrame((state, delta) => {
    if (!isPlaying) return

    // Add subtle camera shake during transitions
    const shakeIntensity = 0.02
    const shakeX = (Math.random() - 0.5) * shakeIntensity
    const shakeY = (Math.random() - 0.5) * shakeIntensity
    const shakeZ = (Math.random() - 0.5) * shakeIntensity

    cameraRef.current.position.x += shakeX
    cameraRef.current.position.y += shakeY
    cameraRef.current.position.z += shakeZ

    // Add camera roll for cinematic effect
    const rollAmount = Math.sin(state.clock.elapsedTime * 0.1) * 0.01
    cameraRef.current.rotation.z += rollAmount

    // Enhanced camera movement based on scene type
    const config = cameraConfigs[currentScene]
    if (config) {
      switch (config.movement) {
        case 'microscopic': // Individual neuron - precise tracking
          cameraRef.current.rotation.z = Math.sin(state.clock.elapsedTime * 0.5) * 0.02
          cameraRef.current.position.y += Math.sin(state.clock.elapsedTime * 0.3) * 0.01
          break
          
        case 'neural': // Brain network - gentle exploration
          cameraRef.current.rotation.y += delta * 0.005
          cameraRef.current.position.y += Math.sin(state.clock.elapsedTime * 0.2) * 0.02
          break
          
        case 'orbital': // Collaborative intelligence - smooth orbiting
          const orbitRadius = 15 * zoomLevel
          const orbitSpeed = 0.015
          const angle = state.clock.elapsedTime * orbitSpeed
          cameraRef.current.position.x = Math.cos(angle) * orbitRadius
          cameraRef.current.position.z = Math.sin(angle) * orbitRadius
          cameraRef.current.lookAt(0, 0, 0)
          break
          
        case 'earth': // Global infrastructure - Earth-like movement
          const earthRadius = 20 * zoomLevel
          const earthSpeed = 0.01
          const earthAngle = state.clock.elapsedTime * earthSpeed
          cameraRef.current.position.x = Math.cos(earthAngle) * earthRadius
          cameraRef.current.position.z = Math.sin(earthAngle) * earthRadius
          cameraRef.current.position.y += Math.sin(state.clock.elapsedTime * 0.05) * 0.5
          cameraRef.current.lookAt(0, 0, 0)
          break
          
        case 'cosmic': // Distributed systems - cosmic perspective
          const cosmicRadius = 30 * zoomLevel
          const cosmicSpeed = 0.008
          const cosmicAngle = state.clock.elapsedTime * cosmicSpeed
          cameraRef.current.position.x = Math.cos(cosmicAngle) * cosmicRadius
          cameraRef.current.position.z = Math.sin(cosmicAngle) * cosmicRadius
          cameraRef.current.position.y += Math.sin(state.clock.elapsedTime * 0.03) * 1
          cameraRef.current.lookAt(0, 0, 0)
          break
      }
    }
  })

  return null
}
