extends Button

var _data:ProfileResource

func setup(profile_data:ProfileResource) -> void:
	_data = profile_data
	match profile_data.match_status:
		ProfileResource.match_statuses.accepted:
			_mark_matched()
		ProfileResource.match_statuses.pending:
			_mark_liked()

func _mark_liked():
	text = "♥️ liked"
	disabled = true

func _mark_matched():
	text = "♥️ Matched!"
	disabled = true

func _pressed() -> void:
	if _data:
		var user_id = _data.id
		Server.send_like(user_id, _on_like_request_returned)

func _on_like_request_returned(resp_code, _resp) -> void:
	match resp_code:
		200: 
			_mark_liked()
			#rescind_like_button.show()
		_: Server.show_default_error_msg(resp_code)
