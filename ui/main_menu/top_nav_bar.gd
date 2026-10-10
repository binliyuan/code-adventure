extends HBoxContainer

signal nav_button_pressed(button_id: String)

const NAV_ITEMS := [
	{"id": "premium", "label": "会员", "icon": "crown"},
	{"id": "heroes", "label": "英雄", "icon": "shield"},
	{"id": "objects", "label": "物品", "icon": "backpack"},
	{"id": "achievements", "label": "成就", "icon": "trophy"},
	{"id": "settings", "label": "设置", "icon": "gear"},
]

const ICON_CHARS := {
	"crown": "♛",
	"shield": "⛨",
	"backpack": "⬡",
	"trophy": "★",
	"gear": "⚙",
}

func _ready() -> void:
	alignment = BoxContainer.ALIGNMENT_BEGIN
	add_theme_constant_override("separation", 24)
	var brand := VBoxContainer.new()
	brand.custom_minimum_size = Vector2(300, 56)
	var title := Label.new()
	title.text = "暖光编程岛"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color("b95f48"))
	brand.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "把好奇心写成冒险"
	subtitle.add_theme_font_size_override("font_size", 13)
	subtitle.add_theme_color_override("font_color", Color("a99a91"))
	brand.add_child(subtitle)
	add_child(brand)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(spacer)

	for item: Dictionary in NAV_ITEMS:
		var btn := Button.new()
		btn.text = "%s  %s" % [ICON_CHARS.get(item["icon"], "●"), item["label"]]
		btn.custom_minimum_size = Vector2(180, 56)
		btn.focus_mode = Control.FOCUS_NONE
		btn.pressed.connect(_on_nav_pressed.bind(item["id"]))

		var style := StyleBoxFlat.new()
		style.bg_color = Color("fffdf9")
		style.set_corner_radius_all(12)
		style.set_content_margin_all(8)
		style.border_color = Color("ead8ca")
		style.set_border_width_all(1)
		btn.add_theme_stylebox_override("normal", style)

		var hover_style: StyleBoxFlat = style.duplicate()
		hover_style.border_color = Color("d9795b")
		btn.add_theme_stylebox_override("hover", hover_style)

		btn.add_theme_font_size_override("font_size", 15)
		btn.add_theme_color_override("font_color", Color("493a35"))
		btn.add_theme_color_override("font_hover_color", Color("b95f48"))
		add_child(btn)

func _on_nav_pressed(button_id: String) -> void:
	nav_button_pressed.emit(button_id)
