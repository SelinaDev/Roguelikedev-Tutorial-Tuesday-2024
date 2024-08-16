class_name WorldGenerator
extends RefCounted

var _rng: RandomNumberGenerator


func generate_world(config: WorldConfig, players: Array[PlayerInfo], progress_callback: Callable, rng_seed: String = "") -> World:
	_rng = RandomNumberGenerator.new()
	if rng_seed.is_empty():
		_rng.randomize()
	else:
		_rng.seed = rng_seed.hash()
	
	var world := World.new()
	world.num_players = players.size()
	
	# TEMP
	
	world.player_locations = []
	world.player_locations.resize(world.num_players)
	world.player_locations.fill(0)
	
	progress_callback.call(0)
	
	for i: int in config.map_configs.size():
		var map_config: MapConfig = config.map_configs[i]
		var map_generator: MapGenerator
		match map_config.map_type:
			_: map_generator = MapGeneratorDungeon.new()
		map_config.stairs_up = i != 0
		map_config.stairs_down = i != config.map_configs.size() - 1
		var map: MapData
		if i == 0:
			map = map_generator.generate_map(map_config, i, _rng, players)
		else:
			map = map_generator.generate_map(map_config, i, _rng, [])
		world.maps[i] = map
		progress_callback.call(roundi(((i + 1) * 100.0) / config.map_configs.size()))
	
	return world
