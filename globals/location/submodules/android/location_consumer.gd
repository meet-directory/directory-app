class_name LocationConsumer
extends RefCounted

## Subclass for LocationFinderAndroid that mocks Android's Java Consumer Class

signal got_location(loc)

func accept(location) -> void:
	got_location.emit(location)
