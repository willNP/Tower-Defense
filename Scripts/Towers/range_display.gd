extends Node2D
class_name RangeDisplay

var radius: float = 0.0
var color: Color = Color(0.3, 0.6, 1.0, 0.2)
var line_width: float = 2.5
var segments: int = 64
var filled: bool = false


func _draw() -> void:
	if radius <= 0.0 or color.a <= 0.0:
		return
	if filled:
		draw_circle(Vector2.ZERO, radius, color)
	else:
		draw_arc(Vector2.ZERO, radius, 0.0, TAU, segments, color, line_width)


func set_radius(value: float) -> void:
	radius = max(value, 0.0)
	queue_redraw()


func set_color(value: Color) -> void:
	color = value
	queue_redraw()


func set_line_width(value: float) -> void:
	line_width = max(value, 0.0)
	queue_redraw()


func set_filled(value: bool) -> void:
	filled = value
	queue_redraw()
