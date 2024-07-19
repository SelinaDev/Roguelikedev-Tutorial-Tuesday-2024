class_name DoorComponent
extends Component

@export var texture_open: AtlasTexture
@export var texture_closed: AtlasTexture
@export var transparent: bool = false
@export var open: bool = false


func process_message_execute(message: Message) -> void:
	match message.type:
		"open":
			if not open:
				_parent_entity.remove_component(Component.Type.MovementBlocker)
				if not transparent:
					_parent_entity.remove_component(Component.Type.VisibilityBlocker)
				_parent_entity.process_message(Message.new(
					"visual_update",
					{"texture": texture_open}
				))
				open = true
		"close":
			if open:
				_parent_entity.enter_component(MovementBlockerComponent.new())
				if not transparent:
					_parent_entity.enter_component(VisibilityBlockerComponent.new())
				_parent_entity.process_message(Message.new(
					"visual_update",
					{"texture": texture_closed}
				))
				open = false


func get_component_type() -> Type:
	return Type.Door
