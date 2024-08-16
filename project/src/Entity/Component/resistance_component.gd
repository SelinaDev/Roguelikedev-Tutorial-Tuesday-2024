class_name ResistanceComponent
extends Component

@export var defense: int


func process_message_precalculate(message: Message) -> void:
	match message.type:
		"take_damage":
			message.get_calculation("damage").terms.append(defense * -1)
		"calculate_defense":
			message.get_calculation("defense").base_value = defense


func process_message_execute(message: Message) -> void:
	match message.type:
		"increase_defense":
			var amount: int = message.data.get("amount", 0)
			defense += amount


func get_component_type() -> Type:
	return Type.Resistance
