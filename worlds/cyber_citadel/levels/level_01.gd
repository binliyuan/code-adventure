extends LevelBase

func _on_level_ready() -> void:
	level_index = 0
	level_title = "关卡 1: 你好世界"
	initial_code = "# 使用 print() 输出 \"你好世界\"\n\n"
	objectives = [
		{"text": "使用 print() 函数", "done": false},
		{"text": "输出 \"你好世界\"", "done": false},
	]
	_code_edit.text = initial_code
	_level_title_label.text = level_title
	_render_objectives()
	_setup_game_scene()

func _setup_game_scene() -> void:
	_game_scene.add_child(CyberBackground.new())
	var console_prop := ConsoleProp.new()
	console_prop.position = Vector2(300, 200)
	_game_scene.add_child(console_prop)
	var hero := HeroBot.new()
	hero.position = Vector2(150, 200)
	_game_scene.add_child(hero)

func _check_objectives() -> void:
	var output := _interpreter.get_output()
	var used_print := output.size() > 0
	var has_hello := false
	for line: String in output:
		if "你好世界" in line:
			has_hello = true
			break
	objectives[0]["done"] = used_print
	objectives[1]["done"] = has_hello
	_render_objectives()

	if has_hello and _game_scene.get_child_count() > 1:
		var console_node := _game_scene.get_child(1)
		if console_node.has_method("show_text"):
			console_node.show_text("你好世界")
		var hero_node := _game_scene.get_child(2)
		if hero_node:
			var tween := create_tween()
			tween.tween_property(hero_node, "scale", Vector2(1.2, 1.2), 0.15)
			tween.tween_property(hero_node, "scale", Vector2(1.0, 1.0), 0.15)

func _on_hint_pressed() -> void:
	_console.push_color(Color("58a6ff"))
	_console.append_text("提示: 试试输入 print(\"你好世界\")\n")
	_console.pop()


class CyberBackground extends Node2D:
	func _draw() -> void:
		draw_rect(Rect2(0, 0, 800, 500), Color("fff5ea"))
		var grid_color := Color("f2dfce")
		for x: int in range(0, 800, 40):
			draw_line(Vector2(x, 0), Vector2(x, 500), grid_color, 1.0)
		for y: int in range(0, 500, 40):
			draw_line(Vector2(0, y), Vector2(800, y), grid_color, 1.0)
		draw_string(ThemeDB.fallback_font, Vector2(20, 30), "WARM_CODE://LEVEL_01", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("b99d8b"))


class ConsoleProp extends Node2D:
	var _display_text := ""

	func _draw() -> void:
		draw_rect(Rect2(-60, -50, 120, 100), Color("e6cbb7"))
		draw_rect(Rect2(-55, -45, 110, 70), Color("fffdf9"))
		draw_rect(Rect2(-60, -50, 120, 100), Color("c99679"), false, 2.0)
		draw_rect(Rect2(-20, 52, 40, 8), Color("c99679"))
		draw_rect(Rect2(-30, 60, 60, 4), Color("c99679"))

		if _display_text.is_empty():
			draw_string(ThemeDB.fallback_font, Vector2(-40, -10), "> _", HORIZONTAL_ALIGNMENT_LEFT, 100, 14, Color("6e9d72"))
		else:
			draw_string(ThemeDB.fallback_font, Vector2(-45, -15), "> " + _display_text, HORIZONTAL_ALIGNMENT_LEFT, 100, 12, Color("6e9d72"))
			draw_string(ThemeDB.fallback_font, Vector2(-45, 5), "✓ 成功", HORIZONTAL_ALIGNMENT_LEFT, 100, 12, Color("d9795b"))

	func show_text(text: String) -> void:
		_display_text = text
		queue_redraw()


class HeroBot extends Node2D:
	func _draw() -> void:
		draw_rect(Rect2(-20, -40, 40, 50), Color("d9795b"))
		draw_rect(Rect2(-22, -42, 44, 54), Color("e6a384"), false, 2.0)
		draw_circle(Vector2(-8, -25), 4.0, Color("fff0b8"))
		draw_circle(Vector2(8, -25), 4.0, Color("fff0b8"))
		draw_rect(Rect2(-6, -15, 12, 3), Color("6e9d72"))
		draw_rect(Rect2(-15, 12, 12, 20), Color("d9795b"))
		draw_rect(Rect2(3, 12, 12, 20), Color("d9795b"))
		draw_rect(Rect2(-30, -20, 10, 30), Color("484f58"))
		draw_rect(Rect2(20, -20, 10, 30), Color("484f58"))
		draw_circle(Vector2(-25, 12), 4.0, Color("484f58"))
		draw_circle(Vector2(25, 12), 4.0, Color("484f58"))
		draw_rect(Rect2(-12, -50, 24, 8), Color("e6c27a"))
