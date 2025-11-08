/**
 * NEURONS TO COSMOS - Epic Cinematic 3D Journey
 * 
 * A breathtaking 30-second automated journey through four scales of existence:
 * PHASE 1 (0-7.5s):   Neural Microcosm - Individual neurons firing
 * PHASE 2 (7.5-13.5s): Brain Structure - Full hemisphere with synaptic connections
 * PHASE 3 (13.5-22.5s): Geospatial Earth - Global data network
 * PHASE 4 (22.5-30s):  Cosmic Perspective - Earth in space with satellites
 * 
 * Inspired by: https://laniman.github.io/threejs-brain-animation/
 * Built with: React Three Fiber, Three.js r160, custom shaders
 */

import { createElement as h } from 'react';
import { createRoot } from 'react-dom/client';
import { Canvas, useFrame, useThree, extend } from '@react-three/fiber';
import { EffectComposer, Bloom, DepthOfField } from '@react-three/postprocessing';
import * as THREE from 'https://unpkg.com/three@0.153.0/build/three.module.js';
import { useRef, useMemo, useState, useEffect } from 'react';

// ═══════════════════════════════════════════════════════════════════════════
// ANIMATION CONFIGURATION
// ═══════════════════════════════════════════════════════════════════════════

const DURATION = 30; // 30 seconds total
const PHASES = {
  NEURAL: { start: 0, end: 7.5, name: 'Neural Microcosm' },
  BRAIN: { start: 7.5, end: 13.5, name: 'Brain Structure' },
  EARTH: { start: 13.5, end: 22.5, name: 'Geospatial Network' },
  COSMOS: { start: 22.5, end: 30, name: 'Cosmic Perspective' }
};

const COLORS = {
  electricBlue: '#00d9ff',
  neuralPink: '#ff6b9d',
  deepPurple: '#8b5cf6',
  cosmicOrange: '#ff6b35',
  dataGreen: '#10b981',
  satelliteWhite: '#e0f2fe'
};

// ═══════════════════════════════════════════════════════════════════════════
// CUSTOM SHADERS
// ═══════════════════════════════════════════════════════════════════════════

