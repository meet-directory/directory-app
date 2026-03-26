extends CanvasLayer

@onready var v_box_container: VBoxContainer = $MarginContainer/VBoxContainer

func print_to_screen(text:String):
	var label = Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	v_box_container.add_child(label)
