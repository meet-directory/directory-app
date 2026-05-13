extends MarginContainer
@onready var label: Label = %Label

func _ready() -> void:
	hide()
	Server.chats_refreshed.connect(Server.get_unread_msg_total.bind(_on_got_total))
	Websockets.new_message_received.connect(func (_id): Server.get_unread_msg_total(_on_got_total))
	Server.get_unread_msg_total(_on_got_total)

func _on_got_total(resp_code, resp) -> void:
	match resp_code:
		200:
			var total = resp['total_unread']
			_update(total)
		_:
			hide()

func _update(total_unread:int) -> void:
	visible = total_unread != 0
	label.text = str(clamp(total_unread, 0, 99))
