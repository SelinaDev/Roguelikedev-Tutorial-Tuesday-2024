class_name InteractAction
extends ActionWithDirection


func perform() -> Result:
	var destination := get_destination()
	var targets := _performing_entity.map_data\
		.get_entities_at(destination)\
		.filter(func(e: Entity) -> bool: return e != _performing_entity)
	
	var grab_targets := targets.filter(func(e: Entity) -> bool: return e.has_component(Component.Type.Item))
	if not grab_targets.is_empty():
		return PickupAction.new(_performing_entity, offset).perform()
	
	var open_targets := targets.filter(func(e: Entity) -> bool: return e.has_component(Component.Type.Door))
	if not open_targets.is_empty():
		return OpenAction.new(_performing_entity, offset).perform()
	
	return Result.NoAction
	
