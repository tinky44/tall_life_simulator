extends CharacterBody2D

signal head_bump(obs_id: String, obs_height_cm: float)

var SPEED: float = 250.0
const JUMP_VELOCITY = -500.0
const GRAVITY = 1200.0
const HEAD_BUMP_COOLDOWN := 0.35
const HEAD_BUMP_SHAKE_TIME := 0.18
const HEAD_BUMP_SHAKE_STRENGTH := 6.0
const BASE_MOVE_SPEED := 250.0
const BASE_WALK_SPEED := 12.0
const BASE_LEG_CM := 180.0 * 0.48
var CM_TO_PX: float = 2.0

var facing: String = "side"
var dir: int = 1
var is_walking: bool = false
var walk_phase: float = 0.0
var walk_speed: float = 12.0
var pose: String = "normal"
var appearance: Dictionary = {}  # 空のとき CharacterDrawer は Global.current_appearance を使用
var receives_global_stress: bool = true

var auto_crouch: bool = true
var target_crouch_cm: float = -1.0
var visual_height_cm: float = 180.0
var is_crouch_impossible: bool = false

var look_head_angle: float = 0.0
var look_pitch: float = 0.0

var m: Dictionary

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var character_drawer: Node2D = $CharacterDrawer

var sensors: Array = []
var _head_bump_cooldown_left: float = 0.0
var _head_bump_shake_left: float = 0.0
var _camera_base_offset: Vector2 = Vector2.ZERO
var _camera_shake_active: bool = false

# ポーズ遷移の補間用
var smooth_d: Dictionary = {}
const POSE_LERP_SPEED: float = 7.0
const REDRAW_MIN_INTERVAL_SEC := 0.0
const IDLE_REDRAW_INTERVAL_SEC := 0.30
const REDRAW_STATE_HEIGHT_EPS_CM := 0.03
const REDRAW_STATE_ANGLE_EPS := 0.003
const REDRAW_STATE_PITCH_EPS := 0.06
const REDRAW_POSE_EPS := {
	"leg_l_angle": 0.08,
	"leg_r_angle": 0.08,
	"arm_l_angle": 0.08,
	"arm_r_angle": 0.08,
	"knee_l": 0.01,
	"knee_r": 0.01,
	"waist_angle": 0.01,
	"y_crotch": 0.20,
	"hy": 0.20,
	"front_hy": 0.20,
}
const REDRAW_POSE_KEYS := ["leg_l_angle", "leg_r_angle", "arm_l_angle", "arm_r_angle", "knee_l", "knee_r"]

var _ceiling_sensor_cached_frame: int = -1
var _ceiling_sensor_colliding: bool = false
var _ceiling_sensor_height_cm: float = INF

var _redraw_elapsed_sec: float = REDRAW_MIN_INTERVAL_SEC
var _last_draw_dir: int = 0
var _last_draw_facing: String = ""
var _last_draw_pose: String = ""
var _last_draw_is_walking: bool = false
var _last_draw_walk_phase: float = 0.0
var _last_draw_visual_height_cm: float = 0.0
var _last_draw_look_head_angle: float = 0.0
var _last_draw_look_pitch: float = 0.0
var _last_draw_pose_values: Dictionary = {}

# 着席コンテキスト（-1 = 未設定、固定値にフォールバック）
var sit_context: Dictionary = {
	"seat_h_cm": -1.0,  # 座面高さ [cm]
	"desk_h_cm": -1.0,  # 机の高さ [cm]（-1 = 机なし）
}

func _ready() -> void:
	collision_layer = 0
	collision_mask |= 4
	update_measurements()

func update_measurements() -> void:
	if has_node("/root/Global"):
		var global = get_node("/root/Global")
		m = global.get_body_measurements()
		CM_TO_PX = global.CM_TO_PX
		visual_height_cm = m["height"]
	else:
		m = _mock_measurements()
		visual_height_cm = m["height"]

	for s in sensors:
		s.queue_free()
	sensors.clear()

	_setup_sensors()
	_update_collision()
	refresh_movement_tuning()
	_reset_redraw_tracking()
	_invalidate_ceiling_sensor_cache()

	if character_drawer:
		_queue_redraw_if_needed(REDRAW_MIN_INTERVAL_SEC, true)

