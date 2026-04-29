extends OnboardingStep

@export_multiline var conf_popup_text:String

@onready var months_option: MobileDropDown = %Months
@onready var days_option: MobileDropDown = %Days
#@onready var years_spin_box: SpinBox = %YearsSpinBox
@onready var years_option: MobileDropDown = %Years

var month_days:Dictionary[String, int] = {
	'January': 31,
	'February': 28,
	'March': 31,
	'April': 30,
	'May': 30,
	'June': 30,
	'July': 30,
	'August': 30,
	'September': 30,
	'October': 30,
	'November': 30,
	'December': 30
}

func _ready() -> void:
	months_option.clear()
	for item in month_days.keys():
		months_option.add_item(item)
	var current_year = Time.get_date_dict_from_system()['year']
	#years_spin_box.max_value = current_year
	years_option.clear()
	for y in range(current_year, 1930, -1):
		years_option.add_item(str(y))
	
	years_option.select(0)
	months_option.select(0)

func _on_months_item_selected(index: int) -> void:
	var month = months_option.get_item_text(index)
	var day_amount = month_days[month]
	days_option.clear()
	for i in range(1, day_amount + 1):
		days_option.add_item(str(i))
	
	days_option.selected = clamp(days_option.selected, 0, day_amount-1)

func _get_birthdate() -> Dictionary:
	#var year = int(years_spin_box.get_line_edit().text)
	var year = years_option.get_item_text(years_option.selected)
	var month = months_option.get_item_text(months_option.selected)
	var day = days_option.get_item_id(days_option.selected) + 1
	var month_idx = months_option.get_item_id(months_option.selected) + 1
	var date_dict = {
		'year': year,
		'month': month_idx,
		'month_str': month,
		'day':day
	}
	return date_dict

func _over_18(date_dict:Dictionary) -> bool:
	var year = int(date_dict['year'])
	var month = date_dict['month']
	var day = date_dict['day']
	
	var current_dict = Time.get_date_dict_from_system()
	var cyear = current_dict['year']
	var cmonth = current_dict['month']
	var cday = current_dict['day']
	
	if cyear - year > 18:
		return true
	
	if cyear - year == 18:
		if cmonth > month:
			return true
		elif cmonth == month:
			if cday >= day:
				return true
	return false

func _on_confirm_birthdate_button_pressed() -> void:
	var d = _get_birthdate()
	var date_str:String = '{} {} {}'.format([d['month_str'], d['day'], d['year']], '{}')
	var popup:ConfirmationPopup = App.show_conf_popup(conf_popup_text.format([date_str], '{}'))
	popup.confirm_pressed.connect(_on_date_confirmed)

func _on_date_confirmed() -> void:
	if _over_18(_get_birthdate()):
		var birthday_dict = _get_birthdate()
		var birthday_string = '{}-{}-{}'.format([birthday_dict['year'], birthday_dict['month'], birthday_dict['day']], '{}')
		info_added.emit('birthdate', birthday_string)
		confirmed.emit()
	else:
		App.show_info_popup("Sorry, you must be over 18 to participate on Directory.")
