class_name MapGeneratorDungeon
extends MapGenerator

const CORRIDOR_CHANCE = 0.2

const TILE_DB = preload("res://resources/ResourceDBs/Tile_db.tres")
const ENTITY_DB = preload("res://resources/ResourceDBs/Entity_db.tres")
const ROOM_PACK_DB = preload("res://resources/ResourceDBs/RoomPack_db.tres")

var _dungeon: Room
var _rooms: Array[Room]

func _generate_map(map_config: MapConfig, id: int, player_info: Array[PlayerInfo]) -> MapData:
	var map_data := MapData.new(id, map_config.map_width, map_config.map_height, TILE_DB.entries.get("floor"))
	
	_generate_dungeon(map_config)
	_dungeon_to_map(map_data, map_config)
	
	_place_entities(map_data, map_config)
	
	var player_start_pos: Vector2i
	var first_room: Room = _rooms.front()
	var first_room_floor := first_room.get_tiles(Room.FLOOR)
	player_start_pos = first_room.position + first_room_floor[_rng.randi() % first_room_floor.size()]
	
	for player: PlayerInfo in player_info:
		var player_entity: Entity = ENTITY_DB.entries.get("player").reify()
		var player_component: PlayerComponent = player_entity.get_component(Component.Type.Player)
		player_component.player_info = player
		player.player_entity = player_entity
		map_data.enter_entity(player_entity)
		var start_position := player_start_pos + Vector2i(player.player_index, 0)
		player_entity.place_at(start_position)
		var actor_component: PlayerActorComponent = player_entity.get_component(Component.Type.Actor)
		actor_component.set_device(player.device)
		var player_camera := PlayerCamera.new(player)
		player_entity.process_message(
			Message.new(
				"set_camera_state", 
				{"camera_state": player_camera.obtain_state()}
			)
		)
		player_entity.process_message(Message.new("fov_update"))
		
	return map_data


func _dungeon_to_map(map_data: MapData, map_config: MapConfig) -> void:
	for x: int in _dungeon.size.x:
		for y: int in _dungeon.size.y:
			var tile_position := Vector2i(x, y)
			var tile: Tile
			match _dungeon.get_tile(tile_position):
				Room.DOOR:
					tile = TILE_DB.entries.get("floor").duplicate()
					map_data.enter_entity(ENTITY_DB.entries.get("door").reify().place_at(tile_position))
				Room.WALL:
					tile = TILE_DB.entries.get("wall").duplicate()
					map_config.wall_variation.modify(tile, _rng)
				Room.BARS:
					tile = TILE_DB.entries.get("bars").duplicate()
				_:
					tile = TILE_DB.entries.get("floor").duplicate()
					map_config.floor_variation.modify(tile, _rng)
			
			map_data.tiles[tile_position] = tile


func _generate_dungeon(map_config: MapConfig) -> Room:
	_dungeon = Room.new()
	_dungeon.initialize(Vector2i(map_config.map_width, map_config.map_height), Room.UNUSED)
	_rooms = []
	
	var candidates: Array[Vector2i] = []
	
	var room_pack: RoomPack = ROOM_PACK_DB.entries.get(map_config.room_pack)
	var prototype_rooms: Array[Room] = room_pack.rooms
	var prototype_corridors: Array[Room] = room_pack.corridors
	
	_place_first_room(prototype_rooms[_rng.randi() % prototype_rooms.size()])
	
	var tries := 0
	
	while _rooms.size() <= map_config.max_rooms and tries <= map_config.max_tries:
		tries += 1
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
			if _dungeon.get_tile(candidate + offset) == Room.UNUSED:
				direction = offset
				found_direction = true
				break
		if not found_direction:
			continue
		
		var new_room_prototype_rotated := new_room_prototype.duplicate()
		new_room_prototype_rotated.rotate(_rng.randi())
		var room_offsets: Array[Vector2i] = new_room_prototype_rotated.get_outer_tiles(direction * -1, Room.FLOOR)
		var room_offset: Vector2i = room_offsets[_rng.randi() % room_offsets.size()]
		var room_position := candidate + direction - room_offset
		var new_room := _duplicate_room_at(new_room_prototype_rotated, room_position)
		
		if not _does_room_fit(new_room):
			continue
		
		if not _check_room(new_room):
			continue
		
		_place_room(new_room, not use_corridor)
		_dungeon.set_tile(candidate, Room.DOOR)
	
	for x: int in _dungeon.size.x:
		for y: int in _dungeon.size.y:
			var position := Vector2i(x, y)
			if _dungeon.get_tile(position) == Room.UNUSED:
				_dungeon.set_tile(position, Room.WALL)
	
	_remove_dead_ends()
	
	return _dungeon


