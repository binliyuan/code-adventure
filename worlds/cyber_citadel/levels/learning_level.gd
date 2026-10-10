extends LevelBase

@export var lesson_id: int = 1

var _lesson_data: Dictionary = {
	1: {"title": "第一关 · 抵达蓝月", "intro": "沿着星球航道前进两格，抵达蓝月空间站。", "code": "# 连续前进两格\ncoder.forward(1)\ncoder.forward(1)\n", "target": "抵达蓝月", "steps": 2, "uses_forward": true},
	2: {"title": "第二关 · 给坐标命名", "intro": "把目的地保存成一个变量。", "code": "# 创建变量 destination，再打印它\n\n", "target": "天琴座", "steps": 0, "uses_forward": false},
	3: {"title": "第三关 · 计算推进力", "intro": "计算能源晶体数量，让飞船加速。", "code": "# 计算 2 + 3，并打印结果\n\n", "target": "5", "steps": 0, "uses_forward": false},
	4: {"title": "第四关 · 拼接呼叫词", "intro": "把两段讯息拼成一条完整呼叫。", "code": "# 用 + 连接两段文字\n\n", "target": "星环舰队", "steps": 0, "uses_forward": false},
	5: {"title": "第五关 · 完成跃迁", "intro": "综合变量和字符串，发送欢迎讯息。", "code": "# 写出完整的欢迎讯息\n\n", "target": "跃迁准备完毕", "steps": 0, "uses_forward": false},
}

func _on_level_ready() -> void:
	lesson_id = clampi(lesson_id, 1, 5)
	level_index = lesson_id - 1
	var data: Dictionary = _lesson_data[lesson_id]
	level_title = data["title"]
	initial_code = data["code"]
	objectives = [
		{"text": "执行 coder.forward(1) × %d" % int(data["steps"]) if data["uses_forward"] else "使用 print() 输出讯息", "done": false},
		{"text": "完成目标：%s" % data["target"], "done": false},
	]
	_code_edit.text = initial_code
	_level_title_label.text = level_title
	_render_objectives()
	_setup_game_scene(data["intro"])

func _setup_game_scene(intro: String) -> void:
	for child in _game_scene.get_children():
		child.queue_free()
	var stage: SpaceStage = SpaceStage.new()
	stage.lesson = lesson_id
	stage.intro = intro
	_game_scene.add_child(stage)

func _check_objectives() -> void:
	var data: Dictionary = _lesson_data[lesson_id]
	var output: PackedStringArray = _interpreter.get_output()
	var commands: Array[String] = _interpreter.get_commands()
	var has_target: bool = false
	if data["uses_forward"]:
		has_target = commands.size() >= int(data["steps"])
	else:
		for line: String in output:
			if str(data["target"]) in line:
				has_target = true
				break
	objectives[0]["done"] = commands.size() >= int(data["steps"]) if data["uses_forward"] else output.size() > 0
	objectives[1]["done"] = has_target
	_render_objectives()
	if has_target and _game_scene.get_child_count() > 0:
		var stage: Node = _game_scene.get_child(0)
		if stage.has_method("celebrate"):
			stage.celebrate()
	if not commands.is_empty() and _game_scene.get_child_count() > 0:
		var motion_stage: Node = _game_scene.get_child(0)
		if motion_stage.has_method("play_forward"):
			motion_stage.play_forward(commands.size())

func _on_hint_pressed() -> void:
	var hints: Dictionary = {
		1: "提示：连续写两行 coder.forward(1)，角色会沿星球航道前进两格。",
		2: "提示：destination = \"天琴座\"，再写 print(destination)",
		3: "提示：energy = 2 + 3，然后 print(energy)",
		4: "提示：print(\"星环\" + \"舰队\")",
		5: "提示：message = \"跃迁准备完毕\"，再 print(message)",
	}
	_console.push_color(Color("70d6ff"))
	_console.append_text(str(hints[lesson_id]) + "\n")
	_console.pop()

