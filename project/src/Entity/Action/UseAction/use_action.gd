class_name UseAction
extends ItemAction

var _targets: Array[Entity] 


func _init(performing_entity: Entity, item: Entity, targets: Array[Entity]) -> void:
	super(performing_entity, item)
	_targets = targets


func perform() -> Result:
	var usable_component: UsableComponent = _item.get_component(Component.Type.Use)
	if not usable_component:
		Log.send_log(
			"%s cannot be used" % _item.get_entity_name(),
			Log.COLOR_IMPOSSIBLE
		)
		return Result.NoAction
	if not _category_check(usable_component):
		return Result.NoAction
	if _targets.is_empty():
		Log.send_log(
			"%s cannot use %s without a target" % [_performing_entity.get_entity_name(), _item.get_entity_name()],
			Log.COLOR_IMPOSSIBLE
		)
		return Result.NoAction
	
	return Result.TurnAction if usable_component.activate(_performing_entity, _targets) else Result.NoAction


func _category_check(_usable_component: UsableComponent) -> bool:
	return true
