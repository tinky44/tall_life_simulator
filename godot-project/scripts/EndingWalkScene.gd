extends Node2D

## エンディング歩行アニメーション
## 主人公とはるかが並んで歩きながら、成長を追体験するスクロールアニメーション。
## 終了後、既存の EndingScene（身長比較画面）に遷移する。

const NPC_SCENE_PATH = "res://NPC.tscn"
const HARUKA_BASE_APPEARANCE := {
	"hair_style": "ponytail", "hair_color": "#111111",
	"tops_type": "school_uniform", "tops_color": "#ffffff",
	"bottoms_type": "skirt_short", "bottoms_color": "#333333",
	"shoes_type": "loafer", "shoes_color": "#4b4b52",
	"hat_type": "none", "hat_color": "#000000",
	"bag_type": "none", "bag_color": "#000000",
}

const WALK_SPEED := 10.0
const SCROLL_SPEED := 80.0
const STAGE_DURATION_MIN := 2.0
const STAGE_DURATION_MAX := 3.5
const SCENERY_STRIP_WIDTH := 2000.0
const HEIGHT_LERP_SPEED := 8.0
enum ObstacleType { LOW_CEILING = 0, CHIN_BAR = 1, LOW_GATE = 2 }

@onready var _fade_overlay: ColorRect = $UI/FadeOverlay
@onready var _stage_label: Label = $UI/StageLabel
@onready var _height_label: Label = $UI/HeightLabel
@onready var _skip_btn: Button = $UI/SkipButton

var _global: Node
var _protagonist: Node
var _haruka: Node
var _bg_strips: Array = []
var _ground_y: float
var _vp_size: Vector2
var _skipped := false
var _finished := false
var _walking := false
var _growth_stages: Array = []
var _obstacles: Array = []       # 複数障害物管理 [{node, type, height_cm, passed}]
var _ducking := false
var _jumping := false
var _initial_protagonist: Node = null
var _comparison_node: Node2D = null


func _ready() -> void:
	_global = get_node("/root/Global")
	_vp_size = get_viewport().get_visible_rect().size
	_ground_y = _vp_size.y - 60.0

	RenderingServer.set_default_clear_color(Color(0.46, 0.72, 0.98))

	_growth_stages = _build_growth_stages()
	_build_background()
	_spawn_characters()

	_skip_btn.pressed.connect(_on_skip_pressed)
	_fade_overlay.color = Color(0, 0, 0, 1)
	_stage_label.modulate.a = 0.0
	_height_label.modulate.a = 0.0

	_run_animation()


func _process(delta: float) -> void:
	if _skipped or _finished or not _walking:
		return

	for npc in [_protagonist, _haruka]:
		if npc == null:
			continue
		npc.is_walking = true
		npc.walk_phase += WALK_SPEED * delta
		# NPC の _physics_process が無効なので手動で visual_height_cm を補間
		if not _ducking or npc != _protagonist:
			var target_h := float(npc.m["height"])
			npc.visual_height_cm = lerp(npc.visual_height_cm, target_h, HEIGHT_LERP_SPEED * delta)
		npc.character_drawer.queue_redraw()

	# 背景スクロール
	for strip in _bg_strips:
		strip.position.x -= SCROLL_SPEED * delta
	_wrap_background()

	# 障害物との相互作用
	_update_obstacles(delta)


# ─── 成長段階の構築 ─────────────────────────────────────────────

func _build_growth_stages() -> Array:
	var history: Array = _global.growth_history
	if history.is_empty():
		return []

	# growth_history の各エントリを1ステージとして使用（age+term の重複は除去）
	var seen := {}
	var stages := []
	for entry in history:
		var age_val: int = int(entry.get("age", 6))
		var term_val: int = int(entry.get("term", 1))
		var key := "%d_%d" % [age_val, term_val]
		if seen.has(key):
			continue
		seen[key] = true
		stages.append({
			"label": Global.get_school_term_label(age_val, term_val),
			"age": age_val,
			"height": float(entry.get("height", 120.0)),
			"avg_height": float(entry.get("avg_height", _global.get_avg_height(age_val))),
			"repr_age": age_val,
		})

	# 現在の状態が未記録なら最終ステージとして補完
	var cur_age: int = int(_global.age)
	var cur_term: int = int(_global.term)
	var cur_height: float = float(_global.current_params.get("height", 0.0))
	var cur_key := "%d_%d" % [cur_age, cur_term]
	if not seen.has(cur_key) and cur_height > 0.0:
		stages.append({
			"label": Global.get_school_term_label(cur_age, cur_term),
			"age": cur_age,
			"height": cur_height,
			"avg_height": _global.get_avg_height(cur_age),
			"repr_age": cur_age,
		})

	return stages


