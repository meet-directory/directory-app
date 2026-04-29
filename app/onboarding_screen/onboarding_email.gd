extends OnboardingStep
@onready var new_username_field: LineEdit = %NewUsernameField
@onready var new_password_field: LineEdit = %NewPasswordField
@onready var confirm_password_field: LineEdit = %ConfirmPasswordField
@onready var container: VBoxContainer = %VBoxContainer2

@onready var error_panel: MarginContainer = %ErrorPanel
@onready var error_messages: VBoxContainer = %ErrorMessages
@onready var warn_email_invalid: Label = %WarnEmailInvalid
@onready var warn_email_empty: Label = %WarnEmailEmpty
@onready var warn_password_empty: Label = %WarnPasswordEmpty
@onready var warn_incorrect_login: Label = %WarnIncorrectLogin
@onready var warn_email_duplicate: Label = %WarnEmailDuplicate
@onready var warn_password_dont_match: Label = %WarnPasswordDontMatch


func _ready() -> void:
	var screen_size = Constants.get_screen_size()
	container.custom_minimum_size.x = screen_size.x/1.5
	error_panel.hide()
	for node in error_messages.get_children():
		node.hide()

func _on_create_account_button_pressed() -> void:
	var email:String = new_username_field.text
	var password:String = new_password_field.text
	var password_conf:String = confirm_password_field.text
	#if email == 'test':
		#confirmed.emit(null)
		#return
	var has_warning: bool = false
	if email.is_empty():
		show_error_message(warn_email_empty)
		has_warning = true
	#elif !valid_email_regex.search(email):
		#warn_email_invalid.show()
		#has_warning = true
	if password != password_conf:
		has_warning = true
		show_error_message(warn_password_dont_match)
	if password.is_empty():
		show_error_message(warn_password_empty)
		has_warning = true
	if has_warning:
		error_panel.show()
		return
	
	var birthday_string = onboarding_data['birthdate']
	Server.register_new_user(email.to_lower(), password, birthday_string, _on_new_user_registered)
	return

func _on_new_user_registered(resp_code:int, response):
	match resp_code:
		400: 
			if response and response.get("msg", "") == "Email Already In Use":
				App.show_info_popup("That email address is already in use! Please choose a different one.")
		200:
			# login and get an active session now that we're in
			var email:String = new_username_field.text
			var password:String = new_password_field.text
			Server.login(email, password, _on_login_request_returned)
		_: Server.show_default_error_msg(resp_code)


func _on_login_request_returned(response_code):
	match response_code:
		200: # SUCCESS
			# The session cookie was already set by the database for logging in
			#Server.get_session_profile(Server.set_session_profile)
			# TODO ensure get_profile is successful before scene change
			# TODO if sesstion profile is not found in db, go to onboarding screen
			Server.get_session_profile()
			confirmed.emit()
		#401: # Invalid login
			#show_error_message(warn_incorrect_login)
		_: Server.show_default_error_msg(response_code)

func show_error_message(message:Label):
	error_panel.show()
	message.show()

func hide_error_message(message:Label):
	if error_messages.visible:
		message.hide()
		if !error_messages.get_children().any(func (node): return node.visible):
			error_panel.hide()


func _on_new_password_field_text_changed(_new_text: String) -> void:
	if new_password_field.text == confirm_password_field.text:
		hide_error_message(warn_password_dont_match)
	else:
		show_error_message(warn_password_dont_match)


func _on_confirm_password_field_text_changed(new_text: String) -> void:
	_on_new_password_field_text_changed(new_text)


func _on_new_username_field_text_changed(_new_text: String) -> void:
	hide_error_message(warn_email_invalid)
	hide_error_message(warn_email_empty)
	hide_error_message(warn_email_duplicate)
