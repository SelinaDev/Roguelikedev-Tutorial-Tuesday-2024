class_name MovementAction
extends ActionWithDirection


func perform() -> Result:
	_performing_entity.process_message(
		Message.new("move", {"offset": offset})
	)
	return Result.TurnAction
