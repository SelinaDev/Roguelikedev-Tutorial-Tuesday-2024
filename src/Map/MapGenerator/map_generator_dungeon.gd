class_name MapGeneratorDungeon
extends MapGenerator

const FLOOR = preload("res://resources/Tiles/floor.tres")
const WALL = preload("res://resources/Tiles/wall.tres")
const PLAYER = preload("res://resources/Entities/Actors/player.tres")


func _generate_map(map_config: MapConfig, id: int, player_info: Array[PlayerInfo]) -> MapData:
	var map_data := MapData.new(id, map_config.map_width, map_config.map_height, FLOOR)
	for x: int in range(14, 17):
		var tile_position := Vector2i(x, 7)
		map_data.tiles[tile_position] = WALL.duplicate()
	
	for player: PlayerInfo in player_info:
		var player_entity := PLAYER.reify()
		var player_component: PlayerComponent = player_entity.get_component(Component.Type.Player)
		player_component.player_info = player
		player.player_entity = player_entity
		map_data.entities.append(player_entity)
		player_entity.map_data = map_data
		var start_position := Vector2i(10 + player.player_index, 10)
		var position_component := PositionComponent.new()
		player_entity.enter_component(position_component)
		position_component.position = start_position
		var actor_component: PlayerActorComponent = player_entity.get_component(Component.Type.Actor)
		actor_component.set_device(player.device)
		var player_camera := PlayerCamera.new(player)
		player_entity.process_message(
			Message.new(
				"set_camera_state", 
				{"camera_state": player_camera.obtain_state()}
			)
		)
		
	return map_data
