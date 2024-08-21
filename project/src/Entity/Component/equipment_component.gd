class_name EquipmentComponent
extends Component

enum Slot {
	HEAD,
	BODY,
	NECK,
	FEET,
	CLOAK,
	MAIN_HAND,
	OFF_HAND,
	RING_1,
	RING_2
}

@export var starting_equipment: Array[Entity]
@export_storage var equipped: Dictionary


func _enter_entity(entity: Entity) -> void:
	for proto_equipment: Entity in starting_equipment:
		var equipment := proto_equipment.reify()
		equip(equipment, false)
		entity.process_message(Message.new("obtain_item", {"item": equipment}))
	starting_equipment = []


func process_message_precalculate(message: Message) -> void:
	for equippable_component: EquippableComponent in equipped.values().map(func(e: Entity) -> EquippableComponent: return e.get_component(Component.Type.Equippable)):
		equippable_component.apply_effect_precalculate(message)


func process_message_execute(message: Message) -> void:
	for equippable_component: EquippableComponent in equipped.values().map(func(e: Entity) -> EquippableComponent: return e.get_component(Component.Type.Equippable)):
		equippable_component.apply_effect_execute(message)
	match message.type:
		"dropped":
			var item: Entity = message.data.get("item")
			if is_equipped(item):
				unequip(item, false)


func is_equipped(item: Entity) -> bool:
	return item in equipped.values()


func unequip_message(item: Entity) -> void:
	Log.send_log(
		"%s unequips %s." % [_parent_entity.get_entity_name(), item.get_entity_name()],
		Log.COLOR_NEUTRAL
	)


func equip_message(item: Entity) -> void:
	Log.send_log(
		"%s equips %s." % [_parent_entity.get_entity_name(), item.get_entity_name()],
		Log.COLOR_NEUTRAL
	)


func toggle_equip(item: Entity, with_message: bool) -> void:
	if item in equipped.values():
		unequip(item, with_message)
	else:
		equip(item, with_message)


func equip(item: Entity, with_message: bool) -> void:
	var equippable: EquippableComponent = item.get_component(Component.Type.Equippable)
	assert(equippable != null)
	if equippable.possible_slots.size() > 1:
		if not equipped.has(equippable.preferred_slot):
			_equip(item, equippable.preferred_slot, equippable.required_slots, with_message)
			return
		else:
			var open_possible_slots := equippable.possible_slots.filter(func(s: Slot) -> bool: return not s in equipped)
			if not open_possible_slots.is_empty():
				_equip(item, open_possible_slots.front(), equippable.required_slots, with_message)
				return
		
		## TODO: Ask for slot (have an ask parameter
		
	else:
		_equip(item, equippable.preferred_slot, equippable.required_slots, with_message)


func _equip(item: Entity, slot: Slot, required_slots: Array[Slot], with_message: bool) -> void:
	if equipped.has(slot):
		unequip(equipped[slot], with_message)
	equipped[slot] = item
	for required_slot: int in required_slots:
		if equipped.has(required_slot):
			unequip(equipped[required_slot], with_message)
		equipped[required_slot] = item
	if with_message:
		equip_message(item)


func unequip(item: Entity, with_message: bool) -> void:
	for slot: int in equipped:
		if equipped[slot] == item:
			equipped.erase(slot)
	if with_message:
		unequip_message(item)


func get_component_type() -> Type:
	return Type.Equipment
