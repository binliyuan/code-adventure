extends Control

const WorldCardScene := preload("res://ui/main_menu/world_card.tscn")

@onready var _top_nav: HBoxContainer = %TopNavBar
@onready var _grid: GridContainer = %WorldGrid
@onready var _bottom_bar: HBoxContainer = %BottomBar

func _ready() -> void:
	theme = ThemeBuilder.build_dark_theme()
	_setup_background()
	_populate_worlds()
	_setup_bottom_bar()
	_top_nav.nav_button_pressed.connect(_on_nav_pressed)

func _setup_background() -> void:
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color("fff8f1")
	add_theme_stylebox_override("panel", bg)

func _populate_worlds() -> void:
	for child in _grid.get_children():
		child.queue_free()

	var worlds := GameManager.get_worlds()
	for world: Dictionary in worlds:
		var card: PanelContainer = WorldCardScene.instantiate()
		_grid.add_child(card)
		var unlocked := GameManager.is_world_unlocked(world["id"])
		var completed := GameManager.get_world_progress(world["id"])
		card.setup(world, unlocked, completed)
		card.card_pressed.connect(_on_card_pressed)

func _setup_bottom_bar() -> void:
	var items := [
		{"id": "junior", "label": "少儿编程"},
		{"id": "worlds", "label": "世界"},
		{"id": "ai_league", "label": "AI 联赛"},
	]
	for item: Dictionary in items:
		var btn := Button.new()
		btn.text = item["label"]
		btn.custom_minimum_size = Vector2(200, 48)
		btn.focus_mode = Control.FOCUS_NONE
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var style := StyleBoxFlat.new()
		style.bg_color = Color("fffdf9")
		style.set_corner_radius_all(10)
		style.set_content_margin_all(8)
		style.border_color = Color("ead8ca")
		style.set_border_width_all(1)
		btn.add_theme_stylebox_override("normal", style)

		var hover: StyleBoxFlat = style.duplicate()
		hover.border_color = Color("d9795b")
		btn.add_theme_stylebox_override("hover", hover)

		btn.add_theme_font_size_override("font_size", 16)
		btn.add_theme_color_override("font_color", Color("89776d"))
		btn.add_theme_color_override("font_hover_color", Color("b95f48"))
		_bottom_bar.add_child(btn)

func _on_card_pressed(world_id: String) -> void:
	if GameManager.is_world_unlocked(world_id):
		GameManager.enter_world(world_id)
	else:
		_show_locked_toast(world_id)

func _show_locked_toast(world_id: String) -> void:
	var world := GameManager.plugin_loader.get_world(world_id)
	var condition: String = world.get("unlock_condition", "")
	var msg := "该世界尚未解锁。"
	if condition.begins_with("complete:"):
		var parts := condition.split(":")
		if parts.size() == 3:
			var req_world := GameManager.plugin_loader.get_world(parts[1])
			var req_name: String = req_world.get("name", parts[1]) if not req_world.is_empty() else parts[1]
			msg = "需完成「%s」的 %s 个关卡才能解锁。" % [req_name, parts[2]]

	var toast := Label.new()
	toast.text = msg
	toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast.add_theme_font_size_override("font_size", 20)
	toast.add_theme_color_override("font_color", Color("493a35"))
	toast.anchor_left = 0.0
	toast.anchor_right = 1.0
	toast.anchor_bottom = 1.0
	toast.anchor_top = 1.0
	toast.offset_top = -80
	toast.offset_bottom = -40

	var bg := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color("fffdf9", 0.98)
	style.border_color = Color("ead8ca")
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(12)
	bg.add_theme_stylebox_override("panel", style)
	bg.add_child(toast)
	bg.anchor_left = 0.25
	bg.anchor_right = 0.75
	bg.anchor_bottom = 1.0
	bg.anchor_top = 1.0
	bg.offset_top = -90
	bg.offset_bottom = -30
	add_child(bg)

	var tween := create_tween()
	tween.tween_interval(2.0)
	tween.tween_property(bg, "modulate:a", 0.0, 0.5)
	tween.tween_callback(bg.queue_free)

func _on_nav_pressed(button_id: String) -> void:
	print("Nav pressed: ", button_id)
