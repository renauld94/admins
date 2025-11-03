// PURE CINEMATIC NEURAL-TO-COSMIC JOURNEY HERO
// Act 1: Neural Genesis — Individual Consciousness
// Modular act system for seamless visual storytelling

// PURE CINEMATIC NEURAL-TO-COSMIC JOURNEY HERO — ALL ACTS

var epicCameraPath = [
  { t: 0, pos: [0,0,0.5], look: [0,0,0], fov: 85 },
  { t: 8, pos: [2,1,2], look: [0,0,0.3], fov: 80 }, // dolly-in
  { t: 15, pos: [0,0,5], look: [0,0,0], fov: 75 },
  { t: 20, pos: [5,5,10], look: [2,2,0], fov: 70 }, // orbit
  { t: 35, pos: [20,15,35], look: [0,5,0], fov: 65 },
  { t: 50, pos: [40,25,60], look: [0,8,0], fov: 60 },
  { t: 65, pos: [80,50,100], look: [0,10,0], fov: 55 },
  { t: 85, pos: [120,70,150], look: [0,15,0], fov: 52 },
  { t: 95, pos: [250,150,300], look: [0,30,0], fov: 45 },
  { t: 105, pos: [0,0,0.5], look: [0,0,0], fov: 85 }
];

var renderer, scene, camera, composer;
var clock, act = 0;
var neuronMesh, burstGroup, brainGroup, cityNode, regionNodes, globalNodes, brainOverlay, satellites, galaxy, returnTrails;

function setupScene() {
  scene = new THREE.Scene();
  scene.background = new THREE.Color(0x000000);
  camera = new THREE.PerspectiveCamera(85, window.innerWidth/window.innerHeight, 0.01, 2000);
  camera.position.set(0,0,0.5);
  renderer = new THREE.WebGLRenderer({ antialias: true });
  renderer.setSize(window.innerWidth, window.innerHeight);
  renderer.setClearColor(0x000000, 1);
  document.body.appendChild(renderer.domElement);

  // Bloom (UnrealBloomPass from three-loader)
  if (window.EffectComposer && window.RenderPass && window.UnrealBloomPass) {
    composer = new window.EffectComposer(renderer);
    composer.addPass(new window.RenderPass(scene, camera));
    var bloomPass = new window.UnrealBloomPass(
      new THREE.Vector2(window.innerWidth, window.innerHeight),
      2.5, 0.7, 0.5
    );
    composer.addPass(bloomPass);
  }

  // Act 1: Neural Genesis
  createNeuronGenesis();
}

function clearScene() {
  while (scene.children.length > 0) scene.remove(scene.children[0]);
}

function createNeuronGenesis() {
  clearScene();
  // Central neuron membrane (glowing sphere)
  var membraneGeo = new THREE.SphereGeometry(0.3, 64, 64);
  var membraneMat = new THREE.MeshPhysicalMaterial({
    color: 0x00d4ff,
    emissive: 0x8b5cf6,
    emissiveIntensity: 0.7,
    roughness: 0.2,
    metalness: 0.1,
    transparent: true,
    opacity: 0.85,
    clearcoat: 0.6,
    clearcoatRoughness: 0.2,
  });
  neuronMesh = new THREE.Mesh(membraneGeo, membraneMat);
  neuronMesh.position.set(0,0,0);
  scene.add(neuronMesh);

  // Particle burst (dendritic tree)
  var burstCount = 1000;
  var burstGeo = new THREE.BufferGeometry();
  var positions = new Float32Array(burstCount * 3);
  var colors = new Float32Array(burstCount * 3);
  for (var i = 0; i < burstCount; i++) {
    var r = 0.3 + Math.random() * 1.2;
    var theta = Math.random() * Math.PI * 2;
    var phi = Math.acos(2 * Math.random() - 1);
    positions[3*i] = r * Math.sin(phi) * Math.cos(theta);
    positions[3*i+1] = r * Math.sin(phi) * Math.sin(theta);
    positions[3*i+2] = r * Math.cos(phi);
    var c = i < burstCount/2 ? [0, 212/255, 1] : [139/255, 92/255, 246/255];
    colors.set(c, 3*i);
  }
  burstGeo.setAttribute('position', new THREE.BufferAttribute(positions, 3));
  burstGeo.setAttribute('color', new THREE.BufferAttribute(colors, 3));
  var burstMat = new THREE.PointsMaterial({
    size: 0.06,
    vertexColors: true,
    transparent: true,
    opacity: 0.85,
    blending: THREE.AdditiveBlending,
  });
  burstGroup = new THREE.Points(burstGeo, burstMat);
  scene.add(burstGroup);
}

