<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>Number Guessing Game</title>
<style>
    body {
        font-family: "Segoe UI", sans-serif;
        background: #111;
        color: #fff;
        text-align: center;
        padding: 20px;
    }
    #container {
        width: 90%;
        max-width: 550px;
        margin: auto;
        background: #222;
        padding: 20px;
        border-radius: 12px;
        box-shadow: 0 0 20px rgba(255,255,255,0.15);
    }
    input[type=number] {
        width: 120px;
        padding: 10px;
        border-radius: 8px;
        border: none;
        font-size: 20px;
        margin: 10px;
        text-align: center;
    }
    button {
        padding: 10px 20px;
        background: #09f;
        color: #fff;
        border: none;
        border-radius: 8px;
        cursor: pointer;
        margin: 10px;
        font-size: 18px;
    }
    button:hover {
        opacity: 0.8;
    }
    .hidden { display: none; }
    table {
        width: 100%;
        margin-top: 20px;
        border-collapse: collapse;
    }
    th, td {
        border-bottom: 1px solid #555;
        padding: 10px;
    }
</style>
</head>
<body>
<div id="container">
    <h1>🎮 Number Guessing Game</h1>

    <!-- 名前入力画面 -->
    <div id="nameScreen">
        <p>名前を入力してください</p>
        <input id="playerName" type="text" placeholder="Your name">
        <button onclick="startMenu()">Start</button>
    </div>

    <!-- メインメニュー -->
    <div id="menuScreen" class="hidden">
        <h2>メニュー</h2>
        <button onclick="startGame()">ゲーム開始</button>
        <button onclick="showRanking()">ランキング</button>
        <button onclick="resetData()">データ削除</button>
    </div>

    <!-- ゲーム画面 -->
    <div id="gameScreen" class="hidden">
        <h2>数字を当ててください（1〜100）</h2>
        <p id="message"></p>
        <input id="guessInput" type="number" min="1" max="100">
        <button onclick="submitGuess()">決定</button>
        <button onclick="backToMenu()">戻る</button>
    </div>

    <!-- ランキング画面 -->
    <div id="rankingScreen" class="hidden">
        <h2>🏆 ランキング</h2>
        <table>
            <thead>
                <tr>
                    <th>名前</th>
                    <th>試行</th>
                    <th>時間</th>
                    <th>日付</th>
                </tr>
            </thead>
            <tbody id="rankingBody"></tbody>
        </table>
        <button onclick="backToMenu()">戻る</button>
    </div>
</div>

<script>
// ==========================
// 保存データ処理 (localStorage)
// ==========================
function loadScores() {
    return JSON.parse(localStorage.getItem("scores") || "[]");
}

function saveScores(scores) {
    localStorage.setItem("scores", JSON.stringify(scores));
}

// ==========================
// 画面切り替え
// ==========================
function showScreen(id) {
    document.querySelectorAll("#container > div").forEach(div => div.classList.add("hidden"));
    document.getElementById(id).classList.remove("hidden");
}

// プレイヤー名
let playerName = "";
let target = 0;
let attempts = 0;
let startTime;

// ==========================
// メニュー開始
// ==========================
function startMenu() {
    playerName = document.getElementById("playerName").value || "Player";
    showScreen("menuScreen");
}

// ==========================
// ゲーム開始
// ==========================
function startGame() {
    target = Math.floor(Math.random() * 100) + 1;
    attempts = 0;
    startTime = Date.now();
    document.getElementById("message").textContent = "";
    document.getElementById("guessInput").value = "";
    showScreen("gameScreen");
}

// ==========================
// 予想入力
// ==========================
function submitGuess() {
    let guess = Number(document.getElementById("guessInput").value);

    if (!guess || guess < 1 || guess > 100) {
        alert("1〜100 の数字を入力してください");
        return;
    }

    attempts++;

    if (guess < target) {
        document.getElementById("message").textContent = "もっと大きい！";
    } else if (guess > target) {
        document.getElementById("message").textContent = "もっと小さい！";
    } else {
        finishGame();
    }
}

// ==========================
// ゲームクリア
// ==========================
function finishGame() {
    let duration = ((Date.now() - startTime) / 1000).toFixed(2);

    alert(`🎉 正解！\n試行: ${attempts}回\n時間: ${duration}s`);

    let scores = loadScores();
    scores.push({
        name: playerName,
        attempts: attempts,
        time: duration,
        date: new Date().toLocaleString()
    });
    saveScores(scores);

    showScreen("menuScreen");
}

// ==========================
// ランキング表示
// ==========================
function showRanking() {
    let scores = loadScores();
    scores.sort((a, b) => a.attempts - b.attempts || a.time - b.time);

    let tbody = document.getElementById("rankingBody");
    tbody.innerHTML = "";

    scores.forEach(s => {
        let tr = document.createElement("tr");
        tr.innerHTML = `
            <td>${s.name}</td>
            <td>${s.attempts}</td>
            <td>${s.time}</td>
            <td>${s.date}</td>
        `;
        tbody.appendChild(tr);
    });

    showScreen("rankingScreen");
}

// ==========================
// データ削除
// ==========================
function resetData() {
    if (confirm("本当に削除しますか？")) {
        localStorage.removeItem("scores");
        alert("データを削除しました");
    }
}

// ==========================
// 戻る
// ==========================
function backToMenu() {
    showScreen("menuScreen");
}
</script>
</body>
</html>
