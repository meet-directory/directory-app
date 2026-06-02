extends MarginContainer
class_name SafeMarginContainer

func _ready() -> void:
	_apply_safe_area(self)

func _apply_safe_area(ui_root: Control) -> void:
	var safe := DisplayServer.get_display_safe_area()
	var full := DisplayServer.window_get_size()
	var ui_scale: float = get_window().content_scale_factor

	# Insets in physical pixels...
	#var left := safe.position.x
	var top := safe.position.y
	#var right := full.x - (safe.position.x + safe.size.x)
	#var bottom := full.y - (safe.position.y + safe.size.y)

	# ...converted into the scaled UI coordinate space.
	#ui_root.add_theme_constant_override("margin_left", int(left / ui_scale))
	ui_root.add_theme_constant_override("margin_top", int(top / ui_scale))
	#ui_root.add_theme_constant_override("margin_right", int(right / ui_scale))
	#ui_root.add_theme_constant_override("margin_bottom", int(bottom / ui_scale))

func _has_ancestor_with_same_script() -> bool:
	var my_script:Script = get_script()
	var p := get_parent()
	while p != null:
		if p is CanvasLayer:
			return false
		if p.get_script() == my_script:
			return true
		p = p.get_parent()
	return false
