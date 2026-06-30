extends Control

@export var scroll_container: ScrollContainer
@export var label: Label
## extra elements outside the scroll container that will affect the height of the box
@export var elements:Array[Control]
const MIN_SIZE := Vector2(30, 150)
const DESIRED_SIZE := Vector2(100,200)

func _ready() -> void:
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	get_viewport().size_changed.connect(refit)
	refit()
	

func refit() -> void:
	await get_tree().process_frame
	
	var viewport_size: Vector2 = get_viewport_rect().size
	var font: Font = label.get_theme_font("font")
	var font_size: int = label.get_theme_font_size("font_size")
	
	# Chrome = space taken up by this Control beyond the label's text area
	# (scroll container margins, theme stylebox, etc.). For a scroll container
	# anchored full-rect inside the Control with no extra margins, this is 0.
	# If you have padding, set it here (or compute as size - label.size at runtime).
	var chrome := Vector2.ZERO

	# 1. Natural unwrapped text size
	var natural := font.get_multiline_string_size(
		label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size
	)
	
	# 2. Width: grow to fit text, cap at screen
	var want_w: float = natural.x + chrome.x
	var target_w: float = clampf(want_w, MIN_SIZE.x, viewport_size.x)

	# 3. Height: if width wasn't capped, no wrapping needed.
	#    If it was capped, re-measure with wrapping at the available inner width.
	var target_h: float
	if want_w <= target_w:
		target_h = natural.y + chrome.y
	else:
		var extra:Vector2 = elements.reduce(func (accum:Vector2, node:Control): return node.size + accum, Vector2.ZERO)
		var inner_w: float = target_w - chrome.x
		var wrapped := font.get_multiline_string_size(
			label.text, HORIZONTAL_ALIGNMENT_LEFT, inner_w, font_size
		)
		wrapped *= 1.5
		target_h = wrapped.y + chrome.y + extra.y

	target_h = clampf(target_h, MIN_SIZE.y, viewport_size.y)
	custom_minimum_size = Vector2(target_w, target_h)
