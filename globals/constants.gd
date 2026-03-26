extends Node

const main_screen_file = "res://app/main_screen/main_screen.tscn"
const login_screen_file = "res://app/login_screen/login.tscn"
const onboarding_screen_file = "res://app/onboarding_screen/onboarding_sequence.tscn"
const load_screen_file = preload("res://app/loading_screen/loading_screen.tscn")

const slide_up_menu_scene = preload("res://app/popups/general_slideup_menu/slide_up_menu.tscn")
const profile_editor_scene = preload("res://app/main_screen/profile/profile_editor/profile_editor_popup.tscn")
const profile_preview_popup_scene = preload("res://app/main_screen/profile/profile_preview/profile_view_popup.tscn")
const info_popup = preload("res://app/popups/info_popup_dialogue.tscn")
const error_popup = preload("res://app/popups/server_popup_dialogue.tscn")
const conf_popup = preload("res://app/popups/confirmation_popup_dialogue.tscn")
const tag_scene = preload("res://app/main_screen/profile_explorer/search_tool/tag_control.tscn")
const editable_tag_scene = preload("res://app/main_screen/profile_explorer/search_tool/editable_tag.tscn")
const tag_selector_scene = preload("res://app/main_screen/tag_selector_popup/tag_selector_popup.tscn")
const tag_editor_row_scene = preload("res://app/main_screen/settings/tag_editor_row.tscn")
const photo_container_scene = preload("res://app/main_screen/profile/photo_viewer/photo_viewer.tscn")
const like_request_pane = preload("res://app/main_screen/messages/like_request_pane.tscn")
const chat_activator_scene = preload("res://app/main_screen/messages/chats/chat_activation_button.tscn")
const chat_pane_scene = preload("res://app/main_screen/messages/chats/chat_pane.tscn")

const PROFILE_VIEWER_MIN_SIZE = Vector2(300, 500)
const MAX_TAG_NAME_LENGTH = 50
const TAG_ALLOWED_CHARS:String = 'abcdefghijklmnopqrstuvwxyz-'
const MIN_REQUIRED_PROFILE_TAGS = 5

const TEST_USER = 't'
const TEST_PASS = 't'

var tag = Tag.new() # used to access tag functions by TagControl

const tag_base_style_file = "res://resources/styles/tag_base.tres"

var tag_styleboxes:Dictionary[Tag.TYPE, StyleBoxFlat]

func _ready() -> void:
	var style:StyleBoxFlat = ResourceLoader.load(tag_base_style_file)
	for t in tag.raw_to_type.values():
		var new_style = style.duplicate()
		new_style.bg_color = tag.get_color(t)
		new_style.border_color = tag.get_color(t).darkened(0.7)
		tag_styleboxes[t] =  new_style

func get_screen_size() -> Vector2:
	return get_viewport().get_visible_rect().size