# ─── キャラクター生成 ──────────────────────────────────────────

func _spawn_characters() -> void:
	if _growth_stages.is_empty():
		return

	var first_stage: Dictionary = _growth_stages[0]
	var protagonist_x := _vp_size.x * 0.30
	var haruka_x := _vp_size.x * 0.60

	# 主人公
	var proto_params := _make_params(first_stage["height"])
	var proto_appearance := _build_protagonist_appearance(first_stage["repr_age"])
	_protagonist = _create_npc(proto_params, proto_appearance, protagonist_x)

	# はるか（主人公より前面に描画）
	var haruka_h: float = _global.get_avg_height(first_stage["age"])
	var haruka_params := _make_params_haruka(haruka_h)
	var haruka_app := _build_haruka_appearance(first_stage["repr_age"])
	_haruka = _create_npc(haruka_params, haruka_app, haruka_x)
	_haruka.z_index = 1


func _create_npc(params: Dictionary, app: Dictionary, x_pos: float) -> Node:
	var npc = load(NPC_SCENE_PATH).instantiate()
	npc.custom_params = params.duplicate(true)
	npc.custom_appearance = app.duplicate(true)
	npc.patrol_range = 0.0
	npc.dir = 1
	npc.facing = "side"
	npc.process_mode = Node.PROCESS_MODE_DISABLED
	npc.position = Vector2(x_pos, _ground_y)
	add_child(npc)
	return npc


func _make_params(height_cm: float) -> Dictionary:
	return {
		"height": height_cm,
		"ratio": _calc_ratio(height_cm),
		"legRatio": 48.0,
		"sex": _global.current_params.get("sex", "female"),
	}


func _make_params_haruka(height_cm: float) -> Dictionary:
	return {
		"height": height_cm,
		"ratio": _calc_ratio(height_cm),
		"legRatio": 45.0,
		"sex": "female",
	}


static func _calc_ratio(h: float) -> float:
	return clampf(5.5 + (h - 100.0) / 30.0, 5.0, 9.0)


func _build_protagonist_appearance(repr_age: int) -> Dictionary:
	var base: Dictionary
	if not _global.initial_appearance.is_empty():
		base = _global.initial_appearance.duplicate(true)
	else:
		base = _global.current_appearance.duplicate(true)
	var uniform: Dictionary = Global.get_school_uniform(repr_age)
	for k in uniform.keys():
		base[k] = uniform[k]
	base["hat_type"] = "school_hat" if repr_age < 12 else "none"
	base["hat_color"] = "#ffd700"
	base["bag_type"] = "randoseru" if repr_age <= 11 else "none"
	if repr_age <= 11:
		base["bag_color"] = Global.RANDOSERU_COLOR
	base["shoes_type"] = "loafer"
	base["shoes_color"] = "#4b4b52"
	return base


func _build_haruka_appearance(repr_age: int) -> Dictionary:
	var base: Dictionary = HARUKA_BASE_APPEARANCE.duplicate(true)
	var uniform: Dictionary = Global.get_school_uniform(repr_age)
	for k in uniform.keys():
		base[k] = uniform[k]
	base["hat_type"] = "school_hat" if repr_age < 12 else "none"
	base["hat_color"] = "#ffd700"
	base["bag_type"] = "none"
	base["shoes_type"] = "loafer"
	base["shoes_color"] = "#4b4b52"
	return base


# ─── 背景 ──────────────────────────────────────────────────────

