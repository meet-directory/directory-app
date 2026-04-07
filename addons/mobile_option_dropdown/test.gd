extends Control
@onready var popup_menu: PopupMenu = $PopupMenu

func _ready() -> void:
	remove_child(popup_menu)
	add_child(popup_menu, false, Node.INTERNAL_MODE_FRONT)
	await get_tree().create_timer(0.5).timeout


func _on_button_toggled(toggled_on: bool) -> void:
	popup_menu.show()
