extends MarginContainer
class_name TagEditorRow

#DEPR

@onready var tag_control: TagControl = $HBoxContainer/Tag
@onready var option_button: OptionButton = $HBoxContainer/OptionButton


func set_tag(tag:Tag) -> void:
	tag_control.set_tag(tag)
	option_button.select(tag.type)


func _on_option_button_item_selected(index: int) -> void:
	tag_control.set_type(index as Tag.TYPE)


func _on_remove_button_pressed() -> void:
	#Server.remove_pending_tag(tag_control.get_tag())
	queue_free()
