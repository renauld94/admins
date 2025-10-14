/**
 * REACT THREE FIBER NEURAL GEOSERVER COMPONENT
 * Integration layer for React Three Fiber
 * Provides React components for the neural GeoServer visualization
 */

import React, { useRef, useEffect, useState, useMemo } from 'react';
import { Canvas, useFrame, useThree } from '@react-three/fiber';
import { OrbitControls, Text, Html } from '@react-three/drei';
import * as THREE from 'three';

// Neural Cluster Component
function NeuralCluster({ layerData, position, onHover, onClick }) {
    const meshRef = useRef();
    const [hovered, setHovered] = useState(false);
    const [clicked, setClicked] = useState(false);
    
    // Determine cluster properties
    const layerType = useMemo(() => {
        if (layerData.type === 'VECTOR') return 'vector';
        if (layerData.type === 'RASTER') return 'raster';
        if (layerData.type === 'WFS') return 'wfs';
        if (layerData.type === 'WMS') return 'wms';
        return 'unknown';
    }, [layerData.type]);
    
    const color = useMemo(() => {
        const colors = {
            vector: '#0ea5e9',    // Blue
            raster: '#10b981',    // Green
            wfs: '#f59e0b',       // Orange
            wms: '#8b5cf6',       // Purple
            unknown: '#6b7280'    // Gray
        };
        return colors[layerType];
    }, [layerType]);
    
    const size = useMemo(() => {
        const baseSize = 0.5;
        const complexity = layerData.resource?.featureType?.attributes?.attribute?.length || 1;
        return baseSize + Math.log(complexity) * 0.2;
    }, [layerData.resource]);
    
    // Animation
    useFrame((state) => {
        if (meshRef.current) {
            const time = state.clock.getElapsedTime();
            const pulse = Math.sin(time * 2) * 0.1 + 1;
            meshRef.current.scale.setScalar(pulse);
            
            // Rotate slowly
            meshRef.current.rotation.y += 0.01;
        }
    });
    
    return (
        <group position={position}>
            {/* Main neuron */}
            <mesh
                ref={meshRef}
                onPointerOver={() => {
                    setHovered(true);
                    onHover?.(layerData);
                }}
                onPointerOut={() => {
                    setHovered(false);
                }}
                onClick={() => {
                    setClicked(!clicked);
                    onClick?.(layerData);
                }}
            >
                <sphereGeometry args={[size, 16, 16]} />
                <meshPhongMaterial
                    color={color}
                    transparent
                    opacity={hovered ? 1 : 0.8}
                    emissive={color}
                    emissiveIntensity={hovered ? 0.5 : 0.2}
                />
            </mesh>
            
            {/* Dendrites */}
            {Array.from({ length: 6 }, (_, i) => (
                <mesh
                    key={i}
                    position={[
                        Math.cos((i / 6) * Math.PI * 2) * size * 1.5,
                        Math.sin((i / 6) * Math.PI * 2) * size * 1.5,
                        (Math.random() - 0.5) * size
                    ]}
                >
                    <sphereGeometry args={[size * 0.3, 8, 8]} />
                    <meshPhongMaterial
                        color={color}
                        transparent
                        opacity={0.6}
                    />
                </mesh>
            ))}
            
            {/* Label */}
            {hovered && (
                <Text
                    position={[0, size * 2, 0]}
                    fontSize={0.5}
                    color={color}
                    anchorX="center"
                    anchorY="middle"
                >
                    {layerData.name}
                </Text>
            )}
        </group>
    );
}

