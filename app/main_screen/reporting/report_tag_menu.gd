extends Menu

@onready var tag_node: TagControl = %Tag
@onready var text_edit: TextEdit = %TextEdit
@onready var chars_used_label: Label = %CharsUsedLabel

var description_char_limit = 300

func setup(tag:Tag) -> void:
	if !is_node_ready():
		await ready
	tag_node.set_tag(tag)


func _on_submit_button_pressed() -> void:
	Server.report_tag(tag_node.get_tag_name(),  text_edit.text, _on_report_submitted)

func _on_report_submitted(resp_code, _resp) -> void:
	match resp_code:
		200:
			App.show_info_popup("Your report was submitted. Thank you!")
			closed.emit()
		_: Server.show_default_error_msg(resp_code)

func _on_cancel_button_pressed() -> void:
	closed.emit()

var old_text = ''
func _on_text_edit_text_changed() -> void:
	if len(text_edit.text) > description_char_limit:
		var col = text_edit.get_caret_column()
		text_edit.text = old_text
		text_edit.set_caret_column(col -1)
	chars_used_label.text = str(description_char_limit - len(text_edit.text))
	old_text = text_edit.text
