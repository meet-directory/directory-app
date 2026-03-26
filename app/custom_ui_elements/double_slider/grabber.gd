extends Button
class_name DoubleSliderGrabber

@export var track:Control
@export var is_left_side:bool = false

@onready var amount_label: Label = $AmountLabel

#func _get_drag_data(at_position: Vector2) -> Variant:
	##set_drag_preview(self.duplicate())
	#return {'type': 'grabber', 'pos': at_position.x, 'node': self}
#
#func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	#var track_pos = track.global_position
	#var real_position = get_global_mouse_position() - track_pos # gonna have to make this relative
	#track._can_drop_data(real_position, data)
	#return true

func set_amount(amt:float) -> void:
	if round(amt) == amt:
		amount_label.text = str(int(amt))
	else:
		amount_label.text = str(amt)

func release() -> void:
	button_pressed = false

#func _ready() -> void:
	#set_amount(owner.get_value_of(position.x))