// Synaptic Connection Component
function SynapticConnection({ start, end, color = '#0ea5e9' }) {
    const curveRef = useRef();
    
    // Create Bezier curve
    const curve = useMemo(() => {
        const midPoint = new THREE.Vector3().addVectors(start, end).multiplyScalar(0.5);
        return new THREE.QuadraticBezierCurve3(start, midPoint, end);
    }, [start, end]);
    
    // Animate particles along the curve
    useFrame((state) => {
        if (curveRef.current) {
            const time = state.clock.getElapsedTime();
            const positions = curveRef.current.geometry.attributes.position.array;
            
            for (let i = 0; i < 20; i++) {
                const i3 = i * 3;
                const t = (i / 20 + time * 0.001) % 1;
                const point = curve.getPoint(t);
                
                positions[i3] = point.x;
                positions[i3 + 1] = point.y;
                positions[i3 + 2] = point.z;
            }
            
            curveRef.current.geometry.attributes.position.needsUpdate = true;
        }
    });
    
    return (
        <group>
            {/* Connection line */}
            <line>
                <bufferGeometry>
                    <bufferAttribute
                        attach="attributes-position"
                        count={curve.getPoints(50).length}
                        array={new Float32Array(curve.getPoints(50).flatMap(p => [p.x, p.y, p.z]))}
                        itemSize={3}
                    />
                </bufferGeometry>
                <lineBasicMaterial color={color} transparent opacity={0.3} />
            </line>
            
            {/* Animated particles */}
            <points ref={curveRef}>
                <bufferGeometry>
                    <bufferAttribute
                        attach="attributes-position"
                        count={20}
                        array={new Float32Array(20 * 3)}
                        itemSize={3}
                    />
                </bufferGeometry>
                <pointsMaterial
                    color={color}
                    size={0.1}
                    transparent
                    opacity={0.8}
                    blending={THREE.AdditiveBlending}
                />
            </points>
        </group>
    );
}

// Earth Sphere Component
function EarthSphere() {
    const earthRef = useRef();
    const glowRef = useRef();
    
    useFrame(() => {
        if (earthRef.current) {
            earthRef.current.rotation.y += 0.001;
        }
        if (glowRef.current) {
            glowRef.current.rotation.y += 0.0005;
        }
    });
    
    return (
        <group>
            {/* Earth */}
            <mesh ref={earthRef}>
                <sphereGeometry args={[15, 64, 64]} />
                <meshPhongMaterial
                    color="#4a90e2"
                    transparent
                    opacity={0.9}
                    shininess={1000}
                />
            </mesh>
            
            {/* Atmospheric glow */}
            <mesh ref={glowRef}>
                <sphereGeometry args={[16, 32, 32]} />
                <meshBasicMaterial
                    color="#0ea5e9"
                    transparent
                    opacity={0.1}
                    side={THREE.BackSide}
                />
            </mesh>
        </group>
    );
}

// Infrastructure Satellite Component
function InfrastructureSatellite({ position, vmId, metrics }) {
    const satelliteRef = useRef();
    
    useFrame((state) => {
        if (satelliteRef.current) {
            const time = state.clock.getElapsedTime();
            
            // Orbital motion
            const orbitRadius = 35 + vmId * 5;
            const angle = (vmId / 5) * Math.PI * 2 + time * 0.0001;
            
            satelliteRef.current.position.x = orbitRadius * Math.cos(angle);
            satelliteRef.current.position.y = orbitRadius * Math.sin(angle);
            satelliteRef.current.rotation.z += 0.01;
            
            // Update based on metrics
            if (metrics) {
                const body = satelliteRef.current.children[0];
                if (body) {
                    // CPU affects rotation speed
                    body.rotation.x += (metrics.cpu || 0) * 0.001;
                    body.rotation.y += (metrics.cpu || 0) * 0.001;
                    
                    // Memory affects scale
                    const scale = 0.8 + ((metrics.memory || 0) / 100) * 0.4;
                    body.scale.setScalar(scale);
                    
                    // Disk I/O affects emissive intensity
                    body.material.emissiveIntensity = 0.1 + ((metrics.diskIO || 0) / 100) * 0.4;
                }
            }
        }
    });
    
    return (
        <group ref={satelliteRef} position={position}>
            {/* Satellite body */}
            <mesh>
                <boxGeometry args={[0.5, 0.5, 0.5]} />
                <meshPhongMaterial
                    color="#f59e0b"
                    transparent
                    opacity={0.8}
                    emissive="#f59e0b"
                    emissiveIntensity={0.3}
                />
            </mesh>
            
            {/* Solar panels */}
            <mesh position={[-0.8, 0, 0]}>
                <boxGeometry args={[1, 0.1, 0.5]} />
                <meshPhongMaterial color="#1f2937" transparent opacity={0.9} />
            </mesh>
            <mesh position={[0.8, 0, 0]}>
                <boxGeometry args={[1, 0.1, 0.5]} />
                <meshPhongMaterial color="#1f2937" transparent opacity={0.9} />
            </mesh>
        </group>
    );
}

