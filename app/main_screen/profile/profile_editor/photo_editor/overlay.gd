# overlay.gd
extends Control

@export var crop_area:ReferenceRect
@export var dim_color: Color = Color(0, 0, 0, 0.6)

func _ready():
	mouse_filter = MOUSE_FILTER_IGNORE  # let clicks pass through to photo

func _draw():
	var crop_rect:Rect2 = crop_area.get_rect()
	var full := Rect2(Vector2.ZERO, size)
	# Draw 4 rects surrounding the crop hole
	draw_rect(Rect2(0, 0, full.size.x, crop_rect.position.y), dim_color)  # top
	draw_rect(Rect2(0, crop_rect.end.y, full.size.x, full.size.y - crop_rect.end.y), dim_color)  # bottom
	draw_rect(Rect2(0, crop_rect.position.y, crop_rect.position.x, crop_rect.size.y), dim_color)  # left
	draw_rect(Rect2(crop_rect.end.x, crop_rect.position.y, full.size.x - crop_rect.end.x, crop_rect.size.y), dim_color)  # right
	# Crop border
	draw_rect(crop_rect, Color.WHITE, false, 2.0)
