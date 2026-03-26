extends Control
class_name TagSelectorContainer

@export var title:String = "Must Match"
@export_multiline var info_text:String
@export var default_tags:Array[String] = []

@export_category("Add Tag Button Params")
@export var use_filter:bool = false
@export var filter_white_list:Array[Tag.TYPE]
@export var enable_add_tag_feature:bool = false


@onready var container: HFlowContainer = %TagContainer
@onready var add_tag_button: Button = %AddTagButton
@onready var label: Label = %Label
@onready var info_button: Button = %InfoButton

func _ready() -> void:
	label.text = title
	for child in container.get_children():
		child.queue_free()
	#add_tag_button.tag_added.connect(_on_tag_added)
	add_tag_button.use_filter = use_filter
	add_tag_button.filter_white_list = filter_white_list
	add_tag_button.enable_add_tag_feature = enable_add_tag_feature
	
	if info_text.is_empty():
		info_button.queue_free()

func _on_tag_added(tag:Tag) -> void:
	var tag_node:TagControl = App.create_new_tag_scene(true)
	container.add_child(tag_node)
	tag_node.set_tag(tag)

func get_tags() -> Array[Tag]:
	var arr:Array[Tag] = []
	for node in container.get_children():
		if node is TagControl:
			arr.append(node.get_tag())
	return arr

func add_tags(tags:Array[Tag]) -> void:
	for node in container.get_children():
		node.queue_free()
	for tag in tags:
		_on_tag_added(tag)


func _on_info_button_pressed() -> void:
	App.show_info_popup(info_text)


func _on_add_tag_button_tags_added(tags: Array[Tag]) -> void:
	add_tags(tags)
