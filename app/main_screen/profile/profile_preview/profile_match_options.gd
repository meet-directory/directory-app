extends MarginContainer
class_name ProfileMatchOptions

@export var report_user_menu:PackedScene


# TODO make like options first move with hflow container before trimming text
@onready var like_options: HFlowContainer = %LikeOptions
@onready var matched_container: MarginContainer = %MatchedContainer
#@onready var rescind_like_button: Button = %RescindLikeButton
@onready var like_button: Button = %LikeButton
@onready var menu_button: Button = %MenuButton


#func _ready() -> void:
	#rescind_like_button.hide()

func setup_for_profile(profile:ProfileResource) -> void:
	match profile.match_status:
		ProfileResource.match_statuses.accepted:
			#like_button.hide()
			_mark_matched()
		ProfileResource.match_statuses.pending:
			#rescind_like_button.show()
			#like_button.hide()
			_mark_liked()

func _mark_liked():
	like_button.text = "♥️ liked"
	like_button.disabled = true

func _mark_matched():
	like_button.text = "♥️ Already Matched!"
	like_button.disabled = true

func _on_like_button_pressed() -> void:
	if owner is ProfileView:
		var user_id = owner.profile_data.id
		Server.send_like(user_id, _on_like_request_returned)

func _on_like_request_returned(resp_code, _resp) -> void:
	match resp_code:
		200: 
			_mark_liked()
			#rescind_like_button.show()
		_: Server.show_default_error_msg(resp_code)

func _on_secret_like_button_pressed() -> void:
	pass # Replace with function body.
	#rescind_like_button.show()


func _on_rescind_like_button_pressed() -> void:
	pass # Replace with function body.
	
	# If this profile is liked and not secret liked, show a warning that the
	# user may have already seen the like and not responded yet. Ask for
	# confirmation before rescinding
	
	#rescind_like_button.hide()


func _on_report_user_button_pressed() -> void:
	if owner is ProfileView:
		var user_prof = owner.profile_data
		var menu = report_user_menu.instantiate()
		menu.setup(user_prof)
		menu_button.button_pressed = false

		App.show_slideup_menu(menu)
