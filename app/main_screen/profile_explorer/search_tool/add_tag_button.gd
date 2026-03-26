extends Button

@export var use_filter:bool = false
@export var filter_white_list:Array[Tag.TYPE]
@export var enable_add_tag_feature:bool = false

#signal tag_added(tag:Tag)
signal tags_added(tags:Array[Tag])

func _on_pressed() -> void:
	var tag_selector:TagSelectorPopup = Constants.tag_selector_scene.instantiate()
	tag_selector.use_filter = use_filter
	tag_selector.filter_white_list = filter_white_list
	tag_selector.enable_add_tag_feature = enable_add_tag_feature
	if owner is TagSelectorContainer:
		tag_selector.set_forbidden_tags(owner.get_tags())
	add_child(tag_selector)
	tag_selector.tags_submitted.connect(tags_added.emit)
