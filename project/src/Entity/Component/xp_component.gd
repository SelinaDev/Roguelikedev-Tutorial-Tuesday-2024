class_name XpComponent
extends Component

@export var xp: int


func process_message_execute(message: Message) -> void:
	match message.type:
		"died":
			var source: Entity = message.data.get("source")
			if source:
				source.process_message(Message.new("xp_received", {"xp": xp}))


func get_component_type() -> Type:
	return Type.XP
