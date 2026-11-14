extends Control
## A replaceable screen-space vignette. It stays above world art and below UI.

var tint := Color(0.015, 0.025, 0.045, 0.52)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	position = Vector2.ZERO
	size = Vector2(960, 540)


func set_tint(value: Color) -> void:
	tint = value
	queue_redraw()


func _draw() -> void:
	for step in range(20):
		var width := 6.0 + float(step) * 4.2
		var alpha := tint.a * (1.0 - float(step) / 20.0) * 0.18
		var edge := Color(tint.r, tint.g, tint.b, alpha)
		draw_rect(Rect2(0, 0, size.x, width), edge)
		draw_rect(Rect2(0, size.y - width, size.x, width), edge)
		draw_rect(Rect2(0, 0, width, size.y), edge)
		draw_rect(Rect2(size.x - width, 0, width, size.y), edge)
