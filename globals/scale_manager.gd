extends Node

const mobile_scales:Dictionary[int, float] = {
	150: 0.5,
	250: 1.5,
	401: 1.5,
	600: 2,
	int(INF) -1: 3  # int(INF) is negative so make it highest pos number with -1
}
const desktop_scale = 1.5

func _ready() -> void:
	print("Version ", App.version)
	_on_viewport_size_changed()
	
	#get_window().content_scale_factor = 2

func _on_viewport_size_changed():
	var size = get_viewport().get_visible_rect().size
	#print('screen size ', size, ' ', rate_limit)
	#print('distance ', size.distance_squared_to(_prev_size), ' from prev ', _prev_size)
	#if size.distance_squared_to(_prev_size) > 100000:
	match App.version:
		App.VERSIONS.MOBILE:
			var keys = mobile_scales.keys()
			keys.sort()
			#var dpi:int = DisplayServer.screen_get_dpi()
			var screen_scale:float = DisplayServer.screen_get_scale()*1.45
			var adjusted_size = size.x
			for px_size in keys:
				if adjusted_size < px_size:
					var scale = mobile_scales[px_size]*screen_scale
					App.app_scale = scale
					print('adjusted screen size ', adjusted_size, ' is less than requirement ', px_size, ' set scale to ', scale)
					get_window().content_scale_factor = scale
					return
		App.VERSIONS.MOBILE_WEB:
			var keys = mobile_scales.keys()
			keys.sort()
			#var dpi:int = DisplayServer.screen_get_dpi()
			var screen_scale:float = DisplayServer.screen_get_scale()*.6
			BrowserDebug.print_to_screen("scale is {}".format([DisplayServer.screen_get_scale()], '{}'))
			var adjusted_size = size.x
			for px_size in keys:
				if adjusted_size < px_size:
					var scale = mobile_scales[px_size]*screen_scale
					App.app_scale = scale
					print('adjusted screen size ', adjusted_size, ' is less than requirement ', px_size, ' set scale to ', scale)
					get_window().content_scale_factor = scale
					return
		App.VERSIONS.DESKTOP_WEB:
			get_window().content_scale_factor = desktop_scale
