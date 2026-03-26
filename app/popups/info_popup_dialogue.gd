extends CanvasLayer
class_name InfoPopup

signal closed

@onready var description_label: Label = %DescriptionLabel
@onready var close_button: Button = %CloseButton

func _ready() -> void:
	var screen_size = get_viewport().get_visible_rect().size
	description_label.custom_minimum_size.x = screen_size.x/2
	close_button.grab_focus()

func set_text(text:String):
	description_label.text = text

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_close_button_pressed()

func _on_close_button_pressed() -> void:
	closed.emit()
	queue_free()
