extends Control
class_name PhotoViewContainer
@onready var photo: TextureRect = %TextureRect
@export var load_material:ShaderMaterial

func set_photo(p:ProfilePhoto) -> void:
	if !p.is_loaded:
		photo.material = load_material # add loading "shine" animation
		await p.loaded
	photo.texture = p.texture
	photo.material = null # remove the "loading shine"
