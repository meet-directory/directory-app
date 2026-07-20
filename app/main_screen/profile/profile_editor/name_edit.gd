extends TextEdit


func _on_text_changed() -> void:
	var new_text = text.remove_chars('\n')
	text = new_text
	set_caret_column(len(text))
