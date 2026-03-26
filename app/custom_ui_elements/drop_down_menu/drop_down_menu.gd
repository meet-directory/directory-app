extends Control

@export var expand_time = 0.1

@export var toggle_button:Button
@export var collapse_control:Control
@export var collapsable_content:MarginContainer
## If set, won't expand to bigger than the size of this control
@export var max_size_container:Control

var active:bool = false

func _ready() -> void:
	active = toggle_button and collapsable_content and collapse_control
	if active:
		collapse_control.clip_contents = true
		collapse_control.custom_minimum_size.y = 0
		toggle_button.toggled.connect(_on_button_toggled)
		toggle_button.toggle_mode = true

func _on_button_toggled(_toggled_on:bool) -> void:
	if active:
		if collapse_control.custom_minimum_size.y == 0:
			var tween = create_tween()
			var max_size:float = INF
			if max_size_container:
				max_size = max_size_container.size.y
			var expand_size:float = clamp(collapsable_content.size.y, 0, max_size)
			tween.tween_property(collapse_control, "custom_minimum_size:y", expand_size, expand_time)
		else:
			var tween:Tween = create_tween()
			tween.tween_property(collapse_control, "custom_minimum_size:y", 0, expand_time)

func _drop_down_if_open() -> void:
	if !(collapse_control.custom_minimum_size.y == 0):
		_on_button_toggled(false)
