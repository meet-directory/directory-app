extends CanvasLayer
class_name InfoPopup
@onready var popup: MarginContainer = %Popup

signal closed

@onready var description_label: Label = %DescriptionLabel
@onready var close_button: Button = %CloseButton
@onready var scroll_content: VBoxContainer = %ScrollContent

func _ready() -> void:
	#_resize()
	close_button.grab_focus()

func _resize() -> void:
	var screen_size = get_viewport().get_visible_rect().size
	popup.custom_minimum_size = screen_size/2
	await get_tree().process_frame
	if scroll_content.size.y > popup.custom_minimum_size.y:
		popup.custom_minimum_size.y = min(screen_size.y, scroll_content.size.y + close_button.size.y)
	for i in range(1, 4):
		await get_tree().process_frame
		if scroll_content.size.y > popup.custom_minimum_size.y:
			popup.custom_minimum_size.x = min(screen_size.x, scroll_content.size.x + 50*i)

func set_text(text:String):
	description_label.text = text
	await get_tree().process_frame
	_resize()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_close_button_pressed()

func _on_close_button_pressed() -> void:
	closed.emit()
	queue_free()
