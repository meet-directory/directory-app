extends OnboardingStep

@onready var is_woman_button: CheckBox = %IsWomanButton
@onready var is_man_button: CheckBox = %IsManButton
@onready var is_nb_button: CheckBox = %IsNBButton
@onready var is_other_button: CheckBox = %IsOtherButton

@onready var want_woman_button: CheckBox = %WantWomanButton
@onready var want_man_button: CheckBox = %WantManButton
@onready var want_nb_button: CheckBox = %WantNBButton
@onready var want_other_button: CheckBox = %WantOtherButton
@onready var continue_button: Button = %ContinueButton

#
#identity_mask:      bit 0 = Woman
					#bit 1 = Man
					#bit 2 = Non-binary
					#bit 3 = Something else

enum Relation { WOMAN = 1, MAN = 2, NB = 4, OTHER = 8 }

var is_buttons:Array[CheckBox]
var want_buttons:Array[CheckBox]

func _ready() -> void:
	is_buttons = [is_woman_button, is_man_button, is_nb_button, is_other_button]
	want_buttons = [want_woman_button, want_man_button, want_nb_button, want_other_button]
	for button in is_buttons:
		button.toggled.connect(_on_button_toggled)
	for button in want_buttons:
		button.toggled.connect(_on_button_toggled)

func _on_button_toggled(_toggled_on) -> void:
	continue_button.disabled = !(is_buttons.any(func (btn:CheckBox): return btn.button_pressed) and want_buttons.any(func (btn:CheckBox): return btn.button_pressed))

func _on_continue_button_pressed() -> void:
	var flags = 0
	if is_woman_button.button_pressed:
		flags |= Relation.WOMAN
	if is_man_button.button_pressed:
		flags |= Relation.MAN
	if is_nb_button.button_pressed:
		flags |= Relation.NB
	if is_other_button.button_pressed:
		flags |= Relation.OTHER
	info_added.emit('is_mask', flags)
	
	var want_flags = 0
	if want_woman_button.button_pressed:
		want_flags |= Relation.WOMAN
	if want_man_button.button_pressed:
		want_flags |= Relation.MAN
	if want_nb_button.button_pressed:
		want_flags |= Relation.NB
	if want_other_button.button_pressed:
		want_flags |= Relation.OTHER
	info_added.emit('want_mask', want_flags)
	
	# TODO only resubmit if there was a change
	Server.update_profile({'identity_mask': flags, 'seeking_mask': want_flags}, _on_server_returned)

func _on_server_returned(resp_code, _resp) -> void:
	match resp_code:
		200:
			confirmed.emit()
		_:
			Server.show_default_error_msg(resp_code)
