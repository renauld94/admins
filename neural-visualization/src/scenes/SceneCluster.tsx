import React, { useRef, useMemo } from 'react'
import { useFrame } from '@react-three/fiber'
import { Instances, Instance, Text } from '@react-three/drei'
import * as THREE from 'three'
import { ParticleSystem } from '../components/ParticleSystem'

interface SceneClusterProps {
  time: number
  dataIntegration: any
}

interface BrainNode {
  id: string
  position: [number, number, number]
  color: string
  domain: string
  activity: number
}

export function SceneCluster({ time, dataIntegration }: SceneClusterProps) {
  const clusterRef = useRef<THREE.Group>(null)
  const connectionsRef = useRef<THREE.Group>(null)
  const [hoveredNode, setHoveredNode] = React.useState<string | null>(null)

  // Define brain nodes representing different domains
  const brainNodes: BrainNode[] = useMemo(() => [
    {
      id: 'neuroscience',
      position: [0, 0, 0],
      color: '#9966ff',
      domain: 'Neuroscience',
      activity: 0.8
    },
    {
      id: 'data-engineering',
      position: [3, 2, -1],
      color: '#3366ff',
      domain: 'Data Engineering',
      activity: 0.9
    },
    {
      id: 'gis-geoserver',
      position: [-2, 3, 1],
      color: '#33ff66',
      domain: 'GIS/GeoServer',
      activity: 0.7
    },
    {
      id: 'domain-experts',
      position: [1, -2, 2],
      color: '#ff9933',
      domain: 'Domain Experts',
      activity: 0.6
    },
    {
      id: 'machine-learning',
      position: [-3, -1, -2],
      color: '#ff3366',
      domain: 'Machine Learning',
      activity: 0.85
    },
    {
      id: 'cloud-infrastructure',
      position: [2, -3, -1],
      color: '#00ccff',
      domain: 'Cloud Infrastructure',
      activity: 0.75
    },
    {
      id: 'visualization',
      position: [-1, 1, 3],
      color: '#ffcc00',
      domain: 'Visualization',
      activity: 0.8
    },
    {
      id: 'collaboration',
      position: [0, 4, 0],
      color: '#cc66ff',
      domain: 'Collaboration',
      activity: 0.9
    }
  ], [])

  // Create connection lines between nodes
  const connectionGeometry = useMemo(() => {
    const geometry = new THREE.BufferGeometry()
    const positions: number[] = []
    const colors: number[] = []
    
    // Create connections between all nodes
    for (let i = 0; i < brainNodes.length; i++) {
      for (let j = i + 1; j < brainNodes.length; j++) {
        const nodeA = brainNodes[i]
        const nodeB = brainNodes[j]
        
        // Calculate connection strength based on activity
        const strength = (nodeA.activity + nodeB.activity) / 2
        
        // Add curved connection
        const start = new THREE.Vector3(...nodeA.position)
        const end = new THREE.Vector3(...nodeB.position)
        const mid = start.clone().add(end).multiplyScalar(0.5)
        mid.y += 1 // Curve upward
        
        // Create bezier curve points
        const curve = new THREE.QuadraticBezierCurve3(start, mid, end)
        const points = curve.getPoints(20)
        
        for (let k = 0; k < points.length - 1; k++) {
          const p1 = points[k]
          const p2 = points[k + 1]
          
          positions.push(p1.x, p1.y, p1.z)
          positions.push(p2.x, p2.y, p2.z)
          
          // Color based on strength
          const colorIntensity = strength
          colors.push(colorIntensity, colorIntensity * 0.8, colorIntensity * 0.6, 1)
          colors.push(colorIntensity, colorIntensity * 0.8, colorIntensity * 0.6, 1)
        }
      }
    }
    
    geometry.setAttribute('position', new THREE.Float32BufferAttribute(positions, 3))
    geometry.setAttribute('color', new THREE.Float32BufferAttribute(colors, 4))
    
    return geometry
  }, [brainNodes])

  useFrame((state) => {
    const elapsed = time
    
    // Animate cluster rotation
    if (clusterRef.current) {
      clusterRef.current.rotation.y = elapsed * 0.05
      clusterRef.current.rotation.x = Math.sin(elapsed * 0.02) * 0.1
    }
    
    // Animate connections
    if (connectionsRef.current) {
      connectionsRef.current.rotation.y = elapsed * 0.02
    }
  })

  const handleNodeClick = (nodeId: string) => {
    console.log(`Clicked node: ${nodeId}`)
    // In a real implementation, this would open a profile tooltip
    // or load data from MOODLE_STATS_WS
  }

  return (
    <group>
      {/* Main cluster group */}
      <group ref={clusterRef}>
        {/* Brain nodes */}
        <Instances limit={brainNodes.length}>
          <sphereGeometry args={[0.3, 16, 16]} />
          <meshBasicMaterial />
          {brainNodes.map((node, index) => (
            <Instance
              key={node.id}
              position={node.position}
              scale={node.activity * 0.5 + 0.5}
              onClick={() => handleNodeClick(node.id)}
              onPointerOver={() => setHoveredNode(node.id)}
              onPointerOut={() => setHoveredNode(null)}
            >
              <meshBasicMaterial color={node.color} transparent opacity={0.8} />
            </Instance>
          ))}
        </Instances>

        {/* Connection lines */}
        <group ref={connectionsRef}>
          <lineSegments geometry={connectionGeometry}>
            <lineBasicMaterial vertexColors transparent opacity={0.6} />
          </lineSegments>
        </group>

        {/* Central hub (your brain) */}
        <mesh position={[0, 0, 0]}>
          <sphereGeometry args={[0.5, 32, 32]} />
          <meshBasicMaterial color="#00ff88" transparent opacity={0.9} />
        </mesh>

        {/* Knowledge transfer particles */}
        {brainNodes.map((node, index) => (
          <ParticleSystem
            key={`particles-${node.id}`}
            count={100}
            time={time + index * 0.5}
            type="data"
            position={node.position}
          />
        ))}
      </group>

      {/* Hover tooltips */}
      {hoveredNode && (
        <Text
          position={[0, 5, 0]}
          fontSize={0.5}
          color="white"
          anchorX="center"
          anchorY="middle"
        >
          {brainNodes.find(n => n.id === hoveredNode)?.domain}
        </Text>
      )}

      {/* Collaborative intelligence particles */}
      <ParticleSystem
        count={3000}
        time={time}
        type="signals"
        position={[0, 0, 0]}
      />
    </group>
  )
}
