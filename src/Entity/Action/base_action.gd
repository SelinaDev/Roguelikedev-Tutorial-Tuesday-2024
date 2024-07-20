class_name Action
extends Resource

enum Result {
	TurnAction,
	FreeAction,
	NoAction
}

var _performing_entity: Entity


func _init(performing_entity: Entity) -> void:
	_performing_entity = performing_entity


func perform() -> Result:
	return Result.NoAction


func _check_message(message: Message, key: String) -> Result:
	return Result.TurnAction if message.data.get(key, false) else Result.NoAction
