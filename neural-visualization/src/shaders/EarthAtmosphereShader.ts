import * as THREE from 'three'

export const EarthAtmosphereShader = {
  uniforms: {
    uTime: { value: 0 },
    uEarthRadius: { value: 2.0 },
    uDayTexture: { value: null },
    uNightTexture: { value: null },
    uCloudTexture: { value: null },
    uSunDirection: { value: new THREE.Vector3(1, 0, 0) }
  },
  
  vertexShader: `
    uniform float uTime;
    uniform float uEarthRadius;
    
    varying vec2 vUv;
    varying vec3 vNormal;
    varying vec3 vPosition;
    varying vec3 vWorldPosition;
    
    void main() {
      vUv = uv;
      vNormal = normalize(normalMatrix * normal);
      vPosition = position;
      vWorldPosition = (modelMatrix * vec4(position, 1.0)).xyz;
      
      gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
    }
  `,
  
  fragmentShader: `
    uniform float uTime;
    uniform float uEarthRadius;
    uniform vec3 uSunDirection;
    
    varying vec2 vUv;
    varying vec3 vNormal;
    varying vec3 vPosition;
    varying vec3 vWorldPosition;
    
    // Rayleigh scattering approximation
    vec3 rayleighScattering(vec3 direction, vec3 sunDirection) {
      float cosTheta = dot(direction, sunDirection);
      float cosTheta2 = cosTheta * cosTheta;
      
      // Rayleigh phase function
      float phase = 3.0 / (16.0 * 3.14159) * (1.0 + cosTheta2);
      
      // Scattering coefficients for Earth's atmosphere
      vec3 betaR = vec3(5.8e-6, 1.35e-5, 3.31e-5); // Rayleigh scattering
      
      return betaR * phase;
    }
    
    // Simple noise function for surface variation
    float noise(vec2 uv) {
      return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
    }
    
    void main() {
      // Base Earth colors
      vec3 dayColor = vec3(0.2, 0.4, 0.8);   // Ocean blue
      vec3 landColor = vec3(0.3, 0.6, 0.2);  // Land green
      vec3 nightColor = vec3(0.05, 0.05, 0.2); // Dark blue
      
      // Determine day/night based on sun direction
      vec3 viewDirection = normalize(cameraPosition - vWorldPosition);
      float sunDot = dot(vNormal, uSunDirection);
      bool isDay = sunDot > 0.0;
      
      // Mix day and night colors
      vec3 baseColor = mix(nightColor, dayColor, smoothstep(-0.1, 0.1, sunDot));
      
      // Add land/ocean variation
      float landMask = noise(vUv * 10.0) > 0.3 ? 1.0 : 0.0;
      baseColor = mix(baseColor, landColor, landMask * 0.3);
      
      // Add city lights on night side
      if (!isDay) {
        float cityLights = noise(vUv * 50.0);
        cityLights = smoothstep(0.7, 1.0, cityLights);
        baseColor += cityLights * vec3(1.0, 0.8, 0.4) * 0.5;
      }
      
      // Add atmospheric scattering
      vec3 scattering = rayleighScattering(viewDirection, uSunDirection);
      baseColor += scattering * 2.0;
      
      // Add Fresnel effect for atmosphere
      float fresnel = 1.0 - abs(dot(vNormal, viewDirection));
      fresnel = pow(fresnel, 2.0);
      
      vec3 atmosphereColor = vec3(0.3, 0.6, 1.0) * fresnel * 0.3;
      baseColor += atmosphereColor;
      
      // Add subtle rotation-based variation
      float rotationEffect = sin(vUv.x * 6.28 + uTime * 0.01) * 0.1;
      baseColor += rotationEffect * vec3(0.1, 0.2, 0.3);
      
      gl_FragColor = vec4(baseColor, 1.0);
    }
  `
}
