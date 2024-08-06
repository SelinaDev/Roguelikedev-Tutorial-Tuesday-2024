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
		_parent_entity.process_message(Message.new("turn_end"))
		took_turn.emit(_parent_entity)


func get_component_type() -> Type:
	return Component.Type.Actor
