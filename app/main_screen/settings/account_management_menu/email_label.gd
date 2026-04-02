extends Label

func _ready() -> void:
	Server.user_session_loaded.connect(set_email)
	if Server.session_profile:
		set_email(Server.session_profile)

func set_email(prof:ProfileResource) -> void:
	text = prof.email
