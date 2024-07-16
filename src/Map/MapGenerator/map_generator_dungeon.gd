class_name MapGeneratorDungeon
extends MapGenerator

enum {
	UNUSED,
	FLOOR,
	WALL,
	DOOR,
}

const ROOMS_PATH = "res://resources/MapGeneration/Dungeon/Rooms/"
const CORRIDORS_PATH = "res://resources/MapGeneration/Dungeon/Corridors/"

const CORRIDOR_CHANCE = 0.2

const FLOOR_TILE = preload("res://resources/Tiles/floor.tres")
const WALL_TILE = preload("res://resources/Tiles/wall.tres")
const PLAYER = preload("res://resources/Entities/Actors/player.tres")

var _dungeon: Room
var _rooms: Array[Room]

func _generate_map(map_config: MapConfig, id: int, player_info: Array[PlayerInfo]) -> MapData:
	var map_data := MapData.new(id, map_config.map_width, map_config.map_height, FLOOR_TILE)
	
	_generate_dungeon(map_config)
	_dungeon_to_map(map_data)
	
	var player_start_pos: Vector2i
	var first_room: Room = _rooms.front()
	var first_room_floor := first_room.get_tiles(FLOOR)
	player_start_pos = first_room.position + first_room_floor[_rng.randi() % first_room_floor.size()]
	
	for player: PlayerInfo in player_info:
		var player_entity := PLAYER.reify()
		var player_component: PlayerComponent = player_entity.get_component(Component.Type.Player)
		player_component.player_info = player
		player.player_entity = player_entity
		map_data.entities.append(player_entity)
		player_entity.map_data = map_data
		var start_position := player_start_pos + Vector2i(player.player_index, 0)
		var position_component := PositionComponent.new()
		player_entity.enter_component(position_component)
		position_component.position = start_position
		var actor_component: PlayerActorComponent = player_entity.get_component(Component.Type.Actor)
		actor_component.set_device(player.device)
		var player_camera := PlayerCamera.new(player)
		player_entity.process_message(
			Message.new(
				"set_camera_state", 
				{"camera_state": player_camera.obtain_state()}
			)
		)
		
	return map_data


func _dungeon_to_map(map_data: MapData) -> void:
	for x: int in _dungeon.size.x:
		for y: int in _dungeon.size.y:
			var tile_position := Vector2i(x, y)
			var tile: Tile
			if _dungeon.get_tile(tile_position) == FLOOR:
				tile = FLOOR_TILE.duplicate()
			else:
				tile = WALL_TILE.duplicate()
			map_data.tiles[tile_position] = tile
	for x: int in range(-1, _dungeon.size.x + 1):
		map_data.tiles[Vector2i(x, -1)] = WALL_TILE.duplicate()
		map_data.tiles[Vector2i(x, _dungeon.size.y)] = WALL_TILE.duplicate()
	for y: int in range(-1, _dungeon.size.y + 1):
		map_data.tiles[Vector2i(-1, y)] = WALL_TILE.duplicate()
		map_data.tiles[Vector2i(_dungeon.size.x, y)] = WALL_TILE.duplicate()


func _generate_dungeon(map_config: MapConfig) -> Room:
	_dungeon = Room.new()
	_dungeon.initialize(Vector2i(map_config.map_width, map_config.map_height), UNUSED)
	_rooms = []
	
	var candidates: Array[Vector2i] = []
	
	var prototype_rooms := _load_rooms(ROOMS_PATH)
	var prototype_corridors := _load_rooms(CORRIDORS_PATH)
	
	_place_first_room(prototype_rooms[_rng.randi() % prototype_rooms.size()])
	
	var tries := 0
	
	while _rooms.size() <= map_config.max_rooms and tries <= map_config.max_tries:
		var use_corridor := _rng.randf() <= CORRIDOR_CHANCE
		
		candidates = []
		for x: int in _dungeon.size.x:
			for y: int in _dungeon.size.y:
				var position := Vector2i(x, y)
				if _is_candidate(position):
					candidates.append(position)
		
		var candidate: Vector2i = candidates[_rng.randi() % candidates.size()]
		
		var new_room_prototype: Room
		if use_corridor:
			new_room_prototype = prototype_corridors[_rng.randi() % prototype_corridors.size()]
		else:
			new_room_prototype = prototype_rooms[_rng.randi() % prototype_rooms.size()]
		
		var direction: Vector2i
		var found_direction := false
		for offset: Vector2i in [Vector2i.RIGHT, Vector2i.UP, Vector2i.LEFT, Vector2i.DOWN]:
			if not _dungeon.is_in_bounds(candidate + offset):
				continue
			if _dungeon.get_tile(candidate + offset) == UNUSED:
				direction = offset
				found_direction = true
				break
		if not found_direction:
			continue
		
		var room_offsets: Array[Vector2i] = new_room_prototype.get_outer_tiles(direction * -1, FLOOR)
		var room_offset: Vector2i = room_offsets[_rng.randi() % room_offsets.size()]
		var room_position := candidate + direction - room_offset
		var new_room := _duplicate_room_at(new_room_prototype, room_position)
		
		if not _does_room_fit(new_room):
			continue
		
		if not _check_room(new_room):
			continue
		
		_place_room(new_room, not use_corridor)
		_dungeon.set_tile(candidate, FLOOR)
	
	for x: int in _dungeon.size.x:
		for y: int in _dungeon.size.y:
			var position := Vector2i(x, y)
			if _dungeon.get_tile(position) == UNUSED:
				_dungeon.set_tile(position, WALL)
	
	return _dungeon


