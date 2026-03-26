extends Button
@onready var menu: MarginContainer = %Menu


func _ready() -> void:
	menu.hide()

func _on_toggled(toggled_on: bool) -> void:
	menu.visible = toggled_on


func _input(event: InputEvent) -> void:
	if button_pressed:
		var is_touch_tap = event is InputEventScreenTouch and event.pressed
		var is_mouse_click = event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT

		if is_touch_tap or is_mouse_click:
			if not menu.get_global_rect().has_point(event.position) and not get_global_rect().has_point(event.position):
				button_pressed = false
				menu.hide()
