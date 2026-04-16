extends Node

var latitude:float
var longitude:float
var city_string:String

var is_location_updated:bool = false
signal location_updated

func _ready() -> void:
	match OS.get_name():
		'Web':
			request_location_web()
		'Android':
			pass
		_:
			request_location_desktop()

func _got_location(lat, lon, city:String='') -> void:
	
	if city.is_empty():
		city = await reverse_geocode(lat, lon)
	latitude = lat
	longitude = lon
	city_string = city
	is_location_updated = true
	location_updated.emit()

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
### Android ####################################################################



### Web ########################################################################

var _js_success_callback
var _js_error_callback

func request_location_web():
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
	_got_location(lat, lon)


func _on_location_error(args) -> void:
	var error = args[0]
	print("Geolocation error code: ", error.code, " - ", error.message)
	if error == 1: # DENIED access
		print('user denied location access')
		# Show prompt that location is required to continue
		# user can refresh to show the location prompt again
		pass
	

### Desktop ####################################################################
# Desktop apps aren't supported yet, just need this for testing

func request_location_desktop():
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_request_completed)
	http.request("https://ipapi.co/json/")

func _on_request_completed(_result, _response_code, _headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	var lat = json["latitude"]
	var lon = json["longitude"]
	var city = json["city"]
	#print("Location: ", lat, ", ", lon, " (", city, ")")
	#lat = 35.7877
	#lon = -78.6442
	#city = "Raleigh"
	#lat = 37.074527
	#lon = -77.9072229
	#city = 'VA'
	_got_location(lat, lon, city)

################################################################################
