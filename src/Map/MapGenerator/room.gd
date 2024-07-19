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


func get_neighbors(room_position: Vector2i, default: int, cardinal_only: bool = true) -> Array[int]:
	var neighbors: Array[int] = []
	
	var offsets: Array[Vector2i] = Globals.CARDINAL_OFFSETS if cardinal_only else Globals.ALL_OFFSETS
	for offset: Vector2i in offsets:
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


func get_tiles_global(tile_type: int) -> Array[Vector2i]:
	return Array(get_tiles(tile_type).map(func(p: Vector2i) -> Vector2i: return p + position), TYPE_VECTOR2I, "", null)


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


func rotate(cw_rotations: int) -> void:
	cw_rotations %= 4
	match cw_rotations:
		1: 
			_transpose()
			_reverse_columns()
		2:
			_reverse_columns()
			_reverse_rows()
		3:
			_transpose()
			_reverse_rows()


func _transpose() -> void:
	var data_transposed := {}
	for x: int in size.x:
		for y: int in size.y:
			data_transposed[Vector2i(y, x)] = get_tile(Vector2i(x, y))
	size = Vector2i(size.y, size.x)
	for x: int in size.x:
		for y: int in size.y:
			var p := Vector2i(x, y)
			set_tile(p, data_transposed[p])


func _reverse_columns() -> void:
	for x: int in size.x:
		var new_column: Array[int] = []
		for y: int in size.y:
			new_column.append(get_tile(Vector2i(x, size.y - 1 - y)))
		for y: int in size.y:
			set_tile(Vector2i(x, y), new_column[y])


func _reverse_rows() -> void:
	for y: int in size.y:
		var new_row: Array[int] = []
		for x: int in size.x:
			new_row.append(get_tile(Vector2i(size.x - 1 - x, y)))
		for x: int in size.x:
			set_tile(Vector2i(x, y), new_row[x])