func _build_background() -> void:
	# 空（固定、スクロールしない）
	var sky_upper := ColorRect.new()
	sky_upper.color = Color(0.42, 0.68, 0.96)
	sky_upper.position = Vector2(0, 0)
	sky_upper.size = Vector2(_vp_size.x, _ground_y * 0.6)
	sky_upper.z_index = -10
	add_child(sky_upper)

	var sky_lower := ColorRect.new()
	sky_lower.color = Color(0.62, 0.82, 0.98)
	sky_lower.position = Vector2(0, _ground_y * 0.6)
	sky_lower.size = Vector2(_vp_size.x, _ground_y * 0.4)
	sky_lower.z_index = -10
	add_child(sky_lower)

	# 地面（固定）
	var ground := ColorRect.new()
	ground.color = Color(0.74, 0.67, 0.48)
	ground.position = Vector2(0, _ground_y)
	ground.size = Vector2(_vp_size.x, _vp_size.y - _ground_y)
	ground.z_index = -3
	add_child(ground)

	# 芝生ライン
	var grass := ColorRect.new()
	grass.color = Color(0.45, 0.70, 0.35)
	grass.position = Vector2(0, _ground_y - 4)
	grass.size = Vector2(_vp_size.x, 8)
	grass.z_index = -2
	add_child(grass)

	# スクロールする景色（2ストリップでシームレスループ）
	for i in range(2):
		var strip := _create_scenery_strip()
		strip.position.x = i * SCENERY_STRIP_WIDTH
		strip.z_index = -5
		add_child(strip)
		_bg_strips.append(strip)


func _create_scenery_strip() -> Node2D:
	var strip := Node2D.new()

	# 柵
	var fence := ColorRect.new()
	fence.color = Color(0.72, 0.58, 0.38)
	fence.position = Vector2(0, _ground_y - 30)
	fence.size = Vector2(SCENERY_STRIP_WIDTH, 4)
	strip.add_child(fence)

	# 柵の柱
	for i in range(int(SCENERY_STRIP_WIDTH / 100)):
		var post := ColorRect.new()
		post.color = Color(0.65, 0.52, 0.32)
		post.position = Vector2(i * 100.0, _ground_y - 50)
		post.size = Vector2(4, 24)
		strip.add_child(post)

	# ベンチ
	_add_bench(strip, 500.0)
	_add_bench(strip, 1400.0)

	# 花壇
	_add_flowers(strip, 200.0)
	_add_flowers(strip, 750.0)
	_add_flowers(strip, 1100.0)
	_add_flowers(strip, 1650.0)

	# 自販機
	_add_vending_machine(strip, 450.0)
	_add_vending_machine(strip, 1200.0)

	# 駐車している車
	_add_car(strip, 820.0)
	_add_car(strip, 1700.0)

	return strip



func _add_bench(parent: Node2D, x: float) -> void:
	var seat := ColorRect.new()
	seat.color = Color(0.60, 0.45, 0.28)
	seat.position = Vector2(x, _ground_y - 22)
	seat.size = Vector2(50, 6)
	parent.add_child(seat)

	for leg_x in [x + 5.0, x + 40.0]:
		var leg := ColorRect.new()
		leg.color = Color(0.45, 0.45, 0.48)
		leg.position = Vector2(leg_x, _ground_y - 16)
		leg.size = Vector2(4, 16)
		parent.add_child(leg)


func _add_flowers(parent: Node2D, x: float) -> void:
	var colors := [
		Color(0.95, 0.30, 0.35), Color(0.95, 0.85, 0.25),
		Color(0.90, 0.50, 0.70), Color(0.65, 0.40, 0.90),
	]
	for i in range(5):
		var flower := ColorRect.new()
		flower.color = colors[i % colors.size()]
		flower.position = Vector2(
			x + i * 10.0 + randf_range(-3.0, 3.0),
			_ground_y - 10.0 + randf_range(-4.0, 2.0),
		)
		flower.size = Vector2(6, 6)
		parent.add_child(flower)


func _add_vending_machine(parent: Node2D, x: float) -> void:
	# StageBuilder の vending_machine 描画をそのまま流用（実物サイズ: 幅80cm×高183cm）
	var p: float = _global.CM_TO_PX
	var x_cm: float = x / p
	var obs := {"id": "vending_machine", "x": x_cm, "x2": x_cm + 80.0, "height": 183, "type": "background"}
	var holder := Node2D.new()
	holder.position = Vector2(0.0, _ground_y)
	parent.add_child(holder)
	StageBuilder._build_obstacle(obs, holder, p)