function createCollaborativeBrains() {
  clearScene();
  brainGroup = new THREE.Group();
  var colors = [0x00d4ff,0x8b5cf6,0xff6b35,0xffd700,0xffff00,0xff0066,0x00ff88,0x9d4edd];
  for (var i=0;i<8;i++) {
    var geo = new THREE.SphereGeometry(0.5, 32, 32);
    var mat = new THREE.MeshPhysicalMaterial({
      color: colors[i], emissive: colors[i], emissiveIntensity: 0.5, transparent:true, opacity:0.8
    });
    var mesh = new THREE.Mesh(geo, mat);
    var angle = i*Math.PI/4;
    mesh.position.set(Math.cos(angle)*2.5, Math.sin(angle)*2.5, 0);
    brainGroup.add(mesh);
  }
  scene.add(brainGroup);
  // Add glowing bridges (lines)
  for (var i=0;i<8;i++) {
    for (var j=i+1;j<8;j++) {
      var mat = new THREE.LineBasicMaterial({ color: 0xffffff, linewidth: 2, transparent:true, opacity:0.5 });
      var points = [];
      points.push(brainGroup.children[i].position);
      points.push(brainGroup.children[j].position);
      var geo = new THREE.BufferGeometry().setFromPoints(points);
      var line = new THREE.Line(geo, mat);
      scene.add(line);
    }
  }
}

function createCityNode() {
  clearScene();
  var geo = new THREE.SphereGeometry(1.2, 64, 64);
  var mat = new THREE.MeshPhysicalMaterial({ color:0x00d4ff, emissive:0x00d4ff, emissiveIntensity:1, transparent:true, opacity:0.9 });
  cityNode = new THREE.Mesh(geo, mat);
  cityNode.position.set(10,8,0);
  scene.add(cityNode);
}

function createRegionalNetwork() {
  clearScene();
  regionNodes = [];
  var cities = [
    {name:'HCMC',pos:[10,8,0],color:0x00d4ff},
    {name:'Singapore',pos:[12,10,2],color:0x00d4ff},
    {name:'Bangkok',pos:[8,14,2],color:0x8b5cf6},
    {name:'Jakarta',pos:[14,6,2],color:0xff6b35},
    {name:'Kuala Lumpur',pos:[16,12,2],color:0xffd700}
  ];
  for (var i=0;i<cities.length;i++) {
    var geo = new THREE.SphereGeometry(0.7, 32, 32);
    var mat = new THREE.MeshPhysicalMaterial({ color:cities[i].color, emissive:cities[i].color, emissiveIntensity:0.7, transparent:true, opacity:0.8 });
    var mesh = new THREE.Mesh(geo, mat);
    mesh.position.set.apply(mesh.position, cities[i].pos);
    scene.add(mesh);
    regionNodes.push(mesh);
  }
  // Connections
  for (var i=0;i<regionNodes.length;i++) {
    for (var j=i+1;j<regionNodes.length;j++) {
      var mat = new THREE.LineBasicMaterial({ color:0xffffff, linewidth:2, transparent:true, opacity:0.5 });
      var points = [];
      points.push(regionNodes[i].position);
      points.push(regionNodes[j].position);
      var geo = new THREE.BufferGeometry().setFromPoints(points);
      var line = new THREE.Line(geo, mat);
      scene.add(line);
    }
  }
}

