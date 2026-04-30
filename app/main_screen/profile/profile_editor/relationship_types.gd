extends MarginContainer


@onready var dating_types: MarginContainer = %DatingTypes
@onready var friend_button: Button = %FriendButton
@onready var casual_button: Button = %CasualButton
@onready var mono_button: Button = %MonoButton
@onready var poly_button: Button = %PolyButton
@onready var dating_toggle: Button = %DatingToggle


#relationship_mask:  bit 0 = Friends & Activities
					#bit 1 = Monogamous Dating
					#bit 2 = Polyamorous Dating
					#bit 3 = Casual / Hookups

enum Relation { FRIENDS = 1, MONO = 2, POLY = 4, CASUAL = 8 }

var toggles:int = 0

func _ready() -> void:
	dating_types.hide()
	dating_toggle.toggled.connect(_on_dating_toggle_toggled)
	#custom_minimum_size.x = min(App.get_screen_size().x*6, 400)

func _on_dating_toggle_toggled(toggled_on: bool) -> void:
	dating_types.visible = toggled_on

func get_warnings():
	var warnings = []
	if dating_toggle.button_pressed and !(mono_button.button_pressed or poly_button.button_pressed or casual_button.button_pressed):
		warnings.append("If dating is selected, you must select a dating type.")
	elif !dating_toggle.button_pressed and !friend_button.button_pressed:
		warnings.append("You must select at least one relationship type.")
	return warnings

func get_mask() -> int:
	var flags = 0
	if friend_button.button_pressed:
		flags |= Relation.FRIENDS
	if dating_toggle.button_pressed:
		if casual_button.button_pressed:
			flags |= Relation.CASUAL
		if poly_button.button_pressed:
			flags |= Relation.POLY
		if mono_button.button_pressed:
			flags |= Relation.MONO
	return flags

func set_mask(flags:int) -> void:
	friend_button.button_pressed = flags & Relation.FRIENDS
	poly_button.button_pressed = flags & Relation.POLY
	mono_button.button_pressed = flags & Relation.MONO
	casual_button.button_pressed = flags & Relation.CASUAL
	dating_toggle.button_pressed = (mono_button.button_pressed or poly_button.button_pressed or casual_button.button_pressed)
