extends MarginContainer
@onready var like_requests_container: VBoxContainer = %LikeRequestsContainer
@onready var chats_container: VBoxContainer = %ChatsContainer
#@onready var slide_window: SlideWindow = %SlideWindow
#@onready var chat_pane: ChatPane = %ChatPane
@onready var tab_container: TabContainer = %TabContainer
@onready var no_chats_label: Label = %NoChatsLabel
@onready var no_likes_label: Label = %NoLikesLabel

func _ready() -> void:
	Server.user_session_loaded.connect(refresh)
	Websockets.new_message_received.connect(refresh)

func selected() -> void:
	refresh()

func refresh(_profile=null) -> void:
	Server.get_likes(_on_get_likes_returned)
	Server.get_chats(_on_get_chats_returned)

func _on_get_likes_returned(resp_code, resp) -> void:
	for node in like_requests_container.get_children():
		node.queue_free()
	match resp_code:
		200:
			no_likes_label.visible = len(resp) == 0
			for row in resp:
				var node:LikeRequestPane = Constants.like_request_pane.instantiate()
				like_requests_container.add_child(node)
				node.setup(row['username'], row['from_id'])
		_: Server.show_default_error_msg(resp_code)

func _on_get_chats_returned(resp_code, resp) -> void:
	for node in chats_container.get_children():
		node.queue_free()
	match resp_code:
		200:
			no_chats_label.visible = len(resp) == 0
			for row in resp:
				var node:ChatActivator = Constants.chat_activator_scene.instantiate()
				chats_container.add_child(node)
				node.setup(row['chat_id'], row['other_user_ids'], row['other_user_names'], row['participant_photo_uris'])
				node.pressed.connect(_on_chat_selected)
		_: Server.show_default_error_msg(resp_code)

func _on_chat_selected(chat_id, participant_ids:Array, participant_names:Array):
	# chats currently only supported with one user
	#chat_pane.setup(chat_id, participant_names[0], participant_ids[0])
	App.show_chat_pane(chat_id, participant_names[0])
	#slide_window.slide_left()
	#tab_container.current_tab = 1

func _on_refresh_button_pressed() -> void:
	refresh()

#func _on_chat_pane_chat_closed() -> void:
	#slide_window.slide_right()
	#tab_container.current_tab = 0
