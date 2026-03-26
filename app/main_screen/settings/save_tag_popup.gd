extends CanvasLayer
@onready var tag_row_container: VBoxContainer = %TagRowContainer

signal dialogue_closed
signal canceled

func load_pending_tags() -> void:
	for child in tag_row_container.get_children():
		child.queue_free()
	for tag in Server.get_pending_tags():
		var tag_row:TagEditorRow = Constants.tag_editor_row_scene.instantiate()
		tag_row_container.add_child(tag_row)
		
		tag_row.set_tag(tag)


func _on_cancel_button_pressed() -> void:
	canceled.emit()
	hide()


func _on_save_button_pressed() -> void:
	return
	Server.save_pending_tags_to_database(_on_tags_saved)

func _on_tags_saved():
	pass
