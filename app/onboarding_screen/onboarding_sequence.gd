extends Control

@export var sequence:Array[PackedScene]
var index = 0
@onready var underlay: Control = %Underlay

func _ready() -> void:
	var current_scene = sequence[index].instantiate()
	current_scene.confirmed.connect(_step_done)
	underlay.add_child(current_scene)
	index += 1
	if Server.session_profile:
		_resume_onboarding()
	
	# temp disabled
	#if !LocationService.is_in_north_carolina():
		#var msg = "We detected that you are in {}. Unfortunately this service \
		#is currently only available in North Carolina, USA. If you think this \
		#is in error or are interested in us coming to your area, please contact us!".format([LocationService.city_str], "{}")
		#var popup:InfoPopup = App.show_info_popup(msg)
		#await popup.closed
		#_account_canceled()

func _step_done(variable:Variant):
	for node in underlay.get_children():
		node.queue_free()
	
	var next_scene = sequence[index].instantiate()
	next_scene.confirmed.connect(_step_done)
	next_scene.set_passed_arg(variable)
	underlay.add_child(next_scene)
	index +=1

func _resume_onboarding():
	index = len(sequence) - 1
	_step_done(null)


func _on_back_button_pressed() -> void:
	print('index ', index)
	if index < 3:
		var conf:ConfirmationPopup = App.show_conf_popup("Cancel Account Creation?")
		conf.confirm_pressed.connect(_account_canceled)
	elif index == 3:
		var conf:ConfirmationPopup = App.show_conf_popup("Return to login screen?")
		conf.confirm_pressed.connect(_account_canceled)

func _account_canceled() -> void:
	Server.logout()
	App.show_login_screen()
