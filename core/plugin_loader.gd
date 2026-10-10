class_name PluginLoader
extends RefCounted

const WORLDS_PATH = "res://worlds/"

var worlds: Array[Dictionary] = []

func scan_worlds() -> void:
	worlds.clear()
	var dir = DirAccess.open(WORLDS_PATH)
	if not dir:
		push_warning("PluginLoader: cannot open %s" % WORLDS_PATH)
		return
	dir.list_dir_begin()
	var folder = dir.get_next()
	while folder != "":
		if dir.current_is_dir() and not folder.begins_with("."):
			var cfg_path = WORLDS_PATH.path_join(folder).path_join("world.cfg")
			var world_data = _parse_world_cfg(cfg_path, folder)
			if not world_data.is_empty():
				worlds.append(world_data)
		folder = dir.get_next()
	dir.list_dir_end()
	worlds.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("order", 999)) < int(b.get("order", 999))
	)

func _parse_world_cfg(path: String, folder: String) -> Dictionary:
	var config = ConfigFile.new()
	if config.load(path) != OK:
		push_warning("PluginLoader: failed to load %s" % path)
		return {}
	return {
		"id": config.get_value("world", "id", folder),
		"name": config.get_value("world", "name", folder),
		"tagline": config.get_value("world", "tagline", ""),
		"total_levels": config.get_value("world", "total_levels", 0),
		"unlock_condition": config.get_value("world", "unlock_condition", "none"),
		"thumbnail": config.get_value("world", "thumbnail", ""),
		"entry_scene": config.get_value("world", "entry_scene", ""),
		"order": config.get_value("world", "order", 999),
		"folder": folder,
	}

func get_world(world_id: String) -> Dictionary:
	for w: Dictionary in worlds:
		if w["id"] == world_id:
			return w
	return {}
