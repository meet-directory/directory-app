extends MobileDropDown

func _ready() -> void:
	super()
	add_item("No Category Selected")
	for cat in Tag.TYPE:
		var emoji:String = Constants.tag.get_emoji(Tag.TYPE[cat])
		var cat_str:String =  emoji + " " + str(cat)
		add_item(cat_str)
	#select(Tag.TYPE.Other)
		# would be nice to have the background color match tag color
		#add_icon_item(preload("res://icon.svg"), cat)