class SpaceStage extends Node2D:
	var lesson: int = 1
	var intro: String = ""
	var _celebrating: bool = false
	var _planet_index: int = 0
	var _robot_position: Vector2 = Vector2(140, 420)
	var _route: Array[Vector2] = [Vector2(140, 420), Vector2(315, 420), Vector2(490, 315), Vector2(665, 210), Vector2(825, 115)]
	var _planet_names: Array[String] = ["星环站", "曙光星", "信标星", "蓝月", "终点站"]
	var _goal_index: int = 2

	func _ready() -> void:
		_goal_index = 2 if lesson == 1 else _route.size() - 1
		queue_redraw()

	func _process(_delta: float) -> void:
		queue_redraw()

	func celebrate() -> void:
		_celebrating = true
		queue_redraw()

	func play_forward(amount: int) -> void:
		var target_index: int = mini(_route.size() - 1, _planet_index + amount)
		if target_index <= _planet_index:
			return
		var target_position: Vector2 = _route[target_index]
		var start_position: Vector2 = _robot_position
		_planet_index = target_index
		_celebrating = target_index >= _goal_index
		var motion: Tween = create_tween()
		motion.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		motion.tween_method(_set_robot_position, start_position, target_position, 0.65)

	func _set_robot_position(value: Vector2) -> void:
		_robot_position = value
		queue_redraw()

	func reset_motion() -> void:
		_planet_index = 0
		_robot_position = _route[0]
		_celebrating = false
		queue_redraw()

	func _draw() -> void:
		draw_rect(Rect2(0, 0, 960, 540), Color("091a31"))
		draw_circle(Vector2(820, 70), 130, Color("102d50"))
		draw_circle(Vector2(820, 70), 90, Color("123e62"))
		for x: int in range(0, 960, 48):
			draw_line(Vector2(x, 105), Vector2(x, 540), Color("16385c"), 1.0)
		for y: int in range(105, 540, 48):
			draw_line(Vector2(0, y), Vector2(960, y), Color("16385c"), 1.0)
		var stars: Array[Vector2] = [Vector2(90, 150), Vector2(380, 135), Vector2(710, 95), Vector2(900, 185)]
		for star: Vector2 in stars:
			draw_circle(star, 2.5, Color("b9f0ff"))
		draw_string(ThemeDB.fallback_font, Vector2(32, 38), "STAR RING FORTRESS  //  PLANET ROUTE 01", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("70d6ff"))
		draw_string(ThemeDB.fallback_font, Vector2(32, 70), intro, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("9eb2cf"))
		for route_index: int in range(_route.size() - 1):
			var route_color: Color = Color("7ee787") if route_index < _planet_index else Color("315578")
			draw_line(_route[route_index], _route[route_index + 1], route_color, 7.0, true)
			draw_line(_route[route_index], _route[route_index + 1], Color("70d6ff", 0.28), 14.0, true)
		for planet_index: int in range(_route.size()):
			var planet_position: Vector2 = _route[planet_index]
			var reached: bool = planet_index <= _planet_index
			var planet_color: Color = Color("7ee787") if reached else Color("70d6ff")
			draw_circle(planet_position, 34.0, Color("071225"))
			draw_circle(planet_position, 27.0, planet_color)
			draw_circle(planet_position + Vector2(-8, -8), 8.0, Color("d8f6ff", 0.75))
			draw_arc(planet_position, 38.0, -0.4, 2.6, 32, Color("b9f0ff", 0.65), 3.0)
			draw_string(ThemeDB.fallback_font, planet_position + Vector2(-34, 58), _planet_names[planet_index], HORIZONTAL_ALIGNMENT_CENTER, 68, 14, Color("e8f1ff"))
		if _celebrating:
			draw_circle(_robot_position, 45.0, Color("70d6ff", 0.16))
		for trail_index: int in range(1, 4):
			draw_line(_robot_position + Vector2(-trail_index * 15, 10), _robot_position + Vector2(-trail_index * 15 - 12, 10), Color("70d6ff", 0.28), 5.0)
		draw_circle(_robot_position + Vector2(0, -24), 20.0, Color("e8f1ff"))
		draw_circle(_robot_position + Vector2(0, -24), 16.0, Color("123657"))
		draw_rect(Rect2(_robot_position + Vector2(-20, -2), Vector2(40, 38)), Color("e8f1ff"))
		draw_rect(Rect2(_robot_position + Vector2(-17, 0), Vector2(34, 31)), Color("1c4264"), false, 2.0)
		draw_circle(_robot_position + Vector2(-6, -24), 3.0, Color("70d6ff"))
		draw_circle(_robot_position + Vector2(6, -24), 3.0, Color("70d6ff"))
		draw_rect(Rect2(_robot_position + Vector2(-15, 34), Vector2(12, 18)), Color("70d6ff"))
		draw_rect(Rect2(_robot_position + Vector2(3, 34), Vector2(12, 18)), Color("70d6ff"))
		draw_string(ThemeDB.fallback_font, Vector2(32, 505), "航道进度  %d / %d" % [_planet_index, _goal_index], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("9eb2cf"))
		if _celebrating:
			draw_string(ThemeDB.fallback_font, Vector2(590, 505), "✓ 已抵达蓝月空间站", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("7ee787"))
