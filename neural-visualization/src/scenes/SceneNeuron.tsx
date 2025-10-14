import React, { useRef, useMemo } from 'react'
import { useFrame } from '@react-three/fiber'
import { Instances, Instance } from '@react-three/drei'
import * as THREE from 'three'
import { NeuralFiringShader } from '../shaders/NeuralFiringShader'
import { ParticleSystem } from '../components/ParticleSystem'

interface SceneNeuronProps {
  time: number
  dataIntegration: any
  zoomLevel?: number
}

export function SceneNeuron({ time, dataIntegration, zoomLevel = 1 }: SceneNeuronProps) {
  const neuronRef = useRef<THREE.Group>(null)
  const dendritesRef = useRef<THREE.Group>(null)
  const axonRef = useRef<THREE.Group>(null)
  const synapseRef = useRef<THREE.Group>(null)
  const brainHemisphereRef = useRef<THREE.Group>(null)
  const neuralNetworkRef = useRef<THREE.Group>(null)

  // Create brain hemisphere geometry
  const brainGeometry = useMemo(() => {
    const geometry = new THREE.SphereGeometry(3, 64, 64)
    
    // Deform to create brain-like shape
    const positions = geometry.attributes.position.array as Float32Array
    for (let i = 0; i < positions.length; i += 3) {
      const x = positions[i]
      const y = positions[i + 1]
      const z = positions[i + 2]
      
      // Create brain-like folds
      const fold1 = Math.sin(x * 8) * Math.cos(y * 8) * 0.1
      const fold2 = Math.sin(z * 6) * Math.cos(x * 6) * 0.08
      const fold3 = Math.sin(y * 10) * Math.cos(z * 10) * 0.06
      
      positions[i] += fold1
      positions[i + 1] += fold2
      positions[i + 2] += fold3
    }
    
    geometry.attributes.position.needsUpdate = true
    geometry.computeVertexNormals()
    return geometry
  }, [])

  // Create neuron geometry
  const neuronGeometry = useMemo(() => {
    const geometry = new THREE.SphereGeometry(0.5, 32, 32)
    
    // Add organic deformation
    const positions = geometry.attributes.position.array as Float32Array
    for (let i = 0; i < positions.length; i += 3) {
      const x = positions[i]
      const y = positions[i + 1]
      const z = positions[i + 2]
      
      // Add noise for organic shape
      const noise = Math.sin(x * 10) * Math.cos(y * 10) * Math.sin(z * 10) * 0.1
      positions[i + 1] += noise
    }
    
    geometry.attributes.position.needsUpdate = true
    geometry.computeVertexNormals()
    return geometry
  }, [])

  // Create dendrite geometry using L-system
  const dendriteGeometry = useMemo(() => {
    const geometry = new THREE.BufferGeometry()
    const positions: number[] = []
    const colors: number[] = []
    
    // L-system for fractal dendrites
    const generateDendrite = (start: THREE.Vector3, direction: THREE.Vector3, length: number, depth: number) => {
      if (depth <= 0) return
      
      const end = start.clone().add(direction.clone().multiplyScalar(length))
      
      // Add segment
      positions.push(start.x, start.y, start.z)
      positions.push(end.x, end.y, end.z)
      
      // Color gradient
      const intensity = depth / 5
      colors.push(intensity, intensity * 0.8, intensity * 0.6, 1)
      colors.push(intensity * 0.8, intensity * 0.6, intensity * 0.4, 1)
      
      // Branch recursively
      if (depth > 1) {
        const branchCount = Math.floor(Math.random() * 3) + 1
        for (let i = 0; i < branchCount; i++) {
          const angle = (Math.PI * 2 * i) / branchCount + Math.random() * 0.5
          const newDirection = direction.clone().applyAxisAngle(new THREE.Vector3(0, 1, 0), angle)
          generateDendrite(end, newDirection, length * 0.7, depth - 1)
        }
      }
    }
    
    // Generate multiple dendrites
    for (let i = 0; i < 8; i++) {
      const angle = (Math.PI * 2 * i) / 8
      const direction = new THREE.Vector3(Math.cos(angle), Math.random() * 0.5 - 0.25, Math.sin(angle))
      generateDendrite(new THREE.Vector3(0, 0, 0), direction, 1.5, 4)
    }
    
    geometry.setAttribute('position', new THREE.Float32BufferAttribute(positions, 3))
    geometry.setAttribute('color', new THREE.Float32BufferAttribute(colors, 4))
    
    return geometry
  }, [])

  // Create axon geometry
  const axonGeometry = useMemo(() => {
    const geometry = new THREE.CylinderGeometry(0.05, 0.1, 3, 8)
    return geometry
  }, [])

  useFrame((state) => {
    const elapsed = time
    
    // Apply zoom scaling to all elements
    const scale = Math.max(0.1, zoomLevel)
    
    // Animate brain hemisphere
    if (brainHemisphereRef.current) {
      brainHemisphereRef.current.rotation.y = elapsed * 0.02
      brainHemisphereRef.current.scale.setScalar(scale)
    }
    
    // Animate neuron membrane
    if (neuronRef.current) {
      neuronRef.current.rotation.y = elapsed * 0.1
      neuronRef.current.scale.setScalar(scale * (1 + Math.sin(elapsed * 2) * 0.05))
    }
    
    // Animate dendrites
    if (dendritesRef.current) {
      dendritesRef.current.rotation.y = elapsed * 0.05
      dendritesRef.current.scale.setScalar(scale)
    }
    
    // Animate axon with traveling impulse
    if (axonRef.current) {
      axonRef.current.rotation.z = elapsed * 0.2
      const impulsePosition = (elapsed % 2) / 2 // 0 to 1 over 2 seconds
      axonRef.current.position.z = (impulsePosition * 3 - 1.5) * scale
      axonRef.current.scale.setScalar(scale)
    }
    
    // Animate synaptic cleft
    if (synapseRef.current) {
      synapseRef.current.rotation.x = elapsed * 0.3
      synapseRef.current.scale.setScalar(scale * (1 + Math.sin(elapsed * 5) * 0.2))
    }
    
    // Animate neural network connections
    if (neuralNetworkRef.current) {
      neuralNetworkRef.current.rotation.y = elapsed * 0.03
      neuralNetworkRef.current.scale.setScalar(scale)
    }
  })

  return (
    <group>
      {/* Brain Hemisphere Background */}
      <group ref={brainHemisphereRef}>
        <mesh geometry={brainGeometry}>
          <meshPhongMaterial 
            color={0x1e40af} 
            transparent 
            opacity={0.3}
            shininess={100}
          />
        </mesh>
        
        {/* Brain surface details */}
        <mesh geometry={brainGeometry}>
          <meshBasicMaterial 
            color={0x3b82f6} 
            transparent 
            opacity={0.1}
            wireframe
          />
        </mesh>
      </group>

      {/* Neural Network Connections */}
      <group ref={neuralNetworkRef}>
        {Array.from({ length: 50 }, (_, i) => {
          const startPos = new THREE.Vector3(
            (Math.random() - 0.5) * 6,
            (Math.random() - 0.5) * 6,
            (Math.random() - 0.5) * 6
          )
          const endPos = new THREE.Vector3(
            (Math.random() - 0.5) * 6,
            (Math.random() - 0.5) * 6,
            (Math.random() - 0.5) * 6
          )
          
          return (
            <line key={i}>
              <bufferGeometry>
                <bufferAttribute
                  attach="attributes-position"
                  count={2}
                  array={new Float32Array([
                    startPos.x, startPos.y, startPos.z,
                    endPos.x, endPos.y, endPos.z
                  ])}
                  itemSize={3}
                />
              </bufferGeometry>
              <lineBasicMaterial 
                color={0x00ff88} 
                transparent 
                opacity={0.3 + Math.sin(time * 2 + i * 0.1) * 0.2}
              />
            </line>
          )
        })}
      </group>

      {/* Main neuron soma */}
      <group ref={neuronRef}>
        <mesh geometry={neuronGeometry}>
          <shaderMaterial
            {...NeuralFiringShader}
            uniforms={{
              ...NeuralFiringShader.uniforms,
              uTime: { value: time },
              uIntensity: { value: 1.0 }
            }}
          />
        </mesh>
      </group>

      {/* Dendrites */}
      <group ref={dendritesRef}>
        <lineSegments geometry={dendriteGeometry}>
          <lineBasicMaterial vertexColors transparent opacity={0.8} />
        </lineSegments>
      </group>

      {/* Axon */}
      <group ref={axonRef}>
        <mesh geometry={axonGeometry} position={[0, 0, 0]}>
          <meshBasicMaterial color="#00ff88" transparent opacity={0.7} />
        </mesh>
      </group>

      {/* Synaptic cleft */}
      <group ref={synapseRef} position={[0, 0, 2]}>
        <mesh>
          <sphereGeometry args={[0.2, 16, 16]} />
          <meshBasicMaterial color="#ff0088" transparent opacity={0.6} />
        </mesh>
      </group>

      {/* Mitochondria */}
      <Instances limit={20}>
        <sphereGeometry args={[0.1, 8, 8]} />
        <meshBasicMaterial color="#ffff00" transparent opacity={0.8} />
        {Array.from({ length: 20 }).map((_, i) => (
          <Instance
            key={i}
            position={[
              (Math.random() - 0.5) * 2,
              (Math.random() - 0.5) * 2,
              (Math.random() - 0.5) * 2
            ]}
            scale={Math.random() * 0.5 + 0.5}
          />
        ))}
      </Instances>

      {/* Ion particle system */}
      <ParticleSystem
        count={1000}
        time={time}
        type="ions"
        position={[0, 0, 0]}
      />
    </group>
  )
}
