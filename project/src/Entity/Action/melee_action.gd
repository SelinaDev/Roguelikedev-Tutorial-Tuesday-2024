class_name MeleeAction
extends ActionWithDirection

const MELEE_HIT_EFFECT = preload("res://resources/DrawableEffects/melee_hit.tres")


func perform() -> Result:
	var target: Entity = get_blocking_entity_at_destination()
	if not target:
		return Result.NoAction
	if _performing_entity == target:
		return Result.NoAction
	
	var prepare_hit_message := Message.new("prepare_hit", {"target": target})
	_performing_entity.process_message(prepare_hit_message)
	if prepare_hit_message.data.get("friendly_fire", false):
		if _performing_entity.has_component(Component.Type.Player):
			Log.send_log(
				"%s cannot attack %s (friendly fire)" % [_performing_entity.get_entity_name(), target.get_entity_name()],
				Log.COLOR_IMPOSSIBLE
			)
		return Result.NoAction
	var damage := prepare_hit_message.get_calculation("damage").get_result()
	var execute_hit_message := Message.new(
		"take_damage",
		{
			"damage_types": prepare_hit_message.data.get("damage_types", []),
			"source": _performing_entity,
		}
	)
	execute_hit_message.get_calculation("damage").base_value = damage
	target.process_message(execute_hit_message)
	target.process_message(Message.new("add_drawable_effect", {"drawable_effect": MELEE_HIT_EFFECT.duplicate()}))
	
	return _check_message(execute_hit_message, "did_hit")
