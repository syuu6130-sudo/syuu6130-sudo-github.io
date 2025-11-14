import React, { useEffect, useMemo, useState, useRef } from "react";
import { motion } from "framer-motion";
import { Star, Sparkles, Zap } from "lucide-react";

// Echo Realms — Loopcraft
// Single-file React component prototype intended for GitHub Pages.
// Features: procedurally generated "Echoes" (small rooms), collectible Echo Shards,
// simple movement, roguelite progression, tiny crafting, local leaderboard.

const GRID_SIZE = 7; // 7x7 tiles
const INITIAL_HEALTH = 5;
const MAX_DEPTH = 6; // number of Echo rooms

function rnd(n) {
  return Math.floor(Math.random() * n);
}

function generateRoom(seed = Math.random()) {
  // deterministic-ish using seed (not cryptographically)
  const rng = (v = 1) => {
    seed = (seed * 9301 + 49297) % 233280;
    return Math.abs(Math.floor((seed / 233280) * v));
  };
  const tiles = Array.from({ length: GRID_SIZE * GRID_SIZE }).map((_, i) => {
    const r = rng(100);
    if (r < 8) return "wall";
    if (r < 18) return "enemy";
    if (r < 30) return "shard";
    return "floor";
  });
  // ensure a player spawn free tile in center-ish
  const center = Math.floor((GRID_SIZE * GRID_SIZE) / 2);
  tiles[center] = "floor";
  return tiles;
}

function idx(x, y) {
  return y * GRID_SIZE + x;
}

