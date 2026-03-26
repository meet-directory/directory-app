extends Control

@onready var container: MarginContainer = %ReportMarginContainer
@export var menu_scene:PackedScene

signal pressed
var _tag:Tag

#func _input(event: InputEvent) -> void:
	#if visible:
		#var is_touch_tap = event is InputEventScreenTouch and event.pressed
		#var is_mouse_click = event is InputEventMouseButton and event.pressed \
			#and event.button_index == MOUSE_BUTTON_LEFT
#
		#if is_touch_tap or is_mouse_click:
			#if not container.get_global_rect().has_point(event.position):
				#hide()

func set_tag(tag:Tag) -> void:
	_tag = tag

func _on_button_pressed() -> void:
	var menu:Menu = menu_scene.instantiate()
	menu.setup(_tag)
	App.show_slideup_menu(menu)
	pressed.emit()
