extends Button

func _ready() -> void:
	Server.user_session_loaded.connect(_on_user_session_loaded)
	pressed.connect(_on_pressed)
	if Server.session_profile:
		_on_user_session_loaded(Server.session_profile)

func _on_user_session_loaded(prof:ProfileResource) -> void:
	if prof.suspended:
		text = "🫥 Unsuspend Account"
	else:
		text = "🫥 Suspend Account"

func _on_pressed() -> void:
	if Server.session_profile.suspended:
		var popup:ConfirmationPopup = App.show_conf_popup(
			"Your account will become visible to other users in the public search. Are you sure?"
		)
		popup.confirm_pressed.connect(_on_unsuspend_confirmed)
	else:
		var popup:ConfirmationPopup = App.show_conf_popup(
			"Suspending your account will make your profile invisible to all other users. You also cannot use the search feature while you are invisible. Are you sure?"
		)
		popup.confirm_pressed.connect(_on_suspend_confirmed)

func _on_suspend_confirmed():
	Server.suspend_account(_on_suspend_returned)

func _on_suspend_returned(resp_code, _resp):
	match resp_code:
		200:
			App.show_info_popup("Your account was suspended. You can still respond to chats and existing requests.")
			Server.session_profile.suspended = true
			_on_user_session_loaded(Server.session_profile)
		_:
			Server.show_default_error_msg(resp_code)

func _on_unsuspend_confirmed():
	Server.unsuspend_account(_on_unsuspend_returned)

func _on_unsuspend_returned(resp_code, _resp):
	match resp_code:
		200:
			App.show_info_popup("Your account was unsuspended")
			Server.session_profile.suspended = false
			_on_user_session_loaded(Server.session_profile)
		_:
			Server.show_default_error_msg(resp_code)
