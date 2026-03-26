extends Control
@onready var search_bar: LineEdit = %SearchBar
@onready var tag_list: VBoxContainer = %TagList

@export var max_results:int

signal text_changed(new_text:String)

var _time_since_last_char:float = 0
var search_delay = 0.2

signal got_results(exact_match:bool)

func _ready() -> void:
	search_bar.text_changed.connect(_on_search_bar_text_changed)

#func get_text() -> String:
	#return search_bar.text

func _process(delta: float) -> void:
	if _time_since_last_char > 0:
		_time_since_last_char -= delta

func _on_search_bar_text_changed(new_text: String) -> void:
	text_changed.emit(new_text)
	if new_text.is_empty():
		return
	var last_char = new_text[-1]
	if last_char in Constants.TAG_ALLOWED_CHARS:
		_time_since_last_char = search_delay
		# Query server for tags simliar to text
		Server.fuzzy_search_tags(new_text, _on_search_returned.bind(new_text))
	else:
		search_bar.text = new_text.left(len(new_text)-1)
		search_bar.caret_column = len(new_text)


func _on_search_returned(_resp_code, data, search_text) -> void:
	var is_match:bool = false
	# reset state
	for child in tag_list.get_children():
		child.queue_free()
		# add tags
	if data:
		for i in range(len(data)):
			if max_results > 0 and i + 1 > max_results:
				got_results.emit(is_match)
				return
			
			var row = data[i]
			var tag:TagControl = App.create_new_tag_scene()
			
			var tag_raw_name:String = row['name']
			var tag_raw_type:String = row['tag_type']
			
			tag_list.add_child(tag)
			tag.set_text(tag_raw_name)
			tag.set_type_raw(tag_raw_type)
			
			# IMPR: technically we only need to check the first row returned, would be more efficient?
			if search_text == tag_raw_name:
				is_match = true
	
	got_results.emit(is_match)
		
		#if search_text_found:
			#create_tag_container.hide()
		#else:
			#create_tag_container.show()
			#not_found_tag.set_text(search_text)
			#not_found_tag.set_type(tag_type_filter)
			
