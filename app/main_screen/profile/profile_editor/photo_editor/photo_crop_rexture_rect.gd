extends TextureRect

var dragging := false
var drag_offset := Vector2.ZERO
var max_scale := 8

# TODO Handle photos that are too small

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP
	pinch.connect(apply_zoom)
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
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			apply_zoom(1.05, get_global_mouse_position())
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			apply_zoom(0.95, get_global_mouse_position())
	

func apply_zoom(factor: float, mouse_pos:Vector2):
	var new_scale = scale * factor
	var crop_size = get_parent().size
	var min_scale = max(
		crop_size.x / texture.get_size().x,
		crop_size.y / texture.get_size().y
	)
	new_scale = new_scale.clamp(Vector2.ONE * min_scale, Vector2.ONE * max_scale)
	
	if scale != new_scale:
		
		#print('mp ', mouse_pos, ' gp: ', global_position, ' factor ', factor)
		var d = mouse_pos - global_position
		var da = d*factor
		var new_global_pos = mouse_pos - da
		global_position = new_global_pos
	
	scale = new_scale
	clamp_to_bounds()

func clamp_to_bounds():
	var crop_size = get_parent().size
	var photo_size = texture.get_size()*scale
	var min_pos = crop_size - photo_size
	var max_pos = Vector2.ZERO
	position.x = clamp(position.x, min_pos.x, max_pos.x)
	position.y = clamp(position.y, min_pos.y, max_pos.y)



############################################# mobile zoom stuff ##################
signal pinch(factor: float, center: Vector2)

var _touches: Dictionary = {}            # all active finger positions
var _finger_a: int = -1                  # the two fingers we're tracking
var _finger_b: int = -1
var _prev_distance: float = 0.0

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_touches[event.index] = event.position
			_try_lock_pair()
		else:
			_touches.erase(event.index)
			# If one of our locked fingers lifted, release the pair
			if event.index == _finger_a or event.index == _finger_b:
				_release_pair()
				_try_lock_pair()  # promote any remaining fingers
	
	elif event is InputEventScreenDrag:
		if _touches.has(event.index):
			_touches[event.index] = event.position
		
		if _finger_a == -1 or _finger_b == -1:
			return
		
		var pos_a: Vector2 = _touches[_finger_a]
		var pos_b: Vector2 = _touches[_finger_b]
		var new_distance := pos_a.distance_to(pos_b)
		
		if _prev_distance <= 1.0 or new_distance <= 1.0:
			_prev_distance = new_distance
			return
		
		var factor := new_distance / _prev_distance
		# Reject impossible jumps 
		if factor < 0.7 or factor > 1.4:
			_prev_distance = new_distance
			return
		
		var event_position = (pos_a + pos_b) * 0.5
		pinch.emit(factor, event_position)
		_prev_distance = new_distance

func _try_lock_pair() -> void:
	if _finger_a != -1 and _finger_b != -1:
		return  # already locked
	var indices := _touches.keys()
	if indices.size() < 2:
		return
	_finger_a = indices[0]
	_finger_b = indices[1]
	_prev_distance = (_touches[_finger_a] as Vector2).distance_to(_touches[_finger_b])

func _release_pair() -> void:
	_finger_a = -1
	_finger_b = -1
	_prev_distance = 0.0
