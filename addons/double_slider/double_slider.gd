@tool
extends Control
class_name DoubleSlider

## Emitted when either value changes. Provides the new low and high values.
signal range_changed(low: float, high: float)
signal low_value_changed(value: float)
signal high_value_changed(value: float)

@export var min_value: float = 0.0:
	set(v):
		min_value = v
		low_value = clampf(low_value, min_value, max_value)
		high_value = clampf(high_value, min_value, max_value)
		queue_redraw()

@export var max_value: float = 100.0:
	set(v):
		max_value = v
		low_value = clampf(low_value, min_value, max_value)
		high_value = clampf(high_value, min_value, max_value)
		queue_redraw()

@export var low_value: float = 20.0:
	set(v):
		var clamped = clampf(v, min_value, _max_low())
		if low_value != clamped:
			low_value = clamped
			emit_signal("low_value_changed", low_value)
			emit_signal("range_changed", low_value, high_value)
			_update_labels()
			queue_redraw()

@export var high_value: float = 80.0:
	set(v):
		var clamped = clampf(v, _min_high(), max_value)
		if high_value != clamped:
			high_value = clamped
			emit_signal("high_value_changed", high_value)
			emit_signal("range_changed", low_value, high_value)
			_update_labels()
			queue_redraw()

@export var step: float = 1.0

@export_group("Appearance")
@export var track_height: float = 4.0
@export var grabber_radius: float = 10.0:
	set(v):
		grabber_radius = v
		custom_minimum_size = Vector2(50, grabber_radius * 2 + 24)
		queue_redraw()
@export var track_color: Color = Color(0.3, 0.3, 0.3)
@export var range_color: Color = Color(0.2, 0.6, 1.0)
@export var grabber_color: Color = Color(1.0, 1.0, 1.0)
@export var grabber_hover_color: Color = Color(0.85, 0.85, 0.85)
@export var grabber_pressed_color: Color = Color(0.2, 0.6, 1.0)

@export_group("Labels")
@export var show_labels: bool = true:
	set(v):
		show_labels = v
		_update_labels()

@export var label_format: String = "%.0f":
	set(v):
		label_format = v
		_update_labels()

@export var label_color: Color = Color(1.0, 1.0, 1.0):
	set(v):
		label_color = v
		_update_labels()

@export var label_font_size: int = 12:
	set(v):
		label_font_size = v
		_update_labels()
		_reposition_labels()

# Internal state
var _dragging: String = ""
var _hovered: String = ""
var _label_low: Label
var _label_high: Label

# Pixel gap enforced between the two grabbers so they never visually overlap
const GRABBER_GAP_PX: float = 2.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	custom_minimum_size = Vector2(50, grabber_radius * 2 + 24)
	_create_labels()

func _create_labels() -> void:
	if _label_low == null:
		_label_low = Label.new()
		_label_low.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		add_child(_label_low)

	if _label_high == null:
		_label_high = Label.new()
		_label_high.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		add_child(_label_high)

	_update_labels()

func _update_labels() -> void:
	if _label_low == null or _label_high == null:
		return

	_label_low.visible = show_labels
	_label_high.visible = show_labels

	if not show_labels:
		return

	_label_low.text = label_format % low_value
	_label_high.text = label_format % high_value

	_label_low.add_theme_color_override("font_color", label_color)
	_label_high.add_theme_color_override("font_color", label_color)
	_label_low.add_theme_font_size_override("font_size", label_font_size)
	_label_high.add_theme_font_size_override("font_size", label_font_size)

	_reposition_labels()

func _reposition_labels() -> void:
	if _label_low == null or _label_high == null:
		return
	if not show_labels:
		return

	var label_h = label_font_size + 4
	var center_y = size.y / 2.0
	var label_y = center_y + grabber_radius + 2.0
	var label_w = 60.0

	var low_x = _value_to_x(low_value)
	var high_x = _value_to_x(high_value)

	_label_low.size = Vector2(label_w, label_h)
	_label_low.position = Vector2(low_x - label_w / 2.0, label_y)

	_label_high.size = Vector2(label_w, label_h)
	_label_high.position = Vector2(high_x - label_w / 2.0, label_y)

func _get_track_rect() -> Rect2:
	var margin = grabber_radius
	var center_y = size.y / 2.0
	return Rect2(
		margin,
		center_y - track_height / 2.0,
		size.x - margin * 2.0,
		track_height
	)

