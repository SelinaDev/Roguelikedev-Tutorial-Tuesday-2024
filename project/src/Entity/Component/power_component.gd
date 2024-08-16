class_name PowerComponent
extends Component

@export var base_power: int


func process_message_precalculate(message: Message) -> void:
	match message.type:
		"prepare_hit":
			message.get_calculation("damage").base_value = base_power
		"calculate_power":
			message.get_calculation("power").base_value = base_power


func process_message_execute(message: Message) -> void:
	match message.type:
		"increase_power":
			var amount: int = message.data.get("amount", 0)
			base_power += amount


func get_component_type() -> Type:
	return Type.Power
