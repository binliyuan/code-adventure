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
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_theme_constant_override("separation", 24)

	for item: Dictionary in NAV_ITEMS:
		var btn := Button.new()
		btn.text = "%s  %s" % [ICON_CHARS.get(item["icon"], "●"), item["label"]]
		btn.custom_minimum_size = Vector2(180, 56)
		btn.focus_mode = Control.FOCUS_NONE
		btn.pressed.connect(_on_nav_pressed.bind(item["id"]))

		var style := StyleBoxFlat.new()
		style.bg_color = Color("161b22")
		style.set_corner_radius_all(12)
		style.set_content_margin_all(8)
		style.border_color = Color("30363d")
		style.set_border_width_all(1)
		btn.add_theme_stylebox_override("normal", style)

		var hover_style: StyleBoxFlat = style.duplicate()
		hover_style.border_color = Color("58a6ff")
		btn.add_theme_stylebox_override("hover", hover_style)

		btn.add_theme_font_size_override("font_size", 15)
		btn.add_theme_color_override("font_color", Color("f0f6fc"))
		btn.add_theme_color_override("font_hover_color", Color("58a6ff"))
		add_child(btn)

func _on_nav_pressed(button_id: String) -> void:
	nav_button_pressed.emit(button_id)
