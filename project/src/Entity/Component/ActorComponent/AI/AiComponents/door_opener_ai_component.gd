class_name DoorOpenerAiComponent
extends AiComponent


func get_proposed_actions(entity: Entity, _target_player: Entity) -> Array[ProposedAction]:
	var entity_position := PositionComponent.get_entity_position(entity)
	for offset: Vector2i in Globals.CARDINAL_OFFSETS:
		var neighbor_position := entity_position + offset
		var neighbor_entity: Entity = entity.map_data.get_blocking_entity_at(neighbor_position)
		if neighbor_entity and neighbor_entity.has_component(Component.Type.Door):
			return [
				ProposedAction.new().with_priority(ProposedAction.Priority.LOW).with_action(
					OpenAction.new(entity, offset)
				)
			]
	return []
