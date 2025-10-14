import React, { useRef, useMemo } from 'react'
import { useFrame } from '@react-three/fiber'
import { Instances, Instance } from '@react-three/drei'
import * as THREE from 'three'
import { ParticleSystem } from '../components/ParticleSystem'

interface SceneOrbitProps {
  time: number
  dataIntegration: any
}

interface Satellite {
  id: string
  orbitRadius: number
  orbitSpeed: number
  color: string
  service: string
  health: 'green' | 'yellow' | 'red'
  cpuUsage: number
}

export function SceneOrbit({ time, dataIntegration }: SceneOrbitProps) {
  const orbitRef = useRef<THREE.Group>(null)
  const earthRef = useRef<THREE.Group>(null)
  const satellitesRef = useRef<THREE.Group>(null)

  // Define satellites representing different services
  const satellites: Satellite[] = useMemo(() => [
    {
      id: 'proxmox-vm1',
      orbitRadius: 3.5,
      orbitSpeed: 0.02,
      color: '#00ff88',
      service: 'Proxmox VM',
      health: 'green',
      cpuUsage: 0.7
    },
    {
      id: 'proxmox-vm2',
      orbitRadius: 3.8,
      orbitSpeed: 0.015,
      color: '#00ff88',
      service: 'Proxmox VM',
      health: 'green',
      cpuUsage: 0.5
    },
    {
      id: 'geoserver-wms',
      orbitRadius: 4.2,
      orbitSpeed: 0.025,
      color: '#3366ff',
      service: 'WMS',
      health: 'green',
      cpuUsage: 0.6
    },
    {
      id: 'geoserver-wfs',
      orbitRadius: 4.5,
      orbitSpeed: 0.018,
      color: '#33ff66',
      service: 'WFS',
      health: 'green',
      cpuUsage: 0.4
    },
    {
      id: 'geoserver-wcs',
      orbitRadius: 4.8,
      orbitSpeed: 0.022,
      color: '#00ccff',
      service: 'WCS',
      health: 'yellow',
      cpuUsage: 0.8
    },
    {
      id: 'geoserver-wps',
      orbitRadius: 5.1,
      orbitSpeed: 0.012,
      color: '#ff9933',
      service: 'WPS',
      health: 'green',
      cpuUsage: 0.3
    },
    {
      id: 'postgis-moon',
      orbitRadius: 6.0,
      orbitSpeed: 0.008,
      color: '#ffffff',
      service: 'PostGIS',
      health: 'green',
      cpuUsage: 0.9
    },
    {
      id: 'moodle-relay1',
      orbitRadius: 3.2,
      orbitSpeed: 0.03,
      color: '#ff3366',
      service: 'Moodle',
      health: 'green',
      cpuUsage: 0.5
    },
    {
      id: 'moodle-relay2',
      orbitRadius: 3.9,
      orbitSpeed: 0.028,
      color: '#ff3366',
      service: 'Moodle',
      health: 'green',
      cpuUsage: 0.4
    },
    {
      id: 'backup-satellite',
      orbitRadius: 7.0,
      orbitSpeed: 0.005,
      color: '#666666',
      service: 'Backup',
      health: 'yellow',
      cpuUsage: 0.2
    }
  ], [])

  // Create Earth geometry
  const earthGeometry = useMemo(() => {
    return new THREE.SphereGeometry(2, 64, 32)
  }, [])

  // Create satellite geometries
  const satelliteGeometries = useMemo(() => ({
    octahedron: new THREE.OctahedronGeometry(0.1),
    sphere: new THREE.SphereGeometry(0.08, 16, 16),
    icosahedron: new THREE.IcosahedronGeometry(0.1),
    dodecahedron: new THREE.DodecahedronGeometry(0.1)
  }), [])

  // Calculate satellite positions
  const getSatellitePosition = (satellite: Satellite, time: number): [number, number, number] => {
    const angle = time * satellite.orbitSpeed
    const x = Math.cos(angle) * satellite.orbitRadius
    const z = Math.sin(angle) * satellite.orbitRadius
    const y = Math.sin(angle * 0.5) * 0.5 // Slight vertical oscillation
    
    return [x, y, z]
  }

  // Get satellite geometry based on service type
  const getSatelliteGeometry = (service: string) => {
    switch (service) {
      case 'WMS': return satelliteGeometries.sphere
      case 'WFS': return satelliteGeometries.octahedron
      case 'WCS': return satelliteGeometries.icosahedron
      case 'WPS': return satelliteGeometries.dodecahedron
      case 'PostGIS': return satelliteGeometries.sphere
      default: return satelliteGeometries.octahedron
    }
  }

  // Get health color
  const getHealthColor = (health: string) => {
    switch (health) {
      case 'green': return '#00ff00'
      case 'yellow': return '#ffff00'
      case 'red': return '#ff0000'
      default: return '#ffffff'
    }
  }

  useFrame((state) => {
    const elapsed = time
    
    // Animate Earth rotation
    if (earthRef.current) {
      earthRef.current.rotation.y = elapsed * 0.01
    }
    
    // Animate orbit group
    if (orbitRef.current) {
      orbitRef.current.rotation.y = elapsed * 0.005
    }
  })

  return (
    <group>
      {/* Earth */}
      <group ref={earthRef}>
        <mesh geometry={earthGeometry}>
          <meshBasicMaterial color="#2a4a6b" />
        </mesh>
      </group>

      {/* Orbital infrastructure */}
      <group ref={orbitRef}>
        {/* Satellites */}
        <group ref={satellitesRef}>
          {satellites.map((satellite, index) => {
            const position = getSatellitePosition(satellite, time)
            const geometry = getSatelliteGeometry(satellite.service)
            const healthColor = getHealthColor(satellite.health)
            
            return (
              <group key={satellite.id} position={position}>
                {/* Main satellite */}
                <mesh geometry={geometry}>
                  <meshBasicMaterial 
                    color={satellite.color} 
                    transparent 
                    opacity={0.9}
                  />
                </mesh>
                
                {/* Health indicator */}
                <mesh position={[0, 0.2, 0]}>
                  <sphereGeometry args={[0.02, 8, 8]} />
                  <meshBasicMaterial color={healthColor} />
                </mesh>
                
                {/* Solar panels */}
                <mesh position={[0.15, 0, 0]} rotation={[0, 0, Math.PI / 4]}>
                  <boxGeometry args={[0.1, 0.05, 0.2]} />
                  <meshBasicMaterial color="#ffff00" transparent opacity={0.8} />
                </mesh>
                <mesh position={[-0.15, 0, 0]} rotation={[0, 0, -Math.PI / 4]}>
                  <boxGeometry args={[0.1, 0.05, 0.2]} />
                  <meshBasicMaterial color="#ffff00" transparent opacity={0.8} />
                </mesh>
                
                {/* Thruster bursts */}
                {satellite.cpuUsage > 0.7 && (
                  <mesh position={[0, 0, -0.15]}>
                    <coneGeometry args={[0.02, 0.1, 8]} />
                    <meshBasicMaterial color="#ff4400" transparent opacity={0.6} />
                  </mesh>
                )}
              </group>
            )
          })}
        </group>

        {/* Orbital paths */}
        {satellites.map((satellite, index) => (
          <mesh key={`orbit-${satellite.id}`} rotation={[Math.PI / 2, 0, 0]}>
            <torusGeometry args={[satellite.orbitRadius, 0.01, 8, 100]} />
            <meshBasicMaterial color="#333333" transparent opacity={0.3} />
          </mesh>
        ))}

        {/* Signal beams */}
        {satellites.map((satellite, index) => {
          const position = getSatellitePosition(satellite, time)
          const beamIntensity = satellite.cpuUsage
          
          return (
            <mesh key={`beam-${satellite.id}`} position={position}>
              <cylinderGeometry args={[0.01, 0.05, 2, 8]} />
              <meshBasicMaterial 
                color="#00ff88" 
                transparent 
                opacity={beamIntensity * 0.5}
              />
            </mesh>
          )
        })}

        {/* Satellite-to-satellite connections */}
        <Instances limit={50}>
          <cylinderGeometry args={[0.005, 0.005, 1, 8]} />
          <meshBasicMaterial color="#00ccff" transparent opacity={0.4} />
          {Array.from({ length: 50 }).map((_, i) => {
            const angle1 = (i * 0.1) % (Math.PI * 2)
            const angle2 = ((i + 25) * 0.1) % (Math.PI * 2)
            const radius1 = 3.5 + (i % 3) * 0.5
            const radius2 = 3.5 + ((i + 1) % 3) * 0.5
            
            const pos1 = [
              Math.cos(angle1) * radius1,
              Math.sin(angle1 * 0.5) * 0.5,
              Math.sin(angle1) * radius1
            ]
            
            const pos2 = [
              Math.cos(angle2) * radius2,
              Math.sin(angle2 * 0.5) * 0.5,
              Math.sin(angle2) * radius2
            ]
            
            const mid = [
              (pos1[0] + pos2[0]) / 2,
              (pos1[1] + pos2[1]) / 2,
              (pos1[2] + pos2[2]) / 2
            ]
            
            return (
              <Instance
                key={i}
                position={mid as [number, number, number]}
                scale={[1, 1, Math.sin(time * 2 + i * 0.1) * 0.5 + 1]}
              />
            )
          })}
        </Instances>
      </group>

      {/* Telemetry particles */}
      {satellites.map((satellite, index) => (
        <ParticleSystem
          key={`telemetry-${satellite.id}`}
          count={50}
          time={time + index * 0.2}
          type="signals"
          position={getSatellitePosition(satellite, time)}
        />
      ))}

      {/* Cache hit flashes */}
      <Instances limit={100}>
        <sphereGeometry args={[0.05, 8, 8]} />
        <meshBasicMaterial color="#ffffff" transparent opacity={0.8} />
        {Array.from({ length: 100 }).map((_, i) => (
          <Instance
            key={i}
            position={[
              (Math.random() - 0.5) * 10,
              (Math.random() - 0.5) * 10,
              (Math.random() - 0.5) * 10
            ]}
            scale={Math.sin(time * 10 + i * 0.1) > 0.9 ? 2 : 0}
          />
        ))}
      </Instances>

      {/* Slow query pulses */}
      <Instances limit={20}>
        <ringGeometry args={[0.1, 0.2, 16]} />
        <meshBasicMaterial color="#ff0000" transparent opacity={0.6} />
        {Array.from({ length: 20 }).map((_, i) => (
          <Instance
            key={i}
            position={[
              (Math.random() - 0.5) * 8,
              (Math.random() - 0.5) * 8,
              (Math.random() - 0.5) * 8
            ]}
            scale={Math.sin(time * 0.5 + i * 0.3) * 0.5 + 1}
          />
        ))}
      </Instances>
    </group>
  )
}
