extends MarginContainer
class_name ProfileEditor

#@onready var relationship_tags: TagSelectorContainer = %WantsTags
#@onready var desire_tags: TagSelectorContainer = %DesireTags
#@onready var other_tags: TagSelectorContainer = %OtherTags
#@onready var personal_tags: TagSelectorContainer = %PersonalTags
@onready var tag_container: TagSelectorContainer = %Tags

@onready var name_edit: LineEdit = %NameEdit
@onready var description_edit: MaxLengthTextEdit = %DescriptionEdit
@onready var photo_viewer: PhotoViewer = %PhotoViewer
@onready var edit_profile_container: Control = %EditProfileContainer
@onready var edit_photos_container: ScrollContainer = %EditPhotosContainer
@onready var photo_editor: MarginContainer = %PhotoEditor

signal edit_saved
signal edit_canceled

#func _ready() -> void:
	#Server.user_session_loaded.connect(_on_profile_loaded)

func display(profile:ProfileResource) -> void:
	name_edit.text = profile.username
	description_edit.set_text(profile.description)
	photo_viewer.setup(profile.photos)
	photo_editor.setup(profile.photos)
	#for child in photo_viewer.get_children():
		#child.queue_free()
	#for texture in profile.photos:
		#var rect:TextureRect = TextureRect.new()
		#rect.texture = texture
		#photo_viewer.add_child(rect)
	
	#personal_tags.add_tags(profile.is_tags.filter(func (t:Tag): return t.type == Tag.TYPE.Personal))
	#relationship_tags.add_tags(profile.is_tags.filter(func (t:Tag): return t.type == Tag.TYPE.RelationshipType))
	#desire_tags.add_tags(profile.is_tags.filter(func (t:Tag): return t.type == Tag.TYPE.Desire))
	#other_tags.add_tags(profile.is_tags.filter(func (t:Tag): return t.type not in [Tag.TYPE.Personal, Tag.TYPE.RelationshipType]))
	tag_container.add_tags(profile.is_tags)
	


func get_edited_profile() -> ProfileResource:
	var prof:ProfileResource = ProfileResource.new()
	prof.username = name_edit.text
	prof.description = description_edit.get_text()
	prof.is_tags = tag_container.get_tags()
	#prof.is_tags = personal_tags.get_tags()
	#prof.is_tags.append_array(relationship_tags.get_tags())
	##prof.is_tags.append_array(desire_tags.get_tags())
	#prof.is_tags.append_array(other_tags.get_tags())
	return prof


func _on_show_to_matches_check_button_toggled(toggled_on: bool) -> void:
	# TODO mark this as hidden in the db and add to profileresource
	pass # Replace with function body.


func _on_edit_photos_button_pressed() -> void:
	# TODO animation
	edit_photos_container.show()
	edit_profile_container.hide()
	#Server.get_session_profile()

#func _on_profile_loaded(prof:ProfileResource) -> void:


func _on_photo_editor_editing_finished() -> void:
	edit_photos_container.hide()
	edit_profile_container.show()
	Server.get_session_profile()

# session is only reloaded when we change photos, so want to refresh the photos
func _ready() -> void:
	Server.user_session_loaded.connect(_on_session_profile_loaded)
	call_deferred("set_sizing")
	custom_minimum_size.x = App.PROFILE_VIEW_WIDTH
	

func set_sizing():
	### Ensure the name is always visible, even on small displays
	### if the photo viewer takes up the whole screen, there is no place to grab
	### to scroll and see the rest of the profile.
	### Likewise the photoviewer size control flags should never be set to EXPAND.
	var y = photo_viewer.get_parent().size.x*.8
	photo_viewer.custom_minimum_size.y = y

func _on_session_profile_loaded(profile:ProfileResource) -> void:
	photo_viewer.setup(profile.photos)
	photo_editor.setup(profile.photos)


func _on_cancel_edit_button_pressed() -> void:	
	edit_canceled.emit()

# TODO can save a request by checking if there are actually any changes before submitting to db
func _on_save_edit_button_pressed() -> void:
	var tags = tag_container.get_tags()
	if len(tags) < Constants.MIN_REQUIRED_PROFILE_TAGS:
		var warning = "Your profile must have at least {} tags.".format([Constants.MIN_REQUIRED_PROFILE_TAGS], '{}')
		App.show_info_popup(warning)
		return
	
	var rtags = len(tags.filter(func (tag:Tag): return tag.type == Tag.TYPE.RelationshipType))
	var ptags = len(tags.filter(func (tag:Tag): return tag.type == Tag.TYPE.Personal))
	
	if name_edit.text == "":
		var warning = "Your profile must have a username!"
		App.show_info_popup(warning)
		return
	
	if rtags < 1 or ptags < 2:
		var warning:String
		
		if rtags < 1 and ptags < 2:
			warning = 'We recommend adding at least one Relationship tag and ' \
			+ "two Personal tags so that other users know what kind of relationship you're looking for." 
		elif rtags < 1:
			warning = 'We recommend adding at least one Relationship tag so ' \
			+ "that other users know what kind of relationship you're looking for." 
		elif ptags < 2:
			warning = 'We recommend adding at least two Personal tags to ' \
			+ "improve the likelihood of other people finding you. If you are using " \
			+ "the app to date, add your gender and sexuality." 
		
		var conf:ConfirmationPopup = App.show_conf_popup(warning, "Keep Editing", "Save Anyway")
		conf.confirm_pressed.connect(_save_profile)
	else:
		_save_profile()

func _save_profile() -> void:
	Server.update_profile(get_edited_profile().to_db(), _on_profile_saved_to_db)
	

func _on_profile_saved_to_db(resp_code:int, _response) -> void:
	match resp_code:
		200:
			edit_saved.emit()
		_: Server.show_default_error_msg(resp_code)

		
