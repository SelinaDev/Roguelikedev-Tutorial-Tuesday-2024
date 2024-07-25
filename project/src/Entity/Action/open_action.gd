class_name OpenAction
extends ActionWithDirection


func perform() -> Result:
	var target: Entity = get_blocking_entity_at_destination()
	if not target:
		return Result.NoAction
	var open_message := Message.new(&"open")
	target.process_message(open_message)
	_performing_entity.process_message(Message.new(&"fov_update"))
	
	if _performing_entity.has_component(Component.Type.Player):
		if open_message.data.get(&"did_open", false):
			Log.send_log("%s opens the %s." % [_performing_entity.name, target.name])
		else:
			Log.send_log("%s could not open the %s." % [_performing_entity.name, target.name], Log.COLOR_IMPOSSIBLE)
	
	return _check_message(open_message, &"did_open")
