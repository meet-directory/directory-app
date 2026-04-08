extends Control

signal confirmed
@onready var launch_button: Button = %LaunchButton
@onready var preview_profile_button: Button = %PreviewProfileButton
@onready var tos_check_box: CheckBox = %TOSCheckBox
@onready var dpp_check_box: CheckBox = %DPPCheckBox

"""
TODO:
	Shouldn't submit profile until filters have been applied
	1. Lets make a flag in the DB for accounts to be invisible (will need for suspended accounts anyway)
	2. Have all accounts be invisible when created
	3. launch button makes it visible

	Grey out subsequent steps so they are done in order, if under 18 should tell them right away
"""

var profile_saved:bool = false

func _ready() -> void:
	launch_button.disabled = true

func set_passed_arg(_var):
	pass

func _on_set_profile_button_pressed() -> void:
	var editor:ProfileEditorPopup = App.show_profile_editor(true)
	editor.saved_to_db.connect(func (): 
		profile_saved = true
		preview_profile_button.disabled = false
		_attempt_show_launch()
		)

func _on_launch_button_pressed() -> void:
	Server.complete_onboard(_on_onboard_completed)

func _on_onboard_completed(resp_code, _resp) -> void:
	match resp_code:
		200:
			# reload user session before starting the app so that the suspended field is properly updated
			Server.user_session_loaded.connect(_on_profile_retrieved)
			Server.failed_to_load_user_session.connect(_on_profile_failed)
			Server.get_session_profile()
		_:
			Server.show_default_error_msg(resp_code)

func _on_profile_retrieved(_prof) -> void:
	get_tree().change_scene_to_file(Constants.main_screen_file)

func _on_profile_failed() -> void:
	var window:InfoPopup = App.show_info_popup("Your profile has been saved, but there was an issue with the server :(. Please try opening the app later.")
	await window.closed
	get_tree().quit()

func _on_preview_profile_button_pressed() -> void:
	App.show_profile_preview(Server.session_profile, ProfileView.DISPLAY_MODES.no_options)

func _attempt_show_launch() -> void:
	var enabled = profile_saved and dpp_check_box.button_pressed and tos_check_box.button_pressed
	launch_button.disabled = !enabled

func _on_tos_check_box_toggled(_toggled_on: bool) -> void:
	_attempt_show_launch()


func _on_dpp_check_box_toggled(_toggled_on: bool) -> void:
	_attempt_show_launch()
