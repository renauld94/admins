import * as THREE from 'three'

export const BrainwaveShader = {
  uniforms: {
    uTime: { value: 0 },
    uBrainActivity: { value: 0.5 },
    uBaseColor: { value: new THREE.Color(0x2a2a3a) },
    uActiveColor: { value: new THREE.Color(0x00ff88) },
    uWaveSpeed: { value: 1.0 },
    uWaveAmplitude: { value: 0.1 }
  },
  
  vertexShader: `
    uniform float uTime;
    uniform float uWaveSpeed;
    uniform float uWaveAmplitude;
    
    varying vec2 vUv;
    varying vec3 vNormal;
    varying vec3 vPosition;
    varying float vWave;
    
    // Simplex noise for organic movement
    vec3 mod289(vec3 x) {
      return x - floor(x * (1.0 / 289.0)) * 289.0;
    }
    
    vec4 mod289(vec4 x) {
      return x - floor(x * (1.0 / 289.0)) * 289.0;
    }
    
    vec4 permute(vec4 x) {
      return mod289(((x*34.0)+1.0)*x);
    }
    
    vec4 taylorInvSqrt(vec4 r) {
      return 1.79284291400159 - 0.85373472095314 * r;
    }
    
    float snoise(vec3 v) {
      const vec2 C = vec2(1.0/6.0, 1.0/3.0);
      const vec4 D = vec4(0.0, 0.5, 1.0, 2.0);
      
      vec3 i = floor(v + dot(v, C.yyy));
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
      
      vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
      p0 *= norm.x;
      p1 *= norm.y;
      p2 *= norm.z;
      p3 *= norm.w;
      
      vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
      m = m * m;
      return 42.0 * dot(m*m, vec4(dot(p0,x0), dot(p1,x1), dot(p2,x2), dot(p3,x3)));
    }
    
    void main() {
      vUv = uv;
      vNormal = normalize(normalMatrix * normal);
      vPosition = position;
      
      // Add brainwave-like movement
      vec3 pos = position;
      
      // Multiple wave frequencies
      float wave1 = sin(pos.x * 2.0 + uTime * uWaveSpeed) * uWaveAmplitude
      float wave2 = cos(pos.y * 1.5 + uTime * uWaveSpeed * 1.3) * uWaveAmplitude * 0.7
      float wave3 = sin(pos.z * 2.5 + uTime * uWaveSpeed * 0.8) * uWaveAmplitude * 0.5
      
      // Add noise for organic feel
      float noise = snoise(pos * 3.0 + uTime * 0.5) * 0.05
      
      pos += normal * (wave1 + wave2 + wave3 + noise)
      
      vWave = wave1 + wave2 + wave3
      
      gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0)
    }
  `,
  
  fragmentShader: `
    uniform float uTime;
    uniform float uBrainActivity;
    uniform vec3 uBaseColor;
    uniform vec3 uActiveColor;
    
    varying vec2 vUv;
    varying vec3 vNormal;
    varying vec3 vPosition;
    varying float vWave;
    
    void main() {
      // Base brain color
      vec3 color = uBaseColor;
      
      // Add activity-based coloring
      float activity = smoothstep(0.0, 1.0, uBrainActivity + vWave * 0.5)
      color = mix(color, uActiveColor, activity)
      
      // Add brainwave patterns
      float wavePattern = sin(vPosition.x * 5.0 + uTime * 2.0) * 
                         cos(vPosition.y * 3.0 + uTime * 1.5) * 
                         sin(vPosition.z * 4.0 + uTime * 2.5)
      
      wavePattern = smoothstep(0.3, 1.0, wavePattern)
      color += wavePattern * vec3(0.2, 0.8, 0.4) * 0.3
      
      // Add neural pathway highlights
      float pathways = sin(vPosition.x * 10.0 + vPosition.y * 8.0 + uTime * 3.0)
      pathways = smoothstep(0.7, 1.0, pathways)
      color += pathways * vec3(0.0, 1.0, 0.5) * 0.2
      
      // Fresnel effect for depth
      vec3 viewDirection = normalize(cameraPosition - vPosition)
      float fresnel = 1.0 - abs(dot(vNormal, viewDirection))
      fresnel = pow(fresnel, 2.0)
      
      color += fresnel * vec3(0.1, 0.4, 0.2) * 0.5
      
      // Add subtle pulsing
      float pulse = sin(uTime * 3.0) * 0.1 + 0.9
      color *= pulse
      
      gl_FragColor = vec4(color, 0.9)
    }
  `
}
