extends Control
class_name PhotoEditButton

@onready var texture_rect: TextureRect = %TextureRect
@export var file_dialogue_scene:PackedScene
@export var photo_cropper_scene:PackedScene
@onready var focus_indicator: MarginContainer = %FocusIndicator
@onready var delete_button: Button = %DeleteButton

var file_access_web:FileAccessWeb


var uri:
	set(value):
		uri = value
		if value:
			delete_button.show()
		else:
			delete_button.hide()

signal photo_added(image:ImageTexture)

func _ready() -> void:
	focus_indicator.hide()
	delete_button.hide()
	match OS.get_name():
		'Web':
			_web_ready()
		'iOS':
			_ios_ready()

func set_default(photo:ProfilePhoto) -> void:
	if !photo.is_loaded:
		await photo.loaded
	uri = photo.get_uri()
	texture_rect.texture = photo.texture
	

func _pressed() -> void:
	_get_new_picture()

func _get_new_picture() -> void:
	match OS.get_name():
		'Web':
			_open_web_photo_picker()
		'iOS':
			_open_ios_photo_picker()
		_:
			var dialogue:FileDialog = file_dialogue_scene.instantiate()
			dialogue.file_selected.connect(_on_file_dialog_file_selected)
			get_tree().root.add_child(dialogue)

func _open_crop_dialog(image:Image):
	var texture = ImageTexture.create_from_image(image)
	var cropper:Node = photo_cropper_scene.instantiate()
	cropper.tree_exited.connect(func(): _selecting = false) # for iOS only
	get_tree().root.add_child(cropper)
	cropper.set_image(texture)
	cropper.photo_cropped.connect(_on_photo_cropped)

func _on_photo_cropped(texture:ImageTexture) -> void:
	#photo_added.emit(texture)
	var index = get_index()
	Server.get_uri(index, _on_server_uri_received.bind(texture, index))

func _on_server_uri_received(resp_code, resp, texture:ImageTexture, _index:int) -> void:
	match resp_code:
		200:
			var signed_req = resp
			ObjectStorage.upload_image(signed_req, texture)
			var pp = ProfilePhoto.new()
			uri = pp.get_uri(signed_req)
			texture_rect.texture = texture
		_:
			Server.show_default_error_msg(resp_code)

func _on_mouse_entered() -> void:
	if uri:
		focus_indicator.show()

func _on_mouse_exited() -> void:
	focus_indicator.hide()

func reset():
	uri = ''
	texture_rect.texture = null

func _on_delete_button_pressed() -> void:
	# TODO use conf popup
	#var conf:ConfirmationPopup = App.show_conf_popup("Are you sure you want to delete this photo?")
	reset()

func _on_delete_button_mouse_entered() -> void:
	focus_indicator.hide()

func _on_photo_edit_button_pressed() -> void:
	_pressed()

### WEB ########################################################################

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
	_open_crop_dialog(image)



### DESKTOP ####################################################################
func _on_file_dialog_file_selected(path: String) -> void:
	var image = Image.new()
	image.load(path)
	_open_crop_dialog(image)


################  IOS  #########################################################

## _picker is a reference to a global singleton, so when image_picked is emitted
## _on_image_picked will be called on all PhotoEditButton nodes.
## _selecting is set to true only on the given node that opened the photo picker
## so that we can ensure _on_image_picked only runs once for the relevant button
var _picker = null
var _selecting = false

func _ios_ready():
	if Engine.has_singleton("PhotoPicker"):
		_picker = Engine.get_singleton("PhotoPicker")
		_picker.connect("image_picked", _on_image_picked)
		_picker.connect("permission_updated", _on_permission_updated)
		
	else:
		print("PhotoPicker not available — only works on iOS device/simulator")

func _open_ios_photo_picker():
	if _picker:
		_selecting = true
		_picker.present(0)

func _on_image_picked(image: Image):
	if _selecting:
		_open_crop_dialog(image)

func _on_permission_updated(granted: bool):
	if not granted:
		print("Photo library permission was denied")
