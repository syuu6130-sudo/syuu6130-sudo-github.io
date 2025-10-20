<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>反射神経ゲーム</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Arial', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 50%, #f093fb 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        
        .container {
            background: white;
            border-radius: 30px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            padding: 40px;
            max-width: 700px;
            width: 100%;
        }
        
        .header {
            text-align: center;
            margin-bottom: 30px;
        }
        
        h1 {
            font-size: 2.5rem;
            color: #333;
            margin-bottom: 10px;
        }
        
        .subtitle {
            color: #666;
            font-size: 1rem;
        }
        
        .settings-btn {
            background: #e5e7eb;
            color: #374151;
            border: none;
            padding: 10px 20px;
            border-radius: 25px;
            cursor: pointer;
            font-size: 0.9rem;
            margin-top: 15px;
            transition: all 0.3s;
        }
        
        .settings-btn:hover {
            background: #d1d5db;
        }
        
        .settings-panel {
            background: #f9fafb;
            border: 2px solid #e5e7eb;
            border-radius: 20px;
            padding: 25px;
            margin: 20px 0;
            display: none;
        }
        
        .settings-panel.active {
            display: block;
        }
        
        .slider-container {
            margin-top: 15px;
        }
        
        .slider {
            width: 100%;
            height: 6px;
            border-radius: 5px;
            outline: none;
            margin: 10px 0;
        }
        
        .slider-labels {
            display: flex;
            justify-content: space-between;
            font-size: 0.85rem;
            color: #666;
        }
        
        .slider-value {
            color: #8b5cf6;
            font-weight: bold;
        }
        
        .mode-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 15px;
            margin-top: 20px;
        }
        
        .mode-btn {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border: none;
            padding: 30px 20px;
            border-radius: 20px;
            cursor: pointer;
            font-size: 1rem;
            transition: all 0.3s;
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }
        
        .mode-btn:hover {
            transform: scale(1.05);
        }
        
        .mode-btn.blue {
            background: linear-gradient(135deg, #3b82f6, #2563eb);
        }
        
        .mode-btn.purple {
            background: linear-gradient(135deg, #8b5cf6, #7c3aed);
        }
        
        .mode-btn.pink {
            background: linear-gradient(135deg, #ec4899, #db2777);
        }
        
        .mode-title {
            font-size: 1.8rem;
            font-weight: bold;
            margin-bottom: 5px;
        }
        
        .mode-subtitle {
            font-size: 0.85rem;
            opacity: 0.9;
            margin-bottom: 10px;
        }
        
        .high-score {
            border-top: 1px solid rgba(255,255,255,0.3);
            padding-top: 10px;
            margin-top: 10px;
            font-size: 0.9rem;
        }
        
        .game-stats {
            display: flex;
            justify-content: space-between;
            margin-bottom: 20px;
        }
        
        .stat-box {
            padding: 15px 25px;
            border-radius: 25px;
            font-size: 1.2rem;
            font-weight: bold;
        }
        
        .score-box {
            background: #dbeafe;
            color: #1e40af;
        }
        
        .time-box {
            background: #fee2e2;
            color: #991b1b;
        }
        
        .game-area {
            position: relative;
            background: linear-gradient(135deg, #eff6ff, #f5f3ff);
            border: 4px solid #a78bfa;
            border-radius: 20px;
            height: 400px;
            overflow: hidden;
            cursor: none;
        }
        
        .crosshair {
            position: absolute;
            width: 20px;
            height: 20px;
            pointer-events: none;
            z-index: 10;
            transform: translate(-50%, -50%);
        }
        
        .crosshair::before,
        .crosshair::after {
            content: '';
            position: absolute;
            background: #ef4444;
        }
        
        .crosshair::before {
            width: 12px;
            height: 2px;
            left: 4px;
            top: 9px;
        }
        
        .crosshair::after {
            width: 2px;
            height: 12px;
            left: 9px;
            top: 4px;
        }
        
        .crosshair-dot {
            position: absolute;
            width: 4px;
            height: 4px;
            background: #ef4444;
            border-radius: 50%;
            left: 8px;
            top: 8px;
        }
        
        .target {
            position: absolute;
            background: linear-gradient(135deg, #ef4444, #ec4899);
            border: 4px solid white;
            border-radius: 50%;
            cursor: none;
            box-shadow: 0 5px 15px rgba(0,0,0,0.3);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 2rem;
            transition: transform 0.1s;
        }
        
        .target:hover {
            transform: scale(1.1);
        }
        
        .combo-text {
            text-align: center;
            margin-top: 15px;
            color: #8b5cf6;
            font-weight: bold;
            font-size: 0.9rem;
        }
        
        .result-screen {
            text-align: center;
        }
        
        .result-box {
            background: linear-gradient(to right, #fef3c7, #fed7aa);
            border-radius: 20px;
            padding: 40px;
            margin-bottom: 25px;
        }
        
        .trophy-icon {
            font-size: 4rem;
            margin-bottom: 15px;
        }
        
        .result-title {
            font-size: 2rem;
            color: #333;
            margin-bottom: 10px;
        }
        
        .result-mode {
            color: #666;
            margin-bottom: 15px;
        }
        
        .result-score {
            font-size: 3.5rem;
            font-weight: bold;
            color: #8b5cf6;
            margin-bottom: 5px;
        }
        
        .result-label {
            color: #666;
            font-size: 1.1rem;
        }
        
        .new-record {
            color: #ec4899;
            font-weight: bold;
            font-size: 1.3rem;
            margin-top: 15px;
        }
        
        .restart-btn {
            background: linear-gradient(to right, #8b5cf6, #ec4899);
            color: white;
            border: none;
            padding: 18px 50px;
            border-radius: 30px;
            font-size: 1.2rem;
            font-weight: bold;
            cursor: pointer;
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
            transition: all 0.3s;
        }
        
        .restart-btn:hover {
            transform: scale(1.05);
        }
        
        .hidden {
            display: none;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🎯 反射神経ゲーム</h1>
            <p class="subtitle">制限時間内にできるだけ多くのターゲットをクリック!</p>
        </div>
        
        <div id="startScreen">
            <div style="text-align: center;">
                <h2 style="font-size: 1.5rem; color: #333; margin-bottom: 15px;">⏱️ モードを選択</h2>
                <button class="settings-btn" onclick="toggleSettings()">⚙️ 設定</button>
            </div>
            
            <div id="settingsPanel" class="settings-panel">
                <h3 style="color: #333; margin-bottom: 10px;">マウス感度</h3>
                <div class="slider-container">
                    <input type="range" min="0.5" max="2" step="0.1" value="1" class="slider" id="sensitivitySlider">
                    <div class="slider-labels">
                        <span>低 (0.5x)</span>
                        <span class="slider-value" id="sensitivityValue">1.0x</span>
                        <span>高 (2.0x)</span>
                    </div>
                </div>
            </div>
            
            <div class="mode-grid">
                <button class="mode-btn blue" onclick="startGame(30)">
                    <div class="mode-title">30秒</div>
                    <div class="mode-subtitle">クイックモード</div>
                    <div class="high-score">🏆 <span id="highScore30">0</span></div>
                </button>
                
                <button class="mode-btn purple" onclick="startGame(60)">
                    <div class="mode-title">1分</div>
                    <div class="mode-subtitle">ノーマルモード</div>
                    <div class="high-score">🏆 <span id="highScore60">0</span></div>
                </button>
                
                <button class="mode-btn pink" onclick="startGame(300)">
                    <div class="mode-title">5分</div>
                    <div class="mode-subtitle">エンデュランスモード</div>
                    <div class="high-score">🏆 <span id="highScore300">0</span></div>
                </button>
            </div>
        </div>
        
        <div id="gameScreen" class="hidden">
            <div class="game-stats">
                <div class="stat-box score-box">スコア: <span id="score">0</span></div>
                <div class="stat-box time-box">残り: <span id="timeLeft">30秒</span></div>
            </div>
            
            <div class="game-area" id="gameArea">
                <div class="crosshair" id="crosshair">
                    <div class="crosshair-dot"></div>
                </div>
                <div class="target" id="target">🎯</div>
            </div>
            
            <div class="combo-text" id="comboText"></div>
        </div>
        
        <div id="resultScreen" class="hidden result-screen">
            <div class="result-box">
                <div class="trophy-icon">🏆</div>
                <h2 class="result-title">ゲーム終了!</h2>
                <p class="result-mode" id="resultMode">30秒モード</p>
                <p class="result-score" id="resultScore">0</p>
                <p class="result-label">ヒット</p>
                <p class="new-record hidden" id="newRecord">🎉 新記録達成! 🎉</p>
            </div>
            <button class="restart-btn" onclick="backToMenu()">🔄 モード選択に戻る</button>
        </div>
    </div>

    <script>
        let gameState = 'start';
        let score = 0;
        let timeLeft = 30;
        let selectedMode = 30;
        let highScores = { 30: 0, 60: 0, 300: 0 };
        let consecutiveHits = 0;
        let targetSize = 64;
        let sensitivity = 1;
        let timerInterval;

        const startScreen = document.getElementById('startScreen');
        const gameScreen = document.getElementById('gameScreen');
        const resultScreen = document.getElementById('resultScreen');
        const gameArea = document.getElementById('gameArea');
        const target = document.getElementById('target');
        const crosshair = document.getElementById('crosshair');
        const sensitivitySlider = document.getElementById('sensitivitySlider');
        const sensitivityValue = document.getElementById('sensitivityValue');

        sensitivitySlider.addEventListener('input', (e) => {
            sensitivity = parseFloat(e.target.value);
            sensitivityValue.textContent = sensitivity.toFixed(1) + 'x';
        });

        function toggleSettings() {
            const panel = document.getElementById('settingsPanel');
            panel.classList.toggle('active');
        }

        function startGame(mode) {
            selectedMode = mode;
            gameState = 'playing';
            score = 0;
            timeLeft = mode;
            consecutiveHits = 0;
            targetSize = 64;
            
            startScreen.classList.add('hidden');
            gameScreen.classList.remove('hidden');
            resultScreen.classList.add('hidden');
            
            updateDisplay();
            moveTarget();
            startTimer();
        }

        function startTimer() {
            clearInterval(timerInterval);
            timerInterval = setInterval(() => {
                timeLeft--;
                updateDisplay();
                
                if (timeLeft <= 0) {
                    endGame();
                }
            }, 1000);
        }

        function moveTarget() {
            const maxX = gameArea.clientWidth - targetSize;
            const maxY = gameArea.clientHeight - targetSize;
            
            const x = Math.random() * (maxX - 40) + 20;
            const y = Math.random() * (maxY - 40) + 20;
            
            target.style.left = x + 'px';
            target.style.top = y + 'px';
            target.style.width = targetSize + 'px';
            target.style.height = targetSize + 'px';
            target.style.fontSize = (targetSize / 2) + 'px';
        }

        target.addEventListener('click', () => {
            if (gameState === 'playing') {
                score++;
                consecutiveHits++;
                
                targetSize = Math.max(32, 64 - consecutiveHits * 2);
                
                updateDisplay();
                moveTarget();
            }
        });

        gameArea.addEventListener('mousemove', (e) => {
            if (gameState === 'playing') {
                const rect = gameArea.getBoundingClientRect();
                const x = (e.clientX - rect.left) * sensitivity;
                const y = (e.clientY - rect.top) * sensitivity;
                
                crosshair.style.left = x + 'px';
                crosshair.style.top = y + 'px';
            }
        });

        function updateDisplay() {
            document.getElementById('score').textContent = score;
            
            const mins = Math.floor(timeLeft / 60);
            const secs = timeLeft % 60;
            const timeText = mins > 0 ? `${mins}:${secs.toString().padStart(2, '0')}` : `${secs}秒`;
            document.getElementById('timeLeft').textContent = timeText;
            
            const comboText = document.getElementById('comboText');
            if (consecutiveHits > 0) {
                comboText.textContent = `連続ヒット: ${consecutiveHits} 🔥 難易度UP!`;
            } else {
                comboText.textContent = '';
            }
        }

        function endGame() {
            clearInterval(timerInterval);
            gameState = 'end';
            
            if (score > highScores[selectedMode]) {
                highScores[selectedMode] = score;
                document.getElementById(`highScore${selectedMode}`).textContent = score;
                document.getElementById('newRecord').classList.remove('hidden');
            } else {
                document.getElementById('newRecord').classList.add('hidden');
            }
            
            const modeLabels = { 30: '30秒', 60: '1分', 300: '5分' };
            document.getElementById('resultMode').textContent = modeLabels[selectedMode] + 'モード';
            document.getElementById('resultScore').textContent = score;
            
            gameScreen.classList.add('hidden');
            resultScreen.classList.remove('hidden');
        }

        function backToMenu() {
            gameState = 'start';
            startScreen.classList.remove('hidden');
            gameScreen.classList.add('hidden');
            resultScreen.classList.add('hidden');
        }
    </script>
</body>
</html>
