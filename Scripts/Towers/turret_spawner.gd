extends Node2D
class_name TurretSpawner

@export var mapGen : MapManager = null

var turrets : Dictionary = {
	
	crossbow = preload("res://Scenes/Towers/Crossbow/crossbow.tscn"),
	crossAmmo = preload("res://Scenes/Towers/Crossbow/crossbow_arrow.tscn")
	
}
var tiles : Array

func _ready() -> void:
	tiles = mapGen.grid


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_global_mouse_position()
		var tile_coords = Vector2i(mouse_pos / mapGen.tile_size)
		if _is_tile_valid(tile_coords):
			var tile_value = tiles[tile_coords.y][tile_coords.x]
			if tile_value != 1:
				var turret : Crossbow = turrets["crossbow"].instantiate()
				turret.global_position = mouse_pos
				self.get_parent().add_child(turret)
			else:
				# en el caso que se clickee en la calle
				pass
func _is_tile_valid(coords: Vector2i) -> bool:
	return coords.x >= 0 and coords.x < mapGen.map_width and coords.y >= 0 and coords.y < mapGen.map_height
