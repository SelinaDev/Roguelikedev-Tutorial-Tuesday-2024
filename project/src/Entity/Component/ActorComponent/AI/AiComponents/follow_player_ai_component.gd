class_name FollowPlayerAiComponent
extends AiComponent

@export var path: Array[Vector2i]


func get_proposed_actions(entity: Entity, target_player: Entity) -> Array[ProposedAction]:
	var entity_position := PositionComponent.get_entity_position(entity)
	if target_player:
		var player_index: int = PlayerComponent.get_player_index(target_player)
		if entity.map_data.is_in_fov(entity_position, player_index):
			var player_position := PositionComponent.get_entity_position(target_player)
			path = entity.map_data.pathfinder.get_id_path(entity_position, player_position)
			path.pop_front()
	
	if path.is_empty():
		return []
	
	var next_position: Vector2i = path.front()
	if entity.map_data.get_blocking_entity_at(next_position):
		return[]
	
	path.pop_front()
	return [
		ProposedAction.new().with_priority(ProposedAction.Priority.LOW).with_score(5).with_action(
			MovementAction.new(entity, next_position - entity_position)
		)
	]
