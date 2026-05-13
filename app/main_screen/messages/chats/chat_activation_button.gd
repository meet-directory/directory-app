extends MarginContainer
class_name ChatActivator
@onready var button: Button = %Button
@onready var view_profile_button: ViewProfileButton = %ViewProfileButton
@onready var msg_notification: MarginContainer = %MsgNotification
@onready var msg_count_label: Label = %msg_count_label

var _chat_id:int
var _participant_ids:Array
var _participant_names:Array
var _unread_count:int = 0

func _ready() -> void:
	Websockets.new_message_received.connect(_on_new_message_received)

func _on_new_message_received(chat_id:int) -> void:
	if _chat_id == chat_id:
		_set_unread_count(_unread_count + 1)

func setup(chat_id:int, participant_ids:Array, participant_names:Array, participant_photo_uris:Array, unread_count:int) -> void:
	assert(len(participant_ids) == len(participant_names))
	assert(len(participant_ids) > 0)
	button.text = participant_names[0]
	_chat_id = chat_id
	_participant_ids.assign(participant_ids)
	_participant_names.assign(participant_names)
	
	_set_unread_count(unread_count)
	
	view_profile_button.set_user_info(_participant_ids[0], participant_photo_uris[0])

func _set_unread_count(count:int) -> void:
	_unread_count = count
	msg_notification.visible = count != 0
	msg_count_label.text = str(clamp(count, 0, 99))

func _on_button_pressed() -> void:
	var pane:ChatPane = App.show_chat_pane(_chat_id, _participant_names[0])
	pane.chat_closed.connect(_on_pane_closed)

func _on_pane_closed() -> void:
	_set_unread_count(0)
