import React, { useRef, useMemo } from 'react'
import { useFrame } from '@react-three/fiber'
import * as THREE from 'three'

interface InfrastructureNetworkProps {
  time: number
  zoomLevel?: number
}

export function InfrastructureNetwork({ time, zoomLevel = 1 }: InfrastructureNetworkProps) {
  const networkRef = useRef<THREE.Group>(null)
  const dataFlowRef = useRef<THREE.Group>(null)

  // Create infrastructure nodes
  const infrastructureNodes = useMemo(() => {
    const nodes = []
    
    // Major data centers around the globe
    const dataCenters = [
      { pos: [4, 0, 0], type: 'datacenter', size: 0.3 },
      { pos: [-4, 0, 0], type: 'datacenter', size: 0.3 },
      { pos: [0, 4, 0], type: 'datacenter', size: 0.3 },
      { pos: [0, -4, 0], type: 'datacenter', size: 0.3 },
      { pos: [2.8, 2.8, 0], type: 'datacenter', size: 0.25 },
      { pos: [-2.8, 2.8, 0], type: 'datacenter', size: 0.25 },
      { pos: [2.8, -2.8, 0], type: 'datacenter', size: 0.25 },
      { pos: [-2.8, -2.8, 0], type: 'datacenter', size: 0.25 },
    ]
    
    // Edge computing nodes
    const edgeNodes = []
    for (let i = 0; i < 20; i++) {
      const angle = (i / 20) * Math.PI * 2
      const radius = 6 + Math.random() * 2
      edgeNodes.push({
        pos: [Math.cos(angle) * radius, Math.sin(angle) * radius, (Math.random() - 0.5) * 2],
        type: 'edge',
        size: 0.1
      })
    }
    
    // IoT sensors
    const iotSensors = []
    for (let i = 0; i < 50; i++) {
      iotSensors.push({
        pos: [
          (Math.random() - 0.5) * 12,
          (Math.random() - 0.5) * 12,
          (Math.random() - 0.5) * 4
        ],
        type: 'sensor',
        size: 0.05
      })
    }
    
    return [...dataCenters, ...edgeNodes, ...iotSensors]
  }, [])

  // Create network connections
  const networkConnections = useMemo(() => {
    const connections = []
    
    // Connect data centers
    for (let i = 0; i < 8; i++) {
      for (let j = i + 1; j < 8; j++) {
        const node1 = infrastructureNodes[i]
        const node2 = infrastructureNodes[j]
        if (node1 && node2) {
          connections.push({
            start: node1.pos,
            end: node2.pos,
            type: 'backbone',
            intensity: 0.8
          })
        }
      }
    }
    
    // Connect edge nodes to nearest data centers
    for (let i = 8; i < 28; i++) {
      const edgeNode = infrastructureNodes[i]
      if (edgeNode) {
        // Find nearest data center
        let nearestDistance = Infinity
        let nearestIndex = 0
        for (let j = 0; j < 8; j++) {
          const dataCenter = infrastructureNodes[j]
          if (dataCenter) {
            const distance = Math.sqrt(
              Math.pow(edgeNode.pos[0] - dataCenter.pos[0], 2) +
              Math.pow(edgeNode.pos[1] - dataCenter.pos[1], 2) +
              Math.pow(edgeNode.pos[2] - dataCenter.pos[2], 2)
            )
            if (distance < nearestDistance) {
              nearestDistance = distance
              nearestIndex = j
            }
          }
        }
        
        const dataCenter = infrastructureNodes[nearestIndex]
        if (dataCenter) {
          connections.push({
            start: edgeNode.pos,
            end: dataCenter.pos,
            type: 'edge',
            intensity: 0.4
          })
        }
      }
    }
    
    return connections
  }, [infrastructureNodes])

  useFrame(() => {
    const elapsedTime = time
    
    // Animate network nodes
    if (networkRef.current) {
      networkRef.current.children.forEach((child, index) => {
        if (child instanceof THREE.Mesh) {
          const node = infrastructureNodes[index]
          if (node) {
            // Pulse animation based on node type
            let pulseSpeed = 1
            let pulseIntensity = 0.1
            
            switch (node.type) {
              case 'datacenter':
                pulseSpeed = 0.5
                pulseIntensity = 0.2
                break
              case 'edge':
                pulseSpeed = 1.5
                pulseIntensity = 0.15
                break
              case 'sensor':
                pulseSpeed = 3
                pulseIntensity = 0.05
                break
            }
            
            const scale = 1 + Math.sin(elapsedTime * pulseSpeed + index * 0.1) * pulseIntensity
            child.scale.setScalar(scale * zoomLevel)
          }
        }
      })
    }
    
    // Animate data flow
    if (dataFlowRef.current) {
      dataFlowRef.current.children.forEach((child, index) => {
        if (child instanceof THREE.Line) {
          const connection = networkConnections[index]
          if (connection) {
            // Animate data flow along connections
            const flowPhase = (elapsedTime * 2 + index * 0.1) % 1
            child.material.opacity = connection.intensity * (0.3 + Math.sin(flowPhase * Math.PI) * 0.7)
          }
        }
      })
    }
  })

  return (
    <group>
      {/* Infrastructure Nodes */}
      <group ref={networkRef}>
        {infrastructureNodes.map((node, index) => {
          let color = 0x00ff88 // Default green
          switch (node.type) {
            case 'datacenter':
              color = 0x3b82f6 // Blue
              break
            case 'edge':
              color = 0xf59e0b // Orange
              break
            case 'sensor':
              color = 0x10b981 // Green
              break
          }
          
          return (
            <mesh key={index} position={node.pos}>
              <sphereGeometry args={[node.size, 8, 8]} />
              <meshBasicMaterial 
                color={color} 
                transparent 
                opacity={0.8}
              />
            </mesh>
          )
        })}
      </group>
      
      {/* Network Connections */}
      <group ref={dataFlowRef}>
        {networkConnections.map((connection, index) => {
          let color = 0x00ff88
          let width = 1
          
          switch (connection.type) {
            case 'backbone':
              color = 0x3b82f6
              width = 3
              break
            case 'edge':
              color = 0xf59e0b
              width = 2
              break
          }
          
          return (
            <line key={index}>
              <bufferGeometry>
                <bufferAttribute
                  attach="attributes-position"
                  count={2}
                  array={new Float32Array([
                    connection.start[0], connection.start[1], connection.start[2],
                    connection.end[0], connection.end[1], connection.end[2]
                  ])}
                  itemSize={3}
                />
              </bufferGeometry>
              <lineBasicMaterial 
                color={color} 
                transparent 
                opacity={connection.intensity}
                linewidth={width}
              />
            </line>
          )
        })}
      </group>
      
      {/* Data Flow Particles */}
      {networkConnections.map((connection, index) => {
        const flowPhase = (time * 2 + index * 0.1) % 1
        const t = flowPhase
        const x = connection.start[0] + (connection.end[0] - connection.start[0]) * t
        const y = connection.start[1] + (connection.end[1] - connection.start[1]) * t
        const z = connection.start[2] + (connection.end[2] - connection.start[2]) * t
        
        return (
          <mesh key={`particle-${index}`} position={[x, y, z]}>
            <sphereGeometry args={[0.02, 4, 4]} />
            <meshBasicMaterial 
              color={0xffffff} 
              transparent 
              opacity={0.8}
            />
          </mesh>
        )
      })}
    </group>
  )
}
