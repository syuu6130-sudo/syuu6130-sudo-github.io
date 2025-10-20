import React, { useState, useEffect } from 'react';
import { Target, Trophy, RefreshCw, Clock } from 'lucide-react';

export default function ReactionGame() {
  const [gameState, setGameState] = useState('start');
  const [score, setScore] = useState(0);
  const [targetPosition, setTargetPosition] = useState({ x: 50, y: 50 });
  const [timeLeft, setTimeLeft] = useState(30);
  const [selectedMode, setSelectedMode] = useState(30);
  const [highScores, setHighScores] = useState({ 30: 0, 60: 0, 300: 0 });

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
      moveTarget();
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
            </div>
            
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
            <div className="relative bg-gradient-to-br from-blue-50 to-purple-50 rounded-2xl h-96 border-4 border-purple-300">
              <button
                onClick={handleTargetClick}
                className="absolute w-16 h-16 bg-gradient-to-br from-red-500 to-pink-500 rounded-full shadow-lg transform hover:scale-110 transition-transform cursor-pointer border-4 border-white flex items-center justify-center"
                style={{
                  left: `${targetPosition.x}%`,
                  top: `${targetPosition.y}%`,
                  transform: 'translate(-50%, -50%)'
                }}
              >
                <Target className="text-white" size={32} />
              </button>
            </div>
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
