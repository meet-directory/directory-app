extends Resource
class_name Tag

@export var tag_name:String
enum TYPE {
	Personal, 
	RelationshipType, 
	Intimacy,
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
	'intimacy': TYPE.Intimacy,
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
	['🧍', Color("b3ac7dff")],  # identity
	['💑', Color("b38f7dff")],  # relationship
	['😏', Color("b594adff")],  # intimacy
	['⭐', Color("7a8e99ff")],  # other
	['🌳', Color("7db38eff")],  # outdoors
	['🏋️‍♀️', Color("b37d82ff")],  # sports
	['🎥', Color("7995b7ff")],  # movie
	['📺', Color("7995b7ff")],  # tv
	['🎵', Color("8a94b8ff")],  # music
	['🎮', Color("7995b7ff")],  # games
	['🥕', Color("a78763ff")],  # diet  
	['🕋', Color("8988b9ff")],  # religion
	['🎨', Color("9bb1c6ff")],  # art
	['📖', Color("7995b7ff")],  # literature
	['🌐', Color("6089aeff")]   # politics
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
