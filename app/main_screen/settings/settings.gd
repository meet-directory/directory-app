extends MarginContainer

@export var add_tag_menu:PackedScene
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
		

func _on_edit_profile_button_pressed() -> void:
	var _editor:ProfileEditorPopup = App.show_profile_editor()

func _on_logout_button_pressed() -> void:
	Server.logout()
	App.show_login_screen()


func _on_profile_view_toggle_pressed() -> void:
	App.show_profile_preview(Server.session_profile)


func _on_delete_account_button_pressed() -> void:
	var conf:ConfirmationPopup = App.show_conf_popup("Deleting your account will immediately delete your account details from our server permanently and irreversably.\nAre you sure?")
	conf.confirm_pressed.connect(_on_first_conf_confirmed)

func _on_first_conf_confirmed() -> void:
	var conf:ConfirmationPopup = App.show_conf_popup("Are you really sure? It cannot be undone.")
	conf.confirm_pressed.connect(_on_second_conf_confirmed)

func _on_second_conf_confirmed() -> void:
	Server.delete_account(_on_deleted)

func _on_deleted(resp_code, _resp) -> void:
	match resp_code:
		200:
			Server.logout()
			App.show_info_popup("Your account was successfully deleted. Sorry to see you go 👋")
		_:
			Server.show_default_error_msg(resp_code)


func _on_add_tag_button_pressed() -> void:
	var tag_menu:Menu = add_tag_menu.instantiate()
	App.show_slideup_menu(tag_menu)
