extends MarginContainer
@onready var axis: Control = %axis


func _process(delta: float) -> void:
	axis.rotation += delta
