class_name MovementAction
extends Action

var offset: Vector2i


func _init(performing_entity: Entity, offset: Vector2i) -> void:
	super(performing_entity)
	self.offset = offset


func perform() -> Result:
	_performing_entity.process_message(
		Message.new("move", {"offset": offset})
	)
	return Result.TurnAction
