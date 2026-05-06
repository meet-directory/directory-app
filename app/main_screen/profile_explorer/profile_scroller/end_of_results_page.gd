extends MarginContainer
class_name EndOfResultsPage
@onready var load_more_tab: CenterContainer = %LoadMoreTab
@onready var end_of_results_tab: CenterContainer = %EndOfResultsTab
@onready var no_results_tab: CenterContainer = %NoResultsTab
@onready var no_location_tab: CenterContainer = %NoLocationTab
@onready var no_loc_label: Label = %NoLocLabel

signal load_more_requested

const BROWSER_NO_LOCATION_TEXT = "It looks like you don't have a location!\nTry refreshing the page and enabling location settings, then refresh your search!"

func _ready() -> void:
	# matches ProfileView
	#custom_minimum_size.x = App.get_screen_size().x - 20
	custom_minimum_size.x = App.PROFILE_VIEW_WIDTH


func _on_load_more_button_pressed() -> void:
	load_more_requested.emit()

func show_eor():
	end_of_results_tab.show()

func show_nor():
	no_results_tab.show()

func show_no_loc():
	match OS.get_name():
		"Web":
			no_loc_label.text = BROWSER_NO_LOCATION_TEXT
	no_location_tab.show()
	
