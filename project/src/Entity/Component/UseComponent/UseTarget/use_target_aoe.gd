class_name UseTargetAoE
extends UseTarget

@export var max_range: int = 1
@export var target_faction: TargetFaction = TargetFaction.ALL
@export var line_config: LineConfig
@export var radius: int = 1


func get_targets(user: Entity) -> Array[Entity]:
    var reticle := Reticle.new()\
        .setup(user)\
        .with_range(max_range)\
        .with_target_faction(target_faction)\
        .with_radius(radius)\
        .with_target_info()
    if line_config:
        reticle.with_line(line_config)
    return await reticle.targets_selected