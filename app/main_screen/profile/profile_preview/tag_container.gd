extends MarginContainer
class_name TagContainer

## This is an uneditable list of tags, for an editable one see tag_selector_container
@export var title:String
@export_category("Add Tag Button Params")
@export var use_filter:bool = false
@export var tag_type_filter:Tag.TYPE

@onready var label: Label = %Label
@onready var container: HFlowContainer = %TagContainer


func _ready() -> void:
	if title.is_empty():
		label.queue_free()
	else:
		label.text = title
	for child in container.get_children():
		if child is TagControl:
			child.queue_free()

func add_tags(tags:Array[Tag]) -> void:
	for node in container.get_children():
		if node is TagControl:
			node.queue_free()
	for tag in tags:
		var node:TagControl = App.create_new_tag_scene(false)
		container.add_child(node)
		node.set_tag(tag)

func show_matched_tags(matched_tags:Array[String]) -> void:
	for tag_node in container.get_children():
		if tag_node is TagControl:
			var tag_name = tag_node.get_tag().tag_name # TODO could be faster by getting text directly and not creating new tag resource
			if tag_name in matched_tags:
				(tag_node as TagControl).show_matched()
