extends MarginContainer

@export var add_tag_menu:PackedScene
@export var account_mgmt_menu:PackedScene
@export var feedback_menu:PackedScene
#@onready var profile: ProfileView = %Profile
#
#@onready var profile_view: VBoxContainer = %ProfileView
#
#func _ready() -> void:
	#Signals.user_session_loaded.connect(_set_user_profiles)
	#if Server.session_profile:
		#_set_user_profiles(Server.session_profile)
#
#func _set_user_profiles(session_profile:ProfileResource) -> void:
		#profile.display(session_profile) # not working?

func _show_menu(menu_scene:PackedScene) -> void:
	var menu:Menu = menu_scene.instantiate()
	App.show_slideup_menu(menu)

func _on_edit_profile_button_pressed() -> void:
	var _editor:ProfileEditorPopup = App.show_profile_editor()

func _on_profile_view_toggle_pressed() -> void:
	App.show_profile_preview(Server.session_profile)

func _on_add_tag_button_pressed() -> void:
	_show_menu(add_tag_menu)

func _on_account_management_button_pressed() -> void:
	_show_menu(account_mgmt_menu)

func _on_feed_back_button_pressed() -> void:
	_show_menu(feedback_menu)

func _on_payment_button_pressed() -> void:
	OS.shell_open(Constants.donation_page)
