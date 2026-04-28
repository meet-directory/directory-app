extends OnboardingStep

@onready var continue_button: Button = %ContinueButton
@onready var dating_types: MarginContainer = %DatingTypes
@onready var friend_button: Button = %FriendButton
@onready var casual_button: Button = %CasualButton
@onready var mono_button: Button = %MonoButton
@onready var poly_button: Button = %PolyButton
@onready var dating_toggle: Button = %DatingToggle

#
#relationship_mask:  bit 0 = Friends & Activities
					#bit 1 = Monogamous Dating
					#bit 2 = Polyamorous Dating
					#bit 3 = Casual / Hookups

enum Relation { FRIENDS = 1, MONO = 2, POLY = 4, CASUAL = 8 }

var toggles:int = 0

func _ready() -> void:
	dating_types.hide()
	custom_minimum_size.x = min(App.get_screen_size().x*6, 400)


func _on_continue_button_pressed() -> void:
	var flags = 0
	if friend_button.button_pressed:
		flags |= Relation.FRIENDS
	if casual_button.button_pressed:
		flags |= Relation.CASUAL
	if poly_button.button_pressed:
		flags |= Relation.POLY
	if mono_button.button_pressed:
		flags |= Relation.MONO
	info_added.emit('relationship_mask', flags)
	
	# TODO only resubmit if there was a change
	Server.update_profile({'relationship_mask': flags}, _on_server_returned)

func _on_server_returned(resp_code, _resp) -> void:
	match resp_code:
		200:
			confirmed.emit()
		_:
			Server.show_default_error_msg(resp_code)


func _on_dating_toggle_toggled(toggled_on: bool) -> void:
	dating_types.visible = toggled_on

func set_continue() -> void:
	continue_button.disabled = !(
		(friend_button.button_pressed and !dating_toggle.button_pressed) or \
		(dating_toggle.button_pressed and (mono_button.button_pressed or poly_button.button_pressed or casual_button.button_pressed))
		)

func _on_button_toggled(_toggled_on: bool) -> void:
	set_continue()
