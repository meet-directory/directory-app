extends MarginContainer
@onready var button_container: VBoxContainer = %ButtonContainer
@onready var category_h_flow: HFlowContainer = %CategoryHFlow
@onready var specific_h_flow: HFlowContainer = %SpecificHFlow
@onready var back_button: Button = %BackButton

signal tag_tapped(tag:Tag)
var filters:Array[Tag.TYPE] = []

func _ready() -> void:
	reset()

func reset() -> void:
	for node in button_container.get_children():
		node.queue_free()
	
	back_button.hide()
	for node in category_h_flow.get_children():
		node.queue_free()
	for node in specific_h_flow.get_children():
		node.queue_free()
	#for b in button_container.get_children():
		#b.show()
		#b.disabled = false
		
	if owner is TagSelectorPopup:
		filters = owner.filter_white_list
	for category in Tag.raw_to_type.keys():
		var button:Button = Button.new()
		button_container.add_child(button)
		button.mouse_filter = Control.MOUSE_FILTER_PASS # allows tap to scroll by passing tap input to scroll container
		var type:Tag.TYPE = Tag.raw_to_type[category]
		
		var style = Constants.tag_styleboxes[type]
		var color:Color = Constants.tag.get_color(type)
		var hover_style:StyleBoxFlat = style.duplicate()
		hover_style.bg_color = color.darkened(-0.1)
		var pressed_style:StyleBoxFlat = style.duplicate()
		pressed_style.bg_color = color.darkened(0.2)
		var disabled_style:StyleBoxFlat = style.duplicate()
		disabled_style.bg_color = color.blend(Color(0.74, 0.74, 0.74, 0.537)).darkened(0.4)
		button.add_theme_stylebox_override("normal", style)
		button.add_theme_stylebox_override("hover", hover_style)
		button.add_theme_stylebox_override("pressed", pressed_style)
		button.add_theme_stylebox_override("disabled", disabled_style)
		button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		
		var emoji:String = Constants.tag.get_emoji(type)
		button.text = emoji + ' ' + category
		button.pressed.connect(_on_category_selected.bind(category, button))
		
		if !filters.is_empty() and !(type in filters):
			button.disabled = true

func _on_category_selected(tag_type:String, button:Control) -> void:
	Server.get_tags_of(tag_type, _got_db_tags.bind(button))
	

func _got_db_tags(resp_code, resp, button:Button) -> void:
	if resp_code == 200:
		back_button.show()
		for b in button_container.get_children():
			b.hide()
		button.show()
		button.disabled = true
		var disabled_tags:Array[String] = []
		if owner is TagSelectorPopup:
			disabled_tags.assign(owner.forbidden_tags.map(func (tag:Tag): return tag.tag_name))
		for row in resp:
			var cat = row['level'].to_lower()
			var n = row['name']
			var tag_type = row['tag_type']
			var tag:TagControl = App.create_new_tag_scene()
			if cat == 'category':
				category_h_flow.add_child(tag)
			else:
				specific_h_flow.add_child(tag)
			tag.set_text(n)
			tag.set_type_raw(tag_type)
			if owner is TagSelectorPopup:
				owner.tag_deselected.connect((func (d_tag_name, t): if t and t.get_tag_name() == d_tag_name: t.enable()).bind(tag))
			if tag.get_tag_name() in disabled_tags:
				tag.disable()
			tag.tapped.connect(_on_tag_tapped.bind(tag))
	else:
		Server.show_default_error_msg(resp_code)


func _on_tag_tapped(tag:Tag, tag_control:TagControl):
	tag_tapped.emit(tag)
	tag_control.disable()
	

func _on_back_button_pressed() -> void:
	reset()

#func reset():
	#back_button.hide()
	#for node in category_h_flow.get_children():
		#node.queue_free()
	#for node in specific_h_flow.get_children():
		#node.queue_free()
	#for b in button_container.get_children():
		#b.show()
		#b.disabled = false
	#
	#if !(type in filters):
		#button.disabled = true
