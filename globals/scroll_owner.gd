extends Node


## Lock every scroll motion to be purely vertical or horizontal. Makes scrolling
## a horizontal list of vertical profiles much more natural

enum Axis { NONE, HORIZONTAL, VERTICAL }

const AXIS_LOCK_THRESHOLD := 8.0  # pixels of drag before axis is decided

var _touch_active := false
var _accumulated := Vector2.ZERO
var _locked_axis := Axis.NONE
var _injecting := false

func _input(event: InputEvent) -> void:
	# Guard against catching our own re-injected event
	if _injecting:
		return
	
	if event is InputEventScreenTouch:
		if event.pressed:
			_touch_active = true
			_locked_axis = Axis.NONE
			_accumulated = Vector2.ZERO
		else:
			_touch_active = false
			_locked_axis = Axis.NONE
		return
			
	if _touch_active:
		if event is InputEventScreenDrag:
			if _locked_axis == Axis.NONE:
				_accumulated += event.relative
				if _accumulated.length() >= AXIS_LOCK_THRESHOLD:
					if abs(_accumulated.x) > abs(_accumulated.y):
						_locked_axis = Axis.HORIZONTAL
					else:
						_locked_axis = Axis.VERTICAL
		
					if event is InputEventScreenDrag or event is InputEventMouseMotion:
						#print('got screen drag')
						var modified: InputEvent = event.duplicate()
						#print(modified)
						get_viewport().set_input_as_handled()  # Block the original event from reaching any node
							
						match _locked_axis:
							Axis.HORIZONTAL:
								modified.relative.y = 0.0
								#modified.relative.x = clamp(modified.relative.x, -20.0, 20.0)
							Axis.VERTICAL:
								modified.relative.x = 0.0
							Axis.NONE:
								pass  
						
						
						# for some reason touch is less sensitive on android
						if OS.get_name() == 'Android':
							modified.relative *= 3
						else:
							modified.relative *= 1.3
						
						_injecting = true
						#if event is InputEventScreenDrag:
							#print(modified.relative)
						get_viewport().push_input(modified)  # Inject the modified version
						_injecting = false
