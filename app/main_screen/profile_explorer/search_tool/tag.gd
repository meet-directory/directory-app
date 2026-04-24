extends MarginContainer
class_name TagControl
const LONG_TAP_DURATION = 1

signal tapped(tag:Tag)

@export var backgrounds:Dictionary[Tag.TYPE, StyleBoxFlat] = {
	Tag.TYPE.Personal: null,
	Tag.TYPE.RelationshipType: null,
	Tag.TYPE.Intimacy: null,
	Tag.TYPE.Other:null
}

@export var type:Tag.TYPE = Tag.TYPE.Other

@export_subgroup("Internal")
@export var normal_label_setting:LabelSettings
@export var small_label_setting:LabelSettings

@onready var match_panel: Panel = %MatchPanel
@onready var disabled_panel: Panel = %DisabledPanel
@onready var emoji_label: Label = %EmojiLabel

@onready var label: Label = %Label
@onready var background_panel: Panel = %BackgroundPanel

var _disabled := false
var _pressed := false


func disable():
	_disabled = true
	disabled_panel.show()

func enable():
	_disabled = false
	disabled_panel.hide()

func shorten():
	label.custom_minimum_size.x = 50
	label.clip_text = true
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS_FORCE
	#label.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY

func is_disabled():
	return _disabled

func show_matched():
	match_panel.show()

func set_tag(tag:Tag) -> void:
	set_text(tag.tag_name)
	set_type(tag.type)

func get_tag_name() -> String:
	return label.text

func get_tag() -> Tag:
	var tag = Tag.new()
	tag.tag_name = label.text
	tag.type = type
	return tag

func set_text(text:String) -> void:
	label.text = text

func set_type_raw(raw:String) -> void:
	var new_type:Tag.TYPE = Constants.tag.raw_to_type.get(raw, Tag.TYPE.Other)
	set_type(new_type)

func set_type(new_type:Tag.TYPE) -> void:
	var bg_style = Constants.tag_styleboxes.get(new_type, Constants.tag_styleboxes[Tag.TYPE.Other])
	background_panel.add_theme_stylebox_override("panel", bg_style)
	type = new_type
	emoji_label.text = Constants.tag.get_emoji(new_type)

var _time_pressed = 0

func _on_button_button_down() -> void:
	_time_pressed = 0
	_pressed = true

func _on_button_button_up() -> void:
	_pressed = false
	if _time_pressed < LONG_TAP_DURATION:
		tapped.emit(get_tag())


func _process(delta: float) -> void:
	if _pressed:
		_time_pressed += delta
		if _time_pressed > LONG_TAP_DURATION:
			ReportOverlay.show_tag_report_button(self)
			_pressed = false
