extends Node

const NPROFILES_PER_QUERY = 10

var BASE_URL:String
var HTTP_PREFIX:String = "https://"
const DEV_BASE_URL = "0.0.0.0:10000"
const PROD_BASE_URL = "directory-api-w9mi.onrender.com"
#const PROD_BASE_URL = "directory-api-1.onrender.com"

const LOGIN_ENDPOINT =                'login'
const REGISTER_ENDPOINT =             'register'
const REFRESH_ENDPOINT =              'auth/refresh'
const API =                           'api/'
const TAG_QUERY_ENDPOINT =            API + 'tags'
const ENDPOINT_SUSPEND =              API + 'suspend'
const ENDPOINT_UNSUSPEND =            API + 'unsuspend'
const ENDPOINT_SAVE_PROFILE =         API + 'profile'
const ENDPOINT_REPORT_USER =          API + 'report_user'
const CREATE_TAG_ENDPOINT =           API + 'create_tag'
const PROFILE_QUERY_ENDPOINT =        API + 'profiles'
const REPORT_TAG_ENDPOINT =           API + 'report_tag'
const BLOCK_USER_ENDPOINT =           API + 'block'
const REPORT_FEEDBACK_ENDPOINT =      API + 'submit_feedback'
const SEND_LIKE_ENDPOINT =            API + 'add_like'
const ACCEPT_LIKE_ENDPOINT =          API + 'accept_like'
const GET_LIKES_ENDPOINT =            API + 'get_likes'
const GET_USER_PROFILE_ENDPOINT =     API + 'fetch_user_profile'
const COMPLETE_ONBOARD_ENDPOINT =     API + 'complete_onboard'
const DELETE_ACCOUNT_ENDPOINT =       API + 'delete'
const ACCOUNT_CHG_PASSWORD_ENDPOINT = API + 'change_password'
const MARK_SEEN_ENDPOINT =            API + 'mark_seen'
const SEND_MSG_ENDPOINT =             API + 'send_message'
const GET_CHATS_ENDPOINT =            API + 'get_chats'
const GET_CHAT_MSGS_ENDPOINT =        API + 'get_chat_messages'
const PHOTO_GET_URL_ENDPOINT =        API + 'get_presigned_url'
const PHOTO_UPDATE_ORDER_ENDPOINT =   API + 'update_photo_order'
const TAG_CATEGORY_ENDPOINT =   API + 'tag_category'
const HTTP_ERROR_DEFAULT = "An error occured. Try again later"
const HTTP_ERROR_POPUP_MSGS = {
	0: "There was no response from the server. Please try again in a moment.",
	400: "An error occured in the application request. This has been logged and we will look into it.",
}

const MARK_SEEN_FLUSH_INTERVAL = 15

const CONTENT_JSON_HEADER = 'Content-Type: application/json'
#const ORIGIN_HEADER = "Origin: localhost:8060"
@export var debug:bool = false

signal user_session_loaded(profile:ProfileResource)
signal failed_to_load_user_session # only used by app.gd to test initial login with stored token
signal logged_out

var session_profile:ProfileResource

func get_cookie_header() -> String:
	return 'Authorization: Bearer ' + TokenStorage.get_access_token()

var _active_loading_screen:Node
var _load_requests = 0
func _show_loading_screen():
	if _load_requests < 1:
		_active_loading_screen = Constants.load_screen_file.instantiate()
		get_tree().root.add_child(_active_loading_screen)
	_load_requests += 1
		
func _remove_loading_screen():
	_load_requests = clamp(_load_requests-1, 0, INF) # should never go below 0 this is just a safeguard
	if _load_requests == 0:
		if _active_loading_screen:
			_active_loading_screen.queue_free()
			_active_loading_screen = null


func _ready() -> void:
	#var api_url = ProjectSettings.get_setting("app/api_url")
	#BASE_URL = api_url
	#print("USING URL ", api_url)
	
	if App.is_prod:
		HTTP_PREFIX = "https://"
		BASE_URL = PROD_BASE_URL
	else:
		HTTP_PREFIX = "http://"
		BASE_URL = DEV_BASE_URL
	
	var flush_timer:Timer = Timer.new()
	add_child(flush_timer)
	flush_timer.wait_time = MARK_SEEN_FLUSH_INTERVAL
	flush_timer.timeout.connect(_flush_seen_profiles)
	flush_timer.start()



