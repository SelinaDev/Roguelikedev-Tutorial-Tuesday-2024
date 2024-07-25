class_name MovementAction
extends ActionWithDirection


func perform() -> Result:
	var move_message := Message.new(&"move", {&"offset": offset})
	_performing_entity.process_message(
		move_message
	)
	
	if _performing_entity.has_component(Component.Type.Player):
		if not move_message.data.get(&"did_perform_move", false):
			Log.send_log(
				"%s cannot move there." % _performing_entity.name,
				Log.COLOR_IMPOSSIBLE
			)
	
	return _check_message(move_message, &"did_perform_move")
