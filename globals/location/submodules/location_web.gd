extends LocationFinder
class_name LocationFinderWeb

var _js_success_callback
var _js_error_callback

func request_location():
	_js_success_callback = JavaScriptBridge.create_callback(_on_location_success)
	_js_error_callback = JavaScriptBridge.create_callback(_on_location_error)

	# Assign to window FIRST, before the eval that references them
	JavaScriptBridge.get_interface("window").godot_geo_success = _js_success_callback
	JavaScriptBridge.get_interface("window").godot_geo_error = _js_error_callback

	JavaScriptBridge.eval("""
		navigator.geolocation.getCurrentPosition(
			godot_geo_success,
			godot_geo_error,
			{ enableHighAccuracy: false, timeout: 10000 }
		);
	""")

func _on_location_success(args) -> void:
	var position = args[0]
	var lat = position.coords.latitude
	var lon = position.coords.longitude
	got_location.emit(lat, lon)


func _on_location_error(args) -> void:
	var error = args[0]
	if error.code == 1: # DENIED access
		var text:String
		if OS.has_feature('web_android'):
			text = "Please enable location services, refresh, and enable the location permission for this site. Without location we can't show users in your area."
		else:
			text = "You denied the location permission. Without your location, we can't show you users in your area. Please refresh the page and allow the permission."
		App.show_info_popup(text)
