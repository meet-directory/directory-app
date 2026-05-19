extends MarginContainer

@export var profile_viewer_scene:PackedScene
@onready var search_toggle_button: Button = %SearchToggleButton
@onready var search_param_list: VBoxContainer = %SearchParamList
@onready var profile_scroller: ProfileScroller = %ProfileScroller
#@onready var not_found_tab: MarginContainer = %NotFoundView

@onready var search_menu: CanvasLayer = %SearchMenu
@onready var suspended_view: RelativeMarginContainer = %SuspendedView
@onready var page: VBoxContainer = %Page
@onready var panel_tab: Panel = %PanelTab

const min_button_size = Vector2(40,40)

func _ready() -> void:
	selected()
	
	# show profiles when the app is loaded
	await get_tree().create_timer(0.05).timeout
	_refresh_search()
	search_toggle_button.custom_minimum_size = min_button_size

func _on_search_toggle_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		search_toggle_button.text = "Search Filter Editor"
		await get_tree().process_frame
		search_toggle_button.custom_minimum_size = search_toggle_button.size + min_button_size * Vector2(1, 0)
		#search_toggle_button.text = "🔧 Close Search Editor"
		#search_param_list.show()
		panel_tab.show()
	else:
		#search_toggle_button.text = "🔧 Edit Search"
		panel_tab.hide()
		search_toggle_button.text = ""
		search_toggle_button.custom_minimum_size = min_button_size
		#_refresh_search()

func _refresh_search() -> void:
	show_profiles()

func _on_refresh_search_result_button_pressed() -> void:
	_refresh_search()
	_on_search_toggle_button_toggled(false)

func show_profiles() -> void:
	var search_tags = Server.search_tool.get_necessary_tags()
	var optional_search_tags = Server.search_tool.get_wanted_tags()
	
	profile_scroller.show_profiles(search_tags, optional_search_tags)

func _on_search_button_pressed() -> void:
	search_toggle_button.button_pressed = false
	_on_refresh_search_result_button_pressed()

func selected():
	if Server.session_profile.suspended:
		suspended_view.show()
		search_menu.hide()
		page.hide()
	else:
		suspended_view.hide()
		search_menu.show()
		page.show()

func deselected():
	search_menu.hide()
