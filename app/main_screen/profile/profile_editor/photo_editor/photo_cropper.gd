extends Node
@onready var draggable_photo: TextureRect = %DraggablePhoto
@onready var crop_area: ReferenceRect = %CropArea

var max_crop_size := Vector2i(1080,1350)

signal photo_cropped(cropped:ImageTexture)

func set_image(texture:Texture2D) -> void:
	draggable_photo.set_photo(texture)

func get_cropped_texture() -> ImageTexture:
	var photo: TextureRect = draggable_photo
	var img: Image = photo.texture.get_image()
	
	# Build the source rect in the original image's space
	var scale_factor = Vector2(
		img.get_width() / photo.texture.get_size().x,
		img.get_height() / photo.texture.get_size().y
	)
	
	# Photo position relative to crop area (0,0 = top-left of crop)
	var offset = -photo.position / photo.scale
	var src_rect = Rect2(
		offset * scale_factor,
		(crop_area.size / photo.scale) * scale_factor
	)
	
	var crop_size:Vector2i = max_crop_size
	if img.get_height() < max_crop_size.y:
		crop_size.y = img.get_height()
		crop_size.x = int(crop_size.y*0.8)
	
	src_rect = src_rect.intersection(Rect2(Vector2.ZERO, Vector2(img.get_width(), img.get_height())))
	var cropped = img.get_region(src_rect.abs())
	cropped.resize(int(crop_size.x), int(crop_size.y))
	
	return ImageTexture.create_from_image(cropped)


func _on_save_button_pressed() -> void:
	photo_cropped.emit(get_cropped_texture())
	queue_free()


func _on_cancel_button_pressed() -> void:
	queue_free()
