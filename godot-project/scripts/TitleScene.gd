extends Control

const BACKGROUND_TEXTURE_PATH := "res://assets/thumbnail_TLS_original.png"
const BACKGROUND_FILL_COLOR := Color("#f4c0ca")
const BUTTON_AREA := Rect2(0.03, 0.52, 0.28, 0.35)
const BUTTON_GAP := 29.0
const BUTTON_BASE_COLOR := Color("#1b3f6b")
const BUTTON_HOVER_COLOR := Color("#29578f")
const BUTTON_PRESSED_COLOR := Color("#14304f")
const BUTTON_BORDER_COLOR := Color("#86a9d7")
const BUTTON_TEXT_COLOR := Color("#f3f7ff")
const BUTTON_MAX_WIDTH := 320.0
const BUTTON_MIN_HEIGHT := 68.0
const BUTTON_MIN_TOTAL_HEIGHT := 280.0

# 右下の Godot ロゴのクリック領域（画像比率）
const GODOT_LOGO_AREA := Rect2(0.88, 0.88, 0.12, 0.12)
const LICENCE_PATH := "res://godot_licence.txt"

var _background_fill: ColorRect
var _background_rect: TextureRect
var _button_box: VBoxContainer
var _godot_btn: Button
var _licence_overlay: Control


func _ready() -> void:
	if _maybe_start_codex_smoke():
		return

	_background_fill = ColorRect.new()
	_background_fill.set_anchors_preset(Control.PRESET_FULL_RECT)
	_background_fill.color = BACKGROUND_FILL_COLOR
	add_child(_background_fill)

	_background_rect = TextureRect.new()
	_background_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_background_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_background_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_background_rect.texture = load(BACKGROUND_TEXTURE_PATH)
	add_child(_background_rect)

	_button_box = VBoxContainer.new()
	_button_box.add_theme_constant_override("separation", int(BUTTON_GAP))
	add_child(_button_box)

	_add_button(_button_box, "\u306f\u3058\u3081\u304b\u3089", _on_start_pressed)
	_add_button(_button_box, "\u7d9a\u304d\u304b\u3089", _on_continue_pressed)
	_add_button(_button_box, "\u3084\u3081\u308b", _on_exit_pressed)

	# 右下 Godot ロゴ用の透明ボタン
	_godot_btn = Button.new()
	_godot_btn.flat = true
	_godot_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_godot_btn.focus_mode = Control.FOCUS_NONE
	_godot_btn.pressed.connect(_on_godot_btn_pressed)
	add_child(_godot_btn)

	resized.connect(_update_layout)
	call_deferred("_update_layout")


func _update_layout() -> void:
	if _button_box == null:
		return

	var image_rect := _get_displayed_background_rect()

	# メインボタン群
	var target_pos := image_rect.position + image_rect.size * BUTTON_AREA.position
	var target_size := image_rect.size * BUTTON_AREA.size
	var width := minf(target_size.x, BUTTON_MAX_WIDTH)
	var height := maxf(target_size.y, BUTTON_MIN_TOTAL_HEIGHT)
	_button_box.position = target_pos
	_button_box.size = Vector2(width, height)

	for child in _button_box.get_children():
		var button := child as Button
		if button == null:
			continue
		button.custom_minimum_size = Vector2(0.0, BUTTON_MIN_HEIGHT)

	# Godot ロゴボタン
	if _godot_btn != null:
		var logo_pos := image_rect.position + image_rect.size * GODOT_LOGO_AREA.position
		var logo_size := image_rect.size * GODOT_LOGO_AREA.size
		_godot_btn.position = logo_pos
		_godot_btn.size = logo_size


func _get_displayed_background_rect() -> Rect2:
	if _background_rect == null or _background_rect.texture == null:
		return Rect2(Vector2.ZERO, size)

	var texture_size := _background_rect.texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return Rect2(Vector2.ZERO, size)

	var viewport_size := size
	var scale := minf(viewport_size.x / texture_size.x, viewport_size.y / texture_size.y)
	var display_size := texture_size * scale
	var display_position := (viewport_size - display_size) * 0.5
	return Rect2(display_position, display_size)


func _add_button(parent: Control, label: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = label
	button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 26)
	button.add_theme_color_override("font_color", BUTTON_TEXT_COLOR)
	button.add_theme_color_override("font_hover_color", BUTTON_TEXT_COLOR)
	button.add_theme_color_override("font_pressed_color", BUTTON_TEXT_COLOR)
	button.add_theme_color_override("font_focus_color", BUTTON_TEXT_COLOR)
	button.add_theme_stylebox_override("normal", _make_button_style(BUTTON_BASE_COLOR))
	button.add_theme_stylebox_override("hover", _make_button_style(BUTTON_HOVER_COLOR))
	button.add_theme_stylebox_override("pressed", _make_button_style(BUTTON_PRESSED_COLOR))
	button.add_theme_stylebox_override("focus", _make_button_style(BUTTON_HOVER_COLOR))
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(callback)
	parent.add_child(button)


func _make_button_style(fill_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = BUTTON_BORDER_COLOR
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_right = 10
	style.corner_radius_bottom_left = 10
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style


func _on_godot_btn_pressed() -> void:
	if _licence_overlay != null:
		return

	var text := ""
	if FileAccess.file_exists(LICENCE_PATH):
		var f := FileAccess.open(LICENCE_PATH, FileAccess.READ)
		text = f.get_as_text()
		f.close()

	# 半透明オーバーレイ
	_licence_overlay = Control.new()
	_licence_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_licence_overlay)

	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0, 0, 0, 0.75)
	_licence_overlay.add_child(dim)

	# パネル（中央寄せ）
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(520, 400)
	panel.set_anchor(SIDE_LEFT, 0.5)
	panel.set_anchor(SIDE_RIGHT, 0.5)
	panel.set_anchor(SIDE_TOP, 0.5)
	panel.set_anchor(SIDE_BOTTOM, 0.5)
	panel.set_offset(SIDE_LEFT, -260)
	panel.set_offset(SIDE_RIGHT, 260)
	panel.set_offset(SIDE_TOP, -220)
	panel.set_offset(SIDE_BOTTOM, 220)
	_licence_overlay.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	panel.add_child(vbox)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0, 320)
	vbox.add_child(scroll)

	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 13)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(label)

	var close_btn := Button.new()
	close_btn.text = "閉じる"
	close_btn.add_theme_font_size_override("font_size", 20)
	close_btn.focus_mode = Control.FOCUS_NONE
	close_btn.pressed.connect(_close_licence_overlay)
	vbox.add_child(close_btn)


func _close_licence_overlay() -> void:
	if _licence_overlay != null:
		_licence_overlay.queue_free()
		_licence_overlay = null


func _on_start_pressed() -> void:
	var global = get_node_or_null("/root/Global")
	if global:
		global.slot_select_mode = "save"
	get_tree().change_scene_to_file("res://scenes/CharacterCreatorScene.tscn")


func _on_continue_pressed() -> void:
	var global = get_node_or_null("/root/Global")
	if global:
		global.slot_select_mode = "load"
	get_tree().change_scene_to_file("res://scenes/SaveSlotSelectScene.tscn")


func _on_exit_pressed() -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.location.replace(new URL('./', window.location.href).toString());")
	else:
		get_tree().quit()


func _maybe_start_codex_smoke() -> bool:
	for arg in OS.get_cmdline_user_args():
		if arg == "--codex-smoke":
			call_deferred("_start_codex_smoke")
			return true
	return false


func _start_codex_smoke() -> void:
	get_tree().change_scene_to_file("res://scenes/CodexSmokeRunner.tscn")
