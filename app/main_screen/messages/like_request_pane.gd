extends MarginContainer
class_name LikeRequestPane

@onready var view_profile_button: Button = %ViewProfileButton

var _user_id
var profile

func setup(username:String, user_id:int) -> void:
	view_profile_button.text = username
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
	pass # Replace with function body.


func _on_view_profile_button_pressed() -> void:
	App.show_profile_preview(profile)

func _on_got_profile(resp_code, resp) -> void:
	match resp_code:
		200:
			profile = ProfileResource.new()
			profile.from_db(resp)
			if len(profile.photos) > 0:
				var pp:ProfilePhoto = profile.photos[0]
				if not pp.is_loaded:
					await pp.loaded
				await get_tree().create_timer(0.1).timeout
				view_profile_button.icon = pp.texture
		_:
			Server.show_default_error_msg(resp_code)
