extends LevelBase

@export var lesson_id: int = 1

var _lesson_data := {
	1: {"title": "第一课 · 和电脑打招呼", "intro": "让小机器人亮起第一盏灯。", "code": "# 用 print() 和机器人打招呼\n\n", "target": "你好世界"},
	2: {"title": "第二课 · 给信息取名字", "intro": "变量像贴在抽屉上的小标签。", "code": "# 创建一个变量，再把它打印出来\n\n", "target": "小米"},
	3: {"title": "第三课 · 让数字动起来", "intro": "用加法帮机器人数出宝石。", "code": "# 计算 2 + 3，并打印结果\n\n", "target": "5"},
	4: {"title": "第四课 · 拼出一句话", "intro": "把几段文字拼成一句温暖的欢迎词。", "code": "# 用 + 连接两段文字\n\n", "target": "小骑士"},
	5: {"title": "第五课 · 完成欢迎仪式", "intro": "综合使用变量和字符串，迎接新伙伴。", "code": "# 写出完整的欢迎词\n\n", "target": "欢迎，探险家"},
}

func _on_level_ready() -> void:
	lesson_id = clampi(lesson_id, 1, 5)
	level_index = lesson_id - 1
	var data: Dictionary = _lesson_data[lesson_id]
	level_title = data["title"]
	initial_code = data["code"]
	objectives = [
		{"text": "使用 print() 输出内容", "done": false},
		{"text": "输出：%s" % data["target"], "done": false},
	]
	_code_edit.text = initial_code
	_level_title_label.text = level_title
	_render_objectives()
	_setup_game_scene(data["intro"])

func _setup_game_scene(intro: String) -> void:
	for child in _game_scene.get_children(): child.queue_free()
	var stage := LearningStage.new()
	stage.lesson = lesson_id
	stage.intro = intro
	_game_scene.add_child(stage)

func _check_objectives() -> void:
	var data: Dictionary = _lesson_data[lesson_id]
	var source := _code_edit.text
	var output := _interpreter.get_output()
	var has_target := false
	for line: String in output:
		if data["target"] in line:
			has_target = true
			break
	objectives[0]["done"] = output.size() > 0 and "print" in source
	objectives[1]["done"] = has_target
	_render_objectives()
	if has_target and _game_scene.get_child_count() > 0:
		var stage := _game_scene.get_child(0)
		if stage.has_method("celebrate"): stage.celebrate()

func _on_hint_pressed() -> void:
	var hints := {
		1: "提示：print(\"你好世界\")",
		2: "提示：name = \"小米\"，再写 print(name)",
		3: "提示：先写 apples = 2 + 3，再 print(apples)",
		4: "提示：print(\"小\" + \"骑士\")",
		5: "提示：welcome = \"欢迎\"，name = \"探险家\"，再把它们连接起来",
	}
	_console.push_color(Color("b95f48"))
	_console.append_text(str(hints[lesson_id]) + "\n")
	_console.pop()

class LearningStage extends Node2D:
	var lesson := 1
	var intro := ""
	var _celebrating := false

	func _ready() -> void:
		queue_redraw()

	func celebrate() -> void:
		_celebrating = true
		queue_redraw()

	func _draw() -> void:
		draw_rect(Rect2(0, 0, 960, 540), Color("fff5ea"))
		for x in range(0, 960, 48): draw_line(Vector2(x, 0), Vector2(x, 540), Color("f4e4d7"), 1.0)
		for y in range(0, 540, 48): draw_line(Vector2(0, y), Vector2(960, y), Color("f4e4d7"), 1.0)
		draw_circle(Vector2(760, 100), 56, Color("ffe9c9"))
		draw_circle(Vector2(760, 100), 40, Color("f8cf9e"))
		draw_string(ThemeDB.fallback_font, Vector2(36, 52), "暖光编程岛  ·  第 %d 课" % lesson, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("8b6758"))
		draw_string(ThemeDB.fallback_font, Vector2(36, 84), intro, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("a48778"))
		var body := Color("d9795b") if not _celebrating else Color("6e9d72")
		draw_circle(Vector2(250, 300), 74, Color("f4d8c2"))
		draw_rect(Rect2(205, 250, 90, 100), body)
		draw_circle(Vector2(228, 290), 9, Color("fff0b8"))
		draw_circle(Vector2(272, 290), 9, Color("fff0b8"))
		draw_line(Vector2(238, 320), Vector2(262, 320), Color("fff8f1"), 4)
		draw_rect(Rect2(220, 350, 24, 48), body)
		draw_rect(Rect2(256, 350, 24, 48), body)
		draw_circle(Vector2(245, 212), 10, Color("e6b86e"))
		draw_circle(Vector2(245, 212), 5, Color("fff8f1"))
		draw_string(ThemeDB.fallback_font, Vector2(430, 330), "准备好了吗？", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color("c07156"))
		if _celebrating: draw_string(ThemeDB.fallback_font, Vector2(430, 370), "✓ 机器人学会了新本领！", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("6e9d72"))