func _add_car(parent: Node2D, x: float) -> void:
	# StageBuilder の car 描画をそのまま流用（実物サイズ: 幅170cm×高150cm）
	var p: float = _global.CM_TO_PX
	var x_cm: float = x / p
	var obs := {"id": "car", "x": x_cm, "x2": x_cm + 170.0, "height": 150, "type": "background"}
	var holder := Node2D.new()
	holder.position = Vector2(0.0, _ground_y)
	parent.add_child(holder)
	StageBuilder._build_obstacle(obs, holder, p)


func _wrap_background() -> void:
	for strip in _bg_strips:
		if strip.position.x + SCENERY_STRIP_WIDTH < 0:
			var max_x := -INF
			for s in _bg_strips:
				if s != strip and s.position.x > max_x:
					max_x = s.position.x
			strip.position.x = max_x + SCENERY_STRIP_WIDTH


# ─── 障害物 ────────────────────────────────────────────────────

func _spawn_obstacle_sequence() -> void:
	if _protagonist == null:
		return
	var proto_h: float = float(_protagonist.m["height"])

	# 3種の障害物を画面右外に時系列で配置
	var configs := [
		{"type": ObstacleType.LOW_CEILING, "x": _vp_size.x + 150.0,  "h_cm": minf(proto_h - 5.0,  180.0)},
		{"type": ObstacleType.CHIN_BAR,    "x": _vp_size.x + 750.0,  "h_cm": minf(proto_h - 12.0, 172.0)},
		{"type": ObstacleType.LOW_GATE,    "x": _vp_size.x + 1350.0, "h_cm": minf(proto_h - 22.0, 164.0)},
	]
	for cfg in configs:
		var h_px: float = cfg["h_cm"] * _global.CM_TO_PX
		var obs_node := _build_obstacle_visual(cfg["type"], h_px)
		obs_node.position = Vector2(cfg["x"], 0)
		obs_node.z_index = -1
		add_child(obs_node)
		_obstacles.append({"node": obs_node, "type": cfg["type"], "height_cm": cfg["h_cm"], "passed": false})


func _build_obstacle_visual(type: int, h_px: float) -> Node2D:
	var root := Node2D.new()
	match type:
		ObstacleType.LOW_CEILING:
			# 長い天井板（左右に壁断面）
			var ceiling := ColorRect.new()
			ceiling.color = Color(0.55, 0.50, 0.42)
			ceiling.position = Vector2(-80.0, _ground_y - h_px - 10.0)
			ceiling.size = Vector2(160.0, 12.0)
			root.add_child(ceiling)
			for wx: float in [-80.0, 68.0]:
				var wall := ColorRect.new()
				wall.color = Color(0.48, 0.44, 0.36)
				wall.position = Vector2(wx, _ground_y - h_px - 10.0)
				wall.size = Vector2(12.0, h_px + 10.0)
				root.add_child(wall)
		ObstacleType.CHIN_BAR:
			# 鉄棒（支柱2本＋横棒）
			for px: float in [-30.0, 22.0]:
				var post := ColorRect.new()
				post.color = Color(0.45, 0.45, 0.48)
				post.position = Vector2(px, _ground_y - h_px - 8.0)
				post.size = Vector2(8.0, h_px + 8.0)
				root.add_child(post)
			var bar := ColorRect.new()
			bar.color = Color(0.70, 0.70, 0.75)
			bar.position = Vector2(-30.0, _ground_y - h_px - 8.0)
			bar.size = Vector2(60.0, 8.0)
			root.add_child(bar)
		ObstacleType.LOW_GATE:
			# くぐり戸（門柱2本＋上梁）
			var beam_w := 100.0
			var post_w := 10.0
			var beam := ColorRect.new()
			beam.color = Color(0.52, 0.40, 0.26)
			beam.position = Vector2(-beam_w / 2.0, _ground_y - h_px - 12.0)
			beam.size = Vector2(beam_w, 14.0)
			root.add_child(beam)
			for px: float in [-beam_w / 2.0, beam_w / 2.0 - post_w]:
				var post := ColorRect.new()
				post.color = Color(0.46, 0.35, 0.22)
				post.position = Vector2(px, _ground_y - h_px - 12.0)
				post.size = Vector2(post_w, h_px + 12.0)
				root.add_child(post)
	return root


