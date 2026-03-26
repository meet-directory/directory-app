extends CanvasLayer
class_name ProfileEditorPopup
@onready var profile_editor: ProfileEditor = %ProfileEditor
@onready var save_tag_popup: CanvasLayer = %SaveTagPopup
@onready var menu_container: MarginContainer = %MenuContainer
@onready var bottom_marker: Control = %BottomMarker
@onready var side_margins: MarginContainer = %SideMargins

signal saved_to_db

var account_creation_mode = false  # may be depr, set during onboarding and in Constants

func _ready() -> void:
	# adjust menu margins for smaller screens
	var screen_width = get_viewport().get_visible_rect().size.x
	var side_margin = min(screen_width/40, 30)
	for attr in ["margin_left", "margin_right", "margin_top"]:
		side_margins.add_theme_constant_override(attr, side_margin)
	
	if Server.session_profile:
		profile_editor.display(Server.session_profile)
	call_deferred('animate_menu_slide')
	profile_editor.edit_canceled.connect(_on_edit_canceled)
	profile_editor.edit_saved.connect(_on_edit_saved)


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

func _on_edit_saved():
	Server.get_session_profile()
	saved_to_db.emit()
	animate_menu_slide_down()

func _on_edit_canceled():
	animate_menu_slide_down()

# DEPR
## Saving pending new tags was canceled and should be removed 
func _on_save_tag_popup_canceled() -> void:
	return
	#var edited_profile:ProfileResource = profile_editor.get_edited_profile()
	#var pending_tags:Array[String] = Server.get_pending_tag_names()
	#var existing_tags:Array[Tag] = edited_profile.is_tags.filter(func (tag:Tag): return tag.tag_name not in pending_tags)
	#Server.clear_pending_tags()
	#edited_profile.is_tags = existing_tags
	#profile_editor.display(edited_profile)
