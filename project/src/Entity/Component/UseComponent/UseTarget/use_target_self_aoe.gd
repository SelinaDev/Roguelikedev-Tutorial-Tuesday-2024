class_name UseTargetSelfAoE
extends UseTarget

@export var target_faction: TargetFaction = TargetFaction.ALL
@export var radius: int = 1


func get_targets(user: Entity) -> Array[Entity]:
    await Engine.get_main_loop().process_frame
    var targets := user.map_data.get_entities([Component.Type.Position])
    var position_component: PositionComponent = user.get_component(Component.Type.Position)
    targets = targets.filter(
        func(e: Entity) -> bool: return position_component.distance_to(PositionComponent.get_entity_position(e))
    )
    targets = filter_faction(user, targets, target_faction)
    return targets