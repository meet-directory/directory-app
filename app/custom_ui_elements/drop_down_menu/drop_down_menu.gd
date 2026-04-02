extends Control

@export var expand_time = 0.1

@export var toggle_button:Button
@export var collapse_control:Control
@export var collapsable_content:MarginContainer
@export_category("Optional")
## If set, won't expand to bigger than the size of this control. Expects use of a scroll container to see elements that don't fit.
@export var max_size_container:Control


var active:bool = false

func _ready() -> void:
	active = toggle_button and collapsable_content and collapse_control
	if active:
		collapse_control.clip_contents = true
		collapse_control.custom_minimum_size.y = 0
		toggle_button.toggled.connect(_on_button_toggled)
		toggle_button.toggle_mode = true
		
		# avoid menu button being triggered by the first draw
		# there's probably a better way to do this
		await get_tree().create_timer(0.5).timeout
		collapsable_content.item_rect_changed.connect(on_content_size_changed)

func on_content_size_changed() -> void:
	# wait a few frames so the element is redrawn at the correct size before expanding
	await get_tree().process_frame
	await get_tree().process_frame
	_expand_size()

func toggle() -> void:
	_on_button_toggled(false)

func _on_button_toggled(_toggled_on:bool) -> void:
	if active:
		if collapse_control.custom_minimum_size.y == 0:
			toggle_button.button_pressed = true
			_expand_size()
		else:
			toggle_button.button_pressed = false
			var tween:Tween = create_tween()
			tween.tween_property(collapse_control, "custom_minimum_size:y", 0, expand_time)

func _expand_size():
	var tween = create_tween()
	var max_size:float = INF
	if max_size_container:
		max_size = max_size_container.size.y
	var expand_size:float = clamp(collapsable_content.size.y, 0, max_size)
	tween.tween_property(collapse_control, "custom_minimum_size:y", expand_size, expand_time)

func _drop_down_if_open() -> void:
	if !(collapse_control.custom_minimum_size.y == 0):
		_on_button_toggled(false)