// Electrical discharge shader with animated noise
const electricalShader = {
  vertexShader: `
    varying vec2 vUv;
    varying vec3 vNormal;
    varying vec3 vPosition;
    
    void main() {
      vUv = uv;
      vNormal = normalize(normalMatrix * normal);
      vPosition = position;
      gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
    }
  `,
  fragmentShader: `
    uniform float time;
    uniform vec3 color;
    uniform float intensity;
    
    varying vec2 vUv;
    varying vec3 vNormal;
    varying vec3 vPosition;
    
    // Simplex noise function
    vec3 mod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
    vec4 mod289(vec4 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
    vec4 permute(vec4 x) { return mod289(((x*34.0)+1.0)*x); }
    vec4 taylorInvSqrt(vec4 r) { return 1.79284291400159 - 0.85373472095314 * r; }
    
    float snoise(vec3 v) {
      const vec2 C = vec2(1.0/6.0, 1.0/3.0);
      const vec4 D = vec4(0.0, 0.5, 1.0, 2.0);
      
      vec3 i  = floor(v + dot(v, C.yyy));
      vec3 x0 = v - i + dot(i, C.xxx);
      
      vec3 g = step(x0.yzx, x0.xyz);
      vec3 l = 1.0 - g;
      vec3 i1 = min(g.xyz, l.zxy);
      vec3 i2 = max(g.xyz, l.zxy);
      
      vec3 x1 = x0 - i1 + C.xxx;
      vec3 x2 = x0 - i2 + C.yyy;
      vec3 x3 = x0 - D.yyy;
      
      i = mod289(i);
      vec4 p = permute(permute(permute(
                i.z + vec4(0.0, i1.z, i2.z, 1.0))
              + i.y + vec4(0.0, i1.y, i2.y, 1.0))
              + i.x + vec4(0.0, i1.x, i2.x, 1.0));
      
      float n_ = 0.142857142857;
      vec3 ns = n_ * D.wyz - D.xzx;
      
      vec4 j = p - 49.0 * floor(p * ns.z * ns.z);
      
      vec4 x_ = floor(j * ns.z);
      vec4 y_ = floor(j - 7.0 * x_);
      
      vec4 x = x_ *ns.x + ns.yyyy;
      vec4 y = y_ *ns.x + ns.yyyy;
      vec4 h = 1.0 - abs(x) - abs(y);
      
      vec4 b0 = vec4(x.xy, y.xy);
      vec4 b1 = vec4(x.zw, y.zw);
      
      vec4 s0 = floor(b0)*2.0 + 1.0;
      vec4 s1 = floor(b1)*2.0 + 1.0;
      vec4 sh = -step(h, vec4(0.0));
      
      vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy;
      vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww;
      
      vec3 p0 = vec3(a0.xy, h.x);
      vec3 p1 = vec3(a0.zw, h.y);
      vec3 p2 = vec3(a1.xy, h.z);
      vec3 p3 = vec3(a1.zw, h.w);
      
      vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2,p2), dot(p3,p3)));
      p0 *= norm.x;
      p1 *= norm.y;
      p2 *= norm.z;
      p3 *= norm.w;
      
      vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
      m = m * m;
      return 42.0 * dot(m*m, vec4(dot(p0,x0), dot(p1,x1), dot(p2,x2), dot(p3,x3)));
    }
    
    void main() {
      // Animated electrical discharge
      float noise = snoise(vPosition * 2.0 + vec3(time * 2.0, 0.0, 0.0));
      float discharge = smoothstep(0.3, 0.7, noise);
      
      // Pulsating glow
      float pulse = sin(time * 3.0) * 0.5 + 0.5;
      
      // Combine effects
      float glow = discharge * pulse * intensity;
      vec3 finalColor = color * (1.0 + glow * 2.0);
      
      gl_FragColor = vec4(finalColor, 0.8 + glow * 0.2);
    }
  `
};

// Fresnel atmospheric glow shader
const atmosphereShader = {
  vertexShader: `
    varying vec3 vNormal;
    varying vec3 vPosition;
    
    void main() {
      vNormal = normalize(normalMatrix * normal);
      vPosition = (modelViewMatrix * vec4(position, 1.0)).xyz;
      gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
    }
  `,
  fragmentShader: `
    uniform vec3 glowColor;
    uniform float intensity;
    
    varying vec3 vNormal;
    varying vec3 vPosition;
    
    void main() {
      vec3 viewDirection = normalize(vPosition);
      float fresnel = pow(1.0 - abs(dot(viewDirection, vNormal)), 3.0);
      
      vec3 color = glowColor * fresnel * intensity;
      float alpha = fresnel * 0.6;
      
      gl_FragColor = vec4(color, alpha);
    }
  `
};

// Data pulse shader for connections
const pulseShader = {
  vertexShader: `
    varying vec2 vUv;
    
    void main() {
      vUv = uv;
      gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
    }
  `,
  fragmentShader: `
    uniform float time;
    uniform vec3 color;
    uniform float speed;
    
    varying vec2 vUv;
    
    void main() {
      float pulse = fract(vUv.x * 2.0 - time * speed);
      float intensity = smoothstep(0.0, 0.1, pulse) * smoothstep(0.3, 0.2, pulse);
      
      vec3 finalColor = color * (1.0 + intensity * 3.0);
      float alpha = 0.3 + intensity * 0.7;
      
      gl_FragColor = vec4(finalColor, alpha);
    }
  `
};

// ═══════════════════════════════════════════════════════════════════════════
// PHASE 1: NEURAL MICROCOSM
// ═══════════════════════════════════════════════════════════════════════════

