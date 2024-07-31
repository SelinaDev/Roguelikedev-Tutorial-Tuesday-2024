class_name DamageUseEffect
extends UseEffect

@export var amount: int
@export var verb: String = "damaged"


func apply(entity: Entity, source: Entity) -> bool:
	var damage_message := Message.new("take_damage", {"source": source})
	damage_message.get_calculation("damage").base_value = amount
	entity.process_message(damage_message)
	#var actual_amount: int = damage_message.data.get("actual_amount", 0)
	return true
