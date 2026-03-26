extends Menu

@export var description_char_limit := 300

@onready var text_edit: TextEdit = %TextEdit
@onready var report_options: OptionButton = %ReportReasonOptions
@onready var username_label: Label = %usernameLabel
@onready var chars_used_label: Label = %CharsUsedLabel

var user_id:int


func setup(prof:ProfileResource) -> void:
	if !is_node_ready():
		await ready
	user_id = prof.id
	username_label.text = prof.username

func _on_cancel_button_pressed() -> void:
	closed.emit()

func _on_submit_button_pressed() -> void:
	var reason:String = report_options.get_item_text(report_options.selected)
	if reason == '':
		App.show_info_popup("Must specify a reason.")
		return
	var desc = text_edit.text
	Server.report_user(user_id, reason, desc, _on_reported)

func _on_reported(resp_code, _resp) -> void:
	match resp_code:
		200:
			var text = "Thank you. You're report has been submitted. We will review it and take appropriate action."
			App.show_info_popup(text)
			closed.emit()
		_:
			Server.show_default_error_msg(resp_code)

var old_text = ''
func _on_text_edit_text_changed() -> void:
	if len(text_edit.text) > description_char_limit:
		var col = text_edit.get_caret_column()
		text_edit.text = old_text
		text_edit.set_caret_column(col -1)
	chars_used_label.text = str(description_char_limit - len(text_edit.text))
	old_text = text_edit.text
