extends HBoxContainer

# hide the save/cancel buttons when the keyboard is visible
# otherwise it is easy to confuse it with a "hide keyboard" or "cancel keyboard" button

func _ready() -> void:
	App.keyboard_opened.connect(func (_height): hide())
	App.keyboard_closed.connect(show)
	#DisplayServer.virtual_keyboard_get_height()