function createGlobalNetwork() {
  clearScene();
  // Earth sphere
  var geo = new THREE.SphereGeometry(10, 64, 64);
  var mat = new THREE.MeshPhysicalMaterial({ color:0x222244, emissive:0x222244, emissiveIntensity:0.5, transparent:true, opacity:0.95 });
  var earth = new THREE.Mesh(geo, mat);
  earth.position.set(0,0,0);
  scene.add(earth);
  // Global nodes
  var nodes = [
    {name:'Berlin',pos:[-5,8,9],color:0x8b5cf6},
    {name:'San Francisco',pos:[-8,-10,8],color:0xff6b35},
    {name:'Tel Aviv',pos:[7,5,9],color:0xffd700},
    {name:'Seoul',pos:[10,-7,8],color:0xffff00},
    {name:'Sydney',pos:[12,12,7],color:0x00d4ff}
  ];
  globalNodes = [];
  for (var i=0;i<nodes.length;i++) {
    var geoN = new THREE.SphereGeometry(1.2, 32, 32);
    var matN = new THREE.MeshPhysicalMaterial({ color:nodes[i].color, emissive:nodes[i].color, emissiveIntensity:0.8, transparent:true, opacity:0.85 });
    var meshN = new THREE.Mesh(geoN, matN);
    meshN.position.set.apply(meshN.position, nodes[i].pos);
    scene.add(meshN);
    globalNodes.push(meshN);
  }
  // Connections
  for (var i=0;i<globalNodes.length;i++) {
    for (var j=i+1;j<globalNodes.length;j++) {
      var mat = new THREE.LineBasicMaterial({ color:0xffffff, linewidth:2, transparent:true, opacity:0.5 });
      var points = [];
      points.push(globalNodes[i].position);
      points.push(globalNodes[j].position);
      var geo = new THREE.BufferGeometry().setFromPoints(points);
      var line = new THREE.Line(geo, mat);
      scene.add(line);
    }
  }
}

function createBrainOverlay() {
  // Overlay wireframe brain mesh
  var geo = new THREE.TorusKnotGeometry(12, 0.8, 120, 16);
  var mat = new THREE.MeshBasicMaterial({ color:0xffffff, wireframe:true, transparent:true, opacity:0.3 });
  brainOverlay = new THREE.Mesh(geo, mat);
  brainOverlay.position.set(0,0,0);
  scene.add(brainOverlay);
}

function createSatellites() {
  satellites = [];
  var shapes = [
    {geo:new THREE.OctahedronGeometry(1.2),color:0x00d4ff},
    {geo:new THREE.IcosahedronGeometry(1.1),color:0x8b5cf6},
    {geo:new THREE.DodecahedronGeometry(1.3),color:0xff6b35},
    {geo:new THREE.BoxGeometry(1.1,1.1,1.1),color:0xffff00},
    {geo:new THREE.CylinderGeometry(0.8,1.2,2,12),color:0x00ff88}
  ];
  for (var i=0;i<shapes.length;i++) {
    var mat = new THREE.MeshPhysicalMaterial({ color:shapes[i].color, emissive:shapes[i].color, emissiveIntensity:0.7, transparent:true, opacity:0.85 });
    var mesh = new THREE.Mesh(shapes[i].geo, mat);
    mesh.position.set(Math.cos(i)*15, Math.sin(i)*15, 12+i*2);
    scene.add(mesh);
    satellites.push(mesh);
  }
}

function createGalaxy() {
  // Procedural galaxy: large particle system
  var starCount = 50000;
  var starGeo = new THREE.BufferGeometry();
  var positions = new Float32Array(starCount * 3);
  for (var i=0;i<starCount;i++) {
    var r = 80 + Math.random()*120;
    var theta = Math.random()*Math.PI*2;
    var phi = Math.acos(2*Math.random()-1);
    positions[3*i] = r*Math.sin(phi)*Math.cos(theta);
    positions[3*i+1] = r*Math.sin(phi)*Math.sin(theta);
    positions[3*i+2] = r*Math.cos(phi);
  }
  starGeo.setAttribute('position', new THREE.BufferAttribute(positions,3));
  var starMat = new THREE.PointsMaterial({ color:0xffffff, size:0.08, transparent:true, opacity:0.7 });
  galaxy = new THREE.Points(starGeo, starMat);
  scene.add(galaxy);
}

function createReturnTrails() {
  // Speed trail particles for return journey
  var trailCount = 20000;
  var trailGeo = new THREE.BufferGeometry();
  var positions = new Float32Array(trailCount * 3);
  for (var i=0;i<trailCount;i++) {
    positions[3*i] = Math.random()*2-1;
    positions[3*i+1] = Math.random()*2-1;
    positions[3*i+2] = Math.random()*2-1;
  }
  trailGeo.setAttribute('position', new THREE.BufferAttribute(positions,3));
  var trailMat = new THREE.PointsMaterial({ color:0x00d4ff, size:0.05, transparent:true, opacity:0.6 });
  returnTrails = new THREE.Points(trailGeo, trailMat);
  scene.add(returnTrails);
}

