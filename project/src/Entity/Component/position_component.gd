class_name PositionComponent
extends Component


@export var position: Vector2i:
	set(value):
		var old_position := position
		position = value
		if _parent_entity:
			var message := Message.new(&"position_update", {&"position": position, &"old_position": old_position})
			_parent_entity.process_message(message)


static func get_entity_position(entity: Entity) -> Vector2i:
	var position_component: PositionComponent = entity.get_component(Component.Type.Position)
	assert(position_component != null)
	return position_component.position


func _enter_entity(_entity: Entity) -> void:
	pass


func process_message_precalculate(message: Message) -> void:
	match message.type:
		&"render", &"fov_update", &"fov_updated", &"pathfinder_update":
			message.data[&"position"] = position
		&"move":
			var destination: Vector2i = position + message.data.get(&"offset", Vector2i.ZERO)
			var destination_tile: Tile = _parent_entity.map_data.tiles.get(destination)
			if destination_tile == null or destination_tile.blocks_movement or _parent_entity.map_data.get_blocking_entity_at(destination) != null:
				destination = position
			message.data[&"destination"] = destination
		&"set_camera_state":
			message.data[&"position"] = position


func process_message_execute(message: Message) -> void:
	match message.type:
		&"move":
			var old_position := position
			position = message.data.get(&"destination", position)
			message.data[&"did_perform_move"] = old_position != position


# implements Manhattan distance
func distance_to(other: Vector2i) -> int:
	var diff: Vector2i = (other - position).abs()
	return diff.x + diff.y


func get_component_type() -> Type:
	return Component.Type.Position
