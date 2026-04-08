extends Button

signal user_blocked

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if owner is ProfileView:  # should always be true
		var user_prof = owner.profile_data
		var conf:ConfirmationPopup = App.show_conf_popup("Are you sure you want to block {}. This cannot be undone without contacting us.".format([user_prof.username], '{}'))
		conf.confirm_pressed.connect(_on_block_confirmed)

func _on_block_confirmed():
	if owner is ProfileView:  # should always be true
		var user_prof = owner.profile_data
		Server.block_user(user_prof.id, _on_block_request_returned)

func _on_block_request_returned(resp_code, _resp) -> void:
	match resp_code:
		200:
			user_blocked.emit()
			App.show_info_popup("User has been blocked.")
		_:
			Server.show_default_error_msg(resp_code)