func _send_post_request(callback:Callable, endpoint, data:Dictionary = {}, http_callback:Callable = _http_request_completed, show_loading_screen=true) -> void:
	if show_loading_screen:
		_show_loading_screen()
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	var retry_function = _send_post_request.bind(callback, endpoint, data, http_callback, show_loading_screen)
	http_request.request_completed.connect(http_callback.bind(callback, retry_function))
	
	var url:String = "{base_url}/{endpoint}".format({
		'base_url': HTTP_PREFIX + BASE_URL, 
		'endpoint': endpoint,
		})
	if debug: print('POST request to ', url, ' with data ', data, ' and header ', get_cookie_header())
	
	var error
	if !data.is_empty():
		var data_string:String = JSON.stringify(data)
		var headers = [CONTENT_JSON_HEADER]
		if !TokenStorage.get_access_token().is_empty():
			headers.append(get_cookie_header())
		error = http_request.request(
			url, 
			headers,
			HTTPClient.METHOD_POST,
			data_string
			)
	else:
		error = http_request.request(
			url, 
			[get_cookie_header()],
			HTTPClient.METHOD_POST,
			)
	if error != OK:
		push_error("An error occurred in the HTTP request.")

func _send_get_request(callback:Callable, endpoint, url_params='', http_callback:Callable = _http_request_completed, show_loading_screen=true) -> void:
	if show_loading_screen:
		_show_loading_screen()
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	var retry_function = _send_get_request.bind(callback, endpoint, url_params, http_callback, show_loading_screen)
	http_request.request_completed.connect(http_callback.bind(callback, retry_function))
	
	var url:String = "{base_url}/{endpoint}?{params}".format({
		'base_url': HTTP_PREFIX + BASE_URL, 
		'endpoint': endpoint,
		'params': url_params
		})
	if debug: print('GET req to ', url)
	var error = http_request.request(url, [get_cookie_header()], HTTPClient.METHOD_GET)
	if error != OK:
		push_error("An error occurred in the HTTP request: ", error)

func is_logged_in() -> bool:
	return session_profile != null

func _http_request_completed(result, response_code, headers, body, callback:Callable, retry_callback:Callable) -> void:
	## if user just logged out avoid running callback functions on instances that may have been freed.
	#if !is_logged_in():  
		#return
	
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	
	## Internal Server Error
	#if response_code >> 2 == 5:
		#App.show_error_popup(HTTP_ERROR_POPUP_MSGS.get(response_code, HTTP_ERROR_DEFAULT))
	if debug: print(' `-> http request response: ', result,' code: ', response_code, ' ', headers, ' body: ', body.get_string_from_utf8(), 'resp: ', response)

	match response_code:
		#200:
			#if debug: print(' `-> http request response: ', result,' code: ', response_code, ' ', headers, ' body: ', body.get_string_from_utf8(), 'resp: ', response)
		401:
			refresh_token(retry_callback)
			_remove_loading_screen()
			return
	
	# response format [{ "name": "dnd" }]
	_remove_loading_screen()
	callback.call(response_code, response)

func show_default_error_msg(response_code:int):
	App.show_error_popup(HTTP_ERROR_POPUP_MSGS.get(response_code, HTTP_ERROR_DEFAULT))

func refresh_token(retry_callback:Callable) -> void:
	_show_loading_screen()
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_got_refresh_token.bind(retry_callback))
	
	var url:String = "{base_url}/{endpoint}".format({
		'base_url': HTTP_PREFIX + BASE_URL, 
		'endpoint': REFRESH_ENDPOINT,
		})
	
	var headers = [CONTENT_JSON_HEADER, 'Authorization: Bearer ' + TokenStorage.load_refresh_token()]
	if debug: print('POST request to ', url, ' with headers ', headers)
	var error = http_request.request(
		url, 
		headers,
		HTTPClient.METHOD_POST,
		)
	if error != OK:
		push_error("An error occurred in the HTTP request.")

