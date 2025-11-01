class_name MapGenerator
extends RefCounted


var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func randomize(_seed: int = 0, use_seed: bool = false) -> void:
	if use_seed:
		_rng.seed = _seed
	else:
		_rng.randomize()


func generate(width: int, height: int, params: Dictionary) -> MapData:
	var max_horizontal_steps: int = params.get("max_horizontal_steps", 3)
	var max_vertical_steps: int = params.get("max_vertical_steps", 4)
	var border_margin: int = params.get("border_margin", 1)
	var start_center_columns: int = params.get("start_center_columns", 6)
	var start_center_band: int = params.get("start_center_band", 6)

	if width <= 0 or height <= 0:
		push_warning("MapGenerator: width and height must be positive values.")
		return MapData.new()

	var map: Array = []
	var path_points: Array[Vector2] = []

	for _y in range(height):
		var row: Array[int] = []
		for _x in range(width):
			row.append(0)
		map.append(row)

	var min_y: int = max(0, border_margin)
	var max_y: int = min(height - 1, height - 1 - border_margin)

	var center_y: int = int(height / 2)
	var band_half: int = int(start_center_band / 2)
	var start_min_y: int = int(clamp(center_y - band_half, min_y, max_y))
	var start_max_y: int = int(clamp(center_y + band_half, min_y, max_y))
	if start_min_y > start_max_y:
		start_min_y = start_max_y

	var x: int = 0
	var y: int = _rng.randi_range(start_min_y, start_max_y)
	map[y][x] = 1
	_append_path_point(path_points, x, y)

	while x < width - 1:
		var right_steps: int = _rng.randi_range(1, max_horizontal_steps)
		for _i in range(right_steps):
			if x >= width - 1:
				break
			x += 1
			map[y][x] = 1
			_append_path_point(path_points, x, y)

		if x >= width - 1:
			break

		var vertical_directions: Array[int] = []
		if y > min_y:
			vertical_directions.append(-1)
		if y < max_y:
			vertical_directions.append(1)

		if vertical_directions.is_empty():
			continue

		var vertical_steps: int = _rng.randi_range(1, max_vertical_steps)
		var direction: int = vertical_directions[_rng.randi_range(0, vertical_directions.size() - 1)]
		for _j in range(vertical_steps):
			var next_y: int = y + direction
			if next_y < min_y or next_y > max_y:
				break

			if x < start_center_columns:
				var within_band: bool = next_y >= start_min_y and next_y <= start_max_y
				if not within_band:
					break

			y = next_y
			map[y][x] = 1
			_append_path_point(path_points, x, y)

	var data: MapData = MapData.new()
	data.set_grid(map)
	data.set_path_points(path_points)
	return data


func _append_path_point(path_points: Array[Vector2], x: int, y: int) -> void:
	var point: Vector2 = Vector2(x, y)
	if path_points.is_empty() or path_points[path_points.size() - 1] != point:
		path_points.append(point)
