extends CanvasLayer
class_name ConfirmationPopup

@onready var description_label: Label = %DescriptionLabel
@onready var cancel_button: Button = %CancelButton
@onready var confirm_button: Button = %ConfirmButton
@onready var popup: MarginContainer = %Popup
@onready var scroll_content: Label = %DescriptionLabel

signal confirm_pressed
signal cancel_pressed

const INFO_CHAR = 'ℹ️'

func _ready() -> void:
	#_resize()
	cancel_button.grab_focus()
	
func _resize() -> void:
	var screen_size = get_viewport().get_visible_rect().size
	popup.custom_minimum_size = screen_size/2
	await get_tree().process_frame
	if scroll_content.size.y > popup.custom_minimum_size.y:
		popup.custom_minimum_size.y = min(screen_size.y, scroll_content.size.y + cancel_button.size.y)
	for i in range(1, 4):
		await get_tree().process_frame
		if scroll_content.size.y > popup.custom_minimum_size.y:
			popup.custom_minimum_size.x = min(screen_size.x, scroll_content.size.x + 50*i)

func set_text(text:String, cancel_btn:String="Go back", confirm_btn="Confirm"):
	description_label.text = INFO_CHAR + ' ' + text
	cancel_button.text = cancel_btn
	confirm_button.text = confirm_btn
	_resize()

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