// Particle System Component
function ParticleSystem({ count = 10000 }) {
    const particlesRef = useRef();
    
    const positions = useMemo(() => {
        const positions = new Float32Array(count * 3);
        for (let i = 0; i < count; i++) {
            const i3 = i * 3;
            const radius = 20 + Math.random() * 30;
            const theta = Math.random() * Math.PI * 2;
            const phi = Math.random() * Math.PI;
            
            positions[i3] = radius * Math.sin(phi) * Math.cos(theta);
            positions[i3 + 1] = radius * Math.sin(phi) * Math.sin(theta);
            positions[i3 + 2] = radius * Math.cos(phi);
        }
        return positions;
    }, [count]);
    
    const colors = useMemo(() => {
        const colors = new Float32Array(count * 3);
        for (let i = 0; i < count; i++) {
            const i3 = i * 3;
            const color = new THREE.Color();
            color.setHSL(0.6 + Math.random() * 0.2, 0.8, 0.6);
            colors[i3] = color.r;
            colors[i3 + 1] = color.g;
            colors[i3 + 2] = color.b;
        }
        return colors;
    }, [count]);
    
    useFrame(() => {
        if (particlesRef.current) {
            particlesRef.current.rotation.x += 0.0005;
            particlesRef.current.rotation.y += 0.001;
        }
    });
    
    return (
        <points ref={particlesRef}>
            <bufferGeometry>
                <bufferAttribute
                    attach="attributes-position"
                    count={count}
                    array={positions}
                    itemSize={3}
                />
                <bufferAttribute
                    attach="attributes-color"
                    count={count}
                    array={colors}
                    itemSize={3}
                />
            </bufferGeometry>
            <pointsMaterial
                size={0.1}
                vertexColors
                transparent
                opacity={0.8}
                blending={THREE.AdditiveBlending}
            />
        </points>
    );
}

// Main Neural GeoServer Scene Component
function NeuralGeoServerScene({ layers = [], connections = [], satellites = [] }) {
    const { camera } = useThree();
    
    useEffect(() => {
        // Set initial camera position
        camera.position.set(0, 0, 50);
    }, [camera]);
    
    return (
        <>
            {/* Lighting */}
            <ambientLight intensity={0.3} />
            <directionalLight position={[50, 50, 50]} intensity={0.8} castShadow />
            <pointLight position={[20, 20, 20]} color="#0ea5e9" intensity={1} distance={100} />
            <pointLight position={[-20, -20, 20]} color="#8b5cf6" intensity={1} distance={100} />
            
            {/* Earth */}
            <EarthSphere />
            
            {/* Particle system */}
            <ParticleSystem count={5000} />
            
            {/* Neural clusters */}
            {layers.map((layer, index) => (
                <NeuralCluster
                    key={layer.name || index}
                    layerData={layer}
                    position={[
                        (Math.random() - 0.5) * 40,
                        (Math.random() - 0.5) * 40,
                        (Math.random() - 0.5) * 40
                    ]}
                    onHover={(layerData) => {
                        console.log('Hovered layer:', layerData.name);
                    }}
                    onClick={(layerData) => {
                        console.log('Clicked layer:', layerData.name);
                    }}
                />
            ))}
            
            {/* Synaptic connections */}
            {connections.map((connection, index) => (
                <SynapticConnection
                    key={index}
                    start={connection.start}
                    end={connection.end}
                    color={connection.color}
                />
            ))}
            
            {/* Infrastructure satellites */}
            {satellites.map((satellite, index) => (
                <InfrastructureSatellite
                    key={satellite.id || index}
                    position={satellite.position}
                    vmId={satellite.vmId || index}
                    metrics={satellite.metrics}
                />
            ))}
        </>
    );
}

