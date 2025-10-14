import React, { useRef, useEffect, useState, useMemo } from 'react'
import { useFrame } from '@react-three/fiber'
import * as THREE from 'three'
import { ParticleSystem } from '../components/ParticleSystem'
import { InfrastructureNetwork } from '../components/InfrastructureNetwork'

interface SceneGeoNeuralProps {
  time: number
  playbackSpeed: number
  zoomLevel?: number
  geoserverData?: any
  neuralData?: any
}

export function SceneGeoNeural({ time, playbackSpeed, zoomLevel = 1, geoserverData, neuralData }: SceneGeoNeuralProps) {
  const earthRef = useRef<THREE.Group>(null)
  const neuralNetworkRef = useRef<THREE.Group>(null)
  const dataFlowRef = useRef<THREE.Group>(null)
  const cityRef = useRef<THREE.Group>(null)
  
  // Enhanced Earth with neural activity overlay
  const earthGeometry = useMemo(() => new THREE.SphereGeometry(2, 64, 64), [])
  const earthMaterial = useMemo(() => new THREE.MeshPhongMaterial({
    color: 0x2563eb,
    shininess: 100,
    transparent: true,
    opacity: 0.8
  }), [])

  // Neural activity heatmap material
  const neuralHeatmapMaterial = useMemo(() => new THREE.ShaderMaterial({
    uniforms: {
      time: { value: 0 },
      neuralData: { value: null },
      intensity: { value: 1.0 }
    },
    vertexShader: `
      varying vec2 vUv;
      varying vec3 vPosition;
      void main() {
        vUv = uv;
        vPosition = position;
        gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
      }
    `,
    fragmentShader: `
      uniform float time;
      uniform float intensity;
      varying vec2 vUv;
      varying vec3 vPosition;
      
      void main() {
        // Create neural activity patterns
        float neuralPattern = sin(vUv.x * 20.0 + time) * cos(vUv.y * 15.0 + time * 0.7);
        neuralPattern += sin(vUv.x * 30.0 + time * 1.3) * cos(vUv.y * 25.0 + time * 0.5);
        
        // Create heatmap effect
        float heat = abs(neuralPattern) * intensity;
        vec3 heatColor = mix(vec3(0.0, 0.2, 0.8), vec3(1.0, 0.0, 0.0), heat);
        
        // Add pulsing effect
        float pulse = sin(time * 2.0) * 0.3 + 0.7;
        heatColor *= pulse;
        
        gl_FragColor = vec4(heatColor, heat * 0.8);
      }
    `,
    transparent: true,
    blending: THREE.AdditiveBlending
  }), [])

  // City buildings geometry
  const cityBuildings = useMemo(() => {
    const buildings = []
    if (geoserverData?.buildings) {
      geoserverData.buildings.forEach((building: any, index: number) => {
        const geometry = new THREE.BoxGeometry(0.02, building.height / 100, 0.02)
        const material = new THREE.MeshPhongMaterial({
          color: building.type === 'residential' ? 0x4f46e5 : 
                 building.type === 'commercial' ? 0x059669 : 0xdc2626
        })
        buildings.push({ geometry, material, position: [building.lon, building.height / 200, building.lat] })
      })
    }
    return buildings
  }, [geoserverData])

  // Neural data points
  const neuralPoints = useMemo(() => {
    const points = []
    if (neuralData?.neural_data) {
      neuralData.neural_data.forEach((point: any, index: number) => {
        points.push({
          position: [point.lon, 0, point.lat],
          activity: point.neural_activity,
          timestamp: point.timestamp
        })
      })
    }
    return points
  }, [neuralData])

  // Global data network connections
  const networkConnections = useMemo(() => {
    const connections = []
    const cities = [
      { name: 'New York', lat: 40.7128, lon: -74.0060 },
      { name: 'London', lat: 51.5074, lon: -0.1278 },
      { name: 'Tokyo', lat: 35.6762, lon: 139.6503 },
      { name: 'Sydney', lat: -33.8688, lon: 151.2093 },
      { name: 'Berlin', lat: 52.5200, lon: 13.4050 }
    ]

    cities.forEach((city, index) => {
      const nextCity = cities[(index + 1) % cities.length]
      connections.push({
        start: [city.lon / 90, 0, city.lat / 90],
        end: [nextCity.lon / 90, 0, nextCity.lat / 90],
        intensity: Math.random() * 0.8 + 0.2
      })
    })
    return connections
  }, [])

  useFrame((state) => {
    const elapsedTime = time * playbackSpeed
    const scale = Math.max(0.1, zoomLevel)

    // Earth rotation with neural activity
    if (earthRef.current) {
      earthRef.current.rotation.y = elapsedTime * 0.02
      earthRef.current.scale.setScalar(scale)
    }

    // Neural heatmap animation
    if (neuralHeatmapMaterial) {
      neuralHeatmapMaterial.uniforms.time.value = elapsedTime
      neuralHeatmapMaterial.uniforms.intensity.value = Math.sin(elapsedTime * 0.5) * 0.5 + 0.5
    }

    // Neural network pulsing
    if (neuralNetworkRef.current) {
      neuralNetworkRef.current.children.forEach((child, index) => {
        if (child instanceof THREE.Mesh) {
          const pulse = Math.sin(elapsedTime * 2 + index * 0.5) * 0.1 + 1
          child.scale.setScalar(pulse * scale)
        }
      })
    }

    // Data flow animation
    if (dataFlowRef.current) {
      dataFlowRef.current.children.forEach((child, index) => {
        if (child instanceof THREE.Line) {
          const material = child.material as THREE.LineBasicMaterial
          material.opacity = Math.sin(elapsedTime * 3 + index * 0.3) * 0.5 + 0.5
        }
      })
    }

    // City buildings animation
    if (cityRef.current) {
      cityRef.current.children.forEach((child, index) => {
        if (child instanceof THREE.Mesh) {
          child.rotation.y = elapsedTime * 0.01
          const height = Math.sin(elapsedTime * 0.5 + index * 0.2) * 0.1 + 1
          child.scale.y = height * scale
        }
      })
    }
  })

  return (
    <group>
      {/* Enhanced Earth with Neural Activity */}
      <group ref={earthRef}>
        <mesh geometry={earthGeometry} material={earthMaterial}>
          {/* Earth surface details */}
          <mesh position={[0, 0, 2.01]}>
            <planeGeometry args={[4, 4]} />
            <meshBasicMaterial color={0x1e40af} transparent opacity={0.3} />
          </mesh>
        </mesh>

        {/* Neural Activity Heatmap Overlay */}
        <mesh geometry={earthGeometry}>
          <primitive object={neuralHeatmapMaterial} />
        </mesh>

        {/* Atmospheric glow */}
        <mesh geometry={new THREE.SphereGeometry(2.1, 32, 32)}>
          <meshBasicMaterial 
            color={0x3b82f6} 
            transparent 
            opacity={0.1} 
            side={THREE.BackSide}
          />
        </mesh>
      </group>

      {/* Neural Data Points */}
      <group ref={neuralNetworkRef}>
        {neuralPoints.map((point, index) => (
          <mesh key={index} position={point.position}>
            <sphereGeometry args={[0.05, 16, 16]} />
            <meshBasicMaterial 
              color={new THREE.Color().setHSL(point.activity, 1, 0.5)}
              transparent
              opacity={0.8}
            />
          </mesh>
        ))}
      </group>

      {/* Global Data Network */}
      <group ref={dataFlowRef}>
        {networkConnections.map((connection, index) => (
          <line key={index}>
            <bufferGeometry>
              <bufferAttribute
                attach="attributes-position"
                count={2}
                array={new Float32Array([
                  ...connection.start,
                  ...connection.end
                ])}
                itemSize={3}
              />
            </bufferGeometry>
            <lineBasicMaterial 
              color={0x00ff88} 
              transparent 
              opacity={connection.intensity}
              linewidth={2}
            />
          </line>
        ))}
      </group>

      {/* Procedural City Buildings */}
      <group ref={cityRef}>
        {cityBuildings.map((building, index) => (
          <mesh 
            key={index} 
            geometry={building.geometry} 
            material={building.material}
            position={building.position}
          />
        ))}
      </group>

      {/* Enhanced Particle Systems */}
      <ParticleSystem 
        count={300} 
        time={time} 
        type="neural" 
        position={[0, 0, 0]} 
      />
      
      <ParticleSystem 
        count={200} 
        time={time} 
        type="data" 
        position={[0, 0, 0]} 
      />

      {/* Global Infrastructure Network */}
      <InfrastructureNetwork time={time} zoomLevel={zoomLevel} />

      {/* GeoServer Data Integration */}
      {geoserverData && (
        <group>
          {/* Render GeoServer layers */}
          {geoserverData.roads?.map((road: any, index: number) => (
            <line key={`road-${index}`}>
              <bufferGeometry>
                <bufferAttribute
                  attach="attributes-position"
                  count={2}
                  array={new Float32Array([
                    road.lon - 0.001, 0, road.lat - 0.001,
                    road.lon + 0.001, 0, road.lat + 0.001
                  ])}
                  itemSize={3}
                />
              </bufferGeometry>
              <lineBasicMaterial color={0x666666} linewidth={1} />
            </line>
          ))}

          {geoserverData.pois?.map((poi: any, index: number) => (
            <mesh key={`poi-${index}`} position={[poi.lon, 0.1, poi.lat]}>
              <coneGeometry args={[0.02, 0.1, 8]} />
              <meshPhongMaterial 
                color={poi.category === 'food' ? 0xff6b6b : 
                       poi.category === 'recreation' ? 0x4ecdc4 : 0xffd93d}
              />
            </mesh>
          ))}
        </group>
      )}
    </group>
  )
}
