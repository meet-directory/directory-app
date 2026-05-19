extends CanvasLayer
class_name ConfirmationPopup

@onready var description_label: Label = %DescriptionLabel
@onready var cancel_button: Button = %CancelButton
@onready var confirm_button: Button = %ConfirmButton
@onready var popup: MarginContainer = %Popup
@onready var scroll_content: Label = %DescriptionLabel
@onready var margin_container: Control = %MarginContainer

signal confirm_pressed
signal cancel_pressed

const INFO_CHAR = 'ℹ️'

func _ready() -> void:
	cancel_button.grab_focus()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_close_button_pressed()
	
	var pos: Vector2
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pos = event.position
	elif event is InputEventScreenTouch and event.pressed:
		pos = event.position
	else:
		return

	if not margin_container.get_global_rect().has_point(pos):
		queue_free()

func set_text(text:String, cancel_btn:String="Go back", confirm_btn="Confirm"):
	description_label.text = INFO_CHAR + ' ' + text
	cancel_button.text = cancel_btn
	confirm_button.text = confirm_btn
	margin_container.refit()



func _on_close_button_pressed() -> void:
	queue_free()

func _on_confirm_button_pressed() -> void:
	confirm_pressed.emit()
	queue_free()

func _on_cancel_button_pressed() -> void:
	cancel_pressed.emit()
	queue_free()
