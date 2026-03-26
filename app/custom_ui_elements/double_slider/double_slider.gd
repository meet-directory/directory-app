extends MarginContainer
class_name DoubleSlider


@export var max_value:float = 100
@export var min_value:float
@export var step_value:float = 1
@export var left_start_pos:float
@export var right_start_pos:float

@onready var track: DoubleSliderTrack = %Track
@onready var grabber_left: DoubleSliderGrabber = %GrabberLeft
@onready var grabber_right: DoubleSliderGrabber = %GrabberRight

signal value_changed(min_val:float, max_val:float)

var slider_pos_offset:float = 12
var right_slider_offset:float = 2


func _ready() -> void:
	grabber_left.set_amount(min_value)
	grabber_right.set_amount(max_value)

# TODO snap grabber positions to a concrete point value
func _get_value_of(x_pos:float) -> int:
	var pixels_per_step = (max_value-min_value) / (track.size.x - slider_pos_offset - right_slider_offset - min_value)
	var adjusted_pos = x_pos - slider_pos_offset
	return clamp(snapped(adjusted_pos*pixels_per_step + min_value, step_value), min_value, max_value)

func get_low_value() -> float:
	return _get_value_of(grabber_left.position.x + slider_pos_offset)

func get_high_value() -> float:
	return _get_value_of(grabber_right.position.x)

func get_snapped_pos(x_pos:float) -> float:
	var pixels_per_step = (track.size.x / (max_value - min_value))*step_value
	return snapped(x_pos, pixels_per_step)
	

func _on_track_grabber_moved() -> void:
	value_changed.emit(get_low_value(), get_high_value())
