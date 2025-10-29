class_name PathController
extends RefCounted


var parent: Node
var tile_size: int = 64
var path_node_name: String = "MobPath"
var show_path: bool = true

var _path_node: Path2D


func setup(parent_node: Node, config: Dictionary) -> void:
	parent = parent_node
	tile_size = config.get("tile_size", tile_size)
	path_node_name = config.get("path_node_name", path_node_name)
	show_path = config.get("show_path", show_path)

	_ensure_path_node()


func update_path(points: Array[Vector2]) -> void:
	_ensure_path_node()

	var curve: Curve2D = Curve2D.new()
	for point in points:
		if not (point is Vector2):
			continue
		var position: Vector2 = (point + Vector2(0.5, 0.5)) * tile_size
		curve.add_point(position)

	_path_node.curve = curve
	_path_node.visible = show_path


func get_path_curve() -> Curve2D:
	_ensure_path_node()
	return _path_node.curve


func get_path_node() -> Path2D:
	_ensure_path_node()
	return _path_node


func _ensure_path_node() -> void:
	if _path_node and is_instance_valid(_path_node):
		_path_node.visible = show_path
		_path_node.z_as_relative = false
		_path_node.z_index = 100
		return

	if parent == null:
		return

	_path_node = parent.get_node_or_null(path_node_name)
	if _path_node == null:
		_path_node = Path2D.new()
		_path_node.name = path_node_name
		parent.add_child(_path_node)

	_path_node.visible = show_path
	_path_node.z_as_relative = false
	_path_node.z_index = 100
