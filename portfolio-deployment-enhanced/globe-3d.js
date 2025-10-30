// 3D Globe with city pulses — lightweight script that uses the global THREE if available.
// This file purposely avoids importing module versions of Three to prevent multiple
// instances being loaded. It waits for `threeJsReady` when THREE isn't yet defined.

(function(){
    function startIfReady() {
        const container = document.getElementById('hero-visualization');
        if (!container) return;
        if (typeof window.THREE === 'undefined') {
            // Wait for loader to emit readiness
            window.addEventListener('threeJsReady', () => {
                try { initGlobe(); } catch (e) { console.warn('globe init failed after threeJsReady', e); }
            }, { once: true });
            return;
        }
        initGlobe();
    }

    function initGlobe(container) {
        const THREE = window.THREE;
        if (!container) container = document.getElementById('hero-visualization');
        if (!container) return;

    // Create renderer
    const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
    renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
    renderer.setSize(container.clientWidth, container.clientHeight);
    renderer.domElement.style.position = 'absolute';
    renderer.domElement.style.top = '0';
    renderer.domElement.style.left = '0';
    renderer.domElement.style.width = '100%';
    renderer.domElement.style.height = '100%';
    renderer.domElement.style.zIndex = '2';
    renderer.domElement.style.pointerEvents = 'auto';
    container.appendChild(renderer.domElement);

    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(45, container.clientWidth / container.clientHeight, 0.1, 1000);
    camera.position.set(0, 0, 3.6);

    // Controls (lightweight, limited)
    const ControlsClass = (THREE && THREE.OrbitControls) ? THREE.OrbitControls : window.OrbitControls;
    const controls = new (ControlsClass)(camera, renderer.domElement);
    controls.enablePan = false;
    controls.enableDamping = true;
    controls.dampingFactor = 0.08;
    controls.minDistance = 2.2;
    controls.maxDistance = 8;
    controls.autoRotate = true;
    controls.autoRotateSpeed = 0.2;

    // Lights
    const ambient = new THREE.AmbientLight(0xffffff, 0.9);
    scene.add(ambient);
    const dir = new THREE.DirectionalLight(0xffffff, 0.6);
    dir.position.set(5, 3, 5);
    scene.add(dir);

    // Globe
    const R = 1.5;
    const sphereGeo = new THREE.SphereGeometry(R, 64, 64);
    const loader = new THREE.TextureLoader();
    const textureUrl = 'https://unpkg.com/three-globe@2.31.0/example/img/earth-blue-marble.jpg';
    const earthMat = new THREE.MeshStandardMaterial({
        map: loader.load(textureUrl),
        roughness: 1,
        metalness: 0
    });
    const globe = new THREE.Mesh(sphereGeo, earthMat);
    scene.add(globe);

    // Atmosphere (fresnel glow)
    const atmosphereMat = new THREE.ShaderMaterial({
        uniforms: { viewVector: { value: camera.position }, c: { value: 0.5 }, p: { value: 2.0 }, glowColor: { value: new THREE.Color(0x0ea5e9) } },
        vertexShader: `varying float intensity; uniform vec3 viewVector; void main(){ vec3 vNormal = normalize(normalMatrix * normal); vec3 vNormel = normalize(vec3(modelViewMatrix * vec4(position, 1.0))); intensity = pow(c - dot(vNormal, vNormel), p); gl_Position = projectionMatrix * modelViewMatrix * vec4(position,1.0); }`,
        fragmentShader: `uniform vec3 glowColor; varying float intensity; void main(){ gl_FragColor = vec4(glowColor * intensity, intensity); }`,
        side: THREE.BackSide,
        blending: THREE.AdditiveBlending,
        transparent: true
    });
    const atmosphere = new THREE.Mesh(new THREE.SphereGeometry(R * 1.08, 64, 64), atmosphereMat);
    scene.add(atmosphere);

    // City markers and pulses
    const cities = [
        { name: 'Brussels', lat: 50.8503, lon: 4.3517 },
        { name: 'London', lat: 51.5074, lon: -0.1278 },
        { name: 'New York', lat: 40.7128, lon: -74.0060 },
        { name: 'San Francisco', lat: 37.7749, lon: -122.4194 },
        { name: 'Berlin', lat: 52.52, lon: 13.405 },
        { name: 'Singapore', lat: 1.3521, lon: 103.8198 },
        { name: 'Tokyo', lat: 35.6762, lon: 139.6503 },
        { name: 'Sydney', lat: -33.8688, lon: 151.2093 },
        { name: 'Toronto', lat: 43.6532, lon: -79.3832 },
        { name: 'Johannesburg', lat: -26.2041, lon: 28.0473 },
        { name: 'Sao Paulo', lat: -23.5505, lon: -46.6333 },
        { name: 'Dubai', lat: 25.2048, lon: 55.2708 }
    ];

    function latLonToVec3(lat, lon, radius) {
        const phi = (90 - lat) * (Math.PI / 180);
        const theta = (lon + 180) * (Math.PI / 180);
        const x = -((radius) * Math.sin(phi) * Math.cos(theta));
        const z = ((radius) * Math.sin(phi) * Math.sin(theta));
        const y = ((radius) * Math.cos(phi));
        return new THREE.Vector3(x, y, z);
    }

    const pulseGroup = new THREE.Group();
    scene.add(pulseGroup);

    const pulseMat = new THREE.MeshBasicMaterial({ color: 0x00d4ff, transparent: true, opacity: 0.9, blending: THREE.AdditiveBlending });
    cities.forEach((c, i) => {
        const pos = latLonToVec3(c.lat, c.lon, R + 0.02);
        const dot = new THREE.Mesh(new THREE.SphereGeometry(0.02, 8, 8), new THREE.MeshBasicMaterial({ color: 0x67e8f9 }));
        dot.position.copy(pos);
        dot.userData = { pulseScale: 1 + Math.random() * 0.8, speed: 0.6 + Math.random() * 0.8, t: Math.random() };
        pulseGroup.add(dot);

        // halo ring as a flat sprite (plane always facing camera)
        const ringGeo = new THREE.RingGeometry(0.035, 0.055, 24);
        const ringMat = new THREE.MeshBasicMaterial({ color: 0x00d4ff, transparent: true, opacity: 0.18, side: THREE.DoubleSide });
        const ring = new THREE.Mesh(ringGeo, ringMat);
        ring.position.copy(pos.clone().multiplyScalar(1.001));
        ring.lookAt(camera.position);
        ring.userData = { baseScale: 1 + Math.random() * 0.5, t: Math.random() };
        pulseGroup.add(ring);
    });

    // subtle starfield backdrop using Points
    const starsGeo = new THREE.BufferGeometry();
    const starCount = 400;
    const starPos = new Float32Array(starCount * 3);
    for (let i = 0; i < starCount; i++) {
        const r = 6 + Math.random() * 20;
        const theta = Math.random() * Math.PI * 2;
        const phi = Math.acos((Math.random() * 2) - 1);
        starPos[i*3] = r * Math.sin(phi) * Math.cos(theta);
        starPos[i*3+1] = r * Math.cos(phi);
        starPos[i*3+2] = r * Math.sin(phi) * Math.sin(theta);
    }
    starsGeo.setAttribute('position', new THREE.BufferAttribute(starPos, 3));
    const starsMat = new THREE.PointsMaterial({ color: 0xffffff, size: 0.02, transparent: true, opacity: 0.8 });
    const stars = new THREE.Points(starsGeo, starsMat);
    scene.add(stars);

    // animation loop
    const clock = new THREE.Clock();
    function animate() {
        requestAnimationFrame(animate);
        const t = clock.getElapsedTime();
        controls.update();

        // animate pulses
        pulseGroup.children.forEach((child) => {
            if (!child.userData) return;
            child.userData.t += (child.userData.speed || 0.8) * 0.01;
            const s = 1 + Math.sin(child.userData.t) * 0.6 * (child.userData.pulseScale || 1);
            child.scale.setScalar(s);
            if (child.material && child.material.opacity !== undefined) {
                child.material.opacity = Math.max(0.08, 0.9 * (1 - (s-1)));
            }
            if (child.geometry && child.geometry.type === 'RingGeometry') {
                // orient ring to camera
                child.lookAt(camera.position);
            }
        });

        // slow globe bobbing and atmosphere update
        globe.rotation.y += 0.0008;
        atmosphere.material.uniforms.viewVector.value = camera.position;

        renderer.render(scene, camera);
    }
    animate();

    // resize
    function onResize() {
        const w = container.clientWidth, h = container.clientHeight;
        camera.aspect = w / h;
        camera.updateProjectionMatrix();
        renderer.setSize(w, h);
    }
    window.addEventListener('resize', onResize);

    // Fade out when advanced visualization takes over
    function fadeOutAndDispose() {
        // animate opacity of DOM element
        const el = renderer.domElement;
        el.style.transition = 'opacity 600ms ease';
        el.style.opacity = '0';
        setTimeout(() => {
            try {
                container.removeChild(el);
                renderer.dispose();
            } catch (e) { /* noop */ }
        }, 700);
    }

    window.addEventListener('hero:upgraded', fadeOutAndDispose);
    // If threeJsReady is emitted later, we don't need to do anything here; the globe keeps running
    // Start: attempt immediate init (if THREE already present) or wait for threeJsReady
    startIfReady();

})();
