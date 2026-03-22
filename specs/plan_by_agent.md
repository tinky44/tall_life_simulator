# エンディングアニメーション 企画メモ

> Issue #85 より。2026-03-22 整理。

---

## コンセプト

ゲームのテーマである「身長が変わると日常体験が変わる」をエンディングで追体験させる。

小学生の頃は屈まずくぐれた障害物が、成長とともに膝まで曲げないとくぐれなくなる。
逆に鉄棒など、背が高くなることでジャンプ一つで届くようになるものもある。
こうした変化を、はるか（平均身長の女の子）と並んで歩きながら体験させることで
「長身として生きる日常」をクロージングとして印象づける。

---

## シーン構成案

### 1. 冒頭 — 歩行開始
- 主人公（最終学年の身長）とはるかが並んで歩き出す
- 背景：街並み、公園、車などが横スクロールで流れていく

### 2. 中盤 — 障害物との遭遇
主人公の学年に合わせた制服を着用しながら、障害物を次々とくぐる・越える。

| 障害物 | 主人公の動作 | はるかの動作 |
|---|---|---|
| 低い入口・くぐり戸 | 深く屈んでくぐる | 軽く屈む or そのまま通過 |
| 鉄棒 | あきらめてジャンプして飛び越える | 屈んでくぐる |
| 天井の低い場所 | 頭をかがめながら通過 | 普通に歩く |

### 3. 制服の変化
- ゲーム開始（小学生）→ 中学生 → 高校生 と学年に合わせて制服が変わる
- 身長もそれに合わせて変化して見せてもよい

### 4. ラスト — 身長比較
- 初期（ゲーム開始時）の主人公とエンディング時の主人公を並べて身長比較
- はるかはこのシーンでは消しても良い
- 成長の可視化で達成感を演出

---

## BGM候補

音楽の卵 様より「散歩」
https://ontama-m.com/ongaku_akarui.html

---

## 成長記録データ構造（Global.gd）

エンディングアニメーションの各フレームは `global.growth_history` の記録に従って描画する。

```gdscript
# Global.gd
var growth_history: Array = []

# 各エントリの構造
{
    "term":       int,    # 学期番号（小1=6、中1=27、高1=36）
    "age":        int,    # 年齢（6〜18）
    "height":     float,  # その時点の身長（cm）
    "avg_height": float,  # 学年平均身長（cm）
    "diff_avg":   float,  # 平均との差（height - avg_height）
    "diff_prev":  float,  # 前回測定からの差（cm）
    "source":     String  # "start" / "measurement"
}
```

### 平均身長定数（はるかの身長として使用）

```gdscript
const AVG_HEIGHT_FEMALE: Dictionary = {
    6: 113.0, 7: 119.0, 8: 124.0, 9: 130.0, 10: 136.0, 11: 143.0,
    12: 150.0, 13: 154.0, 14: 156.0, 15: 157.0, 16: 158.0, 17: 158.5, 18: 158.5
}
# 取得: global.get_avg_height(age)
```

### エンディングアニメーションへの活用方針

- `growth_history[0]` → ゲーム開始時（小学生）の身長・制服
- `growth_history[-1]` → 最終測定時の身長・制服
- 各エントリの `age` から制服・学校種別を判定
  - 6〜11歳：小学生、12〜14歳：中学生、15〜17歳：高校生
- `entry["height"]` と `global.get_avg_height(entry["age"])` の比率でキャラクター描画スケールを決定
- アニメーション中の身長変化は history をキーフレームとして補間

### 学年変換ユーティリティ（Global.gd）

```gdscript
global.term_to_age(t: int) -> int
global.age_to_term(a: int) -> int
global.get_school_term_label(age, term) -> String  # "小学1年 1学期"
```

---

## エンディング遷移条件

### トリガー：`pending_term_choice` フラグ（Global.gd:495）

`advance_term()` の中で、**学校段階（school_level）が変わった学期**に `true` になる。

| タイミング | 内容 |
|---|---|
| 小4進級（age 9） | school_level 0 → 1 |
| 中学入学（age 12） | school_level 1 → 2 |
| 高校入学（age 15） | school_level 2 → 3 |
| 高校卒業（age 18） | school_level 3 → 4 |

### 表示：学年選択パネル（MainScene.gd:639）

