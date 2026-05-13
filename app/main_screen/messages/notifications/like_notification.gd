extends MarginContainer
@onready var label: Label = %Label

func _ready() -> void:
	hide()
	App.nlikes_changed.connect(_on_likes_changed)

func _on_likes_changed(nlikes:int) -> void:
	visible = nlikes != 0
	label.text = str(clamp(nlikes, 0, 99))
