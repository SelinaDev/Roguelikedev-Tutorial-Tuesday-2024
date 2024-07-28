class_name ConsumableUseComponent
extends UsableComponent

@export var uses: int = 1


func activate(user: Entity, targets: Array[Entity]) -> bool:
	var did_activate := super.activate(user, targets)
	if did_activate:
		consume(user)
	return did_activate


func consume(user: Entity) -> void:
	uses -= 1
	if uses <= 0:
		var user_inventory: InventoryComponent = user.get_component(Component.Type.Inventory)
		if user_inventory:
			user_inventory.items.erase(_parent_entity)


func _get_use_description() -> String:
	var effect_descriptions: Array[String] = effects.map(func(e: UseEffect) -> String: return e.get_effect_description())
	return "When %s, it %s. This item has %d use%s left" % [
		get_use_verb_passive(),
		TextTools.concatenate_list(effect_descriptions),
		uses,
		"" if uses == 1 else "s"
	]