func refresh_movement_tuning() -> void:
	if m == null or m.is_empty():
		return

	var base_move_speed: float = BASE_MOVE_SPEED
	if has_node("/root/Global"):
		var global = get_node("/root/Global")
		base_move_speed = float(global.system_settings.get("move_speed", BASE_MOVE_SPEED))

	var leg_cm: float = float(m.get("leg", BASE_LEG_CM))
	var leg_scale: float = clampf(leg_cm / BASE_LEG_CM, 0.65, 1.8)

	# 脚が長いほど一歩が伸びるので、前進速度だけ身長に応じて伸ばす。
	# 歩行テンポはベース速度設定にのみ追従させ、足運びとのズレを抑える。
	SPEED = base_move_speed * leg_scale
	walk_speed = BASE_WALK_SPEED * (base_move_speed / BASE_MOVE_SPEED)

func _process(delta: float) -> void:
	_update_look_at_npc(delta)

func _update_look_at_npc(delta: float) -> void:
	var parent = get_parent()
	var nearest_npc: Node2D = null
	var nearest_dist: float = INF

	for child in parent.get_children():
		if child == self:
			continue
		if child.get("npc_id") == null:
			continue
		var npc_m = child.get("m")
		if npc_m == null or npc_m.is_empty():
			continue
		var dist_x: float = abs(global_position.x - child.global_position.x)
		if dist_x < nearest_dist:
			nearest_dist = dist_x
			nearest_npc = child

	if nearest_npc == null or nearest_dist > 170.0:
		look_head_angle = lerp_angle(look_head_angle, 0.0, 5.0 * delta)
		look_pitch = lerp(look_pitch, 0.0, 5.0 * delta)
		return

	var npc_m: Dictionary = nearest_npc.get("m")
	var my_eye_y: float = global_position.y - float(m["landmarks"]["eye"]) * CM_TO_PX
	var npc_eye_y: float = nearest_npc.global_position.y - float(npc_m["landmarks"]["eye"]) * CM_TO_PX
	var diff_y_px: float = npc_eye_y - my_eye_y
	var angle: float = clamp(atan2(diff_y_px, max(nearest_dist, 1.0)), -PI / 3.0, PI / 3.0)

	look_head_angle = lerp_angle(look_head_angle, angle, 8.0 * delta)
	var max_pitch: float = float(m["head"]) * CM_TO_PX * 0.2
	look_pitch = lerp(look_pitch, sin(angle) * max_pitch, 8.0 * delta)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	_handle_input()
	_handle_auto_crouch()
	_update_visual_height(delta)

	# 脚の痛み・成長痛による速度補正
	var _leg_pain_factor = 1.0
	if has_node("/root/Global"):
		var _g = get_node("/root/Global")
		if _g.get("is_leg_pain"):
			_leg_pain_factor = 0.5
		elif _g.is_growth_pain_active():
			_leg_pain_factor = 0.75

	var direction := Input.get_axis("ui_left", "ui_right")

	# 屈み時は歩幅が短くなる分だけ移動速度を下げてスライド感を防ぐ
	var crouch_analysis: Dictionary = {}
	var crouch_speed_mult := 1.0
	if pose == "normal" and not m.is_empty():
		crouch_analysis = CharacterPoseCalculator.get_crouch_analysis(visual_height_cm, m, CM_TO_PX)
		crouch_speed_mult = maxf(float(crouch_analysis.get("stride_ratio", 1.0)), 0.2)

	if pose != "normal" or is_crouch_impossible:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	elif direction:
		velocity.x = direction * SPEED * _leg_pain_factor * crouch_speed_mult
		dir = int(sign(direction))
		if not (Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down")):
			facing = "side"
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	is_walking = (velocity.x != 0)
	if is_walking:
		walk_phase += walk_speed * _leg_pain_factor * delta
	else:
		walk_phase = lerp_angle(walk_phase, 0.0, 10.0 * delta)

	_update_collision()
	_update_smooth_pose(delta, crouch_analysis)
	move_and_slide()
	_process_head_bump(delta)
	_update_camera_shake()
	_queue_redraw_if_needed(delta)

func _handle_input() -> void:
	if Input.is_action_pressed("ui_up"):
		facing = "back"
	elif Input.is_action_pressed("ui_down"):
		facing = "front"

	if Input.is_key_pressed(KEY_1):
		pose = "normal"
	elif Input.is_key_pressed(KEY_2):
		pose = "taiiku_suwari"
	elif Input.is_key_pressed(KEY_3):
		pose = "chair_sit"
	elif Input.is_key_pressed(KEY_4):
		pose = "sleep"

func _setup_sensors() -> void:
	var look_ahead_px: float = 40.0 * CM_TO_PX
	var heights_cm = [
		m["landmarks"]["top"],
		m["landmarks"]["eye"],
		m["landmarks"]["shoulder"],
		m["height"] * 0.75
	]

	for h_cm in heights_cm:
		var ray = RayCast2D.new()
		ray.position = Vector2(0, -h_cm * CM_TO_PX)
		ray.target_position = Vector2(look_ahead_px, 0)
		ray.collision_mask = 1 | 2 | 4
		ray.hit_from_inside = true
		add_child(ray)
		sensors.append(ray)

	var ceil_ray = RayCast2D.new()
	ceil_ray.position = Vector2(0, -m["height"] * 0.5 * CM_TO_PX)
	ceil_ray.target_position = Vector2(0, -m["height"] * 0.7 * CM_TO_PX)
	ceil_ray.collision_mask = 1 | 2 | 4
	ceil_ray.hit_from_inside = true
	add_child(ceil_ray)
	sensors.append(ceil_ray)

func _handle_auto_crouch() -> void:
	if not auto_crouch:
		return
	if pose != "normal":
		return

	var look_px = 40.0 * CM_TO_PX * dir
	for i in range(4):
		sensors[i].target_position.x = look_px
		sensors[i].force_raycast_update()

	var should_crouch = false
	var min_obs_h_cm = INF

	for i in range(4):
		var ray: RayCast2D = sensors[i]
		if ray.is_colliding():
			var hit_point = ray.get_collision_point()
			var collider = ray.get_collider()
			var obs_cm = 0.0

			if collider and collider.has_meta("obs_height_cm"):
				obs_cm = float(collider.get_meta("obs_height_cm"))
			else:
				var obj_y = global_position.y - hit_point.y
				obs_cm = obj_y / CM_TO_PX

			should_crouch = true
			if obs_cm < min_obs_h_cm:
				min_obs_h_cm = obs_cm

	_update_ceiling_sensor_cache()
	if _ceiling_sensor_colliding:
		if _ceiling_sensor_height_cm <= m["landmarks"]["top"] + 2.0:
			should_crouch = true
			if _ceiling_sensor_height_cm < min_obs_h_cm:
				min_obs_h_cm = _ceiling_sensor_height_cm

	if should_crouch:
		target_crouch_cm = min_obs_h_cm - 8.0
	else:
		target_crouch_cm = -1.0


func _is_ceiling_blocked() -> bool:
	_update_ceiling_sensor_cache()
	return _ceiling_sensor_colliding

func _update_smooth_pose(delta: float, crouch_analysis: Dictionary = {}) -> void:
	if m == null or m.is_empty():
		return
	var target_d = CharacterPoseCalculator.calculate_pose_data(self, m, CM_TO_PX, crouch_analysis)
	if smooth_d.is_empty():
		smooth_d = target_d.duplicate()
		return
	var pose_t = clamp(POSE_LERP_SPEED * delta, 0.0, 1.0)
	# 腰の目標姿勢に追いついたら、歩行の脚振りは遅延させない。
	var current_waist: float = float(smooth_d.get("waist_angle", target_d.get("waist_angle", 0.0)))
	var target_waist: float = float(target_d.get("waist_angle", current_waist))
	var current_crotch: float = float(smooth_d.get("y_crotch", target_d.get("y_crotch", 0.0)))
	var target_crotch: float = float(target_d.get("y_crotch", current_crotch))
	var walk_pose_settled: bool = abs(current_waist - target_waist) < 0.05 and abs(current_crotch - target_crotch) < 4.0
	for key in target_d:
		var val = target_d[key]
		if not (val is float or val is int):
			continue
		var t: float = 1.0 if (walk_pose_settled and key in REDRAW_POSE_KEYS) else pose_t
		smooth_d[key] = lerp(float(smooth_d.get(key, val)), float(val), t)

func set_pose_immediately(new_pose: String) -> void:
	pose = new_pose
	_refresh_pose_visual_immediately()

func _refresh_pose_visual_immediately() -> void:
	if m == null or m.is_empty():
		return
	visual_height_cm = _get_target_visual_height_cm()
	_update_collision()
	smooth_d = CharacterPoseCalculator.calculate_pose_data(self, m, CM_TO_PX)
	if character_drawer:
		_queue_redraw_if_needed(REDRAW_MIN_INTERVAL_SEC, true)

func _get_target_visual_height_cm() -> float:
	var target_h_cm = m["height"]

	if pose == "taiiku_suwari":
		target_h_cm = m["height"] * 0.5
	elif pose == "chair_sit":
		target_h_cm = m["height"] * 0.55  # 椅子の高さ分（腰から上）
	elif pose == "sleep":
		target_h_cm = m["height"] * 0.35
	elif pose == "normal":
		if target_crouch_cm > 0:
			target_h_cm = target_crouch_cm
		elif Input.is_key_pressed(KEY_S):
			target_h_cm *= 0.8

	_update_ceiling_sensor_cache()
	if _ceiling_sensor_colliding:
		if target_h_cm > _ceiling_sensor_height_cm - 8.0:
			target_h_cm = _ceiling_sensor_height_cm - 8.0

	return target_h_cm

func _update_visual_height(delta: float) -> void:
	var target_h_cm = _get_target_visual_height_cm()
	visual_height_cm = lerp(visual_height_cm, target_h_cm, 15.0 * delta)

func _update_collision() -> void:
	var h_px = visual_height_cm * CM_TO_PX
	var shape = collision_shape.shape as CapsuleShape2D
	if shape:
		shape.height = max(40.0, h_px)
		collision_shape.position.y = -h_px / 2.0

func get_head_screen_y_offset() -> float:
	if not smooth_d.is_empty():
		var head_center_key: String = "front_hy" if facing == "front" else "hy"
		var fallback_head_h: float = float(m.get("head", 0.0)) * CM_TO_PX if m and not m.is_empty() else visual_height_cm * CM_TO_PX * 0.13
		var head_center_y: float = float(smooth_d.get(head_center_key, -fallback_head_h * 0.5))
		var head_h: float = float(smooth_d.get("head_h", fallback_head_h))
		return head_center_y - head_h * 0.5
	return -visual_height_cm * CM_TO_PX

func _process_head_bump(delta: float) -> void:
	_head_bump_cooldown_left = max(0.0, _head_bump_cooldown_left - delta)
	_head_bump_shake_left = max(0.0, _head_bump_shake_left - delta)

	if _head_bump_cooldown_left > 0.0:
		return

	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		if collision == null:
			continue

		var collider = collision.get_collider()
		if collider == null:
			continue
		if not collider.has_meta("obs_type"):
			continue
		if String(collider.get_meta("obs_type")) != "overhead":
			continue

		var normal := collision.get_normal()
		if normal.y < 0.55:
			continue

		var hit_point: Vector2 = collision.get_position()
		var head_y := global_position.y - visual_height_cm * CM_TO_PX
		if hit_point.y > head_y + 16.0:
			continue

		_trigger_head_bump(
			String(collider.get_meta("obs_id")),
			float(collider.get_meta("obs_height_cm"))
		)
		break

func _trigger_head_bump(obs_id: String, obs_height_cm: float) -> void:
	_head_bump_cooldown_left = HEAD_BUMP_COOLDOWN
	_head_bump_shake_left = HEAD_BUMP_SHAKE_TIME
	velocity.y = max(velocity.y, 90.0)
	emit_signal("head_bump", obs_id, obs_height_cm)

func _update_camera_shake() -> void:
	var cam := get_node_or_null("Camera2D") as Camera2D
	if cam == null:
		return

	if _head_bump_shake_left <= 0.0:
		if _camera_shake_active:
			cam.offset = _camera_base_offset
			_camera_shake_active = false
		else:
			_camera_base_offset = cam.offset
		return

	if not _camera_shake_active:
		_camera_base_offset = cam.offset
		_camera_shake_active = true

	var strength := HEAD_BUMP_SHAKE_STRENGTH * (_head_bump_shake_left / HEAD_BUMP_SHAKE_TIME)
	cam.offset = _camera_base_offset + Vector2(
		randf_range(-strength, strength),
		randf_range(-strength * 0.6, strength * 0.6)
	)

func _reset_redraw_tracking() -> void:
	_redraw_elapsed_sec = REDRAW_MIN_INTERVAL_SEC
	_last_draw_dir = dir
	_last_draw_facing = ""
	_last_draw_pose = ""
	_last_draw_is_walking = false
	_last_draw_walk_phase = walk_phase
	_last_draw_visual_height_cm = visual_height_cm
	_last_draw_look_head_angle = look_head_angle
	_last_draw_look_pitch = look_pitch
	_last_draw_pose_values.clear()

func _queue_redraw_if_needed(delta: float, force: bool = false) -> void:
	if character_drawer == null:
		return
	_redraw_elapsed_sec += maxf(delta, 0.0)

	if force:
		_commit_redraw_state()
		character_drawer.queue_redraw()
		_redraw_elapsed_sec = 0.0
		return

	var should_redraw: bool = _has_significant_redraw_change()
	if should_redraw:
		if _redraw_elapsed_sec < REDRAW_MIN_INTERVAL_SEC:
			return
	else:
		if _redraw_elapsed_sec < IDLE_REDRAW_INTERVAL_SEC:
			return

	_commit_redraw_state()
	character_drawer.queue_redraw()
	_redraw_elapsed_sec = 0.0

func _has_significant_redraw_change() -> bool:
	if _last_draw_pose == "":
		return true
	if _last_draw_pose != pose or _last_draw_facing != facing or _last_draw_dir != dir:
		return true
	if _last_draw_is_walking != is_walking:
		return true
	if abs(_last_draw_visual_height_cm - visual_height_cm) > REDRAW_STATE_HEIGHT_EPS_CM:
		return true
	if abs(_last_draw_look_head_angle - look_head_angle) > REDRAW_STATE_ANGLE_EPS:
		return true
	if abs(_last_draw_look_pitch - look_pitch) > REDRAW_STATE_PITCH_EPS:
		return true
	if is_walking and abs(_last_draw_walk_phase - walk_phase) > REDRAW_STATE_ANGLE_EPS:
		return true

	for key in REDRAW_POSE_EPS.keys():
		var current_val: float = float(smooth_d.get(key, 0.0))
		var previous_val: float = float(_last_draw_pose_values.get(key, current_val))
		if abs(current_val - previous_val) > float(REDRAW_POSE_EPS[key]):
			return true

	return false

func _commit_redraw_state() -> void:
	_last_draw_dir = dir
	_last_draw_facing = facing
	_last_draw_pose = pose
	_last_draw_is_walking = is_walking
	_last_draw_walk_phase = walk_phase
	_last_draw_visual_height_cm = visual_height_cm
	_last_draw_look_head_angle = look_head_angle
	_last_draw_look_pitch = look_pitch
	_last_draw_pose_values.clear()
	for key in REDRAW_POSE_EPS.keys():
		_last_draw_pose_values[key] = float(smooth_d.get(key, 0.0))

func _invalidate_ceiling_sensor_cache() -> void:
	_ceiling_sensor_cached_frame = -1
	_ceiling_sensor_colliding = false
	_ceiling_sensor_height_cm = INF

func _update_ceiling_sensor_cache() -> void:
	if sensors.size() <= 4 or not is_instance_valid(sensors[4]):
		_ceiling_sensor_colliding = false
		_ceiling_sensor_height_cm = INF
		_ceiling_sensor_cached_frame = Engine.get_physics_frames()
		return

	var current_frame: int = Engine.get_physics_frames()
	if _ceiling_sensor_cached_frame == current_frame:
		return

	var ceil_ray: RayCast2D = sensors[4]
	ceil_ray.force_raycast_update()
	_ceiling_sensor_colliding = ceil_ray.is_colliding()
	if _ceiling_sensor_colliding:
		var hit_point: Vector2 = ceil_ray.get_collision_point()
		var ceil_y_px = global_position.y - hit_point.y
		_ceiling_sensor_height_cm = ceil_y_px / CM_TO_PX
	else:
		_ceiling_sensor_height_cm = INF
	_ceiling_sensor_cached_frame = current_frame

func _mock_measurements() -> Dictionary:
	var h = 180.0
	var ht = h / 7.5
	var n = ht * 0.22
	var leg = h * 0.48
	var arm = h - leg - ht - 2 * n
	return {
		"height": h,
		"head": ht,
		"headWidth": ht * 0.702,
		"neck": n,
		"shoulder": ht * 1.872,
		"arm": arm,
		"armLength": arm,
		"leg": leg,
		"landmarks": {
			"top": h,
			"eye": h - ht * 0.5,
			"shoulder": h - ht - 2 * n
		}
	}
