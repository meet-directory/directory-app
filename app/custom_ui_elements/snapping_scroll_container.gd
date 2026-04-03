extends ScrollContainer
class_name SnappingScrollContainer

enum scroll_types {VERTICAL, HORIZONTAL}
@export var scroll_type:scroll_types = scroll_types.HORIZONTAL
@export var item_padding:Vector2
@export var item_container:BoxContainer

var _min_scroll
var _max_scroll

signal scrolled_to(index:int)

const SNAP_TIME = 0.1

signal wheel_scroll_ended

const IDLE_TIME := 0.15

var _wheel_timer: SceneTreeTimer = null

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index in [
			MOUSE_BUTTON_WHEEL_UP,
			MOUSE_BUTTON_WHEEL_DOWN,
			MOUSE_BUTTON_WHEEL_LEFT,
			MOUSE_BUTTON_WHEEL_RIGHT
		]:
			_reset_wheel_timer()

func _reset_wheel_timer() -> void:
	if _wheel_timer != null:
		_wheel_timer.timeout.disconnect(_on_wheel_idle)
	_wheel_timer = get_tree().create_timer(IDLE_TIME)
	_wheel_timer.timeout.connect(_on_wheel_idle, CONNECT_ONE_SHOT)

func _on_wheel_idle() -> void:
	_wheel_timer = null
	wheel_scroll_ended.emit()


func _ready() -> void:
	scroll_ended.connect(_snap_to_index)
	wheel_scroll_ended.connect(_snap_to_index)
	await get_tree().process_frame
	for item in item_container.get_children():
		if item is Control:
			item.custom_minimum_size = size - item_padding*2

func _snap_to_index():
	var index:int
	match scroll_type:
		scroll_types.VERTICAL:
			var item_girth = size.y
			var n_items = item_container.get_child_count()
			index = clamp(round(snappedi(scroll_vertical, item_girth)/item_girth), 0, n_items-1)
		scroll_types.HORIZONTAL:
			var item_girth = size.x
			var n_items = item_container.get_child_count()
			index = clamp(round(snappedi(scroll_horizontal, item_girth)/item_girth), 0, n_items-1)
	scroll_to(index)

func scroll_up() -> void:
	var index:int
	match scroll_type:
		scroll_types.VERTICAL:
			var item_girth = size.y
			var n_items = item_container.get_child_count()
			index = clamp(round(snappedi(scroll_vertical, item_girth)/item_girth), 0, n_items-1)
		scroll_types.HORIZONTAL:
			var item_girth = size.x
			var n_items = item_container.get_child_count()
			index = clamp(round(snappedi(scroll_horizontal, item_girth)/item_girth), 0, n_items-1)
	scroll_to(index + 1)

func scroll_down() -> void:
	var index:int
	match scroll_type:
		scroll_types.VERTICAL:
			var item_girth = size.y
			var n_items = item_container.get_child_count()
			index = clamp(round(snappedi(scroll_vertical, item_girth)/item_girth), 0, n_items-1)
		scroll_types.HORIZONTAL:
			var item_girth = size.x
			var n_items = item_container.get_child_count()
			index = clamp(round(snappedi(scroll_horizontal, item_girth)/item_girth), 0, n_items-1)
	scroll_to(index - 1)

func scroll_to(index:int) -> void:
	var tween:Tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	
	var item_girth
	match scroll_type:
		scroll_types.VERTICAL:
			item_girth = size.y
			tween.tween_property(self, "scroll_vertical", item_girth*index, SNAP_TIME)
			scrolled_to.emit(index)
		scroll_types.HORIZONTAL:
			item_girth = size.x 
			tween.tween_property(self, "scroll_horizontal", item_girth*index, SNAP_TIME)
			scrolled_to.emit(index)
	_max_scroll = item_girth*(index + 1.1) # 1.2
	_min_scroll = item_girth*(index-1)

func _process(_delta: float) -> void:
	if _max_scroll == null:
		var item_girth
		match scroll_type:
			scroll_types.VERTICAL:
				item_girth = size.y
			scroll_types.HORIZONTAL:
				item_girth = size.x 
		_max_scroll = item_girth
		_min_scroll = 0
	
	match scroll_type:
		scroll_types.HORIZONTAL:
			if scroll_horizontal > _max_scroll or scroll_horizontal < _min_scroll:
				# for some reason setting this to anything stops scroll inertia, but there's probably a better way
				# simply clamping the value every time disables scrolling at all for some reason
				scroll_horizontal = scroll_horizontal
