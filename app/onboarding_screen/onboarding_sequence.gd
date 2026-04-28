extends Control

@export var sequence:Array[PackedScene]
@export var progress_panel_complete:StyleBoxFlat
@export var progress_panel_incomplete:StyleBoxFlat

var index = 0
@onready var underlay: Control = %Underlay
@onready var scroll_container: MobileScrollContainer = %ScrollContainer
@onready var progress_panels: HBoxContainer = %ProgressPanels


var onboarding_data:Dictionary

func _ready() -> void:
	for child in progress_panels.get_children():
		child.queue_free()
	for i in range(sequence.size()):
		var panel:Panel = Panel.new()
		panel.custom_minimum_size.x = 20
		if i == 0:
			panel.add_theme_stylebox_override('panel', progress_panel_complete)
		else:
			panel.add_theme_stylebox_override('panel', progress_panel_incomplete)
		progress_panels.add_child(panel)
	
	_step_done()
	if Server.session_profile:
		_resume_onboarding()

func _step_done():
	for node in underlay.get_children():
		node.queue_free()
	
	_mark_step_complete(index)
	
	var next_scene:OnboardingStep = sequence[index].instantiate()
	next_scene.confirmed.connect(_step_done)
	next_scene.info_added.connect(_add_data)
	next_scene.onboarding_data = onboarding_data
	underlay.add_child(next_scene)
	scroll_container.update()
	Server.set_onboard_step(index, func (_x, _y): return)
	index += 1

func _mark_step_complete(step_index:int) -> void:
	(progress_panels.get_child(step_index) as Panel).add_theme_stylebox_override('panel', progress_panel_complete)

func _add_data(key:String, data:Variant) -> void:
	onboarding_data[key] = data

func _resume_onboarding():
	# get index from server and resume
	Server.get_onboard_step(_on_onboard_step_received)

func _on_onboard_step_received(resp_code, data) -> void:
	match resp_code:
		200:
			index = data['step']
			for i in range(index):
				_mark_step_complete(i)
			_step_done()
		_:
			Server.show_default_error_msg(resp_code)


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
