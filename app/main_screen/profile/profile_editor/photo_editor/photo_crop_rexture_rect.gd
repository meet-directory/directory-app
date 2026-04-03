extends TextureRect

var dragging := false
var drag_offset := Vector2.ZERO
var max_scale := 8

# TODO Handle photos that are too small

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP
	#pivot_offset.x = size.x / 2.0
	#clamp_to_bounds()

func set_photo(tex:Texture2D) -> void:
	if not get_parent().is_node_ready():
		await get_parent().ready
	texture = tex
	
	# Ensure photo starts within bounds
	await get_tree().process_frame
	apply_zoom(1, Vector2.ZERO)

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		dragging = event.pressed
		if dragging:
			drag_offset = get_global_mouse_position() - global_position
	
	if event is InputEventMouseMotion and dragging:
		global_position = get_global_mouse_position() - drag_offset
		clamp_to_bounds()
	
	# Pinch to zoom (touch) or scroll wheel to zoom
	if event is InputEventMagnifyGesture:
		apply_zoom(event.factor, event.position)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			apply_zoom(1.05, get_parent().global_position - get_global_mouse_position())
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			apply_zoom(0.95, get_parent().global_position - get_global_mouse_position())

func apply_zoom(factor: float, mouse_pos:Vector2):
	var new_scale = scale * factor
	var crop_size = get_parent().size
	var min_scale = max(
		crop_size.x / texture.get_size().x,
		crop_size.y / texture.get_size().y
	)
	new_scale = new_scale.clamp(Vector2.ONE * min_scale, Vector2.ONE * max_scale)
	
	if scale != new_scale:  # haven't tried zooming past max or min
		var offset = (mouse_pos*factor - mouse_pos)*new_scale
		position += offset
	
	scale = new_scale
	clamp_to_bounds()

func clamp_to_bounds():
	var crop_size = get_parent().size
	var photo_size = texture.get_size()*scale
	var min_pos = crop_size - photo_size
	var max_pos = Vector2.ZERO
	position.x = clamp(position.x, min_pos.x, max_pos.x)
	position.y = clamp(position.y, min_pos.y, max_pos.y)
