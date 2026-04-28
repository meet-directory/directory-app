extends MarginContainer
@onready var friend_button: Control = %FriendButton
@onready var casual_button: Control = %CasualButton
@onready var mono_button: Control = %MonoButton
@onready var poly_button: Control = %PolyButton

enum Relation { FRIENDS = 1, MONO = 2, POLY = 4, CASUAL = 8 }


func set_mask(flags:int) -> void:
	friend_button.visible = flags & Relation.FRIENDS
	poly_button.visible = flags & Relation.POLY
	mono_button.visible = flags & Relation.MONO
	casual_button.visible = flags & Relation.CASUAL
