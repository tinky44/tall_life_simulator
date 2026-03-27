# Tall Life Simulator（トールライフシミュレーター）

[![Play Now!](https://img.shields.io/badge/Play-Web_Version-green?style=for-the-badge&logo=godotengine)](https://tinky44.github.io/tall_life_simulator/)

[感想お待ちしております！](https://docs.google.com/forms/d/e/1FAIpQLScLX_9BPy6C1sz0aZ9qgVi_qHGIWhBPBJzX3hucorF2V763Rw/viewform?usp=publish-editor)

## 概要

**Tall Life Simulator** は、高身長な人物の日常を追体験する Godot 4.x 製ライフシミュレーターです。
キャラクター作成から学校生活・成長の記録まで、100cm〜240cm超の身長差が生む「独自の視点と工夫」を体験できます。

## 主な機能

### 動的プロポーション
- 7〜9頭身、脚比率などを細かくカスタマイズ可能なキャラクター作成
- 身長に応じてアニメーション・当たり判定がリアルタイムに変化

### 自動屈みアクション
- 天井の低い場所・電車のつり革に頭がぶつからないよう自然に屈む
- 屈み量は目標身長まで二分探索で正確に計算

### 成長と時間の流れ
- 学期ごとの身長測定と成長曲線の記録
- 小学校〜高校まで、制服・ステージ・NPC反応が学年に応じて変化

### 多様なステージ
- 自宅・学校（教室/廊下/校庭/保健室）・駅・電車内・屋外など
- NPCとの身長差反応、障害物との干渉をリアルタイムに体験

### エンディング
- 学校段階ごとの成長を振り返る歩行アニメーション演出
- 初期身長 vs 最終身長の比較画面

## ローカルでの実行方法

```bash
# リポジトリをクローン
git clone https://github.com/tinky44/tall_life_simulator.git

# Godot エディタで開く（Godot 4.x が必要）
godot --path godot-project --editor
```

`godot-project/project.godot` をインポートして「▶ 再生」で起動します。

## プロジェクト構造

```
tall_life_simulator/
├── godot-project/          # Godot プロジェクト本体
│   ├── scripts/            # GDScript（27ファイル）
│   ├── scenes/             # シーンファイル（.tscn）
│   └── project.godot
├── docs/                   # GitHub Pages（ビルド成果物）
├── assets/                 # 素材ファイル
└── specs/                  # 設計仕様書
```

## ドキュメント

- [詳細仕様書](specs/spec.md)
- [キャラクター描画システム](specs/character_drawing_system.md)
- [ゲームストーリー仕様](specs/game_story/game_story_spec.md)
- [AIエージェント向け定義（CLAUDE.md）](CLAUDE.md)

## 開発環境

| 項目 | 内容 |
|---|---|
| エンジン | Godot 4.6 |
| 言語 | GDScript |
| レンダラー | GL Compatibility |
| フォント | Noto Sans CJK JP |

## ライセンス

このゲームはGodot Engineを利用して制作されました。

```
This game uses Godot Engine, available under the following license:

Copyright (c) 2014-present Godot Engine contributors.
Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
---

*Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>*
