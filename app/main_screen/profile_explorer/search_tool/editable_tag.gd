extends TagControl

@onready var button: Button = $MarginContainer/Button

func _ready() -> void:
	# editable tags can only be deleted, so we don't need the tap functionality
	button.queue_free()

func _on_delete_button_pressed() -> void:
	queue_free()
