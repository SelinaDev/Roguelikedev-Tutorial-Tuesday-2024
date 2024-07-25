class_name CloseAction
extends ActionWithDirection


func perform() -> Result:
	var targets: Array[Entity] = _performing_entity.map_data.get_entities_at(get_destination())
	if targets.is_empty():
		return Result.NoAction
	var target: Entity = targets.filter(func(entity: Entity) -> bool: return entity.has_component(Component.Type.Door)).front()
	if not target:
		return Result.NoAction
	var close_message := Message.new(&"close")
	target.process_message(close_message)
	_performing_entity.process_message(Message.new(&"fov_update"))
	
	if _performing_entity.has_component(Component.Type.Player):
		if close_message.data.get(&"did_close", false):
			Log.send_log("%s closes the %s." % [_performing_entity.name, target.name])
		else:
			Log.send_log("%s could not close the %s." % [_performing_entity.name, target.name], Log.COLOR_IMPOSSIBLE)
	
	
	return _check_message(close_message, &"did_close")
