extends CanvasLayer


func _on_line_edit_text_submitted(new_text: String) -> void:
	if new_text == "passwordlolz":
		queue_free()
