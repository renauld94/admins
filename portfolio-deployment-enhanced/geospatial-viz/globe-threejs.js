// Three.js globe with simple node rendering and WebSocket placeholder
import * as THREE from 'https://unpkg.com/three@0.153.0/build/three.module.js';
import { OrbitControls } from 'https://unpkg.com/three@0.153.0/examples/jsm/controls/OrbitControls.js';

// Module scope (no IIFE)
  const container = document.getElementById('container');

  const scene = new THREE.Scene();
  const camera = new THREE.PerspectiveCamera(50, window.innerWidth/window.innerHeight, 0.1, 2000);
  camera.position.set(0, 0, 400);

  const renderer = new THREE.WebGLRenderer({antialias:true});
  renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, (window.PerformancePatch && window.PerformancePatch.maxDevicePixelRatio) || 1));
  // Use container size for responsive rendering (handles mobile browser UI chrome)
  function fitRendererToContainer(){
    const w = container.clientWidth || window.innerWidth;
    const h = container.clientHeight || window.innerHeight;
    renderer.setSize(w, h);
    camera.aspect = w / h;
    camera.updateProjectionMatrix();
  }
  fitRendererToContainer();
  container.appendChild(renderer.domElement);

  const controls = new OrbitControls(camera, renderer.domElement);
  controls.enableDamping = true;
  controls.dampingFactor = 0.12;
  // Enhanced touch responsiveness for mobile
  controls.touches = { ONE: THREE.TOUCH.ROTATE, TWO: THREE.TOUCH.DOLLY_PAN, THREE: THREE.TOUCH.PAN };
  controls.rotateSpeed = 0.8;
  controls.zoomSpeed = 1.0;
  controls.panSpeed = 0.8;
  // Inertia simulation via continued damping
  controls.autoRotate = false;
  controls.autoRotateSpeed = 0;
  // Touch-specific enhancements
  renderer.domElement.addEventListener('touchstart', (ev) => {
    if(ev.touches.length === 2) {
      // Two-finger pinch: calculate initial distance
      const dx = ev.touches[0].clientX - ev.touches[1].clientX;
      const dy = ev.touches[0].clientY - ev.touches[1].clientY;
      renderer.domElement._initialPinchDistance = Math.sqrt(dx*dx + dy*dy);
    }
  }, { passive: true });
  renderer.domElement.addEventListener('touchmove', (ev) => {
    if(ev.touches.length === 2 && renderer.domElement._initialPinchDistance) {
      // Pinch zoom: calculate new distance and apply zoom delta
      const dx = ev.touches[0].clientX - ev.touches[1].clientX;
      const dy = ev.touches[0].clientY - ev.touches[1].clientY;
      const dist = Math.sqrt(dx*dx + dy*dy);
      const pinchDelta = (dist - renderer.domElement._initialPinchDistance) * 0.01;
      controls.dollyIn(1 - pinchDelta);
      renderer.domElement._initialPinchDistance = dist;
    }
  }, { passive: true });
  renderer.domElement.addEventListener('touchend', (ev) => {
    delete renderer.domElement._initialPinchDistance;
  }, { passive: true });

  // Earth
  const RADIUS = 120;
  const sphereGeo = new THREE.SphereGeometry(RADIUS, 64, 64);
  // Load a local earth texture if present (falls back to color if missing).
  let earthTexture;
  try {
    earthTexture = new THREE.TextureLoader().load('earth_day.jpg');
  } catch (e) {
    earthTexture = null;
  }
  const mat = new THREE.MeshPhongMaterial({
    map: earthTexture || null,
    color: earthTexture ? undefined : 0x0b3d62,
    specular: new THREE.Color('grey'),
  });
  const earth = new THREE.Mesh(sphereGeo, mat);
  scene.add(earth);

  // Lighting
  const hemi = new THREE.HemisphereLight(0xffffff, 0x444444, 0.6);
  scene.add(hemi);
  const dir = new THREE.DirectionalLight(0xffffff, 0.8);
  dir.position.set(5,3,5);
  scene.add(dir);

  // Nodes group (will hold instanced meshes)
  const nodesGroup = new THREE.Group();
  scene.add(nodesGroup);

  // Generate placeholder nodes (1000) distributed across globe
  function latLonToVec3(lat, lon, radius) {
    const phi = (90 - lat) * (Math.PI/180);
    const theta = (lon + 180) * (Math.PI/180);
    const x = - (radius) * Math.sin(phi) * Math.cos(theta);
    const z = (radius) * Math.sin(phi) * Math.sin(theta);
    const y = (radius) * Math.cos(phi);
    return new THREE.Vector3(x,y,z);
  }

  // Custom shader material for pulse animation
  function createPulseMaterial(colorHex) {
    const color = typeof colorHex === 'number' ? colorHex : parseInt((colorHex || '#00d4ff').replace('#','0x'));
    return new THREE.ShaderMaterial({
      uniforms: {
        baseColor: { value: new THREE.Color(color) },
        time: { value: 0 }
      },
      vertexShader: `
        attribute float pulse;
        varying float vPulse;
        void main() {
          vPulse = pulse;
          vec3 transformed = position * (1.0 + vPulse * 1.8);
          gl_Position = projectionMatrix * modelViewMatrix * vec4(transformed, 1.0);
        }
      `,
      fragmentShader: `
        uniform vec3 baseColor;
        varying float vPulse;
        void main() {
          float alpha = 0.8 + 0.2 * vPulse;
          gl_FragColor = vec4(baseColor, alpha);
        }
      `,
    });
  }

  const NODE_COUNT = 1000;
  // nodeInstances will hold per-node metadata for mapping and animations
  const nodeInstances = [];
  // Keep lat/lon in userData for each node so we can map events to nearest node
  const nodeTypes = ['healthcare','research','infrastructure','fishing','educational','environmental','communications','energy','transportation'];
  const typeColors = { 
    healthcare: '#00d4ff', 
    research: '#8b5cf6', 
    infrastructure: '#10b981', 
    fishing: '#f59e0b',
    educational: '#ec4899',
    environmental: '#06b6d4',
    communications: '#f43f5e',
    energy: '#eab308',
    transportation: '#a855f7'
  };
  const typeDescriptions = {
    healthcare: 'Medical facilities, hospitals, clinics',
    research: 'Universities, labs, research centers',
    infrastructure: 'Critical infrastructure & utilities',
    fishing: 'Fishing zones & maritime activity',
    educational: 'Educational institutions & training',
    environmental: 'Environmental & conservation sites',
    communications: 'Telecom & broadcast infrastructure',
    energy: 'Power plants & energy infrastructure',
    transportation: 'Transportation hubs & networks'
  };
  const typeCounts = { healthcare:0, research:0, infrastructure:0, fishing:0, educational:0, environmental:0, communications:0, energy:0, transportation:0 };

  // Pre-generate node metadata (lat/lon, type) then create instanced meshes by type
  const tempNodes = [];
  for (let i=0;i<NODE_COUNT;i++){
    const lat = (Math.random()*180) - 90;
    const lon = (Math.random()*360) - 180;
    const t = nodeTypes[Math.floor(Math.random()*nodeTypes.length)];
    tempNodes.push({lat, lon, type: t});
    typeCounts[t] = (typeCounts[t] || 0) + 1;
  }

  // Create one InstancedMesh per type
  const instancedMeshes = {}; // type -> {mesh, nextIndex}
  const sphereGeom = new THREE.SphereGeometry(1.4, 6, 6);
  nodeTypes.forEach(t => {
    const count = typeCounts[t] || 0;
    const mat = createPulseMaterial(typeColors[t]);
    const im = new THREE.InstancedMesh(sphereGeom, mat, Math.max(count,1));
    im.instanceMatrix.setUsage(THREE.DynamicDrawUsage);
    im.name = 'inst_' + t;
    im.userData.type = t;
    // Add per-instance pulse attribute
    const pulseArray = new Float32Array(Math.max(count,1));
    im.geometry.setAttribute('pulse', new THREE.InstancedBufferAttribute(pulseArray, 1));
    instancedMeshes[t] = { mesh: im, nextIndex: 0, pulseArray };
    nodesGroup.add(im);
  });

  // Populate instances and nodeInstances metadata
  const tmpMat = new THREE.Matrix4();
  for (let i=0;i<tempNodes.length;i++){
    const n = tempNodes[i];
    const pos = latLonToVec3(n.lat, n.lon, RADIUS + 1.8);
    const imObj = instancedMeshes[n.type];
    const instanceId = imObj.nextIndex++;
    // build matrix: translate to pos, no rotation needed, scale 1
    tmpMat.identity();
    tmpMat.setPosition(pos);
    imObj.mesh.setMatrixAt(instanceId, tmpMat);
    // store metadata mapping global index -> instance
    nodeInstances.push({ index: i, type: n.type, lat: n.lat, lon: n.lon, instanceId: instanceId, instancedMesh: imObj.mesh });
  }

  // mark instanceMatrix updated
  Object.values(instancedMeshes).forEach(obj => obj.mesh.instanceMatrix.needsUpdate = true);
  // expose counts in the DOM if present
  const nodeCountEl = document.getElementById('nodeCount');
  if(nodeCountEl) nodeCountEl.textContent = NODE_COUNT;

  // Populate legend for 3D globe dynamically
  function populateGlobeLegend(){
    const legendBody = document.querySelector('#legend .legend-body');
    if(!legendBody) return;
    legendBody.innerHTML = '';
    
    // Add search/filter input
    const searchContainer = document.createElement('div');
    searchContainer.style.cssText = 'margin-bottom:10px;padding:8px;background:rgba(255,255,255,0.05);border-radius:4px;';
    const searchInput = document.createElement('input');
    searchInput.type = 'text';
    searchInput.placeholder = 'Search node types...';
    searchInput.style.cssText = 'width:100%;padding:6px 8px;border:1px solid rgba(255,255,255,0.2);border-radius:3px;background:rgba(255,255,255,0.1);color:#fff;font-size:12px;';
    searchContainer.appendChild(searchInput);
    legendBody.appendChild(searchContainer);
    
    // Add legend items container
    const itemsContainer = document.createElement('div');
    itemsContainer.id = 'legend-items-container';
    legendBody.appendChild(itemsContainer);
    
    // Render legend items with optional filtering
    function renderLegendItems(filterText = '') {
      itemsContainer.innerHTML = '';
      nodeTypes.forEach(t=>{
        if(filterText && !t.includes(filterText.toLowerCase())) return;
        
        const div = document.createElement('div');
        div.className = 'legend-item';
        div.tabIndex = 0;
        div.setAttribute('role','button');
        div.setAttribute('data-type', t);
        div.style.cssText = 'cursor:pointer;padding:8px;border-radius:4px;transition:background 0.2s;margin-bottom:4px;';
        
        const title = t.charAt(0).toUpperCase() + t.slice(1);
        const count = typeCounts[t] || 0;
        const desc = typeDescriptions[t] || '';
        
        div.innerHTML = `
          <label style="display:flex;align-items:center;gap:8px;cursor:pointer;width:100%;">
            <input type="checkbox" checked data-type="${t}" style="cursor:pointer;">
            <span style="width:12px;height:12px;border-radius:3px;display:inline-block;background:${typeColors[t]};flex-shrink:0;"></span>
            <div style="flex:1;min-width:0;">
              <div style="font-weight:600;font-size:12px;">${title}</div>
              <div style="font-size:10px;color:rgba(255,255,255,0.6);margin-top:2px;">${count} nodes</div>
              <div style="font-size:9px;color:rgba(255,255,255,0.5);margin-top:2px;">${desc}</div>
            </div>
          </label>
        `;
        
        itemsContainer.appendChild(div);
        const checkbox = div.querySelector('input[type=checkbox]');
        
        // Hover effect
        div.addEventListener('mouseenter', ()=>{ div.style.background = 'rgba(255,255,255,0.1)'; });
        div.addEventListener('mouseleave', ()=>{ div.style.background = 'transparent'; });
        
        // restore checkbox state from localStorage
        try{
          const stored = localStorage.getItem('globe_legend_' + t);
          if(stored === '0') { checkbox.checked = false; }
        } catch(_){}
        
        checkbox.addEventListener('change', (ev)=>{ toggleNodeType(t, checkbox.checked); try{ localStorage.setItem('globe_legend_' + t, checkbox.checked ? '1' : '0'); }catch(_){} });
        div.addEventListener('keydown', (ev)=>{ if(ev.key==='Enter' || ev.key===' ') { ev.preventDefault(); checkbox.checked = !checkbox.checked; checkbox.dispatchEvent(new Event('change')); } });
      });
    }
    
    // Search/filter handler
    searchInput.addEventListener('input', (ev) => {
      renderLegendItems(ev.target.value);
    });
    
    // Initial render
    renderLegendItems();
  }

  function toggleNodeType(type, show){
    const obj = instancedMeshes[type];
    if(obj && obj.mesh){
      obj.mesh.visible = !!show;
    }
  }

  // initialize globe legend
  populateGlobeLegend();
  document.getElementById('nodeCount').textContent = NODE_COUNT;

  // Pulsing via per-instance attribute; animate loop will update pulse values
  const activePulses = []; // {index, start, duration}
  function pulseNode(index){
    const idx = index % nodeInstances.length;
    activePulses.push({ index: idx, start: performance.now(), duration: 600 });
  }

  // Find nearest node by event latitude/longitude
  function findNearestNodeByLatLon(lat, lon){
    const v = latLonToVec3(lat, lon, RADIUS + 1.8).normalize();
    let best = {idx:0, score:-Infinity};
    for(let i=0;i<nodeInstances.length;i++){
      const n = nodeInstances[i];
      const nv = latLonToVec3(n.lat, n.lon, RADIUS + 1.8).normalize();
      const score = nv.dot(v);
      if(score > best.score){ best.score = score; best.idx = i; }
    }
    return best.idx;
  }

  // WebSocket placeholder - connect and update node pulses when messages arrive
  let ws;
  function tryConnectWS(){
    try{
      ws = new WebSocket('ws://localhost:8000/ws/realtime');
      ws.onopen = ()=>{ document.getElementById('wsStatus').textContent = 'connected'; };
      ws.onclose = ()=>{ document.getElementById('wsStatus').textContent = 'disconnected'; setTimeout(tryConnectWS,2000); };
      ws.onerror = ()=>{ document.getElementById('wsStatus').textContent = 'error'; };
      ws.onmessage = (ev)=>{
        // Expect JSON { nodeId: <n> } or array
          try{
            const data = JSON.parse(ev.data);
            // If earthquake events arrive as objects with coords, map to nearest node
            if(data && data.type === 'earthquakes' && Array.isArray(data.events)){
              // Update live events stat card
              const eventsList = document.getElementById('eventsList');
              const eventCount = document.getElementById('eventCount');
              if(eventsList) {
                eventsList.innerHTML = '';
                data.events.slice(0, 5).forEach((evt, i) => {
                  const div = document.createElement('div');
                  div.className = 'event-item';
                  const mag = evt.mag ? evt.mag.toFixed(1) : '?';
                  const place = evt.place ? evt.place.substring(0, 40) : 'Unknown';
                  div.innerHTML = `<div><span class="mag">${mag}</span> — ${place}</div>`;
                  eventsList.appendChild(div);
                  // pulse the node
                  const c = evt.coords;
                  if(c && typeof c.lat === 'number' && typeof c.lon === 'number'){
                    const idx = findNearestNodeByLatLon(c.lat, c.lon);
                    pulseNode(idx);
                  } else {
                    pulseNode(Math.floor(Math.random()*NODE_COUNT));
                  }
                });
                if(eventCount) eventCount.textContent = data.count || data.events.length;
              }
            } else if(Array.isArray(data)) {
              data.forEach(d=>pulseNode(d.nodeId || Math.floor(Math.random()*NODE_COUNT)));
            } else {
              // Accept direct {nodeId: n} messages too
              pulseNode(data.nodeId || Math.floor(Math.random()*NODE_COUNT));
            }
          }catch(e){
            // fallback: random pulse
            pulseNode(Math.floor(Math.random()*NODE_COUNT));
          }
      };
    }catch(e){
      setTimeout(tryConnectWS,2000);
    }
  }
  // attempt connect but do not block if no ws server
  tryConnectWS();

  // Resize handling (use container dims)
  window.addEventListener('resize', ()=>{
    fitRendererToContainer();
  });

  // UI: legend/menu toggles (responsive)
  const menuToggle = document.getElementById('menuToggle');
  const legendEl = document.getElementById('legend');
  const legendClose = document.getElementById('legendClose');
  if(menuToggle && legendEl){
    menuToggle.addEventListener('click', ()=>{
      const visible = legendEl.getAttribute('data-visible') === '1';
      const next = !visible;
      legendEl.setAttribute('data-visible', next ? '1' : '0');
      legendEl.style.display = next ? 'block' : 'none';
      try { localStorage.setItem('globe_legend_open', next ? '1' : '0'); } catch(_){}
    });
    legendClose.addEventListener('click', ()=>{ legendEl.setAttribute('data-visible','0'); legendEl.style.display = 'none'; });
    // Default: show legend on wide screens, hide on small
    try{
      const persisted = localStorage.getItem('globe_legend_open');
      if(persisted === '1') { legendEl.style.display = 'block'; legendEl.setAttribute('data-visible','1'); }
      else if (persisted === '0') { legendEl.style.display = 'none'; legendEl.setAttribute('data-visible','0'); }
      else {
        if(window.innerWidth <= 768){ legendEl.style.display = 'none'; legendEl.setAttribute('data-visible','0'); }
        else { legendEl.style.display = 'block'; legendEl.setAttribute('data-visible','1'); }
      }
    }catch(_){}
  }

  // Animation loop: update pulses and render
  function animate(){
    requestAnimationFrame(animate);
    const now = performance.now();
    // update active pulses
    if(activePulses.length){
      for(let i=activePulses.length-1;i>=0;i--){
        const p = activePulses[i];
        const t = Math.min(1, (now - p.start)/p.duration);
        const ni = nodeInstances[p.index];
        if(!ni) { activePulses.splice(i,1); continue; }
        // set pulse value for this instance
        const obj = instancedMeshes[ni.type];
        obj.pulseArray[ni.instanceId] = Math.sin(t*Math.PI);
        obj.mesh.geometry.attributes.pulse.needsUpdate = true;
        if(t>=1){
          obj.pulseArray[ni.instanceId] = 0;
          activePulses.splice(i,1);
        }
      }
    }
    earth.rotation.y += 0.0008;
    controls.update();
    renderer.render(scene, camera);
  }
  animate();