export default function EchoRealmsLoopcraft() {
  const [depth, setDepth] = useState(1);
  const [roomSeed, setRoomSeed] = useState(() => Math.floor(Math.random() * 1e9));
  const room = useMemo(() => generateRoom(roomSeed), [roomSeed]);
  const [playerPos, setPlayerPos] = useState({ x: Math.floor(GRID_SIZE / 2), y: Math.floor(GRID_SIZE / 2) });
  const [health, setHealth] = useState(INITIAL_HEALTH);
  const [shards, setShards] = useState(0);
  const [score, setScore] = useState(0);
  const [log, setLog] = useState([`You enter Echo ${depth}`]);
  const [turn, setTurn] = useState(0);
  const [gameOver, setGameOver] = useState(false);
  const [leaderboard, setLeaderboard] = useState(() => {
    try {
      return JSON.parse(localStorage.getItem("echo_leaderboard") || "[]");
    } catch (e) {
      return [];
    }
  });

  const turnRef = useRef(turn);
  useEffect(() => (turnRef.current = turn), [turn]);

  useEffect(() => {
    setPlayerPos({ x: Math.floor(GRID_SIZE / 2), y: Math.floor(GRID_SIZE / 2) });
  }, [roomSeed]);

  useEffect(() => {
    function handler(e) {
      if (gameOver) return;
      const key = e.key.toLowerCase();
      const map = { w: [0, -1], a: [-1, 0], s: [0, 1], d: [1, 0], arrowup: [0, -1], arrowleft: [-1, 0], arrowdown: [0, 1], arrowright: [1, 0] };
      if (!map[key]) return;
      e.preventDefault();
      const [dx, dy] = map[key];
      movePlayer(dx, dy);
    }
    window.addEventListener("keydown", handler);
    return () => window.removeEventListener("keydown", handler);
  }, [playerPos, room, gameOver]);

  function pushLog(text) {
    setLog((l) => [text, ...l].slice(0, 12));
  }

  function movePlayer(dx, dy) {
    const nx = playerPos.x + dx;
    const ny = playerPos.y + dy;
    if (nx < 0 || nx >= GRID_SIZE || ny < 0 || ny >= GRID_SIZE) return;
    const tile = room[idx(nx, ny)];
    if (tile === "wall") {
      pushLog("Bumped into an echo wall.");
      setScore((s) => s + 1);
      return;
    }
    setPlayerPos({ x: nx, y: ny });
    setTurn((t) => t + 1);

    if (tile === "enemy") {
      // enemy encounter
      const dmg = 1 + Math.floor(Math.random() * Math.min(depth, 3));
      setHealth((h) => {
        const nh = h - dmg;
        pushLog(`Took ${dmg} damage from a drifting echo.`);
        if (nh <= 0) {
          handleGameOver();
        }
        return Math.max(0, nh);
      });
      setScore((s) => s + 10);
    }
    if (tile === "shard") {
      setShards((c) => c + 1);
      pushLog("Collected an Echo Shard.");
      setScore((s) => s + 20);
      // mutate the room slightly by removing that shard
      room[idx(nx, ny)] = "floor";
    }
    // small chance to discover an exit
    if (Math.random() < 0.06 + depth * 0.01) {
      pushLog("A shimmering doorway appears — advance deeper? (Press Advance)");
    }
  }

  function craftUpgrade() {
    if (shards >= 3) {
      setShards((s) => s - 3);
      setHealth((h) => Math.min(h + 2, INITIAL_HEALTH + depth));
      pushLog("Crafted an Aether Patch — health increased.");
      setScore((s) => s + 50);
    } else {
      pushLog("Not enough shards to craft.");
    }
  }

  function advance() {
    // go deeper: new room seed and slightly harder
    setDepth((d) => Math.min(d + 1, MAX_DEPTH));
    setRoomSeed(Math.floor(Math.random() * 1e9));
    setTurn(0);
    setScore((s) => s + depth * 100);
    pushLog(`You step deeper into Echo ${depth + 1}.`);
  }

  function handleGameOver() {
    setGameOver(true);
    pushLog("Your echo fades... Game over.");
    const entry = { when: Date.now(), score, depth, shards };
    const next = [...leaderboard, entry].sort((a, b) => b.score - a.score).slice(0, 8);
    setLeaderboard(next);
    localStorage.setItem("echo_leaderboard", JSON.stringify(next));
  }

  function resetRun() {
    setDepth(1);
    setRoomSeed(Math.floor(Math.random() * 1e9));
    setPlayerPos({ x: Math.floor(GRID_SIZE / 2), y: Math.floor(GRID_SIZE / 2) });
    setHealth(INITIAL_HEALTH);
    setShards(0);
    setScore(0);
    setLog([`You enter Echo 1`]);
    setTurn(0);
    setGameOver(false);
  }

  // Mini passive tick: enemies sometimes move/hunt (light simulation)
  useEffect(() => {
    if (gameOver) return;
    const id = setInterval(() => {
      // slight random event
      if (Math.random() < 0.12 + depth * 0.02) {
        // heal or damage
        if (Math.random() < 0.5) {
          setHealth((h) => Math.min(h + 1, INITIAL_HEALTH + depth));
          pushLog("A warm echo mends your wounds.");
        } else {
          setHealth((h) => Math.max(0, h - 1));
          pushLog("A sharp echo grazes you.");
        }
      }
    }, 3500);
    return () => clearInterval(id);
  }, [depth, gameOver]);

  return (
    <div className="min-h-screen p-6 bg-gradient-to-br from-slate-900 via-indigo-900 to-purple-800 text-white flex flex-col items-center">
      <header className="w-full max-w-3xl flex items-center justify-between mb-4">
        <div className="flex items-center gap-3">
          <Sparkles />
          <h1 className="text-2xl font-extrabold">Echo Realms — Loopcraft</h1>
          <span className="text-sm opacity-80">(prototype)</span>
        </div>
        <div className="text-right text-sm">
          <div>Depth: <strong>{depth}</strong></div>
          <div>Score: <strong>{score}</strong></div>
        </div>
      </header>

      <main className="w-full max-w-3xl flex gap-6">
        <section className="bg-slate-800/40 rounded-2xl p-4 flex-shrink-0">
          <div className="w-[420px] h-[420px] grid grid-cols-7 gap-0 rounded-lg overflow-hidden border-2 border-slate-700">
            {Array.from({ length: GRID_SIZE * GRID_SIZE }).map((_, i) => {
              const x = i % GRID_SIZE;
              const y = Math.floor(i / GRID_SIZE);
              const tile = room[i];
              const isPlayer = playerPos.x === x && playerPos.y === y;
              return (
                <motion.div
                  key={i}
                  layout
                  whileHover={{ scale: 1.03 }}
                  onClick={() => movePlayer(x - playerPos.x, y - playerPos.y)}
                  className={`w-full h-full flex items-center justify-center border-[1px] border-slate-700/30 text-xs select-none ${
                    tile === "wall"
                      ? "bg-slate-900"
                      : tile === "enemy"
                      ? "bg-rose-700/30"
                      : tile === "shard"
                      ? "bg-amber-400/80 text-black"
                      : "bg-slate-700/30"
                  }`}
                >
                  {isPlayer ? <div className="p-2 rounded-full bg-gradient-to-br from-indigo-400 to-violet-500 shadow-lg">You</div> : tile === "enemy" ? <Zap /> : tile === "shard" ? <Star /> : null}
                </motion.div>
              );
            })}
          </div>

          <div className="mt-3 flex gap-2">
            <button className="px-3 py-1 rounded-md bg-indigo-600/80 hover:bg-indigo-500" onClick={craftUpgrade}>
              Craft (3 shards)
            </button>
            <button className="px-3 py-1 rounded-md bg-emerald-600/80 hover:bg-emerald-500" onClick={advance}>
              Advance
            </button>
            <button className="px-3 py-1 rounded-md bg-slate-600/60 hover:bg-slate-500" onClick={resetRun}>
              Restart
            </button>
          </div>
        </section>

        <aside className="flex-1 flex flex-col gap-3">
          <div className="bg-slate-800/40 p-3 rounded-2xl">
            <div className="flex items-center justify-between">
              <div>
                <div className="text-sm opacity-90">Health</div>
                <div className="text-xl font-bold">{health} / {INITIAL_HEALTH + depth}</div>
              </div>
              <div className="text-right">
                <div className="text-sm opacity-80">Shards</div>
                <div className="text-lg font-bold">{shards}</div>
              </div>
            </div>
            <div className="mt-3 text-xs opacity-80">Controls: WASD / arrow keys or click tiles. Craft to heal. Advance to go deeper and bank score.</div>
          </div>

          <div className="bg-slate-800/30 p-3 rounded-2xl flex-1 overflow-auto">
            <div className="text-sm font-semibold mb-2">Log</div>
            <ul className="text-xs list-disc ml-4 space-y-1">
              {log.map((t, i) => (
                <li key={i}>{t}</li>
              ))}
            </ul>
          </div>

          <div className="bg-slate-800/30 p-3 rounded-2xl">
            <div className="flex items-center justify-between mb-2">
              <div className="text-sm font-semibold">Leaderboard</div>
              <div className="text-xs opacity-70">Local</div>
            </div>
            <ol className="text-xs list-decimal ml-4">
              {leaderboard.length === 0 ? <li>No runs yet</li> : leaderboard.map((r, i) => (
                <li key={i} className="mb-1">Score {r.score} — Depth {r.depth} — {new Date(r.when).toLocaleString()}</li>
              ))}
            </ol>
          </div>

          <div className="bg-slate-800/40 p-3 rounded-2xl text-center text-xs opacity-85">Pro tip: Each Echo mutates slightly when you collect shards — experiment with crafting combos to find secret outcomes. Share your highest score on socials and challenge friends!</div>
        </aside>
      </main>

      {gameOver && (
        <motion.div initial={{ y: 40, opacity: 0 }} animate={{ y: 0, opacity: 1 }} className="fixed inset-0 flex items-center justify-center p-6">
          <div className="bg-black/70 backdrop-blur-sm rounded-3xl p-6 text-center max-w-md w-full">
            <h2 className="text-2xl font-bold mb-3">Echo Faded</h2>
            <p className="mb-3">Score: <strong>{score}</strong> — Depth reached: <strong>{depth}</strong></p>
            <div className="flex gap-3 justify-center">
              <button className="px-4 py-2 rounded-md bg-indigo-600" onClick={resetRun}>Try Again</button>
              <button className="px-4 py-2 rounded-md bg-slate-600" onClick={() => { setGameOver(false); }}>Close</button>
            </div>
          </div>
        </motion.div>
      )}

      <footer className="mt-6 text-xs opacity-80">Prototype built for GitHub Pages. Made-up world — enjoy and remix! ♥</footer>
    </div>
  );
}
