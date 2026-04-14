@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_custom_type(
		"DoubleSlider",
		"Control",
		preload("double_slider.gd"),
		null
	)

func _exit_tree() -> void:
	remove_custom_type("DoubleSlider")
