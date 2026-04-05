@tool
extends VBoxContainer
class_name MessageControl
@onready var bubble_container: RelativeMarginContainer = %BubbleContainer
@onready var panel: Panel = %Panel
@onready var time_stamp_label: Label = %TimeStampLabel
@onready var message_label: Label = %MessageLabel

@export var sent_by_user_panel:StyleBoxFlat
@export var sent_by_other_panel:StyleBoxFlat

@export var sent_by_user:bool = false:
	set(value):
		sent_by_user = value
		if Engine.is_editor_hint() and is_node_ready():
			set_correct_style()

func set_correct_style() -> void:
	if sent_by_user:
		#bubble_container.size_flags_horizontal = Control.SIZE_SHRINK_END
		time_stamp_label.size_flags_horizontal = Control.SIZE_SHRINK_END
		bubble_container.right = 0
		bubble_container.left = 0.2
		panel.add_theme_stylebox_override('panel', sent_by_user_panel)
	else:
		#bubble_container.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		time_stamp_label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		bubble_container.right = 0.2
		bubble_container.left = 0
		panel.add_theme_stylebox_override('panel', sent_by_other_panel)

func _ready() -> void:
	if !Engine.is_editor_hint():
		#var screen_size = get_viewport().get_visible_rect().size
		#bubble_container.custom_minimum_size.x = screen_size.x * 0.6
		set_correct_style()

func display_message(text:String, utc_timestamp:String, sent_by_this:bool) -> void:
	message_label.text = text
	time_stamp_label.text = _convert_timestamp(utc_timestamp)
	sent_by_user = sent_by_this
	set_correct_style()

func _convert_timestamp(utc_timestamp:String) -> String:
	# YYYY-MM-DDTHH:MM:SS.SSSS
	var unix_time:int = Time.get_unix_time_from_datetime_string(utc_timestamp)
	var offset:int = Time.get_time_zone_from_system().bias * 60
	var local_unix = unix_time + offset
	var local_time = Time.get_datetime_dict_from_unix_time(local_unix)
	
	var hour = local_time.hour
	var minute = local_time.minute
	return "%02d:%02d" % [hour, minute]
	
