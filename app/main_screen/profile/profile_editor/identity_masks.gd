extends MarginContainer

@onready var is_woman_button: CheckBox = %IsWomanButton
@onready var is_man_button: CheckBox = %IsManButton
@onready var is_nb_button: CheckBox = %IsNBButton
@onready var is_other_button: CheckBox = %IsOtherButton

@onready var want_woman_button: CheckBox = %WantWomanButton
@onready var want_man_button: CheckBox = %WantManButton
@onready var want_nb_button: CheckBox = %WantNBButton
@onready var want_other_button: CheckBox = %WantOtherButton

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


func get_warnings() -> Array:
	var warnings = []
	if !(is_buttons.any(func (btn:CheckBox): return btn.button_pressed) and want_buttons.any(func (btn:CheckBox): return btn.button_pressed)):
		warnings.append("Must select at least one identity and one open to meeting")
	return warnings

func get_is_mask() -> int:
	var flags = 0
	if is_woman_button.button_pressed:
		flags |= Relation.WOMAN
	if is_man_button.button_pressed:
		flags |= Relation.MAN
	if is_nb_button.button_pressed:
		flags |= Relation.NB
	if is_other_button.button_pressed:
		flags |= Relation.OTHER
	return flags

func get_wants_mask() -> int:
	var flags = 0
	if want_woman_button.button_pressed:
		flags |= Relation.WOMAN
	if want_man_button.button_pressed:
		flags |= Relation.MAN
	if want_nb_button.button_pressed:
		flags |= Relation.NB
	if want_other_button.button_pressed:
		flags |= Relation.OTHER
	return flags

func set_is_mask(flags:int) -> void:
	is_woman_button.button_pressed = flags & Relation.WOMAN
	is_man_button.button_pressed = flags & Relation.MAN
	is_nb_button.button_pressed = flags & Relation.NB
	is_other_button.button_pressed = flags & Relation.OTHER

func set_wants_mask(flags:int) -> void:
	want_woman_button.button_pressed = flags & Relation.WOMAN
	want_man_button.button_pressed = flags & Relation.MAN
	want_nb_button.button_pressed = flags & Relation.NB
	want_other_button.button_pressed = flags & Relation.OTHER