func _place_first_room(prototype: Room) -> void:
	var first_room_pos := Vector2i(
		_rng.randi_range(1, _dungeon.size.x - prototype.size.x - 1),
		_rng.randi_range(1, _dungeon.size.y - prototype.size.y - 1)
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
			if room.get_tile(room_position) == Room.UNUSED:
				continue
			for offset: Vector2i in Globals.ALL_OFFSETS:
				var neighbor_position := target_position + offset
				if not _dungeon.is_in_bounds(neighbor_position):
					continue
				if _dungeon.get_tile(neighbor_position) == Room.UNUSED:
					_dungeon.set_tile(neighbor_position, Room.WALL)


func _check_room(room: Room) -> bool:
	for x: int in room.size.x:
		for y: int in room.size.y:
			var position := Vector2i(x, y)
			var target_position := room.position + position
			if _dungeon.get_tile(target_position) != Room.UNUSED and room.get_tile(position) != Room.UNUSED:
				return false
	return true


func _does_room_fit(room: Room) -> bool:
	if room.position.x < 1 or room.position.y < 1:
		return false
	var room_end := room.position + room.size
	if room_end.x + 1 >= _dungeon.size.x or room_end.y + 1>= _dungeon.size.y:
		return false
	return true


func _is_candidate(p: Vector2i) -> bool:
	if _dungeon.get_tile(p) != Room.WALL:
		return false
	var neighbors := _dungeon.get_neighbors(p, Room.WALL)
	for i: int in 2:
		if neighbors[0 + i] == Room.WALL and neighbors[2 + i] == Room.WALL:
			if (neighbors[1 + i] == Room.FLOOR and neighbors[(3 + i) % 4] == Room.UNUSED) or (neighbors[1 + i] == Room.UNUSED and neighbors[(3 + i) % 4] == Room.FLOOR):
				return true
	return false


func _duplicate_room_at(room: Room, position: Vector2i) -> Room:
	var new_room = room.duplicate()
	new_room.position = position
	return new_room


func _is_dead_end(tile_position: Vector2i) -> bool:
	if not _dungeon.get_tile(tile_position) in [Room.FLOOR, Room.DOOR]:
		return false
	var neighbors := _dungeon.get_neighbors(tile_position, Room.WALL)
	return neighbors.reduce(func(accum: int, tile: int) -> int: return accum + int(tile == Room.WALL), 0) == 3


func _remove_dead_end(tile_position: Vector2i) -> void:
	_dungeon.set_tile(tile_position, Room.WALL)
	for offset: Vector2i in Globals.CARDINAL_OFFSETS:
		var neighbor := tile_position + offset
		if _is_dead_end(neighbor):
			_remove_dead_end(neighbor)


func _remove_dead_ends() -> void:
	for x: int in _dungeon.size.x:
		for y: int in _dungeon.size.y:
			var tile_position := Vector2i(x, y)
			if _is_dead_end(tile_position):
				_remove_dead_end(tile_position)

func _add_extra_doors() -> void:
	for x: int in _dungeon.size.x:
		for y: int in _dungeon.size.y:
			var tile_position := Vector2i(x, y)
			if _dungeon.get_tile(tile_position) != Room.WALL:
				continue
			var neighbors := _dungeon.get_neighbors(tile_position, Room.WALL, false)
			var num_walls: int = neighbors.reduce(func(accum: int, tile: int) -> int: return accum + int(tile == Room.WALL), 0)
			if num_walls != 2:
				continue
			var opposing_horizontally := neighbors[0] == Room.WALL and neighbors[4] == Room.WALL
			var opposing_vertically := neighbors[2] == Room.WALL and neighbors[6] == Room.WALL
			if opposing_horizontally or opposing_vertically:
				_dungeon.set_tile(tile_position, Room.FLOOR)


func _place_entities(map_data: MapData, map_config: MapConfig) -> void:
	for room: Room in _rooms.slice(1):
		_place_entities_in_room(map_data, map_config, room)


func _place_entities_in_room(map_data: MapData, map_config: MapConfig, room: Room) -> void:
	var num_enemies: int = _rng.randi() % map_config.max_enemies_per_room + 1
	var room_tiles := room.get_tiles_global(Room.FLOOR)
	
	for _i in num_enemies:
		var enemy_position: Vector2i = room_tiles.pop_at(_rng.randi() % room_tiles.size())
		var enemy_type = "orc" if _rng.randf() < 0.5 else "goblin"
		var enemy: Entity = ENTITY_DB.entries.get(enemy_type).reify()
		enemy.place_at(enemy_position)
		map_data.enter_entity(enemy)
