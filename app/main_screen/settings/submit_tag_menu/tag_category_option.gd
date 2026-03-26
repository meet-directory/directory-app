extends OptionButton

func _ready() -> void:
	add_item("No Category Selected")
	for cat in Tag.TYPE:
		var emoji:String = Constants.tag.get_emoji(Tag.TYPE[cat])
		if cat == 'Desire':
			cat = 'Sex'
		var cat_str:String =  emoji + " " + str(cat)
		add_item(cat_str)
	#select(Tag.TYPE.Other)
		# would be nice to have the background color match tag color
		#add_icon_item(preload("res://icon.svg"), cat)
