extends Button
@export var menu:Control
@onready var report_user_button: Button = %ReportUserButton

func _ready() -> void:
	menu.hide()

func _on_toggled(toggled_on: bool) -> void:
	menu.visible = toggled_on
	
	# focus a button so scrollcontainer follows and actually shows the menu when its opened
	await get_tree().process_frame
	report_user_button.grab_focus()
