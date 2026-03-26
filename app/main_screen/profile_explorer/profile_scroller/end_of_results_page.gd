extends MarginContainer
class_name EndOfResultsPage
@onready var load_more_tab: CenterContainer = %LoadMoreTab
@onready var end_of_results_tab: CenterContainer = %EndOfResultsTab
@onready var no_results_tab: CenterContainer = %NoResultsTab

signal load_more_requested

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
