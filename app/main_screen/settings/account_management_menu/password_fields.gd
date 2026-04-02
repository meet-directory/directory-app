extends MarginContainer
@onready var old_password_field: LineEdit = %OldPasswordField
@onready var new_password_field: LineEdit = %NewPasswordField
@onready var conf_password_field: LineEdit = %ConfPasswordField
@onready var submit_password_button: Button = %SubmitPasswordButton
@onready var warning_box: WarningBox = %WarningBox

var attempted:bool = false
signal size_changed
signal password_submitted

func _ready() -> void:
	warning_box.all_warnings_cleared.connect(func (): 
		submit_password_button.disabled = false
		size_changed.emit()
		)
	warning_box.warning_activated.connect(func (): 
		submit_password_button.disabled = true
		size_changed.emit()
		)


func _on_old_password_field_text_changed(_new_text: String) -> void:
	if attempted:
		warning_box.hide_warning('incorrect-pass')
		warning_box.warn_conditional('old-pass-empty', old_password_field.text.is_empty())
		warning_box.warn_conditional('same-pass', new_password_field.text == old_password_field.text)

func _on_new_password_field_text_changed(_new_text: String) -> void:
	if attempted:
		warning_box.warn_conditional('pass-dont-match', new_password_field.text != conf_password_field.text)
		warning_box.warn_conditional('new-pass-empty', new_password_field.text.is_empty())
		warning_box.warn_conditional('same-pass', new_password_field.text == old_password_field.text)

func _on_conf_password_field_text_changed(_new_text: String) -> void:
	if attempted:
		warning_box.warn_conditional('pass-dont-match', new_password_field.text != conf_password_field.text)

func _on_submit_password_button_pressed() -> void:
	attempted = true
	warning_box.warn_conditional('pass-dont-match', new_password_field.text != conf_password_field.text)
	warning_box.warn_conditional('old-pass-empty', old_password_field.text.is_empty())
	warning_box.warn_conditional('new-pass-empty', new_password_field.text.is_empty())
	warning_box.warn_conditional('same-pass', new_password_field.text == old_password_field.text)
	if !warning_box.has_warnings():
		Server.change_password(old_password_field.text, new_password_field.text, _on_password_submitted)

func _on_password_submitted(resp_code, resp) -> void:
	match resp_code:
		200:
			App.show_info_popup("Password changed succcessfully!")
			password_submitted.emit()
		400:
			if resp.get('msg') == 'incorrect password':
				warning_box.show_warning('incorrect-pass')
		_:
			Server.show_default_error_msg(resp_code)
