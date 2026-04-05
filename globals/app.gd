extends Node
@export var is_prod = true
## Prevents downloading photos during development. If using prod, should always be true
@export var load_photos = true

const keyboard_padding = 0
var _last_height:float = 0

signal keyboard_opened(height:int)
signal keyboard_closed

## app constants once set
var app_scale:float # set by scale manager

enum VERSIONS {MOBILE, MOBILE_WEB, DESKTOP_WEB}
var version:VERSIONS = VERSIONS.DESKTOP_WEB

var PROFILE_VIEW_WIDTH

func is_mobile():
	return OS.get_name() in ['Android', 'iOS'] or OS.has_feature("web_android") or OS.has_feature("web_ios")

func _process(_delta):
	if DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD):
		var h = DisplayServer.virtual_keyboard_get_height() / app_scale
		if h != _last_height:
			if h > 0:
				keyboard_opened.emit(h + keyboard_padding)
			else:
				keyboard_closed.emit()
			_last_height = h

func _ready():
	if OS.has_feature("web_android") or OS.has_feature("web_ios"):
		version = VERSIONS.MOBILE_WEB
	elif OS.get_name() == "Android" or OS.get_name() == "iOS":
		version = VERSIONS.MOBILE
	
	# When browsing on desktop or desktop-web, give profile previews a max width
	await get_tree().process_frame
	if OS.has_feature("web_android") or OS.has_feature("web_ios"):
		PROFILE_VIEW_WIDTH = get_screen_size().x - 20
	elif OS.get_name() == "Android" or OS.get_name() == "iOS":
		PROFILE_VIEW_WIDTH = get_screen_size().x - 20
	else:
		PROFILE_VIEW_WIDTH = min(get_screen_size().x - 20, 400)




func show_login_screen() -> void:
	get_tree().change_scene_to_file(Constants.login_screen_file)

func show_main_app_screen() -> void:
	assert(Server.session_profile)
	if Server.session_profile.onboarded:
		get_tree().change_scene_to_file(Constants.main_screen_file)
	else:
		var popup:InfoPopup = show_info_popup("Looks like you started creating an account. Lets finish your profile setup and find your people!")
		await popup.closed
		get_tree().change_scene_to_file(Constants.onboarding_screen_file)







###################################


func show_profile_preview(profile:ProfileResource):
	var preview = Constants.profile_preview_popup_scene.instantiate()
	get_tree().root.add_child(preview)
	preview.show_profile(profile)

func show_profile_editor(creation_mode=false) -> ProfileEditorPopup:
	var editor:ProfileEditorPopup = Constants.profile_editor_scene.instantiate()
	editor.account_creation_mode = creation_mode
	get_tree().root.add_child(editor)
	return editor

func show_info_popup(text:String) -> InfoPopup:
	var popup = add_node(Constants.info_popup)
	popup.set_text(text)
	return popup

func show_error_popup(text:String) -> void:
	var popup = Constants.error_popup.instantiate()
	get_tree().root.add_child(popup)
	popup.set_text(text)

func show_conf_popup(text:String, cancel_btn:String="Go back", confirm_btn="Confirm") -> ConfirmationPopup:
	var popup = Constants.conf_popup.instantiate()
	get_tree().root.add_child(popup)
	popup.set_text(text, cancel_btn, confirm_btn)
	return popup

func create_new_tag_scene(editable=false) -> TagControl:
	var scene:TagControl
	if editable:
		scene = Constants.editable_tag_scene.instantiate()
	else:
		scene = Constants.tag_scene.instantiate()
	
	return scene

func get_screen_size() -> Vector2:
	return get_viewport().get_visible_rect().size

func show_chat_pane(chat_id:int, username:String) -> void:
	var pane:ChatPane = add_node(Constants.chat_pane_scene)
	pane.setup(chat_id, username)

func show_slideup_menu(menu:Menu) -> void:
	var slide_up_menu:SlideUpMenu = add_node(Constants.slide_up_menu_scene)
	slide_up_menu.setup(menu)

func add_node(scene:PackedScene) -> Node:
	var node:Node = scene.instantiate()
	get_tree().root.add_child(node)
	return node

func _on_timer_timeout() -> void:
	pass
	#var h = DisplayServer.virtual_keyboard_get_height()
	#BrowserDebug.print_to_screen("keyb height: "+ str(h))
	#if DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD):
		#BrowserDebug.print_to_screen("Virtual keyboard supported")
	#else:
		#BrowserDebug.print_to_screen("Virtual keyboard not supported")
