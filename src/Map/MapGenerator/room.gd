class_name Room
extends Resource

@export var position: Vector2i
@export var size: Vector2i
@export var data: Array[int]


func initialize(size: Vector2i, initial_tile: int) -> void:
	self.size = size
	data = []
	data.resize(size.x * size.y)
	data.fill(initial_tile)


func get_tile(room_position: Vector2i) -> int:
	return data[_to_index(room_position)]


func set_tile(room_position: Vector2i, tile: int) -> void:
	data[_to_index(room_position)] = tile


func _to_index(room_position: Vector2i) -> int:
	assert(is_in_bounds(room_position))
	return room_position.y * size.x + room_position.x


func is_in_bounds(room_position: Vector2i) -> bool:
	return room_position.x >= 0 and room_position.x < size.x and room_position.y >= 0 and room_position.y < size.y


func get_neighbors(room_position: Vector2i, default: int) -> Array[int]:
	var neighbors: Array[int] = []
	
	for offset: Vector2i in [Vector2i.RIGHT, Vector2i.UP, Vector2i.LEFT, Vector2i.DOWN]:
		var neighbor_position := room_position + offset
		if is_in_bounds(neighbor_position):
			neighbors.append(get_tile(neighbor_position))
		else:
			neighbors.append(default)
	
	return neighbors


func get_tiles(tile_type: int) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for x: int in size.x:
		for y: int in size.y:
			var tile_position := Vector2i(x, y)
			if get_tile(tile_position) == tile_type:
				out.append(tile_position)
	return out


func get_outer_tiles(direction: Vector2i, tile_type: int) -> Array[Vector2i]:
	var outer_tiles: Array[Vector2i] = []
	
	if direction == Vector2i.LEFT or direction == Vector2i.RIGHT:
		# Column
		var x: int = 0 if direction == Vector2i.LEFT else size.x - 1
		for y: int in size.y:
			var tile_pos := Vector2i(x, y)
			if get_tile(tile_pos) == tile_type:
				outer_tiles.append(tile_pos)
	else:
		# Row
		var y: int = 0 if direction == Vector2i.UP else size.y - 1
		for x: int in size.x:
			var tile_pos := Vector2i(x, y)
			if get_tile(tile_pos) == tile_type:
				outer_tiles.append(tile_pos)
				
	return outer_tiles
