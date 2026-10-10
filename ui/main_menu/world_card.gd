extends PanelContainer

signal card_pressed(world_id: String)

var world_data: Dictionary = {}
var _is_unlocked := false

@onready var _thumbnail: TextureRect = %Thumbnail
@onready var _title_label: Label = %TitleLabel
@onready var _tagline_label: Label = %TaglineLabel
@onready var _status_label: Label = %StatusLabel
@onready var _progress_label: Label = %ProgressLabel
@onready var _progress_bar: ProgressBar = %ProgressBar
@onready var _lock_overlay: ColorRect = %LockOverlay

func setup(data: Dictionary, unlocked: bool, completed: int) -> void:
	world_data = data
	_is_unlocked = unlocked

	if not is_node_ready():
		await ready

	_title_label.text = data.get("name", "Unknown").to_upper()
	_tagline_label.text = data.get("tagline", "")

	var total: int = data.get("total_levels", 0)
	_progress_bar.max_value = total
	_progress_bar.value = completed
	_progress_label.text = "%d / %d" % [completed, total]

	if unlocked:
		_status_label.text = "开始"
		_status_label.add_theme_color_override("font_color", Color("6e9d72"))
		_lock_overlay.visible = false
	else:
		_status_label.text = "未解锁"
		_status_label.add_theme_color_override("font_color", Color("a99a91"))
		_lock_overlay.visible = true

	var thumb_path: String = data.get("thumbnail", "")
	if thumb_path and ResourceLoader.exists(thumb_path):
		_thumbnail.texture = load(thumb_path)
	else:
		_thumbnail.texture = _make_thumbnail(str(data.get("id", "")))

func _make_thumbnail(world_id: String) -> Texture2D:
	var gradient := Gradient.new()
	var palette: Array = {
		"cyber_citadel": [Color("f4c9a8"), Color("d9795b")],
		"neon_desert": [Color("f7dfb0"), Color("e7a66e")],
		"stellar_forge": [Color("d8d1eb"), Color("9b86c4")],
		"stellar_nexus": [Color("d5e4e8"), Color("7eabb3")],
		"underwater_metro": [Color("cde8e0"), Color("6aa69a")],
		"neo_memphis": [Color("f2d4dc"), Color("d68ba0")],
	}.get(world_id, [Color("f1e0d6"), Color("c99679")])
	gradient.colors = PackedColorArray(palette)
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 960
	texture.height = 240
	texture.fill_from = Vector2(0, 0)
	texture.fill_to = Vector2(1, 1)
	return texture

func _ready() -> void:
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		card_pressed.emit(world_data.get("id", ""))

func _on_mouse_entered() -> void:
	var style := get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	if style:
		style.border_color = Color("d9795b") if _is_unlocked else Color("c8b8ae")
		style.set_border_width_all(2)
		add_theme_stylebox_override("panel", style)

func _on_mouse_exited() -> void:
	remove_theme_stylebox_override("panel")
