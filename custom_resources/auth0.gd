extends Node
class_name Auth0

const AUTH0_DOMAIN = ""
const CLIENT_ID = ""
var REDIRECT_URI

var _code_verifier := ""
var http := HTTPRequest.new()

func _get_redirect_uri() -> String:
	match OS.get_name():
		"Linux", "Windows", "macOS":
			return "http://localhost:7654/callback"
		"Android", "iOS":
			return "myapp://callback"
		_:
			return "myapp://callback"

func _ready() -> void:
	REDIRECT_URI = _get_redirect_uri()
	add_child(http)
	http.request_completed.connect(_on_token_response)

# Step 1: Open browser to Auth0
func begin_login(connection: String = "") -> void:
	_code_verifier = _generate_code_verifier()
	var challenge := _generate_code_challenge(_code_verifier)

	var params := {
		"response_type": "code",
		"client_id": CLIENT_ID,
		"redirect_uri": REDIRECT_URI,
		"scope": "openid profile email offline_access",
		"code_challenge": challenge,
		"code_challenge_method": "S256",
	}

	# Pass "google-oauth2" or "apple" to skip the Auth0 login page entirely
	if connection != "":
		params["connection"] = connection

	var query := _dict_to_query(params)
	var auth_url = AUTH0_DOMAIN + "/authorize?" + query
	OS.shell_open(auth_url)
	print('open begin login to \n' + auth_url)
	match OS.get_name():
		"Linux", "Windows", "macOS":
			_start_local_server()

var tcp_server := TCPServer.new()

func _start_local_server() -> void:
	tcp_server.listen(7654)

func _process(_delta: float) -> void:
	if tcp_server.is_connection_available():
		var conn := tcp_server.take_connection()
		var request := conn.get_string(conn.get_available_bytes())
		# Parse out the ?code= from the GET request line
		var code := _extract_code(request)
		conn.put_data("HTTP/1.1 200 OK\r\n\r\nLogin successful, return to the app.".to_utf8_buffer())
		tcp_server.stop()
		handle_callback(code)

func _extract_code(request: String) -> String:
	var line := request.split("\n")[0]          # "GET /callback?code=xxx HTTP/1.1"
	var path := line.split(" ")[1]              # "/callback?code=xxx"
	var query := path.split("?")[1]             # "code=xxx"
	for param in query.split("&"):
		if param.begins_with("code="):
			return param.substr(5)
	return ""

# Step 2: Called when your app catches the redirect URI callback
func handle_callback(code: String) -> void:
	var body := _dict_to_query({
		"grant_type": "authorization_code",
		"client_id": CLIENT_ID,
		"code": code,
		"redirect_uri": REDIRECT_URI,
		"code_verifier": _code_verifier,
	})
	http.request(
		AUTH0_DOMAIN + "/oauth/token",
		["Content-Type: application/x-www-form-urlencoded"],
		HTTPClient.METHOD_POST,
		body
	)

signal token_successfully_saved

func _on_token_response(_result, status, _headers, body) -> void:
	var json = JSON.parse_string(body.get_string_from_utf8())
	if status == 200:
		var access_token: String = json["access_token"]
		TokenStorage.save_access_token(access_token)
		token_successfully_saved.emit()
		var id_token: String = json["id_token"]  # JWT with user info
		# Send access_token to your backend to verify the user
		print('got token ', access_token)
	print('response: ')
	for key in json.keys():
		print(key, ' : ', json[key])
	
	
func _generate_code_verifier() -> String:
	var bytes := PackedByteArray()
	for i in 32:
		bytes.append(randi() % 256)
	return Marshalls.raw_to_base64(bytes)\
		.replace("+", "-").replace("/", "_").replace("=", "")

func _generate_code_challenge(verifier: String) -> String:
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(verifier.to_utf8_buffer())
	var hash := ctx.finish()
	return Marshalls.raw_to_base64(hash)\
		.replace("+", "-").replace("/", "_").replace("=", "")

func _dict_to_query(d: Dictionary) -> String:
	return "&".join(d.keys().map(func(k): return k + "=" + str(d[k]).uri_encode()))