func _on_got_refresh_token(_result, response_code, _headers, body, retry_callback:Callable) -> void:
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	_remove_loading_screen()
	match response_code:
		200:
			var token = response["access_token"]
			TokenStorage.save_access_token(token)
			retry_callback.call()
			if debug: print('RETRY!!!')
		_:
			logout()
			App.show_login_screen()
			App.show_error_popup("Unable to authenticate, please login again.")


func _http_login_request_completed(result, response_code, headers, body, callback:Callable, _retry_callback:Callable):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	
	#print('login http request result', result,' ', response_code, ' ', headers, ' ', response)
	match response_code:
		200:
			TokenStorage.save_refresh_token(response["refresh_token"])
			TokenStorage.save_access_token(response["access_token"])
		401: # this is handled by the login callback on the login page
			pass
		_:
			if debug: print('http request result', result,' ', response_code, ' ', headers, ' ', response)
			App.show_error_popup(HTTP_ERROR_POPUP_MSGS.get(response_code, HTTP_ERROR_DEFAULT))
	
	_remove_loading_screen()
	callback.call(response_code)

func _on_login_request_returned(response_code):
	match response_code:
		200: # SUCCESS
			# The session cookie was already set by the database for logging in
			Server.get_session_profile()
		_: Server.show_default_error_msg(response_code)


###########################################################

func get_session_profile() -> void:
	get_user_profile(-1, set_session_profile)

func get_user_profile(user_id:int, callback:Callable) -> void:
	var data = {'user_id': user_id}
	_send_post_request(callback, GET_USER_PROFILE_ENDPOINT, data)


func set_session_profile(resp_code, response_data) -> void:
	if !response_data: 
		failed_to_load_user_session.emit()
		return
	match resp_code:
		200:
			var current_profile:ProfileResource = ProfileResource.new()
			var profile_data:Dictionary = response_data
			current_profile.from_db(profile_data)
			session_profile = current_profile
			user_session_loaded.emit(session_profile)
		_:
			failed_to_load_user_session.emit()


### Account Management ########################################################

func login(email:String, password:String, callback:Callable) -> void:
	var data: = {"email": email,"password": password}
	_send_post_request(callback, LOGIN_ENDPOINT, data, _http_login_request_completed)

func logout() -> void:
	session_profile = null
	TokenStorage.clear_access_token()
	logged_out.emit()
	App.show_login_screen()

# curl -X POST http://localhost:8080/register \
#   -H "Content-Type: application/json" \
#   -d '{"email":"user@example.com","password":"test123"}'
func register_new_user(email:String, password:String, birthdate:String, callback:Callable) -> void:
	var data = {"email": email,"password": password, "birthdate": birthdate}
	_send_post_request(callback, REGISTER_ENDPOINT, data)

func delete_account(callback:Callable) -> void:
	_send_post_request(callback, DELETE_ACCOUNT_ENDPOINT)

func complete_onboard(callback:Callable) -> void:
	_send_post_request(callback, COMPLETE_ONBOARD_ENDPOINT)

func suspend_account(callback:Callable) -> void:
	_send_post_request(callback, ENDPOINT_SUSPEND)

func unsuspend_account(callback:Callable) -> void:
	_send_post_request(callback, ENDPOINT_UNSUSPEND)

func update_profile(new_profile_data:Dictionary, callback:Callable) -> void:
	_send_post_request(callback, ENDPOINT_SAVE_PROFILE, new_profile_data)

func change_password(old_password:String, new_password:String, callback:Callable) -> void:
	var data:Dictionary = {'old_password': old_password, 'new_password': new_password}
	_send_post_request(callback, ACCOUNT_CHG_PASSWORD_ENDPOINT, data)


### Other ########################################################

func block_user(user_id:int, callback:Callable) -> void:
	var data = {'user_id': user_id}
	_send_post_request(callback, BLOCK_USER_ENDPOINT, data)

func report_user(user_id:int, reason:String, description:String, callback:Callable) -> void:
	var data = {
		'reported_user': user_id,
		'reason': reason,
		'description': description
	}
	_send_post_request(callback, ENDPOINT_REPORT_USER, data)

func report_tag(tag_name:String, description:String, callback:Callable) -> void:
	var data = {
		'tag_name': tag_name,
		'description': description
	}
	_send_post_request(callback, REPORT_TAG_ENDPOINT, data)

