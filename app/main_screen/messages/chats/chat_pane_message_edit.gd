extends TextEdit

signal submitted(msg:String)

func _input(event: InputEvent) -> void:
	if has_focus():
		if event.is_action_pressed("message_enter"):
			text = text.remove_chars('\n')
			if !text.is_empty():
				submitted.emit(text)


func _on_text_changed() -> void:
	#var last_char = text[-1]
	#print('last char [', last_char, ']')
	#if last_char == '\n':
		#text = text.rstrip('\n')
	text = text.remove_chars('\n')
	set_caret_column(len(text))


#func _on_text_set() -> void:
	#submitted.emit(text)
	#print('set')
