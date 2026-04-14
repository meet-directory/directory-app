extends VBoxContainer
class_name SearchParamList

#@onready var max_distance_slider: HSlider = $MaxDistance/MaxDistanceSlider
@onready var must_match_tags_container: TagSelectorContainer = %MustMatchTagsContainer
@onready var want_match_tags_container: TagSelectorContainer = %WantMatchTagsContainer
@onready var dont_match_tags_container: TagSelectorContainer = %DontMatchTagsContainer
@onready var age_slider:DoubleSlider = %AgeSlider
@onready var distance_slider:DoubleSlider = %DistanceSlider
@onready var dont_show_seen_check_box: CheckBox = %DontShowSeenCheckBox

# used by the api_server_autoload to make sure we've loaded user preferences before calling the first query
var is_params_retrieved:bool = false
signal params_retrived

func _ready() -> void:
	Server.search_tool = self
	Server.get_user_search_params(_on_retrieved_params)

func _on_retrieved_params(resp_code, resp) -> void:
	match resp_code:
		404:
			pass
		200:
			_populate_params_from_db(resp)
	is_params_retrieved = true
	params_retrived.emit()

func _populate_params_from_db(data:Dictionary) -> void:
	age_slider.low_value = data['min_age']
	age_slider.high_value = data['max_age']
	distance_slider.low_value = data['min_dist']
	distance_slider.high_value = data['max_dist']
	dont_show_seen_check_box.button_pressed = !data.get('include_seen', true)
	
	var tags:Array = data.get('tags', [])
	must_match_tags_container.add_tags(_get_tags_of_type('must', tags))
	want_match_tags_container.add_tags(_get_tags_of_type('optional', tags))
	dont_match_tags_container.add_tags(_get_tags_of_type('must_not', tags))

func _get_tags_of_type(match_type:String, tag_data:Array) -> Array[Tag]:
	var tags:Array[Tag]
	var matched_data = tag_data.filter(func (raw): return raw.get('match_type', '') == match_type)
	tags.assign(matched_data.map(func (raw) -> Tag: 
		var tag:Tag = Tag.new()
		tag.set_type_from_string(raw['tag_type'])
		tag.tag_name = raw.name
		return tag)
		)
	return tags

func get_necessary_tags() -> Array[String]:
	var must_match:Array[Tag] = must_match_tags_container.get_tags()
	var tag_names:Array[String]
	tag_names.assign(must_match.map(get_tag_name))
	#tag_names.append_array(want_match.map(get_tag_name))
	return tag_names

func get_wanted_tags() -> Array[String]:
	var want_match:Array[Tag] = want_match_tags_container.get_tags()
	var tag_names:Array[String]
	tag_names.assign(want_match.map(get_tag_name))
	#tag_names.append_array(want_match.map(get_tag_name))
	return tag_names

func get_html_query_values() -> Dictionary:
	#var max_dist = max_distance_slider.value
	var must_match:Array[Tag] = must_match_tags_container.get_tags()
	var want_match:Array[Tag] = want_match_tags_container.get_tags()
	var dont_match:Array[Tag] = dont_match_tags_container.get_tags()
	
	var parameters = {
		'min_age': int(age_slider.low_value),
		'max_age': int(age_slider.high_value),
		'min_dist': int(distance_slider.low_value),
		'max_dist': int(distance_slider.high_value),
		'must_match': must_match.reduce(reduce_tag_name, ''),
		'must_not_match': dont_match.reduce(reduce_tag_name, ''),
		'optional_match': want_match.reduce(reduce_tag_name, ''),
		'include_seen': !dont_show_seen_check_box.button_pressed
	}
	return parameters

func reduce_tag_name(accum:String, tag:Tag) -> String:
	return accum + tag.tag_name + ','

func get_tag_name(tag:Tag) -> String:
	return tag.tag_name
