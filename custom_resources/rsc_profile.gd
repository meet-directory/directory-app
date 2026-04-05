extends Resource
class_name ProfileResource

@export var username:String
@export var email:String
@export var photos:Array[ProfilePhoto]
@export var description:String
@export var age:int = 0
@export var id:int = -1
@export var suspended:bool
@export var onboarded:bool

@export var messages:Dictionary[String, Message]

## hidden users that have liked you
@export var hidden_likes:Dictionary[String, bool]
## people that have liked you that you also liked
@export var matches:Dictionary[String, bool]
## people that liked you and allowed you to view the like without waiting for a match
@export var public_likes:Dictionary[String, bool]

@export var location:Array[float] # longlat

enum match_statuses {none, accepted, pending, rejected}
var match_status_tx:Dictionary[String, match_statuses] = {
	'accepted': match_statuses.accepted,
	'none': match_statuses.none,
	'pending': match_statuses.pending,
	'rejected': match_statuses.rejected
}
var match_status:match_statuses

@export var is_tags:Array[Tag]
@export var wants_tags:Array[Tag] # DEPR?

var example = '{ "user_id": 8.0, "data": { "age": 35.0, "bio": "Dummy user 0 this is my bio lorem ipsum dolor", "photos": ["https://example.com/photos/rakdbsgs.jpg", "https://example.com/photos/zzberuiz.jpg", "https://example.com/photos/vwvucixr.jpg"], "tags": { "is": { "interests": ["dnd", "hiking"], "personal": ["woman", "bi"], "sexual": ["threesom", "FFM", "MMF"] }, "wants": { "relationship_type": ["casual", "polyamorous"] } }, "username": "user_0" } }'

func to_db() -> Dictionary:
	var data:Dictionary = {
		"data": {
			"username": username,
			"age": age,
			"bio": description,
			},
		"tags": is_tags.reduce(func (accum:String, tag:Tag):
			return accum + tag.tag_name + ','
			, '')
	}
	return data

func from_db(dict:Dictionary):
	var data:Dictionary
	if dict.has('data'):
		data = dict['data']
	else:
		data = dict
	
	onboarded = data.get('onboarded', true)
	
	var image_urls = dict.get('image_uris', [])
	if true:
		for i in len(image_urls):
			if len(photos) < i+1:
				photos.append(ProfilePhoto.new())
			photos[i].set_url(image_urls[i])
	
	# All of these fields MUST be present in the data, default values are only provided
	# in case onboarding was started but no profile data was sent yet.
	username = data.get('username', '')
	age = dict.get('age', 0)
	description = data.get('bio', '')
	id = dict['user_id']
	suspended = dict.get('suspend_status', true)
	
	if data.has('email'):  # only present for the logged-in user
		email = data['email']
	
	match_status = match_status_tx[dict.get('match_status', 'none')]
	
	var raw_tags:Array = dict.get('tags', [])
	is_tags.assign(raw_tags.map(func (raw): 
		var tag = Tag.new()
		tag.tag_name = raw['name']
		tag.set_type_from_string(raw['tag_type'])
		return tag
		)
	)
