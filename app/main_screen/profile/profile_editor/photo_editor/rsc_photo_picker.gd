extends Resource
class_name PhotoPicker

## Support native photo selection on any device!

signal got_image(image:Image)

func _init() -> void:
	match OS.get_name():
		'Web':
			_web_ready()

func get_photo() -> void:
	match OS.get_name():
		'Web':
			_open_web_photo_picker()
		'iOS':
			_open_ios_photo_picker()
		'Android':
			_open_android_photo_picker()
		_:
			_open_default_photo_picker()

### WEB ########################################################################
# This must be a global variable or it won't work
var file_access_web:FileAccessWeb

func _web_ready() -> void:
	file_access_web = FileAccessWeb.new()

func _open_web_photo_picker() -> void:
	file_access_web.loaded.connect(_on_web_file_loaded)
	file_access_web.progress.connect(_on_progress)
	file_access_web.open(".jpg, .jpeg")

func _on_progress(_current_bytes: int, _total_bytes: int) -> void:
	pass
	#var percentage: float = float(current_bytes) / float(total_bytes) * 100
	#progress.value = percentage

func _on_web_file_loaded(_file_name: String, _file_type: String, base64_data: String) -> void:
	var raw_data:PackedByteArray = Marshalls.base64_to_raw(base64_data)
	var image = Image.new()
	image.load_jpg_from_buffer(raw_data)
	got_image.emit(image)


### DESKTOP ####################################################################
func _open_default_photo_picker() -> void:
	var dialogue:FileDialog = FileDialog.new() # file_dialogue_scene.instantiate()
	dialogue.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialogue.access = FileDialog.ACCESS_FILESYSTEM
	dialogue.filters = ['*.jpg', '*.jpeg']
	dialogue.use_native_dialog = true
	dialogue.title = "Open a File"
	dialogue.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
	dialogue.visible = true
	dialogue.oversampling_override = 1.0
	dialogue.file_selected.connect(_on_file_dialog_file_selected)

func _on_file_dialog_file_selected(path: String) -> void:
	var image = Image.new()
	image.load(path)
	got_image.emit(image)


################  Mobile  #########################################################

## _picker is a reference to a global singleton, so if image_picked is connected
## only once in _init or _ready, it will fire regardless of which photo_edit_button
## is using the image_picker. To avoid bugs, we just connect and disconnect signals
## each time a photo is selected to ensure it only fires for the active button.
var _picker = null

################  IOS  #########################################################

func _open_ios_photo_picker():
	if Engine.has_singleton("PhotoPicker"):
		_picker = Engine.get_singleton("PhotoPicker")
		_picker.connect("image_picked", _on_ios_image_picked)
		_picker.connect("permission_updated", _on_permission_updated)
		
	else:
		print("PhotoPicker not available — only works on iOS device/simulator")
	
	if _picker:
		_picker.present(0)

func _on_ios_image_picked(image: Image):
	_picker.disconnect("image_picked", _on_ios_image_picked)
	_picker.disconnect("permission_updated", _on_permission_updated)
	_picker = null
	got_image.emit(image)

func _on_permission_updated(granted: bool):
	if not granted:
		print("Photo library permission was denied")


################  ANDROID  #########################################################

func _open_android_photo_picker():
	if Engine.has_singleton("GodotGetImage"):
		_picker = Engine.get_singleton("GodotGetImage")
		_picker.connect("image_request_completed", _on_android_image_picked)
		_picker.connect("error", _on_error)
		
		# limit image size to avoid out-of-memory issues
		_picker.setOptions({
			"image_format": "jpg",
			"image_quality": 90,
			"image_max_size": 4032,  # max width or height in pixels
		})
	else:
		push_warning("GodotGetImage not available — only works on Android device")

	if _picker:
		_picker.getGalleryImage()

func _on_android_image_picked(data: Dictionary):
	_picker.disconnect("image_request_completed", _on_android_image_picked)
	_picker.disconnect("error", _on_error)
	_picker = null
	
	if !data.has("0"):
		print("error accessing photo on android device")
	
	var buffer:PackedByteArray = data["0"]
	var image: Image = Image.new()
	var _err = image.load_jpg_from_buffer(buffer)
	
	await Engine.get_main_loop().process_frame  # without this image is black
	got_image.emit(image)

func _on_error(message: String):
	print("Image picker error: ", message)
