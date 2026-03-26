extends MarginContainer
class_name DoubleSliderTrack

#@onready var selected_track: MarginContainer = %SelectedTrack
@onready var selection_panel: Panel = $SelectedTrack/Panel

var right_pos:float
var left_pos:float

@export var double_slider:DoubleSlider
@export var left_slider:DoubleSliderGrabber
@export var right_slider:DoubleSliderGrabber

signal grabber_moved

var _ratio_unset = true
#var og_size:float


var _padding:float = 16
var _right_pading:float = 15

var processing_left = false
var processing_right = false

#func _ready() -> void:
	#await get_tree().create_timer(0.05).timeout
	#_update_selection_bar()

func _process(_delta: float) -> void:
	var mouse_pos = get_global_mouse_position().x - global_position.x
	var at_position = mouse_pos
	if processing_left:
		var x_pos = left_slider.position.x
	
		left_pos = left_slider.position.x
		_update_selection_bar()
		left_slider.set_amount(double_slider.get_low_value())
		if x_pos >= right_pos - _padding:
			if mouse_pos < left_pos:
				_set_node_x_pos(left_slider, at_position)
				return
		_set_node_x_pos(left_slider, at_position)
	
	if processing_right:
		var x_pos = right_slider.position.x
		if right_pos == 0:
			right_pos = size.x
		if x_pos > size.x - _right_pading:
			if mouse_pos < size.x:
				_set_node_x_pos(right_slider, at_position)
			return
			
		right_pos = right_slider.position.x
		_update_selection_bar()
		right_slider.set_amount(double_slider.get_high_value())
		if x_pos <= left_pos + _padding:
			if mouse_pos > right_pos:
				_set_node_x_pos(right_slider, at_position)
			return 
		_set_node_x_pos(right_slider, at_position)


# ensure positions stay on slider
func _set_node_x_pos(node:Control, pos:float) -> void:
	pos = double_slider.get_snapped_pos(pos) # snap slider positions to the nearest step value
	if node == left_slider:
		node.position.x = clamp(pos, 0, right_slider.position.x - _padding)
	elif node == right_slider:
		node.position.x = clamp(pos, left_slider.position.x + _padding, size.x - _right_pading)
	grabber_moved.emit()

func _update_selection_bar() -> void:
	if right_pos == 0:
		right_pos = size.x
	selection_panel.size.x = right_pos - left_pos 
	selection_panel.position.x = left_pos + 5


# keep the same ratios/position when the window changes size
var last_size
func _on_draw() -> void:
	return
	# TODO bug when leave search screen and return, right slider is set to 0
	if _ratio_unset:
		_ratio_unset = false
		#og_size = size.x
		last_size = size.x
	else:
		var ratio:float = size.x/last_size
		var center:float = last_size / 2
		var new_center:float = size.x / 2
		
		var ld = center - left_pos
		var nld = ld * ratio
		var new_left_pos = new_center - nld
		left_slider.position.x = new_left_pos
		left_pos = new_left_pos
		
		var rd = center - right_pos
		var nrd = rd * ratio
		var new_right_pos = new_center - nrd
		print('slider ', rd, ' ', nrd, ' ', new_right_pos)
		print('size slider ', size.x, ' ', new_right_pos, ' ', _right_pading)

		right_slider.position.x = clamp(new_right_pos, new_left_pos, size.x - _right_pading)
		print('right slider to ', right_slider.position.x)
		right_pos = new_right_pos
		
		_update_selection_bar()
		last_size = size.x



func _input(event: InputEvent) -> void:
	if event.is_action_released("left-click"):
		left_slider.release_focus()
		right_slider.release_focus()


func _on_grabber_left_button_down() -> void:
	processing_left = true

func _on_grabber_left_button_up() -> void:
	processing_left = false


func _on_grabber_right_button_down() -> void:
	processing_right = true


func _on_grabber_right_button_up() -> void:
	processing_right = false
