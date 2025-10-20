import React, { useState, useEffect, useRef } from 'react';
import { Target, Trophy, RefreshCw, Clock, Settings } from 'lucide-react';

export default function ReactionGame() {
  const [gameState, setGameState] = useState('start');
  const [score, setScore] = useState(0);
  const [targetPosition, setTargetPosition] = useState({ x: 50, y: 50 });
  const [timeLeft, setTimeLeft] = useState(30);
  const [selectedMode, setSelectedMode] = useState(30);
  const [highScores, setHighScores] = useState({ 30: 0, 60: 0, 300: 0 });
  const [consecutiveHits, setConsecutiveHits] = useState(0);
  const [targetSize, setTargetSize] = useState(64);
  const [mouseX, setMouseX] = useState(0);
  const [mouseY, setMouseY] = useState(0);
  const [showSettings, setShowSettings] = useState(false);
  const [sensitivity, setSensitivity] = useState(1);
  const gameAreaRef = useRef(null);

  useEffect(() => {
    if (gameState === 'playing' && timeLeft > 0) {
      const timer = setTimeout(() => setTimeLeft(timeLeft - 1), 1000);
      return () => clearTimeout(timer);
    } else if (timeLeft === 0 && gameState === 'playing') {
      endGame();
    }
  }, [timeLeft, gameState]);

  const startGame = (mode) => {
    setSelectedMode(mode);
    setGameState('playing');
    setScore(0);
    setTimeLeft(mode);
    setConsecutiveHits(0);
    setTargetSize(64);
    moveTarget();
  };

  const moveTarget = () => {
    const x = Math.random() * 80 + 10;
    const y = Math.random() * 70 + 10;
    setTargetPosition({ x, y });
  };

  const handleTargetClick = () => {
    if (gameState === 'playing') {
      setScore(score + 1);
      const newHits = consecutiveHits + 1;
      setConsecutiveHits(newHits);
      const newSize = Math.max(32, 64 - newHits * 2);
      setTargetSize(newSize);
      moveTarget();
    }
  };

  const handleMouseMove = (e) => {
    if (gameAreaRef.current) {
      const rect = gameAreaRef.current.getBoundingClientRect();
      setMouseX(e.clientX - rect.left);
      setMouseY(e.clientY - rect.top);
    }
  };

  const endGame = () => {
    setGameState('end');
    if (score > highScores[selectedMode]) {
      setHighScores({ ...highScores, [selectedMode]: score });
    }
  };

  const formatTime = (seconds) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return mins > 0 ? `${mins}:${secs.toString().padStart(2, '0')}` : `${secs}秒`;
  };

  const getModeLabel = (seconds) => {
    if (seconds === 30) return '30秒';
    if (seconds === 60) return '1分';
    if (seconds === 300) return '5分';
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-600 via-pink-500 to-orange-400 flex items-center justify-center p-4">
      <div className="bg-white rounded-3xl shadow-2xl p-8 max-w-2xl w-full">
        <div className="text-center mb-6">
          <h1 className="text-4xl font-bold text-gray-800 mb-2 flex items-center justify-center gap-2">
            <Target className="text-pink-500" size={40} />
            反射神経ゲーム
          </h1>
          <p className="text-gray-600">制限時間内にできるだけ多くのターゲットをクリック!</p>
        </div>

        {gameState === 'start' && (
          <div className="space-y-6">
            <div className="text-center">
              <h2 className="text-2xl font-bold text-gray-800 mb-4 flex items-center justify-center gap-2">
                <Clock className="text-purple-500" size={28} />
                モードを選択
              </h2>
              <button
                onClick={() => setShowSettings(!showSettings)}
                className="inline-flex items-center gap-2 bg-gray-200 text-gray-700 px-4 py-2 rounded-full hover:bg-gray-300 transition-colors"
              >
                <Settings size={18} />
                設定
              </button>
            </div>

            {showSettings && (
              <div className="bg-gray-50 p-6 rounded-2xl border-2 border-gray-200">
                <h3 className="font-bold text-gray-800 mb-4">マウス感度</h3>
                <input
                  type="range"
                  min="0.5"
                  max="2"
                  step="0.1"
                  value={sensitivity}
                  onChange={(e) => setSensitivity(parseFloat(e.target.value))}
                  className="w-full"
                />
                <div className="flex justify-between text-sm text-gray-600 mt-2">
                  <span>低 (0.5x)</span>
                  <span className="font-bold text-purple-600">{sensitivity.toFixed(1)}x</span>
                  <span>高 (2.0x)</span>
                </div>
              </div>
            )}
            
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <button
                onClick={() => startGame(30)}
                className="bg-gradient-to-br from-blue-500 to-blue-600 text-white p-6 rounded-2xl hover:from-blue-600 hover:to-blue-700 transform hover:scale-105 transition-all shadow-lg"
              >
                <div className="text-3xl font-bold mb-2">30秒</div>
                <div className="text-sm opacity-90">クイックモード</div>
                <div className="mt-3 pt-3 border-t border-blue-400">
                  <Trophy className="inline mr-2" size={16} />
                  <span className="font-bold">{highScores[30]}</span>
                </div>
              </button>

              <button
                onClick={() => startGame(60)}
                className="bg-gradient-to-br from-purple-500 to-purple-600 text-white p-6 rounded-2xl hover:from-purple-600 hover:to-purple-700 transform hover:scale-105 transition-all shadow-lg"
              >
                <div className="text-3xl font-bold mb-2">1分</div>
                <div className="text-sm opacity-90">ノーマルモード</div>
                <div className="mt-3 pt-3 border-t border-purple-400">
                  <Trophy className="inline mr-2" size={16} />
                  <span className="font-bold">{highScores[60]}</span>
                </div>
              </button>

              <button
                onClick={() => startGame(300)}
                className="bg-gradient-to-br from-pink-500 to-pink-600 text-white p-6 rounded-2xl hover:from-pink-600 hover:to-pink-700 transform hover:scale-105 transition-all shadow-lg"
              >
                <div className="text-3xl font-bold mb-2">5分</div>
                <div className="text-sm opacity-90">エンデュランスモード</div>
                <div className="mt-3 pt-3 border-t border-pink-400">
                  <Trophy className="inline mr-2" size={16} />
                  <span className="font-bold">{highScores[300]}</span>
                </div>
              </button>
            </div>
          </div>
        )}

        {gameState === 'playing' && (
          <div>
            <div className="flex justify-between mb-4 text-xl font-bold">
              <div className="bg-blue-100 px-6 py-3 rounded-full text-blue-700">
                スコア: {score}
              </div>
              <div className="bg-red-100 px-6 py-3 rounded-full text-red-700">
                残り: {formatTime(timeLeft)}
              </div>
            </div>
            <div 
              ref={gameAreaRef}
              className="relative bg-gradient-to-br from-blue-50 to-purple-50 rounded-2xl h-96 border-4 border-purple-300"
              onMouseMove={handleMouseMove}
              style={{ cursor: 'none' }}
            >
              <div
                style={{
                  position: 'absolute',
                  left: mouseX,
                  top: mouseY,
                  width: '20px',
                  height: '20px',
                  transform: 'translate(-10px, -10px)',
                  pointerEvents: 'none',
                  zIndex: 100
                }}
              >
                <div style={{ position: 'relative', width: '20px', height: '20px' }}>
                  <div style={{ position: 'absolute', width: '12px', height: '2px', background: '#ef4444', left: '4px', top: '9px' }}></div>
                  <div style={{ position: 'absolute', width: '2px', height: '12px', background: '#ef4444', left: '9px', top: '4px' }}></div>
                  <div style={{ position: 'absolute', width: '4px', height: '4px', background: '#ef4444', borderRadius: '50%', left: '8px', top: '8px' }}></div>
                </div>
              </div>

              <button
                onClick={handleTargetClick}
                className="absolute bg-gradient-to-br from-red-500 to-pink-500 rounded-full shadow-lg transform hover:scale-110 transition-transform border-4 border-white flex items-center justify-center"
                style={{
                  left: `${targetPosition.x}%`,
                  top: `${targetPosition.y}%`,
                  transform: 'translate(-50%, -50%)',
                  width: `${targetSize}px`,
                  height: `${targetSize}px`,
                  cursor: 'none'
                }}
              >
                <Target className="text-white" size={targetSize / 2} />
              </button>
            </div>
            {consecutiveHits > 0 && (
              <div className="text-center mt-3 text-sm font-bold text-purple-600">
                連続ヒット: {consecutiveHits} 🔥 難易度UP!
              </div>
            )}
          </div>
        )}

        {gameState === 'end' && (
          <div className="text-center space-y-6">
            <div className="bg-gradient-to-r from-yellow-100 to-orange-100 rounded-2xl p-8">
              <Trophy className="mx-auto text-yellow-500 mb-4" size={64} />
              <h2 className="text-3xl font-bold text-gray-800 mb-2">ゲーム終了!</h2>
              <p className="text-gray-500 mb-3">{getModeLabel(selectedMode)}モード</p>
              <p className="text-5xl font-bold text-purple-600 mb-2">{score}</p>
              <p className="text-gray-600">ヒット</p>
              {score === highScores[selectedMode] && score > 0 && (
                <p className="text-pink-500 font-bold mt-4 text-xl">🎉 新記録達成! 🎉</p>
              )}
            </div>
            <button
              onClick={() => setGameState('start')}
              className="bg-gradient-to-r from-purple-500 to-pink-500 text-white px-12 py-4 rounded-full text-xl font-bold hover:from-purple-600 hover:to-pink-600 transform hover:scale-105 transition-all shadow-lg flex items-center gap-2 mx-auto"
            >
              <RefreshCw size={24} />
              モード選択に戻る
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
