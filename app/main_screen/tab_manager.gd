extends HBoxContainer

signal tab_pressed(index:int)

@export var current_tab:int = 0

func _ready() -> void:
	for i in get_child_count():
		var child:Button = get_child(i)
		child.pressed.connect(_on_tab_pressed.bind(i))
	get_child(current_tab).button_pressed = true
	
	# hack to make sure the tab renders
	var first_tab = current_tab
	current_tab = 90
	_on_tab_pressed(first_tab)

func _on_tab_pressed(index:int):
	if current_tab == index:
		get_child(index).button_pressed = true
		return
	
	current_tab = index
	for child in get_children():
		if child is Button:
			child.button_pressed = false
	get_child(index).button_pressed = true
	tab_pressed.emit(index)
	
