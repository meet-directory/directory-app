extends Menu
@onready var tag_edit_preview: TagControl = %TagEditPreview
@onready var tag_category_option: MobileDropDown = %TagCategory
@onready var save_tag_button: Button = %SaveTagButton
@onready var warning_box: WarningBox = %WarningBox
@onready var tag_search_bar: VBoxContainer = %TagSearchBar
@onready var warning_box_container: VBoxContainer = %WarningBoxContainer


func _ready() -> void:
	tag_category_option.item_selected.connect(_on_category_changed)
	warning_box.show_warning('empty-name')
	warning_box.show_warning('empty-category')

func _on_category_changed(index:int):
	index -= 1
	warning_box.warn_conditional('empty-category', index == -1)
	if index >= 0:
		tag_edit_preview.set_type(index)


func set_tag_text(text:String) -> void:
	tag_edit_preview.set_text(text)


func _on_tag_search_bar_text_changed(new_text: String) -> void:
	save_tag_button.disabled = true
	tag_edit_preview.set_text(new_text)
	warning_box.warn_conditional('empty-name', new_text.is_empty())

func _on_tag_search_bar_got_results(exact_match:bool) -> void:
	warning_box.warn_conditional('duplicate', exact_match)


func _on_close_button_pressed() -> void:
	closed.emit()

func _on_save_tag_button_pressed() -> void:
	var tag_name = tag_edit_preview.get_tag_name()
	var tag_cat = Tag.raw_to_type.find_key(tag_edit_preview.type)
	var text = "Creating tag with name {} and category {}. Are you sure?".format([tag_name, tag_cat], '{}')
	var conf:ConfirmationPopup = App.show_conf_popup(text)
	conf.confirm_pressed.connect(_on_conf)

func _on_conf():
	Server.create_tag(tag_edit_preview.get_tag_name(), tag_edit_preview.type, _on_submitted_tag)
	
func _on_submitted_tag(resp_code:int, _resp) -> void:
	match resp_code:
		200:
			App.show_info_popup("The tag was sucessfully submitted to the public Server. Thank you for your contribution!")
			closed.emit()
		_: Server.show_default_error_msg(resp_code)

func _on_warning_box_all_warnings_cleared() -> void:
	save_tag_button.disabled = false
	warning_box_container.hide()

func _on_warning_box_warning_activated() -> void:
	save_tag_button.disabled = true
	warning_box_container.show()