// Main Neural GeoServer Component
export default function NeuralGeoServerViz({ 
    geoserverUrl = 'https://www.simondatalab.de/geospatial-viz',
    proxmoxUrl = 'https://136.243.155.166:8006',
    ...props 
}) {
    const [layers, setLayers] = useState([]);
    const [connections, setConnections] = useState([]);
    const [satellites, setSatellites] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    
    // Load GeoServer data
    useEffect(() => {
        const loadData = async () => {
            try {
                setLoading(true);
                
                // Load layers
                const layersResponse = await fetch(`${geoserverUrl}/rest/layers.json`);
                const layersData = await layersResponse.json();
                
                if (layersData.layers && layersData.layers.layer) {
                    setLayers(layersData.layers.layer);
                } else {
                    // Fallback demo data
                    setLayers([
                        { name: 'Demo Vector Layer', type: 'VECTOR' },
                        { name: 'Demo Raster Layer', type: 'RASTER' },
                        { name: 'Demo WFS Layer', type: 'WFS' },
                        { name: 'Demo WMS Layer', type: 'WMS' }
                    ]);
                }
                
                // Create demo connections
                setConnections([
                    {
                        start: new THREE.Vector3(-10, 0, 0),
                        end: new THREE.Vector3(10, 0, 0),
                        color: '#0ea5e9'
                    },
                    {
                        start: new THREE.Vector3(0, -10, 0),
                        end: new THREE.Vector3(0, 10, 0),
                        color: '#8b5cf6'
                    }
                ]);
                
                // Create demo satellites
                setSatellites([
                    { id: 'vm-1', vmId: 1, position: [35, 0, 0], metrics: { cpu: 45, memory: 60, diskIO: 30 } },
                    { id: 'vm-2', vmId: 2, position: [40, 0, 0], metrics: { cpu: 70, memory: 80, diskIO: 50 } },
                    { id: 'vm-3', vmId: 3, position: [45, 0, 0], metrics: { cpu: 30, memory: 40, diskIO: 20 } }
                ]);
                
                setLoading(false);
                
            } catch (err) {
                console.error('Failed to load GeoServer data:', err);
                setError(err.message);
                setLoading(false);
            }
        };
        
        loadData();
    }, [geoserverUrl]);
    
    if (loading) {
        return (
            <div style={{ 
                display: 'flex', 
                alignItems: 'center', 
                justifyContent: 'center', 
                height: '100%',
                color: '#0ea5e9',
                fontSize: '1.2rem'
            }}>
                <div>
                    <div style={{ marginBottom: '1rem' }}>🌌 Initializing Neural GeoServer...</div>
                    <div style={{ fontSize: '0.9rem', opacity: 0.8 }}>Loading geospatial intelligence</div>
                </div>
            </div>
        );
    }
    
    if (error) {
        return (
            <div style={{ 
                display: 'flex', 
                alignItems: 'center', 
                justifyContent: 'center', 
                height: '100%',
                color: '#ef4444',
                fontSize: '1rem',
                textAlign: 'center',
                padding: '2rem'
            }}>
                <div>
                    <div style={{ marginBottom: '1rem' }}>❌ Error loading visualization</div>
                    <div style={{ fontSize: '0.8rem', opacity: 0.8 }}>{error}</div>
                </div>
            </div>
        );
    }
    
    return (
        <Canvas
            camera={{ position: [0, 0, 50], fov: 75 }}
            style={{ width: '100%', height: '100%' }}
            shadows
        >
            <NeuralGeoServerScene 
                layers={layers}
                connections={connections}
                satellites={satellites}
            />
            <OrbitControls
                enableDamping
                dampingFactor={0.05}
                minDistance={10}
                maxDistance={200}
                maxPolarAngle={Math.PI / 2}
            />
        </Canvas>
    );
}

// Export individual components for advanced usage
export {
    NeuralCluster,
    SynapticConnection,
    EarthSphere,
    InfrastructureSatellite,
    ParticleSystem,
    NeuralGeoServerScene
};
