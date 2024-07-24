class_name OpenAction
extends ActionWithDirection


func perform() -> Result:
	var target: Entity = get_blocking_entity_at_destination()
	if not target:
		return Result.NoAction
	var open_message := Message.new("open")
	target.process_message(open_message)
	_performing_entity.process_message(Message.new("fov_update"))
	return _check_message(open_message, "did_open")
