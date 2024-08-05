class_name UseTargetNearest
extends UseTarget

@export var max_range: int = 1
@export var target_faction: TargetFaction = TargetFaction.ALL
@export var max_targets: int = 1


func get_targets(user: Entity) -> Array[Entity]:
	await _wait_a_tick()
	var user_position_component: PositionComponent = user.get_component(Component.Type.Position)
	var targets := user.map_data.get_entities([Component.Type.Position, Component.Type.Durability])\
		.filter(func(e: Entity) -> bool: 
			return user_position_component.distance_to(PositionComponent.get_entity_position(e)) <= max_range)\
		.filter(func(e: Entity) -> bool: return e != user)
	targets = filter_faction(user, targets, target_faction)
	targets.sort_custom(
		func(a: Entity, b: Entity) -> bool:
			return user_position_component.distance_to(PositionComponent.get_entity_position(a)) < user_position_component.distance_to(PositionComponent.get_entity_position(b))
	)
	targets = targets.slice(0, max_targets)
	return targets
