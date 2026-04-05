extends Control
class_name TagEditor
@export var container:Control
@onready var tag_category_option: OptionButton = %TagCategoryOption
@onready var tag_edit_preview: TagControl = %TagEditPreview
@onready var scroll_container: ScrollContainer = %ScrollContainer

signal closed
signal canceled

func _ready() -> void:
	tag_category_option.item_selected.connect(_on_category_changed)

func _on_category_changed(index:int):
	tag_edit_preview.set_type(index)

func _on_add_tag_button_pressed() -> void:
	expand()

func set_tag_text(text:String) -> void:
	tag_edit_preview.set_text(text)

func expand():
	scroll_container.scroll_vertical = 0
	var tween:Tween = create_tween()
	var height = container.size.y
	tween.tween_property(self, "custom_minimum_size:y", height, 0.5)

func close():
	var tween:Tween = create_tween()
	tween.tween_property(self, "custom_minimum_size:y", 0, 0.2)

func _on_submit_button_pressed() -> void:
	var tag_name = tag_edit_preview.get_tag_name()
	var tag_cat = Tag.raw_to_type.find_key(tag_edit_preview.type)
	var text = "Creating tag with name {} and category {}. Are you sure?".format([tag_name, tag_cat])
	var conf:ConfirmationPopup = App.show_conf_popup(text)
	conf.confirm_pressed.connect(_on_conf)

func _on_conf():
	Server.create_tag(tag_edit_preview.get_tag_name(), tag_edit_preview.type, _on_submitted_tag)
	

func _on_submitted_tag(resp_code:int, _resp) -> void:
	match resp_code:
		200:
			App.show_info_popup("The tag was sucessfully submitted to the public Server. Thank you for your contribution!")
			close()
			closed.emit()
		_: Server.show_default_error_msg(resp_code)

func _on_cancel_button_pressed() -> void:
	close()
	canceled.emit()
