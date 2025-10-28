class_name MapData
extends RefCounted


var grid: Array = []
var path_points: Array[Vector2] = []


func set_grid(value: Array) -> void:
	grid = value


func set_path_points(points: Array) -> void:
	path_points.clear()
	for point in points:
		if point is Vector2:
			path_points.append(point)


func get_grid() -> Array:
	return grid


func get_path_points() -> Array[Vector2]:
	return path_points
