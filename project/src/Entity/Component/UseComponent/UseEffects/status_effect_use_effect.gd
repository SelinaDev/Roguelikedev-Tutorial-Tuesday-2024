class_name StatusEffectUseEffect
extends UseEffect

@export var status_effect: StatusEffect


func apply(entity: Entity, _source: Entity) -> bool:
	var effect: StatusEffect = status_effect.duplicate()
	entity.add_status_effect(effect)
	return true
