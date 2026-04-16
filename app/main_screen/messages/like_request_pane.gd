extends MarginContainer
class_name LikeRequestPane

@onready var view_profile_button: Button = %ViewProfileButton

var _user_id
var profile

func setup(user_id:int) -> void:
	_user_id = user_id
	
	# TODO return photo uris from server with the get_likes endpoint
	# for the button and fetch the whole profile only when button is pressed
	Server.get_user_profile(_user_id, _on_got_profile)


func _on_accept_button_pressed() -> void:
	Server.accept_like(_user_id, func (code, _resp):
		match code:
			200:
				queue_free()
			_: Server.show_default_error_msg(code)
		)


func _on_decline_button_pressed() -> void:
	var conf:ConfirmationPopup = App.show_conf_popup(
		"Would you also like to block this person so they can no longer see your profile?",
		"Yes, decline and block",
		"No, just decline"
	)
	conf.cancel_pressed.connect(_on_blocked)
	conf.confirm_pressed.connect(_on_declined)

func _on_declined() -> void:
	Server.decline_like(_user_id, func (code, _resp):
		match code:
			200:
				queue_free()
			_: Server.show_default_error_msg(code)
		)

func _on_blocked() -> void:
	Server.block_user(_user_id, func (code, _resp):
		match code:
			200:
				queue_free()
			_: Server.show_default_error_msg(code)
		)

func _on_got_profile(resp_code, resp) -> void:
	match resp_code:
		200:
			profile = ProfileResource.new()
			profile.from_db(resp)
			view_profile_button.setup(profile)
		_:
			Server.show_default_error_msg(resp_code)
