class_name HealUseEffect
extends UseEffect

@export var amount: int


func apply(entity: Entity) -> bool:
	var heal_message := Message.new("heal")
	heal_message.get_calculation("amount").base_value = amount
	entity.process_message(heal_message)
	var actual_amount: int = heal_message.data.get("actual_amount", 0)
	return actual_amount > 0


func get_effect_description() -> String:
	return "restores %d health" % amount
