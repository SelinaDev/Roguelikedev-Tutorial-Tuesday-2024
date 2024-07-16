class_name PositionComponent
extends Component


@export var position: Vector2i:
	set(value):
		var old_position := position
		position = value
		if _parent_entity:
			var message := Message.new("position_update", {"position": position, "old_position": old_position})
			_parent_entity.process_message(message)


func _enter_entity(_entity: Entity) -> void:
	position = position
	var message := Message.new("render")
	_parent_entity.process_message(message)


func process_message_precalculate(message: Message) -> void:
	match message.type:
		"render", "init_camera":
			message.data["position"] = position
		"move":
			var destination: Vector2i = position + message.data.get("offset", Vector2i.ZERO)
			var destination_tile: Tile = _parent_entity.map_data.tiles.get(destination)
			if destination_tile == null or destination_tile.blocks_movement:
				destination = position
			message.data["destination"] = destination
		"set_camera_state":
			message.data["position"] = position


func process_message_execute(message: Message) -> void:
	match message.type:
		"move":
			position = message.data.get("destination", position)


# implements Manhattan distance
func distance_to(other: Vector2i) -> int:
	var diff: Vector2i = (other - position).abs()
	return diff.x + diff.y


func get_component_type() -> Type:
	return Component.Type.Position
