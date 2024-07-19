class_name OpenAction
extends ActionWithDirection

var target: Entity


func _init(performing_entity: Entity, offset: Vector2i, target: Entity) -> void:
	super(performing_entity, offset)
	self.target = target


func perform() -> Result:
	if not target:
		return Result.NoAction
	target.process_message(Message.new("open"))
	_performing_entity.process_message(Message.new("fov_update"))
	return Result.TurnAction
