extends Resource
class_name Tag

@export var tag_name:String
enum TYPE {
	Personal, 
	RelationshipType, 
	Desire,
	Other,
	Outdoors,
	Sport,
	Movies,
	TvShows,
	Music,
	Games,
	Diet,
	Religion,
	Art,
	Reading,
	Politics,
	}

const raw_to_type:Dictionary[String, TYPE] = {
	'personal': TYPE.Personal,
	'relationship': TYPE.RelationshipType,
	'sex': TYPE.Desire,
	'outdoors': TYPE.Outdoors,
	'sport': TYPE.Sport,
	'movies': TYPE.Movies,
	'tv-shows': TYPE.TvShows,
	'music': TYPE.Music,
	'games': TYPE.Games,
	'diet': TYPE.Diet,
	'religion': TYPE.Religion,
	'art': TYPE.Art,
	'reading': TYPE.Reading,
	'politics': TYPE.Politics,
	'other': TYPE.Other,
}
@export var type:TYPE

const _media_color = Color("7995b7ff")
# enum is used as an index to the character
const type_to_emoji = [
	['🧍', Color("c0a895ff")],
	['💑', Color("be8359ff")],
	['😏', Color("b594adff")],
	['⭐', Color("7a97a7ff")],
	['🌳', Color("829989ff")],
	['🏋️‍♀️', Color("cc6672ff")],
	['🎥', _media_color],
	['📺', _media_color],
	['🎵', _media_color],
	['🎮', _media_color],
	['🥕', Color(0.698, 0.531, 0.451, 1.0)],
	['🕋', Color(0.459, 0.606, 0.606, 1.0)],
	['🎨', Color(0.73, 0.703, 0.496, 1.0)],
	['📖', _media_color],
	['🌐', Color(0.477, 0.594, 0.654, 1.0)]
	]


#var type_to_emoji:Dictionary[TYPE, String] = {
	#TYPE.Personal: "🧍",
	#TYPE.RelationshipType: "",
	#TYPE.Desire: "",
	#TYPE.Other: ""
#}

func get_emoji(tag_type:TYPE = type) -> String:
	return type_to_emoji[tag_type][0]

func get_color(tag_type:TYPE = type) -> Color:
	return type_to_emoji[tag_type][1]

func get_string_from_type(t:TYPE) -> String:
	return raw_to_type.find_key(t)

func get_type_from_string(raw:String) -> TYPE:
	return raw_to_type.get(raw, TYPE.Other)

func set_type_from_string(raw:String) -> void:
	type = raw_to_type.get(raw, TYPE.Other)
