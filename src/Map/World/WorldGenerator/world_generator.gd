class_name WorldGenerator
extends RefCounted

var _rng: RandomNumberGenerator


func generate_world(_config: WorldConfig, players: Array[PlayerInfo], rng_seed: String = "") -> World:
	_rng = RandomNumberGenerator.new()
	if rng_seed.is_empty():
		_rng.randomize()
	else:
		_rng.seed = rng_seed.hash()
	
	var world := World.new()
	
	# TEMP
	var map_generator := MapGeneratorDungeon.new()
	var map_config := MapConfig.new()
	map_config.map_height = 40
	map_config.map_width = 40
	var map: MapData = map_generator.generate_map(map_config, 0, _rng, players)
	world.maps[0] = map
	
	return world