func _value_to_x(value: float) -> float:
	var track = _get_track_rect()
	if max_value == min_value:
		return track.position.x
	return track.position.x + (value - min_value) / (max_value - min_value) * track.size.x

func _x_to_value(x: float) -> float:
	var track = _get_track_rect()
	var ratio = clampf((x - track.position.x) / track.size.x, 0.0, 1.0)
	var raw = min_value + ratio * (max_value - min_value)
	if step > 0.0:
		raw = roundf(raw / step) * step
	return clampf(raw, min_value, max_value)

# Convert a pixel distance to its equivalent value distance on this track
func _px_to_value_gap(px: float) -> float:
	var track = _get_track_rect()
	if track.size.x == 0.0:
		return 0.0
	return px / (track.size.x * (max_value - min_value))

# The highest value the low grabber may reach without overlapping the high grabber
func _max_low() -> float:
	return high_value - _px_to_value_gap(grabber_radius * 2.0 + GRABBER_GAP_PX)

# The lowest value the high grabber may reach without overlapping the low grabber
func _min_high() -> float:
	return low_value + _px_to_value_gap(grabber_radius * 2.0 + GRABBER_GAP_PX)

func _get_grabber_pos(which: String) -> Vector2:
	var val = low_value if which == "low" else high_value
	return Vector2(_value_to_x(val), size.y / 2.0)

func _is_over_grabber(pos: Vector2, which: String) -> bool:
	return pos.distance_to(_get_grabber_pos(which)) <= grabber_radius + 2.0

func _draw() -> void:
	var track = _get_track_rect()
	var low_x = _value_to_x(low_value)
	var high_x = _value_to_x(high_value)
	var center_y = size.y / 2.0

	# Full track
	draw_rect(track, track_color, true, -1.0)
	draw_rect(track, track_color.darkened(0.3), false, 1.0)

	# Active range between grabbers
	var active_rect = Rect2(
		low_x,
		center_y - track_height / 2.0,
		high_x - low_x,
		track_height
	)
	draw_rect(active_rect, range_color, true, -1.0)

	# Draw grabbers — low first so high renders on top if they get close
	for which in ["low", "high"]:
		var gpos = _get_grabber_pos(which)
		var color = grabber_color
		if _dragging == which:
			color = grabber_pressed_color
		elif _hovered == which:
			color = grabber_hover_color

		draw_circle(gpos, grabber_radius + 1.0, Color(0, 0, 0, 0.15))
		draw_circle(gpos, grabber_radius, color)
		draw_arc(gpos, grabber_radius, 0, TAU, 32,
			range_color if _dragging == which else Color(0.5, 0.5, 0.5), 1.5)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var pos = event.position
				var over_low = _is_over_grabber(pos, "low")
				var over_high = _is_over_grabber(pos, "high")

				if over_low and over_high:
					var d_low = pos.distance_to(_get_grabber_pos("low"))
					var d_high = pos.distance_to(_get_grabber_pos("high"))
					_dragging = "low" if d_low <= d_high else "high"
				elif over_low:
					_dragging = "low"
				elif over_high:
					_dragging = "high"
				else:
					# Click on track — snap nearest grabber
					var clicked_val = _x_to_value(pos.x)
					var d_low = abs(clicked_val - low_value)
					var d_high = abs(clicked_val - high_value)
					_dragging = "low" if d_low <= d_high else "high"
					if _dragging == "low":
						low_value = clicked_val
					else:
						high_value = clicked_val
			else:
				_dragging = ""
			queue_redraw()

	elif event is InputEventMouseMotion:
		var pos = event.position
		if _dragging == "low":
			low_value = clampf(_x_to_value(pos.x), min_value, _max_low())
		elif _dragging == "high":
			high_value = clampf(_x_to_value(pos.x), _min_high(), max_value)
		else:
			var prev_hovered = _hovered
			if _is_over_grabber(pos, "high"):
				_hovered = "high"
			elif _is_over_grabber(pos, "low"):
				_hovered = "low"
			else:
				_hovered = ""
			if _hovered != prev_hovered:
				queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_EXIT:
		_hovered = ""
		queue_redraw()
	elif what == NOTIFICATION_RESIZED:
		_reposition_labels()
