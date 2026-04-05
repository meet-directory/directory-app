extends Node

func upload_image(presigned_url: String, image_texture: ImageTexture) -> void:
	var image: Image = image_texture.get_image()
	var image_data: PackedByteArray = image.save_jpg_to_buffer()

	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_upload_completed)

	var headers = [
		"Content-Type: image/jpeg",
		"Content-Length: " + str(image_data.size())
	]

	var error = http_request.request_raw(
		presigned_url,
		headers,
		HTTPClient.METHOD_PUT,
		image_data
	)

	if error != OK:
		print("Upload request failed to start: ", error)


func _on_upload_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	pass
	#if response_code == 200:
		#print("Upload successful!")
	#else:
		#print("Upload failed with code: ", response_code)
		#print("Body: ", body.get_string_from_utf8())

func get_texture(presigned_url:String, callback:Callable) -> void:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_fetch_completed.bind(callback))
	var error = http_request.request_raw(
		presigned_url,
		[],
		HTTPClient.METHOD_GET,
		#image_data
	)

	if error != OK:
		print("Upload request failed to start: ", error)
	

func _on_fetch_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, callback:Callable) -> void:
	# if user just logged out avoid running callback functions on instances that may have been freed.
	if !Server.is_logged_in():  
		return
	match response_code:
		200:
			var image:Image = Image.new()
			if !body.is_empty():
				image.load_jpg_from_buffer(body)
				callback.call(image)
