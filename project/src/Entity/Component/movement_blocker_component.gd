class_name MovementBlockerComponent
extends Component


func _enter_entity(entity: Entity) -> void:
	entity.process_message(Message.new("pathfinder_update"))


func before_exit() -> void:
	_parent_entity.process_message(Message.new("pathfinder_update", {"solid": false}))


func process_message_execute(message: Message) -> void:
	match message.type:
		"enter_map":
			_parent_entity.process_message(Message.new("pathfinder_update"))
		"exit_map":
			_parent_entity.map_data.pathfinder_set_point(message.data.get("position"), false)
		"pathfinder_update":
			if not message.data.has("position"):
				return
			var solid: bool = message.data.get("solid", true)
			if not _parent_entity.map_data:
				return
			_parent_entity.map_data.pathfinder_set_point(message.data.get("position"), solid)
		"position_update":
			if not _parent_entity.map_data:
				return
			_parent_entity.map_data.pathfinder_set_point(message.data.get("position"), true)
			_parent_entity.map_data.pathfinder_set_point(message.data.get("old_position"), false)


func get_component_type() -> Type:
	return Type.MovementBlocker