`_show_term_choice_panel()` により、学期開始の導入セリフが終わった直後にポーズして選択肢を表示。

```
[ 1. このまま続ける ]
[ 2. エンディングへ  ]
```

### 遷移先（MainScene.gd:931）

「エンディングへ」を選択すると:

```gdscript
get_tree().change_scene_to_file("res://scenes/EndingWalkScene.tscn")
```

→ `EndingWalkScene.tscn` へ遷移（`EndingScene.tscn` とは別シーン）

### ⚠️ 設計上の課題（レビュー指摘）

エンディングは卒業時だけでなく**小4・中学入学・高校入学・卒業**の4節目すべてで起動しうる。
「制服ごとの成長を通しで見せる」企画と矛盾するため、下記を先に決める必要がある。

- **案A：卒業時専用にする** — 小4/中/高進級時は選択肢を出さない or「続ける」のみにする
- **案B：その時点までの到達段階だけで構成する** — 小4でエンディングを選んだら小学生パートのみ再生

---

## 実装メモ（未着手）

- `EndingScene.tscn` はすでに存在する → `EndingScene.gd` を拡張する
- 横スクロール演出はTween or AnimationPlayerで制御
- 障害物は `StageBuilder.gd` のオブジェクト定義を流用できるか検討
- 制服変化はキャラクター描画システムへの色・形パラメータ追加が必要
- はるかの身長は `global.get_avg_height(age)` で取得（固定値ではなく年齢連動）


レビュー結果

Findings

High: この案は「最終学年の主人公」で通しの成長アニメをやる前提ですが、現行フローのエンディング導線は卒業時だけではありません。plan_by_agent.md (line 21) と plan_by_agent.md (line 34) は小→中→高を通しで見せる想定ですが、実装側は Global.gd (line 494) で「小4進級 / 中学 / 高校 / 卒業」の各節目に終了選択を出し、MainScene.gd (line 106) と MainScene.gd (line 931) でそのまま EndingScene.tscn に遷移します。企画側で「卒業専用にする」のか「その時点までの到達段階だけで構成する」のかを先に決めないと、未到達の学校段階を見せるか、既存導線を壊すかのどちらかになります。

→** その時点までの到達段階だけで構成する**

High: EndingScene.tscn を新規作成する前提が、現行実装と衝突しています。plan_by_agent.md (line 53) に対して、すでに EndingScene.gd (line 3) と EndingScene.gd (line 48) で「初期シルエット / はるか / 現在の主人公」の比較画面が実装済みです。このメモだと「既存エンディングを置き換えるのか」「歩行アニメのあとに比較画面へ遷移するのか」「別シーンを挟むのか」が未定義なので、作業分解の出発点が曖昧です。

→歩行アニメのあとに比較画面へ遷移するのか

Medium: 制服変化と身長変化の見せ方に必要なデータ源が不足しています。plan_by_agent.md (line 33) は学校段階ごとの見た目変化を前提にしていますが、現状エンディングが直接使えるのは EndingScene.gd (line 30) の initial_params / initial_appearance と EndingScene.gd (line 52) の current_params / current_appearance だけです。growth_history は Global.gd (line 260) のとおり高さログ中心で、各時点の外見は保持していません。中間制服を年齢から都度再構成するのか、エンディング用スナップショットを保存するのかが決まっていないと、実装に入れません。

Medium: 障害物ごとの動作表が、今あるキャラ制御の粒度と噛み合っていません。plan_by_agent.md (line 27) では鉄棒を「ジャンプして飛び越える」としていますが、現行のプレイヤー側で明示的に扱っている姿勢は SkeletalPlayer.gd (line 190) の normal / taiiku_suwari / chair_sit / sleep で、屈みは character_pose_spec.md (line 21) と character_pose_spec.md (line 228) のように高さ制約ベースです。つまり、この案を実装するには「既存プレイヤーをそのまま動かす」のではなく、エンディング専用の演出リグか、少なくともジャンプ相当の新アニメーション仕様が必要です。

　→ジャンプは不要でもいい。

Open Questions

plan_by_agent.md は、既存の比較エンディングの前段に差し込む案ですか、それとも EndingScene.gd の全面置換ですか。
早期終了ルートでもこの演出を流す想定なら、「未進学の制服や障害物は出さない」制約を明記したほうが安全です。
