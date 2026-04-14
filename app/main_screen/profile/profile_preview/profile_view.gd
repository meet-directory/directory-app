extends Control
class_name ProfileView

@onready var name_label: Label = %NameLabel
@onready var description_label: Label = %DescriptionLabel
@onready var photo_viewer: PhotoViewer = %PhotoViewer

@onready var relationship_tags: TagContainer = %RelationshipTags
@onready var desire_tags: TagContainer = %DesireTags
@onready var other_tags: TagContainer = %OtherTags
@onready var personal_tags: TagContainer = %PersonalTags
@onready var match_options: MarginContainer = %MatchOptions
@onready var age_label: Label = %AgeLabel
@onready var report_menu: MarginContainer = %ReportMenu
@onready var location_label: Label = %LocationLabel
@onready var location_panel: MarginContainer = %LocationPanel

var profile_data:ProfileResource

enum DISPLAY_MODES {
	no_options, 		# no actions to perform on this user (used to display a user's own profile)
	all_options, 		# Like, report, or block this user
	only_report_options	# Users that are already liked or matched only show report and block options
	}
var display_mode:DISPLAY_MODES

func set_display_mode(mode:DISPLAY_MODES) -> void:
	display_mode = mode
	match mode:
		DISPLAY_MODES.no_options:
			report_menu.hide()
		DISPLAY_MODES.all_options:
			match_options.visible = true
		DISPLAY_MODES.only_report_options:
			match_options.visible = false

signal user_blocked

func _ready() -> void:
	call_deferred("set_sizing")
	custom_minimum_size.x = App.PROFILE_VIEW_WIDTH

func set_sizing():
	### Ensure the name is always visible, even on small displays
	### if the photo viewer takes up the whole screen, there is no place to grab
	### to scroll and see the rest of the profile.
	### Likewise the photoviewer size control flags should never be set to EXPAND.
	var y = photo_viewer.get_parent().size.x*1.2 # photo_viewer.get_parent().size.x - name_padding)
	photo_viewer.custom_minimum_size.y = y

func display(profile:ProfileResource, must_have_tags:Array[String]=[], wanted_tags:Array[String]=[]) -> void:
	profile_data = profile
	match_options.setup_for_profile(profile_data)
	name_label.text = profile.username
	description_label.text = profile.description
	age_label.text = str(profile.age)
	location_label.text = profile.loc_string
	if profile.loc_string.is_empty():
		location_panel.hide()
	
	var rtags = profile.is_tags.filter(func (t:Tag): return t.type == Tag.TYPE.RelationshipType)
	if len(rtags) > 0:
		relationship_tags.add_tags(rtags)
	else:
		relationship_tags.hide()
	var ptags = profile.is_tags.filter(func (t:Tag): return t.type == Tag.TYPE.Personal)
	if len(ptags) > 0:
		personal_tags.add_tags(ptags)
	else:
		personal_tags.hide()
	desire_tags.add_tags(profile.is_tags.filter(func (t:Tag): return t.type == Tag.TYPE.Intimacy))
	other_tags.add_tags(profile.is_tags.filter(func (t:Tag): return t.type not in [Tag.TYPE.Personal, Tag.TYPE.RelationshipType]))
	
	var tag_containers:Array[TagContainer] = [relationship_tags, personal_tags, desire_tags, other_tags]
	
	for tag_container in tag_containers:
		tag_container.show_matched_tags(must_have_tags)
		tag_container.show_matched_tags(wanted_tags)
	
	photo_viewer.setup(profile.photos)



func _on_block_user_button_user_blocked() -> void:
	user_blocked.emit()
