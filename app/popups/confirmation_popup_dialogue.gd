extends CanvasLayer
class_name ConfirmationPopup

@onready var description_label: Label = %DescriptionLabel
@onready var cancel_button: Button = %CancelButton
@onready var confirm_button: Button = %ConfirmButton

signal confirm_pressed
signal cancel_pressed

const INFO_CHAR = 'ℹ️'

func _ready() -> void:
	var screen_size = get_viewport().get_visible_rect().size
	description_label.custom_minimum_size.x = screen_size.x/2
	cancel_button.grab_focus()

func set_text(text:String, cancel_btn:String="Go back", confirm_btn="Confirm"):
	description_label.text = INFO_CHAR + ' ' + text
	cancel_button.text = cancel_btn
	confirm_button.text = confirm_btn

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_close_button_pressed()

func _on_close_button_pressed() -> void:
	queue_free()

func _on_confirm_button_pressed() -> void:
	confirm_pressed.emit()
	queue_free()

func _on_cancel_button_pressed() -> void:
	cancel_pressed.emit()
	queue_free()
