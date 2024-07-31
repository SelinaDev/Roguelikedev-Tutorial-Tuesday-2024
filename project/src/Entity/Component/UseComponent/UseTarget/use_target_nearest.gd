class_name UseTargetNearest
extends UseTarget

enum TargetFaction {
	ALL,
	FRIENDLY,
	ENEMY
}

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
	var faction_component: FactionComponent = user.get_component(Component.Type.Faction)
	if faction_component and target_faction != TargetFaction.ALL:
		match target_faction:
			TargetFaction.FRIENDLY:
				targets = targets.filter(func(e: Entity) -> bool: return faction_component.is_friendly(e))
			TargetFaction.ENEMY:
				targets = targets.filter(func(e: Entity) -> bool: return faction_component.is_hostile(e))
	targets.sort_custom(
		func(a: Entity, b: Entity) -> bool:
			return user_position_component.distance_to(PositionComponent.get_entity_position(a)) > user_position_component.distance_to(PositionComponent.get_entity_position(b))
	)
	targets = targets.slice(0, max_targets)
	return targets
