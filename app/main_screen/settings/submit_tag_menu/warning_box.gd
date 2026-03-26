extends MarginContainer
class_name WarningBox

@export var warnings:Dictionary[String, String] = {}
@export var label_setting:LabelSettings
@onready var warning_label_container: VBoxContainer = %WarningLabelContainer

signal all_warnings_cleared
signal warning_activated

var _warn_labels:Dictionary[String, Label]

func _ready() -> void:
	for key in warnings.keys():
		var text := '• ' + warnings[key]
		var label := Label.new()
		label.label_settings = label_setting
		warning_label_container.add_child(label)
		label.text = text
		_warn_labels[key] = label
		label.hide()

func warn_conditional(key:String, condition:bool) -> void:
	if condition:
		show_warning(key)
	else:
		hide_warning(key)

func show_warning(key:String) -> void:
	#show()
	warning_activated.emit()
	assert(_warn_labels.has(key))
	_warn_labels[key].show()

func hide_warning(key:String) -> void:
	assert(_warn_labels.has(key))
	_warn_labels[key].hide()
	if !has_warnings():
		all_warnings_cleared.emit()
		#hide()

func has_warnings() -> bool:
	return warning_label_container.get_children().any(func (node:Label): return node.visible)
