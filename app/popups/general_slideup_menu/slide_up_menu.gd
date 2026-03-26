extends CanvasLayer
class_name SlideUpMenu

#@export var menu_scene:PackedScene

@onready var side_margins: MarginContainer = %SideMargins
@onready var bottom_marker: Control = %BottomMarker
@onready var menu_container: MarginContainer = %MenuContainer

func setup(menu:Menu):
	side_margins.add_child(menu)
	menu.closed.connect(close_menu)

func _ready() -> void:
	# adjust menu margins for smaller screens
	var screen_width = get_viewport().get_visible_rect().size.x
	var side_margin = min(screen_width/40, 30)
	for attr in ["margin_left", "margin_right", "margin_top"]:
		side_margins.add_theme_constant_override(attr, side_margin)
	
	call_deferred('animate_menu_slide')

func animate_menu_slide() -> void:
	var bottom_of_screen = bottom_marker.size.y
	var current_pos = 0
	menu_container.position.y = bottom_of_screen
	var tween:Tween = create_tween()
	tween.tween_property(menu_container, "position:y", current_pos, 0.3)

func animate_menu_slide_down() -> void:
	var bottom_of_screen = bottom_marker.size.y
	var tween:Tween = create_tween()
	tween.tween_property(menu_container, "position:y", bottom_of_screen, 0.3)
	await tween.finished
	queue_free()

func close_menu() -> void:
	animate_menu_slide_down()
