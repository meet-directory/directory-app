extends OnboardingStep


const text = "An eight-digit code has been sent to %s"

@onready var label: Label = %Label
@onready var line_edit: LineEdit = %LineEdit
@onready var warning_box: WarningBox = %WarningBox

func _ready() -> void:
	var email = Server.session_profile.email
	label.text = text % [email]
	_check_disable()

func _check_disable():
	if not is_node_ready():
		await ready
	await get_tree().create_timer(1).timeout
	if App.disable_email_verification:
		confirmed.emit()
		

func _on_submit_button_pressed() -> void:
	var code = line_edit.text
	var email = Server.session_profile.email
	Server.verify_email(email, code, _on_verify_returned)

func _on_verify_returned(resp_code:int, resp) -> void:
	match resp_code:
		200:
			confirmed.emit()
		400:
			warning_box.hide_warning('resent')
			warning_box.show_warning('invalid')

func _on_resend_button_pressed() -> void:
	Server.resend_code(Server.session_profile.email, _on_code_resent)

func _on_code_resent(resp_code, _resp) -> void:
	match resp_code:
		200:
			warning_box.hide_warning('invalid')
			warning_box.show_warning('resent')
