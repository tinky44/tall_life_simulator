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

var _background_fill: ColorRect
var _background_rect: TextureRect
var _button_box: VBoxContainer


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

	resized.connect(_update_layout)
	call_deferred("_update_layout")


func _update_layout() -> void:
	if _button_box == null:
		return

	var image_rect := _get_displayed_background_rect()
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
