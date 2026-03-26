extends MarginContainer
@onready var create_account_button: Button = %CreateAccountButton
@onready var login_button: Button = %LoginButton
#@onready var new_username_field: LineEdit = %NewUsernameField
#@onready var new_password_field: LineEdit = %NewPasswordField
@onready var username_field: LineEdit = %UsernameField
@onready var password_field: LineEdit = %PasswordField

@onready var error_panel: MarginContainer = %ErrorPanel
@onready var error_messages: VBoxContainer = %ErrorMessages

@onready var warn_email_invalid: Label = %WarnEmailInvalid
@onready var warn_email_empty: Label = %WarnEmailEmpty
@onready var warn_password_empty: Label = %WarnPasswordEmpty
@onready var warn_incorrect_login: Label = %WarnIncorrectLogin
@onready var warn_email_duplicate: Label = %WarnEmailDuplicate


var valid_email_regex:RegEx

func _ready() -> void:
	error_panel.hide()
	for node in error_messages.get_children():
		node.hide()
	valid_email_regex = RegEx.new()
	valid_email_regex.compile(".+@.+\\..+")
	
	_restore_session()

func _restore_session():
	Server.user_session_loaded.connect(_on_user_session_loaded)
	Server.failed_to_load_user_session.connect(_on_user_session_not_loaded)
	await get_tree().process_frame  # ensure tree is set up so there are no errors when showing the loading screen etc
	var token = TokenStorage.load_access_token()
	if token:
		Server.get_session_profile()

func _on_user_session_not_loaded() -> void:
	TokenStorage.clear_access_token()

func _on_user_session_loaded(_prof:ProfileResource=null) -> void:
	App.show_main_app_screen()

func _on_login_button_pressed() -> void:
	var email:String = username_field.text.to_lower()
	var password:String = password_field.text
	
	Server.login(email, password, _on_login_request_returned)

func _on_login_request_returned(response_code):
	match response_code:
		200: # SUCCESS
			# The session cookie was set by the database when logging in
			# if this runs successfully, user_session_loaded will be emitted and call the function below to start the app
			#Server.user_session_loaded.connect(_on_user_session_loaded)
			Server.get_session_profile()
		401: # Invalid login
			show_error_message(warn_incorrect_login)
		_: Server.show_default_error_msg(response_code)


func _on_create_account_button_pressed() -> void:
	get_tree().change_scene_to_file(Constants.onboarding_screen_file)
	#var email:String = new_username_field.text
	#var password:String = new_password_field.text
	#
	#Server.register_new_user(email, password, _on_new_user_registered)
	#return
	#var has_warning: bool = false
	#if email.is_empty():
		#warn_email_empty.show()
		#has_warning = true
	#elif !valid_email_regex.search(email):
		#warn_email_invalid.show()
		#has_warning = true
	#if password.is_empty():
		#warn_password_empty.show()
		#has_warning = true
	#if has_warning:
		#error_panel.show()
		#return
#
#func _on_new_user_registered(resp_code:int, _response):
	#match resp_code:
		#400: # email already in use or application problem
			#show_error_message(warn_email_duplicate) 
		#200:
			#var email:String = new_username_field.text
			#var password:String = new_password_field.text
			## TODO ensure this login is successful before switching
			#Server.login(email, password, func (_code): pass)
			#get_tree().change_scene_to_file(Constants.onboarding_screen_file)

func show_error_message(message:Label):
	error_panel.show()
	message.show()

func hide_error_message(message:Label):
	if error_messages.visible:
		message.hide()
		if !error_messages.get_children().any(func (node): return node.visible):
			error_panel.hide()

## UI responses ######################################################

func _on_login_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		create_account_button.hide()
		login_button.text = "Go back"
	else:
		create_account_button.show()
		login_button.text = "Login"


#func _on_create_account_button_toggled(toggled_on: bool) -> void:
	#if toggled_on:
		#login_button.hide()
		#create_account_button.text = "Go back"
	#else:
		#login_button.show()
		#create_account_button.text = "Create Account"


func _on_username_field_text_submitted(_new_text: String) -> void:
	#if password_field.text.is_empty():
		password_field.grab_focus()
	#else:
		#_on_login_button_pressed()


func _on_password_field_text_submitted(_new_text: String) -> void:
	_on_login_button_pressed()


func _on_password_field_text_changed(_new_text: String) -> void:
	hide_error_message(warn_incorrect_login)

func _on_username_field_text_changed(_new_text: String) -> void:
	hide_error_message(warn_incorrect_login)


func _on_new_username_field_text_changed(new_text: String) -> void:
	if !new_text.is_empty():
		hide_error_message(warn_email_empty)
	hide_error_message(warn_email_duplicate)

func _on_new_password_field_text_changed(new_text: String) -> void:
	if !new_text.is_empty():
		hide_error_message(warn_password_empty)
