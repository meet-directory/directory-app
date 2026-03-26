extends Resource
class_name SearchCriteria

@export var max_distance:int
@export var max_age:int = 100
@export var min_age:int = 18

@export_category("Tags")
@export var must_match:Array[Tag]
@export var try_match:Array[Tag]
@export var dont_match:Array[Tag]
