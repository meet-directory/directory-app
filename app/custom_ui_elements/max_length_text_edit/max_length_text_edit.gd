extends MarginContainer
class_name MaxLengthTextEdit

@export_multiline var placeholder_text:String
@onready var text_edit: TextEdit = %TextEdit
@onready var chars_used_label: Label = %CharsUsedLabel
@onready var max_len_label: Label = %MaxLenLabel

@export var char_limit:int = 300

func _ready() -> void:
	text_edit.placeholder_text = placeholder_text
	max_len_label.text = str(char_limit)
	chars_used_label.text = str(char_limit)

func set_text(text:String) -> void:
	text_edit.text = text
	_on_text_edit_text_changed()

func get_text() -> String:
	return text_edit.text

var old_text = ''
func _on_text_edit_text_changed() -> void:
	if len(text_edit.text) > char_limit:
		var col = text_edit.get_caret_column()
		text_edit.text = old_text
		text_edit.set_caret_column(col -1)
	chars_used_label.text = str(char_limit - len(text_edit.text))
	old_text = text_edit.text
