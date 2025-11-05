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
var selected_turret: StringName = ""
var _map_controller: Map_1
var _showing_guides: bool = false
var _preview_turret: Tower
var _preview_type: StringName = ""
var _preview_valid: bool = false
const RANGE_HIGHLIGHT_COLOR := Color(0.3, 0.9, 0.4, 0.6)
const SPAWN_HIGHLIGHT_COLOR := Color(1.0, 0.6, 0.4, 0.45)

func _ready() -> void:
	if mapGen:
		tiles = mapGen.grid
	_map_controller = get_parent() as Map_1
	set_process(true)
	_refresh_preview_turret()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("salir"):
		set_selected_turret("")
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not mapGen or tiles.is_empty():
			return
		tiles = mapGen.grid
		var mouse_pos = get_global_mouse_position()
		var tile_coords = Vector2i(mouse_pos / mapGen.tile_size)
		if _is_tile_valid(tile_coords):
			var tile_value = tiles[tile_coords.y][tile_coords.x]
			if tile_value != 1:
				if not turrets.has(selected_turret):
					return
				if _map_controller == null:
					return
				if not _is_position_buildable(mouse_pos, selected_turret):
					return
				if not _map_controller.try_purchase_turret(selected_turret):
					return
				var turret_scene: PackedScene = turrets[selected_turret]
				var turret : Tower = turret_scene.instantiate()
				turret.global_position = mouse_pos
				self.get_parent().add_child(turret)
				set_selected_turret("")
			else:
				# en el caso que se clickee en la calle
				pass
func _is_tile_valid(coords: Vector2i) -> bool:
	return coords.x >= 0 and coords.x < mapGen.map_width and coords.y >= 0 and coords.y < mapGen.map_height


func set_selected_turret(turret_name: StringName) -> void:
	var new_selection: StringName = turret_name
	if new_selection != "" and not turrets.has(new_selection):
		return

	if new_selection == "":
		selected_turret = ""
		_clear_preview()
		_show_default_guides()
		if _map_controller:
			_map_controller.on_turret_selection_changed(selected_turret)
		return

	if selected_turret == new_selection:
		return

	selected_turret = new_selection
	_refresh_preview_turret()
	_show_range_guides_for_selection()
	if _map_controller:
		_map_controller.on_turret_selection_changed(selected_turret)

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

func _is_position_buildable(position: Vector2, turret_type: StringName) -> bool:
	if mapGen == null:
		return false
	if turret_type == "":
		return false
	tiles = mapGen.grid
	var tile_coords: Vector2i = Vector2i(position / mapGen.tile_size)
	if not _is_tile_valid(tile_coords):
		return false
	if tiles[tile_coords.y][tile_coords.x] == 1:
		return false
	if not _can_place_turret(position, turret_type):
		return false
	if _map_controller and not _map_controller.can_afford_turret(turret_type):
		return false
	return true

func _process(_delta: float) -> void:
	_update_preview()
	if _showing_guides:
		_update_guides()

func _hide_all_guides() -> void:
	var parent_node: Node = get_parent()
	if parent_node == null:
		return
	for child in parent_node.get_children():
		if child is Tower:
			var tower: Tower = child as Tower
			if tower.is_preview():
				continue
			tower.reset_range_color()
			tower.hide_spawn_block_indicator()
	_showing_guides = false

func _show_range_guides_for_selection() -> void:
	_hide_all_guides()
	var parent_node: Node = get_parent()
	if parent_node == null:
		return
	for child in parent_node.get_children():
		if child is Tower:
			var tower: Tower = child as Tower
			if tower.is_preview():
				continue
			if tower.get_turret_type() == selected_turret:
				tower.set_range_color(RANGE_HIGHLIGHT_COLOR)
				tower.hide_spawn_block_indicator()
			else:
				tower.show_spawn_block_indicator(SPAWN_HIGHLIGHT_COLOR)
	_showing_guides = true

func _show_default_guides() -> void:
	_hide_all_guides()
	var parent_node: Node = get_parent()
	if parent_node == null:
		return
	for child in parent_node.get_children():
		if child is Tower:
			var tower: Tower = child as Tower
			if tower.is_preview():
				continue
			tower.show_default_range_indicator()
			tower.hide_spawn_block_indicator()
	_showing_guides = false

func _update_guides() -> void:
	if selected_turret == "":
		return
	var parent_node: Node = get_parent()
	if parent_node == null:
		return
	for child in parent_node.get_children():
		if child is Tower:
			var tower: Tower = child as Tower
			if tower.is_preview():
				continue
			if tower.get_turret_type() == selected_turret:
				tower.set_range_color(RANGE_HIGHLIGHT_COLOR)
				tower.hide_spawn_block_indicator()
			else:
				tower.show_spawn_block_indicator(SPAWN_HIGHLIGHT_COLOR)

func _exit_tree() -> void:
	_hide_all_guides()
	_clear_preview()

func _refresh_preview_turret() -> void:
	_clear_preview()
	if selected_turret == "":
		return
	if not turrets.has(selected_turret):
		return
	var scene: PackedScene = turrets[selected_turret]
	var instance: Node = scene.instantiate()
	if not (instance is Tower):
		instance.queue_free()
		return
	var preview: Tower = instance as Tower
	preview.set_preview_mode(true)
	add_child(preview)
	_preview_turret = preview
	_preview_type = selected_turret

func _clear_preview() -> void:
	if _preview_turret and is_instance_valid(_preview_turret):
		_preview_turret.queue_free()
	_preview_turret = null
	_preview_type = ""
	_preview_valid = false

func _update_preview() -> void:
	if selected_turret == "":
		return
	if _preview_turret == null or not is_instance_valid(_preview_turret):
		return
	if selected_turret != _preview_type:
		_refresh_preview_turret()
		return
	if mapGen:
		tiles = mapGen.grid

	var mouse_pos: Vector2 = get_global_mouse_position()
	_preview_turret.global_position = mouse_pos
	_preview_valid = _is_position_buildable(mouse_pos, selected_turret)

	var valid_color: Color = Tower.PREVIEW_RANGE_COLOR
	var invalid_color: Color = Tower.PREVIEW_INVALID_COLOR
	_preview_turret.modulate = valid_color if _preview_valid else invalid_color
	_preview_turret.set_range_color(valid_color if _preview_valid else invalid_color)
