class_name SaveData
extends Resource

const SAVE_PATH := "user://save_data.cfg"

var world_progress: Dictionary = {}

func get_world_completed(world_id: String) -> int:
	if world_progress.has(world_id):
		var val: Variant = world_progress[world_id].get("completed", 0)
		return int(val)
	return 0

func set_level_completed(world_id: String, level_index: int) -> void:
	if not world_progress.has(world_id):
		world_progress[world_id] = {"completed": 0, "levels_done": ""}
	var current: int = int(world_progress[world_id].get("completed", 0))
	if level_index + 1 > current:
		world_progress[world_id]["completed"] = level_index + 1
	var done := _get_levels_done_set(world_id)
	done[level_index] = true
	world_progress[world_id]["levels_done"] = _encode_levels_done(done)

func is_level_completed(world_id: String, level_index: int) -> bool:
	var done := _get_levels_done_set(world_id)
	return done.has(level_index)

func get_completed_levels(world_id: String) -> Array[int]:
	var done := _get_levels_done_set(world_id)
	var result: Array[int] = []
	for k: int in done:
		result.append(k)
	result.sort()
	return result

func _get_levels_done_set(world_id: String) -> Dictionary:
	if not world_progress.has(world_id):
		return {}
	var raw: String = str(world_progress[world_id].get("levels_done", ""))
	if raw.is_empty():
		var hw: int = int(world_progress[world_id].get("completed", 0))
		var d: Dictionary = {}
		for i: int in range(hw):
			d[i] = true
		return d
	var d: Dictionary = {}
	for s: String in raw.split(",", false):
		d[s.to_int()] = true
	return d

func _encode_levels_done(done: Dictionary) -> String:
	var keys: Array[int] = []
	for k: int in done:
		keys.append(k)
	keys.sort()
	var parts: PackedStringArray = []
	for k: int in keys:
		parts.append(str(k))
	return ",".join(parts)

func is_world_unlocked(world_id: String, unlock_condition: String) -> bool:
	if unlock_condition == "none" or unlock_condition.is_empty():
		return true
	# Format: "complete:world_id:level_count"
	var parts := unlock_condition.split(":")
	if parts.size() == 3 and parts[0] == "complete":
		return get_world_completed(parts[1]) >= parts[2].to_int()
	return false

func save() -> void:
	var config := ConfigFile.new()
	for world_id: String in world_progress:
		for key: String in world_progress[world_id]:
			config.set_value(world_id, key, world_progress[world_id][key])
	config.save(SAVE_PATH)

func load_data() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	for section: String in config.get_sections():
		world_progress[section] = {}
		for key: String in config.get_section_keys(section):
			world_progress[section][key] = config.get_value(section, key)