func _spawn_obstacles_loop() -> void:
	var types := [ObstacleType.LOW_CEILING, ObstacleType.CHIN_BAR, ObstacleType.LOW_GATE]
	var idx := 0
	await get_tree().create_timer(4.0).timeout
	while _walking and not _skipped:
		if _protagonist != null:
			_spawn_single_obstacle(types[idx % types.size()])
			idx += 1
		await get_tree().create_timer(7.0).timeout


func _spawn_single_obstacle(type: int) -> void:
	if _protagonist == null:
		return
	var proto_h: float = float(_protagonist.m["height"])
	var h_cm: float
	match type:
		ObstacleType.LOW_CEILING: h_cm = minf(proto_h - 5.0,  180.0)
		ObstacleType.CHIN_BAR:   h_cm = minf(proto_h - 12.0, 172.0)
		ObstacleType.LOW_GATE:   h_cm = minf(proto_h - 22.0, 164.0)
	var h_px: float = h_cm * _global.CM_TO_PX
	var obs_node := _build_obstacle_visual(type, h_px)
	obs_node.position = Vector2(_vp_size.x + 200.0, 0.0)
	obs_node.z_index = -1
	add_child(obs_node)
	_obstacles.append({"node": obs_node, "type": type, "height_cm": h_cm, "passed": false})


func _update_obstacles(delta: float) -> void:
	var proto_x: float = _protagonist.position.x if _protagonist else 0.0
	var haruka_x: float = _haruka.position.x if _haruka else 0.0
	var any_proto_active := false

	for obs in _obstacles:
		if obs.get("passed", false):
			continue
		obs["node"].position.x -= SCROLL_SPEED * delta
		var obs_x: float = obs["node"].position.x
		var dp: float = obs_x - proto_x  # 正=まだ来ていない, 負=通過中
		var dh: float = obs_x - haruka_x

		match obs["type"]:
			ObstacleType.LOW_CEILING:
				# 主人公: 天井に頭が当たるなら屈む
				if dp < 80.0 and dp > -140.0:
					any_proto_active = true
					_ducking = true
					_protagonist.visual_height_cm = lerp(
						_protagonist.visual_height_cm, obs["height_cm"] - 3.0, 9.0 * delta)
				# はるかはそのまま通過

			ObstacleType.CHIN_BAR:
				# 主人公: 近づいたらジャンプ
				if dp < 60.0 and dp > -20.0 and not _jumping:
					_start_jump()
				# はるか: 棒の下をくぐる
				if dh < 70.0 and dh > -100.0 and _haruka != null:
					_haruka.visual_height_cm = lerp(
						_haruka.visual_height_cm, obs["height_cm"] - 5.0, 8.0 * delta)

			ObstacleType.LOW_GATE:
				# 主人公: 深く屈む
				if dp < 70.0 and dp > -130.0:
					any_proto_active = true
					_ducking = true
					_protagonist.visual_height_cm = lerp(
						_protagonist.visual_height_cm, obs["height_cm"] - 10.0, 10.0 * delta)
				# はるか: ゲート高より高ければ軽く屈む
				if dh < 70.0 and dh > -100.0 and _haruka != null:
					var haruka_h: float = float(_haruka.m["height"])
					if haruka_h > obs["height_cm"]:
						_haruka.visual_height_cm = lerp(
							_haruka.visual_height_cm, obs["height_cm"] - 3.0, 7.0 * delta)

		if obs_x < -300.0:
			obs["node"].queue_free()
			obs["passed"] = true

	# 全障害物を通過したら屈み解除
	if not any_proto_active:
		_ducking = false

	# 通過済みを除去
	_obstacles = _obstacles.filter(func(o: Dictionary) -> bool: return not o.get("passed", false))


