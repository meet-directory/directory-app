extends CanvasLayer
@onready var center_container: CenterContainer = %CenterContainer
@onready var grey_panel: Panel = %GreyPanel


# Grey screen to disable interaction and display the loading message
# after this many seconds
const seconds_till_logo_display = .5

func _ready() -> void:
	center_container.hide()
	grey_panel.hide()
	await get_tree().create_timer(seconds_till_logo_display).timeout
	grey_panel.show()
	center_container.show()
