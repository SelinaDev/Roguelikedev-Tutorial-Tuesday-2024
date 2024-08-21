class_name PowerEquippableEffect
extends EquippableEffect

@export var power_bonus: int

func process_message_precalculate(message: Message) -> void:
	match message.type:
		"prepare_hit":
			message.get_calculation("damage").terms.append(power_bonus)
		"calculate_power":
			message.get_calculation("power").terms.append(power_bonus)
