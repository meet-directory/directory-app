extends CanvasLayer
class_name TagSelectorPopup

@export var use_filter:bool = false
@export var filter_white_list:Array[Tag.TYPE]
@export var enable_add_tag_feature:bool = false
@onready var middle_margin_container: MarginContainer = %MiddleMarginContainer

#signal tag_selected(tag:Tag)
signal tags_submitted(tags:Array[Tag])
signal tag_deselected(tag_name:String)

@onready var tag_list: VBoxContainer = %TagList
@onready var other_category_tag_list: VBoxContainer = %OtherCategoryTagList
@onready var filter_container: Control = %FilterContainer
@onready var create_tag_container: MarginContainer = %CreateTagContainer
@onready var not_found_tag: TagControl = %NotFoundTag
@onready var search_bar: LineEdit = %SearchBar
@onready var selected_tag_container: Control = %SelectedTagContainer
@onready var tag_editor: TagEditor = %TagEditor
@onready var close_button: Button = %CloseButton
@onready var save_button: Button = %SaveTags
@onready var main_scroll_container: ScrollContainer = %MainScrollContainer
@onready var tab_container: TabContainer = %TabContainer

# tabs
@onready var tag_search_scroller: ScrollContainer = %TagSearchScroller
@onready var tag_explorer: ScrollContainer = %TagExplorer
@onready var tag_category_explorer: MarginContainer = %TagCategoryExplorer

var forbidden_tags:Array[Tag] = []

func _ready() -> void:
	filter_container.visible = false
	create_tag_container.visible = false
	search_bar.max_length = Constants.MAX_TAG_NAME_LENGTH
	search_bar.grab_focus() # enable typing straight away without first clicking search bar
	var screen_size = Constants.get_screen_size()
	#middle_margin_container.custom_minimum_size.x = min(screen_size.x*.95, 450)
	#middle_margin_container.custom_minimum_size.y = min(screen_size.y*.95, 500)
	
	# forbidden tags gets set before this is ready so we add them here
	for tag in forbidden_tags:
		_add_selected_tag(tag)
	#call_deferred("_setup")
	tag_explorer.show()

#func _setup():
	#tab_container.custom_minimum_size.y = max(main_scroll_container.size.y - 90, 200)

func set_forbidden_tags(tags:Array[Tag]) -> void:
	forbidden_tags = tags

func _add_selected_tag(tag:Tag) -> void:
		var tag_node:TagControl = App.create_new_tag_scene(true)
		selected_tag_container.add_child(tag_node)
		tag_node.set_tag(tag)
		#tag_node.shorten()
		tag_node.tree_exiting.connect(_on_tag_deselected.bind(tag_node.get_tag()))

func _on_tag_deselected(tag:Tag):
	forbidden_tags = forbidden_tags.filter(func (ftag:Tag): return ftag.tag_name != tag.tag_name)
	tag_deselected.emit(tag.tag_name)

func _on_search_bar_text_changed(new_text: String) -> void:
	if new_text.is_empty():
		tag_explorer.show()
		tag_category_explorer.reset()
		return
	tag_search_scroller.show()
	var last_char = new_text[-1]
	if last_char in Constants.TAG_ALLOWED_CHARS:
		# Query server for tags simliar to text
		Server.fuzzy_search_tags(new_text, _on_search_returned.bind(new_text))
	else:
		search_bar.text = new_text.left(len(new_text)-1)
		search_bar.caret_column = len(new_text)


