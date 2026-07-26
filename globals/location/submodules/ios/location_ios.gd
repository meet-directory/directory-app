extends LocationFinder
class_name LocationFinderIOS

## Uses the LocationPlugin native plugin (ios/plugins/location_plugin), which wraps
## CoreLocation's CLLocationManager and exposes it as a singleton with signals.

## These are Apple's actual raw CLAuthorizationStatus values
enum AuthStatus {
	NOT_DETERMINED = 0,
	RESTRICTED = 1,
	DENIED = 2,
	AUTHORIZED_ALWAYS = 3,
	AUTHORIZED_WHEN_IN_USE = 4,
}

## Reported by the plugin's LocationStatusUpdated signal
enum LocStatus {
	IDLE,
	IN_USE,
	NOT_ENABLED,
	STOPPED,
}

var _plugin


## Ensure we have location permission, then start CoreLocation updates
func request_location():
	_plugin = _get_plugin()
	if not _plugin:
		print("LocationPlugin singleton not available")
		location_request_failed.emit()
		return

	if not _plugin.is_connected("LocationUpdated", _on_location_updated):
		_plugin.connect("LocationUpdated", _on_location_updated)
		_plugin.connect("AuthorizationStatusUpdated", _on_authorization_status_updated)
		_plugin.connect("LocationStatusUpdated", _on_location_status_updated)

	# Safe to call every time: iOS only shows the system permission prompt once,
	# further calls just report back the already-determined status.
	_plugin.AskLocationAccess()

func _get_plugin():
	if Engine.has_singleton("LocationPlugin"):
		return Engine.get_singleton("LocationPlugin")
	return null

func _on_authorization_status_updated(status: int) -> void:
	match status:
		AuthStatus.AUTHORIZED_ALWAYS, AuthStatus.AUTHORIZED_WHEN_IN_USE:
			_plugin.StartLocationService()
		AuthStatus.DENIED, AuthStatus.RESTRICTED:
			App.show_info_popup("Directory might not show accurate results without the location permission. Please grant the location permission in the settings.")

func _on_location_status_updated(status: int) -> void:
	if status == LocStatus.NOT_ENABLED:
		# If we don't wait a second, the popup will reappear immediately and the user may think nothing happened
		await get_tree().create_timer(0.5).timeout
		var conf:ConfirmationPopup = App.show_conf_popup(
			"Is location services turned on? Without your current location, " +
			"Directory can't update your search results.",
			"Use anyway",
			"Try again")
		conf.confirm_pressed.connect(request_location)

func _on_location_updated(lat: float, lon: float) -> void:
	# One-shot: location_service.gd handles its own polling interval
	_plugin.StopLocationService()
	got_location.emit(lat, lon)