function NeuralParticles({ time, phase }) {
  const particlesRef = useRef();
  const count = 12000;
  
  // Circular texture for round particles
  const circleTexture = useMemo(() => {
    const canvas = document.createElement('canvas');
    canvas.width = 64;
    canvas.height = 64;
    const ctx = canvas.getContext('2d');
    const gradient = ctx.createRadialGradient(32, 32, 0, 32, 32, 32);
    gradient.addColorStop(0, 'rgba(255, 255, 255, 1)');
    gradient.addColorStop(0.5, 'rgba(255, 107, 157, 0.8)');
    gradient.addColorStop(1, 'rgba(0, 217, 255, 0)');
    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, 64, 64);
    return new THREE.CanvasTexture(canvas);
  }, []);
  
  const particles = useMemo(() => {
    const positions = new Float32Array(count * 3);
    const velocities = new Float32Array(count * 3);
    const colors = new Float32Array(count * 3);
    const sizes = new Float32Array(count);
    
    for (let i = 0; i < count; i++) {
      // Cluster particles around neuron pathways
      const angle = Math.random() * Math.PI * 2;
      const radius = Math.random() * 3 + 1;
      const height = (Math.random() - 0.5) * 4;
      
      positions[i * 3] = Math.cos(angle) * radius;
      positions[i * 3 + 1] = height;
      positions[i * 3 + 2] = Math.sin(angle) * radius;
      
      velocities[i * 3] = (Math.random() - 0.5) * 0.02;
      velocities[i * 3 + 1] = (Math.random() - 0.5) * 0.02;
      velocities[i * 3 + 2] = (Math.random() - 0.5) * 0.02;
      
      // Color variation: electric blue to neural pink
      const colorMix = Math.random();
      colors[i * 3] = colorMix * 1.0 + (1 - colorMix) * 0.0;     // R
      colors[i * 3 + 1] = colorMix * 0.42 + (1 - colorMix) * 0.85; // G
      colors[i * 3 + 2] = colorMix * 0.61 + (1 - colorMix) * 1.0;  // B
      
      sizes[i] = Math.random() * 0.05 + 0.02;
    }
    
    return { positions, velocities, colors, sizes };
  }, [count]);
  
  useFrame(() => {
    if (!particlesRef.current || phase !== 0) return;
    
    const positions = particlesRef.current.geometry.attributes.position.array;
    const velocities = particles.velocities;
    
    for (let i = 0; i < count; i++) {
      // Neurotransmitter burst movement
      positions[i * 3] += velocities[i * 3] * (1 + Math.sin(time * 2) * 0.5);
      positions[i * 3 + 1] += velocities[i * 3 + 1];
      positions[i * 3 + 2] += velocities[i * 3 + 2] * (1 + Math.cos(time * 2) * 0.5);
      
      // Boundary constraints
      const dist = Math.sqrt(
        positions[i * 3] ** 2 + 
        positions[i * 3 + 2] ** 2
      );
      
      if (dist > 4) {
        velocities[i * 3] *= -0.8;
        velocities[i * 3 + 2] *= -0.8;
      }
      
      if (Math.abs(positions[i * 3 + 1]) > 3) {
        velocities[i * 3 + 1] *= -0.8;
      }
    }
    
    particlesRef.current.geometry.attributes.position.needsUpdate = true;
  });
  
  return h('points', { ref: particlesRef },
    h('bufferGeometry', null,
      h('bufferAttribute', {
        attach: 'attributes-position',
        count,
        array: particles.positions,
        itemSize: 3
      }),
      h('bufferAttribute', {
        attach: 'attributes-color',
        count,
        array: particles.colors,
        itemSize: 3
      }),
      h('bufferAttribute', {
        attach: 'attributes-size',
        count,
        array: particles.sizes,
        itemSize: 1
      })
    ),
    h('pointsMaterial', {
      map: circleTexture,
      size: 0.15,
      vertexColors: true,
      transparent: true,
      opacity: 0.9,
      blending: THREE.AdditiveBlending,
      depthWrite: false,
      sizeAttenuation: true
    })
  );
}

