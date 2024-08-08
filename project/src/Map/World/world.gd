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
		map_data = maps.get(id)
		_active_maps[id] = map_data
		map_data.activate()
	
	return map_data
