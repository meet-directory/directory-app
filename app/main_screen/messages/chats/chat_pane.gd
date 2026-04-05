extends MarginContainer
class_name ChatPane
@onready var username_label: Label = %UsernameLabel
@onready var message_edit: TextEdit = %MessageEdit

@export var message_control_scene:PackedScene
@export var grey_label_setting:LabelSettings
@onready var messages_container: VBoxContainer = %MessagesContainer
@onready var scroll_container: ScrollContainer = %ScrollContainer

signal chat_closed
var _chat_id

func _ready() -> void:
	Websockets.new_message_received.connect(_new_message_received)

func _new_message_received(chat_id:int):
	if chat_id == _chat_id:
		Server.get_chat_msgs(chat_id, _on_msgs_loaded)

func setup(chat_id:int, username:String) -> void:
	username_label.text = username
	_chat_id = chat_id
	Server.get_chat_msgs(chat_id, _on_msgs_loaded)

func _on_msgs_loaded(resp_code, resp) -> void:
	match resp_code:
		200:
			for node in messages_container.get_children():
				node.queue_free()
			var user_id = Server.session_profile.id
			var last_timestamp:String = ''
			for row in resp:
				var new_date = _get_timestamp_date(row['timestamp'])
				if last_timestamp != new_date:
					last_timestamp = new_date
					var label = Label.new()
					label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
					messages_container.add_child(label)
					label.text = last_timestamp
					label.label_settings = grey_label_setting
				append_message(row['text'], row['timestamp'], user_id == row['sender_id'])
			#scroll_container.set_deferred("scroll_vertical" , scroll_container.get_v_scroll_bar().max_value)
		_: Server.show_default_error_msg(resp_code)


func _get_timestamp_date(timestamp:String) -> String:
	# YYYY-MM-DDTHH:MM:SS.SSSS
	var parts = timestamp.split('T')
	var date = parts[0]
	return date

func _on_back_button_pressed() -> void:
	chat_closed.emit()
	queue_free()


func append_message(text:String, timestamp:String, by_user:bool) -> void:
	var msg:MessageControl = message_control_scene.instantiate()
	messages_container.add_child(msg)
	msg.display_message(text, timestamp, by_user)

func _on_message_edit_submitted(_msg: String) -> void:
	_send_message()

func _send_message() -> void:
	var msg:String = message_edit.text
	if !msg.is_empty() and Server.session_profile:
		Server.send_message(_chat_id, msg, _on_message_sent)

func _on_message_sent(resp_code, _resp) -> void:
	match resp_code:
		200:
			# YYYY-MM-DDTHH:MM:SS.SSSS
			var ts = Time.get_datetime_string_from_system()
			append_message(message_edit.text, ts, true)
			message_edit.clear()
		_: Server.show_default_error_msg(resp_code)


func _on_messages_container_child_entered_tree(node: Node) -> void:
	if scroll_container:
		if not node.is_node_ready():
			await node.ready
			# wait for the node's size to be initialized so that the max_value is correct
			await get_tree().create_timer(0.05).timeout # hacky :P
		scroll_container.set_deferred("scroll_vertical" , scroll_container.get_v_scroll_bar().max_value)


func _on_submit_text_button_pressed() -> void:
	_send_message()
