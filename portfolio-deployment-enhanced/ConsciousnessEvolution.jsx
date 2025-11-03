import React, { useEffect, useRef, useState } from 'react';
import * as THREE from 'three';
import { EffectComposer } from 'three/examples/jsm/postprocessing/EffectComposer';
import { RenderPass } from 'three/examples/jsm/postprocessing/RenderPass';
import { UnrealBloomPass } from 'three/examples/jsm/postprocessing/UnrealBloomPass';

/**
 * CONSCIOUSNESS EVOLUTION - LEGENDARY CINEMATIC EXPERIENCE
 * 60 seconds of pure visual storytelling
 * No text. No labels. Only raw cinematic power.
 */

const ConsciousnessEvolution = () => {
  const containerRef = useRef(null);
  const [isPlaying, setIsPlaying] = useState(false);
  const sceneRef = useRef(null);
  const animationRef = useRef(null);

  useEffect(() => {
    if (!containerRef.current) return;

    // ═══════════════════════════════════════════════════════════════
    // SCENE SETUP
    // ═══════════════════════════════════════════════════════════════
    
    const scene = new THREE.Scene();
    scene.background = new THREE.Color(0x000510); // Deep space
    scene.fog = new THREE.FogExp2(0x000510, 0.00025);
    sceneRef.current = scene;

    const camera = new THREE.PerspectiveCamera(
      45,
      containerRef.current.clientWidth / containerRef.current.clientHeight,
      0.1,
      10000
    );
    camera.position.set(0, 0, 5); // Start inside neuron

    const renderer = new THREE.WebGLRenderer({ 
      antialias: true,
      alpha: true,
      powerPreference: 'high-performance'
    });
    renderer.setSize(containerRef.current.clientWidth, containerRef.current.clientHeight);
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    renderer.toneMapping = THREE.ACESFilmicToneMapping;
    renderer.toneMappingExposure = 1.2;
    containerRef.current.appendChild(renderer.domElement);

    // ═══════════════════════════════════════════════════════════════
    // POST-PROCESSING - EPIC MODE
    // ═══════════════════════════════════════════════════════════════
    
    const composer = new EffectComposer(renderer);
    const renderPass = new RenderPass(scene, camera);
    composer.addPass(renderPass);

    const bloomPass = new UnrealBloomPass(
      new THREE.Vector2(window.innerWidth, window.innerHeight),
      2.5, // strength
      0.8, // radius
      0.7  // threshold
    );
    composer.addPass(bloomPass);

    // ═══════════════════════════════════════════════════════════════
    // CITY DATA - GEOGRAPHIC NODES
    // ═══════════════════════════════════════════════════════════════
    
    const cities = {
      hcmc: { lat: 10.8231, lon: 106.6297, color: 0x00f0ff, name: 'Origin' },
      singapore: { lat: 1.3521, lon: 103.8198, color: 0x00f0ff },
      bangkok: { lat: 13.7563, lon: 100.5018, color: 0xa855f7 },
      jakarta: { lat: -6.2088, lon: 106.8456, color: 0xff6b35 },
      kualaLumpur: { lat: 3.1390, lon: 101.6869, color: 0xffd700 },
      berlin: { lat: 52.5200, lon: 13.4050, color: 0xa855f7 },
      sanFrancisco: { lat: 37.7749, lon: -122.4194, color: 0xff6b35 },
      seoul: { lat: 37.5665, lon: 126.9780, color: 0x00ff41 },
      tokyo: { lat: 35.6762, lon: 139.6503, color: 0x00ff41 },
      sydney: { lat: -33.8688, lon: 151.2093, color: 0x87ceeb },
      mumbai: { lat: 19.0760, lon: 72.8777, color: 0xffd700 },
      nyc: { lat: 40.7128, lon: -74.0060, color: 0xff6b35 }
    };

    // Convert lat/lon to 3D position on sphere
    const latLonTo3D = (lat, lon, radius = 100) => {
      const phi = (90 - lat) * (Math.PI / 180);
      const theta = (lon + 180) * (Math.PI / 180);
      return new THREE.Vector3(
        -radius * Math.sin(phi) * Math.cos(theta),
        radius * Math.cos(phi),
        radius * Math.sin(phi) * Math.sin(theta)
      );
    };

    // ═══════════════════════════════════════════════════════════════
    // ACT 1: GENESIS - NEURAL NETWORK
    // ═══════════════════════════════════════════════════════════════
    
    const neurons = new THREE.Group();
    const neuronGeometry = new THREE.SphereGeometry(0.3, 16, 16);
    const neuronMaterial = new THREE.MeshBasicMaterial({ color: 0x00f0ff });
    
    const createNeuron = (position) => {
      const neuron = new THREE.Mesh(neuronGeometry, neuronMaterial.clone());
      neuron.position.copy(position);
      const light = new THREE.PointLight(0x00f0ff, 2, 10);
      light.position.copy(position);
      neurons.add(neuron);
      neurons.add(light);
      return neuron;
    };

    // Initial neuron at origin
    createNeuron(new THREE.Vector3(0, 0, 0));
    scene.add(neurons);

    // Synaptic connections
    const connections = new THREE.Group();
    scene.add(connections);

    // ═══════════════════════════════════════════════════════════════
    // EARTH GLOBE
    // ═══════════════════════════════════════════════════════════════
    
    const earthGeometry = new THREE.SphereGeometry(100, 64, 64);
    const earthMaterial = new THREE.MeshPhongMaterial({
      color: 0x0a2540,
      emissive: 0x001a33,
      emissiveIntensity: 0.3,
      shininess: 15,
      transparent: true,
      opacity: 0
    });
    const earth = new THREE.Mesh(earthGeometry, earthMaterial);
    earth.rotation.y = Math.PI; // Start with Asia facing camera
    scene.add(earth);

    // Atmosphere
    const atmosphereGeometry = new THREE.SphereGeometry(102, 64, 64);
    const atmosphereMaterial = new THREE.ShaderMaterial({
      transparent: true,
      opacity: 0,
      side: THREE.BackSide,
      vertexShader: `
        varying vec3 vNormal;
        void main() {
          vNormal = normalize(normalMatrix * normal);
          gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
        }
      `,
      fragmentShader: `
        varying vec3 vNormal;
        void main() {
          float intensity = pow(0.7 - dot(vNormal, vec3(0.0, 0.0, 1.0)), 2.0);
          gl_FragColor = vec4(0.0, 0.94, 1.0, 1.0) * intensity;
        }
      `
    });
    const atmosphere = new THREE.Mesh(atmosphereGeometry, atmosphereMaterial);
    scene.add(atmosphere);

    // City nodes
    const cityNodes = new THREE.Group();
    const cityMeshes = {};
    
    Object.entries(cities).forEach(([key, city]) => {
      const pos = latLonTo3D(city.lat, city.lon, 100);
      const nodeGeometry = new THREE.SphereGeometry(1.5, 32, 32);
      const nodeMaterial = new THREE.MeshBasicMaterial({
        color: city.color,
        transparent: true,
        opacity: 0
      });
      const node = new THREE.Mesh(nodeGeometry, nodeMaterial);
      node.position.copy(pos);
      
      const light = new THREE.PointLight(city.color, 0, 50);
      light.position.copy(pos);
      
      cityNodes.add(node);
      cityNodes.add(light);
      cityMeshes[key] = { mesh: node, light, position: pos };
    });
    scene.add(cityNodes);

    // Network connections between cities
    const networkLines = new THREE.Group();
    scene.add(networkLines);

    const createConnection = (city1Key, city2Key, color = 0x00f0ff) => {
      const pos1 = cityMeshes[city1Key].position;
      const pos2 = cityMeshes[city2Key].position;
      
      const curve = new THREE.QuadraticBezierCurve3(
        pos1,
        pos1.clone().add(pos2).multiplyScalar(0.5).normalize().multiplyScalar(120),
        pos2
      );
      
      const points = curve.getPoints(50);
      const geometry = new THREE.BufferGeometry().setFromPoints(points);
      const material = new THREE.LineBasicMaterial({
        color: color,
        transparent: true,
        opacity: 0,
        linewidth: 2
      });
      const line = new THREE.Line(geometry, material);
      networkLines.add(line);
      return { line, curve };
    };

    // ═══════════════════════════════════════════════════════════════
    // PARTICLES - 10,000 EPIC MODE
    // ═══════════════════════════════════════════════════════════════
    
    const particleCount = 10000;
    const particlesGeometry = new THREE.BufferGeometry();
    const positions = new Float32Array(particleCount * 3);
    const colors = new Float32Array(particleCount * 3);
    const sizes = new Float32Array(particleCount);
    
    for (let i = 0; i < particleCount; i++) {
      // Distribute particles in space
      const theta = Math.random() * Math.PI * 2;
      const phi = Math.random() * Math.PI;
      const radius = 200 + Math.random() * 400;
      
      positions[i * 3] = radius * Math.sin(phi) * Math.cos(theta);
      positions[i * 3 + 1] = radius * Math.sin(phi) * Math.sin(theta);
      positions[i * 3 + 2] = radius * Math.cos(phi);
      
      colors[i * 3] = Math.random();
      colors[i * 3 + 1] = Math.random();
      colors[i * 3 + 2] = Math.random();
      
      sizes[i] = Math.random() * 2;
    }
    
    particlesGeometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
    particlesGeometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));
    particlesGeometry.setAttribute('size', new THREE.BufferAttribute(sizes, 1));
    
    const particlesMaterial = new THREE.PointsMaterial({
      size: 1.5,
      vertexColors: true,
      transparent: true,
      opacity: 0.6,
      sizeAttenuation: true
    });
    
    const particles = new THREE.Points(particlesGeometry, particlesMaterial);
    scene.add(particles);

    // ═══════════════════════════════════════════════════════════════
    // SATELLITES
    // ═══════════════════════════════════════════════════════════════
    
    const satellites = new THREE.Group();
    const satelliteMeshes = [];
    
    for (let i = 0; i < 12; i++) {
      const satGeometry = new THREE.OctahedronGeometry(2, 0);
      const satMaterial = new THREE.MeshPhongMaterial({
        color: [0xffd700, 0x00f0ff, 0xa855f7][i % 3],
        emissive: [0xffd700, 0x00f0ff, 0xa855f7][i % 3],
        emissiveIntensity: 0.5,
        transparent: true,
        opacity: 0
      });
      const satellite = new THREE.Mesh(satGeometry, satMaterial);
      satellite.userData.angle = (i / 12) * Math.PI * 2;
      satellite.userData.altitude = 130 + (i % 3) * 20;
      satellite.userData.speed = 0.0002 + (i % 3) * 0.0001;
      satellites.add(satellite);
      satelliteMeshes.push(satellite);
    }
    scene.add(satellites);

    // ═══════════════════════════════════════════════════════════════
    // BRAIN OVERLAY
    // ═══════════════════════════════════════════════════════════════
    
    const brainGroup = new THREE.Group();
    const brainGeometry = new THREE.SphereGeometry(105, 32, 32);
    const brainMaterial = new THREE.MeshBasicMaterial({
      color: 0x00f0ff,
      wireframe: true,
      transparent: true,
      opacity: 0
    });
    const brain = new THREE.Mesh(brainGeometry, brainMaterial);
    brainGroup.add(brain);
    scene.add(brainGroup);

    // ═══════════════════════════════════════════════════════════════
    // LIGHTING
    // ═══════════════════════════════════════════════════════════════
    
    const ambientLight = new THREE.AmbientLight(0xffffff, 0.3);
    scene.add(ambientLight);

    const sunLight = new THREE.DirectionalLight(0xffffff, 1);
    sunLight.position.set(500, 200, 500);
    scene.add(sunLight);

    // ═══════════════════════════════════════════════════════════════
    // ANIMATION TIMELINE
    // ═══════════════════════════════════════════════════════════════
    
    let time = 0;
    const timeline = {
      // ACT 1: GENESIS (0-12s)
      act1_neuronMultiply: { start: 0, end: 3 },
      act1_brainsMerge: { start: 3, end: 6 },
      act1_fusion: { start: 6, end: 9 },
      act1_geoContext: { start: 9, end: 12 },
      
      // ACT 2: NETWORK AWAKENING (12-28s)
      act2_firstConnection: { start: 12, end: 14 },
      act2_regionalCascade: { start: 14, end: 18 },
      act2_meshDensify: { start: 18, end: 22 },
      act2_continentalBreach: { start: 22, end: 28 },
      
      // ACT 3: PLANETARY CONSCIOUSNESS (28-42s)
      act3_zoomOut: { start: 28, end: 32 },
      act3_globalSync: { start: 32, end: 36 },
      act3_satellites: { start: 36, end: 39 },
      act3_brainOverlay: { start: 39, end: 42 },
      
      // ACT 4: THE ULTIMATE PULSE (42-52s)
      act4_accumulation: { start: 42, end: 45 },
      act4_pulse: { start: 45, end: 48 },
      act4_syncPeak: { start: 48, end: 50 },
      act4_harmonic: { start: 50, end: 52 },
      
      // ACT 5: ETERNAL PRESENCE (52-60s)
      act5_settle: { start: 52, end: 55 },
      act5_livingSystem: { start: 55, end: 60 }
    };

    const easeInOutCubic = (t) => {
      return t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2;
    };

    const lerp = (a, b, t) => a + (b - a) * t;

    // ═══════════════════════════════════════════════════════════════
    // ANIMATION LOOP
    // ═══════════════════════════════════════════════════════════════
    
    const animate = () => {
      animationRef.current = requestAnimationFrame(animate);
      
      if (!isPlaying) return;
      
      time += 1/60; // 60 FPS
      const t = time;

      // ─────────────────────────────────────────────────────────────
      // ACT 1: GENESIS
      // ─────────────────────────────────────────────────────────────
      
      // t=0-3s: Neuron multiplication
      if (t >= 0 && t <= 3) {
        const progress = t / 3;
        const neuronCount = Math.floor(easeInOutCubic(progress) * 100);
        
        while (neurons.children.length < neuronCount * 2) {
          const pos = new THREE.Vector3(
            (Math.random() - 0.5) * 40,
            (Math.random() - 0.5) * 40,
            (Math.random() - 0.5) * 40
          );
          createNeuron(pos);
        }
        
        // Pulse neurons
        neurons.children.forEach((child, i) => {
          if (child.isMesh) {
            child.material.emissiveIntensity = 0.5 + Math.sin(t * 10 + i) * 0.5;
          }
        });
      }

      // t=3-6s: Multiple brains orbit
      if (t >= 3 && t <= 6) {
        const progress = (t - 3) / 3;
        camera.position.z = lerp(5, 80, easeInOutCubic(progress));
        camera.fov = lerp(90, 60, progress);
        camera.updateProjectionMatrix();
      }

      // t=6-9s: Fusion into single node
      if (t >= 6 && t <= 9) {
        const progress = (t - 6) / 3;
        neurons.children.forEach((child) => {
          if (child.isMesh) {
            child.position.lerp(new THREE.Vector3(0, 0, 0), 0.02);
            child.material.opacity = 1 - progress * 0.5;
          }
        });
      }

      // t=9-12s: Geographic context emerges
      if (t >= 9 && t <= 12) {
        const progress = (t - 9) / 3;
        earth.material.opacity = easeInOutCubic(progress);
        atmosphere.material.opacity = easeInOutCubic(progress) * 0.6;
        
        // Show HCMC node
        cityMeshes.hcmc.mesh.material.opacity = easeInOutCubic(progress);
        cityMeshes.hcmc.light.intensity = easeInOutCubic(progress) * 10;
        
        camera.position.set(0, 50, 200);
        camera.lookAt(cityMeshes.hcmc.position);
      }

      // ─────────────────────────────────────────────────────────────
      // ACT 2: NETWORK AWAKENING
      // ─────────────────────────────────────────────────────────────
      
      // t=12-14s: First connection HCMC→Singapore
      if (t >= 12 && t <= 14) {
        const progress = (t - 12) / 2;
        cityMeshes.singapore.mesh.material.opacity = easeInOutCubic(progress);
        cityMeshes.singapore.light.intensity = easeInOutCubic(progress) * 10;
        
        if (!networkLines.children.length) {
          createConnection('hcmc', 'singapore', 0x00f0ff);
        }
        networkLines.children[0].material.opacity = easeInOutCubic(progress);
      }

      // t=14-18s: Regional cascade
      if (t >= 14 && t <= 18) {
        const progress = (t - 14) / 4;
        ['bangkok', 'jakarta', 'kualaLumpur'].forEach((city, i) => {
          const cityProgress = Math.max(0, Math.min(1, (progress - i * 0.25) * 4));
          cityMeshes[city].mesh.material.opacity = easeInOutCubic(cityProgress);
          cityMeshes[city].light.intensity = easeInOutCubic(cityProgress) * 10;
        });
        
        camera.position.set(0, 100, 350);
      }

      // t=22-28s: Continental breach
      if (t >= 22 && t <= 28) {
        const progress = (t - 22) / 6;
        ['berlin', 'sanFrancisco', 'seoul'].forEach((city, i) => {
          const cityProgress = Math.max(0, Math.min(1, (progress - i * 0.2) * 5));
          cityMeshes[city].mesh.material.opacity = easeInOutCubic(cityProgress);
          cityMeshes[city].light.intensity = easeInOutCubic(cityProgress) * 10;
        });
      }

      // ─────────────────────────────────────────────────────────────
      // ACT 3: PLANETARY CONSCIOUSNESS
      // ─────────────────────────────────────────────────────────────
      
      // t=28-32s: Exponential zoom out
      if (t >= 28 && t <= 32) {
        const progress = (t - 28) / 4;
        camera.position.set(
          0,
          lerp(100, 200, easeInOutCubic(progress)),
          lerp(350, 500, easeInOutCubic(progress))
        );
        camera.fov = lerp(45, 40, progress);
        camera.updateProjectionMatrix();
      }

      // t=32-36s: Global synchronization
      if (t >= 32 && t <= 36) {
        earth.rotation.y += 0.001;
        
        Object.values(cityMeshes).forEach((city) => {
          const pulse = Math.sin(t * 2) * 0.5 + 0.5;
          city.light.intensity = 5 + pulse * 5;
        });
      }

      // t=36-39s: Satellite deployment
      if (t >= 36 && t <= 39) {
        const progress = (t - 36) / 3;
        satelliteMeshes.forEach((sat) => {
          sat.material.opacity = easeInOutCubic(progress);
          const angle = sat.userData.angle + t * sat.userData.speed;
          const altitude = sat.userData.altitude;
          sat.position.set(
            Math.cos(angle) * altitude,
            Math.sin(t + sat.userData.angle) * 20,
            Math.sin(angle) * altitude
          );
          sat.rotation.x += 0.01;
          sat.rotation.y += 0.02;
        });
      }

      // t=39-42s: Brain overlay
      if (t >= 39 && t <= 42) {
        const progress = (t - 39) / 3;
        brain.material.opacity = easeInOutCubic(progress) * 0.3;
        const breathe = Math.sin(t * 2) * 0.02 + 1;
        brainGroup.scale.set(breathe, breathe, breathe);
      }

      // ─────────────────────────────────────────────────────────────
      // ACT 4: THE ULTIMATE PULSE
      // ─────────────────────────────────────────────────────────────
      
      // t=45-48s: The Pulse
      if (t >= 45 && t <= 48) {
        const pulseIntensity = Math.sin((t - 45) * Math.PI * 2) * 0.5 + 0.5;
        
        cityMeshes.hcmc.light.intensity = 50 * pulseIntensity;
        bloomPass.strength = 2.5 + pulseIntensity * 2;
        
        Object.values(cityMeshes).forEach((city) => {
          city.light.intensity = 10 + pulseIntensity * 20;
          city.mesh.scale.set(1 + pulseIntensity * 0.5, 1 + pulseIntensity * 0.5, 1 + pulseIntensity * 0.5);
        });
      }

      // t=48-50s: Global synchronization peak
      if (t >= 48 && t <= 50) {
        const heartbeat = Math.sin(t * Math.PI) * 0.3 + 0.7;
        earth.scale.set(heartbeat, heartbeat, heartbeat);
        brainGroup.scale.set(heartbeat, heartbeat, heartbeat);
      }

      // ─────────────────────────────────────────────────────────────
      // ACT 5: ETERNAL PRESENCE
      // ─────────────────────────────────────────────────────────────
      
      // t=52-60s: Living system loop
      if (t >= 52) {
        camera.position.set(0, 180, 420); // Hero angle
        camera.lookAt(0, 0, 0);
        
        earth.rotation.y += 0.0005;
        
        const breathe = Math.sin(t) * 0.02 + 1;
        brainGroup.scale.set(breathe, breathe, breathe);
        
        // Gentle pulses
        Object.values(cityMeshes).forEach((city, i) => {
          const pulse = Math.sin(t * 0.5 + i) * 0.5 + 0.5;
          city.light.intensity = 5 + pulse * 3;
        });
        
        // Loop after 60s
        if (t >= 60) {
          time = 0;
        }
      }

      // Continuous satellite orbits
      if (t >= 36) {
        satelliteMeshes.forEach((sat) => {
          const angle = sat.userData.angle + t * sat.userData.speed;
          const altitude = sat.userData.altitude;
          sat.position.set(
            Math.cos(angle) * altitude,
            Math.sin(t * 0.3 + sat.userData.angle) * 20,
            Math.sin(angle) * altitude
          );
          sat.rotation.x += 0.01;
          sat.rotation.y += 0.02;
        });
      }

      // Particle rotation
      particles.rotation.y += 0.0002;
      particles.rotation.x += 0.0001;

      composer.render();
    };

    // ═══════════════════════════════════════════════════════════════
    // INTERACTION
    // ═══════════════════════════════════════════════════════════════
    
    const onKeyDown = (event) => {
      if (event.code === 'Space') {
        setIsPlaying(prev => !prev);
      }
      if (event.key === 'r' || event.key === 'R') {
        time = 0;
      }
    };

    window.addEventListener('keydown', onKeyDown);

    // Start animation
    setIsPlaying(true);
    animate();

    // ═══════════════════════════════════════════════════════════════
    // RESPONSIVE
    // ═══════════════════════════════════════════════════════════════
    
    const onWindowResize = () => {
      camera.aspect = containerRef.current.clientWidth / containerRef.current.clientHeight;
      camera.updateProjectionMatrix();
      renderer.setSize(containerRef.current.clientWidth, containerRef.current.clientHeight);
      composer.setSize(containerRef.current.clientWidth, containerRef.current.clientHeight);
    };

    window.addEventListener('resize', onWindowResize);

    // ═══════════════════════════════════════════════════════════════
    // CLEANUP
    // ═══════════════════════════════════════════════════════════════
    
    return () => {
      window.removeEventListener('resize', onWindowResize);
      window.removeEventListener('keydown', onKeyDown);
      if (animationRef.current) {
        cancelAnimationFrame(animationRef.current);
      }
      containerRef.current?.removeChild(renderer.domElement);
      renderer.dispose();
    };
  }, [isPlaying]);

  return (
    <div
      ref={containerRef}
      style={{
        width: '100%',
        height: '100vh',
        position: 'relative',
        overflow: 'hidden',
        background: '#000510'
      }}
    />
  );
};

export default ConsciousnessEvolution;
