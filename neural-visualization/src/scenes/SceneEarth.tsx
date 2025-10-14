import React, { useRef, useMemo } from 'react'
import { useFrame } from '@react-three/fiber'
import * as THREE from 'three'
import { ParticleSystem } from '../components/ParticleSystem'
import { InfrastructureNetwork } from '../components/InfrastructureNetwork'

interface SceneEarthProps {
  time: number
  playbackSpeed: number
  zoomLevel?: number
}

export function SceneEarth({ time, playbackSpeed, zoomLevel = 1 }: SceneEarthProps) {
  const earthRef = useRef<THREE.Mesh>(null)
  const atmosphereRef = useRef<THREE.Mesh>(null)
  const networkRef = useRef<THREE.Group>(null)

  // Create Earth geometry and material
  const earthGeometry = useMemo(() => new THREE.SphereGeometry(2, 64, 64), [])
  
  const earthMaterial = useMemo(() => {
    const material = new THREE.MeshPhongMaterial({
      color: 0x2563eb,
      shininess: 100,
      transparent: true,
      opacity: 0.9
    })
    return material
  }, [])

  // Create atmosphere effect
  const atmosphereGeometry = useMemo(() => new THREE.SphereGeometry(2.1, 32, 32), [])
  
  const atmosphereMaterial = useMemo(() => {
    const material = new THREE.MeshBasicMaterial({
      color: 0x00ff88,
      transparent: true,
      opacity: 0.1,
      side: THREE.BackSide
    })
    return material
  }, [])

  // Create network connections
  const networkGeometry = useMemo(() => {
    const geometry = new THREE.BufferGeometry()
    const points = []
    const connections = []

    // Generate network nodes around Earth
    for (let i = 0; i < 50; i++) {
      const phi = Math.acos(-1 + (2 * i) / 50)
      const theta = Math.sqrt(50 * Math.PI) * phi
      
      const x = 3.5 * Math.cos(theta) * Math.sin(phi)
      const y = 3.5 * Math.sin(theta) * Math.sin(phi)
      const z = 3.5 * Math.cos(phi)
      
      points.push(x, y, z)
    }

    // Create connections between nodes
    for (let i = 0; i < points.length; i += 3) {
      for (let j = i + 3; j < points.length; j += 3) {
        const distance = Math.sqrt(
          Math.pow(points[i] - points[j], 2) +
          Math.pow(points[i + 1] - points[j + 1], 2) +
          Math.pow(points[i + 2] - points[j + 2], 2)
        )
        
        if (distance < 2) {
          connections.push(
            points[i], points[i + 1], points[i + 2],
            points[j], points[j + 1], points[j + 2]
          )
        }
      }
    }

    geometry.setAttribute('position', new THREE.Float32BufferAttribute(connections, 3))
    return geometry
  }, [])

  const networkMaterial = useMemo(() => {
    return new THREE.LineBasicMaterial({
      color: 0x00ff88,
      transparent: true,
      opacity: 0.6
    })
  }, [])

  useFrame((state) => {
    const elapsedTime = time * playbackSpeed

    // Rotate Earth
    if (earthRef.current) {
      earthRef.current.rotation.y = elapsedTime * 0.1
    }

    // Pulse atmosphere
    if (atmosphereRef.current) {
      atmosphereRef.current.scale.setScalar(1 + Math.sin(elapsedTime * 2) * 0.05)
      atmosphereRef.current.material.opacity = 0.1 + Math.sin(elapsedTime * 3) * 0.05
    }

    // Animate network connections
    if (networkRef.current) {
      networkRef.current.rotation.y = elapsedTime * 0.05
      networkRef.current.children.forEach((child, index) => {
        if (child instanceof THREE.Line) {
          child.material.opacity = 0.3 + Math.sin(elapsedTime * 2 + index * 0.1) * 0.3
        }
      })
    }
  })

  return (
    <group>
      {/* Earth */}
      <mesh ref={earthRef} geometry={earthGeometry} material={earthMaterial}>
        {/* Add some surface details */}
        <mesh position={[0, 0, 2.1]}>
          <planeGeometry args={[0.5, 0.5]} />
          <meshBasicMaterial color={0x10b981} transparent opacity={0.8} />
        </mesh>
      </mesh>

      {/* Atmosphere */}
      <mesh ref={atmosphereRef} geometry={atmosphereGeometry} material={atmosphereMaterial} />

      {/* Network connections */}
      <group ref={networkRef}>
        <lineSegments geometry={networkGeometry} material={networkMaterial} />
      </group>

      {/* Data flow particles */}
      <ParticleSystem
        count={200}
        time={time}
        type="data"
        position={[0, 0, 0]}
      />

      {/* Signal particles */}
      <ParticleSystem
        count={150}
        time={time}
        type="signals"
        position={[0, 0, 0]}
      />

      {/* Global Infrastructure Network */}
      <InfrastructureNetwork time={time} zoomLevel={zoomLevel} />
    </group>
  )
}