func _place_first_room(prototype: Room) -> void:
	var first_room_pos := Vector2i(
		_rng.randi_range(0, _dungeon.size.x - prototype.size.x),
		_rng.randi_range(0, _dungeon.size.y - prototype.size.y)
	)
	var first_room := _duplicate_room_at(prototype, first_room_pos)
	_place_room(first_room, true)


func _place_room(room: Room, is_room: bool) -> void:
	for x: int in room.size.x:
		for y: int in room.size.y:
			var position := Vector2i(x, y)
			var target_position := room.position + position
			_dungeon.set_tile(target_position, room.get_tile(position))
	_make_border(room)
	if is_room:
		_rooms.append(room)


func _make_border(room: Room) -> void:
	for x: int in room.size.x:
		for y: int in room.size.y:
			var room_position := Vector2i(x, y)
			var target_position := room.position + room_position
			if room.get_tile(room_position) == UNUSED:
				continue
			for offset: Vector2i in [Vector2i.RIGHT, Vector2i.UP, Vector2i.LEFT, Vector2i.DOWN]:
				var neighbor_position := target_position + offset
				if not _dungeon.is_in_bounds(neighbor_position):
					continue
				if _dungeon.get_tile(neighbor_position) == UNUSED:
					_dungeon.set_tile(neighbor_position, WALL)

func _check_room(room: Room) -> bool:
	for x: int in room.size.x:
		for y: int in room.size.y:
			var position := Vector2i(x, y)
			var target_position := room.position + position
			if _dungeon.get_tile(target_position) != UNUSED and room.get_tile(position) != UNUSED:
				return false
	return true


func _does_room_fit(room: Room) -> bool:
	if room.position.x < 0 or room.position.y < 0:
		return false
	var room_end := room.position + room.size
	if room_end.x >= _dungeon.size.x or room_end.y >= _dungeon.size.y:
		return false
	return true


func _load_rooms(path: String) -> Array[Room]:
	var rooms_array: Array[Room] = []
	var dir := DirAccess.open(path)
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		rooms_array.append(_load_room(path.path_join(file_name)))
		file_name = dir.get_next()
	return rooms_array


func _load_room(path: String) -> Room:
	var file := FileAccess.open(path, FileAccess.READ)
	var proto_data: Array[int] = []
	var proto_size := Vector2i.ZERO
	
	var lines = file.get_as_text(true).split("\n")

	for line: String in lines:
		if line.is_empty():
			continue
		proto_size.y += 1
		if proto_size.y == 1:
			proto_size.x = line.length()
		for i: int in line.length():
			var tile: int = -1
			match line[i]:
				".": tile = FLOOR
				"#": tile = WALL
				"+": tile = DOOR
				"x": tile = UNUSED
			if tile == -1: continue
			proto_data.append(tile)
	
	var new_room := Room.new()
	new_room.initialize(proto_size, 0)
	new_room.data = proto_data
	return new_room


func _is_candidate(p: Vector2i) -> bool:
	if _dungeon.get_tile(p) != WALL:
		return false
	var neighbors := _dungeon.get_neighbors(p, WALL)
	for i: int in 2:
		if neighbors[0 + i] == WALL and neighbors[2 + i] == WALL:
			if (neighbors[1 + i] == FLOOR and neighbors[(3 + i) % 4] == UNUSED) or (neighbors[1 + i] == UNUSED and neighbors[(3 + i) % 4] == FLOOR):
				return true
	return false


func _duplicate_room_at(room: Room, position: Vector2i) -> Room:
	var new_room = room.duplicate()
	new_room.position = position
	return new_room
