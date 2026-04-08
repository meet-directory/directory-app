extends Button

@export var report_user_menu:PackedScene

func _pressed() -> void:
	if owner is ProfileView:  # should always be true
		var user_prof = owner.profile_data
		var menu = report_user_menu.instantiate()
		menu.setup(user_prof)
		#menu_button.button_pressed = false

		App.show_slideup_menu(menu)
