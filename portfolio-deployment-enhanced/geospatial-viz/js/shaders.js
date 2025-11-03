// Lightweight GLSL shader snippets used by neural-hero.js
export const particleVertex = `
precision highp float;
uniform float time;
uniform float size;
uniform float pulseSpeed;
attribute float phase;
attribute vec3 colorAttr;
varying vec3 vColor;
varying float vPhase;
void main(){
  vColor = colorAttr;
  vPhase = phase;
  vec3 pos = position;
  float pulse = sin(time * pulseSpeed + phase) * 0.5 + 0.5;
  vec3 displaced = pos * (1.0 + pulse * 0.08);
  vec4 mvPosition = modelViewMatrix * vec4(displaced, 1.0);
  gl_PointSize = size * (150.0 / -mvPosition.z);
  gl_Position = projectionMatrix * mvPosition;
}
`;

export const particleFragment = `
precision highp float;
uniform vec3 glowColor;
uniform float glowIntensity;
varying vec3 vColor;
varying float vPhase;
void main(){
  vec2 coord = gl_PointCoord - vec2(0.5);
  float dist = length(coord);
  if(dist > 0.5) discard;
  float alpha = 1.0 - smoothstep(0.0, 0.5, dist);
  float pulse = 0.6 + 0.4 * vPhase;
  vec3 col = vColor * glowIntensity * pulse;
  gl_FragColor = vec4(col, alpha);
}
`;

export const lineVertex = `
precision highp float;
attribute float lineU;
varying float vU;
void main(){
  vU = lineU;
  gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}
`;

export const lineFragment = `
precision highp float;
uniform float time;
uniform vec3 color;
uniform float speed;
varying float vU;
void main(){
  float t = fract(vU + time * speed);
  float intensity = exp(-abs(t - 0.5) * 8.0);
  vec3 col = color * intensity;
  gl_FragColor = vec4(col, intensity);
}
`;
