extends Control
class_name PhotoEditButton

@onready var texture_rect: TextureRect = %TextureRect
@export var photo_cropper_scene:PackedScene
@onready var focus_indicator: MarginContainer = %FocusIndicator
@onready var delete_button: Button = %DeleteButton

var photo_picker:PhotoPicker

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
	photo_picker = PhotoPicker.new()
	photo_picker.got_image.connect(_open_crop_dialog)

func set_default(photo:ProfilePhoto) -> void:
	if !photo.is_loaded:
		await photo.loaded
	uri = photo.get_uri()
	texture_rect.texture = photo.texture

func _pressed() -> void:
	photo_picker.get_photo()

func _open_crop_dialog(image:Image):
	var texture = ImageTexture.create_from_image(image)
	var cropper:Node = photo_cropper_scene.instantiate()
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
