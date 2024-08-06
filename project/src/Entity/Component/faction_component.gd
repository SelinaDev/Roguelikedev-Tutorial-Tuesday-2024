class_name FactionComponent
extends Component

enum Faction {
	NEUTRAL,
	PLAYER,
	MONSTERS,
	LONE_WOLF,
}


@export var faction: Faction = Faction.MONSTERS


func is_friendly(entity: Entity) -> bool:
	var other_faction: FactionComponent = entity.get_component(Component.Type.Faction)
	if not other_faction:
		return false
	match faction:
		Faction.NEUTRAL:
			return true
		Faction.LONE_WOLF:
			return false
		_:
			return faction == other_faction.faction


func is_hostile(entity: Entity) -> bool:
	var other_faction: FactionComponent = entity.get_component(Component.Type.Faction)
	if not other_faction:
		return false
	match faction:
		Faction.NEUTRAL:
			return false
		Faction.LONE_WOLF:
			return true
		_:
			return faction != other_faction.faction


func process_message_precalculate(message: Message) -> void:
	match message.type:
		"prepare_hit":
			var target: Entity = message.data.get("target") as Entity
			if target and is_friendly(target):
				message.data["friendly_fire"] = true


func process_message_execute(message: Message) -> void:
	match message.type:
		"die":
			_parent_entity.remove_component(get_component_type())


func get_component_type() -> Type:
	return Component.Type.Faction
