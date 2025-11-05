extends Node2D
class_name TurretSpawner

@export var mapGen : MapManager = null

var turrets : Dictionary = {
	cannon = preload("res://Scenes/Towers/Canon/Canon.tscn"),
	crossbow = preload("res://Scenes/Towers/Crossbow/Crossbow.tscn")
}

var ammo : Dictionary = {
	cannonBall = preload("res://Scenes/Towers/Canon/cannon_ball.tscn"),
	crossbowArrow = preload("res://Scenes/Towers/Crossbow/CrossbowArrow.tscn")
}
var tiles : Array
var selected_turret: StringName = "cannon"
var _map_controller: Map_1

func _ready() -> void:
	if mapGen:
		tiles = mapGen.grid
	_map_controller = get_parent() as Map_1


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not mapGen or tiles.is_empty():
			return
		var mouse_pos = get_global_mouse_position()
		var tile_coords = Vector2i(mouse_pos / mapGen.tile_size)
		if _is_tile_valid(tile_coords):
			var tile_value = tiles[tile_coords.y][tile_coords.x]
			if tile_value != 1:
				if not turrets.has(selected_turret):
					return
				if _map_controller == null:
					return
				if not _can_place_turret(mouse_pos, selected_turret):
					return
				if not _map_controller.try_purchase_turret(selected_turret):
					return
				var turret_scene: PackedScene = turrets[selected_turret]
				var turret : Tower = turret_scene.instantiate()
				turret.global_position = mouse_pos
				self.get_parent().add_child(turret)
			else:
				# en el caso que se clickee en la calle
				pass
func _is_tile_valid(coords: Vector2i) -> bool:
	return coords.x >= 0 and coords.x < mapGen.map_width and coords.y >= 0 and coords.y < mapGen.map_height


func set_selected_turret(turret_name: StringName) -> void:
	if turrets.has(turret_name):
		selected_turret = turret_name

func _can_place_turret(position: Vector2, turret_type: StringName) -> bool:
	var parent_node: Node = get_parent()
	if parent_node == null:
		return false

	for child in parent_node.get_children():
		if child is Tower:
			var existing: Tower = child as Tower
			if existing.get_turret_type() == turret_type:
				if existing.is_position_within_range(position):
					print("No se puede colocar otra torreta %s dentro de su rango existente." % str(turret_type))
					return false
			else:
				if existing.is_position_within_spawn_block(position):
					print("No se puede colocar una torreta %s dentro del área de %s." % [str(turret_type), str(existing.get_turret_type())])
					return false
	return true
