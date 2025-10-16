<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="午後の麦茶 3Dペットボトルビジュアライゼーション">
    <title>午後の麦茶 3Dペットボトル</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            overflow: hidden;
            background: linear-gradient(to bottom, #87CEEB 0%, #e0f2f7 100%);
            font-family: 'Helvetica Neue', Arial, sans-serif;
        }
        #container {
            width: 100vw;
            height: 100vh;
        }
        #controls {
            position: absolute;
            top: 20px;
            left: 20px;
            z-index: 100;
        }
        button {
            background: linear-gradient(135deg, #d4a574, #8b6f47);
            border: none;
            color: white;
            padding: 12px 24px;
            margin: 5px;
            border-radius: 20px;
            cursor: pointer;
            font-weight: 600;
            font-size: 14px;
            transition: transform 0.3s;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        button:hover {
            transform: scale(1.05);
        }
        button:active {
            transform: scale(0.95);
        }
        #info {
            position: absolute;
            bottom: 30px;
            left: 50%;
            transform: translateX(-50%);
            color: #5a4a3a;
            font-size: 18px;
            font-weight: 600;
            text-align: center;
            text-shadow: 0 2px 4px rgba(255,255,255,0.5);
        }
        #loading {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            color: #5a4a3a;
            font-size: 24px;
            font-weight: 600;
        }
    </style>
