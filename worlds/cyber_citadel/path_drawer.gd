extends Control

func _draw() -> void:
	var entry := owner
	if not entry or not "_node_positions" in entry:
		return
	var positions: Array[Vector2] = entry._node_positions
	if positions.size() < 2:
		return
	var offset := Vector2(32, 32)
	for i: int in range(positions.size() - 1):
		var from := positions[i] + offset
		var to := positions[i + 1] + offset
		draw_line(from, to, Color("30363d"), 3.0, true)
