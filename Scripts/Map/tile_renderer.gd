class_name TileRenderer
extends RefCounted


var _tiles: Array[Node] = []


func clear() -> void:
	for tile in _tiles:
		if tile and is_instance_valid(tile):
			tile.queue_free()
	_tiles.clear()


func render(parent: Node, grid: Array, tile_size: int, grass_texture: Texture2D, path_texture: Texture2D) -> void:
	clear()

	for y in range(grid.size()):
		var row: Array = grid[y]
		if typeof(row) != TYPE_ARRAY:
			continue

		for x in range(row.size()):
			var tile_value: int = row[x]
			var tile_texture: Texture2D = _resolve_texture(tile_value, grass_texture, path_texture)
			if tile_texture == null:
				continue

			var sprite: Sprite2D = Sprite2D.new()
			sprite.texture = tile_texture
			sprite.centered = false
			sprite.scale = Vector2(
				tile_size / float(tile_texture.get_width()),
				tile_size / float(tile_texture.get_height())
			)
			sprite.position = Vector2(x, y) * tile_size
			parent.add_child(sprite)
			_tiles.append(sprite)


func _resolve_texture(tile_value: int, grass_texture: Texture2D, path_texture: Texture2D) -> Texture2D:
	match tile_value:
		0:
			return grass_texture
		1:
			return path_texture
		_:
			return null
