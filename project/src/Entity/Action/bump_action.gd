class_name BumpAction
extends ActionWithDirection


func perform() -> Result:
	var blocking_entity := get_blocking_entity_at_destination()
	
	if blocking_entity:
		if blocking_entity.has_component(Component.Type.Door):
			return OpenAction.new(_performing_entity, offset, blocking_entity).perform()
		else:
			return MeleeAction.new(_performing_entity, offset, blocking_entity).perform()
	
	return MovementAction.new(_performing_entity, offset).perform()
