extends Button
@onready var menu: MarginContainer = %Menu


@onready var block_user_button: Button = %BlockUserButton

func _ready() -> void:
	menu.hide()

func _on_toggled(toggled_on: bool) -> void:
	menu.visible = toggled_on
	
	# scroll to fit menu
	if menu.visible:
		await get_tree().process_frame
		block_user_button.grab_focus()


func _input(event: InputEvent) -> void:
	if button_pressed:
		var is_touch_tap = event is InputEventScreenTouch and event.pressed
		var is_mouse_click = event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT
