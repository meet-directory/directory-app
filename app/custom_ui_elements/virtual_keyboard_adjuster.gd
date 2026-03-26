extends MarginContainer
class_name VirtualKeyboardAdjuster

func _ready() -> void:
	App.keyboard_opened.connect(func (height:int):
		add_theme_constant_override("margin_bottom", height)
		)
	App.keyboard_closed.connect(func ():
		add_theme_constant_override("margin_bottom", 0)
		)
