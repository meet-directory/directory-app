extends CanvasLayer

@export var tag_report_menu_scene:PackedScene
@onready var menus: Control = %Menus

@onready var grey_panel: Control = %GreyPanel

#func _ready() -> void:
	#tag_report_menu.hide()
	#grey_panel.hide()



func show_tag_report_button(tc:TagControl) -> void:
	var tag_position:Vector2 = tc.get_global_rect().get_center()
	tag_position.y -= 16
	var tag_report_menu = tag_report_menu_scene.instantiate()
	menus.add_child(tag_report_menu)

	var menu_size = tag_report_menu.container.size.x/2
	tag_position.x = clamp(tag_position.x, menu_size, App.get_screen_size().x - menu_size)
	tag_report_menu.position = tag_position
	#tag_report_menu.position = Vector2(100, 100)
	grey_panel.show()
	tag_report_menu.set_tag(tc.get_tag())
	tag_report_menu.pressed.connect(_on_report_button_pressed)

func _on_report_button_pressed() -> void:
	_clear()

func _on_grey_panel_pressed() -> void:
	_clear()

func _clear() -> void:
	grey_panel.hide()
	for child in menus.get_children():
		child.queue_free()
