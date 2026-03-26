extends TabContainer


func _on_tab_manager_tab_pressed(index: int) -> void:
	current_tab = index
	for i in get_child_count():
		var tab = get_child(i)
		if i == current_tab:
			if tab.has_method("selected"):
				tab.selected()
		else:
			if tab.has_method("deselected"):
				tab.deselected()
