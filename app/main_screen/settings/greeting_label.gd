extends Label

@export var greeting_message:String = "Hello, {}!"

func _ready() -> void:
	Server.user_session_loaded.connect(_reset_text)
	if Server.session_profile:
		_reset_text(Server.session_profile)

func _reset_text(new_profile:ProfileResource):
	text = greeting_message.format([new_profile.username], '{}')
	
