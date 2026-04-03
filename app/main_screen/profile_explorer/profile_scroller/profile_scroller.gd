extends MarginContainer
class_name ProfileScroller

@export var profile_viewer_scene:PackedScene
@export var end_of_results_scene:PackedScene

@onready var profile_scroller: HBoxContainer = %ProfileScroller
@onready var scroll_container: SnappingScrollContainer = %ProfileScrollContainer
@onready var margin_container: MarginContainer = %MarginContainer
@onready var right_button: Button = %RightButton
@onready var left_button: Button = %LeftButton

var end_screen:EndOfResultsPage
var _search_tags
var _optional_search_tags

var page:int = 0

var current_index = 0

func _ready() -> void:
	var padding = clamp((App.get_screen_size().x - App.PROFILE_VIEW_WIDTH)/2, 0, 20)
	custom_minimum_size.x = App.PROFILE_VIEW_WIDTH + padding*2
	margin_container.add_theme_constant_override("margin_left", padding)
	margin_container.add_theme_constant_override("margin_right", padding)
	profile_scroller.add_theme_constant_override("separation", padding*2)
	
	scroll_container.scrolled_to.connect(_on_scrolled_to)
	right_button.hide()
	left_button.hide()
	
	for child in profile_scroller.get_children():
		child.queue_free()
	
	if !App.is_mobile():
		scroll_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
		#scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED

func _on_scrolled_to(index:int) -> void:
	current_index = index
	left_button.show()
	right_button.show()
	if index == 0:
		left_button.hide()
	elif index == profile_scroller.get_child_count() -1:
		right_button.hide()
	_mark_seen(index)

func _mark_seen(index:int) -> void:
	# Only mark seen if we stay on the same profile for a whole second
	await get_tree().create_timer(1).timeout
	if index == current_index:
		if profile_scroller.get_child_count() > index:
			var p = profile_scroller.get_child(index)
			if p is ProfileView:
				Server.push_seen_profile(p.profile_data.id)

func show_profiles(search_tags, optional_search_tags) -> void:
	for child in profile_scroller.get_children():
		child.queue_free()
	
	_search_tags = search_tags
	_optional_search_tags = optional_search_tags
	
	page = -1
	_load_next_page()

func _load_next_page() -> void:
	page += 1
	right_button.show()
	Server.query_profiles(_http_request_completed, page)

func _http_request_completed(_resp_code, response):
	if response != null:
		var profiles:Array[ProfileResource]
		for data in response:
			var profile = ProfileResource.new()
			profile.from_db(data)
			profiles.append(profile)
		profile_scroller.show()
		if end_screen:
			end_screen.queue_free()
		_add_profiles(profiles)
 
func _add_profiles(profiles:Array[ProfileResource]) -> void:
	for profile in profiles:
		var profile_viewer:ProfileView = profile_viewer_scene.instantiate()
		profile_scroller.add_child(profile_viewer)
		profile_viewer.display(profile, _search_tags, _optional_search_tags)
		profile_viewer.show_match_options = true
	
	end_screen = end_of_results_scene.instantiate()
	profile_scroller.add_child(end_screen)
	#var padding = clamp((App.get_screen_size().x - App.PROFILE_VIEW_WIDTH)/2, 0, 20)
	#end_screen.add_theme_constant_override("margin_left", -padding*2)
	end_screen.load_more_requested.connect(_load_next_page)
	
	_mark_seen(current_index)
	if len(profiles) < Server.NPROFILES_PER_QUERY:
		if len(profiles) == 0 and page == 0:
			end_screen.show_nor()
			right_button.hide()
			left_button.hide()
		else:
			end_screen.show_eor()

func _on_right_button_pressed() -> void:
	scroll_container.scroll_up()

func _on_left_button_pressed() -> void:
	scroll_container.scroll_down()
