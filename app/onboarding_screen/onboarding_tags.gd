extends OnboardingStep

@onready var tag_selector_container: TagSelectorContainer = $VBoxContainer/TagSelectorContainer


func _on_confirm_pressed() -> void:
	var tags = tag_selector_container.get_tags()
	var tag_string = tags.reduce(func (accum:String, tag:Tag):
			return accum + tag.tag_name + ','
			, '')
	
	Server.update_profile({'tags': tag_string}, _on_server_returned)

func _on_server_returned(resp_code, _resp) -> void:
	match resp_code:
		200:
			confirmed.emit()
		_:
			Server.show_default_error_msg(resp_code)