</head>
<body>
    <div id="loading">読み込み中...</div>
    <div id="container"></div>
    <div id="controls">
        <button onclick="toggleRotation()">回転 ON/OFF</button>
        <button onclick="resetCamera()">カメラリセット</button>
    </div>
    <div id="info">午後の麦茶 - 香ばしい麦の味わい</div>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>
    <script>
        let scene, camera, renderer, bottle, label;
        let autoRotate = true;
        let time = 0;
        let cameraAutoMove = true;

        function init() {
            // シーンの初期化
            scene = new THREE.Scene();
            scene.background = new THREE.Color(0x87CEEB);

            // カメラの初期化
            camera = new THREE.PerspectiveCamera(40, window.innerWidth / window.innerHeight, 0.1, 1000);
            camera.position.set(12, 5, 25);
            camera.lookAt(0, 0, 0);

            // レンダラーの初期化
            renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
            renderer.setSize(window.innerWidth, window.innerHeight);
            renderer.setPixelRatio(window.devicePixelRatio);
            renderer.shadowMap.enabled = true;
            renderer.shadowMap.type = THREE.PCFSoftShadowMap;
            document.getElementById('container').appendChild(renderer.domElement);

            // ライティング
            const ambientLight = new THREE.AmbientLight(0xffffff, 0.7);
            scene.add(ambientLight);

            const directionalLight = new THREE.DirectionalLight(0xffffff, 1.5);
            directionalLight.position.set(15, 20, 15);
            directionalLight.castShadow = true;
            directionalLight.shadow.mapSize.width = 2048;
            directionalLight.shadow.mapSize.height = 2048;
            directionalLight.shadow.camera.left = -20;
            directionalLight.shadow.camera.right = 20;
            directionalLight.shadow.camera.top = 20;
            directionalLight.shadow.camera.bottom = -20;
            scene.add(directionalLight);

            const fillLight = new THREE.PointLight(0xffffff, 0.6);
            fillLight.position.set(-12, 8, 8);
            scene.add(fillLight);

            const rimLight1 = new THREE.PointLight(0xffd700, 1.2, 40);
            rimLight1.position.set(20, 10, -15);
            scene.add(rimLight1);

            const rimLight2 = new THREE.PointLight(0xff8844, 1, 40);
            rimLight2.position.set(-15, 8, 12);
            scene.add(rimLight2);

            // 地面（影を受ける）
            const groundGeo = new THREE.PlaneGeometry(50, 50);
            const groundMat = new THREE.ShadowMaterial({ opacity: 0.25 });
            const ground = new THREE.Mesh(groundGeo, groundMat);
            ground.rotation.x = -Math.PI / 2;
            ground.position.y = -6;
            ground.receiveShadow = true;
            scene.add(ground);

            // パーティクル
            createParticles();

            // ボトル作成
            createBottle();

            // ローディング非表示
            document.getElementById('loading').style.display = 'none';

            // イベントリスナー
            window.addEventListener('resize', onWindowResize);

            // アニメーション開始
            animate();
        }

        function createBottle() {
            const bottleGroup = new THREE.Group();

            // ボトル本体（角型・くびれあり）
            const bodyShape = new THREE.Shape();
            bodyShape.moveTo(-1.2, 0);
            bodyShape.lineTo(-1.2, 3);
            bodyShape.lineTo(-0.9, 4);
            bodyShape.lineTo(-1.2, 5);
            bodyShape.lineTo(-1.2, 8);
            bodyShape.lineTo(1.2, 8);
            bodyShape.lineTo(1.2, 5);
            bodyShape.lineTo(0.9, 4);
            bodyShape.lineTo(1.2, 3);
            bodyShape.lineTo(1.2, 0);
            bodyShape.lineTo(-1.2, 0);

            const extrudeSettings = {
                depth: 2.4,
                bevelEnabled: true,
                bevelThickness: 0.05,
                bevelSize: 0.05,
                bevelSegments: 2
            };

            const bodyGeo = new THREE.ExtrudeGeometry(bodyShape, extrudeSettings);
            const bodyMat = new THREE.MeshPhysicalMaterial({
                color: 0xffffff,
                transparent: true,
                opacity: 0.25,
                transmission: 0.95,
                roughness: 0.05,
                metalness: 0,
                clearcoat: 1.0,
                ior: 1.5,
                thickness: 0.3
            });
            const body = new THREE.Mesh(bodyGeo, bodyMat);
            body.position.set(0, -4, -1.2);
            body.castShadow = true;
            body.receiveShadow = true;
            bottleGroup.add(body);

            // 減圧吸収パネル（凹み）
            for (let i = 0; i < 4; i++) {
                const panelGeo = new THREE.BoxGeometry(0.8, 1.5, 0.1);
                const panelMat = new THREE.MeshPhysicalMaterial({
                    color: 0xffffff,
                    transparent: true,
                    opacity: 0.3,
                    transmission: 0.9,
                    roughness: 0.1
                });
                const panel = new THREE.Mesh(panelGeo, panelMat);
                panel.position.set(0, -2 + i * 2.5, i % 2 === 0 ? 1.25 : -1.25);
                panel.castShadow = true;
                bottleGroup.add(panel);
            }

            // ボトル底部
            const bottomGeo = new THREE.BoxGeometry(2.4, 0.5, 2.4);
            const bottom = new THREE.Mesh(bottomGeo, bodyMat);
            bottom.position.y = -4.25;
            bottom.castShadow = true;
            bottleGroup.add(bottom);

            // ネック部分
            const neckGeo = new THREE.CylinderGeometry(0.65, 0.9, 1.5, 32);
            const neck = new THREE.Mesh(neckGeo, bodyMat);
            neck.position.y = 4.75;
            neck.castShadow = true;
            bottleGroup.add(neck);

            // キャップ（白い丸）
            const capGeo = new THREE.CylinderGeometry(0.75, 0.75, 0.8, 32);
            const capMat = new THREE.MeshStandardMaterial({
                color: 0xffffff,
                roughness: 0.3,
                metalness: 0.1
            });
            const cap = new THREE.Mesh(capGeo, capMat);
            cap.position.y = 5.9;
            cap.castShadow = true;
            bottleGroup.add(cap);

            const capTopGeo = new THREE.CylinderGeometry(0.75, 0.7, 0.25, 32);
            const capTop = new THREE.Mesh(capTopGeo, capMat);
            capTop.position.y = 6.525;
            capTop.castShadow = true;
            bottleGroup.add(capTop);

            // 中身の麦茶（濃い茶色）
            const liquidGeo = new THREE.BoxGeometry(2.2, 7.6, 2.2);
            const liquidMat = new THREE.MeshPhysicalMaterial({
                color: 0x6b4423,
                transparent: true,
                opacity: 0.7,
                roughness: 0.15,
                metalness: 0,
                transmission: 0.4
            });
            const liquid = new THREE.Mesh(liquidGeo, liquidMat);
            liquid.position.y = 0;
            bottleGroup.add(liquid);

            // ラベル作成
            createLabel(bottleGroup);

            scene.add(bottleGroup);
            bottle = bottleGroup;
        }

        function createLabel(parent) {
            const canvas = document.createElement('canvas');
            canvas.width = 1024;
            canvas.height = 512;
            const ctx = canvas.getContext('2d');

            // ラベル背景（暖色系）- 完全不透明
            const gradient = ctx.createLinearGradient(0, 0, 0, 512);
            gradient.addColorStop(0, '#f4e4c1');
            gradient.addColorStop(0.5, '#e8d4a8');
            gradient.addColorStop(1, '#d4c090');
            ctx.fillStyle = gradient;
            ctx.fillRect(0, 0, 1024, 512);

            // 上下の濃い茶色のバー
            ctx.fillStyle = '#8b6f47';
            ctx.fillRect(0, 0, 1024, 50);
            ctx.fillRect(0, 462, 1024, 50);

            // 「午後の麦茶」ロゴ
            ctx.fillStyle = '#4a3a1a';
            ctx.font = 'bold 110px serif';
            ctx.textAlign = 'center';
            ctx.fillText('午後の麦茶', 512, 190);

            // 英語表記
            ctx.font = 'italic 44px Georgia';
            ctx.fillStyle = '#7a5a2a';
            ctx.fillText('GOGO NO MUGICHA', 512, 250);

            // 「香ばしい麦の味わい」
            ctx.font = 'bold 48px sans-serif';
            ctx.fillStyle = '#5a3a1a';
            ctx.fillText('香ばしい麦の味わい', 512, 330);

            // 装飾ライン
            ctx.strokeStyle = '#d4a574';
            ctx.lineWidth = 4;
            ctx.beginPath();
            ctx.moveTo(180, 380);
            ctx.lineTo(844, 380);
            ctx.stroke();

            // 麦のイラスト風装飾
            ctx.fillStyle = '#c4a564';
            for (let i = 0; i < 5; i++) {
                ctx.beginPath();
                ctx.arc(200 + i * 150, 420, 8, 0, Math.PI * 2);
                ctx.fill();
            }

            // テクスチャとしてラベルを作成
            const labelTexture = new THREE.CanvasTexture(canvas);
            labelTexture.needsUpdate = true;
            
            // ラベルをボトルより少し大きめにして、しっかり見えるようにする
            const labelGeo = new THREE.BoxGeometry(2.5, 5.5, 2.5);
            const labelMat = new THREE.MeshStandardMaterial({
                map: labelTexture,
                transparent: false,
                roughness: 0.4,
                metalness: 0.1
            });
            
            const labelMesh = new THREE.Mesh(labelGeo, labelMat);
            labelMesh.position.y = 0.3;
            parent.add(labelMesh);
            label = labelMesh;
        }

        function createParticles() {
            const particleGeo = new THREE.BufferGeometry();
            const positions = [];
            const colors = [];

            for (let i = 0; i < 500; i++) {
                const radius = 25 + Math.random() * 30;
                const theta = Math.random() * Math.PI * 2;
                const phi = Math.random() * Math.PI * 2;

                positions.push(
                    Math.sin(theta) * Math.cos(phi) * radius,
                    Math.sin(theta) * Math.sin(phi) * radius - 5,
                    Math.cos(theta) * radius
                );

                const color = new THREE.Color();
                color.setHSL(0.1 + Math.random() * 0.15, 0.7, 0.55);
                colors.push(color.r, color.g, color.b);
            }

            particleGeo.setAttribute('position', new THREE.Float32BufferAttribute(positions, 3));
            particleGeo.setAttribute('color', new THREE.Float32BufferAttribute(colors, 3));

            const particleMat = new THREE.PointsMaterial({
                size: 0.4,
                vertexColors: true,
                transparent: true,
                opacity: 0.6,
                blending: THREE.AdditiveBlending
            });

            const particles = new THREE.Points(particleGeo, particleMat);
            scene.add(particles);
            
            window.particles = particles;
        }

        function animate() {
            requestAnimationFrame(animate);
            time += 0.01;

            if (bottle && autoRotate) {
                bottle.rotation.y = time * 0.3;
                bottle.position.y = Math.sin(time * 0.8) * 0.4;
            }

            // ダイナミックカメラアニメーション
            if (cameraAutoMove) {
                const cameraRadius = 25;
                const cameraSpeed = time * 0.35;
                const verticalSpeed = time * 0.45;
                
                camera.position.x = Math.sin(cameraSpeed) * cameraRadius * Math.cos(verticalSpeed * 0.25);
                camera.position.y = 5 + Math.sin(verticalSpeed) * 10 + Math.cos(time * 0.25) * 4;
                camera.position.z = Math.cos(cameraSpeed) * cameraRadius + 8;
                
                camera.lookAt(0, 0, 0);

                // FOV変化
                camera.fov = 40 + Math.sin(time * 0.5) * 12;
                camera.updateProjectionMatrix();
            }

            // パーティクルアニメーション
            if (window.particles) {
                window.particles.rotation.y = time * 0.04;
                window.particles.rotation.x = Math.sin(time * 0.25) * 0.08;
                
                const positions = window.particles.geometry.attributes.position.array;
                for (let i = 0; i < positions.length; i += 3) {
                    positions[i + 1] += Math.sin(time + positions[i]) * 0.015;
                }
                window.particles.geometry.attributes.position.needsUpdate = true;
            }

            renderer.render(scene, camera);
        }

        function toggleRotation() {
            autoRotate = !autoRotate;
        }

        function resetCamera() {
            cameraAutoMove = !cameraAutoMove;
            if (!cameraAutoMove) {
                camera.position.set(12, 5, 25);
                camera.lookAt(0, 0, 0);
                camera.fov = 40;
                camera.updateProjectionMatrix();
            }
        }

        function onWindowResize() {
            camera.aspect = window.innerWidth / window.innerHeight;
            camera.updateProjectionMatrix();
            renderer.setSize(window.innerWidth, window.innerHeight);
        }

        // ページ読み込み完了後に初期化
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', init);
        } else {
            init();
        }
    </script>
</body>
</html>