func _start_jump() -> void:
	if _jumping or _protagonist == null:
		return
	_jumping = true
	var base_y: float = _protagonist.position.y
	var tw := create_tween()
	tw.tween_property(_protagonist, "position:y", base_y - 38.0, 0.25)
	tw.tween_property(_protagonist, "position:y", base_y, 0.28)
	tw.tween_callback(func() -> void: _jumping = false)


# ─── アニメーション制御 ────────────────────────────────────────

func _run_animation() -> void:
	if _growth_stages.is_empty():
		_transition_to_ending()
		return

	# ステージ数に応じて表示時間を動的に決定
	var stage_dur: float = clampf(
		20.0 / max(_growth_stages.size(), 1),
		STAGE_DURATION_MIN, STAGE_DURATION_MAX
	)

	# (1) 暗転からフェードイン
	var tw_in := create_tween()
	tw_in.tween_property(_fade_overlay, "color:a", 0.0, 0.8)
	await tw_in.finished
	if _skipped:
		return

	# (2) 歩行開始・障害物ループ起動（fire-and-forget）
	_walking = true
	_spawn_obstacles_loop()

	# (3) 最初の段階を表示
	_show_labels(_growth_stages[0])

	await get_tree().create_timer(stage_dur).timeout
	if _skipped:
		return

	# (4) 後続の成長段階
	for i in range(1, _growth_stages.size()):
		await _transition_to_stage(_growth_stages[i])
		if _skipped:
			return
		await get_tree().create_timer(stage_dur).timeout
		if _skipped:
			return

	# (5) 成長サマリーを表示（障害物はウォーク開始時からループ生成済み）
	await _show_growth_summary()
	if _skipped:
		return

	await get_tree().create_timer(3.0).timeout
	if _skipped:
		return

	# (7) EndingScene へ遷移
	_transition_to_ending()


func _transition_to_stage(stage: Dictionary) -> void:
	# 白フラッシュ
	var tw1 := create_tween()
	tw1.tween_property(_fade_overlay, "color", Color(1, 1, 1, 0.6), 0.15)
	await tw1.finished
	if _skipped:
		return

	# 主人公: 新しい身長・制服に更新
	# visual_height_cm を新身長に即時セットすることで屈みポーズ判定を防ぐ
	_protagonist.custom_params = _make_params(stage["height"]).duplicate(true)
	_protagonist.custom_appearance = _build_protagonist_appearance(stage["repr_age"]).duplicate(true)
	_protagonist.update_measurements()
	_protagonist.visual_height_cm = stage["height"]

	# はるか: 年齢相応の平均身長に更新
	var haruka_h: float = _global.get_avg_height(stage["age"])
	_haruka.custom_params = _make_params_haruka(haruka_h).duplicate(true)
	_haruka.custom_appearance = _build_haruka_appearance(stage["repr_age"]).duplicate(true)
	_haruka.update_measurements()
	_haruka.visual_height_cm = haruka_h

	# フラッシュ戻し
	var tw2 := create_tween()
	tw2.tween_property(_fade_overlay, "color", Color(1, 1, 1, 0), 0.3)
	await tw2.finished

	_show_labels(stage)


func _show_labels(stage: Dictionary) -> void:
	_stage_label.text = stage["label"]
	var diff_avg: float = stage["height"] - stage["avg_height"]
	_height_label.text = "身長 %.0fcm（平均%+.0fcm）" % [stage["height"], diff_avg]

	if _stage_label.modulate.a < 0.5:
		var tw := create_tween().set_parallel(true)
		tw.tween_property(_stage_label, "modulate:a", 1.0, 0.4)
		tw.tween_property(_height_label, "modulate:a", 1.0, 0.4)


