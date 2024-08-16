class_name World
extends Resource

@export_storage var maps: Dictionary # Dictionary[int, MapData]
@export_storage var num_players: int
@export_storage var player_locations: Array[int]

var _active_maps: Dictionary


func get_active_maps() -> Array:
	return _active_maps.values()


func is_map_active(id: int) -> bool:
	return id in _active_maps


func get_map(id: int = 0) -> MapData:
	var map_data: MapData
	
	if id in _active_maps:
		map_data = _active_maps.get(id)
	else:
		map_data = maps[id]
		_active_maps[id] = map_data
		map_data.activate()
	
	return map_data


func deactivate() -> void:
	for map: MapData in _active_maps.values():
		map.deactivate()


func move_player_to_map(player: Entity, to_index: int) -> void:
	var player_index := PlayerComponent.get_player_index(player)
	var player_info := PlayerComponent.get_player_info(player)
	var current_location: int = player_locations[player_index]
	var old_map: MapData = get_map(current_location)
	var new_map: MapData = get_map(to_index)
	old_map.remove_entity(player)
	player_locations[player_index] = to_index
	var stairs_array := new_map.get_entities([Component.Type.Position, Component.Type.Stairs])\
		.filter(func(e: Entity) -> bool: return (e.get_component(Component.Type.Stairs) as StairsComponent).target_map_index == current_location)
	assert(stairs_array.size() == 1)
	var stairs: Entity = stairs_array.front()
	new_map.enter_entity(player)
	player.place_at(PositionComponent.get_entity_position(stairs))
	RenderingServer.viewport_remove_canvas(player_info.sub_viewport.get_viewport_rid(), old_map.canvas)
	RenderingServer.viewport_attach_canvas(player_info.sub_viewport.get_viewport_rid(), new_map.canvas)
	player.process_message(Message.new("fov_update"))
	player.process_message(Message.new("render", {"canvas": new_map.canvas}))
	if not old_map.id in player_locations:
		old_map.deactivate()
		_active_maps.erase(old_map.id)


func get_player_entities() -> Array[Entity]:
	var players: Array[Entity] = []
	
	for player_index: int in num_players:
		var location: int = player_locations[player_index]
		var map: MapData = maps[location]
		assert(map != null)
		var player_array := map.get_entities([Component.Type.Player]).filter(
			func(e: Entity) -> bool: return PlayerComponent.get_player_index(e) == player_index
		)
		assert(player_array.size() == 1)
		players.append(player_array.front())
	
	return players


func get_player(index: int) -> Entity:
	var location: int = player_locations[index]
	var map: MapData = maps[location]
	var player_array := map.get_entities([Component.Type.Player]).filter(
		func(e: Entity) -> bool: return PlayerComponent.get_player_index(e) == index
	)
	assert(player_array.size() == 1)
	return player_array.front()
