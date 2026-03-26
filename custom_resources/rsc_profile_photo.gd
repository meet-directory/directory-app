extends Resource
class_name ProfilePhoto

@export var signed_uri:String
@export var texture:Texture2D
@export var is_loaded:bool = false
signal loaded

# TODO for now we are loading all photos, in future may want to only load on demand
# may have to extract uris and refresh them from the server in case of expiry when we get to that

# TODO should also have a failed to load signal or indicator so photo displays can say the link is broken.

func get_uri(url=signed_uri) -> String:
	# i.e. https://app-photos.s3.us-east-2.wasabisys.com/dev-82-2-4c31c0f2-bc69-4b80-a424-1529df1bcd78?x-id=GetObject&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=4TICAV7DV4CE7W2L6FAT%2F20260311%2Fus-east-2%2Fs3%2Faws4_request&X-Amz-Date=20260311T175653Z&X-Amz-Expires=900&X-Amz-SignedHeaders=host&X-Amz-Signature=958e3efb80f235f0df61b81f2d08c0d3c3b9ae5f9f6adcd67ab5d198aad5d68c
	return url.split('.com/')[1].split('?')[0]

func set_url(new_signed_uri:String, load_now:bool=true) -> void:
	signed_uri = new_signed_uri
	if load_now:
		if App.load_photos:
			ObjectStorage.get_texture(signed_uri, _add_photo)

func _add_photo(image:Image) -> void:
	texture = ImageTexture.create_from_image(image)
	loaded.emit()
	is_loaded = true
	

func _to_string() -> String:
	return "ProfilePhoto({})".format([signed_uri], '{}')
