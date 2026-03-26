extends Control
class_name PhotoEditViewer

func set_photos(photos:Array[ProfilePhoto]) -> void:
	for node in get_children():
		node.reset()
	for i in len(photos):
		get_child(i).set_default(photos[i])

func get_uris() -> Array[String]:
	var uris:Array[String] = []
	for child in get_children():
		if child is PhotoEditButton:
			if child.uri:
				uris.append(child.uri)
	print('return URIS ', len(uris), '\n', uris)
	return uris
