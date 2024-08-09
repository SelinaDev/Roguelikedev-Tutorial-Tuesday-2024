class_name World
extends Resource

@export_storage var maps: Dictionary # Dictionary[int, MapData]
@export_storage var num_players: int
@export_storage var player_locations: Array[int]

var _active_maps: Dictionary


func get_active_maps() -> Array:
	return _active_maps.values()


func get_map(id: int = 0) -> MapData:
	var map_data: MapData
	
	if id in _active_maps:
		map_data = _active_maps.get(id)
	else:
		map_data = maps[id]
		_active_maps[id] = map_data
		map_data.activate()
	
	return map_data


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
