class_name EquippableComponent
extends Component

@export var effects: Array[EquippableEffect]
@export var preferred_slot: EquipmentComponent.Slot
@export var required_slots: Array[EquipmentComponent.Slot]
@export var possible_slots: Array[EquipmentComponent.Slot]

func apply_effect_precalculate(message: Message) -> void:
	for effect: EquippableEffect in effects:
		effect.process_message_precalculate(message)


func apply_effect_execute(message: Message) -> void:
	for effect: EquippableEffect in effects:
		effect.process_message_execute(message)


func _enter_entity(_entity: Entity) -> void:
	var duplicated: Array[EquippableEffect]
	for effect: EquippableEffect in effects:
		duplicated.append(effect.duplicate())
	effects = duplicated


func get_component_type() -> Type:
	return Type.Equippable
