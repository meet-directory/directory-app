extends Button
class_name ViewProfileButton

var _profile:ProfileResource
@export var show_username:bool = true
var _user_id:int

func _ready() -> void:
	text = ''

func set_user_info(id:int, photo_uri:String = '') -> void:
	_user_id = id
	if photo_uri:
		ObjectStorage.get_texture(photo_uri, _got_photo)

func _got_photo(img:Image) -> void:
	icon = ImageTexture.create_from_image(img)

func setup(profile:ProfileResource) -> void:
	if show_username:
		text = profile.username
	if len(profile.photos) > 0:
		var pp:ProfilePhoto = profile.photos[0]
		if not pp.is_loaded:
			await pp.loaded
		await get_tree().create_timer(0.1).timeout
		icon = pp.texture
	_profile = profile


func _on_pressed() -> void:
	if _profile:
		App.show_profile_preview(_profile, ProfileView.DISPLAY_MODES.only_report_options)
	else:
		Server.get_user_profile(_user_id, _on_got_profile)

func _on_got_profile(resp_code, resp) -> void:
	match resp_code:
		200:
			_profile = ProfileResource.new()
			_profile.from_db(resp)
			App.show_profile_preview(_profile, ProfileView.DISPLAY_MODES.only_report_options)
		_:
			Server.show_default_error_msg(resp_code)
