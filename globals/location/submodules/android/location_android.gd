extends LocationFinder
class_name LocationFinderAndroid

var _handler
var _consumer


func has_location_permission() -> bool:
	return "android.permission.ACCESS_COARSE_LOCATION" in OS.get_granted_permissions()

## Ensure we have the permission, then poll for current location
func request_location():
	if has_location_permission():
		_poll_location()
		return
		
	OS.request_permission("android.permission.ACCESS_COARSE_LOCATION")
	get_tree().on_request_permissions_result.connect(func (permission: String, granted: bool) -> void:
		if permission == "android.permission.ACCESS_COARSE_LOCATION":
			if granted:
				_poll_location()
			else:
				App.show_info_popup("Directory might not show accurate results without the location permission. Please grant the location permission in the settings.")
		)

func _poll_location():
	# Retrieve the AndroidRuntime singleton
	var android_runtime = Engine.get_singleton("AndroidRuntime")
	if android_runtime:
		# Retrieve the android LocationManager
		var context = android_runtime.getApplicationContext()
		var lm = context.getSystemService("location")
		if lm == null:
			print("failed to get location manager")
			return
		
		# Choose the best provider available
		var provider := ""
		for candidate in ["fused", "gps", "network"]:
			if lm.isProviderEnabled(candidate):
				provider = candidate
				break
		
		# If no provider is available, location services is probably off and we should notify the user
		if provider == "":
			# If we don't wait a second, the popup will reappear immediately and the usesr may think nothing happened
			await get_tree().create_timer(0.5).timeout
			var conf:ConfirmationPopup = App.show_conf_popup(
				"Is location services turned on? Without your current location, " +
				"Directory can't update your search results.", 
				"Use anyway", 
				"Try again")
			conf.confirm_pressed.connect(_poll_location)
			return
		
		# 1. First check for a cached location
		var last = lm.getLastKnownLocation(provider)
		if last != null:
			got_location.emit(last.getLatitude(), last.getLongitude())
		else:
			# 2. If cached location isn't available, poll for a new one
			var executor = context.getMainExecutor()
			_handler = LocationConsumer.new()
			_handler.got_location.connect(func(location):
				if location == null:
					_emit_failed.call_deferred("Provider returned null")
					return
				_emit_received.call_deferred(
					location.getLatitude(),
					location.getLongitude(),
					location.getAccuracy()
				)
			)
			_consumer = JavaClassWrapper.create_proxy(
				_handler,
				["java.util.function.Consumer"]
			)
		
			var CancellationSignalCls = JavaClassWrapper.wrap("android.os.CancellationSignal")
			var cancel = CancellationSignalCls.CancellationSignal()
			# 7. Fire the one-shot request
			# TODO this can take a while and delay search results from displaying
			# In this case we should notify the user of the delay
			# or search anyway if the user has a location stored on the server already
			lm.getCurrentLocation(provider, cancel, executor, _consumer)
			
			# Don't wait too long on location update if gps is being slow.
			# also this might be required?
			get_tree().create_timer(15.0).timeout.connect(func():
				if cancel:
					cancel.cancel()
			)

func _emit_received(lat: float, lon: float, _acc: float) -> void:
	got_location.emit(lat, lon)

func _emit_failed(reason: String) -> void:
	location_request_failed.emit()
	print("Failed to request location :", reason)
