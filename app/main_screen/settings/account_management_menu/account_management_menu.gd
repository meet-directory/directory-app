extends Menu


func _on_logout_button_pressed() -> void:
	Server.logout()
	App.show_login_screen()
	closed.emit()

func _on_delete_account_button_pressed() -> void:
	var conf:ConfirmationPopup = App.show_conf_popup("Deleting your account will immediately delete your account details from our server permanently and irreversibly.\nAre you sure?")
	conf.confirm_pressed.connect(_on_first_conf_confirmed)

func _on_first_conf_confirmed() -> void:
	var conf:ConfirmationPopup = App.show_conf_popup("Are you really sure? It cannot be undone.")
	conf.confirm_pressed.connect(_on_second_conf_confirmed)

func _on_second_conf_confirmed() -> void:
	Server.delete_account(_on_deleted)

func _on_deleted(resp_code, _resp) -> void:
	match resp_code:
		200:
			Server.logout()
			App.show_info_popup("Your account was successfully deleted. Sorry to see you go 👋")
		_:
			Server.show_default_error_msg(resp_code)

func _on_close_button_pressed() -> void:
	closed.emit()
