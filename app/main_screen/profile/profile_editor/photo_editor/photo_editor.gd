extends MarginContainer
@onready var photo_edit_viewer: PhotoEditViewer = %PhotoEditViewer

signal editing_finished

func setup(photos:Array[ProfilePhoto]) -> void:
	photo_edit_viewer.set_photos(photos)

func _on_cancel_button_pressed() -> void:
	editing_finished.emit()

func _on_save_button_pressed() -> void:
	var uris = photo_edit_viewer.get_uris()
	Server.update_and_confirm_photos(uris, _on_photos_confirmed)

func _on_photos_confirmed(resp_code, _resp) -> void:
	match resp_code:
		200:
			editing_finished.emit()
		_:
			Server.show_default_error_msg(resp_code)
