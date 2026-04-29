extends Control
class_name PhotoViewer

## TODO in the future this will fetch photos from a url and display a loading image while they are fetch


# params
@export var distance_thresh = 90
@export var scroll_wheel_amount = 20

@export var photo_container_scene:PackedScene
@export var photo_index_button:PackedScene

@onready var photo_container_list: VBoxContainer = %PhotoContainerList
@onready var index_list: VBoxContainer = %IndexList
@onready var viewer_size_node: Control = %ViewerSizeNode
@onready var scroll_container: SnappingScrollContainer = %ScrollContainer



func _has_photos() -> bool:
	return photo_container_list.get_child_count() > 0

func setup(photos:Array[ProfilePhoto]) -> void:
	for node in photo_container_list.get_children():
		node.queue_free()
	for node in index_list.get_children():
		node.queue_free()
	
	for i in range(len(photos)):
		var photo = photos[i]
		var container:PhotoViewContainer = photo_container_scene.instantiate()
		photo_container_list.add_child(container)
		container.set_photo(photo)
		
		var index_btn:Button = photo_index_button.instantiate()
		index_list.add_child(index_btn)
		index_btn.pressed.connect(_on_index_button_pressed.bind(i))
	
	if index_list.get_child_count() > 0:
		index_list.get_child(0).button_pressed = true
	
	await get_tree().process_frame
	custom_minimum_size = scroll_container.size

func _on_index_button_pressed(i:int):
	scroll_container.scroll_to(i)


func _on_scroll_container_scrolled_to(index: int) -> void:
	for i in range(index_list.get_child_count()):
		var node:Button = index_list.get_child(i)
		if i == index:
			node.button_pressed = true
		else:
			node.button_pressed = false
	
