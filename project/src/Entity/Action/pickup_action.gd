class_name PickupAction
extends ActionWithDirection


func perform() -> Result:
	if not _performing_entity.has_component(Component.Type.Inventory):
		Log.send_log(
			"%s cannot pick up items." % _performing_entity.get_entity_name().capitalize(),
			Log.COLOR_IMPOSSIBLE
		)
		return Result.NoAction
	var targets: Array[Entity] = _performing_entity.map_data\
		.get_entities_at(PositionComponent.get_entity_position(_performing_entity) + offset)\
		.filter(func(e: Entity) -> bool: return e.has_component(Component.Type.Item))
	
	if targets.is_empty():
		Log.send_log(
			"Nothing to pick up at %s's location" % _performing_entity.get_entity_name(),
			Log.COLOR_IMPOSSIBLE
		)
	
	var did_pick_up := false
	var inventory: InventoryComponent = _performing_entity.get_component(Component.Type.Inventory)
	
	for item: Entity in targets:
		did_pick_up = _perform_pickup(inventory, item) or did_pick_up
	
	return Result.TurnAction if did_pick_up else Result.NoAction


func _perform_pickup(inventory: InventoryComponent, item: Entity) -> bool:
	if inventory.items.size() >= inventory.capacity:
		Log.send_log(
			"%s cannot pick up %s (inventory is full)" % [_performing_entity.get_entity_name().capitalize(), item.get_entity_name()],
			Log.COLOR_IMPOSSIBLE
		)
		return false
	_performing_entity.map_data.remove_entity(item)
	inventory.items.append(item)
	Log.send_log(
		"%s picked up %s" % [_performing_entity.get_entity_name().capitalize(), item.get_entity_name()]
	)
	return true
