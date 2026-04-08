extends CanvasLayer


#@onready var side_margins: MarginContainer = %SideMargins
@onready var profile_viewer: ProfileView = %ProfileViewer
@onready var bottom_marker: Control = %BottomMarker
@onready var menu_container: MarginContainer = %MenuContainer


func _ready() -> void:
	call_deferred('animate_menu_slide')

func show_profile(profile:ProfileResource, mode:ProfileView.DISPLAY_MODES) -> void:
	profile_viewer.set_display_mode(mode)
	profile_viewer.display(profile)
	

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

func _on_close_button_pressed() -> void:
	animate_menu_slide_down()


func _on_profile_viewer_user_blocked() -> void:
	App.user_blocked_from_profile_popup.emit()
	animate_menu_slide_down()
