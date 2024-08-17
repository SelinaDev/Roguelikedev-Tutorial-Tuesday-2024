class_name EquipAction
extends ItemAction


func perform() -> Result:
	if not _item.has_component(Component.Type.Equippable):
		Log.send_log(
			"%s cannot be equipped." % _item.get_entity_name().capitalize(),
			Log.COLOR_IMPOSSIBLE
		)
		return Result.NoAction
	
	var equipment: EquipmentComponent = _performing_entity.get_component(Component.Type.Equipment)
	if not equipment:
		Log.send_log(
			"%s cannot use equipment." % _item.get_entity_name().capitalize(),
			Log.COLOR_IMPOSSIBLE
		)
		return Result.NoAction
	
	# NOTE: Change to use message system for cursed items
	equipment.toggle_equip(_item, true)
	
	return Result.TurnAction
