extends Node

var _world: World
var _slot: int = -1


#TEMPORARY
func get_map(id: int = 0) -> MapData:
	var map_data: MapData = _world.get_map(id)
	return map_data


func get_active_maps() -> Array:
	return _world.get_active_maps()


func generate_new_world(config: WorldConfig, player_info: Array[PlayerInfo], slot: int) -> void:
	_slot = slot
	SaveManager.clear_slot(slot
	)
	var world_generator := WorldGenerator.new()
	_world = world_generator.generate_world(config, player_info)


func get_world() -> World:
	return _world


func set_world(world: World, slot: int) -> void:
	_world = world
	_slot = slot


func get_current_slot() -> int:
	return _slot