func _show_growth_summary() -> void:
	if _growth_stages.is_empty():
		return

	_walking = false

	# はるかを非表示
	if _haruka != null:
		_haruka.visible = false

	var first_stage: Dictionary = _growth_stages[0]
	var last_stage: Dictionary = _growth_stages[-1]
	var first_h: float = first_stage["height"]
	var last_h: float = last_stage["height"]
	var growth: float = last_h - first_h

	# キャラクター配置
	var init_x := _vp_size.x * 0.33
	var final_x := _vp_size.x * 0.57

	# 最終主人公: 位置調整・停止
	_protagonist.position.x = final_x
	_protagonist.is_walking = false
	_protagonist.visual_height_cm = last_h
	_protagonist.character_drawer.queue_redraw()

	# 初期主人公を生成（透過なし）
	var init_params := _make_params(first_h)
	var init_app := _build_protagonist_appearance(first_stage["repr_age"])
	_initial_protagonist = _create_npc(init_params, init_app, init_x)
	_initial_protagonist.visual_height_cm = first_h
	_initial_protagonist.is_walking = false
	_initial_protagonist.modulate.a = 1.0
	_initial_protagonist.character_drawer.queue_redraw()

	# 身長差インジケーター描画
	_draw_comparison_ui(first_h, last_h, init_x, final_x)

	# テキスト
	_stage_label.text = "成長の記録"
	_height_label.text = "%.0fcm → %.0fcm（+%.0fcm 成長！）" % [first_h, last_h, growth]

	var tw := create_tween().set_parallel(true)
	tw.tween_property(_stage_label, "modulate:a", 1.0, 0.4)
	tw.tween_property(_height_label, "modulate:a", 1.0, 0.4)
	await tw.finished


func _draw_comparison_ui(first_h: float, last_h: float, init_x: float, final_x: float) -> void:
	if _comparison_node != null:
		_comparison_node.queue_free()

	_comparison_node = Node2D.new()
	_comparison_node.z_index = 5
	add_child(_comparison_node)

	var first_h_px: float = first_h * _global.CM_TO_PX
	var last_h_px: float = last_h * _global.CM_TO_PX
	var growth: float = last_h - first_h

	# 矢印を2キャラの中間に配置
	var mid_x := (init_x + final_x) / 2.0 + 10.0
	var top_final := _ground_y - last_h_px   # 最終主人公の頭頂
	var top_init  := _ground_y - first_h_px  # 初期主人公の頭頂

	var arrow_color := Color(0.95, 0.25, 0.25, 1.0)
	var line_w := 2.0
	var tick_w := 14.0

	# 縦線（頭頂差を繋ぐ）
	var v_line := ColorRect.new()
	v_line.color = arrow_color
	v_line.position = Vector2(mid_x - line_w / 2.0, top_final)
	v_line.size = Vector2(line_w, top_init - top_final)
	_comparison_node.add_child(v_line)

	# 上ティック（最終主人公の頭高さ）
	var tick_top := ColorRect.new()
	tick_top.color = arrow_color
	tick_top.position = Vector2(mid_x - tick_w / 2.0, top_final - 1.0)
	tick_top.size = Vector2(tick_w, 3.0)
	_comparison_node.add_child(tick_top)

	# 下ティック（初期主人公の頭高さ）
	var tick_bot := ColorRect.new()
	tick_bot.color = arrow_color
	tick_bot.position = Vector2(mid_x - tick_w / 2.0, top_init - 1.0)
	tick_bot.size = Vector2(tick_w, 3.0)
	_comparison_node.add_child(tick_bot)

	# "+XXcm" ラベル
	var lbl := Label.new()
	lbl.text = "+%.0fcm" % growth
	lbl.add_theme_color_override("font_color", arrow_color)
	lbl.add_theme_font_size_override("font_size", 22)
	lbl.position = Vector2(mid_x + 6.0, (top_final + top_init) / 2.0 - 14.0)
	_comparison_node.add_child(lbl)


# ─── スキップ・遷移 ────────────────────────────────────────────

func _on_skip_pressed() -> void:
	if _skipped or _finished:
		return
	_skipped = true
	_walking = false
	var tw := create_tween()
	tw.tween_property(_fade_overlay, "color", Color(0, 0, 0, 1), 0.3)
	await tw.finished
	get_tree().change_scene_to_file("res://scenes/EndingScene.tscn")


func _transition_to_ending() -> void:
	if _skipped:
		return
	_finished = true
	_walking = false
	var tw := create_tween()
	tw.tween_property(_fade_overlay, "color", Color(0, 0, 0, 1), 1.0)
	await tw.finished
	get_tree().change_scene_to_file("res://scenes/EndingScene.tscn")
