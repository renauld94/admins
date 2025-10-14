import React, { useRef, useMemo, useEffect } from 'react'
import { useFrame } from '@react-three/fiber'
import * as THREE from 'three'

interface ParticleSystemProps {
  count: number
  time: number
  type: 'ions' | 'neurotransmitters' | 'data' | 'signals'
  position: [number, number, number]
}

export function ParticleSystem({ count, time, type, position }: ParticleSystemProps) {
  const meshRef = useRef<THREE.Points>(null)
  const materialRef = useRef<THREE.PointsMaterial>(null)

  const { positions, colors, sizes } = useMemo(() => {
    const positions = new Float32Array(count * 3)
    const colors = new Float32Array(count * 3)
    const sizes = new Float32Array(count)

    for (let i = 0; i < count; i++) {
      const i3 = i * 3
      
      // Random positions around origin
      positions[i3] = (Math.random() - 0.5) * 10
      positions[i3 + 1] = (Math.random() - 0.5) * 10
      positions[i3 + 2] = (Math.random() - 0.5) * 10
      
      // Type-specific colors
      switch (type) {
        case 'ions':
          colors[i3] = 0.0     // R
          colors[i3 + 1] = 1.0 // G
          colors[i3 + 2] = 0.5 // B
          break
        case 'neurotransmitters':
          colors[i3] = 1.0     // R
          colors[i3 + 1] = 0.0 // G
          colors[i3 + 2] = 0.5 // B
          break
        case 'data':
          colors[i3] = 0.0     // R
          colors[i3 + 1] = 0.5 // G
          colors[i3 + 2] = 1.0 // B
          break
        case 'signals':
          colors[i3] = 1.0     // R
          colors[i3 + 1] = 1.0 // G
          colors[i3 + 2] = 0.0 // B
          break
      }
      
      sizes[i] = Math.random() * 0.5 + 0.1
    }

    return { positions, colors, sizes }
  }, [count, type])

  const geometry = useMemo(() => {
    const geometry = new THREE.BufferGeometry()
    geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3))
    geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3))
    geometry.setAttribute('size', new THREE.BufferAttribute(sizes, 1))
    return geometry
  }, [positions, colors, sizes])

  useFrame((state) => {
    if (!meshRef.current || !meshRef.current.geometry) return

    const positionAttribute = meshRef.current.geometry.attributes.position
    const colorAttribute = meshRef.current.geometry.attributes.color
    
    if (!positionAttribute || !colorAttribute) return

    const positions = positionAttribute.array as Float32Array
    const colors = colorAttribute.array as Float32Array

    for (let i = 0; i < count; i++) {
      const i3 = i * 3
      
      // Animate particles based on type
      switch (type) {
        case 'ions':
          // Ion channel bursts
          const burstPhase = (time + i * 0.1) % 2
          if (burstPhase < 0.1) {
            positions[i3 + 1] += Math.sin(time * 10) * 0.1
            colors[i3 + 1] = 1.0 + Math.sin(time * 20) * 0.5
          }
          break
          
        case 'neurotransmitters':
          // Traveling neurotransmitter packets
          const travelPhase = (time + i * 0.05) % 3
          positions[i3] += Math.sin(travelPhase * Math.PI) * 0.2
          break
          
        case 'data':
          // Data flow patterns
          positions[i3] += Math.sin(time * 2 + i * 0.1) * 0.05
          positions[i3 + 2] += Math.cos(time * 1.5 + i * 0.1) * 0.05
          break
          
        case 'signals':
          // Signal propagation
          const signalPhase = (time + i * 0.02) % 1
          positions[i3 + 1] += signalPhase * 0.3
          if (signalPhase > 0.8) {
            colors[i3] = 1.0
            colors[i3 + 1] = 1.0
            colors[i3 + 2] = 1.0
          }
          break
      }
      
      // Reset particles that go too far
      if (Math.abs(positions[i3]) > 15 || 
          Math.abs(positions[i3 + 1]) > 15 || 
          Math.abs(positions[i3 + 2]) > 15) {
        positions[i3] = (Math.random() - 0.5) * 10
        positions[i3 + 1] = (Math.random() - 0.5) * 10
        positions[i3 + 2] = (Math.random() - 0.5) * 10
      }
    }

    positionAttribute.needsUpdate = true
    colorAttribute.needsUpdate = true
  })

  return (
    <points ref={meshRef} position={position}>
      <primitive object={geometry} />
      <pointsMaterial
        ref={materialRef}
        size={0.1}
        sizeAttenuation={true}
        vertexColors={true}
        transparent={true}
        opacity={0.8}
        blending={THREE.AdditiveBlending}
      />
    </points>
  )
}