func _on_search_returned(_resp_code, data, search_text) -> void:
	var search_text_found:bool = false
	
	# reset state
	for child in tag_list.get_children():
		child.queue_free()
	for child in other_category_tag_list.get_children():
		child.queue_free()
	filter_container.visible = false
	
	var forbidden_tag_names = forbidden_tags.map(func (tag:Tag): return tag.tag_name)
	# add tags
	if data:
		for row in data:
			var tag:TagControl = App.create_new_tag_scene()
			
			var tag_raw_name:String = row['name']
			var tag_raw_type:String = row['tag_type']
			
			var tag_type = Tag.raw_to_type[tag_raw_type]
			var is_black_listed = use_filter and !(tag_type in filter_white_list)
			
			if is_black_listed:
				filter_container.show()
				other_category_tag_list.add_child(tag)
			else:
				tag_list.add_child(tag)
				tag.tapped.connect(_on_tag_tapped)
			
			tag.set_text(tag_raw_name)
			tag.set_type_raw(tag_raw_type)
			tag_deselected.connect((func (d_tag_name, t): if t and t.get_tag_name() == d_tag_name: t.enable()).bind(tag))
			if tag_raw_name in forbidden_tag_names:
				tag.disable()
			
			# IMPR: technically we only need to check the first row returned, would be more efficient?
			if search_text == tag_raw_name:
				search_text_found = true
		
	if enable_add_tag_feature:
		if len(search_text) < 2:
			create_tag_container.hide()
			return

		if search_text_found:
			create_tag_container.hide()
		else:
			create_tag_container.show()
			not_found_tag.set_text(search_text)
			#not_found_tag.set_type(tag_type_filter)
			

func _on_tag_tapped(tag:Tag):
	#tag_selected.emit(tag)
	forbidden_tags.append(tag)
	
	_add_selected_tag(tag)
	
	# reset state
	for child in tag_list.get_children():
		child.queue_free()
	for child in other_category_tag_list.get_children():
		child.queue_free()
	filter_container.visible = false
	
	search_bar.clear()
	search_bar.grab_focus()


func _get_first_tag_result() -> Tag:
	if tag_list.get_child_count() > 0:
		var tag_node:TagControl = tag_list.get_child(0)
		if !tag_node.is_disabled():
			return tag_node.get_tag()
	return null

func _on_search_bar_text_submitted(_new_text: String) -> void:
	## Add the first search result as if you had tapped it when enter is pressed
	var first_tag:Tag = _get_first_tag_result()
	if first_tag:
		_on_tag_tapped(first_tag)


func _on_tag_category_explorer_tag_tapped(tag: Tag) -> void:
	#_on_tag_tapped(tag)
	forbidden_tags.append(tag)
	_add_selected_tag(tag)

func _on_close_button_pressed() -> void:
	queue_free()

func _on_add_tag_button_pressed() -> void:
	#await get_tree().create_timer(0.5).timeout
	tag_search_scroller.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	tag_search_scroller.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tween:Tween = create_tween()
	tween.tween_property(tag_search_scroller, "scroll_vertical", 100000000, 0.5) # keep the tag_editor visible during its expansion
	
	# expand the tag editor and disable this popup
	search_bar.editable = false
	#close_button.disabled = true
	save_button.disabled = true
	tag_editor.expand()
	tag_editor.set_tag_text(search_bar.text)
	return
	
func _on_tag_editor_closed() -> void:
	filter_container.visible = false
	#var new_tag:Tag = not_found_tag.get_tag()
	#tag_selected.emit(new_tag)
	#Server.add_pending_tag(new_tag)
	create_tag_container.hide()
	
	# reset state
	search_bar.clear()
	search_bar.grab_focus()
	for child in tag_list.get_children():
		child.queue_free()
	for child in other_category_tag_list.get_children():
		child.queue_free()
	filter_container.hide()
	
	# re-enable everything
	search_bar.editable = true
	save_button.disabled = false

func _on_tag_editor_canceled() -> void:
	# re-enable everything
	search_bar.editable = true
	save_button.disabled = false


"""
Tests to write
NewTagContainer only and always visible when:
	The search text does not exist in the database
	The search text is not already pending to add a new tag
	A new tag was just added, but there's another eligible tag to add
NewTagContainer is not visible when:
	The search text does exist in the database
"""




func _on_add_tags_pressed() -> void:
	var tags:Array[Tag]
	for node in selected_tag_container.get_children():
		if node is TagControl:
			tags.append(node.get_tag())
	tags_submitted.emit(tags)
	queue_free()
