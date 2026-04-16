extends Control

@export var sequence:Array[PackedScene]
var index = 0
@onready var underlay: Control = %Underlay
@onready var scroll_container: MobileScrollContainer = %ScrollContainer

func _ready() -> void:
	var current_scene = sequence[index].instantiate()
	current_scene.confirmed.connect(_step_done)
	underlay.add_child(current_scene)
	scroll_container.update()
	index += 1
	if Server.session_profile:
		_resume_onboarding()

func _step_done(variable:Variant):
	for node in underlay.get_children():
		node.queue_free()
	
	var next_scene = sequence[index].instantiate()
	next_scene.confirmed.connect(_step_done)
	next_scene.set_passed_arg(variable)
	underlay.add_child(next_scene)
	scroll_container.update()
	index +=1

func _resume_onboarding():
	index = len(sequence) - 1
	_step_done(null)


func _on_back_button_pressed() -> void:
	if index < 3:
		var conf:ConfirmationPopup = App.show_conf_popup("Cancel Account Creation?", "No", "Yes")
		conf.confirm_pressed.connect(_account_canceled)
	elif index == 3:
		var conf:ConfirmationPopup = App.show_conf_popup("Return to login screen?", "No", "Yes")
		conf.confirm_pressed.connect(_account_canceled)

func _account_canceled() -> void:
	Server.logout()
	App.show_login_screen()
