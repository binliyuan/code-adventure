extends Control

const LevelNodeScene := preload("res://worlds/cyber_citadel/level_node.tscn")
const TOTAL_LEVELS := 5
const COLS := 5
const NODE_SPACING_X := 140.0
const NODE_SPACING_Y := 120.0
const MARGIN_LEFT := 200.0
const MARGIN_TOP := 40.0

@onready var _back_btn: Button = %BackButton
@onready var _title_label: Label = %TitleLabel
@onready var _progress_label: Label = %ProgressLabel
@onready var _scroll: ScrollContainer = %LevelScroll
@onready var _canvas: Control = %LevelCanvas
@onready var _path_drawer: Control = %PathDrawer

var _node_positions: Array[Vector2] = []

func _ready() -> void:
	theme = ThemeBuilder.build_dark_theme()
	_back_btn.pressed.connect(_on_back_pressed)
	_title_label.text = "暖光编程岛"
	_build_level_map()
	_update_progress()

func _build_level_map() -> void:
	for child in _canvas.get_children():
		if child != _path_drawer:
			child.queue_free()
	_node_positions.clear()

	var completed := GameManager.save_data.get_completed_levels("cyber_citadel")
	var highest := GameManager.get_world_progress("cyber_citadel")

	for i: int in range(TOTAL_LEVELS):
		var row := i / COLS
		var col := i % COLS
		if row % 2 == 1:
			col = COLS - 1 - col

		var pos := Vector2(
			MARGIN_LEFT + col * NODE_SPACING_X,
			MARGIN_TOP + row * NODE_SPACING_Y
		)
		_node_positions.append(pos)

		var node: Control = LevelNodeScene.instantiate()
		_canvas.add_child(node)
		node.position = pos

		var state: int
		if i in completed:
			state = node.State.COMPLETED
		elif i <= highest:
			state = node.State.CURRENT
		else:
			state = node.State.LOCKED

		node.setup(i, state)
		node.level_selected.connect(_on_level_selected)

	var total_rows := ceili(float(TOTAL_LEVELS) / COLS)
	_canvas.custom_minimum_size = Vector2(
		MARGIN_LEFT * 2 + (COLS - 1) * NODE_SPACING_X + 64,
		MARGIN_TOP * 2 + (total_rows - 1) * NODE_SPACING_Y + 64
	)

	_path_drawer.queue_redraw()

func _update_progress() -> void:
	var completed := GameManager.get_world_progress("cyber_citadel")
	_progress_label.text = "%d/%d 已完成" % [completed, TOTAL_LEVELS]

func _on_level_selected(index: int) -> void:
	var scene_path := "res://worlds/cyber_citadel/levels/level_%02d.tscn" % (index + 1)
	if ResourceLoader.exists(scene_path):
		get_tree().change_scene_to_file(scene_path)
	else:
		_show_coming_soon()

func _show_coming_soon() -> void:
	var toast := Label.new()
	toast.text = "该关卡正在开发中..."
	toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast.add_theme_font_size_override("font_size", 20)
	toast.add_theme_color_override("font_color", Color("493a35"))

	var bg := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color("fffdf9", 0.98)
	style.border_color = Color("ead8ca")
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(16)
	bg.add_theme_stylebox_override("panel", style)
	bg.add_child(toast)
	bg.anchor_left = 0.3
	bg.anchor_right = 0.7
	bg.anchor_top = 0.45
	bg.anchor_bottom = 0.55
	add_child(bg)

	var tween := create_tween()
	tween.tween_interval(1.5)
	tween.tween_property(bg, "modulate:a", 0.0, 0.5)
	tween.tween_callback(bg.queue_free)

func _on_back_pressed() -> void:
	GameManager.return_to_menu()
