#@tool
extends Button
class_name MobileDropDown

signal item_selected(index:int)

@export var selected:int = -1: # TODO clamp between -1 and the number of items
	set(value):
		# unhighlight the current item
		(option_list.get_child(selected) as Button).disabled = false
		selected = value
		text = get_item_text(selected)
@export var fit_to_longest_item:bool = true
#@export var allow_reselect:bool = false
@export_subgroup("Appearance")
@export_range(0, 100) var item_separation:int = 0
@export var style_pressed:StyleBox = preload("res://addons/mobile_option_dropdown/default_styles/pressed.tres")
@export var style_normal:StyleBox = preload("res://addons/mobile_option_dropdown/default_styles/normal.tres")
@export var style_hover:StyleBox = preload("res://addons/mobile_option_dropdown/default_styles/hover.tres")
@export var style_disabled:StyleBox = preload("res://addons/mobile_option_dropdown/default_styles/disabled.tres")
@export var style_focus:StyleBox = preload("res://addons/mobile_option_dropdown/default_styles/focus.tres")
@export_subgroup("Items")
@export var items:Array[String]

const arrow_down = "res://addons/mobile_option_dropdown/arrow_down.svg"

var control
var option_list: VBoxContainer
var popup:Popup

func _ready() -> void:
	icon = load(arrow_down)
	icon_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	if Engine.is_editor_hint():
		pass
	else:
		# 1. set up base node structure
		# button
		# `- popup
		#    `- margin_container
		#       `- panel
		#       `- scroll_container
		#          `- option_list (VBoxContainer)
		#             `- (buttons go here)
		control = Control.new()
		var panel = Panel.new()
		option_list = VBoxContainer.new()
		var sc = ScrollContainer.new()
		var mc = MarginContainer.new()
		popup = Popup.new()
		control.layout_mode = 1
		control.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		mc.layout_mode = 1
		mc.set_anchors_preset(Control.PRESET_FULL_RECT)
		
		add_child(control)
		control.add_child(popup, false, Node.INTERNAL_MODE_FRONT)
		popup.add_child(mc)
		mc.add_child(panel)
		mc.add_child(sc)
		sc.add_child(option_list)
		
		option_list.add_theme_constant_override('separation', item_separation - 1)
		
		toggle_mode = true
		toggled.connect(_on_toggled)
		option_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		#popup.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_MAX
		# ensure button is unpressed whenever the menu gets hiden
		popup.popup_hide.connect(func (): 
			button_pressed = false
			_on_toggled(false)
			)
		action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS  # prevent reopening when the base button is pressed
		
		# 2. add options
		#if option_list.is_node_ready():
			#await option_list.ready
		for i in range(len(items)):
			_add_item_button(i)
		
		select(selected)
		
		# Wait one frame so that they render and we can get the correct sizing
		popup.show()
		await get_tree().process_frame
		var max_size = 0
		for node in option_list.get_children():
			if max_size < node.size.x:
				max_size = node.size.x
		max_size += 10 # a little extra padding prevents horizontal scroll
		
		
		if fit_to_longest_item:
			custom_minimum_size.x = max_size
		
		popup.hide()

func _add_item_button(index:int=-1) -> void:
	if index < 0:
		index = len(items) - 1  # append to end
	var node:Button = Button.new()
	option_list.add_child(node)
	node.mouse_filter = Control.MOUSE_FILTER_PASS  # allow scroll event from tap to reach the scrollcontainer
	node.text = items[index]
	node.alignment = HORIZONTAL_ALIGNMENT_LEFT
	node.pressed.connect(_on_new_option_selected.bind(index, node.text))
	node.add_theme_stylebox_override("normal", style_normal)
	node.add_theme_stylebox_override("pressed", style_pressed)
	node.add_theme_stylebox_override("hover", style_hover)
	node.add_theme_stylebox_override("focus", style_focus)
	node.add_theme_stylebox_override("disabled", style_disabled)

func _show_popup():
	popup.position = control.global_position
	
	if popup.size.x < size.x:
		popup.size.x = size.x
	
	# disable the current selection
	(option_list.get_child(selected) as Button).disabled = true
	
	# ensure popup doesn't go off screen and uses scrollbox instead
	var option_rect:Rect2 = option_list.get_rect()
	var vp_rect:Rect2 = get_viewport().get_visible_rect()
	var rect_bottom = popup.position.y + option_rect.size.y
	var rect_right = popup.position.x + popup.size.x
	
	if rect_bottom > vp_rect.size.y:
		var overflow = rect_bottom - vp_rect.size.y
		popup.size.y = int(option_rect.size.y - overflow)
	else:
		popup.size.y = int(option_list.size.y)
	
	if rect_right > vp_rect.size.x:
		var overflow = rect_right - vp_rect.size.x
		popup.position.x = int(popup.position.x - overflow)

func _on_new_option_selected(index:int, item:String) -> void:
	selected = index
	item_selected.emit(index)
	popup.hide()
	text = item
	button_pressed = false
	_on_toggled(false)

func _on_toggled(toggled_on:bool) -> void:
	popup.visible = toggled_on
	if toggled_on:
		_show_popup()

################# public api #############################
func clear() -> void:
	items = []
	for node in option_list.get_children():
		node.queue_free()

func select(index:int) -> void:
	if index > -1 and index < len(items):
		_on_new_option_selected(index, items[index])

func add_item(item_text:String) -> void:
	items.append(item_text)
	_add_item_button()

func get_item_text(index:int) -> String:
	return (option_list.get_child(index) as Button).text

# just for compatability with OptionButton, don't actually support ids separate from order yet
func get_item_id(index:int) -> int:
	return index
