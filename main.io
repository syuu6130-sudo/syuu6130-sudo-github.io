import json
import random
import time
import os
from datetime import datetime

# ============================================================
#  Mini Game Project (Number Guessing & Score Ranking)
#  ~200 lines sample project
# ============================================================

DATA_FILE = "scores.json"

# -------------------------------
# Utility functions
# -------------------------------
def load_scores():
    """Load scores from JSON file."""
    if not os.path.exists(DATA_FILE):
        return []

    try:
        with open(DATA_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    except:
        return []


def save_scores(scores):
    """Save score list to JSON file."""
    with open(DATA_FILE, "w", encoding="utf-8") as f:
        json.dump(scores, f, indent=4, ensure_ascii=False)


def clear_screen():
    """Clear console screen."""
    os.system("cls" if os.name == "nt" else "clear")


# -------------------------------
# Game logic
# -------------------------------
def play_game(player_name):
    clear_screen()
    print("=========================================")
    print("        🔢 Number Guessing Game")
    print("=========================================")

    target = random.randint(1, 100)
    attempts = 0
    start_time = time.time()

    while True:
        try:
            guess = int(input("1〜100の間で予想してね："))
        except:
            print("数字を入力してね。")
            continue

        attempts += 1

        if guess < target:
            print("もっと大きいよ！")
        elif guess > target:
            print("もっと小さいよ！")
        else:
            break

    end_time = time.time()
    duration = round(end_time - start_time, 2)

    score = {
        "name": player_name,
        "attempts": attempts,
        "time": duration,
        "date": datetime.now().strftime("%Y/%m/%d %H:%M:%S")
    }

    print("\n🎉 おめでとう！ 正解は", target)
    print(f"⏱️ 時間: {duration}s")
    print(f"🧮 試行回数: {attempts} 回")

    # Save score
    scores = load_scores()
    scores.append(score)
    save_scores(scores)

    input("\nEnterキーでメニューへ戻る...")
    clear_screen()


# -------------------------------
# Ranking system
# -------------------------------
def show_ranking():
    clear_screen()
    print("=========================================")
    print("               🏆 Ranking")
    print("=========================================\n")

    scores = load_scores()
    if not scores:
        print("ランキングデータがありません。")
        input("\nEnterで戻る…")
        return

    # Sort by attempts, then time
    sorted_scores = sorted(scores, key=lambda x: (x["attempts"], x["time"]))

    for i, s in enumerate(sorted_scores[:20], start=1):
        print(f"{i:2d}位 | {s['name']:<12} | {s['attempts']:>2} 回 | {s['time']:>5}s | {s['date']}")

    input("\nEnterで戻る…")


# -------------------------------
# Delete all scores
# -------------------------------
def reset_scores():
    clear_screen()
    print("⚠️ 本当にリセットしますか？")
    print("1: はい\n2: いいえ")
    ans = input(">> ")

    if ans == "1":
        save_scores([])
        print("データを削除しました。")
    else:
        print("キャンセルしました。")

    input("\nEnterでメニューへ戻る...")


# -------------------------------
# Main menu
# -------------------------------
def main_menu():
    clear_screen()
    print("=========================================")
    print("      🎮 Simple Python Game System")
    print("=========================================\n")
    print("1: ゲーム開始")
    print("2: ランキング表示")
    print("3: データリセット")
    print("4: 終了\n")

    return input("番号を入力: ")


# -------------------------------
# Main program
# -------------------------------
def main():
    clear_screen()
    print("=========================================")
    print("     🎉 Mini Game Project (200 lines)")
    print("=========================================\n")

    name = input("あなたの名前を入力してください: ").strip()
    if not name:
        name = "Player"

    while True:
        select = main_menu()

        if select == "1":
            play_game(name)
        elif select == "2":
            show_ranking()
        elif select == "3":
            reset_scores()
        elif select == "4":
            print("また遊んでね！")
            break
        else:
            print("1〜4を入力してね。")
            time.sleep(1)


if __name__ == "__main__":
    main()
