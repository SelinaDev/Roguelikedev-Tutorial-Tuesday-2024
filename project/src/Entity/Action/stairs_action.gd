class_name StairsAction
extends Action

func perform() -> Result:
	var is_player := _performing_entity.has_component(Component.Type.Player)
	assert(_performing_entity.has_component(Component.Type.Player))
	var position := PositionComponent.get_entity_position(_performing_entity)
	var stairs_array := _performing_entity.map_data.get_entities_at(position).filter(
		func(e: Entity) -> bool: return e.has_component(Component.Type.Stairs)
	)
	if stairs_array.is_empty():
		if is_player:
			Log.send_log(
				"There are not stairs at %s's position" % _performing_entity.get_entity_name(),
				Log.COLOR_IMPOSSIBLE
			)
		return Action.Result.NoAction
	var stairs: Entity = stairs_array.front()
	var stairs_component: StairsComponent = stairs.get_component(Component.Type.Stairs)
	WorldManager.get_world().move_player_to_map(_performing_entity, stairs_component.target_map_index)
	if is_player:
		Log.send_log(
			"%s %s %s" % [
				_performing_entity.get_entity_name(),
				stairs_component.use_verb,
				stairs.get_entity_name()
			]
		)
	return Action.Result.FreeAction


func can_use_stairs() -> bool:
	return true
