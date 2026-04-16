extends ScrollContainer
class_name MobileScrollContainer

# Extra padding so the field isn't flush against the keyboard
const SCROLL_PADDING := 12

var _focused_field:Control
var _last_keyb_height = 0

func _ready() -> void:
	update()

func update() -> void:
	if DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD):
		_connect_text_fields(self)

# Recursively find and connect all focusable nodes
func _connect_text_fields(node: Node) -> void:
	print('connect ', node)
	for child in node.get_children():
		if child is TextEdit or child is LineEdit:
			child.focus_entered.connect(func (): _focused_field = child)
			child.focus_exited.connect(func (): if _focused_field == child: _focused_field = null)
		_connect_text_fields(child)

func _process(_delta: float) -> void:
	if _focused_field:
		var keyboard_height: float = DisplayServer.virtual_keyboard_get_height()
		if keyboard_height != _last_keyb_height:
			_scroll_to_field(_focused_field)
		_last_keyb_height = DisplayServer.virtual_keyboard_get_height()

func _scroll_to_field(field: Control) -> void:
	# Field's top/bottom relative to the scroll container's origin
	# global_position difference gives position as if scroll_vertical == 0,
	# so add scroll_vertical to get position within the full content
	var field_top: float = (field.global_position.y - global_position.y) + scroll_vertical
	var field_bottom: float = field_top + field.size.y

	var view_bottom: float = scroll_vertical + size.y

	if field_bottom + SCROLL_PADDING > view_bottom:
		# Field is below (or will be below) the visible area
		scroll_vertical = int(field_bottom - size.y + SCROLL_PADDING)
