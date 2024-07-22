extends Node

var _world: World


#TEMPORARY
func get_map(id: int = 0) -> MapData:
	var map_data: MapData = _world.get_map(id)
	return map_data


func get_active_maps() -> Array:
	return _world.get_active_maps()


func generate_new_world(config: WorldConfig, player_info: Array[PlayerInfo]) -> void:
	var world_generator := WorldGenerator.new()
	_world = world_generator.generate_world(config, player_info)
