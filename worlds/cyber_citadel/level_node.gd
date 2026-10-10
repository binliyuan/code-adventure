extends Control

signal level_selected(index: int)

enum State { COMPLETED, CURRENT, LOCKED }

const COLOR_COMPLETED = Color("7ee787")
const COLOR_CURRENT = Color("70d6ff")
const COLOR_LOCKED = Color("365372")
const COLOR_BG_COMPLETED = Color("163c35")
const COLOR_BG_CURRENT = Color("123657")
const COLOR_BG_LOCKED = Color("0e2039")

var level_index: int = 0
var state: State = State.LOCKED
var _hover = false

func setup(idx: int, s: State) -> void:
	level_index = idx
	state = s
	custom_minimum_size = Vector2(64, 64)
	size = Vector2(64, 64)
	if state != State.LOCKED:
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	queue_redraw()

func _draw() -> void:
	var center = size / 2.0
	var radius = 28.0

	var bg_color: Color
	var ring_color: Color
	match state:
		State.COMPLETED:
			bg_color = COLOR_BG_COMPLETED
			ring_color = COLOR_COMPLETED
		State.CURRENT:
			bg_color = COLOR_BG_CURRENT
			ring_color = COLOR_CURRENT
		State.LOCKED:
			bg_color = COLOR_BG_LOCKED
			ring_color = COLOR_LOCKED

	if _hover and state != State.LOCKED:
		ring_color = ring_color.lightened(0.2)

	draw_circle(center, radius + 3.0, ring_color)
	draw_circle(center, radius, bg_color)

	if state == State.CURRENT:
		var glow = ring_color
		glow.a = 0.3
		draw_circle(center, radius + 8.0, glow)

	var font = ThemeDB.fallback_font
	var font_size = 18
	if state == State.COMPLETED:
		var check = "✓"
		var ts = font.get_string_size(check, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
		draw_string(font, center - ts / 2.0 + Vector2(0, ts.y * 0.35), check, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, COLOR_COMPLETED)
	elif state == State.LOCKED:
		var lock = "·"
		var ts = font.get_string_size(lock, HORIZONTAL_ALIGNMENT_CENTER, -1, 14)
		draw_string(font, center - ts / 2.0 + Vector2(0, ts.y * 0.35), lock, HORIZONTAL_ALIGNMENT_CENTER, -1, 14, COLOR_LOCKED)

	var num = str(level_index + 1)
	var num_size = font.get_string_size(num, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	var text_color = Color("e8f1ff") if state != State.LOCKED else Color("7187a3")
	var y_offset = num_size.y * 0.35
	if state == State.COMPLETED:
		y_offset += 10.0
	elif state == State.LOCKED:
		y_offset -= 10.0
	draw_string(font, center - num_size / 2.0 + Vector2(0, y_offset), num, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, text_color)

func _gui_input(event: InputEvent) -> void:
	if state == State.LOCKED:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		level_selected.emit(level_index)

func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_ENTER:
		_hover = true
		queue_redraw()
	elif what == NOTIFICATION_MOUSE_EXIT:
		_hover = false
		queue_redraw()
