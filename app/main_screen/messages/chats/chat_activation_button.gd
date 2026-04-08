extends MarginContainer
class_name ChatActivator
@onready var button: Button = %Button
@onready var view_profile_button: ViewProfileButton = %ViewProfileButton

var _chat_id:int
var _participant_ids:Array
var _participant_names:Array

signal pressed(chat_id, participant_ids:Array, participant_names:Array)

func setup(chat_id:int, participant_ids:Array, participant_names:Array, participant_photo_uris:Array) -> void:
	assert(len(participant_ids) == len(participant_names))
	assert(len(participant_ids) > 0)
	button.text = participant_names[0]
	_chat_id = chat_id
	_participant_ids.assign(participant_ids)
	_participant_names.assign(participant_names)
	
	view_profile_button.set_user_info(_participant_ids[0], participant_photo_uris[0])
	


func _on_button_pressed() -> void:
	pressed.emit(_chat_id, _participant_ids, _participant_names)
