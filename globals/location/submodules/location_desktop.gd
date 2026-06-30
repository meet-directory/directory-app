extends LocationFinder
class_name LocationFinderDesktop

## Directory isn't officially supported for desktop, this is for local testing and can be used as a fallback for movile devices

func request_location():
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_request_completed)
	http.request("https://ipapi.co/json/")

func _on_request_completed(_result, _response_code, _headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	var lat = json["latitude"]
	var lon = json["longitude"]
	#var city = json["city"]
	
	#print("Location: ", lat, ", ", lon, " (", city, ")")
	#lat = 35.7877
	#lon = -78.6442
	#city = "Raleigh"
	#lat = 37.074527
	#lon = -77.9072229
	#city = 'VA'
	got_location.emit(lat, lon)
