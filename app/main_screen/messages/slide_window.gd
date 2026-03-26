extends Control
#class_name SlideWindow
#
#@export var contents:Control
#@export var transition_time:float = 0.2
#
#var scrolled:bool = false
#
#func _ready() -> void:
	#draw.connect(_on_draw)
	#_refresh()
#
#func _refresh() -> void:
	#var screen_size = Constants.get_screen_size()
	#var parent_size = get_parent().size
	#print('parent size ', parent_size, ' ssize ', screen_size)
	#contents.size.x = screen_size.x*2 - 20
	#contents.size.y = parent_size.y
	#if scrolled:
		#contents.position.x = screen_size.x * -1
#
#func slide_left() -> void:
	#var tween:Tween = create_tween()
	#var right_pos = Constants.get_screen_size().x * -1
	#scrolled = true
	#tween.tween_property(contents, "position:x", right_pos, transition_time)
#
#func slide_right() -> void:
	#var tween:Tween = create_tween()
	#var right_pos = 0
	#scrolled = false
	#tween.tween_property(contents, "position:x", right_pos, transition_time)
#
#func _on_draw() -> void:
	#_refresh()
