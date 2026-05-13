extends MarginContainer
@onready var like_requests_container: VBoxContainer = %LikeRequestsContainer
@onready var chats_container: VBoxContainer = %ChatsContainer
#@onready var slide_window: SlideWindow = %SlideWindow
#@onready var chat_pane: ChatPane = %ChatPane
@onready var tab_container: TabContainer = %TabContainer
@onready var no_chats_label: Label = %NoChatsLabel
@onready var no_likes_label: Label = %NoLikesLabel

func _ready() -> void:
	Server.user_session_loaded.connect(_refresh_if_active)
	if Server.session_profile:
		_refresh_if_active()
	Websockets.like_request_accepted.connect(Server.get_likes.bind(_on_get_likes_returned))
	App.user_blocked_from_profile_popup.connect(_refresh_if_active)

func selected() -> void:
	refresh()

func _refresh_if_active(_profile=null) -> void:
	if visible:
		refresh()

func refresh() -> void:
	Server.get_likes(_on_get_likes_returned)
	Server.get_chats(_on_get_chats_returned)

func _on_get_likes_returned(resp_code, resp) -> void:
	for node in like_requests_container.get_children():
		node.queue_free()
	match resp_code:
		200:
			no_likes_label.visible = len(resp) == 0
			App.nlikes_changed.emit(len(resp))
			for row in resp:
				var node:LikeRequestPane = Constants.like_request_pane.instantiate()
				node.action_taken.connect(_on_like_action_taken.bind(node))
				node.accepted.connect(refresh)
				like_requests_container.add_child(node)
				node.setup(row['from_id'])
		_: Server.show_default_error_msg(resp_code)

func _on_like_action_taken(like_pane:Node):
	var nlikes = max(0, like_requests_container.get_child_count() -1)
	like_pane.queue_free()
	App.nlikes_changed.emit(nlikes)

func _on_get_chats_returned(resp_code, resp) -> void:
	for node in chats_container.get_children():
		node.queue_free()
	match resp_code:
		200:
			no_chats_label.visible = len(resp) == 0
			for row in resp:
				var node:ChatActivator = Constants.chat_activator_scene.instantiate()
				chats_container.add_child(node)
				node.setup(row['chat_id'], row['other_user_ids'], row['other_user_names'], row['participant_photo_uris'], row['unread_count'])
		_: Server.show_default_error_msg(resp_code)

func _on_refresh_button_pressed() -> void:
	refresh()

#func _on_chat_pane_chat_closed() -> void:
	#slide_window.slide_right()
	#tab_container.current_tab = 0
