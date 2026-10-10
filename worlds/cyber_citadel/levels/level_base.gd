class_name LevelBase
extends Control

var world_id = "cyber_citadel"
var level_index = 0
var level_title = "关卡"
var objectives: Array[Dictionary] = []
var initial_code = "# 在这里写你的代码\n"
var _interpreter: CodeInterpreter
var _completed = false

@onready var _back_btn: Button = %BackButton
@onready var _level_title_label: Label = %LevelTitleLabel
@onready var _objective_list: VBoxContainer = %ObjectiveList
@onready var _code_edit: CodeEdit = %CodeEdit
@onready var _run_btn: Button = %RunButton
@onready var _reset_btn: Button = %ResetButton
@onready var _hint_btn: Button = %HintButton
@onready var _console: RichTextLabel = %Console
@onready var _game_scene: Node2D = %GameScene

func _ready() -> void:
	theme = ThemeBuilder.build_dark_theme()
	_interpreter = CodeInterpreter.new()
	_interpreter.output_line.connect(_on_output_line)
	_interpreter.execution_finished.connect(_on_execution_finished)
	_interpreter.execution_error.connect(_on_execution_error)
	_interpreter.command_executed.connect(_on_command_executed)

	_back_btn.pressed.connect(_on_back_pressed)
	_run_btn.pressed.connect(_on_run_pressed)
	_reset_btn.pressed.connect(_on_reset_pressed)
	_hint_btn.pressed.connect(_on_hint_pressed)

	_setup_code_edit()
	_code_edit.text = initial_code
	_render_objectives()
	_level_title_label.text = level_title
	_on_level_ready()

func _setup_code_edit() -> void:
	_code_edit.gutters_draw_line_numbers = true
	_code_edit.indent_size = 4
	_code_edit.indent_automatic = true
	_code_edit.scroll_smooth = true
	_code_edit.minimap_draw = false
	_code_edit.caret_blink = true

	var highlighter = CodeHighlighter.new()
	highlighter.number_color = Color("d2a8ff")
	highlighter.symbol_color = Color("e8f1ff")
	highlighter.function_color = Color("70d6ff")
	highlighter.member_variable_color = Color("8be9fd")

	var keywords = ["if", "else", "elif", "for", "while", "def", "return",
		"and", "or", "not", "True", "False", "None", "in", "break", "continue", "pass"]
	for kw: String in keywords:
		highlighter.add_keyword_color(kw, Color("ff7b9f"))

	var builtins = ["print", "len", "range", "input", "str", "int", "float", "type"]
	for fn: String in builtins:
		highlighter.add_keyword_color(fn, Color("8be9fd"))

	highlighter.add_color_region("\"", "\"", Color("ffe29a"))
	highlighter.add_color_region("'", "'", Color("ffe29a"))
	highlighter.add_color_region("#", "", Color("7187a3"), true)

	_code_edit.syntax_highlighter = highlighter

	var edit_bg = StyleBoxFlat.new()
	edit_bg.bg_color = Color("091a31")
	edit_bg.set_content_margin_all(12)
	_code_edit.add_theme_stylebox_override("normal", edit_bg)
	_code_edit.add_theme_color_override("font_color", Color("e8f1ff"))
	_code_edit.add_theme_color_override("background_color", Color("091a31"))
	_code_edit.add_theme_color_override("line_number_color", Color("365372"))
	_code_edit.add_theme_color_override("caret_color", Color("70d6ff"))
	_code_edit.add_theme_color_override("current_line_color", Color("102a49"))
	_code_edit.add_theme_font_size_override("font_size", 16)

func _render_objectives() -> void:
	for child in _objective_list.get_children():
		child.queue_free()
	for obj: Dictionary in objectives:
		var label = Label.new()
		var done: bool = obj.get("done", false)
		var prefix = "✓ " if done else "☐ "
		label.text = prefix + obj["text"]
		label.add_theme_font_size_override("font_size", 14)
		label.add_theme_color_override("font_color", Color("3fb950") if done else Color("8b949e"))
		_objective_list.add_child(label)

func _on_run_pressed() -> void:
	_console.clear()
	_console.push_color(Color("9eb2cf"))
	_console.append_text("正在执行...\n")
	_console.pop()
	_interpreter.execute(_code_edit.text, _build_context())

func _on_reset_pressed() -> void:
	_code_edit.text = initial_code
	_console.clear()
	for obj: Dictionary in objectives:
		obj["done"] = false
	_render_objectives()
	_completed = false
	if _game_scene.get_child_count() > 0:
		var stage: Node = _game_scene.get_child(0)
		if stage.has_method("reset_motion"):
			stage.reset_motion()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://worlds/cyber_citadel/world_entry.tscn")

func _on_hint_pressed() -> void:
	_console.push_color(Color("b95f48"))
	_console.append_text("提示：先完成目标列表中的第一项，再运行代码。\n")
	_console.pop()

func _on_output_line(text: String) -> void:
	_console.push_color(Color("e8f1ff"))
	_console.append_text("> " + text + "\n")
	_console.pop()

func _on_execution_finished(success: bool) -> void:
	if not success:
		return
	_check_objectives()
	if _all_objectives_done() and not _completed:
		_completed = true
		_on_level_complete()

func _on_execution_error(line_num: int, message: String) -> void:
	_console.push_color(Color("ff7b9f"))
	_console.append_text("错误 (第 %d 行): %s\n" % [line_num, message])
	_console.pop()

func _on_command_executed(_command: String, _amount: int) -> void:
	pass

func _check_objectives() -> void:
	pass

func _all_objectives_done() -> bool:
	for obj: Dictionary in objectives:
		if not obj.get("done", false):
			return false
	return true

func _on_level_complete() -> void:
	GameManager.complete_level(world_id, level_index)
	_render_objectives()
	_console.push_color(Color("3fb950"))
	_console.append_text("\n✓ 关卡完成！\n")
	_console.pop()
	_show_victory_panel()

func _show_victory_panel() -> void:
	var panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color("0e2039", 0.98)
	style.set_corner_radius_all(16)
	style.set_content_margin_all(32)
	style.border_color = Color("7ee787")
	style.set_border_width_all(2)
	panel.add_theme_stylebox_override("panel", style)

	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 16)

	var title = Label.new()
	title.text = "关卡完成！"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color("7ee787"))
	vbox.add_child(title)

	var next_btn = Button.new()
	next_btn.text = "下一关"
	next_btn.custom_minimum_size = Vector2(160, 48)
	next_btn.pressed.connect(func() -> void:
		panel.queue_free()
		_go_next_level()
	)
	vbox.add_child(next_btn)

	var back_btn = Button.new()
	back_btn.text = "返回关卡选择"
	back_btn.custom_minimum_size = Vector2(160, 48)
	back_btn.pressed.connect(func() -> void:
		_on_back_pressed()
	)
	vbox.add_child(back_btn)

	panel.add_child(vbox)
	panel.anchor_left = 0.3
	panel.anchor_right = 0.7
	panel.anchor_top = 0.25
	panel.anchor_bottom = 0.75
	add_child(panel)

func _go_next_level() -> void:
	var next_index = level_index + 2
	var next_scene = "res://worlds/cyber_citadel/levels/level_%02d.tscn" % next_index
	if ResourceLoader.exists(next_scene):
		get_tree().change_scene_to_file(next_scene)
	else:
		_on_back_pressed()

func _build_context() -> Dictionary:
	return {}

func _on_level_ready() -> void:
	pass