function setAct(t) {
  // Switch scene objects based on time
  if (t < 15) createNeuronGenesis();
  else if (t < 25) createCollaborativeBrains();
  else if (t < 35) createCityNode();
  else if (t < 50) createRegionalNetwork();
  else if (t < 65) createGlobalNetwork();
  else if (t < 75) { createGlobalNetwork(); createBrainOverlay(); }
  else if (t < 85) { createGlobalNetwork(); createBrainOverlay(); createSatellites(); }
  else if (t < 95) { createGlobalNetwork(); createBrainOverlay(); createSatellites(); createGalaxy(); }
  else if (t < 105) { createReturnTrails(); }
  else createNeuronGenesis();
}

function animate() {
  requestAnimationFrame(animate);
  if (!clock) clock = new THREE.Clock();
  var t = clock.getElapsedTime();
  // Cinematic Camera choreography with epic effects
  var cam = epicCameraPath[0];
  for (var i=1;i<epicCameraPath.length;i++) {
    if (t < epicCameraPath[i].t) { cam = epicCameraPath[i-1]; break; }
    if (t >= epicCameraPath[epicCameraPath.length-1].t) cam = epicCameraPath[epicCameraPath.length-1];
  }
  // Interpolate camera position, fov, and lookAt target
  var nextIdx = epicCameraPath.findIndex(p=>p.t>t);
  var prev = epicCameraPath[Math.max(0,nextIdx-1)];
  var next = epicCameraPath[Math.min(epicCameraPath.length-1,nextIdx)];
  var dt = (t-prev.t)/(next.t-prev.t);
  var basePos = new THREE.Vector3().fromArray(prev.pos).lerp(new THREE.Vector3().fromArray(next.pos), isNaN(dt)?0:dt);
  var baseFov = prev.fov + ((next.fov-prev.fov)*(isNaN(dt)?0:dt));
  var prevLook = new THREE.Vector3().fromArray(prev.look);
  var nextLook = new THREE.Vector3().fromArray(next.look);
  var lookTarget = prevLook.clone().lerp(nextLook, isNaN(dt)?0:dt);

  // Epic effects: camera shake and FOV pulse on act transitions
  var shake = 0;
  var pulse = 0;
  var actTimes = [0,15,25,35,50,65,85,95,105];
  for (var i=0;i<actTimes.length;i++) {
    var dist = Math.abs(t-actTimes[i]);
    if (dist < 1.2) {
      shake += (1.2-dist)*0.12*Math.sin(t*18+actTimes[i]);
      pulse += (1.2-dist)*2.5*Math.sin(t*8+actTimes[i]);
    }
  }
  camera.position.set(
    basePos.x + shake*Math.random(),
    basePos.y + shake*Math.random(),
    basePos.z + shake*Math.random()
  );
  camera.fov = baseFov + pulse;
  camera.lookAt(lookTarget);
  camera.updateProjectionMatrix();

  // Dramatic lighting/exposure animation
  if (scene && scene.children.length > 0) {
    var exposure = 1.0 + 0.25*Math.sin(t/3);
    renderer.toneMappingExposure = exposure;
    for (var i=0;i<scene.children.length;i++) {
      if (scene.children[i].material && scene.children[i].material.emissive) {
        scene.children[i].material.emissiveIntensity = 0.5 + 0.5*Math.sin(t/2 + i);
      }
    }
  }

  setAct(t);

  if (composer) composer.render();
  else renderer.render(scene, camera);
}

// Initialize only after both the DOM is ready and THREE.js has loaded.
// This prevents "THREE is not defined" errors when the module executes
// before the non-module three-loader.js finishes injecting the global.
(function() {
  var domReady = false;
  var started = false;

  function startIfReady() {
    if (started) return;
    // If DOM is ready and THREE is available, start immediately.
    if (domReady && (typeof THREE !== 'undefined')) {
      started = true;
      try { setupScene(); animate(); } catch (e) { console.error('Failed to start neural hero:', e); }
    }
  }

  // If THREE arrives before DOMContentLoaded, wait for DOM then start.
  window.addEventListener('threeJsReady', function() {
    // give three-loader a tiny moment to populate globals
    setTimeout(startIfReady, 20);
  });

  document.addEventListener('DOMContentLoaded', function() {
    domReady = true;
    startIfReady();
  });

  // Fallback: if DOM already ready (rare when module imported late) and THREE present
  if (document.readyState === 'interactive' || document.readyState === 'complete') {
    domReady = true;
    startIfReady();
  }
})();
