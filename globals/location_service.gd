extends Node

""" 
Just detects if IP address is in NC or not as a rough way to limit people from making accounts
elsewhere.

IP location is only accurate to around 50km
In the future will need iOS and Android plugins to use actual GPS data.
"""

signal location_received(lat: float, lon: float, city:String)
signal location_failed(error: String)

const rounding_degree = 0.01
var latitude:float
var longitude:float
var city_str:String

func _ready() -> void:
	location_received.connect(_save_loc)
	#location_received.connect(_print_location)
	#location_failed.connect(_print_err)
	get_location()

func _save_loc(lat:float, lon:float, city) -> void:
	latitude = snappedf(lat, rounding_degree)
	longitude = snappedf(lon, rounding_degree)
	city_str = city

#func _print_location(lat, lon, city) -> void:
	#print("Got location ", lat,' ', lon, ' ', city, '. In NC? ', is_in_north_carolina(lat, lon))
#
#func _print_err(err:String) -> void:
	#print("Got location failed: ", err)

# Simplified NC border polygon [longitude, latitude]
const NC_POLYGON = [
	[-84.32, 34.99], [-84.29, 35.21], [-84.10, 35.27], [-83.96, 35.46],
	[-83.49, 35.56], [-83.17, 35.73], [-82.90, 35.92], [-82.69, 36.12],
	[-82.41, 36.07], [-82.03, 36.12], [-81.91, 36.30], [-81.70, 36.54],
	[-81.35, 36.57], [-80.88, 36.56], [-80.44, 36.55], [-79.95, 36.54],
	[-79.51, 36.54], [-77.90, 36.55], [-76.92, 36.55],
	[-76.00, 36.55], [-75.60, 36.55], [-75.40, 36.20],
	[-75.20, 35.90], [-74.90, 35.60], [-74.90, 35.20],
	[-75.10, 34.90], [-75.40, 34.60],
	[-75.60, 34.20], [-76.00, 33.70], [-76.60, 33.70],
	[-77.20, 33.70], [-77.80, 33.80], [-78.55, 33.75], [-79.06, 34.20],
	[-79.67, 34.80], [-80.32, 34.81], [-80.56, 34.82],
	[-80.93, 35.10], [-81.04, 35.05], [-81.37, 35.16],
	[-82.27, 35.20], [-82.78, 35.07], [-83.11, 35.00],
	[-84.02, 35.00], [-84.32, 34.99]
]

func is_in_north_carolina(lat:float=latitude, lon:float=longitude) -> bool:
	return _point_in_polygon(lon, lat, NC_POLYGON)

func _point_in_polygon(x: float, y: float, polygon: Array) -> bool:
	var inside = false
	var j = polygon.size() - 1
	for i in range(polygon.size()):
		var xi = polygon[i][0]; var yi = polygon[i][1]
		var xj = polygon[j][0]; var yj = polygon[j][1]
		if ((yi > y) != (yj > y)) and (x < (xj - xi) * (y - yi) / (yj - yi) + xi):
			inside = !inside
		j = i
	return inside


func get_location():
	return  # disable till we use it
	if OS.get_name() == "Web":
		_get_web_location()
	else:
		_get_ip_location()

var on_success
var on_error

func _get_web_location():
	# Set up JS callbacks that signal back into GDScript
	on_success = JavaScriptBridge.create_callback(_on_web_success)
	on_error = JavaScriptBridge.create_callback(_on_web_error)
	JavaScriptBridge.get_interface("navigator").geolocation.getCurrentPosition(on_success, on_error)

func _on_web_success(args) -> void:
	var coords = args[0].coords
	emit_signal("location_received", coords.latitude, coords.longitude, '')

func _on_web_error(args) -> void:
	emit_signal("location_failed", str(args[0].message))


func _get_ip_location():
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_ip_request_completed)
	http.request("https://ipwho.is/")

func _on_ip_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		var data = json.get_data()
		if data.get("success", false):
			emit_signal("location_received", data.latitude, data.longitude, data.city)
		else:
			emit_signal("location_failed", "IP lookup failed")
	else:
		emit_signal("location_failed", "HTTP error: " + str(response_code))