function Neuron({ position, time, phase }) {
  const meshRef = useRef();
  const materialRef = useRef();
  
  useFrame(() => {
    if (!meshRef.current || !materialRef.current) return;
    
    // Pulsating glow effect
    const pulse = Math.sin(time * 3 + position[0]) * 0.5 + 1.5;
    materialRef.current.emissiveIntensity = pulse;
    
    // Fade out in phase transition
    if (phase > 0) {
      materialRef.current.opacity = Math.max(0, 1 - (phase - 0) * 2);
    }
  });
  
  return h('mesh', { ref: meshRef, position },
    h('sphereGeometry', { args: [0.15, 16, 16] }),
    h('meshStandardMaterial', {
      ref: materialRef,
      color: COLORS.neuralPink,
      emissive: COLORS.cosmicOrange,
      emissiveIntensity: 2,
      transparent: true,
      opacity: 1
    })
  );
}

function NeuralNetwork({ time, phase }) {
  const neurons = useMemo(() => {
    const positions = [];
    for (let i = 0; i < 40; i++) {
      const angle = (i / 40) * Math.PI * 2;
      const radius = 2 + Math.random();
      const height = (Math.random() - 0.5) * 3;
      positions.push([
        Math.cos(angle) * radius,
        height,
        Math.sin(angle) * radius
      ]);
    }
    return positions;
  }, []);
  
  return h('group', null,
    ...neurons.map((pos, i) => 
      h(Neuron, { key: i, position: pos, time, phase })
    )
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// PHASE 2: BRAIN STRUCTURE
// ═══════════════════════════════════════════════════════════════════════════

function BrainHemisphere({ time, phase }) {
  const meshRef = useRef();
  const materialRef = useRef();
  
  useFrame(() => {
    if (!meshRef.current || !materialRef.current) return;
    
    // Wave propagation animation
    const wave = Math.sin(time * 2) * 0.5 + 0.5;
    materialRef.current.emissiveIntensity = 0.5 + wave * 1.5;
    
    // Rotate slowly
    meshRef.current.rotation.y = time * 0.1;
    
    // Fade in during phase 1, fade out during phase 2
    if (phase < 1) {
      materialRef.current.opacity = Math.min(1, (phase - 0.5) * 2);
    } else if (phase > 1) {
      materialRef.current.opacity = Math.max(0, 1 - (phase - 1) * 0.5);
    }
  });
  
  return h('mesh', { ref: meshRef },
    h('icosahedronGeometry', { args: [2.5, 4] }),
    h('meshStandardMaterial', {
      ref: materialRef,
      color: COLORS.deepPurple,
      emissive: COLORS.electricBlue,
      emissiveIntensity: 1,
      transparent: true,
      opacity: 0,
      wireframe: false,
      roughness: 0.3,
      metalness: 0.7
    })
  );
}

function SynapticConnections({ time, phase }) {
  const linesRef = useRef();
  const count = 200;
  
  const connections = useMemo(() => {
    const points = [];
    const colors = [];
    
    for (let i = 0; i < count; i++) {
      // Random points on sphere surface
      const theta1 = Math.random() * Math.PI * 2;
      const phi1 = Math.random() * Math.PI;
      const theta2 = Math.random() * Math.PI * 2;
      const phi2 = Math.random() * Math.PI;
      
      const r = 2.5;
      
      points.push(
        r * Math.sin(phi1) * Math.cos(theta1),
        r * Math.cos(phi1),
        r * Math.sin(phi1) * Math.sin(theta1),
        
        r * Math.sin(phi2) * Math.cos(theta2),
        r * Math.cos(phi2),
        r * Math.sin(phi2) * Math.sin(theta2)
      );
      
      // Color gradient
      const c = new THREE.Color(COLORS.electricBlue);
      colors.push(c.r, c.g, c.b, c.r, c.g, c.b);
    }
    
    return { points: new Float32Array(points), colors: new Float32Array(colors) };
  }, [count]);
  
  useFrame(() => {
    if (!linesRef.current || phase < 0.8 || phase > 1.5) return;
    
    // Traveling light pulses animation would go here
    // For now, simple opacity control
    linesRef.current.material.opacity = phase > 1 ? Math.max(0, 1 - (phase - 1) * 2) : (phase - 0.8) * 5;
  });
  
  return h('lineSegments', { ref: linesRef },
    h('bufferGeometry', null,
      h('bufferAttribute', {
        attach: 'attributes-position',
        count: connections.points.length / 3,
        array: connections.points,
        itemSize: 3
      }),
      h('bufferAttribute', {
        attach: 'attributes-color',
        count: connections.colors.length / 3,
        array: connections.colors,
        itemSize: 3
      })
    ),
    h('lineBasicMaterial', {
      vertexColors: true,
      transparent: true,
      opacity: 0,
      blending: THREE.AdditiveBlending
    })
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// PHASE 3: GEOSPATIAL EARTH
// ═══════════════════════════════════════════════════════════════════════════

function Earth({ time, phase }) {
  const meshRef = useRef();
  const materialRef = useRef();
  
  // Load Earth textures
  const [earthMap, normalMap] = useMemo(() => {
    const textureLoader = new THREE.TextureLoader();
    // Using NASA Blue Marble texture URLs
    const earth = textureLoader.load('https://cdn.jsdelivr.net/gh/mrdoob/three.js@r128/examples/textures/planets/earth_atmos_2048.jpg');
    const normal = null; // Optional normal map
    return [earth, normal];
  }, []);
  
  useFrame(() => {
    if (!meshRef.current) return;
    
    // Rotate Earth
    meshRef.current.rotation.y += 0.0005;
    
    // Scale and opacity transitions
    if (phase < 2) {
      const t = Math.max(0, (phase - 1.5) * 2);
      meshRef.current.scale.setScalar(t * 3);
      if (materialRef.current) {
        materialRef.current.opacity = t;
      }
    } else if (phase >= 2 && phase < 3) {
      meshRef.current.scale.setScalar(3);
      if (materialRef.current) {
        materialRef.current.opacity = 1;
      }
    } else {
      const t = Math.max(0, 1 - (phase - 3) * 0.5);
      if (materialRef.current) {
        materialRef.current.opacity = t;
      }
    }
  });
  
  return h('mesh', { ref: meshRef, scale: 0 },
    h('sphereGeometry', { args: [1, 64, 64] }),
    h('meshStandardMaterial', {
      ref: materialRef,
      map: earthMap,
      normalMap,
      roughness: 0.7,
      metalness: 0.2,
      transparent: true,
      opacity: 0
    })
  );
}

function DataArcs({ time, phase }) {
  const arcsRef = useRef();
  
  const arcs = useMemo(() => {
    const arcData = [];
    const cities = [
      [0, 0.5, 0.866],      // ~50°N
      [0.5, 0.5, 0.707],    // ~45°N, 45°E
      [-0.5, 0.5, 0.707],   // ~45°N, -45°E
      [0.866, 0, 0.5],      // Equator, 60°E
      [-0.866, 0, 0.5],     // Equator, -60°E
      [0, -0.5, 0.866],     // ~-50°S
      [0.5, -0.5, 0.707],   // ~-45°S, 45°E
      [-0.5, -0.5, 0.707],  // ~-45°S, -45°E
    ];
    
    // Create arcs between random city pairs
    for (let i = 0; i < 30; i++) {
      const start = cities[Math.floor(Math.random() * cities.length)];
      const end = cities[Math.floor(Math.random() * cities.length)];
      
      if (start === end) continue;
      
      // Create arc using quadratic bezier curve
      const startVec = new THREE.Vector3(...start).multiplyScalar(3.1);
      const endVec = new THREE.Vector3(...end).multiplyScalar(3.1);
      const mid = new THREE.Vector3().addVectors(startVec, endVec).multiplyScalar(0.5);
      mid.normalize().multiplyScalar(4.5); // Arc height
      
      const curve = new THREE.QuadraticBezierCurve3(startVec, mid, endVec);
      const points = curve.getPoints(50);
      
      arcData.push({ points, color: new THREE.Color(
        Math.random() > 0.5 ? COLORS.dataGreen : COLORS.electricBlue
      )});
    }
    
    return arcData;
  }, []);
  
  useFrame(() => {
    if (!arcsRef.current || phase < 2 || phase > 3) return;
    
    // Fade in/out
    const opacity = phase < 2.5 ? (phase - 2) * 2 : Math.max(0, 1 - (phase - 2.5) * 2);
    arcsRef.current.children.forEach(line => {
      line.material.opacity = opacity * 0.6;
    });
  });
  
  return h('group', { ref: arcsRef },
    ...arcs.map((arc, i) => 
      h('line', { key: i },
        h('bufferGeometry', null,
          h('bufferAttribute', {
            attach: 'attributes-position',
            count: arc.points.length,
            array: new Float32Array(arc.points.flatMap(p => [p.x, p.y, p.z])),
            itemSize: 3
          })
        ),
        h('lineBasicMaterial', {
          color: arc.color,
          transparent: true,
          opacity: 0,
          blending: THREE.AdditiveBlending
        })
      )
    )
  );
}

function EarthAtmosphere({ time, phase }) {
  const meshRef = useRef();
  
  useFrame(() => {
    if (!meshRef.current || phase < 2 || phase > 3) return;
    
    meshRef.current.rotation.y = time * 0.0003;
    
    // Fade in/out with Earth
    const opacity = phase < 2.5 ? (phase - 2) * 2 : Math.max(0, 1 - (phase - 2.5) * 2);
    meshRef.current.material.opacity = opacity * 0.3;
    meshRef.current.scale.setScalar(3.2 * (opacity > 0 ? 1 : 0));
  });
  
  return h('mesh', { ref: meshRef, scale: 0 },
    h('sphereGeometry', { args: [1.1, 64, 64] }),
    h('shaderMaterial', {
      transparent: true,
      side: THREE.BackSide,
      blending: THREE.AdditiveBlending,
      uniforms: {
        glowColor: { value: new THREE.Color(COLORS.electricBlue) },
        intensity: { value: 1.5 }
      },
      vertexShader: atmosphereShader.vertexShader,
      fragmentShader: atmosphereShader.fragmentShader
    })
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// PHASE 4: COSMIC PERSPECTIVE
// ═══════════════════════════════════════════════════════════════════════════

function Starfield({ phase }) {
  const starsRef = useRef();
  const count = 10000;
  
  const stars = useMemo(() => {
    const positions = new Float32Array(count * 3);
    const sizes = new Float32Array(count);
    
    for (let i = 0; i < count; i++) {
      // Random positions in sphere
      const radius = 50 + Math.random() * 50;
      const theta = Math.random() * Math.PI * 2;
      const phi = Math.random() * Math.PI;
      
      positions[i * 3] = radius * Math.sin(phi) * Math.cos(theta);
      positions[i * 3 + 1] = radius * Math.cos(phi);
      positions[i * 3 + 2] = radius * Math.sin(phi) * Math.sin(theta);
      
      sizes[i] = Math.random() * 2 + 0.5;
    }
    
    return { positions, sizes };
  }, [count]);
  
  useFrame(() => {
    if (!starsRef.current || phase < 3) return;
    
    const opacity = Math.min(1, (phase - 3) * 2);
    starsRef.current.material.opacity = opacity;
  });
  
  return h('points', { ref: starsRef },
    h('bufferGeometry', null,
      h('bufferAttribute', {
        attach: 'attributes-position',
        count,
        array: stars.positions,
        itemSize: 3
      }),
      h('bufferAttribute', {
        attach: 'attributes-size',
        count,
        array: stars.sizes,
        itemSize: 1
      })
    ),
    h('pointsMaterial', {
      color: 0xffffff,
      size: 0.5,
      transparent: true,
      opacity: 0,
      blending: THREE.AdditiveBlending,
      sizeAttenuation: true
    })
  );
}

function Satellites({ time, phase }) {
  const groupRef = useRef();
  const satelliteCount = 18;
  
  const orbits = useMemo(() => {
    return Array.from({ length: satelliteCount }, (_, i) => ({
      radius: 4 + Math.random() * 2,
      speed: 0.1 + Math.random() * 0.2,
      offset: (i / satelliteCount) * Math.PI * 2,
      tilt: (Math.random() - 0.5) * 0.5
    }));
  }, [satelliteCount]);
  
  useFrame(() => {
    if (!groupRef.current || phase < 3) return;
    
    const opacity = Math.min(1, (phase - 3) * 2);
    
    groupRef.current.children.forEach((satellite, i) => {
      const orbit = orbits[i];
      const angle = time * orbit.speed + orbit.offset;
      
      satellite.position.x = Math.cos(angle) * orbit.radius;
      satellite.position.y = Math.sin(angle) * orbit.radius * Math.sin(orbit.tilt);
      satellite.position.z = Math.sin(angle) * orbit.radius * Math.cos(orbit.tilt);
      
      satellite.material.opacity = opacity;
    });
  });
  
  return h('group', { ref: groupRef },
    ...Array.from({ length: satelliteCount }, (_, i) =>
      h('mesh', { key: i },
        h('boxGeometry', { args: [0.08, 0.08, 0.15] }),
        h('meshStandardMaterial', {
          color: COLORS.satelliteWhite,
          emissive: COLORS.electricBlue,
          emissiveIntensity: 0.5,
          transparent: true,
          opacity: 0
        })
      )
    )
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// CAMERA CHOREOGRAPHY
// ═══════════════════════════════════════════════════════════════════════════

function CameraRig() {
  const { camera } = useThree();
  const [time, setTime] = useState(0);
  const [phase, setPhase] = useState(0);
  
  useFrame((state, delta) => {
    const newTime = (time + delta) % DURATION;
    setTime(newTime);
    
    // Determine current phase
    let currentPhase = 0;
    if (newTime >= PHASES.BRAIN.start && newTime < PHASES.BRAIN.end) currentPhase = 1;
    else if (newTime >= PHASES.EARTH.start && newTime < PHASES.EARTH.end) currentPhase = 2;
    else if (newTime >= PHASES.COSMOS.start) currentPhase = 3;
    setPhase(currentPhase);
    
    // Smooth phase progress (0-1 within each phase)
    const phaseProgress = currentPhase === 0 ? newTime / PHASES.NEURAL.end :
                         currentPhase === 1 ? (newTime - PHASES.BRAIN.start) / (PHASES.BRAIN.end - PHASES.BRAIN.start) :
                         currentPhase === 2 ? (newTime - PHASES.EARTH.start) / (PHASES.EARTH.end - PHASES.EARTH.start) :
                         (newTime - PHASES.COSMOS.start) / (PHASES.COSMOS.end - PHASES.COSMOS.start);
    
    // Camera positions per phase
    if (currentPhase === 0) {
      // NEURAL: Extreme close-up, moving through neurons
      camera.position.x = Math.sin(newTime * 0.3) * 2;
      camera.position.y = Math.cos(newTime * 0.2) * 1.5;
      camera.position.z = 3 + Math.sin(newTime * 0.15) * 0.5;
      camera.lookAt(0, 0, 0);
      camera.fov = 60 - phaseProgress * 10; // Narrow FOV for close-up
    } else if (currentPhase === 1) {
      // BRAIN: Pull back to reveal full structure
      const pullback = phaseProgress * 8;
      camera.position.x = Math.sin(newTime * 0.2) * pullback;
      camera.position.y = 3 + phaseProgress * 2;
      camera.position.z = 5 + pullback;
      camera.lookAt(0, 0, 0);
      camera.fov = 50 + phaseProgress * 20; // Widen FOV
    } else if (currentPhase === 2) {
      // EARTH: Orbit around Earth
      const orbitRadius = 10;
      camera.position.x = Math.cos(newTime * 0.1) * orbitRadius;
      camera.position.y = 3 + Math.sin(newTime * 0.15) * 2;
      camera.position.z = Math.sin(newTime * 0.1) * orbitRadius;
      camera.lookAt(0, 0, 0);
      camera.fov = 70;
    } else {
      // COSMOS: Pull back to cosmic perspective
      const zoom = 15 + phaseProgress * 10;
      camera.position.x = Math.cos(newTime * 0.05) * zoom;
      camera.position.y = 8 + phaseProgress * 4;
      camera.position.z = Math.sin(newTime * 0.05) * zoom;
      camera.lookAt(0, 0, 0);
      camera.fov = 80;
    }
    
    camera.updateProjectionMatrix();
  });
  
  return null;
}

// ═══════════════════════════════════════════════════════════════════════════
// SCENE ORCHESTRATOR
// ═══════════════════════════════════════════════════════════════════════════

function Scene() {
  const [time, setTime] = useState(0);
  const [phase, setPhase] = useState(0);
  
  useFrame((state, delta) => {
    const newTime = (time + delta) % DURATION;
    setTime(newTime);
    
    // Determine phase (0=neural, 1=brain, 2=earth, 3=cosmos)
    const phaseNum = newTime < PHASES.BRAIN.start ? 0 :
                    newTime < PHASES.EARTH.start ? 1 :
                    newTime < PHASES.COSMOS.start ? 2 : 3;
    setPhase(phaseNum);
  });
  
  return h('group', null,
    // Lighting
    h('ambientLight', { intensity: 0.3 }),
    h('directionalLight', { position: [10, 10, 5], intensity: 1.5 }),
    h('pointLight', { position: [-10, -10, -5], intensity: 1, color: COLORS.electricBlue }),
    
    // Phase 1: Neural Microcosm
    h(NeuralParticles, { time, phase }),
    h(NeuralNetwork, { time, phase }),
    
    // Phase 2: Brain Structure
    h(BrainHemisphere, { time, phase }),
    h(SynapticConnections, { time, phase }),
    
    // Phase 3: Geospatial Earth
    h(Earth, { time, phase }),
    h(DataArcs, { time, phase }),
    h(EarthAtmosphere, { time, phase }),
    
    // Phase 4: Cosmic Perspective
    h(Starfield, { phase }),
    h(Satellites, { time, phase }),
    
    // Camera choreography
    h(CameraRig, null)
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// POST-PROCESSING EFFECTS
// ═══════════════════════════════════════════════════════════════════════════

function Effects() {
  return h(EffectComposer, null,
    h(Bloom, {
      intensity: 1.5,
      luminanceThreshold: 0.2,
      luminanceSmoothing: 0.9
    }),
    h(DepthOfField, {
      focusDistance: 0.01,
      focalLength: 0.1,
      bokehScale: 3
    })
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// ROOT COMPONENT
// ═══════════════════════════════════════════════════════════════════════════

function App() {
  return h(Canvas, {
    camera: { position: [0, 0, 5], fov: 60 },
    gl: { 
      antialias: true,
      alpha: true,
      powerPreference: 'high-performance'
    },
    style: {
      position: 'fixed',
      top: 0,
      left: 0,
      width: '100vw',
      height: '100vh',
      background: 'radial-gradient(ellipse at center, #0a0a1a 0%, #000000 100%)'
    }
  },
    h(Scene, null),
    h(Effects, null)
  );
}

// Mount application
const container = document.getElementById('hero-container');
if (container) {
  const root = createRoot(container);
  root.render(h(App));
  console.log('🎬 NEURONS TO COSMOS - Epic cinematic journey initialized!');
}
