class_name DrinkAction
extends UseAction


func _category_check(usable_component: UsableComponent) -> bool:
	var is_drinkable := usable_component.usage_type == UsableComponent.UsageType.DRINK
	if not is_drinkable:
		Log.send_log("The %s cannot be drunk." % _item.get_entity_name(), Log.COLOR_IMPOSSIBLE)
	return is_drinkable
