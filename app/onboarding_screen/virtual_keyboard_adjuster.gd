extends VirtualKeyboardAdjuster

var min_size = 320

func _ready() -> void:
	var screen_size = Constants.get_screen_size()
	if screen_size.x < min_size:
		custom_minimum_size.x = screen_size.x
	else:
		custom_minimum_size.x = min_size
	
