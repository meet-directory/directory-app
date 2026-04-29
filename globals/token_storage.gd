extends Node

const REFRESH_TOKEN_PATH = "user://refresh_auth.dat"
const ACCESS_TOKEN_PATH = "user://access_auth.dat"

var _access_token:String

#func _ready():
	#var refresh_token = load_refresh_token()
	#if refresh_token == "":
		#show_login_screen()
	#else:
		#attempt_token_refresh(refresh_token)

#func attempt_token_refresh(refresh_token: String) -> void:
	## POST to your /auth/refresh endpoint
	#var result = await api.refresh(refresh_token)
	#if result.success:
		#_access_token = result.access_token  # Keep only in memory
		#show_main_app()
	#else:
		#clear_refresh_token()  # Token expired/revoked
		#show_login_screen()

#func on_login_success(access_token: String, refresh_token: String) -> void:
	#_access_token = access_token       # In-memory only
	#save_refresh_token(refresh_token)  # Persisted to disk
	#show_main_app()


func get_device_key() -> String:
	var components = []
	# TODO use cookies instead or make sure this is secure on web
	if OS.get_name() != 'Web':
		components.append(OS.get_unique_id())
	else:
		components.append("bloop") # TODO probably insecure idk
	components.append(OS.get_model_name())
	var raw = "salt-akdsfjagmbpo392582fkweo48o:" + ":".join(components)
	return raw.sha256_text()

# TODO yeah code is duplicated below, but it probably won't be the same once we
# actually use android/ios secure storage so no point refactoring

func save_refresh_token(token: String) -> void:
	var key = get_device_key()
	var file = FileAccess.open_encrypted_with_pass(REFRESH_TOKEN_PATH, FileAccess.WRITE, key)
	if file:
		file.store_string(token)
		file.close()

func save_access_token(token: String) -> void:
	_access_token = token
	
	var key = get_device_key()
	var file = FileAccess.open_encrypted_with_pass(ACCESS_TOKEN_PATH, FileAccess.WRITE, key)
	if file:
		file.store_string(token)
		file.close()

func load_refresh_token() -> String:
	var key = get_device_key()
	if not FileAccess.file_exists(REFRESH_TOKEN_PATH):
		return ""
	var file = FileAccess.open_encrypted_with_pass(REFRESH_TOKEN_PATH, FileAccess.READ, key)
	if file:
		var token = file.get_as_text()
		file.close()
		return token
	return ""

func load_access_token() -> String:
	var key = get_device_key()
	if not FileAccess.file_exists(ACCESS_TOKEN_PATH):
		return ""
	var file = FileAccess.open_encrypted_with_pass(ACCESS_TOKEN_PATH, FileAccess.READ, key)
	if file:
		var token = file.get_as_text()
		file.close()
		_access_token = token
		return token
	return ""

func clear_access_token() -> void:
	_access_token = ''
	DirAccess.remove_absolute(ACCESS_TOKEN_PATH)
	DirAccess.remove_absolute(REFRESH_TOKEN_PATH)

func get_access_token() -> String:
	return _access_token
