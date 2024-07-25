class_name DoorComponent
extends Component

@export var texture_open: AtlasTexture
@export var texture_closed: AtlasTexture
@export var transparent: bool = false
@export var open: bool = false


func process_message_execute(message: Message) -> void:
	match message.type:
		&"open":
			if not open:
				_parent_entity.remove_component(Component.Type.MovementBlocker)
				if not transparent:
					_parent_entity.remove_component(Component.Type.VisibilityBlocker)
				_parent_entity.process_message(Message.new(
					&"visual_update",
					{&"texture": texture_open}
				))
				open = true
				message.data[&"did_open"] = true
				_parent_entity.map_data.force_fov_update()
		&"close":
			if open:
				if not _parent_entity.map_data.get_entities_at(PositionComponent.get_entity_position(_parent_entity)).is_empty():
					Log.send_log(
						"The %s cannot close because there is something in the way." % _parent_entity.name,
						Log.COLOR_IMPOSSIBLE
					)
					return
				_parent_entity.enter_component(MovementBlockerComponent.new())
				if not transparent:
					_parent_entity.enter_component(VisibilityBlockerComponent.new())
				_parent_entity.process_message(Message.new(
					&"visual_update",
					{&"texture": texture_closed}
				))
				open = false
				message.data[&"did_close"] = true
				_parent_entity.map_data.force_fov_update()


func get_component_type() -> Type:
	return Type.Door
