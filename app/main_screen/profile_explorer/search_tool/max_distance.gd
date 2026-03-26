extends HBoxContainer
#@onready var h_slider: HSlider = $MaxDistanceSlider
#@onready var dist_amount_label: Label = %DistAmountLabel


#
#
#func _on_h_slider_value_changed(value: float) -> void:
	#dist_amount_label.text = str(round(value))


func _on_double_slider_value_changed(min_val: float, max_val: float) -> void:
	pass # Replace with function body.
