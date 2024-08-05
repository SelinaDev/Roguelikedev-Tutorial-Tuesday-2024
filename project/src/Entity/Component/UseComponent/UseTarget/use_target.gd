class_name UseTarget
extends Resource

enum TargetFaction {
	ALL,
	WITH_FACTION,
	FRIENDLY,
	ENEMY
}


func get_targets(_user: Entity) -> Array[Entity]:
	await _wait_a_tick()
	return []


func _wait_a_tick() -> void:
	await Engine.get_main_loop().process_frame


func get_target_string() -> String:
	return ""


static func filter_faction(from: Entity, potential_targets: Array[Entity], target_faction: TargetFaction) -> Array[Entity]:
	if target_faction == TargetFaction.ALL:
		return potential_targets
	if target_faction == TargetFaction.WITH_FACTION:
		return potential_targets.filter(func(e: Entity) -> bool: return e.has_component(Component.Type.Faction))
	var faction_component: FactionComponent = from.get_component(Component.Type.Faction)
	if not faction_component:
		return potential_targets
	if target_faction == TargetFaction.FRIENDLY:
		return potential_targets.filter(func(e: Entity) -> bool: return faction_component.is_friendly(e))
	if target_faction == TargetFaction.ENEMY:
		return potential_targets.filter(func(e: Entity) -> bool: return faction_component.is_hostile(e))
	return potential_targets
