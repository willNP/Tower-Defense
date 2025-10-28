class_name PathController
extends RefCounted


var parent: Node
var tile_size: int = 64
var path_node_name: String = "MobPath"
var icon_texture: Texture2D
var icon_scale: float = 0.3
var show_debug_icon: bool = true
var show_path: bool = true

var _path_node: Path2D
var _path_follow: PathFollow2D
var _debug_icon: Sprite2D
var _debug_tween: Tween


func setup(parent_node: Node, config: Dictionary) -> void:
	parent = parent_node
	tile_size = config.get("tile_size", tile_size)
	path_node_name = config.get("path_node_name", path_node_name)
	icon_texture = config.get("icon_texture", icon_texture)
	icon_scale = config.get("icon_scale", icon_scale)
	show_debug_icon = config.get("show_debug_icon", show_debug_icon)
	show_path = config.get("show_path", show_path)

	_ensure_path_node()
	if not show_debug_icon:
		_remove_debug_icon()


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

	if show_debug_icon:
		_update_debug_icon(curve)
	else:
		_remove_debug_icon()


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


func _update_debug_icon(curve: Curve2D) -> void:
	_ensure_debug_icon()
	if _path_follow == null:
		return

	if _debug_tween and _debug_tween.is_running():
		_debug_tween.kill()

	if curve == null or curve.get_point_count() == 0:
		_path_follow.progress_ratio = 0.0
		return

	_path_follow.progress_ratio = 0.0

	var path_length: float = curve.get_baked_length()
	var duration: float = max(path_length / float(tile_size) * 0.5, 1.5)

	if parent:
		_debug_tween = parent.create_tween()
		_debug_tween.tween_property(_path_follow, "progress_ratio", 1.0, duration)


func _ensure_debug_icon() -> void:
	if not show_debug_icon:
		_remove_debug_icon()
		return

	if _path_follow and is_instance_valid(_path_follow):
		if _path_follow.get_parent() != _path_node and _path_node:
			_path_follow.get_parent().remove_child(_path_follow)
			_path_node.add_child(_path_follow)
		_path_follow.z_as_relative = false
		_path_follow.z_index = 101
		_ensure_icon_node()
		return

	if _path_node == null:
		return

	_path_follow = PathFollow2D.new()
	_path_follow.name = "DebugPathFollow"
	_path_follow.rotates = false
	_path_follow.loop = false
	_path_follow.z_as_relative = false
	_path_follow.z_index = 101

	_ensure_icon_node()

	_path_node.add_child(_path_follow)


func _ensure_icon_node() -> void:
	if _debug_icon and is_instance_valid(_debug_icon):
		_debug_icon.visible = true
		_debug_icon.z_as_relative = false
		_debug_icon.z_index = 102
		return

	if icon_texture == null:
		return

	_debug_icon = Sprite2D.new()
	_debug_icon.texture = icon_texture
	_debug_icon.centered = true
	_debug_icon.scale = Vector2(icon_scale, icon_scale)
	_debug_icon.z_as_relative = false
	_debug_icon.z_index = 102
	_path_follow.add_child(_debug_icon)


func _remove_debug_icon() -> void:
	if _debug_tween and _debug_tween.is_running():
		_debug_tween.kill()

	if _debug_icon and is_instance_valid(_debug_icon):
		_debug_icon.queue_free()
	_debug_icon = null

	if _path_follow and is_instance_valid(_path_follow):
		_path_follow.queue_free()
	_path_follow = null
