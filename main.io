<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<style>
  body { margin:0; overflow:hidden; background:#000; }
  #globe { width:100vw; height:100vh; }
</style>
</head>
<body>
<div id="globe"></div>

<script src="https://unpkg.com/three@0.160.0/build/three.min.js"></script>
<script src="https://unpkg.com/three-globe@2.27.1/dist/three-globe.min.js"></script>

<script>
  const renderer = new THREE.WebGLRenderer({ antialias: true });
  renderer.setSize(window.innerWidth, window.innerHeight);
  document.getElementById('globe').appendChild(renderer.domElement);

  const scene = new THREE.Scene();
  const camera = new THREE.PerspectiveCamera(45, window.innerWidth / window.innerHeight, 0.1, 2000);
  camera.position.z = 300;

  const globe = new ThreeGlobe()
    .globeImageUrl('https://unpkg.com/three-globe/example/img/earth-blue-marble.jpg')
    .bumpImageUrl('https://unpkg.com/three-globe/example/img/earth-topology.png');

  scene.add(globe);

  const light = new THREE.AmbientLight(0xffffff, 1);
  scene.add(light);

  function animate() {
    requestAnimationFrame(animate);
    globe.rotation.y += 0.001;
    renderer.render(scene, camera);
  }
  animate();
</script>
</body>
</html>
