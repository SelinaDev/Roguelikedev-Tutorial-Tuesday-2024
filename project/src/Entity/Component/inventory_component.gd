class_name InventoryComponent
extends Component


@export var capacity: int = 24
@export_storage var items: Array[Entity]


func process_message_execute(message: Message) -> void:
	match message.type:
		"obtain_item":
			var item: Entity = message.data.get("item")
			if item and items.size() <= capacity:
				items.append(item)


func drop(item: Entity) -> void:
	assert(item in items)
	items.erase(item)
	var parent_position := PositionComponent.get_entity_position(_parent_entity)
	item.place_at(parent_position)
	_parent_entity.map_data.enter_entity(item)
	_parent_entity.process_message(Message.new("dropped", {"item": item}))


func get_component_type() -> Type:
	return Type.Inventory
