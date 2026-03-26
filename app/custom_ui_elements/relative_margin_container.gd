@tool
extends MarginContainer
class_name RelativeMarginContainer

@export_range(0, 1, 0.001) var top:float:
	set(value):
		top = clamp(value, 0, 1-bottom)
		_refresh()

@export_range(0, 1, 0.001) var bottom:float:
	set(value):
		bottom = clamp(value, 0, 1-top)
		_refresh()

@export_range(0, 1, 0.001) var left:float:
	set(value):
		left = clamp(value, 0, 1-right)
		_refresh()

@export_range(0, 1, 0.001) var right:float:
	set(value):
		right = clamp(value, 0, 1-left)
		_refresh()

func _refresh():
	var h_unit = size.x
	var v_unit = size.y
	add_theme_constant_override('margin_left', h_unit*left)
	add_theme_constant_override('margin_right', h_unit*right)
	add_theme_constant_override('margin_top', v_unit*top)
	add_theme_constant_override('margin_bottom', v_unit*bottom)

func _draw() -> void:
	_refresh()
