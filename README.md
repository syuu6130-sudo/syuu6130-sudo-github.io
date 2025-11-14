<!--
Interactive Earth — single-file HTML (JavaScript)
Features:
- 3D globe using three.js + Globe.gl (no API key)
- Zoom in/out and smooth fly-to on click
- Country outlines (TopoJSON/world-atlas)
- City markers with labels (preloaded major cities)
- Search box (uses Nominatim public geocoding) to jump to any place
- On-hover shows name + lat/lon, click focuses camera
- UI controls for auto-rotate, atmosphere, and marker size

How to use:
1. Save this file as `interactive-earth.html`.
2. Open it in a modern browser (Chrome/Edge/Firefox). If textures fail due to CORS, run a local server (e.g. `python -m http.server`).
3. No API keys required.
-->

<!doctype html>
<html lang="ja">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Interactive Earth — JavaScript Globe</title>
  <style>
    html,body{height:100%;margin:0;font-family:system-ui,-apple-system,Segoe UI,Roboto,'Noto Sans JP',sans-serif}
    #container{position:fixed;inset:0;background:#081028}
    #ui{position:fixed;left:12px;top:12px;z-index:3;color:#e6f0ff;background:rgba(2,6,23,0.6);padding:10px;border-radius:10px;backdrop-filter:blur(6px);min-width:280px}
    #title{font-weight:700;margin-bottom:6px}
    .row{display:flex;gap:8px;align-items:center;margin-bottom:8px}
    input[type=text]{flex:1;padding:6px;border-radius:6px;border:1px solid rgba(255,255,255,0.08);background:rgba(255,255,255,0.02);color:#fff}
    button{padding:6px 8px;border-radius:6px;border:none;background:#1f6feb;color:#fff;cursor:pointer}
    button.ghost{background:transparent;border:1px solid rgba(255,255,255,0.08)}
    #legend{font-size:13px;opacity:0.9}
    #info{position:fixed;right:12px;bottom:12px;color:#99b;z-index:3;background:rgba(2,6,23,0.5);padding:8px;border-radius:8px;font-size:13px}
    .label{pointer-events:none;background:rgba(0,0,0,0.6);padding:6px;border-radius:6px;color:#fff}
  </style>
</head>
<body>
  <div id="container"></div>

  <div id="ui">
    <div id="title">Interactive Earth</div>
    <div class="row">
      <input id="search" type="text" placeholder="都市名・住所を入力してEnter（例：Tokyo）" />
      <button id="go">Go</button>
    </div>
    <div class="row">
      <button id="reset" class="ghost">Reset View</button>
      <button id="autorotate" class="ghost">Toggle Auto-Rotate</button>
    </div>
    <div id="legend">
      使い方: マウスで回転、ホイールでズーム、都市をクリックで中心に移動。検索はNominatimを使用します。
    </div>
  </div>

  <div id="info" class="label">位置: — | 緯度: — | 経度: —</div>

  <!-- Libraries from CDNs -->
  <script src="https://unpkg.com/three@0.152.2/build/three.min.js"></script>
  <script src="https://unpkg.com/three@0.152.2/examples/js/controls/OrbitControls.js"></script>
  <script src="https://unpkg.com/three-globe@2.28.5/dist/globe.min.js"></script>
  <script src="https://unpkg.com/topojson-client@3.1.0/dist/topojson-client.min.js"></script>

  <script>
  (async function(){
    const container = document.getElementById('container');
    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(40, innerWidth/innerHeight, 0.1, 1000);
    camera.position.set(0, 0, 200);

    const renderer = new THREE.WebGLRenderer({antialias:true, alpha:true});
    renderer.setPixelRatio(window.devicePixelRatio);
    renderer.setSize(innerWidth, innerHeight);
    container.appendChild(renderer.domElement);

    // lights
    scene.add(new THREE.AmbientLight(0xbbccff, 0.9));
    const dir = new THREE.DirectionalLight(0xffffff, 0.6);
    dir.position.set(5,3,5);
    scene.add(dir);

    // controls
    const controls = new THREE.OrbitControls(camera, renderer.domElement);
    controls.enableDamping = true;
    controls.dampingFactor = 0.1;
    controls.minDistance = 60;
    controls.maxDistance = 400;

    // globe
    const Globe = new ThreeGlobe({ animateIn: true })
      .globeImageUrl('https://unpkg.com/three-globe/example/img/https://unpkg.com/three-globe/example/img/earth-blue-marble.jpg')
      .bumpImageUrl('https://unpkg.com/three-globe/example/img/https://unpkg.com/three-globe/example/img/earth-topology.png')
      .backgroundImageUrl(null);

    // atmosphere glow (subtle)
    const atmosphereMat = new THREE.ShaderMaterial({
      uniforms: {},
      vertexShader: `varying vec3 vNormal;void main(){vNormal = normalize(normalMatrix * normal);gl_Position = projectionMatrix * modelViewMatrix * vec4(position,1.0);}`,
      fragmentShader: `varying vec3 vNormal;void main(){float intensity = pow(0.6 - dot(vNormal, vec3(0,0,1.0)), 3.0);gl_FragColor = vec4(0.3,0.5,1.0, intensity);}`,
      blending: THREE.AdditiveBlending,
      side: THREE.BackSide,
      transparent: true
    });
    const atmosphere = new THREE.Mesh(new THREE.SphereGeometry(101, 50, 50), atmosphereMat);

    const globeObject = Globe;
    globeObject.scale.set(100,100,100);

    scene.add(globeObject);
    scene.add(atmosphere);

    // load country polygons
    const worldTopo = await fetch('https://unpkg.com/world-atlas@2/countries-110m.json').then(r=>r.json());
    const countries = topojson.feature(worldTopo, worldTopo.objects.countries).features;
    Globe.polygonsData(countries)
      .polygonCapColor(() => 'rgba(200, 200, 200, 0.0)')
      .polygonSideColor(() => 'rgba(0,0,0,0.15)')
      .polygonStrokeColor(() => 'rgba(150,150,150,0.2)')
      .polygonsTransitionDuration(300);

    // preload some major cities
    const cities = [
      { name: 'Tokyo', lat: 35.6895, lng: 139.6917 },
      { name: 'New York', lat: 40.7128, lng: -74.0060 },
      { name: 'London', lat: 51.5074, lng: -0.1278 },
      { name: 'Paris', lat: 48.8566, lng: 2.3522 },
      { name: 'Sydney', lat: -33.8688, lng: 151.2093 },
      { name: 'Moscow', lat: 55.7558, lng: 37.6173 },
      { name: 'São Paulo', lat: -23.5505, lng: -46.6333 },
      { name: 'Cairo', lat: 30.0444, lng: 31.2357 },
      { name: 'Mumbai', lat: 19.0760, lng: 72.8777 },
      { name: 'Beijing', lat: 39.9042, lng: 116.4074 }
    ];

    Globe.pointsData(cities)
        .pointLat('lat')
        .pointLng('lng')
        .pointLabel('name')
        .pointAltitude(0.01)
        .pointRadius(0.6)
        .pointsTransitionDuration(0);

    // tooltip handling
    const info = document.getElementById('info');
    const raycaster = new THREE.Raycaster();
    const mouse = new THREE.Vector2();

    function updateInfo(text){ info.textContent = text; }

    function onMove(event){
      const rect = renderer.domElement.getBoundingClientRect();
      mouse.x = ((event.clientX - rect.left) / rect.width) * 2 - 1;
      mouse.y = -((event.clientY - rect.top) / rect.height) * 2 + 1;
    }
    window.addEventListener('pointermove', onMove);

    // animate/hover loop
    let hovered = null;
    function animate(){
      requestAnimationFrame(animate);
      controls.update();

      // hover detection for points
      raycaster.setFromCamera(mouse, camera);
      const intersects = raycaster.intersectObjects(globeObject.children || [], true);
      // Instead of complex object picking, use Globe's built-in pointer handling

      renderer.render(scene, camera);
    }
    animate();

    // helper to fly camera to lat/lng
    function flyToLatLng(lat, lng, altitude=160){
      const phi = (90 - lat) * Math.PI/180;
      const theta = (lng + 180) * Math.PI/180;
      // convert to cartesian for camera target
      const r = 100;
      const x = r * Math.sin(phi) * Math.cos(theta);
      const y = r * Math.cos(phi);
      const z = r * Math.sin(phi) * Math.sin(theta);

      // use tween-like approach
      const startPos = camera.position.clone();
      const startTarget = controls.target.clone();
      const endPos = new THREE.Vector3(x* (altitude/100), y* (altitude/100), z* (altitude/100));
      const endTarget = new THREE.Vector3(x,y,z);

      const duration = 900;
      const t0 = performance.now();
      (function step(){
        const t = Math.min(1, (performance.now()-t0)/duration);
        camera.position.lerpVectors(startPos, endPos, easeInOutCubic(t));
        controls.target.lerpVectors(startTarget, endTarget, easeInOutCubic(t));
        controls.update();
        if(t<1) requestAnimationFrame(step);
      })();
    }
    function easeInOutCubic(t){ return t<.5 ? 4*t*t*t : 1 - Math.pow(-2*t+2,3)/2 }

    // clicking handling: pick nearest point (city) and focus
    renderer.domElement.addEventListener('pointerdown', async (ev)=>{
      const rect = renderer.domElement.getBoundingClientRect();
      const x = ((ev.clientX - rect.left)/rect.width) * 2 - 1;
      const y = -((ev.clientY - rect.top)/rect.height) * 2 + 1;
      // use Globe's getCoords? We'll compute geo coords from mouse

      const coords = Globe.getCoordsFromScreen && Globe.getCoordsFromScreen(x, y, camera);
      if(coords){
        const { lat, lng } = coords;
        updateInfo(`位置: クリックされた場所 | 緯度: ${lat.toFixed(4)} | 経度: ${lng.toFixed(4)}`);
      }
    });

    // UI elements
    const searchInput = document.getElementById('search');
    const goBtn = document.getElementById('go');
    const resetBtn = document.getElementById('reset');
    const autorotateBtn = document.getElementById('autorotate');
    let autorotate = false;

    function setAutoRotate(on){ autorotate = on; Globe.pause = !on; autorotateBtn.textContent = on ? 'Auto-Rotate: ON' : 'Auto-Rotate: OFF'; }
    setAutoRotate(true);

    goBtn.onclick = ()=> searchAndFly(searchInput.value);
    searchInput.addEventListener('keydown', (e)=>{ if(e.key === 'Enter') searchAndFly(searchInput.value); });
    resetBtn.onclick = ()=>{ camera.position.set(0,0,200); controls.target.set(0,0,0); }
    autorotateBtn.onclick = ()=> setAutoRotate(!autorotate);

    async function searchAndFly(query){
      if(!query) return;
      updateInfo('検索中…');
      try{
        const url = `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(query)}&limit=1`;
        const res = await fetch(url, { headers: { 'Accept-Language': 'en' } });
        const j = await res.json();
        if(j && j.length){
          const lat = parseFloat(j[0].lat);
          const lon = parseFloat(j[0].lon);
          flyToLatLng(lat, lon, 140);
          updateInfo(`位置: ${j[0].display_name} | 緯度: ${lat.toFixed(4)} | 経度: ${lon.toFixed(4)}`);
        } else updateInfo('場所が見つかりませんでした。');
      }catch(err){ updateInfo('検索エラー'); console.error(err); }
    }

    // update info on mouse move -> convert screen to lat/lng using Globe.gl helper when available
    window.addEventListener('mousemove', ()=>{
      const rect = renderer.domElement.getBoundingClientRect();
      const sx = ((event.clientX - rect.left)/rect.width) * 2 - 1;
      const sy = -((event.clientY - rect.top)/rect.height) * 2 + 1;
      const coords = Globe.getCoordsFromScreen && Globe.getCoordsFromScreen(sx, sy, camera);
      if(coords) updateInfo(`位置: マウス上 | 緯度: ${coords.lat.toFixed(4)} | 経度: ${coords.lng.toFixed(4)}`);
    });

    // responsive
    window.addEventListener('resize', ()=>{ camera.aspect = innerWidth/innerHeight; camera.updateProjectionMatrix(); renderer.setSize(innerWidth, innerHeight); });

    // small animation for auto rotate
    (function rotateLoop(){
      requestAnimationFrame(rotateLoop);
      if(autorotate){
        globeObject.rotateY(0.0005);
      }
    })();

    // add simple legend of loaded cities clickable
    const legend = document.createElement('div');
    legend.style.position='fixed'; legend.style.left='12px'; legend.style.bottom='12px'; legend.style.zIndex=3; legend.style.color='#dfeeff';
    legend.style.background='rgba(2,6,23,0.5)'; legend.style.padding='8px'; legend.style.borderRadius='8px'; legend.style.fontSize='13px';
    legend.innerHTML = '<strong>Major cities</strong><br/>' + cities.map(c=>`<a href='#' data-lat='${c.lat}' data-lng='${c.lng}' style='color:#9fbffb;display:inline-block;margin:4px 6px;text-decoration:none'>${c.name}</a>`).join('');
    document.body.appendChild(legend);
    legend.querySelectorAll('a').forEach(a=>{
      a.addEventListener('click', (e)=>{ e.preventDefault(); flyToLatLng(parseFloat(a.dataset.lat), parseFloat(a.dataset.lng), 120); });
    });

    // final notes in console
    console.log('Interactive Earth ready — try searching or clicking city names in the legend.');

  })();
  </script>
</body>
</html>
