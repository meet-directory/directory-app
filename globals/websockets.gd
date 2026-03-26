extends Node
class_name WebSocketClient

@export var handshake_headers: PackedStringArray
@export var supported_protocols: PackedStringArray
var tls_options: TLSOptions = null

signal new_message_received(chat_id:int)
signal like_request_received
signal like_request_accepted

var socket := WebSocketPeer.new()

enum states {DISCONNECTED, CONNECTING, CONNECTED, WAITING}
var current_state:states = states.DISCONNECTED:
	set(value):
		current_state = value
		#print("WS State changed to ", current_state)

func _ready() -> void:
	Server.logged_out.connect(_close)

func _close(code: int = 1000, reason: String = "") -> void:
	current_state = states.DISCONNECTED
	socket.close(code, reason)
	socket = WebSocketPeer.new()

func _initiate_connection():
	handshake_headers = [Server.get_cookie_header()]
	var protocol = "ws://"
	if App.is_prod:
		protocol = "wss://"
	var websocket_url = protocol + Server.BASE_URL + "/ws" + "?token=" + TokenStorage.get_access_token()
	
	socket.supported_protocols = supported_protocols
	socket.handshake_headers = handshake_headers
	
	var err := socket.connect_to_url(websocket_url, tls_options)
	if err != OK:
		print('Error connecting to websocket ', err)
		return err
	
	#print("Connected to websocket on ", url,'\n with header',socket.handshake_headers, ' got resp ', err, ' ready state ', last_state)
	return OK

#func _send(message: String) -> int:
	#if typeof(message) == TYPE_STRING:
		#return socket.send_text(message)
	#return socket.send(var_to_bytes(message))

const max_backoff = 20
var exp_backoff = 2
var _time_till_retry:float = 0

func _reconnect():
	exp_backoff = 0
	_time_till_retry = randf() * 2
	current_state = states.WAITING

func _process(delta: float) -> void:
	match current_state:
		states.WAITING:
			_time_till_retry -= delta
			if _time_till_retry < 0:
				current_state = states.CONNECTING
		states.DISCONNECTED:
			if Server.session_profile:
				_reconnect()
		states.CONNECTING:
			socket.poll()
			var state := socket.get_ready_state()
			if state == WebSocketPeer.STATE_CLOSED:
				_initiate_connection()
				exp_backoff = clamp(exp_backoff**2, 2, max_backoff)
				_time_till_retry = exp_backoff
				current_state = states.WAITING
			else:
				current_state = states.CONNECTED
		states.CONNECTED:
			var state := socket.get_ready_state()
			if state == socket.STATE_CLOSED:
				_reconnect()
			else:
				socket.poll()
				while socket.get_ready_state() == socket.STATE_OPEN and socket.get_available_packet_count():
					_handle_message()

func _handle_message() -> void:
	var message = _get_message()
	var type:String = message.get('type')
	var data:Dictionary = message.get('data', {})
	match type:
		'msg':
			new_message_received.emit(data['chat_id'])
		'like':
			if data['accepted']:
				like_request_accepted.emit()
			else:
				like_request_received.emit()

func _get_message() -> Variant:
	if socket.get_available_packet_count() < 1:
		return null
	var pkt := socket.get_packet()
	if socket.was_string_packet():
		var msg_str = pkt.get_string_from_utf8()
		return JSON.parse_string(msg_str)
	var raw_msg = bytes_to_var(pkt)
	return raw_msg
