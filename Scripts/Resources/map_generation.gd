extends Node2D
class_name MapManager

signal path_updated(curve: Curve2D, path_points: Array[Vector2])


@export_group("Map Dimensions")
@export var tile_size: int = 64
@export var map_width: int = 39
@export var map_height: int = 24

@export_group("Path Shape")
@export var max_horizontal_steps: int = 3
@export var max_vertical_steps: int = 4
@export var border_margin: int = 1
@export var start_center_columns: int = 6
@export var start_center_band: int = 6

@export_group("Visuals")
@export var grass_texture: Texture2D = preload("res://Resources/Images/Maps/grass.png")
@export var path_texture: Texture2D = preload("res://Resources/Images/Maps/path.png")
@export var show_path: bool = true
@export var show_debug_icon: bool = true
@export var debug_icon_scale: float = 0.3
@export var debug_icon_texture: Texture2D = preload("res://icon.svg")

@export_group("Path Nodes")
@export var path_node_name: String = "MobPath"

var _map_generator: MapGenerator = MapGenerator.new()
var _tile_renderer: TileRenderer = TileRenderer.new()
var _path_controller: PathController = PathController.new()
var _map_data: MapData

var grid: Array = []



func _ready() -> void:
	_map_generator.randomize()
	_configure_path_controller()
	generate_map()


func generate_map(seed: int = 0, use_seed: bool = false) -> void:
	_configure_path_controller()
	_map_generator.randomize(seed, use_seed)
	_map_data = _map_generator.generate(map_width, map_height, _generator_params())
	
	if _map_data == null:
		return

	grid = _map_data.get_grid()
	_tile_renderer.render(self, grid, tile_size, grass_texture, path_texture)

	var path_points: Array[Vector2] = _map_data.get_path_points()
	_path_controller.update_path(path_points)
	var current_curve: Curve2D = _path_controller.get_path_curve()
	path_updated.emit(current_curve, path_points)


func regenerate_with_seed(seed: int) -> void:
	generate_map(seed, true)


func regenerate_random() -> void:
	generate_map()


func clear_tiles() -> void:
	_tile_renderer.clear()


func get_map_data() -> MapData:
	return _map_data


func get_path_points() -> Array[Vector2]:
	if _map_data:
		return _map_data.get_path_points()
	return [] as Array[Vector2]


func get_path_curve() -> Curve2D:
	return _path_controller.get_path_curve()


func get_path_node() -> Path2D:
	return _path_controller.get_path_node()


func _configure_path_controller() -> void:
	var config: Dictionary = {
		"tile_size": tile_size,
		"path_node_name": path_node_name,
		"icon_texture": debug_icon_texture,
		"icon_scale": debug_icon_scale,
		"show_debug_icon": show_debug_icon,
		"show_path": show_path
	}
	_path_controller.setup(self, config)


func _generator_params() -> Dictionary:
	return {
		"max_horizontal_steps": max_horizontal_steps,
		"max_vertical_steps": max_vertical_steps,
		"border_margin": border_margin,
		"start_center_columns": start_center_columns,
		"start_center_band": start_center_band
	}
	
