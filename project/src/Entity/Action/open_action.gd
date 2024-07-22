class_name OpenAction
extends ActionWithDirection

var target: Entity


func _init(performing_entity: Entity, offset: Vector2i, target: Entity) -> void:
	super(performing_entity, offset)
	self.target = target


func perform() -> Result:
	if not target:
		return Result.NoAction
	var open_message := Message.new("open")
	target.process_message(open_message)
	_performing_entity.process_message(Message.new("fov_update"))
	return _check_message(open_message, "did_open")
