class_name DropAction
extends ItemAction


func perform() -> Result:
	var inventory: InventoryComponent = _performing_entity.get_component(Component.Type.Inventory)
	if not inventory:
		return Result.NoAction
	inventory.drop(_item)
	return Result.TurnAction
