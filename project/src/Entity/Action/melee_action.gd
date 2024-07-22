class_name MeleeAction
extends ActionWithDirection

var target: Entity


func _init(performing_entity: Entity, offset: Vector2i, target: Entity) -> void:
	super(performing_entity, offset)
	self.target = target


func perform() -> Result:
	if not target:
		return Result.NoAction
	
	print("You punch the %s" % target.name)
	
	return Result.TurnAction
