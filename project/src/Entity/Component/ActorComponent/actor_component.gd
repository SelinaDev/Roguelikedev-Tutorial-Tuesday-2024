class_name ActorComponent
extends Component

signal took_turn(entity)

var _queued_action: Action = null


func get_action() -> Action:
	var next_action: Action = _queued_action
	_queued_action = null
	return next_action


func receive_action_result(result: Action.Result) -> void:
	if result == Action.Result.TurnAction:
		took_turn.emit(_parent_entity)


func get_point_path_to(destination: Vector2i) -> PackedVector2Array:
	var position_component: PositionComponent = _parent_entity.get_component(Component.Type.Position)
	if not position_component:
		return []
	return _parent_entity.map_data.pathfinder.get_point_path(position_component.position, destination)


func get_component_type() -> Type:
	return Component.Type.Actor
