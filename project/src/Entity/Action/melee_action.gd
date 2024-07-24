class_name MeleeAction
extends ActionWithDirection

func perform() -> Result:
	var target: Entity = get_blocking_entity_at_destination()
	if not target:
		return Result.NoAction
	
	var prepare_hit_message := Message.new("prepare_hit")
	_performing_entity.process_message(prepare_hit_message)
	var damage := prepare_hit_message.get_calculation("damage").get_result()
	var execute_hit_message := Message.new(
		"take_damage",
		{
			"damage_types": prepare_hit_message.data.get("damage_types", []),
			"source": _performing_entity
		}
	)
	execute_hit_message.get_calculation("damage").base_value = damage
	target.process_message(execute_hit_message)
	
	return _check_message(execute_hit_message, "did_hit")
