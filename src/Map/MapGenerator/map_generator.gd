class_name MapGenerator
extends RefCounted

var _rng: RandomNumberGenerator


func generate_map(map_config: MapConfig, id: int, rng: RandomNumberGenerator = null, player_info: Array[PlayerInfo] = []) -> MapData:
	if rng:
		_rng = rng
	else:
		_rng = RandomNumberGenerator.new()
		_rng.randomize()
	return _generate_map(map_config, id, player_info)


func _generate_map(_map_config: MapConfig, _id: int, _player_info: Array[PlayerInfo]) -> MapData:
	return null
