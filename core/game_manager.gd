extends Node

var save_data = SaveData.new()
var plugin_loader = PluginLoader.new()
var current_world_id = ""

func _ready() -> void:
	save_data.load_data()
	plugin_loader.scan_worlds()

func get_worlds() -> Array[Dictionary]:
	return plugin_loader.worlds

func is_world_unlocked(world_id: String) -> bool:
	var world = plugin_loader.get_world(world_id)
	if world.is_empty():
		return false
	return save_data.is_world_unlocked(world_id, world["unlock_condition"])

func get_world_progress(world_id: String) -> int:
	return save_data.get_world_completed(world_id)

func enter_world(world_id: String) -> void:
	var world = plugin_loader.get_world(world_id)
	if world.is_empty() or not is_world_unlocked(world_id):
		return
	current_world_id = world_id
	var entry: String = world.get("entry_scene", "")
	if entry.is_empty():
		entry = "res://worlds/%s/world_entry.tscn" % world["folder"]
	get_tree().change_scene_to_file(entry)

func return_to_menu() -> void:
	current_world_id = ""
	get_tree().change_scene_to_file("res://ui/main_menu/main_menu.tscn")

func complete_level(world_id: String, level_index: int) -> void:
	save_data.set_level_completed(world_id, level_index)
	save_data.save()
