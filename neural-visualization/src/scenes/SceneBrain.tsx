import React, { useRef, useMemo } from 'react'
import { useFrame } from '@react-three/fiber'
import { Instances, Instance } from '@react-three/drei'
import * as THREE from 'three'
import { BrainwaveShader } from '../shaders/BrainwaveShader'
import { ParticleSystem } from '../components/ParticleSystem'

interface SceneBrainProps {
  time: number
  dataIntegration: any
}

export function SceneBrain({ time, dataIntegration }: SceneBrainProps) {
  const brainRef = useRef<THREE.Group>(null)
  const neuronsRef = useRef<THREE.Points>(null)
  const regionsRef = useRef<THREE.Group>(null)

  // Create brain hemisphere geometry
  const brainGeometry = useMemo(() => {
    const geometry = new THREE.SphereGeometry(3, 64, 64)
    
    // Modify to create brain-like shape
    const positions = geometry.attributes.position.array as Float32Array
    for (let i = 0; i < positions.length; i += 3) {
      const x = positions[i]
      const y = positions[i + 1]
      const z = positions[i + 2]
      
      // Create brain-like indentations
      const indent1 = Math.sin(x * 5) * Math.cos(y * 5) * 0.1
      const indent2 = Math.sin(z * 3) * Math.cos(x * 3) * 0.15
      
      positions[i] += indent1
      positions[i + 1] += indent2
      positions[i + 2] += indent1 * 0.5
    }
    
    geometry.attributes.position.needsUpdate = true
    geometry.computeVertexNormals()
    return geometry
  }, [])

  // Create neuron point cloud
  const neuronPositions = useMemo(() => {
    const positions = new Float32Array(100000 * 3) // 100k neurons
    const colors = new Float32Array(100000 * 3)
    
    for (let i = 0; i < 100000; i++) {
      const i3 = i * 3
      
      // Distribute neurons on brain surface with some depth
      const phi = Math.acos(2 * Math.random() - 1)
      const theta = 2 * Math.PI * Math.random()
      const radius = 3 + (Math.random() - 0.5) * 0.5
      
      positions[i3] = radius * Math.sin(phi) * Math.cos(theta)
      positions[i3 + 1] = radius * Math.sin(phi) * Math.sin(theta)
      positions[i3 + 2] = radius * Math.cos(phi)
      
      // Color by brain region
      const region = Math.floor(Math.random() * 4)
      switch (region) {
        case 0: // Frontal (blue)
          colors[i3] = 0.2
          colors[i3 + 1] = 0.4
          colors[i3 + 2] = 1.0
          break
        case 1: // Temporal (purple)
          colors[i3] = 0.6
          colors[i3 + 1] = 0.2
          colors[i3 + 2] = 0.8
          break
        case 2: // Occipital (cyan)
          colors[i3] = 0.0
          colors[i3 + 1] = 0.8
          colors[i3 + 2] = 1.0
          break
        case 3: // Parietal (green)
          colors[i3] = 0.2
          colors[i3 + 1] = 0.8
          colors[i3 + 2] = 0.4
          break
      }
    }
    
    return { positions, colors }
  }, [])

  const neuronGeometry = useMemo(() => {
    const geometry = new THREE.BufferGeometry()
    geometry.setAttribute('position', new THREE.BufferAttribute(neuronPositions.positions, 3))
    geometry.setAttribute('color', new THREE.BufferAttribute(neuronPositions.colors, 3))
    return geometry
  }, [neuronPositions])

  useFrame((state) => {
    const elapsed = time
    
    // Animate brain rotation
    if (brainRef.current) {
      brainRef.current.rotation.y = elapsed * 0.1
      brainRef.current.rotation.x = Math.sin(elapsed * 0.05) * 0.1
    }
    
    // Animate neuron firing patterns
    if (neuronsRef.current) {
      const colors = neuronsRef.current.geometry.attributes.color.array as Float32Array
      
      for (let i = 0; i < 100000; i++) {
        const i3 = i * 3
        const phase = (elapsed + i * 0.001) % 2
        
        // Synchronized firing patterns
        if (phase < 0.1) {
          colors[i3] = Math.min(1.0, colors[i3] + 0.5)
          colors[i3 + 1] = Math.min(1.0, colors[i3 + 1] + 0.5)
          colors[i3 + 2] = Math.min(1.0, colors[i3 + 2] + 0.5)
        } else {
          // Fade back to original
          colors[i3] *= 0.95
          colors[i3 + 1] *= 0.95
          colors[i3 + 2] *= 0.95
        }
      }
      
      neuronsRef.current.geometry.attributes.color.needsUpdate = true
    }
    
    // Animate brain regions
    if (regionsRef.current) {
      regionsRef.current.rotation.y = elapsed * 0.05
    }
  })

  return (
    <group>
      {/* Main brain hemisphere */}
      <group ref={brainRef}>
        <mesh geometry={brainGeometry}>
          <shaderMaterial
            {...BrainwaveShader}
            uniforms={{
              ...BrainwaveShader.uniforms,
              uTime: { value: time },
              uBrainActivity: { value: 0.8 }
            }}
          />
        </mesh>
      </group>

      {/* Neuron point cloud */}
      <points ref={neuronsRef}>
        <bufferGeometry ref={neuronGeometry} />
        <pointsMaterial
          size={0.02}
          sizeAttenuation={true}
          vertexColors={true}
          transparent={true}
          opacity={0.8}
          blending={THREE.AdditiveBlending}
        />
      </points>

      {/* Brain regions visualization */}
      <group ref={regionsRef}>
        {/* Frontal lobe */}
        <mesh position={[0, 2, 1]}>
          <sphereGeometry args={[0.5, 16, 16]} />
          <meshBasicMaterial color="#3366ff" transparent opacity={0.3} />
        </mesh>
        
        {/* Temporal lobe */}
        <mesh position={[-2, 0, 0]}>
          <sphereGeometry args={[0.4, 16, 16]} />
          <meshBasicMaterial color="#9966ff" transparent opacity={0.3} />
        </mesh>
        
        {/* Occipital lobe */}
        <mesh position={[0, -1, -2]}>
          <sphereGeometry args={[0.3, 16, 16]} />
          <meshBasicMaterial color="#00ccff" transparent opacity={0.3} />
        </mesh>
        
        {/* Parietal lobe */}
        <mesh position={[2, 1, 0]}>
          <sphereGeometry args={[0.4, 16, 16]} />
          <meshBasicMaterial color="#33ff66" transparent opacity={0.3} />
        </mesh>
      </group>

      {/* Brainwave ripple effects */}
      <Instances limit={50}>
        <ringGeometry args={[0.1, 0.2, 16]} />
        <meshBasicMaterial color="#00ff88" transparent opacity={0.5} />
        {Array.from({ length: 50 }).map((_, i) => (
          <Instance
            key={i}
            position={[
              (Math.random() - 0.5) * 6,
              (Math.random() - 0.5) * 6,
              (Math.random() - 0.5) * 6
            ]}
            scale={Math.sin(time * 2 + i * 0.1) * 0.5 + 1}
          />
        ))}
      </Instances>

      {/* Neural activity particles */}
      <ParticleSystem
        count={2000}
        time={time}
        type="neurotransmitters"
        position={[0, 0, 0]}
      />
    </group>
  )
}
