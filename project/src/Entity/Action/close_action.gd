class_name CloseAction
extends ActionWithDirection


func perform() -> Result:
	var targets: Array[Entity] = _performing_entity.map_data.get_entities_at(get_destination())
	var target: Entity = targets.filter(func(entity: Entity) -> bool: return entity.has_component(Component.Type.Door)).front()
	if not target:
		return Result.NoAction
	var close_message := Message.new("close")
	target.process_message(close_message)
	_performing_entity.process_message(Message.new("fov_update"))
	return _check_message(close_message, "did_close")
