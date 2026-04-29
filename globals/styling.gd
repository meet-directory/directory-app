@tool
extends Node

@export var accent_color:Color:
	set(value):
		if value != accent_color:
			accent_color = value
			apply_accent(accent_color)

@export_subgroup("Styles")
@export var theme:Theme
@export var main_screen_button_normal:StyleBoxFlat


signal accent_changed(new_accent: Color)

func apply_accent(accent: Color) -> void:
	_update_button_styles(accent)
	# Repeat for other types as needed: CheckBox, OptionButton, etc.
	accent_changed.emit(accent)

func _update_button_styles(accent: Color) -> void:
	main_screen_button_normal.bg_color = accent
	var normal := theme.get_stylebox("normal", "Button") as StyleBoxFlat
	var pressed := theme.get_stylebox("pressed", "Button") as StyleBoxFlat
	var hover := theme.get_stylebox("hover", "Button") as StyleBoxFlat
	var focus := theme.get_stylebox("focus", "Button") as StyleBoxFlat
	var disabled := theme.get_stylebox("disabled", "Button") as StyleBoxFlat
	
	var border_color = derive_border(accent)
	if normal:
		normal.bg_color = accent
		normal.border_color = border_color
	if pressed:
		pressed.bg_color  = derive_pressed(accent)
		pressed.border_color = border_color
	if hover:
		hover.bg_color = derive_hover(accent)
		hover.border_color = border_color
	if focus:
		focus.bg_color    = derive_focused(accent)
		focus.border_color = border_color
	if disabled: 
		disabled.bg_color = derive_disabled(accent)
		disabled.border_color = border_color

static func derive_border(accent: Color) -> Color:
	var h := accent.h
	var s := accent.s
	var v := accent.v
	# Shift hue toward blue
	h = lerp(h, 0.66, 0.08)
	v = clamp(v - 0.42, 0.0, 1.0)
	s = clamp(s - 0.2, 0.0, 1.0)
	return Color.from_hsv(h, s, v, accent.a)

static func derive_pressed(accent: Color) -> Color:
	var h := accent.h
	var s := accent.s
	var v := accent.v
	# Shift hue toward blue
	h = lerp(h, 0.66, 0.08)
	v = clamp(v - 0.08, 0.0, 1.0)
	s = clamp(s + 0.05, 0.0, 1.0)
	return Color.from_hsv(h, s, v, accent.a)

static func derive_focused(accent: Color) -> Color:
	# Slightly lighter
	var h := accent.h
	var s := accent.s
	var v := accent.v
	v = clamp(v + 0.10, 0.0, 1.0)
	s = clamp(s - 0.05, 0.0, 1.0)
	return Color.from_hsv(h, s, v, accent.a)

static func derive_hover(accent: Color) -> Color:
	var v = clamp(accent.v + 0.05, 0.0, 1.0)
	return Color.from_hsv(accent.h, accent.s, v, accent.a)

static func derive_disabled(accent: Color) -> Color:
	return Color.from_hsv(accent.h, accent.s * 0.3, accent.v * 0.8, 0.6)
