class_name MovementAction
extends ActionWithDirection


func perform() -> Result:
	var move_message := Message.new("move", {"offset": offset})
	_performing_entity.process_message(
		move_message
	)
	return _check_message(move_message, "did_perform_move")