func report_feedback(email:String, reason:String, description:String, callback:Callable) -> void:
	var data = {
		'email': email,
		'reason': reason,
		'description': description
	}
	_send_post_request(callback, REPORT_FEEDBACK_ENDPOINT, data)

### Seen Profiles ########################################################

# TODO would be good to include if seen or not in profiledata returned from the server so that when querying
# without the filter we don't send excess mark_seen requests to the server.

# NOTE if app crashes or gets closed before the flush happens, data won't be pushed to the server
var _seen_profiles:Dictionary[int, bool] = {}  # dictionary as hashset
var _flush_queue:Dictionary[int, bool] = {}

func push_seen_profile(user_id:int) -> void:
	if user_id not in _seen_profiles.keys():
		_flush_queue[user_id] = true

func _flush_seen_profiles():
	if len(_flush_queue.keys()) > 0:
		_mark_profiles_seen(_flush_queue.keys(), _on_mark_seen_returned)

# NOTE between the time the request is sent and received, some profiles could get added and then erased
func _on_mark_seen_returned(resp_code:int, _resp) -> void:
	match resp_code:
		200:
			for key in _flush_queue.keys():
				_seen_profiles[key] = true
			_flush_queue = {}
		#_:
			#print('failed to flush seen profiles')

func _mark_profiles_seen(seen_user_ids:Array[int], callback) -> void:
	var data = {'seen_ids': seen_user_ids}
	_send_post_request(callback, MARK_SEEN_ENDPOINT, data, _http_request_completed, false)

### Querying ########################################################

func fuzzy_search_tags(text:String, callback:Callable) -> void:
	_send_get_request(callback, TAG_QUERY_ENDPOINT, "name={}".format([text], '{}'), _http_request_completed, false)

var search_tool:SearchParamList

func query_profiles(callback:Callable, page=0) -> void:
	var parameters:Dictionary = search_tool.get_html_query_values()
	
	parameters['limit'] = NPROFILES_PER_QUERY
	parameters['offset'] = page*NPROFILES_PER_QUERY
	
	var param_str:String = ''
	for param_key in parameters.keys():
		param_str += "{}={}&".format([param_key, str(parameters[param_key])], "{}")
	_send_get_request(callback, PROFILE_QUERY_ENDPOINT, param_str)


### TAGS ########################################################

func get_tags_of(tag_type:String, callback:Callable) -> void:
	assert(tag_type in Tag.raw_to_type.keys())
	_send_post_request(callback, TAG_CATEGORY_ENDPOINT, {"category": tag_type})

func create_tag(tag_name:String, tag_type:Tag.TYPE, callback:Callable) -> void:
	var type_str = Constants.tag.get_string_from_type(tag_type)
	var data = {"name": tag_name, "tag_type": type_str}
	_send_post_request(callback, CREATE_TAG_ENDPOINT, data)


### LIKE AND MESSAGE MANAGEMENT #######################################

func send_like(to_id:int, callback:Callable) -> void:
	var data = {"to_id": to_id}
	_send_post_request(callback, SEND_LIKE_ENDPOINT , data)

func get_likes(callback:Callable) -> void:
	_send_get_request(callback, GET_LIKES_ENDPOINT)

func accept_like(from_id:int, callback:Callable) -> void:
	var data = {"to_id": from_id}
	_send_post_request(callback, ACCEPT_LIKE_ENDPOINT, data)

func get_chats(callback:Callable) -> void:
	_send_get_request(callback, GET_CHATS_ENDPOINT)

func get_chat_msgs(chat_id:int, callback:Callable) -> void:
	var data = {"chat_id": chat_id}
	_send_post_request(callback, GET_CHAT_MSGS_ENDPOINT, data)

func send_message(chat_id:int, text:String, callback:Callable) -> void:
	var data = {"chat_id": chat_id, "text": text}
	_send_post_request(callback, SEND_MSG_ENDPOINT, data)


### OBJECT STORAGE #######################################
func get_uri(index:int, callback:Callable) -> void:
	_send_post_request(callback, PHOTO_GET_URL_ENDPOINT, {'index': index})

func update_and_confirm_photos(uris:Array[String], callback:Callable) -> void:
	_send_post_request(callback, PHOTO_UPDATE_ORDER_ENDPOINT, {'uris': uris})
