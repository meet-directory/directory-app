extends Menu

@onready var report_reason_options: OptionButton = %ReportReasonOptions
@onready var max_length_text_edit: MaxLengthTextEdit = %MaxLengthTextEdit
@onready var contact_check_box: CheckBox = $MarginContainer/VBoxContainer2/ScrollContainer/VBoxContainer/HBoxContainer5/ContactCheckBox


func _on_cancel_button_pressed():
	closed.emit()

func _on_submit_button_pressed():
	var type = report_reason_options.get_item_text(report_reason_options.selected)
	var text = max_length_text_edit.get_text()
	var email = 'anonymous'
	if contact_check_box.button_pressed:
		email = Server.session_profile.email
	
	if type.is_empty():
		App.show_info_popup("Please select a type.")
	elif text.is_empty():
		App.show_info_popup("Please type in your feedback.")
	else:
		Server.report_feedback(email, type, text, _on_reported)

func _on_reported(resp_code, _resp) -> void:
	match resp_code:
		200:
			if contact_check_box.button_pressed:
				App.show_info_popup("Your feedback has been submitted.")
			else:
				App.show_info_popup("Your feedback has been submitted anonymously.")
			closed.emit()
		_:
			Server.show_default_error_msg(resp_code)
