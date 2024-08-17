class_name DefenseEquippableEffect
extends EquippableEffect

@export var defense_bonus: int

func process_message_precalculate(message: Message) -> void:
	match message.type:
		"take_damage":
			message.get_calculation("damage").terms.append(defense_bonus * -1)
		"calculate_defense":
			message.get_calculation("defense").terms.append(defense_bonus)
