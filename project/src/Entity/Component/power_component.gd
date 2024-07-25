class_name PowerComponent
extends Component

@export var base_power: int


func process_message_precalculate(message: Message) -> void:
	match message.type:
		&"prepare_hit":
			message.get_calculation(&"damage").base_value = base_power



func get_component_type() -> Type:
	return Type.Power
