extends Button

@export_multiline var info_text:String

func _pressed() -> void:
	App.show_info_popup(info_text)
