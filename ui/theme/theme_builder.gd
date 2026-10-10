class_name ThemeBuilder
extends RefCounted

static func build_dark_theme() -> Theme:
	return build_warm_theme()

static func build_warm_theme() -> Theme:
	var theme := Theme.new()

	var bg_color := Color("fff8f1")
	var card_color := Color("fffdf9")
	var card_hover := Color("fff0e2")
	var accent_color := Color("d9795b")
	var success_color := Color("6e9d72")
	var locked_color := Color("a99a91")
	var text_primary := Color("493a35")
	var text_secondary := Color("89776d")
	var border_color := Color("ead8ca")

	# Default font size
	theme.set_default_font_size(18)

	# Button
	var btn_normal := _flat_stylebox(card_color, 12.0, border_color)
	var btn_hover := _flat_stylebox(card_hover, 12.0, accent_color)
	var btn_pressed := _flat_stylebox(Color("f9e2d3"), 12.0, accent_color)
	theme.set_stylebox("normal", "Button", btn_normal)
	theme.set_stylebox("hover", "Button", btn_hover)
	theme.set_stylebox("pressed", "Button", btn_pressed)
	theme.set_color("font_color", "Button", text_primary)
	theme.set_color("font_hover_color", "Button", Color("b95f48"))
	theme.set_font_size("font_size", "Button", 16)

	# PanelContainer
	var panel_style := _flat_stylebox(card_color, 16.0, border_color)
	theme.set_stylebox("panel", "PanelContainer", panel_style)

	# Label
	theme.set_color("font_color", "Label", text_primary)
	theme.set_font_size("font_size", "Label", 18)

	# ScrollContainer
	var scroll_bg := StyleBoxFlat.new()
	scroll_bg.bg_color = bg_color
	theme.set_stylebox("panel", "ScrollContainer", scroll_bg)

	# ProgressBar
	var pb_bg := _flat_stylebox(Color("f2e9e2"), 6.0)
	var pb_fill := _flat_stylebox(accent_color, 6.0)
	theme.set_stylebox("background", "ProgressBar", pb_bg)
	theme.set_stylebox("fill", "ProgressBar", pb_fill)
	theme.set_color("font_color", "ProgressBar", text_primary)

	# Store colors as metadata for scripts to access
	theme.set_color("bg_color", "Custom", bg_color)
	theme.set_color("card_color", "Custom", card_color)
	theme.set_color("card_hover", "Custom", card_hover)
	theme.set_color("accent_color", "Custom", accent_color)
	theme.set_color("success_color", "Custom", success_color)
	theme.set_color("locked_color", "Custom", locked_color)
	theme.set_color("text_primary", "Custom", text_primary)
	theme.set_color("text_secondary", "Custom", text_secondary)
	theme.set_color("border_color", "Custom", border_color)

	return theme

static func _flat_stylebox(bg: Color, corner_radius: float, border: Color = Color.TRANSPARENT) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_corner_radius_all(int(corner_radius))
	if border != Color.TRANSPARENT:
		sb.border_color = border
		sb.set_border_width_all(1)
	sb.set_content_margin_all(8)
	return sb
