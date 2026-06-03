extends Node

const mobile_scales: Dictionary[int, float] = {
	150: 0.5,
	250: 1.5,
	401: 1.5,
	600: 2.0,
	999999: 3.0,
}
const desktop_scale := 1.5


const CALIBRATION := {
	"ios": 1.0,
	"android": 1.45,
	"web": 0.7,
}

func _ready() -> void:
	_on_viewport_size_changed()

func _on_viewport_size_changed() -> void:
	match App.version:
		App.VERSIONS.MOBILE:
			var calib: float = CALIBRATION["android"] if OS.get_name() == "Android" else CALIBRATION["ios"]
			_apply_mobile_scale(calib)
		App.VERSIONS.MOBILE_WEB:
			_apply_mobile_scale(CALIBRATION["web"])
		App.VERSIONS.DESKTOP_WEB:
			get_window().content_scale_factor = desktop_scale

func _apply_mobile_scale(calibration: float) -> void:
	var screen_scale: float = DisplayServer.screen_get_scale()
	var size := get_viewport().get_visible_rect().size
	# Bucket on LOGICAL points, not raw pixels — this is the iOS fix.
	var logical_width := size.x / screen_scale

	var keys := mobile_scales.keys()
	keys.sort()
	for px_size in keys:
		if logical_width < px_size:
			var scale: float = mobile_scales[px_size] * screen_scale * calibration
			App.app_scale = scale
			get_window().content_scale_factor = scale
			return

func apply_safe_area(ui_root: Control) -> void:
	var safe := DisplayServer.get_display_safe_area()
	var full := DisplayServer.window_get_size()
	var scale: float = get_window().content_scale_factor

	# Insets in physical pixels...
	#var left := safe.position.x
	var top := safe.position.y
	#var right := full.x - (safe.position.x + safe.size.x)
	#var bottom := full.y - (safe.position.y + safe.size.y)

	# ...converted into the scaled UI coordinate space.
	#ui_root.add_theme_constant_override("margin_left", int(left / scale))
	ui_root.add_theme_constant_override("margin_top", int(top / scale))
	#ui_root.add_theme_constant_override("margin_right", int(right / scale))
	#ui_root.add_theme_constant_override("margin_bottom", int(bottom / scale))
