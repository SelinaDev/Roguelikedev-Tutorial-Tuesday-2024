class_name StairsComponent
extends Component

# NOTE: If I want to have/handle multiple stairs I would also need an id for this component to link specific stairs togeter
@export_storage var target_map_index: int
@export var use_verb: String


func get_component_type() -> Type:
	return Component.Type.Stairs
