extends Node

### Location Service
## The first location update is requested on the first query for profiles, which occurs automatically
## when a user logs in if they are not suspended. After that the location is updated at regular intervals.
## Should a location update fail the updates will also stop until the user tries to search again.
## 
## Each supported platform handles location separately, they each inherit the LocationFinder base class
## so that they can be used interchangeably by this global script, which is the only exposed surface
## to the rest of the app. 

signal location_updated(success:bool)

## Seconds between updates
var update_interval = 15 * 60

var latitude:float
var longitude:float
var city_string:String  # only gonna be used for user troubleshooting in settings

var _last_update_time:int = 0
var _location_finder:LocationFinder


func _ready() -> void:
	match OS.get_name():
		"Android":
			_location_finder = LocationFinderAndroid.new()
		# TODO: iOS
		'Web':
			_location_finder = LocationFinderWeb.new()
			# Not currently supporting mobile web, but if we do,
			# calling request_location must be done from a user gesture
		_:
			# desktop apps aren't officially supported, this IP Location
			# is added as a fallback and for quick testing on desktop builds
			_location_finder = LocationFinderDesktop.new()
	
	add_child(_location_finder)
	if not _location_finder.is_node_ready():
		await _location_finder.ready
	_location_finder.got_location.connect(_got_location)
	_location_finder.location_request_failed.connect(location_updated.emit.bind(false))


func is_location_expired():
	# always returns true location has never been updated this session
	return Time.get_unix_time_from_system() - _last_update_time > update_interval

func start_location_requests():
	_location_finder.request_location()

func _request_location_loop():
	if Server.session_profile.suspended:
		return
	await get_tree().create_timer(update_interval).timeout
	_location_finder.request_location()

func _got_location(lat, lon) -> void:
	#print('got location!', lat, ', ', lon)
	latitude = lat
	longitude = lon
	Server.update_location(_on_server_updated, lat, lon)
	#App.show_info_popup("Location! " + str(lat) + ', ' + str(lon))
	city_string = await reverse_geocode(lat, lon)

func _on_server_updated(resp_code, _resp):
	match resp_code:
		200:
			_last_update_time = Time.get_unix_time_from_system()
			location_updated.emit(true)
			_request_location_loop()
		_:
			location_updated.emit(false)
			# TODO It's gonna be weird to get this message during a timed update that isn't linked to intentionally refreshing the search
			# Should clean up the logic to silently fail and display this only if in response to searching
			# But if this request to the server fails we have bigger problems for now.
			App.show_info_popup("Sorry, there was a problem updating your location on our servers. Try again later")

func reverse_geocode(lat: float, lon: float) -> String:
	var url = "https://nominatim.openstreetmap.org/reverse?lat=%s&lon=%s&format=json" % [lat, lon]
	var http = HTTPRequest.new()
	add_child(http)
	
	http.request(url, ["User-Agent: Directory/1.0"])
	
	var response = await http.request_completed
	http.queue_free()
	
	var result_code = response[1]
	var body = response[3]
	
	if result_code != 200:
		push_error("Reverse geocode failed with code: %d" % result_code)
		return ""
	
	var json = JSON.new()
	if json.parse(body.get_string_from_utf8()) != OK:
		push_error("Reverse geocode JSON parse failed")
		return ""
	
	var data = json.get_data()
	var address = data.get("address", {})
	
	var city = address.get("city",
		address.get("town",
		address.get("village", "")))
	
	if city == "":
		return ""
	
	var country_code = address.get("country_code", "")
	if country_code == "us":
		var state_code = data.get("ISO3166-2-lvl4", "")
		if state_code != "":
			var parts = state_code.split("-")
			if parts.size() == 2:
				return "%s, %s" % [city, parts[1]]
	
	return city



### Web ########################################################################

#var _js_success_callback
#var _js_error_callback
#
#func request_location_web():
	#_js_success_callback = JavaScriptBridge.create_callback(_on_location_success)
	#_js_error_callback = JavaScriptBridge.create_callback(_on_location_error)
#
	## Assign to window FIRST, before the eval that references them
	#JavaScriptBridge.get_interface("window").godot_geo_success = _js_success_callback
	#JavaScriptBridge.get_interface("window").godot_geo_error = _js_error_callback
#
	#JavaScriptBridge.eval("""
		#navigator.geolocation.getCurrentPosition(
			#godot_geo_success,
			#godot_geo_error,
			#{ enableHighAccuracy: false, timeout: 10000 }
		#);
	#""")
#
#func _on_location_success(args) -> void:
	#var position = args[0]
	#var lat = position.coords.latitude
	#var lon = position.coords.longitude
	#_got_location(lat, lon)
#
#
#func _on_location_error(args) -> void:
	#var error = args[0]
	#print("Geolocation error code: ", error.code, " - ", error.message)
	#if error.code == 1: # DENIED access
		#var text:String
		#if OS.has_feature('web_android'):
			#text = "Please enable location services, refresh, and enable the location permission for this site. Without location we can't show users in your area."
		#else:
			#text = "You denied the location permission. Without your location, we can't show you users in your area. Please refresh the page and allow the permission.\n\n Note that Directory only collects rough location data to see what city you are in."
		#App.show_info_popup(text)
