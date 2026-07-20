extends HBoxContainer

# When the keyboard is up, we still want to show a save/cancel button at the bottom
# in case user scrolls to bottom without closing keyboard and is confused
# on how to save

func _ready() -> void:
	App.keyboard_opened.connect(func (_height): show())
	App.keyboard_closed.connect(hide)
	#DisplayServer.virtual_keyboard_get_height()
