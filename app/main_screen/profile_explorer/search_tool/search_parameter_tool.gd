extends VBoxContainer
class_name SearchParamList

#@onready var max_distance_slider: HSlider = $MaxDistance/MaxDistanceSlider
@onready var must_match_tags_container: TagSelectorContainer = %MustMatchTagsContainer
@onready var want_match_tags_container: TagSelectorContainer = %WantMatchTagsContainer
@onready var dont_match_tags_container: TagSelectorContainer = %DontMatchTagsContainer
@onready var age_slider: DoubleSlider = %AgeSlider
@onready var distance_slider: DoubleSlider = %DistanceSlider
@onready var dont_show_seen_check_box: CheckBox = %DontShowSeenCheckBox


func _ready() -> void:
	Server.search_tool = self

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
		'min_age': int(age_slider.get_low_value()),
		'max_age': int(age_slider.get_high_value()),
		'min_dist': 0,
		'max_dist': 200,
		#'min_dist': int(distance_slider.get_low_value()),
		#'max_dist': int(distance_slider.get_high_value()),
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


func _on_double_slider_value_changed(min_val: float, max_val: float) -> void:
	pass # Replace with function body.
