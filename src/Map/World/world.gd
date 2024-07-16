class_name World
extends Resource

@export var maps: Dictionary # Dictionary[int, MapData]

var _active_maps: Dictionary


func get_map(id: int = 0) -> MapData:
	var map_data: MapData
	
	if id in _active_maps:
		map_data = _active_maps.get(id)
	else:
		map_data = maps.get(id)
		_active_maps[id] = map_data
		map_data.activate()
	
	return map_data
