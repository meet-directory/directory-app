extends MarginContainer
@onready var scroll_container: ScrollContainer = %ScrollContainer

@onready var selected_tag_container: HFlowContainer = %SelectedTagContainer


func _ready() -> void:
	selected_tag_container.child_entered_tree.connect(_adjust_height)
	selected_tag_container.child_exiting_tree.connect(_adjust_height)

## Set height to follow the amount of tags present, but not get too long
func _adjust_height(_node:Node):
	## Waiting one frame ensures the node has actually exited/entered and the size
	## has been adjusted. Otherwise the size has not actually updated yet.
	await get_tree().process_frame
	scroll_container.custom_minimum_size.y = min(selected_tag_container.size.y, App.get_screen_size().y/5.5)
	scroll_container.set_deferred("scroll_vertical", int(selected_tag_container.size.y + 300))
